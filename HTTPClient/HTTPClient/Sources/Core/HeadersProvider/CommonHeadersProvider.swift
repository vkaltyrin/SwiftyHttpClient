import Foundation

public protocol CommonHeadersProvider {
    func headersForRequest<R: ApiRequest>(request: R) -> [HttpHeader]
}

public final class CommonHeadersProviderImpl: CommonHeadersProvider {
    public func headersForRequest<R: ApiRequest>(request: R) -> [HttpHeader] {
        return []
    }
}
