import Foundation
import HTTPClient

public final class HTTPClientFactory {
    
    public class func HTTPClient(
        commonHeadersProvider: CommonHeadersProvider,
        responseDecoder: ResponseDecoder
        ) -> HTTPClient {
        return HTTPClient(
            requestRetrier: RequestRetrierImpl(),
            commonHeadersProvider: commonHeadersProvider,
            responseDecoder: responseDecoder
        )
    }
    
    public class func HTTPClient(
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
            operationBuilder: AlamofireUploadMultipartFormDataOperationBuilder(
                uploader: AlamofireBackgroundUploader()
            ),
            logger: DefaultLogger()
        )
    }
}
