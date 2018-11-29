import Foundation
import KeychainAccess

final class KeychainSensitiveDataProvider: SensitiveDataProvider {
    
    // MARK: - Private
    private let keychain: Keychain
    
    // MARK: - Init
    public init(service: String, accessGroup: String? = nil) {
        keychain = Keychain(service: service, accessGroup: accessGroup ?? "")
    }
    
    public func value<T>(forKey key: String) -> T? {
        return keychain[key] as? T
    }
    
    public func setValue<T>(_ value: T?, forKey key: String) {
        
        try? keychain.remove(key)
        
        guard let value = value as? String else { return }
        keychain[key] = value
    }
}
