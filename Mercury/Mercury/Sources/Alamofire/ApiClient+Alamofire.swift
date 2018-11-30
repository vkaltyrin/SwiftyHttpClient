import Foundation

final class Mercury {
    class func apiClient() -> ApiClient {
        return apiClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: CommonHeadersProviderImpl(),
            responseParser: JsonResponseParserImpl()
        )
    }
    
    class func apiClient(
        commonHeadersProvider: CommonHeadersProvider,
        responseParser: ResponseParser
        ) -> ApiClient {
        return apiClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: commonHeadersProvider,
            responseParser: responseParser
        )
    }
    
    class func apiClient(
        requestRetrier: RequestRetrier,
        commonHeadersProvider: CommonHeadersProvider,
        responseParser: ResponseParser
        ) -> ApiClient {
        return ApiClientImpl(
            requestBuilder: RequestBuilderImpl(
                commonHeadersProvider: commonHeadersProvider
            ),
            requestRetrier: requestRetrier,
            requestDispatcher: AlamofireRequestDispatcher(
                responseParser: responseParser
            ),
            uploader: AlamofireBackgroundUploader(),
            operationBuilder: AlamofireUploadMultipartFormDataOperationBuilder()
        )
    }
}
