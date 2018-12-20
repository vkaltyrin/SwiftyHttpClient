/*
 Implement ResponseDecoder and inject it into the HTTPClient.
 */
public protocol ResponseDecoder: class {
    func decode<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
    )
}
