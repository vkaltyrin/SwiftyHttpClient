import Foundation

private let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US_POSIX")
    numberFormatter.numberStyle = .decimal
    return numberFormatter
}()

protocol RequestBuilder {
    func apiRequest<R: ApiRequest>(from request: R)
        -> DataResult<URLRequest, RequestError<R.Method.ErrorResponse>>
    
    func uploadRequest<R: UploadMultipartFormDataRequest>(from request: R)
        -> DataResult<R, RequestError<R.Method.ErrorResponse>>
}

final class RequestBuilderImpl: RequestBuilder {
    private let sessionInfoHolder: SessionInfoHolder
    private let commonRequestHeadersProvider: CommonRequestHeadersProvider
    
    private let baseUrl: String
    
    // MARK: - Init
    
    init(
        baseUrl: String,
        sessionInfoHolder: SessionInfoHolder,
        commonRequestHeadersProvider: CommonRequestHeadersProvider)
    {
        self.baseUrl = baseUrl
        self.sessionInfoHolder = sessionInfoHolder
        self.commonRequestHeadersProvider = commonRequestHeadersProvider
    }
    
    // MARK: - ApiRequest
    
    func apiRequest<R: ApiRequest>(from request: R)
        -> DataResult<URLRequest, RequestError<R.Method.ErrorResponse>>
    {
        let urlRequestResult = makeUrlRequest(from: request)
        
        switch urlRequestResult {
        case .error(let error):
            return .error(error)
        case .data(let urlRequest):
            return .data(urlRequest)
        }
    }
    
    func uploadRequest<R: UploadMultipartFormDataRequest>(from request: R)
        -> DataResult<R, RequestError<R.Method.ErrorResponse>>
    {
        switch makeRequest(from: request) {
        case .error(let error):
            return .error(error)
        case .data(let result):
            var request = request
            
            request.url = result.url.absoluteString
            request.headers = result.headers
            
            return .data(request)
        }
    }
    
    // MARK: - Private
    
    private func makeRequest<R: ApiRequest>(from request: R)
        -> DataResult<(url: URL, headers: [HttpHeader]), RequestError<R.Method.ErrorResponse>>
    {
        if request.method.isAuthorizationRequired && sessionInfoHolder.session == nil {
            return .error(.apiClientError(.attemptToSendAuthorizedRequestWithNoSession))
        }
        
        guard let url = makeUrl(from: request) else {
            return .error(.apiClientError(.cantBuildUrlFromGivenRequest))
        }
        
        return .data(
            (
                url: url,
                headers: makeHeaders(for: request)
            )
        )
    }
    
    private func makeUrlRequest<R: ApiRequest>(from request: R)
        -> DataResult<URLRequest, RequestError<R.Method.ErrorResponse>>
    
    {
        switch makeRequest(from: request) {
        case .error(let error):
            return .error(error)
        case .data(let result):
            var urlRequest = URLRequest(url: result.url)
            
            urlRequest.appendHttpHeaders(
                result.headers
            )
            
            urlRequest.httpMethod = request.method.httpMethod.value
            
            var parameters = [String: Any]()
            appendFlatternedParameters(&parameters, fromTreeParameters: request.params, keyPrefix: nil)
        
            do {
                let shouldSendParametersInUrl = request.method.httpMethod == .get || request.method.httpMethod == .head
                if shouldSendParametersInUrl {
                    let queryString = encodedSortedByKeyStringFrom(dictionary: parameters)
                    urlRequest.url = URL(string: result.url.absoluteString + "?" + queryString)
                } else {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                }
            } catch {
                print("error")
            }
            
            return .data(urlRequest)
        }
    }
    
    private func makeHeaders<R: ApiRequest>(for request: R) -> [HttpHeader] {
        // TODO: use keychain instead of SessionStorage
        return commonRequestHeadersProvider.headersForRequest(
            request: request,
            sessionId: sessionInfoHolder.session ?? SessionStorageImpl().sessionId
        )
    }
    
    private func makeUrl<T: ApiRequest>(from request: T) -> URL? {
        let baseUrl = URL(string: self.baseUrl)
        
        var pathComponents = [String]()
        
        pathComponents.append(request.method.pathPrefix)
        
        if request.method.version != 0 {
            pathComponents.append(String(request.method.version))
        }
        
        pathComponents.append(request.path)
        
        let normalizedQueryPath = pathComponents.joined(separator: "/").normalizedQueryPath()
        
        return URL(string: normalizedQueryPath, relativeTo: baseUrl)
    }
    
    private func appendFlatternedParameters(
        _ flatternedParameters: inout [String: Any],
        fromTreeParameters treeParameters: [String: Any],
        keyPrefix: String?)
    {
        for (key, value) in treeParameters {
            let nextKeyPrefix: String
            
            if let keyPrefix = keyPrefix {
                nextKeyPrefix = "\(keyPrefix)[\(key)]"
            } else {
                nextKeyPrefix = key
            }
            
            if let array = value as? [Any] {
                for (index, item) in array.enumerated() {
                    // Call this function again as if array was a dictionary
                    appendFlatternedParameters(
                        &flatternedParameters,
                        fromTreeParameters: [String(index): item],
                        keyPrefix: nextKeyPrefix
                    )
                }
            } else if let dictionary = value as? [String: Any] {
                appendFlatternedParameters(
                    &flatternedParameters,
                    fromTreeParameters: dictionary,
                    keyPrefix: nextKeyPrefix
                )
            } else if let string = value as? String {
                flatternedParameters[nextKeyPrefix] = string
            } else if let number = value as? NSNumber {
                flatternedParameters[nextKeyPrefix] = numberFormatter.string(from: number)
            } else {
                flatternedParameters[nextKeyPrefix] = value
            }
        }
    }
    
    private func encodedSortedByKeyStringFrom(dictionary: [String: Any]) -> String {
        var result = ""
        let sortedKeys = dictionary.keys.sorted(by: <)
        
        for key in sortedKeys {
            if let value = dictionary.stringFor(key: key) {
                if !result.isEmpty {
                    result+="&"
                }
                
                let encodedKey = key.byAddingCustomPercentEncodingForChecksumCalculation()
                let encodedValue = value.byAddingCustomPercentEncodingForChecksumCalculation()
                
                result += "\(encodedKey)=\(encodedValue)"
            }
        }
        return result
    }
}
