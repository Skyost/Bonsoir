class SuccessObject {
    let id: String
    let result: Any?
    
    public convenience init(id: String) {
        self.init(id: id, result: nil)
    }
    
    public init(id: String, result: Any?) {
        self.id = id
        self.result = result
    }
    
    public func toJson() -> [String: Any] {
        var json: [String: Any] = [:]
        json["id"] = id
        if result != nil {
            json["result"] = result
        }
        return json
    }
}
