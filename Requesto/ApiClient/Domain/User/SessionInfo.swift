// MARK: - SessionInfoHolder

protocol SessionInfoHolder: class {
    var session: String? { get }
    var refreshToken: String? { get }
    var userSessionDiff: UserSessionDiff? { get }
}

// MARK: - SessionInfo -

struct SessionInfo: Equatable {
    
    // MARK: SessionInfoHolder
    let session: String?
    let refreshToken: String?
    let userName: String?
    
    // MARK: Equatable
    static func ==(left: SessionInfo, right: SessionInfo) -> Bool {
        return left.session == right.session &&
            left.refreshToken == right.refreshToken
    }
}
