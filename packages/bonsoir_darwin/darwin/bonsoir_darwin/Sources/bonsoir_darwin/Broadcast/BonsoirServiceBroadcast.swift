#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Network

/// Allows to broadcast a given service to the local network.
@available(iOS 13.0, macOS 10.15, *)
class BonsoirServiceBroadcast: BonsoirAction {
    /// The advertised service.
    private let service: BonsoirService

    /// The reference to the registering..
    private var sdRef: DNSServiceRef?

    /// Whether `broadcastStarted` has been sent. Later replies with the add flag are renames.
    private var hasStarted = false

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger, service: BonsoirService) {
        self.service = service
        super.init(id: id, action: "broadcast", logMessages: Generated.broadcastMessages, printLogs: printLogs, onDispose: onDispose, messenger: messenger)
    }

    /// Starts the broadcast.
    public func start() {
        // A second registration would leave the first reference scheduled with nothing to free it.
        guard !isDisposed, sdRef == nil else {
            return
        }
        guard let port = UInt16(exactly: service.port) else {
            onError(parameters: [service, kDNSServiceErr_BadParam], details: kDNSServiceErr_BadParam)
            dispose()
            return
        }
        var txtRecord = TXTRecordRef()
        TXTRecordCreate(&txtRecord, 0, nil)
        defer { TXTRecordDeallocate(&txtRecord) }
        for (key, value) in service.attributes {
            // A TXT entry ("key=value") is at most 255 bytes long, and the key must be printable ASCII.
            guard let valueData = value.data(using: .utf8), let length = UInt8(exactly: valueData.count), TXTRecordSetValue(&txtRecord, key, length, [UInt8](valueData)) == kDNSServiceErr_NoError else {
                log(logMessages[Generated.broadcastAttributeInvalid]!, [service, key])
                continue
            }
        }
        // dns_sd.h leaves the reference uninitialized on failure, so it is only stored on success.
        var registerRef: DNSServiceRef?
        let error = DNSServiceRegister(&registerRef, 0, 0, service.name, service.type, "local.", service.hostAddresses.first ?? service.hostname, CFSwapInt16HostToBig(port), TXTRecordGetLength(&txtRecord), TXTRecordGetBytesPtr(&txtRecord), BonsoirServiceBroadcast.registerCallback, Unmanaged.passUnretained(self).toOpaque())
        guard error == kDNSServiceErr_NoError, let registerRef else {
            onError(parameters: [service, error], details: error)
            dispose()
            return
        }
        sdRef = registerRef
        // DNSServiceProcessResult() would block the main thread until the daemon answers.
        let queueError = DNSServiceSetDispatchQueue(registerRef, DispatchQueue.main)
        if queueError != kDNSServiceErr_NoError {
            onError(parameters: [service, queueError], details: queueError)
            dispose()
            return
        }
        log(logMessages[Generated.broadcastInitialized]!, [service])
    }

    override public func dispose() {
        guard !isDisposed else {
            return
        }
        if let sdRef {
            self.sdRef = nil
            DNSServiceRefDeallocate(sdRef)
        }
        onSuccess(eventId: Generated.broadcastStopped, service: service)
        super.dispose()
    }

    /// Callback triggered by`DNSServiceRegister`. Called for as long as the reference is scheduled.
    private static let registerCallback: DNSServiceRegisterReply = { _, flags, errorCode, name, _, _, context in
        guard let context else {
            return
        }
        let broadcast = Unmanaged<BonsoirServiceBroadcast>.fromOpaque(context).takeUnretainedValue()
        guard !broadcast.isDisposed else {
            return
        }
        guard errorCode == kDNSServiceErr_NoError else {
            broadcast.onError(parameters: [broadcast.service, errorCode], details: errorCode)
            broadcast.dispose()
            return
        }
        // Without the add flag, the daemon has deregistered the service (see dns_sd.h).
        guard (flags & DNSServiceFlags(kDNSServiceFlagsAdd)) != 0 else {
            broadcast.dispose()
            return
        }
        if let name {
            let newName = String(cString: name)
            if broadcast.service.name != newName {
                let oldName = broadcast.service.name
                broadcast.service.name = newName
                broadcast.onSuccess(eventId: Generated.broadcastNameAlreadyExists, service: broadcast.service, parameters: [oldName])
            }
        }
        if !broadcast.hasStarted {
            broadcast.hasStarted = true
            broadcast.onSuccess(eventId: Generated.broadcastStarted, service: broadcast.service)
        }
    }
}
