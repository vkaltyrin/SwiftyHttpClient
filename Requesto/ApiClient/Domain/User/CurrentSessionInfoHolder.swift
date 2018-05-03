import KeychainAccess

// MARK: - CurrentSessionInfoHolderImpl -

final class CurrentSessionInfoHolderImpl:
    SessionInfoHolder
{
    private let sensitiveDataStorage: SensitiveDataStorage?
    private var previousLoggedInUserId: String?
    private var userId: String?
    private var currentSessionInfo: SessionInfo?
    
    // MARK: - Init
    init(sensitiveDataStorage: SensitiveDataStorage?) {
        
        self.sensitiveDataStorage = sensitiveDataStorage
    }
    
    // MARK: - SessionInfoHolder
    var session: String? {
        return currentSessionInfo?.session
    }
    
    var refreshToken: String? {
        return currentSessionInfo?.refreshToken
    }
    
    var userSessionDiff: UserSessionDiff? {
        return UserSessionDiff(
            previousUserId: previousLoggedInUserId,
            currentUserId: userId
        )
    }
    
}
