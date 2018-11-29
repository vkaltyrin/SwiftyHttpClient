import Alamofire

public enum HttpMethod: String {
    case options, get, head, post, put, patch, delete, trace, connect
    var value: String {
        return rawValue.uppercased()
    }
}

public extension HttpMethod {
    var toAlamofireMethod: Alamofire.HTTPMethod {
        switch self {
        case .options:
            return .options
        case .get:
            return .get
        case .head:
            return .head
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        case .trace:
            return .trace
        case .connect:
            return .connect
        }
    }
}
