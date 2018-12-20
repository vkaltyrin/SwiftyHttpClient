import Foundation

final class Mercury {
    class func apiClient() -> ApiClient {
        return apiClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: CommonHeadersProviderImpl(),
            responseDecoder: JsonResponseParserImpl()
        )
    }
    
    class func apiClient(
        commonHeadersProvider: CommonHeadersProvider,
        responseDecoder: ResponseDecoder
        ) -> ApiClient {
        return apiClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: commonHeadersProvider,
            responseDecoder: responseDecoder
        )
    }
    
    class func apiClient(
        requestRetrier: RequestRetrier,
        commonHeadersProvider: CommonHeadersProvider,
        responseDecoder: ResponseDecoder
        ) -> ApiClient {
        return ApiClientImpl(
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
