#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Darwin
import Network

/// Allows to find net services on local network.
@available(iOS 13.0, macOS 10.15, *)
class BonsoirServiceDiscovery: BonsoirAction {
    /// The type we're listening to.
    private let type: String
    
    /// The current browser instance.
    private let browser: NWBrowser
    
    /// Contains all found services.
    private var services: [BonsoirService] = []
    
    /// Contains all services we're currently resolving.
    private var pendingResolution: [DNSServiceRef] = []

    /// Contains all services whose hostnames are currently resolving.
    private var pendingAddressResolution: [String: BonsoirService] = [:]

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger, type: String) {
        self.type = type
        browser = NWBrowser(for: .bonjourWithTXTRecord(type: type, domain: "local."), using: .tcp)
        super.init(id: id, action: "discovery", logMessages: Generated.discoveryMessages, printLogs: printLogs, onDispose: onDispose, messenger: messenger)
        browser.stateUpdateHandler = stateHandler
        browser.browseResultsChangedHandler = browseHandler
    }
    
    /// Finds a service amongst discovered services.
    private func findService(_ name: String, _ type: String? = nil) -> BonsoirService? {
        return services.first(where: { $0.name == name && (type == nil || $0.type == type) })
    }
    
    /// Handles state changes.
    func stateHandler(_ newState: NWBrowser.State) {
        switch newState {
        case .ready:
            onSuccess(eventId: Generated.discoveryStarted, parameters: [type])
        case .failed(let error):
            let details: Any?
            if #available(iOS 16.4, macOS 13.3, *) {
                details = error.errorCode
            } else {
                details = error.debugDescription
            }
            onError(parameters: [error], details: details)
            dispose()
        case .cancelled:
            onSuccess(eventId: Generated.discoveryStopped, parameters: [type])
            dispose()
        default:
            break
        }
    }
    
    /// Handles the browsing of services.
    func browseHandler(_ newResults: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>) {
        for change in changes {
            switch change {
            case .added(let result):
                if case .service(let name, let type, _, _) = result.endpoint {
                    var service = findService(name, type)
                    if service != nil {
                        break
                    }
                    service = BonsoirService(name: name, type: type, port: 0, hostAddresses: [], attributes: [:])
                    if case .bonjour(let records) = result.metadata {
                        service!.attributes = records.dictionary
                    }
                    onSuccess(eventId: Generated.discoveryServiceFound, service: service)
                    services.append(service!)
                }
            case .removed(let result):
                if case .service(let name, let type, _, _) = result.endpoint {
                    guard let service = findService(name, type) else {
                        break
                    }
                    onSuccess(eventId: Generated.discoveryServiceLost, service: service)
                    if let index = services.firstIndex(where: { $0 === service }) {
                        services.remove(at: index)
                    }
                }
            case .changed(let old, let new, _):
                if case .service(let newName, let newType, _, _) = new.endpoint {
                    if case .service(let oldName, let oldType, _, _) = old.endpoint {
                        guard let service = findService(oldName) else {
                            break
                        }
                        var newAttributes: [String: String]
                        if case .bonjour(let newRecords) = new.metadata {
                            newAttributes = newRecords.dictionary
                        } else {
                            newAttributes = service.attributes
                        }
                        if oldName == newName && oldType == newType && newAttributes == service.attributes {
                            break
                        }
                        service.name = newName
                        service.type = newType
                        service.attributes = newAttributes
                        onSuccess(eventId: Generated.discoveryServiceUpdated, service: service)
                    }
                }
            default:
                break
            }
        }
    }
    
    /// Resolves a service.
    public func resolveService(name: String, type: String) -> Bool {
        guard let service = findService(name, type) else {
            onError(message: Generated.discoveryUndiscoveredServiceResolveFailed, parameters: [name, type])
            return false
        }
        var sdRef: DNSServiceRef? = nil
        let error = DNSServiceResolve(&sdRef, 0, 0, name, type, "local.", BonsoirServiceDiscovery.resolveCallback, Unmanaged.passUnretained(self).toOpaque())
        if error != kDNSServiceErr_NoError {
            onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [error])
            stopResolution(sdRef: sdRef, remove: false)
            return false
        }

        // Recorded before scheduling, not after: this only reads as safe because
        // the caller and the delivery share the main queue, so no reply can slip
        // in between. Ordering it this way keeps that from becoming a trap if the
        // delivery queue ever changes.
        pendingResolution.append(sdRef!)

        // Replies arrive on the main queue, which is where `services`, the
        // bookkeeping below and the browse handler already live — and dns_sd.h
        // requires the reference to be deallocated on the queue it was scheduled
        // on, so that is the mutual exclusion the header asks the caller for.
        let queueError = DNSServiceSetDispatchQueue(sdRef, DispatchQueue.main)
        if queueError != kDNSServiceErr_NoError {
            onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [queueError])
            stopResolution(sdRef: sdRef)
            return false
        }

        return true
    }

    /// Resolves the IP address for the given service hostname.
    private func resolveAddress(for service: BonsoirService, hostname: String) -> Bool {
        var sdRef: DNSServiceRef? = nil
        let error = DNSServiceGetAddrInfo(&sdRef, 0, 0, DNSServiceProtocol(kDNSServiceProtocol_IPv4 | kDNSServiceProtocol_IPv6), hostname, BonsoirServiceDiscovery.addressResolveCallback, Unmanaged.passUnretained(self).toOpaque())
        if error != kDNSServiceErr_NoError {
            onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [error])
            stopResolution(sdRef: sdRef, remove: false)
            return false
        }

        pendingResolution.append(sdRef!)
        pendingAddressResolution[BonsoirServiceDiscovery.resolutionKey(for: sdRef)] = service

        let queueError = DNSServiceSetDispatchQueue(sdRef, DispatchQueue.main)
        if queueError != kDNSServiceErr_NoError {
            onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [queueError])
            pendingAddressResolution.removeValue(forKey: BonsoirServiceDiscovery.resolutionKey(for: sdRef))
            stopResolution(sdRef: sdRef)
            return false
        }

        return true
    }
    
    /// Stops the resolution of the given service.
    private func stopResolution(sdRef: DNSServiceRef?, remove: Bool = true) {
        if remove, let index = pendingResolution.firstIndex(where: { $0 == sdRef }) {
            pendingResolution.remove(at: index)
        }
        DNSServiceRefDeallocate(sdRef)
    }
    
    /// Starts the discovery.
    public func start() {
        browser.start(queue: .main)
    }
    
    override public func dispose() {
        for sdRef in pendingResolution {
            stopResolution(sdRef: sdRef, remove: false)
        }
        pendingResolution.removeAll()
        pendingAddressResolution.removeAll()
        services.removeAll()
        if [.setup, .ready].contains(browser.state) {
            browser.cancel()
        }
        super.dispose()
    }
    
    /// Callback triggered by`DNSServiceResolve`.
    ///
    /// Delivered on the main queue, because that is the queue the reference was
    /// scheduled on — so the `services` array, the `BonsoirService` being filled
    /// in and the browse handler are all on the same thread, and the reference
    /// can be deallocated right here.
    private static let resolveCallback: DNSServiceResolveReply = { sdRef, _, _, errorCode, fullName, hosttarget, port, _, _, context in
        let discovery = Unmanaged<BonsoirServiceDiscovery>.fromOpaque(context!).takeUnretainedValue()
        guard !discovery.isDisposed else {
            return
        }

        var service: BonsoirService?
        if let fullName, let serviceData = ServiceResolution.parseBonjourFqdn(ServiceResolution.unescapeAscii(String(cString: fullName))) {
            service = discovery.findService(serviceData.0, serviceData.1)
        }
        if let service, errorCode == kDNSServiceErr_NoError {
            if let hosttarget {
                service.hostname = String(cString: hosttarget)
            }
            service.port = Int(CFSwapInt16BigToHost(port))

            if service.hostname == nil {
                discovery.onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [errorCode])
            } else {
                discovery.resolveAddress(for: service, hostname: service.hostname!)
            }
        } else if service == nil {
            discovery.onError(message: Generated.discoveryServiceResolveFailed, parameters: ["nil", errorCode])
        } else {
            discovery.onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [errorCode])
        }

        discovery.stopResolution(sdRef: sdRef, remove: sdRef != nil)
    }

    /// Callback triggered by `DNSServiceGetAddrInfo`.
    ///
    /// Delivered on the main queue, like `resolveCallback`. `address` points into
    /// memory owned by the DNSSD library and is only valid while this callback
    /// runs, so it is turned into a string here rather than carried anywhere.
    private static let addressResolveCallback: DNSServiceGetAddrInfoReply = { sdRef, flags, _, errorCode, _, address, _, context in
        let discovery = Unmanaged<BonsoirServiceDiscovery>.fromOpaque(context!).takeUnretainedValue()
        guard !discovery.isDisposed else {
            return
        }

        let resolvedAddress = address == nil ? nil : ServiceResolution.ipAddress(from: address!)
        let hasMoreResults = (flags & DNSServiceFlags(kDNSServiceFlagsMoreComing)) != 0

        let resolutionKey = BonsoirServiceDiscovery.resolutionKey(for: sdRef)
        guard let service = discovery.pendingAddressResolution[resolutionKey] else {
            discovery.stopResolution(sdRef: sdRef, remove: sdRef != nil)
            return
        }

        if errorCode == kDNSServiceErr_NoError, let resolvedAddress {
            if !service.hostAddresses.contains(resolvedAddress) {
                service.hostAddresses.append(resolvedAddress)
            }
        } else if service.hostAddresses.isEmpty && !hasMoreResults {
            discovery.onSuccess(eventId: Generated.discoveryServiceResolveFailed, service: service, parameters: [errorCode])
        }

        if !hasMoreResults {
            if !service.hostAddresses.isEmpty {
                discovery.onSuccess(eventId: Generated.discoveryServiceResolved, service: service)
            }
            discovery.pendingAddressResolution.removeValue(forKey: resolutionKey)
            discovery.stopResolution(sdRef: sdRef, remove: sdRef != nil)
        }
    }

    /// Identifies an address resolution.
    ///
    /// This is the reference's address, which the allocator reuses freely — a
    /// probe here handed the same address back 20 times out of 20. It is only
    /// sound because every insertion, lookup, removal and deallocation now
    /// happens on the main queue, so an entry cannot outlive the reference it
    /// was keyed by. Anything that reintroduces off-queue bookkeeping has to
    /// replace this with real per-resolution identity in the DNSSD context.
    private static func resolutionKey(for sdRef: DNSServiceRef?) -> String {
        guard let sdRef else {
            return "nil"
        }
        return String(describing: sdRef)
    }
}
