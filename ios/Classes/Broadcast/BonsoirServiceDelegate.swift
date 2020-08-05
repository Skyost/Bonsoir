import Foundation
import Flutter

class BonsoirServiceDelegate: NSObject, NetServiceDelegate, FlutterStreamHandler {
    let id: Int
    let printLogs: Bool
    let onDispose: (Bool) -> Void
    
    var eventChannel: FlutterEventChannel?
    var eventSink: FlutterEventSink?
    
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
    
    public func dispose(stopBroadcast: Bool = true) {
        onDispose(stopBroadcast)
    }
}
