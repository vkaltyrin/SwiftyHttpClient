import Foundation

public protocol UploadMultipartFormDataRequestOperationBuilder: class {
    func buildOperation<R: UploadMultipartFormDataRequest>(
        request: R,
        dataProvider: DataProvider,
        uploader: Uploader,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
        ) -> Operation
}
