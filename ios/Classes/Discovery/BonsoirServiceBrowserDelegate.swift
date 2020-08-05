import Foundation
import Flutter

class BonsoirServiceBrowserDelegate: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, FlutterStreamHandler {
    let id: Int
    let printLogs: Bool
    let onDispose: (Bool) -> Void
    
    var eventChannel: FlutterEventChannel?
    var eventSink: FlutterEventSink?
    
    var discoveredServices: [NetService] = []
    var lostServices: [NetService] = []
    
    public init(id: Int, printLogs: Bool, onDispose: @escaping (Bool) -> Void, messenger: FlutterBinaryMessenger) {
        self.id = id
        self.printLogs = printLogs
        self.onDispose = onDispose
        super.init()
        eventChannel = FlutterEventChannel(name: "\(SwiftBonsoirPlugin.package).discovery.\(id)", binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir discovery started : \(browser)")
        }
        eventSink?(SuccessObject(id: "discovery_started").toJson())
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch error: [String: NSNumber]) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir has encountered an error during discovery : \(error)")
        }
        eventSink?(FlutterError.init(code: "discovery_error", message: "Bonsoir has encountered an error during discovery.", details: error))
        dispose(stopDiscovery: true)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        discoveredServices.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10.0)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        let index: Int? = discoveredServices.firstIndex(of: service)
        if index != nil {
            discoveredServices.remove(at: index!)
        }
        lostServices.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10.0)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if discoveredServices.contains(sender) {
            if self.printLogs {
                NSLog("\n[\(self.id)] Bonsoir has discovered a service : \(sender)")
            }
            self.eventSink?(SuccessObject(id: "discovery_service_found", result: self.serviceToJson(sender)).toJson())
        }
        else if lostServices.contains(sender) {
            lostServices.remove(at: lostServices.firstIndex(of: sender)!)
            sender.stop()
            
            if self.printLogs {
                NSLog("\n[\(self.id)] A Bonsoir discovered service has been lost : \(sender)")
            }
            
            self.eventSink?(SuccessObject(id: "discovery_service_lost", result: self.serviceToJson(sender)).toJson())
        }
    }
    
    func netService(_ sender: NetService, didNotResolve error: [String: NSNumber])  {
        if discoveredServices.contains(sender) {
            if self.printLogs {
                NSLog("\n[\(self.id)] Bonsoir has discovered a service but failed to resolve it : \(sender)")
            }
            self.eventSink?(SuccessObject(id: "discovery_service_found", result: self.serviceToJson(sender)).toJson())
        }
        else if lostServices.contains(sender) {
            if self.printLogs {
                NSLog("\n[\(self.id)] A Bonsoir discovered service has been lost and Bonsoir failed to resolve it : \(sender)")
            }
            self.eventSink?(SuccessObject(id: "discovery_service_lost", result: self.serviceToJson(sender)).toJson())
        }
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            NSLog("\n[\(id)] Bonsoir discovery stopped : \(browser)")
        }
        eventSink?(SuccessObject(id: "discovery_stopped").toJson())
        dispose()
    }
    
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = eventSink
      return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
      eventSink = nil
      return nil
    }
    
    public func dispose(stopDiscovery: Bool = false) {
        onDispose(stopDiscovery)
    }
    
    private func serviceToJson(_ service: NetService) -> [String: Any?] {
        return [
            "service.name": service.name,
            "service.type": service.type,
            "service.port": service.port,
            "service.ip": resolveIPv4(addresses: service.addresses)
        ]
    }
    
    private func resolveIPv4(addresses: [Data]?) -> String? {
        if addresses == nil {
            return nil
        }
        
        var result: String?

        for addr in addresses! {
            let data = addr as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)

            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                        $0.pointee
                    }
                }

                if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
                    result = ip
                    break
                }
            }
        }

        return result
    }
}
