/*
 Implement ResponseDecoder and inject it into the ApiClient.
 */
public protocol ResponseDecoder: class {
    func decode<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
    )
}
