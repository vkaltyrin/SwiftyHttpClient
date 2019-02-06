# SwiftyHttpClient

This library is just a light-weight HTTPClient which is widely used by me in different iOS projects. It's similar to Moya in some cases, but the key difference is a usage of generics to adopt decoders and OOP style for creation of requests.

# FAQ

* [What is ApiRequest](#request)
* [How to use one base url for all requests](#baseurl)
* [How to add specific headers for all requests](#headers)
* [How to implement a request using spec](#definerequest)
* [How to proccess the response](#response)
* [How to send the request](#sendrequest)
* [How to learn more via the Example project](#demo)
* [How to use it with the Alamofire](#alamofire)

<a name="request"/>

## What is ApiRequest

Let's consider there is a need to create a request to Github API.
Here is a spec of the request [URL](https://developer.github.com/v3/repos/#list-your-repositories).

There is a `ApiRequest` protocol to define the spec of the request.

```swift

public protocol ApiRequest {
    associatedtype Result
    associatedtype ErrorResponse
    
    var basePath: String { get }
    var method: HttpMethod { get }
    var path: String { get }
    
    var headers: [HttpHeader] { get }
    var params: [String: Any] { get }
    var httpBody: Data? { get }
    
    var cachePolicy: RequestCachePolicy { get }
    var retryPolicy: RetryPolicy { get }
    var retrier: RequestRetrier? { get }
    
    var errorConverter: ResponseConverterOf<ErrorResponse> { get }
    var resultConverter: ResponseConverterOf<Result> { get }
}

```


`ResponseConverterOf<T>` – it's a response converter, which goal is to decode data to the object of type `T`.
`SwiftHttpClient` provides a default implementation of this convert for the type  `T: Codable`.
As a general rule, there is no need to implement own response converter, it's enough to use the default implementation.

`ErrorResponse` – it's a unified type of [error for the Github API](https://developer.github.com/v3/#client-errors)

There is a corresponding `struct` conforming to the `Codable` protocol.

```swift

struct GithubErrorResponse: Codable {
    struct Error: Codable {
        let resource: String
        let field: String
        let code: String
    }
    
    let message: String
    let errors: [Error]
}

```

`Result` – it's a type of the corresponding type of the model.

Let's define the `GithubRequest` for all requests of the Github API.

```swift

protocol GithubRequest: ApiRequest where ErrorResponse == GithubErrorResponse {}

```

All requests of the Github API have the unified format of the response for the error `GithubErrorResponse`.
`Result` is defined in the particular request using the  `associated type`.

```swift

extension GithubUserRepositoriesRequest: GithubRequest {
    typealias Result = [GithubRepository]

    ...
}

```

`GithubRepository` is the struct which is conforming to `Codable` protocol:

```swift

struct GithubRepository: Codable {
    let name: String
    let fork: Bool
}

```

## How to use one base url for all requests

<a name="baseurl"/>

Base url for the Github API is `https://api.github.com`.
Let's define an extension:

```swift

extension GithubRequest {
    var basePath: String {
        return "https://api.github.com"
    }
}

```

Now all requests have one base url.

## How to add specific headers for all requests

<a name="headers"/>

Let's define:

```swift

final class GithubCommonHeaderProvider: CommonHeadersProvider {
    func headersForRequest<R>(request: R) -> [HttpHeader] where R : ApiRequest {
        return [HttpHeader(name: "Accept", value: "application/vnd.github.v3+json")]
    }
}

```

Thereafter, it's injected into the `HttpClient`.

## How to implement a request using spec

<a name="definerequest"/>

It's easy, there is a need to define the structure like this for parameters:

```swift

struct GithubUserRepositoriesRequest {
    enum Visibility: String {
        case all
        case `public`
        case `private`
    }
    
    // MARK: - Parameters
    private let username: String
    private let password: String
    private let visibility: Visibility
    
    // MARK: - Init
    init(username: String, password: String, visibility: Visibility) {
        self.username = username
        self.password = password
        self.visibility = visibility
    }
}

```

For the specific request it's possible to specify path, headers, http method, parameters and so on:

```swift

extension GithubUserRepositoriesRequest: GithubRequest {
    typealias Result = [GithubRepository]
    
    /*
     Look at https://developer.github.com/v3/auth/#via-username-and-password
     */
    var headers: [HttpHeader] {
        guard let userData = "\(username):\(password)".data(using: String.Encoding.utf8) else {
            return []
        }
        let basicAuthorizationHeaderValue = "Basic \(userData.base64EncodedString())"
        return [
            HttpHeader(name: "Authorization", value: basicAuthorizationHeaderValue)
        ]
    }
    
    var method: HttpMethod {
        return .get
    }
    
    var path: String {
        return "/user/repos"
    }
    
    var params: [String : Any] {
        return ["visibility" : visibility.rawValue]
    }
}

```

Headers defined in `var headers: [HttpHeader]` are merged with headers which implemented the `CommonHeadersProvider` protocol. The default implementation of `DefaultCommonHeadersProvider` contains nothing headers.

Algorithm to define the request:
1. Understand the specification
2. Implement corresponding struct
3. Implement corresponding extension

## How to proccess the response

<a name="response"/>

To implement custom processing of the response there is a `BeforeDecodingStrategy` protocol. The implementation can be injected in the `HttpClient`.

```swift

final class GithubResponseStrategy: BeforeDecodingStrategy {
    func process<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R
        ) -> DataResult<R.Result, RequestError<R.ErrorResponse>>?
    {
        if response.response?.statusCode == 401 {
            return .error(.httpUnauthenticated)
        }
        
        if response.response?.statusCode == 403 {
            return .error(.forbidden)
        }
        
        return nil
    }
}

```

## How to send the request

<a name="sendrequest"/>

Here is an algorithm:

1. Inject `HttpClient` in the corresponding service.
2. Send the request:

```swift

let request = GithubUserRepositoriesRequest(
            username: username,
            password: password,
            visibility: .private
        )

httpClient.send(request: request) { [weak self] result in
    result.onData { [weak self] response in
        self?.log(response)
    }
    result.onError { error in
        switch error {
        case .apiError(let apiError):
            self?.log(apiError)
        default:
            self?.log("Error. Debug for investigation.")
        }
    }
}

```

## How to learn more via the Example project

<a name="demo"/>

You can learn more if you look at the [example project](https://github.com/vkaltyrin/SwiftyHttpClient/tree/master/HTTPClientExample).

## How to use it with the Alamofire

<a name="alamofire"/>

There is also an implementation of core classes using the Alamofire.
Here is an [url](https://github.com/vkaltyrin/SwiftyHttpClient/tree/master/HTTPClientAlamofire).
