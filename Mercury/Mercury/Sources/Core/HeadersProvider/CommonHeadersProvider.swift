import Foundation

public protocol CommonHeadersProvider {
    func headersForRequest<R: ApiRequest>(request: R) -> [HttpHeader]
}

final class CommonHeadersProviderImpl: CommonHeadersProvider {
    func headersForRequest<R: ApiRequest>(request: R) -> [HttpHeader] {
        return []
    }
}
