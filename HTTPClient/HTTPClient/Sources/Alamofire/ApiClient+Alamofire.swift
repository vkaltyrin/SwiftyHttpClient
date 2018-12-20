import Foundation

final class HTTPClientFactory {
    
    class func HTTPClient(
        commonHeadersProvider: CommonHeadersProvider,
        responseDecoder: ResponseDecoder
        ) -> HTTPClient {
        return HTTPClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: commonHeadersProvider,
            responseDecoder: responseDecoder
        )
    }
    
    class func HTTPClient(
        requestRetrier: RequestRetrier,
        commonHeadersProvider: CommonHeadersProvider,
        responseDecoder: ResponseDecoder
        ) -> HTTPClient {
        return HTTPClientImpl(
            requestBuilder: RequestBuilderImpl(
                commonHeadersProvider: commonHeadersProvider
            ),
            requestRetrier: requestRetrier,
            requestDispatcher: AlamofireRequestDispatcher(
                responseDecoder: responseDecoder
            ),
            uploader: AlamofireBackgroundUploader(),
            operationBuilder: AlamofireUploadMultipartFormDataOperationBuilder()
        )
    }
}
