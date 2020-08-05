import Flutter
import Foundation

public class SwiftBonsoirPlugin: NSObject, FlutterPlugin {
    var services: [Int: NetService] = [:]
    var browsers: [Int: NetServiceBrowser] = [:]
    let messenger: FlutterBinaryMessenger

    private init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(name: "fr.skyost.bonsoir", binaryMessenger: messenger)
        let instance = SwiftBonsoirPlugin(messenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: [String: Any?] = call.arguments as! [String: Any?]
        let id = arguments["id"] as! Int
        switch call.method {
        case "broadcast.initialize":
            let service = NetService(domain: "local.", type: arguments["service.type"] as! String, name: arguments["service.name"] as! String, port: Int32(arguments["service.port"] as! Int))
            let delegate = BonsoirServiceDelegate(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: {
                service.stop()
                self.services.removeValue(forKey: id)
            }, messenger: messenger)
            service.delegate = delegate
            services[id] = service
            result(true)
        case "broadcast.start":
            services[id]?.publish()
            result(true)
        case "broadcast.stop":
            services[id]?.stop()
            result(true)
        case "discovery.initialize":
            let browser = NetServiceBrowser()
            let delegate = BonsoirServiceBrowserDelegate(id: id, printLogs: arguments["printLogs"] as! Bool, onDispose: {
                browser.stop()
                self.browsers.removeValue(forKey: id)
            }, messenger: messenger)
            browser.delegate = delegate
            browsers[id] = browser
            result(true)
        case "discovery.start":
            browsers[id]?.searchForServices(ofType: arguments["type"] as! String, inDomain: "local.")
            result(true)
        case "discovery.stop":
            browsers[id]?.stop()
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
}
