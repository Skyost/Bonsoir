#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Foundation
import Network

/// Allows to broadcast a given service to the local network.
class BonsoirNWListener: NSObject, NWListener, FlutterStreamHandler {
    /// The delegate identifier.
    let id: Int

    /// Whether to print debug logs.
    let printLogs: Bool

    /// Triggered when this instance is being disposed.
    let onDispose: (Bool) -> Void

    /// The current event channel.
    var eventChannel: FlutterEventChannel?

    /// The current event sink.
    var eventSink: FlutterEventSink?

    /// Initializes this class.
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger, port: Int) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        self.stateUpdateHandler = stateHandler
        super.init(using: .tcp, on: port)
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).broadcast.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    /// Handles state changes.
    func stateHandler(_ newState: NWListener.State) {
        switch newState {
        case .setup:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast initialized : \(service)")
            }
        case .waiting(let error):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast waiting for a network to become available : \(service)")
            }
        case .ready:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcasted : \(service)")
            }
            eventSink?(SuccessObject(id: "broadcastStarted", service: BonsoirService(service: service)).toJson())
        case .failed(let error):
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service failed to broadcast : \(service), error code : \(error)")
            }
            eventSink?(FlutterError.init(code: "broadcastError", message: "Bonsoir service failed to broadcast.", details: error))
            dispose()
        case .cancelled:
            if printLogs {
                SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast stopped : \(service)")
            }
            
            eventSink?(SuccessObject(id: "broadcastStopped", service: BonsoirService(service: service)).toJson())
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

    /// Disposes the current class instance.
    public func dispose(stopBroadcast: Bool = true) {
        onDispose(stopBroadcast)
    }
}
