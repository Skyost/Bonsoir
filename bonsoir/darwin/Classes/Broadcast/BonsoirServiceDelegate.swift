#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import Foundation

/// Allows to broadcast a given service to the local network.
class BonsoirServiceDelegate: NSObject, NetServiceDelegate, FlutterStreamHandler {
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
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        super.init()
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).broadcast.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    func netServiceDidPublish(_ service: NetService) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcasted : \(service)")
        }
        eventSink?(SuccessObject(id: "broadcast_started", service: service).toJson())
    }

    func netService(_ service: NetService, didNotPublish error: [String: NSNumber]) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service failed to broadcast : \(service), error code : \(error)")
        }
        eventSink?(FlutterError.init(code: "broadcast_error", message: "Bonsoir service failed to broadcast.", details: error));
    }

    func netServiceDidStop(_ service: NetService) {
        if printLogs {
            SwiftBonsoirPlugin.log(category: "broadcast", id: id, message: "Bonsoir service broadcast stopped : \(service)")
        }
        
        eventSink?(SuccessObject(id: "broadcast_stopped", service: service).toJson())
        dispose(stopBroadcast: false)
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
