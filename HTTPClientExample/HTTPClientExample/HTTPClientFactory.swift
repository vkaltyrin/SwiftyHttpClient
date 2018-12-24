import Foundation
import HTTPClient

protocol HTTPClientFactory: class {
    func githubHTTPClient(logger: Logger) -> HTTPClient
}

final class HTTPClientFactoryImpl: HTTPClientFactory {
    func githubHTTPClient(logger: Logger) -> HTTPClient {
        return HTTPClientImpl(
            commonHeadersProvider: GithubCommonHeaderProvider(),
            beforeDecodingStrategy: GithubResponseStrategy(),
            logger: logger
        )
    }
}
