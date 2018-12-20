import Foundation

public protocol HTTPClient: class {
    @discardableResult
    func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    
    @discardableResult
    func upload<R: UploadMultipartFormDataRequest>(
        dataProvider: DataProvider,
        request: R,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
}
