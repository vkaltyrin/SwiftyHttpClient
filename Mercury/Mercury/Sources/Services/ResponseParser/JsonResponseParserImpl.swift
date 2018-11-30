import Alamofire

public final class JsonResponseParserImpl: ResponseParser {
    
    // MARK :- ResponseParser
    
    public func parse<R: ApiRequest>(
        response: DataResponse<Data>,
        for request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
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

            if let error = request.errorConverter.decodeResponse(data: value) {
                completion(.error(.apiError(error)))
            } else if let result = request.resultConverter.decodeResponse(data: value) {
                // Return parsed response
                completion(.data(result))
            } else {
                completion(.error(.apiClientError(.parsingFailure)))
            }
        }
    }
}
