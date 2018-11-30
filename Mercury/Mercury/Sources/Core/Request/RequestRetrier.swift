import Foundation

public protocol RequestRetrier: class {
    func shouldRetry<R: ApiRequest>(policy: RetryPolicy, request: R) -> Bool
}
