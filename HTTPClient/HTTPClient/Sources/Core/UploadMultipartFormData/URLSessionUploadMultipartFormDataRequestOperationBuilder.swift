import Foundation

// TODO: implement it
final class URLSessionUploadMultipartFormDataRequestOperationBuilder: UploadMultipartFormDataRequestOperationBuilder {
    func buildOperation<R: UploadMultipartFormDataRequest>(
        request: R,
        dataProvider: DataProvider,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
        ) -> Operation {
        return Operation()
    }
}
