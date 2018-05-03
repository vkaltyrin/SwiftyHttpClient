import Foundation
import KeychainAccess

public protocol AutoMockable {}

public protocol SessionStorage: AutoMockable {
    var sessionId: String? { get set }
}

public final class SessionStorageImpl: SessionStorage {
    
    private let keychain = Keychain(service: "SessionStorage")
    private let sessionKey = "sessionId"
    
    public init() {}
    
    public var sessionId: String? {
        get {
            return keychain[sessionKey]
        }
        set {
            return keychain[sessionKey] = newValue
        }
    }
}
