import Foundation
import Unbox

// MARK: - RequestCachePolicy -

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

// MARK: - UploadMultipartFormDataRequest -

public protocol UploadMultipartFormDataRequest: ApiRequest {
    var url: String { get set }
    
    var headers: [HttpHeader] { get set }
    var params: [String: Any] { get set }
    
    var name: String { get }
    var fileName: String { get }
    var mimeType: String { get }
}

// MARK: - Request -

public protocol ApiRequest {
    associatedtype Method: ApiMethod
    
    var method: Method { get }
    var path: String { get }
    var headers: [HttpHeader] { get }
    var params: [String: Any] { get }
    var httpBody: Data? { get }
    var cachePolicy: RequestCachePolicy { get }
}

// MARK: - Default declarations

public extension ApiRequest {
     var cachePolicy: RequestCachePolicy {
        return .useProtocolCachePolicy
    }
     var headers: [HttpHeader] { return [] }
    
     var httpBody: Data? {
        return nil
    }
}

public extension ApiRequest {
    func normalizedQueryPath() -> String {
        return path.normalizedQueryPath()
    }
}

extension String {
    func normalizedQueryPath() -> String {
        // remove leading and trailing `/` characters
        let components = self.components(separatedBy: "/")
        let nonEmptyComponents = components.filter { !$0.isEmpty }
        
        // return leading `/` character
        return "/" + nonEmptyComponents.joined(separator: "/")
    }
}
