import Foundation

public enum RetryPolicy {
    case noRetry
    case retryOnce
}

public protocol ApiRequest {
    associatedtype Result
    associatedtype ErrorResponse
    
    var endpoint: String { get }
    var method: HttpMethod { get }
    var path: String { get }
    
    var headers: [HttpHeader] { get }
    var params: [String: Any] { get }
    var httpBody: Data? { get }
    
    var cachePolicy: RequestCachePolicy { get }
    var retryPolicy: RetryPolicy { get }
    var retrier: RequestRetrier? { get }
    
    var errorConverter: ResponseConverterOf<ErrorResponse> { get }
    var resultConverter: ResponseConverterOf<Result> { get }
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
    
    var retrier: RequestRetrier? {
        return nil
    }
}
