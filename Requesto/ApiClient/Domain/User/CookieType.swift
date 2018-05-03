enum CookieType: String {

    case userAgent = "User-Agent"
    case session = "X-Session"
    case xDate = "X-Date"
    
    var name: String {
        return rawValue
    }
}
