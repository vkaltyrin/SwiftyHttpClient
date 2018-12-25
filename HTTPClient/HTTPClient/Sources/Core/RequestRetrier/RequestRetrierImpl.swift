import Foundation

public final class RequestRetrierImpl: RequestRetrier {
    
    public init() {}
    
    public func shouldRetry<R>(policy: RetryPolicy, request: R) -> Bool where R : ApiRequest {
        switch policy {
        case .noRetry:
            return false
        case .retryOnce:
            return true
        }
    }
}
