/// Sent to the event channel when there is no error.
class SuccessObject {
    /// The response id.
    let id: String

    /// The response result.
    let result: Any?

    /// Creates a new instance with any result.
    public convenience init(id: String) {
        self.init(id: id, result: nil)
    }

    /// Creates a new success object instance.
    public init(id: String, result: Any?) {
        self.id = id
        self.result = result
    }

    /// Converts the current instance into a dictionary.
    public func toJson() -> [String: Any] {
        var json: [String: Any] = [:]
        json["id"] = id
        if result != nil {
            json["result"] = result
        }
        return json
    }
}
