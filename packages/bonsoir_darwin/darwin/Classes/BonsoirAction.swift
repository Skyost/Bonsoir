#if canImport(Flutter)
    import Flutter
#endif
#if canImport(FlutterMacOS)
    import FlutterMacOS
#endif
#if canImport(os)
    import os
#endif

/// Represents a Bonsoir action (broadcast or discovery).
@available(iOS 13.0, macOS 10.15, *)
class BonsoirAction: NSObject, FlutterStreamHandler {
    /// The action identifier.
    private let id: Int
    
    /// The action name.
    private let action: String
    
    /// Whether to print debug logs.
    private let printLogs: Bool
    
    /// Triggered when this instance is being disposed.
    private let onDispose: () -> Void
    
    /// The current event channel.
    private var eventChannel: FlutterEventChannel?
    
    /// The current event sink.
    private var eventSink: FlutterEventSink?
    
    /// Initializes this class.
    public init(id: Int, action: String, printLogs: Bool, onDispose: @escaping () -> Void, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.action = action
        self.printLogs = printLogs
        self.onDispose = onDispose
        super.init()
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).\(action).\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }
    
    /// Called by the event channel when ready to list.
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    /// Called by the event channel when cancelled.
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    /// Triggered when a success occurs.
    func onSuccess(_ eventId: String, _ message: String, _ service: BonsoirService? = nil) {
        log(message)
        eventSink?(SuccessObject(id: eventId, service: service).toJson())
    }
    
    /// Triggered when an error occurs.
    func onError(_ message: String, _ details: Any? = nil) {
        log(message)
        eventSink?(FlutterError(code: "\(action)Error", message: message, details: details))
    }

    /// Disposes the current class instance.
    public func dispose() {
        onDispose()
    }
    
    /// Logs a given message.
    func log(_ message: String) {
        if printLogs {
            #if canImport(os)
                os_log("[%d] %s", log: OSLog(subsystem: SwiftBonsoirPlugin.package, category: action), type: OSLogType.info, id, message)
            #else
                NSLog("\n[\(id)] \(message)")
            #endif
        }
    }
}
