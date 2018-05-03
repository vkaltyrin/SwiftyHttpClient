import Foundation

public protocol SensitiveDataStorage: class {
    var session: String? { get set }
    var userName: String? { get set }
}

final class SensitiveDataStorageImpl: SensitiveDataStorage {
    
    private struct Keys {
        static let session = "session"
        static let userName = "userName"
    }
    
    // MARK: - Private properties
    private let sessionDataProvider: SensitiveDataProvider
    private let userInfoDataProvider: SensitiveDataProvider
    
    // MARK: - SensitiveDataStorage
    public var session: String? {
        get { return sessionDataProvider.value(forKey: Keys.session) }
        set { sessionDataProvider.setValue(newValue, forKey: Keys.session) }
    }
    
    public var userName: String? {
        get { return userInfoDataProvider.value(forKey: Keys.userName) }
        set { userInfoDataProvider.setValue(newValue, forKey: Keys.userName) }
    }
    
    // MARK: - Init
    public init(
        sessionDataProvider: SensitiveDataProvider,
        userInfoDataProvider: SensitiveDataProvider)
    {
        self.sessionDataProvider = sessionDataProvider
        self.userInfoDataProvider = userInfoDataProvider
    }
}
