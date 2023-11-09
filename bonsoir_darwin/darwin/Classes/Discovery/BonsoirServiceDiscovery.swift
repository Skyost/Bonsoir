#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Network

/// Allows to find net services on local network.
@available(iOS 13.0, macOS 10.15, *)
class BonsoirServiceDiscovery: NSObject, FlutterStreamHandler {
    /// The delegate identifier.
    let id: Int

    /// Whether to print debug logs.
    let printLogs: Bool

    /// Triggered when this instance is being disposed.
    let onDispose: (Bool) -> Void

    /// The type we're listening to.
    let type: String
    
    /// The current browser instance.
    let browser: NWBrowser

    /// The current event channel.
    var eventChannel: FlutterEventChannel?

    /// The current event sink.
    var eventSink: FlutterEventSink?
    
    /// Contains all found services.
    var services: [BonsoirService] = []
    
    /// Contains all services wh're currently resolving.
    var resolvingServices: [DNSServiceRef?: BonsoirService] = [:]

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger, type: String) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        self.type = type
        browser = NWBrowser(for: .bonjourWithTXTRecord(type: type, domain: "local."), using: .tcp)
        super.init()
        browser.stateUpdateHandler = stateHandler
        browser.browseResultsChangedHandler = browseHandler
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).discovery.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }
    
    /// Handles state changes.
    func stateHandler(_ newState: NWBrowser.State) {
        switch newState {
        case .ready:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery started : \(type)")
            }
            eventSink?(SuccessObject(id: "discoveryStarted").toJson())
        case .failed(let error):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has encountered an error during discovery : \(error)")
            }
            eventSink?(FlutterError.init(code: "discoveryError", message: "Bonsoir has encountered an error during discovery.", details: error))
            dispose()
        case .cancelled:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir discovery stopped : \(type)")
            }
            eventSink?(SuccessObject(id: "discoveryStopped").toJson())
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
                    let service = BonsoirService(name: name, type: type, port: 0, host: nil, attributes: nil)
                    if case .bonjour(let records) = result.metadata {
                        service.attributes = records.dictionary
                    }
                    if printLogs {
                        SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has found a service : \(service.description)")
                    }
                    eventSink?(SuccessObject(id: "discoveryServiceFound", service: service).toJson())
                    services.append(service)
                }
            case .removed(let result):
                if case .service(let name, let type, _, _) = result.endpoint {
                    let service = services.first(where: {$0.name == name && $0.type == type})
                    if service == nil {
                        break
                    }
                    if printLogs {
                        SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "A Bonsoir service has been lost : \(service!.description)")
                    }
                    eventSink?(SuccessObject(id: "discoveryServiceLost", service: service).toJson())
                    if let index = self.services.firstIndex(where: { $0 === service }) {
                        self.services.remove(at: index)
                    }
                }
            case .changed(let old, let new, _):
                if case .service(let newName, let newType, _, _) = new.endpoint {
                    if case .service(let oldName, let oldType, _, _) = old.endpoint {
                        let service = services.first(where: {$0.name == oldName && $0.type == oldType})
                        if service == nil {
                            break
                        }
                        if printLogs {
                            SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "A Bonsoir service has changed : \(service!.description)")
                        }
                        eventSink?(SuccessObject(id: "discoveryServiceLost", service: service).toJson())
                        service!.name = newName
                        service!.type = newType
                        if case .bonjour(let newRecords) = new.metadata {
                            service!.attributes = newRecords.dictionary
                        }
                        eventSink?(SuccessObject(id: "discoveryServiceFound", service: service).toJson())
                    }
                }
            default:
                break
            }
        }
    }

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    /// Resolves a service.
    public func resolveService(name: String, type: String) -> Bool {
        for result in browser.browseResults {
            if case .service(let name, let type, _, _) = result.endpoint {
                let service = services.first(where: {$0.name == name && $0.type == type})
                if service == nil {
                    return false
                }
                var sdRef: DNSServiceRef? = nil
                let error = DNSServiceResolve(&sdRef, 0, 0, name, type, "local.", { (sdRef, flags, interfaceIndex, errorCode, fullName, hosttarget, port, txtLen, txtRecord, context) in
                    let discovery = Unmanaged<BonsoirServiceDiscovery>.fromOpaque(context!).takeUnretainedValue()
                    let service = discovery.resolvingServices[sdRef]
                    if errorCode == kDNSServiceErr_NoError {
                        if hosttarget != nil {
                            service!.host = String(cString: hosttarget!)
                        }
                        service!.port = Int(port)
                        if discovery.printLogs == true {
                            SwiftBonsoirPlugin.log(category: "discovery", id: discovery.id, message: "Bonsoir has resolved a service : \(service!.description)")
                        }
                        discovery.eventSink?(SuccessObject(id: "discoveryServiceResolved", service: service).toJson())
                    } else {
                        if discovery.printLogs {
                            SwiftBonsoirPlugin.log(category: "discovery", id: discovery.id, message: "Bonsoir has failed to resolve a service : \(errorCode)")
                        }
                        discovery.stopResolution(sdRef: sdRef, remove: sdRef != nil)
                        discovery.eventSink?(SuccessObject(id: "discoveryServiceResolveFailed", service: service).toJson())
                    }
                }, Unmanaged.passUnretained(self).toOpaque())
                if error == kDNSServiceErr_NoError {
                    resolvingServices[sdRef] = service
                    DNSServiceProcessResult(sdRef)
                } else {
                    if printLogs {
                        SwiftBonsoirPlugin.log(category: "discovery", id: id, message: "Bonsoir has failed to resolve a service : \(error)")
                    }
                    stopResolution(sdRef: sdRef, remove: false)
                    eventSink?(SuccessObject(id: "discoveryServiceResolveFailed", service: service).toJson())
                }
                return true
            }
        }
        return false
    }
    
    /// Stops the resolution of the given service.
    private func stopResolution(sdRef: DNSServiceRef?, remove: Bool = true) {
        if remove {
            resolvingServices.removeValue(forKey: sdRef)
        }
        DNSServiceRefDeallocate(sdRef)
    }
    
    /// Starts the discovery.
    public func start() {
        browser.start(queue: .main)
    }

    /// Disposes the current class instance.
    public func dispose() {
        for sdRef in resolvingServices.keys {
            stopResolution(sdRef: sdRef, remove: false)
        }
        resolvingServices.removeAll()
        services.removeAll()
        if case .setup || .ready = browser.state {
            browser.cancel()
        }
        onDispose()
    }
}
