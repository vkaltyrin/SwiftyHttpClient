// MARK: - UserSessionDiff

 final class UserSessionDiff: Equatable {
    let previousUserId: String?
    let currentUserId: String?
    
     var userHasChanged: Bool {
        if let previousUserId = previousUserId, let currentUserId = currentUserId, previousUserId != currentUserId {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Init
    
    init(previousUserId: String?, currentUserId: String?) {
        self.previousUserId = previousUserId
        self.currentUserId = currentUserId
    }
    
    // MARK: - Equatable
    
     static func ==(left: UserSessionDiff, right: UserSessionDiff) -> Bool {
        return left.previousUserId == right.previousUserId &&
            left.currentUserId == right.currentUserId
    }
}
