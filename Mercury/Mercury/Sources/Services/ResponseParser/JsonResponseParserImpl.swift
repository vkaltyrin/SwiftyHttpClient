import Alamofire

public final class JsonResponseParserImpl: ResponseParser {
    
    // MARK :- ResponseParser
    
    public func parse<R: ApiRequest>(
        response: DataResponse<Data>,
        for request: R,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion
        )
    {
        if response.response?.statusCode == 401 {
            completion(.error(.httpUnauthenticated))
            return
        }
        
        if response.response?.statusCode == 403 {
            completion(.error(.forbidden))
            return
        }
        
        switch response.result {
        case .failure(let error):
            // Unknown network error
            completion(.error(.networkError(error)))
        case .success(let value):
            // Parse success response

            let method = request.method
            if let error = method.errorConverter.decodeResponse(data: value) {
                completion(.error(.apiError(error)))
            } else if let result = method.resultConverter.decodeResponse(data: value) {
                // Return parsed response
                completion(.data(result))
            } else {
                completion(.error(.apiClientError(.parsingFailure)))
            }
        }
    }
}
