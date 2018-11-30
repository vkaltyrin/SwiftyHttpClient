import XCTest
import Quick
import Nimble
@testable import Mercury

private struct TestSuccessResponse: Decodable {}
private struct TestFailureResponse: Decodable {}

private struct TestApiRequest: ApiRequest {
    var method: HttpMethod
    var endpoint: String
    var path: String
    var params: [String : Any]
    
    typealias Result = TestSuccessResponse
    typealias ErrorResponse = TestFailureResponse
    
    init(method: HttpMethod, endpoint: String, path: String, params: [String : Any]) {
        self.method = method
        self.endpoint = endpoint
        self.path = path
        self.params = params
    }
}

class RequestBuilderSpec: QuickSpec {
    var requestBuilder: RequestBuilder!
    
    override func spec() {
        beforeSuite {
            self.requestBuilder = RequestBuilderImpl(
                commonHeadersProvider: CommonHeadersProviderImpl()
            )
        }
        
        describe("Request") {
            context("when it's defined with post http method") {
                it("is built correctly") {
                    let request = TestApiRequest(
                        method: .post,
                        endpoint: "http://google.com",
                        path: "/user/auth",
                        params: [:]
                    )
                    
                    let result = self.requestBuilder.buildUrlRequest(from: request)
                    let urlRequest = try! URLRequest(url: "http://google.com/user/auth", method: .post)
                    expect(result).to(beData { value in
                        expect(value.url?.absoluteString).to(equal(urlRequest.url?.absoluteString))
                    })
                }
            }
        }
    }
}

func beData<T,E>(_ test: @escaping (T) -> Void = { _ in }) -> Predicate<DataResult<T, E>> {
    return Predicate.define("be <data>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .data(value) = actual {
            test(value)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

func beError<T,E>(_ test: @escaping (E) -> Void = { _ in }) -> Predicate<DataResult<T, E>> {
    return Predicate.define("be <error>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .error(error) = actual {
            test(error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
