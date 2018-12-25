import Foundation

final class AlamofireUploadMultipartFormDataOperationBuilder: UploadMultipartFormDataRequestOperationBuilder {
    
    private let uploader: AlamofireUploader
    
    init(uploader: AlamofireUploader) {
        self.uploader = uploader
    }
    
    func buildOperation<R: UploadMultipartFormDataRequest>(
        request: R,
        dataProvider: DataProvider,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion
        ) -> Operation
    {
        return AlamofireUploadMultipartFormDataRequestOperation(
            request: request,
            dataProvider: dataProvider,
            uploader: uploader,
            onProgressChange: onProgressChange,
            completion: completion
        )
    }
}
