import Foundation
@testable import HTTPClient

struct TestSuccessResponse: Decodable {}
struct TestFailureResponse: Decodable {}

struct TestApiRequest: ApiRequest {
    let method: HttpMethod
    let endpoint: String
    let path: String
    let params: [String : Any]
    let headers: [HttpHeader]
    let httpBody: Data?
    let cachePolicy: RequestCachePolicy
    
    typealias Result = TestSuccessResponse
    typealias ErrorResponse = TestFailureResponse
    
    init(
        method: HttpMethod,
        endpoint: String,
        path: String,
        params: [String : Any],
        headers: [HttpHeader],
        httpBody: Data?,
        cachePolicy: RequestCachePolicy)
    {
        self.method = method
        self.endpoint = endpoint
        self.path = path
        self.params = params
        self.headers = headers
        self.httpBody = httpBody
        self.cachePolicy = cachePolicy
    }
}
