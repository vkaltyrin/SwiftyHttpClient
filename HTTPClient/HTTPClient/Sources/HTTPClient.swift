import Foundation

public protocol HTTPClient: class {
    @discardableResult
    func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    
    @discardableResult
    func send<R: UploadMultipartFormDataRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
}
