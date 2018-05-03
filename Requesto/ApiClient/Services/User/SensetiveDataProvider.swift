public protocol SensitiveDataProvider {
    func value<T>(forKey key: String) -> T?
    func setValue<T>(_ value: T?, forKey key: String)
}
