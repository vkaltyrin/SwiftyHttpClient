import Foundation
import HTTPClient

/*
 GithubRequest contains common parameters for all requests of the Github API.
 */
protocol GithubRequest: ApiRequest where ErrorResponse == GithubErrorResponse {}

extension GithubRequest {
    var endpoint: String {
        return "https://api.github.com"
    }
}

/*
 This class provides common headers for each request of the Github API. It's injected into the HttpClient.
 Look at HttpClientFactory.
 */
final class GithubCommonHeaderProvider: CommonHeadersProvider {
    func headersForRequest<R>(request: R) -> [HttpHeader] where R : ApiRequest {
        return [HttpHeader(name: "Accept", value: "application/vnd.github.v3+json")]
    }
}

/*
 This struct implements the Github API specification of errors. Look at https://developer.github.com/v3/#client-errors for details.
 */
struct GithubErrorResponse: Decodable {
    struct Error: Decodable {
        let resource: String
        let field: String
        let code: String
    }
    
    let message: String
    let errors: [Error]
}

/*
 Currently this class is written manually, but there is a plan to generate it using the Sourcery.
 For now, just write it manually.
 */
final class GithubAPI {
    func searchRepositoriesRequest(
        query: String,
        sort: GithubSearchRepositoriesRequest.SortKey,
        order: GithubSearchRepositoriesRequest.OrderKey
        ) -> GithubSearchRepositoriesRequest {
        return GithubSearchRepositoriesRequest(
            query: query,
            sort: sort,
            order: order
        )
    }
    
    func basicAuthorization(username: String, password: String) -> GithubBasicAuthorizationRequest {
        return GithubBasicAuthorizationRequest(username: username, password: password)
    }
}
