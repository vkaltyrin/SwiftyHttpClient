import Foundation

extension HTTPCookie {
    
    static let defaultExpiresTime: TimeInterval = 60 * 60 * 24
    
    static func appCookie(
        cookieType: CookieType,
        value: String,
        expires: TimeInterval = defaultExpiresTime) -> HTTPCookie?
    {
        return appCookie(key: cookieType.name, value: value, expires: expires)
    }
    
    static func appCookie(
        key: String,
        value: String,
        expires: TimeInterval = defaultExpiresTime) -> HTTPCookie?
    {
        
        let expireDate = NSDate(timeIntervalSinceNow: expires)
        let properties: [HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.domain: "domain", //inject
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "true", //inject
            HTTPCookiePropertyKey.expires: expireDate
        ]
        return HTTPCookie(properties: properties)
    }
}
