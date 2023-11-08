#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Network

/// Allows to broadcast a given service to the local network.
@available(iOS 13.0, macOS 10.15, *)
class BonsoirNWListener: NSObject, FlutterStreamHandler {
    /// The delegate identifier.
    let id: Int

    /// Whether to print debug logs.
    let printLogs: Bool

    /// Triggered when this instance is being disposed.
    let onDispose: (Bool) -> Void
    
    /// The advertised service.
    let service: BonsoirService
    
    /// The listener object.
    let listener: NWListener

    /// The current event channel.
    var eventChannel: FlutterEventChannel?

    /// The current event sink.
    var eventSink: FlutterEventSink?

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger, service: BonsoirService) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        self.service = service
        listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(String(service.port))!)
        super.init()
        listener.newConnectionHandler = { connection in }
        listener.stateUpdateHandler = stateHandler
        listener.service = NWListener.Service(name: service.name, type: service.type, domain: "local.", txtRecord: NWTXTRecord(service.attributes ?? [:]))
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).broadcast.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
        if self.service.host != nil && printLogs {
            SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "You're trying to broadcast the host \(String(describing: service.host)) associated with the type \(service.type). Please note that, on Darwin platforms, this is not taken into account.")
        }
    }

    /// Handles state changes.
    func stateHandler(_ newState: NWListener.State) {
        switch newState {
        case .setup:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast initialized : \(service.description)")
            }
        case .waiting(_):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast waiting for a network to become available : \(service.description)")
            }
        case .ready:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcasted : \(service.description)")
            }
            eventSink?(SuccessObject(id: "broadcastStarted", service: service).toJson())
        case .failed(let error):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service failed to broadcast : \(service.description), error code : \(error)")
            }
            eventSink?(FlutterError.init(code: "broadcastError", message: "Bonsoir service failed to broadcast.", details: error))
            dispose()
        case .cancelled:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast stopped : \(service.description)")
            }
            
            eventSink?(SuccessObject(id: "broadcastStopped", service: service).toJson())
            dispose(stopBroadcast: false)
        default:
            break
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
    
    /// Starts the broadcast.
    public func start() {
        listener.start(queue: .main)
    }
    
    /// Cancels the broadcast.
    public func cancel() {
        listener.cancel()
    }

    /// Disposes the current class instance.
    public func dispose(stopBroadcast: Bool = true) {
        onDispose(stopBroadcast)
    }
}
