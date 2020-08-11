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

    /// Contains all created services (Broadcast).
    var services: [Int: NetService] = [:]

    /// Contains all created browsers (Discovery).
    var browsers: [Int: NetServiceBrowser] = [:]

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
            let service = NetService(domain: "local.", type: arguments["service.type"] as! String, name: arguments["service.name"] as! String, port: Int32(arguments["service.port"] as! Int))
            let delegate = BonsoirServiceDelegate(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopBroadcast in
                if stopBroadcast {
                    service.stop()
                }
                self.services.removeValue(forKey: id)
            }, messenger: messenger)
            service.delegate = delegate
            services[id] = service
            result(true)
        case "broadcast.start":
            services[id]?.publish()
            result(true)
        case "broadcast.stop":
            (services[id]?.delegate as! BonsoirServiceDelegate?)?.dispose()
            result(true)
        case "discovery.initialize":
            let browser = NetServiceBrowser()
            let delegate = BonsoirServiceBrowserDelegate(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: { stopDiscovery in
                if stopDiscovery {
                    browser.stop()
                }
                self.browsers.removeValue(forKey: id)
            }, messenger: messenger)
            browser.delegate = delegate
            browsers[id] = browser
            result(true)
        case "discovery.start":
            browsers[id]?.searchForServices(ofType: arguments["type"] as! String, inDomain: "local.")
            result(true)
        case "discovery.stop":
            (browsers[id]?.delegate as! BonsoirServiceBrowserDelegate?)?.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func detachFromEngineForRegistrar(registrar: FlutterPluginRegistrar) {
        for service in services.values {
            (service.delegate as! BonsoirServiceDelegate).dispose()
        }
        for browser in browsers.values {
            (browser.delegate as! BonsoirServiceBrowserDelegate).dispose()
        }
    }
    
    /// Logs a given message.
    public static func log(category: String, id: Int, message: String) {
        #if canImport(os)
        if #available(iOS 10.0, macOS 10.12, *) {
            os_log("[%d] %s", log: OSLog(subsystem: "fr.skyost.bonsoir", category: category), type: OSLogType.info, id, message)
            return
        }
        #endif
        
        NSLog("\n[\(id)] \(message)")
    }
}
