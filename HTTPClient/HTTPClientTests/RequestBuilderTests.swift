import XCTest
import Quick
import Nimble
@testable import HTTPClient

class RequestBuilderSpec: QuickSpec {
    var requestBuilder: RequestBuilder!
    
    override func spec() {
        beforeSuite {
            self.requestBuilder = RequestBuilderImpl(
                commonHeadersProvider: CommonHeadersProviderImpl()
            )
        }
        
        describe("http://api.github.com/gists/1/comments") {
            context("PUT, POST, OPTIONS, PATCH, DELETE, TRACE, CONNECT") {
                
                let methods: [HttpMethod] = [
                    .put,
                    .post,
                    .options,
                    .patch,
                    .delete,
                    .trace,
                    .connect
                ]
                
                it("creates a valid request") {
                    methods.forEach {
                        self.validateRequest(
                            method: $0,
                            endpoint: "http://api.github.com",
                            path: "/gists/1/comments",
                            params: ["body" : "Just commenting for the sake of commenting"],
                            headers: [],
                            httpBody: nil,
                            cachePolicy: .useProtocolCachePolicy
                        )
                    }
                }
                
                context("Contains header") {
                    it("creates a valid request") {
                        methods.forEach {
                            self.validateRequest(
                                method: $0,
                                endpoint: "http://api.github.com",
                                path: "/gists/1/comments",
                                params: ["body" : "Just commenting for the sake of commenting"],
                                headers: [
                                    HttpHeader(name: "Accept", value: "application/vnd.github.v3+json")
                                ],
                                httpBody: nil,
                                cachePolicy: .useProtocolCachePolicy
                            )
                        }
                    }
                }
                
                context("Contains array in parameters") {
                    it("creates a valid request") {
                        methods.forEach {
                            self.validateRequest(
                                method: $0,
                                endpoint: "http://api.github.com",
                                path: "/repos/google/earlgrey/topic",
                                params: ["names" : [
                                    "octocat",
                                    "atom",
                                    "electron",
                                    "API"
                                    ]
                                ],
                                headers: [
                                    HttpHeader(name: "Accept", value: "application/vnd.github.v3+json")
                                ],
                                httpBody: nil,
                                cachePolicy: .useProtocolCachePolicy,
                                expectedParams: [
                                    "names[0]" : "octocat",
                                    "names[1]" : "atom",
                                    "names[2]" : "electron",
                                    "names[3]" : "API"
                                ]
                            )
                        }
                    }
                }
                
            }
            
            context("HEAD, GET") {
                let methods: [HttpMethod] = [
                    .head,
                    .get
                ]
                
                context("Parameters are empty") {
                    it("creates a valid request") {
                        methods.forEach {
                            self.validateRequest(
                                method: $0,
                                endpoint: "http://api.github.com",
                                path: "/gists/1/comments",
                                params: [:],
                                headers: [],
                                httpBody: nil,
                                cachePolicy: .useProtocolCachePolicy
                            )
                        }
                    }
                }
                
                context("Parameters are non empty") {
                    it("creates a valid request") {
                        methods.forEach {
                            self.validateRequest(
                                method: $0,
                                endpoint: "http://api.github.com",
                                path: "/gists/1/comments",
                                params: [
                                    "param1" : "value1",
                                    "param2" : "value2"
                                ],
                                headers: [],
                                httpBody: nil,
                                cachePolicy: .useProtocolCachePolicy,
                                expectedPostfix: "?param1=value1&param2=value2"
                            )
                        }
                    }
                }
                
                context("Contains header") {
                    it("creates a valid request") {
                        methods.forEach {
                            self.validateRequest(
                                method: $0,
                                endpoint: "http://api.github.com",
                                path: "/gists/1/comments",
                                params: [:],
                                headers: [
                                    HttpHeader(name: "Accept", value: "application/vnd.github.v3+json"),
                                    HttpHeader(name: "Auth", value: "token")
                                ],
                                httpBody: nil,
                                cachePolicy: .useProtocolCachePolicy
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func validateRequest(
        method: HttpMethod,
        endpoint: String,
        path: String,
        params: [String: Any],
        headers: [HttpHeader],
        httpBody: Data?,
        cachePolicy: RequestCachePolicy,
        expectedPostfix: String = "",
        expectedParams: [String: Any]? = nil)
    {
        let request = TestApiRequest(
            method: method,
            endpoint: endpoint,
            path: path,
            params: params,
            headers: headers,
            httpBody: httpBody,
            cachePolicy: cachePolicy
        )
        
        let result = self.requestBuilder.buildUrlRequest(from: request)
        let urlString = endpoint + path + expectedPostfix
        var allHTTPHeaderFields: [String: String] = [:]
        headers.forEach { header in
            allHTTPHeaderFields[header.name] = header.value
        }
        
        expect(result).to(beData { urlRequest in
            switch method {
            case .get, .head:
                let httpBodyMatcher = httpBody != nil ? equal(httpBody) : beNil()
                expect(urlRequest.httpBody).to(httpBodyMatcher)
            default:
                if
                    let body = urlRequest.httpBody,
                    let requestJsonObject = try? JSONSerialization.jsonObject(
                        with: body,
                        options: JSONSerialization.ReadingOptions.allowFragments),
                    let requestJson = requestJsonObject as? [String: Any]
                {
                    let dictionary: NSDictionary
                    if let toEqualParams = expectedParams {
                        dictionary = NSDictionary(dictionary: toEqualParams)
                    } else {
                        dictionary = NSDictionary(dictionary: params)
                    }
                    expect(NSDictionary(dictionary: requestJson))
                        .to(equal(NSDictionary(dictionary: dictionary)))
                }
            }
            
            expect(urlRequest.url?.absoluteString).to(equal(urlString))
            expect(urlRequest.httpMethod).to(equal(method.value))
            expect(urlRequest.allHTTPHeaderFields).to(equal(allHTTPHeaderFields))
            expect(urlRequest.cachePolicy).to(equal(cachePolicy.toNSURLRequestCachePolicy))
        })
    }
}
