import Flutter
import UIKit

public class SwiftBonsoirPlugin: NSObject, FlutterPlugin {
  let services: [NetService] = []
  let browsers: [NetServiceBrowser] = []
  var channel: FlutterMethodChannel

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fr.skyost.bonsoir", binaryMessenger: registrar.messenger())
    let instance = SwiftBonsoirPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch case.method {
    case "broadcast.start":
        let id = services.count
        let service = NetService(domain: "local.", type: call.arguments["service.type"], name: call.arguments["service.name"], port: call.arguments["service.port"])
        service.delegate = BonsoirServiceDelegate(id: id, printLogs: call.arguments['printLogs'])
        service.publish()
        services.append(service)
        result(id)
    case "broadcast.stop":
        let id = call.arguments["id"] as? Int else {
            result(FlutterError(code: "invalidId", message: "Invalid identifier.", details: "Expected identifier to be a valid integer."))
            return
        }
        if id > 0 && id < services.count {
            services[id].stop()
			services.remove(at: id)
        }
        result(true)
    case "discovery.start":
        let id = browsers.count
        let browser = NetServiceBrowser()
        browser.delegate = BonsoirServiceBrowserDelegate(id: id, printLogs: call.arguments['printLogs'], channel: channel)
        browser.searchForServices(ofType: call.arguments["type"], inDomain: "local.")
        browsers.append(browser)
        result(id)
    case "discovery.stop":
        let id = call.arguments["id"] as? Int else {
            result(FlutterError(code: "invalidId", message: "Invalid identifier.", details: "Expected identifier to be a valid integer."))
            return
        }
        if id > 0 && id < browsers.count {
            browsers[id].stop()
			browsers.remove(at: id)
        }
        result(true)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
