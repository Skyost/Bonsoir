import Foundation
import Flutter

class BonsoirServiceBrowserDelegate: NSObject, NetServiceBrowserDelegate, FlutterStreamHandler {
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
        eventChannel = FlutterEventChannel(name: "fr.skyost.bonsoir.discovery.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            print("[\(id)] Bonsoir discovery started : \(browser)")
        }
        eventSink?(SuccessObject(id: "discovery_started").toJson())
    }

    private func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch error: Error) {
        if printLogs {
            print("[\(id)] Bonsoir has encountered an error during discovery : \(error)")
        }
        eventSink?(FlutterError.init(code: "discovery_error", message: "Bonsoir has encountered an error during discovery.", details: error))
        dispose()
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if printLogs {
            print("[\(id)] Bonsoir has discovered a service : \(service)")
        }
        eventSink?(SuccessObject(id: "discovery_service_found", result: serviceToJson(service)).toJson())
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if printLogs {
            print("[\(id)] A Bonsoir discovered service has been lost : \(service)")
        }
        eventSink?(SuccessObject(id: "discovery_service_lost", result: serviceToJson(service)).toJson())
    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            print("[\(id)] Bonsoir discovery stopped : \(browser)")
        }
        eventSink?(SuccessObject(id: "discovery_stopped").toJson())
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

    private func netServiceDidResolveAddress(_ sender: NetService) -> String? {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else { return nil }
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                return
            }
            let sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        return String(cString:hostname)
    }
    
    private func serviceToJson(_ service: NetService) -> [String: Any?] {
        return [
            "service.name": service.name,
            "service.type": service.type,
            "service.port": service.port,
            "service.ip": netServiceDidResolveAddress(service)
        ]
    }
}
