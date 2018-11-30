import Foundation

protocol RequestBuilder {
    func buildUrlRequest<R: ApiRequest>(from request: R)
        -> DataResult<URLRequest, RequestError<R.ErrorResponse>>
    
    func buildUploadRequest<R: UploadMultipartFormDataRequest>(from request: R)
        -> DataResult<R, RequestError<R.ErrorResponse>>
}
