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

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger, service: BonsoirService) {
        self.service = service
        super.init(id: id, action: "broadcast", printLogs: printLogs, onDispose: onDispose, messenger: messenger)
    }

    /// Starts the broadcast.
    public func start() {
        var txtRecord = TXTRecordRef()
        TXTRecordCreate(&txtRecord, 0, nil)
        for (key, value) in service.attributes {
            TXTRecordSetValue(&txtRecord, key, UInt8(value.count), value)
        }
        let error = DNSServiceRegister(&sdRef, 0, 0, service.name, service.type, "local.", service.host, CFSwapInt16HostToBig(UInt16(service.port)), TXTRecordGetLength(&txtRecord), TXTRecordGetBytesPtr(&txtRecord), BonsoirServiceBroadcast.registerCallback as DNSServiceRegisterReply, Unmanaged.passUnretained(self).toOpaque())
        if error == kDNSServiceErr_NoError {
            log("Bonsoir service broadcast initialized : \(service)")
            DNSServiceProcessResult(sdRef)
        } else {
            onError("Bonsoir service failed to broadcast : \(service), error code : \(error)", error)
            dispose()
        }
    }

    override public func dispose() {
        DNSServiceRefDeallocate(sdRef)
        onSuccess("broadcastStopped", "Bonsoir service broadcast stopped : \(service)", service)
        super.dispose()
    }

    /// Callback triggered by`DNSServiceRegister`.
    private static let registerCallback: DNSServiceRegisterReply = { _, _, errorCode, name, _, _, context in
        let broadcast = Unmanaged<BonsoirServiceBroadcast>.fromOpaque(context!).takeUnretainedValue()
        if errorCode == kDNSServiceErr_NoError {
            let newName = name == nil ? nil : String(cString: name!)
            if newName != nil && broadcast.service.name != newName {
                let oldName = broadcast.service.name
                broadcast.service.name = newName!
                broadcast.onSuccess("broadcastNameAlreadyExists", "Trying to broadcast a service with a name that already exists : \(broadcast.service) (old name was \(oldName))", broadcast.service)
            }
            broadcast.onSuccess("broadcastStarted", "Bonsoir service broadcasted : \(broadcast.service)", broadcast.service)
        } else {
            broadcast.onError("Bonsoir service failed to broadcast : \(broadcast.service)", errorCode)
            broadcast.dispose()
        }
    }
}
