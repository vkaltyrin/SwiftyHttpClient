import Foundation

public enum RequestCachePolicy {
    case useProtocolCachePolicy
    case reloadIgnoringLocalCacheData
    case returnCacheDataElseLoad
    case returnCacheDataDontLoad
    
    var toNSURLRequestCachePolicy: NSURLRequest.CachePolicy {
        switch self {
        case .useProtocolCachePolicy:
            return .useProtocolCachePolicy
        case .reloadIgnoringLocalCacheData:
            return .reloadIgnoringLocalCacheData
        case .returnCacheDataElseLoad:
            return .returnCacheDataElseLoad
        case .returnCacheDataDontLoad:
            return .returnCacheDataDontLoad
        }
    }
}
