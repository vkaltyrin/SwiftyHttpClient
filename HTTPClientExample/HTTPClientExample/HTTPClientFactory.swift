import Foundation
import HTTPClient

protocol HTTPClientFactory: class {
    func githubHTTPClient() -> HTTPClient
}

final class HTTPClientFactoryImpl: HTTPClientFactory {
    func githubHTTPClient() -> HTTPClient {
        return HTTPClientImpl(
            commonHeadersProvider: GithubCommonHeaderProvider(),
            beforeDecodingStrategy: GithubResponseStrategy())
    }
}
