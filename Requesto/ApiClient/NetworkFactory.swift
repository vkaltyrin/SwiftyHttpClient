import Foundation

public protocol NetworkFactory {
    func apiClient() -> ApiClient
    func apiClient(responseParser: ResponseParser) -> ApiClient
}

public final class NetworkFactoryImpl: NetworkFactory {
    
    private let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - NetworkFactory
    
    public func apiClient() -> ApiClient {
        return apiClient(responseParser: responseParser())
    }
    
    public func apiClient(responseParser: ResponseParser) -> ApiClient {
        let sessionInfoHolder = self.sessionInfoHolder()
        
        return ApiClientImpl(
            requestBuilder: requestBuilder(sessionInfoHolder: sessionInfoHolder),
            sessionInfoHolder: sessionInfoHolder,
            responseParser: responseParser
        )
    }
    
    // MARK: - Private
    
    private func requestBuilder(sessionInfoHolder: SessionInfoHolder) -> RequestBuilder {
        return RequestBuilderImpl(
            baseUrl: baseURL,
            sessionInfoHolder: sessionInfoHolder,
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
    
    private func sessionInfoHolder() -> SessionInfoHolder {
        return CurrentSessionInfoHolderImpl(
            sensitiveDataStorage: keychainSensitiveDataStorage()
        )
    }
    
    private func userSessionProvider() -> UserSessionProvider {
        return UserSessionProviderImpl()
    }
    
    private func keychainSensitiveDataStorage() -> SensitiveDataStorage {
        
        let sessionDataProvider = KeychainSensitiveDataProvider(
            service: KeychainConstants.sessionKeychainService,
            accessGroup: nil
        )
        let userInfoDataProvider = KeychainSensitiveDataProvider(
            service: KeychainConstants.userInfoKeychainService
        )
        
        let sensitiveDataStorage = SensitiveDataStorageImpl(
            sessionDataProvider: sessionDataProvider,
            userInfoDataProvider: userInfoDataProvider
        )
        
        return sensitiveDataStorage
    }
    
}
