#if canImport(Flutter)
    import Flutter
#elseif canImport(FlutterMacOS)
    import FlutterMacOS
#endif
#if canImport(os)
    import os
#endif
import Network

/// The main plugin Swift class.
@available(iOS 13.0, macOS 10.15, *)
public class SwiftBonsoirPlugin: NSObject, FlutterPlugin {
    /// The package name.
    static let package: String = "fr.skyost.bonsoir"

    /// Contains all created listeners (Broadcast).
    var listeners: [Int: BonsoirNWListener] = [:]

    /// Contains all created browsers (Discovery).
    var browsers: [Int: BonsoirNWBrowser] = [:]

    /// The binary messenger instance.
    let messenger: FlutterBinaryMessenger

    /// The class constructor.
    private init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if canImport(Flutter)
            let messenger = registrar.messenger()
        #elseif canImport(FlutterMacOS)
            let messenger = registrar.messenger
        #endif
        let channel = FlutterMethodChannel(name: package, binaryMessenger: messenger)
        let instance = SwiftBonsoirPlugin(messenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: [String: Any?] = call.arguments as! [String: Any?]
        let id = arguments["id"] as! Int
        switch call.method {
        case "broadcast.initialize":
            let service = BonsoirService(name: arguments["service.name"] as! String, type: arguments["service.type"] as! String, port: arguments["service.port"] as! Int, ip: nil, attributes: arguments["service.attributes"] as! [String : String]?)
            if let ip = arguments["service.ip"] as? String? {
                service.ip = ip
            }
            let listener = BonsoirNWListener(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopBroadcast in
                if stopBroadcast {
                    self.listeners[id]?.cancel()
                }
                self.listeners.removeValue(forKey: id)
            }, messenger: messenger, service: service)
            listeners[id] = listener
            result(true)
        case "broadcast.start":
            listeners[id]?.start()
            result(listeners[id] != nil)
        case "broadcast.stop":
            listeners[id]?.dispose()
            result(listeners[id] != nil)
        case "discovery.initialize":
            let browser = BonsoirNWBrowser(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopDiscovery in
                if stopDiscovery {
                    self.browsers[id]?.cancel()
                }
                self.browsers.removeValue(forKey: id)
            }, messenger: messenger, type: arguments["type"] as! String)
            browsers[id] = browser
            result(true)
        case "discovery.start":
            browsers[id]?.start()
            result(browsers[id] != nil)
        case "discovery.resolveService":
            let resolveStarted: Bool = browsers[id]?.resolveService(name: arguments["name"] as! String, type: arguments["type"] as! String) ?? false
            result(resolveStarted)
        case "discovery.stop":
            browsers[id]?.dispose()
            result(browsers[id] != nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func detachFromEngineForRegistrar(registrar: FlutterPluginRegistrar) {
        for listener in listeners.values {
            listener.dispose()
        }
        for browser in browsers.values {
            browser.dispose()
        }
    }
    
    /// Logs a given message.
    public static func log(category: String, id: Int, message: String) {
        #if canImport(os)
            os_log("[%d] %s", log: OSLog(subsystem: "fr.skyost.bonsoir", category: category), type: OSLogType.info, id, message)
        #else
            NSLog("\n[\(id)] \(message)")
        #endif
    }
}
