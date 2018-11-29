import Foundation

public extension URL {
    // MARK: - Mutating
    static func httpURL(string: String) -> URL? {
        guard let url = URL(string: string) else {
            return nil
        }
        let httpPrefix = "http"
        let range = url.scheme?.range(of: httpPrefix)
        let hasNotHttpPrefix = range == nil
        
        if hasNotHttpPrefix {
            return URL(string: httpPrefix + "://" + string)
        }
        return url
    }
    
    var httpURL: URL? {
        let httpPrefix = "http"
        let range = scheme?.range(of: httpPrefix)
        let hasNotHttpPrefix = range == nil
        if hasNotHttpPrefix {
            return URL(string: httpPrefix + "://" + absoluteString)
        }
        return self
    }
    
    // MARK: - Components
    var uriVersionValue: Int? {
        return host?.toInt()
    }
    
    func firstComponentValue() -> String? {
        return componentValueAtIndex(index: 0)
    }
    
    func componentValueAtIndex(index: Int) -> String? {
        if let valueComponents = pathComponentsWithoutSlashes() {
            if valueComponents.count > index {
                if let secondValue = valueComponents[index] as? String {
                    return secondValue
                }
            }
        }
        return nil
    }
    
    func pathComponentsWithoutSlashes() -> [AnyObject]? {
        let valueComponents = pathComponents.filter { $0 != "/" }
        return valueComponents as [AnyObject]?
    }
    
    func urlByReplacingLastComponentWith(_ component: String) -> URL? {
        return deletingLastPathComponent().appendingPathComponent(component, isDirectory: false)
    }
    
    func urlByReplacingLastComponentWithNumberSign() -> URL? {
        return urlByReplacingLastComponentWith("#")
    }
    
    // MARK: - Schemes
    
    func isAppStoreURL() -> Bool {
        if let scheme = scheme {
            if scheme.hasPrefix("itms") || scheme.hasPrefix("itunes.apple.com") {
                return true
            }
        }
        return false
    }
    
}

