import Foundation

public enum RetryPolicy {
    case noRetry
    case retryOnce
}

public protocol ApiRequest {
    associatedtype Method: ApiMethod
    
    var method: Method { get }
    var endpoint: String { get }
    var path: String { get }
    var headers: [HttpHeader] { get }
    var params: [String: Any] { get }
    var httpBody: Data? { get }
    var cachePolicy: RequestCachePolicy { get }
    var retryPolicy: RetryPolicy { get }
}

public extension ApiRequest {
     var cachePolicy: RequestCachePolicy {
        return .useProtocolCachePolicy
    }
     var headers: [HttpHeader] { return [] }
    
     var httpBody: Data? {
        return nil
    }
    
    var retryPolicy: RetryPolicy {
        return .noRetry
    }
}
