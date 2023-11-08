import Network

/// Represents a Bonsoir service.
class BonsoirService {
    /// The response service name.
    let name: String?
    
    /// The response service type.
    let type: String?
    
    /// The response service port.
    let port: Int?
    
    /// The response service name.
    let ip: String?
    
    /// The response service name.
    let attributes: [String : String]?

    /// Creates a new service instance.
    public init(name: String?, type: String?, port: Int?, ip: String?, attributes: [String : String]?) {
        self.name = name
        self.type = type
        self.port = port
        self.ip = ip
        self.attributes = attributes
    }
    
    /// Creates a new service instance.
    public init(service: NWListener.Service) {
        self.init(name: name, type: type, port: port, ip: '127.0.0.1', attributes: service.txtRecordObject.dictionary) 
    }
    
    /// Converts a given service to a dictionary.
    private func toJson(prefix: String = "service.") -> [String: Any?] {
        return [
            "\(prefix)name": name,
            "\(prefix)type": type,
            "\(prefix)port": port,
            "\(prefix)ip": ip,
            "\(prefix)attributes": attributes
        ]
    }
	
	/// Returns the description of this object.
	public var description: String {
		return "\(toJson(prefix: ""))"
	}
}
