import Foundation

public final class ResponseDecoderImpl: ResponseDecoder {
    // MARK :- Dependencies
    private let beforeDecodingStrategy: BeforeDecodingStrategy
    
    // MARK: - Init
    public init(beforeDecodingStrategy: BeforeDecodingStrategy) {
        self.beforeDecodingStrategy = beforeDecodingStrategy
    }
    
    public convenience init() {
        self.init(beforeDecodingStrategy: DefaultBeforeDecodingStrategy())
    }
    
    // MARK :- ResponseDecoder
    
    public func decode<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
        )
    {
        if let result = beforeDecodingStrategy.process(response: response, for: request) {
            completion(result)
            return
        }
        
        switch response.result {
        case .error(let error):
            // Unknown network error
            completion(.error(.networkError(error)))
        case .data(let value):
            if let error = request.errorConverter.decodeResponse(data: value) {
                completion(.error(.apiError(error)))
            } else if let result = request.resultConverter.decodeResponse(data: value) {
                completion(.data(result))
            } else {
                completion(.error(.apiClientError(.decodingFailure)))
            }
        }
    }
}
