import Foundation

public protocol NetworkFactory {
    func apiClient() -> ApiClient
    
    func apiClient(
        sessionStorage: SessionStorage,
        responseParser: ResponseParser,
        loggerService: LoggerService?
        ) -> ApiClient
    
    func apiClient(
        sessionStorage: SessionStorage,
        responseParser: ResponseParser,
        loggerService: LoggerService?,
        uploader: Uploader
        ) -> ApiClient
}

public final class NetworkFactoryImpl: NetworkFactory {
    
    private let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - NetworkFactory
    
    public func apiClient() -> ApiClient {
        return apiClient(
            sessionStorage: sessionStorage(),
            responseParser: responseParser(),
            loggerService: nil,
            uploader: uploader()
        )
    }
    
    public func apiClient(
        sessionStorage: SessionStorage,
        responseParser: ResponseParser,
        loggerService: LoggerService?
        ) -> ApiClient {
        return ApiClientImpl(
            requestBuilder: requestBuilder(sessionStorage: sessionStorage),
            sessionStorage: sessionStorage,
            responseParser: responseParser,
            loggerService: loggerService,
            uploader: uploader()
        )
    }
    
    public func apiClient(
        sessionStorage: SessionStorage,
        responseParser: ResponseParser,
        loggerService: LoggerService?,
        uploader: Uploader
        ) -> ApiClient {
        return ApiClientImpl(
            requestBuilder: requestBuilder(sessionStorage: sessionStorage),
            sessionStorage: sessionStorage,
            responseParser: responseParser,
            loggerService: loggerService,
            uploader: uploader
        )
    }
    
    // MARK: - Private
    
    private func sessionStorage() -> SessionStorage {
        return SessionStorageImpl()
    }
    
    private func requestBuilder(sessionStorage: SessionStorage) -> RequestBuilder {
        return RequestBuilderImpl(
            baseUrl: baseURL,
            sessionStorage: sessionStorage,
            commonRequestHeadersProvider: commonRequestHeadersProvider()
        )
    }
    
    private func commonRequestHeadersProvider() -> CommonRequestHeadersProvider {
        return CommonRequestHeadersProviderImpl(
            xSessionHeaderProvider: xSessionHeaderProvider(),
            xDateHeaderProvider: xDateHeaderProvider()
        )
    }
    
    private func xSessionHeaderProvider() -> XSessionHeaderProvider {
        return XSessionHeaderProviderImpl()
    }
    
    private func xDateHeaderProvider() -> XDateHeaderProvider {
        return XDateHeaderProviderImpl(
            currentDateProvider: CurrentDateProviderImpl()
        )
    }
    
    private func responseParser() -> ResponseParser {
        return JsonResponseParserImpl()
    }
    
    private func userSessionProvider() -> UserSessionProvider {
        return UserSessionProviderImpl()
    }
    
    private func uploader() -> Uploader {
        return BackgroundUploader()
    }
}
