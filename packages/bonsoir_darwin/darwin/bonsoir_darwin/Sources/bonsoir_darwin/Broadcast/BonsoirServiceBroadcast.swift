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

    /// Whether the daemon has already confirmed the registration once.
    ///
    /// `dns_sd.h` promises a callback with `kDNSServiceFlagsAdd` set for every
    /// successful registration, and a service registered in more than one domain
    /// gets one per domain. This one always passes `local.` as the domain, so
    /// that case cannot arise here and a further Add is a rename. Reporting one
    /// as a second `broadcastStarted` would have Dart believe two broadcasts
    /// exist where there is one; the rename is reported on its own event.
    private var hasStarted = false

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger, service: BonsoirService) {
        self.service = service
        super.init(id: id, action: "broadcast", logMessages: Generated.broadcastMessages, printLogs: printLogs, onDispose: onDispose, messenger: messenger)
    }

    /// Starts the broadcast.
    public func start() {
        // Registering twice would strand the first reference: it stays scheduled
        // on the queue below, holding an unretained pointer back here, and
        // `dispose()` can only free the one this property names. Android guards
        // its own `start()` the same way, with `isActive`.
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
        // `TXTRecordCreate` with a null buffer makes the record allocate its own,
        // which is the caller's to release. `DNSServiceRegister` copies the
        // bytes, so releasing once it has returned is safe.
        defer { TXTRecordDeallocate(&txtRecord) }
        for (key, value) in service.attributes {
            // A TXT value is length-prefixed with a single byte, so one longer
            // than 255 bytes cannot be represented. Skipped rather than
            // truncated, and rather than trapping on the conversion — but said
            // out loud, because an attribute quietly missing from an advert is
            // hard to see from the other end.
            guard let valueData = value.data(using: .utf8), let length = UInt8(exactly: valueData.count) else {
                log("Bonsoir service attribute dropped, its value does not fit a TXT record : %s.", [key])
                continue
            }
            TXTRecordSetValue(&txtRecord, key, length, [UInt8](valueData))
        }

        var registerRef: DNSServiceRef?
        let registerError = DNSServiceRegister(&registerRef, 0, 0, service.name, service.type, "local.", service.hostAddresses.first ?? service.hostname, CFSwapInt16HostToBig(port), TXTRecordGetLength(&txtRecord), TXTRecordGetBytesPtr(&txtRecord), BonsoirServiceBroadcast.registerCallback, Unmanaged.passUnretained(self).toOpaque())
        guard registerError == kDNSServiceErr_NoError, let registerRef else {
            onError(parameters: [service, registerError], details: registerError)
            dispose()
            return
        }

        // Recorded before scheduling, not after: this only reads as safe because
        // the caller and the delivery share the main queue, so no reply can slip
        // in between. Ordering it this way keeps that from becoming a trap if the
        // delivery queue ever changes, and it is what lets the guard below tear
        // the reference down through the ordinary path.
        sdRef = registerRef

        // Hand the reference to DNSSD rather than draining it here.
        //
        // This used to call `DNSServiceProcessResult(sdRef)`. That is a blocking
        // read on the socket to `mDNSResponder`, and `SwiftBonsoirPlugin.handle`
        // is invoked on the platform (main) thread — so starting a broadcast
        // froze the UI for as long as the daemon took to answer, which on iOS is
        // unbounded while a Local Network permission prompt is still on screen.
        // It also drained exactly ONE reply and never scheduled the reference
        // afterwards, so a rename or a deregistration raised later was never
        // delivered.
        //
        // Replies arrive on the main queue, which is where `start()`, `dispose()`
        // and the bookkeeping above already live — and dns_sd.h requires the
        // reference to be deallocated on the queue it was scheduled on, so that
        // is the mutual exclusion the header asks the caller for. Discovery
        // resolves the same way.
        let queueError = DNSServiceSetDispatchQueue(registerRef, DispatchQueue.main)
        guard queueError == kDNSServiceErr_NoError else {
            onError(parameters: [service, queueError], details: queueError)
            dispose()
            return
        }

        if let message = logMessages[Generated.broadcastInitialized] {
            log(message, [service])
        }
    }

    override public func dispose() {
        guard !isDisposed else {
            return
        }
        // Deallocated on the queue the replies are delivered on — see `start()`.
        // Cleared first, so a second teardown can never hand the same reference
        // to DNSSD twice, and a registration that never got one never hands it a
        // null.
        if let sdRef {
            self.sdRef = nil
            DNSServiceRefDeallocate(sdRef)
        }
        onSuccess(eventId: Generated.broadcastStopped, service: service)
        super.dispose()
    }

    /// Callback triggered by`DNSServiceRegister`.
    ///
    /// Called for as long as the reference lives, rather than the single time
    /// the old blocking drain read it — so it has to hold up to being called
    /// again.
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
        guard (flags & DNSServiceFlags(kDNSServiceFlagsAdd)) != 0 else {
            // "If a successfully-registered name later suffers a name conflict
            // or similar problem and has to be deregistered, the callback will
            // be invoked with the kDNSServiceFlagsAdd flag not set." The service
            // is off the network, so this is reported as a stop — which is what
            // Android reports for the same situation, from
            // `onServiceUnregistered`. It cannot be the client's own
            // `DNSServiceRefDeallocate`; the header says that one is explicitly
            // not reported, so a reply here came from the daemon.
            //
            // Read from the header rather than observed: I could not stage a
            // conflict against an ALREADY-registered name without a second
            // responder on the network. What I did measure is the initial
            // conflict — registering a name that is already taken delivers a
            // single further reply with Add set and the new name, no removal
            // before it — so ordinary auto-rename does not reach this branch.
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
