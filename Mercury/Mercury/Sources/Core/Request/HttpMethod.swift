public enum HttpMethod: String {
    case options, get, head, post, put, patch, delete, trace, connect
    var value: String {
        return rawValue.uppercased()
    }
}
