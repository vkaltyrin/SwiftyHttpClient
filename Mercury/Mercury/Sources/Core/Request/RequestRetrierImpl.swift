import Foundation

final class RequestRetrierImpl: RequestRetrier {
    func shouldRetry<R>(policy: RetryPolicy, request: R) -> Bool where R : ApiRequest {
        switch policy {
        case .noRetry:
            return false
        case .retryOnce:
            return true
        }
    }
}
