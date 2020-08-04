import NetService

class BonsoirServiceBrowserDelegate: NetServiceBrowserDelegate {
    let id: Int
    let printLogs: Bool
    let channel: FlutterMethodChannel

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            print("[\(id)] Bonsoir discovery started : \(browser)")
        }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch error: Error) {
        if printLogs {
            print("[\(id)] Bonsoir has encountered an error during discovery : \(error)")
        }
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if printLogs {
            print("[\(id)] Bonsoir has discovered a service : \(service)")
        }
		channel.invokeMethod("service.found", [
			"name": service.name,
			"type": service.type,
			"port": service.port,
			"ip": netServiceDidResolveAddress(service)
		])
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if printLogs {
            print("[\(id)] A Bonsoir discovered service has been lost : \(service)")
        }
		channel.invokeMethod("service.removed", [
			"name": service.name,
			"type": service.type,
			"port": service.port,
			"ip": netServiceDidResolveAddress(service)
		])
    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        if printLogs {
            print("[\(id)] Bonsoir discovery stopped : \(browser)")
        }
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else { return }
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                // handle error
                return
            }
            var sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        return String(cString:hostname)
    }
}