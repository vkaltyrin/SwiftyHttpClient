import Foundation

public extension ApiRequest {
    func normalizedQueryPath() -> String {
        return path.normalizedQueryPath()
    }
    
    func fullQueryPath() -> String {
        return "\(basePath)\(normalizedQueryPath())"
    }
}
