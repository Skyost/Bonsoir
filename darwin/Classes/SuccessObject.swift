import Foundation

/// Sent to the event channel when there is no error.
class SuccessObject {
    /// The response id.
    let id: String

    /// The response service.
    let service: NetService?

    /// Creates a new instance with any result.
    public convenience init(id: String) {
        self.init(id: id, service: nil)
    }

    /// Creates a new success object instance.
    public init(id: String, service: NetService?) {
        self.id = id
        self.service = service
    }

    /// Converts the current instance into a dictionary.
    public func toJson() -> [String: Any] {
        var json: [String: Any] = [:]
        json["id"] = id
        if service != nil {
            json["service"] = serviceToJson(service!)
        }
        return json
    }
    
    /// Converts a given service to a dictionary.
    private func serviceToJson(_ service: NetService) -> [String: Any?] {
        return [
            "service.name": service.name,
            "service.type": service.type,
            "service.port": service.port,
            "service.ip": resolveIPv4(addresses: service.addresses),
        ]
    }
    
    /// Allows to resolve an IP v4 address.
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
