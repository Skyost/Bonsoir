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

    func netServiceDidPublish(_ sender: NetService) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir service broadcasted : \(sender)")
        }
        eventSink?(SuccessObject(id: "broadcast_started").toJson())
    }

    func netService(_ sender: NetService, didNotPublish error: [String: NSNumber]) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir service failed to broadcast : \(sender), error code : \(error)")
        }
        eventSink?(FlutterError.init(code: "broadcast_error", message: "Bonsoir service failed to broadcast.", details: error));
    }

    func netServiceDidStop(_ sender: NetService) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir service broadcast stopped : \(sender)")
        }
        
        eventSink?(SuccessObject(id: "broadcast_stopped").toJson())
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
