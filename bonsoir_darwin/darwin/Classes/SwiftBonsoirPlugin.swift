#if canImport(Flutter)
    import Flutter
#elseif canImport(FlutterMacOS)
    import FlutterMacOS
#endif
#if canImport(os)
    import os
#endif
import Foundation

/// The main plugin Swift class.
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
            let service = NWListener.Service(type: arguments["service.type"] as! String, name: arguments["service.name"] as! String)
            let attributes = arguments["service.attributes"]
            if attributes != nil {
                service.txtRecordObject = NWTXTRecord(attributes as! [String : String])
            }
            let listener = BonsoirNWListener(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopBroadcast in
                if stopBroadcast {
                    listener.cancel()
                }
                self.listeners.removeValue(forKey: id)
            }, messenger: messenger, port: arguments["service.port"] as! Int)
            listener.service = service
            listeners[id] = listener
            result(listeners[id] != nil)
        case "broadcast.start":
            listeners[id]?.start(queue: .main)
            result(listeners[id] != nil)
        case "broadcast.stop":
            listeners[id]?.dispose()
            result(listeners[id] != nil)
        case "discovery.initialize":
            let browser = BonsoirNWBrowser(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopDiscovery in
                if stopDiscovery {
                    browser.cancel()
                }
                self.browsers.removeValue(forKey: id)
            }, messenger: messenger, type: arguments["type"] as! String)
            browsers[id] = browser
            result(browsers[id] != nil)
        case "discovery.start":
            browsers[id]?.start(queue: .main)
            result(browsers[id] != nil)
        case "discovery.resolveService":
            var resolveStarted: Bool = false
            let delegate: BonsoirNWBrowser? = browsers[id]?.delegate as! BonsoirNWBrowser?
            if delegate != nil {
                resolveStarted = delegate!.resolveService(name: arguments["name"] as! String, type: arguments["type"] as! String)!
            }
            result(resolveStarted)
        case "discovery.stop":
            browsers[id]?.dispose()
            result(browsers[id] != nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func detachFromEngineForRegistrar(registrar: FlutterPluginRegistrar) {
        for service in services.values {
            (service.delegate as! BonsoirNWListener).dispose()
        }
        for browser in browsers.values {
            (browser.delegate as! BonsoirNWBrowser).dispose()
        }
    }
    
    /// Logs a given message.
    public static func log(category: String, id: Int, message: String) {
        #if canImport(os)
        if #available(iOS 10.0, macOS 10.12, *) {
            os_log("[%d] %s", log: OSLog(subsystem: "fr.skyost.bonsoir", category: category), type: OSLogType.info, id, message)
            return
        }
        else {
            NSLog("\n[\(id)] \(message)")
        }
        #endif
        
        NSLog("\n[\(id)] \(message)")
    }
    
    /// Encodes the specified attributes.
    private func encodeAttributes(attributes: [String: String?]) -> [String: Data] {
        var result: [String: Data] = [:]
        for (key, value) in attributes {
            if(value != nil) {
                result[key] = String(describing: value!).data(using: .utf8)
            }
        }
        return result
    }
}
