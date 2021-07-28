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
            "service.attributes": LWSafeNSServiceDecode(fromTXTRecord: service.txtRecordData() ?? NetService.data(fromTXTRecord: [:]))
        ]
    }

    // This is a safer function to decode a Bonjour discovered record. The default "NetService.dictionary" will throw if a key is not a key value pair (i.e. it is a Key==NULL)... (seen when we publish a system with no system name)
    // From: https://stackoverflow.com/questions/40193911/nsnetservice-dictionaryfromtxtrecord-fails-an-assertion-on-invalid-input
    // A blank Key should be treated as a true bool as discussed here: http://www.zeroconf.org/Rendezvous/txtrecords.html
    func LWSafeNSServiceDecode(fromTXTRecord txtData: Data) -> [String: String] {
        var result = [String: String]()
        var data = txtData

        while !data.isEmpty {
            // The first byte of each record is its length, so prefix that much data
            let recordLength = Int(data.removeFirst())
            guard data.count >= recordLength else { return [:] }
            let recordData = data[..<(data.startIndex + recordLength)]
            data = data.dropFirst(recordLength)

            guard let record = String(bytes: recordData, encoding: .utf8) else { return [:] }
            // The format of the entry is "key=value"
            // (According to the reference implementation, = is optional if there is no value,
            // and any equals signs after the first are part of the value.)
            // `ommittingEmptySubsequences` is necessary otherwise an empty string will crash the next line
            let keyValue = record.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            let key = String(keyValue[0])
            // If there's no value, make the value the empty string
            switch keyValue.count {
            case 1:
                result[key] = Bool(true).description
            case 2:
                result[key] = String(keyValue[1])
            default:
                fatalError()
            }
        }

        return result
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
    
    /// Decodes the given attributes.
    private func decodeAttributes(attributes: [String: Data?]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in attributes {
            if(value != nil) {
                result[key] = String(decoding: value!, as: UTF8.self)
            }
        }
        return result
    }
}
