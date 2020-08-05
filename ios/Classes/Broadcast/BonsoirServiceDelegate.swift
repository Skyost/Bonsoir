import Foundation
import Flutter

class BonsoirServiceDelegate: NSObject, NetServiceDelegate, FlutterStreamHandler {
    let id: Int
    let printLogs: Bool
    let onDispose: () -> Void
    
    var eventChannel: FlutterEventChannel?
    var eventSink: FlutterEventSink?
    
    public init(id: Int, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        super.init()
        eventChannel = FlutterEventChannel(name: "fr.skyost.bonsoir.broadcast.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    public func netServiceDidPublish(_ sender: NetService) {
        if printLogs {
            print("[\(id)] Bonsoir service broadcasted : \(sender)")
        }
        eventSink?(SuccessObject(id: "broadcast_started").toJson())
    }

    private func netService(_ sender: NetService, didNotPublish error: Error) {
        if printLogs {
            print("[\(id)] Bonsoir service failed to broadcast : \(sender), error code : \(error)")
        }
        eventSink?(FlutterError.init(code: "broadcast_error", message: "Bonsoir service failed to broadcast.", details: error));
    }

    public func netServiceDidStop(_ sender: NetService) {
        if printLogs {
            print("[\(id)] Bonsoir service broadcast stopped : \(sender)")
        }
        
        eventSink?(SuccessObject(id: "broadcast_stopped").toJson())
        dispose()
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = eventSink
      return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      eventSink = nil
      return nil
    }
    
    public func dispose() {
        onDispose()
    }
}
