import Alamofire

// Implement ResponseParser protocol and inject imp into ApiClient to support the specific behaviour.
public protocol ResponseParser: class {
    func parse<R: ApiRequest>(
        response: DataResponse<Data>,
        for request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
    )
}
