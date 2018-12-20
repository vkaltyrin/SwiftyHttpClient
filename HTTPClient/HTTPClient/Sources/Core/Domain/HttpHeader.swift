public final class HttpHeader {
    public enum DefaultField: String {
        case contentType = "Content-Type"
        case userAgent = "User-Agent"
        case xSession = "X-Session"
        case xDate = "X-Date"
        case cookie = "Cookie"

        var name: String {
            return rawValue
        }
    }
    
    let name: String
    let value: String
    
    // MARK: - Init
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    public init(field: DefaultField, value: String) {
        name = field.name
        self.value = value
    }
    
    public init?(field: DefaultField, value: String?) {
        guard let fieldValue = value else {
            return nil
        }
        name = field.name
        self.value = fieldValue
    }
}
