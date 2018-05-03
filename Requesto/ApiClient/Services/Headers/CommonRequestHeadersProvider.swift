// Common headers for different types of request
 protocol CommonRequestHeadersProvider {
    func headersForRequest<R: ApiRequest>(
        request: R,
        sessionId: String?)
        -> [HttpHeader]
}

final class CommonRequestHeadersProviderImpl: CommonRequestHeadersProvider {
    private let xSessionHeaderProvider: XSessionHeaderProvider
    private let xDateHeaderProvider: XDateHeaderProvider
    
    init(
        xSessionHeaderProvider: XSessionHeaderProvider,
        xDateHeaderProvider: XDateHeaderProvider)
    {
        self.xSessionHeaderProvider = xSessionHeaderProvider
        self.xDateHeaderProvider = xDateHeaderProvider
    }
    
    func headersForRequest<R: ApiRequest>(
        request: R,
        sessionId: String?)
        -> [HttpHeader]
    {
        var headers = [HttpHeader]()
        
        if let sessionId = sessionId {
            headers.append(xSessionHeaderProvider.xSessionHeader(sessionId: sessionId))
        }
        
        if let header = xDateHeaderProvider.xDateHeader() {
            headers.append(header)
        }
        
        return headers
    }
}
