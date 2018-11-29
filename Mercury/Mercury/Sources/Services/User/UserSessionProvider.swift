import Foundation
import Alamofire

protocol UserSessionProvider {
    func sessionId(response: DataResponse<Data>) -> String?
}

final class UserSessionProviderImpl: UserSessionProvider {
    func sessionId(response: DataResponse<Data>) -> String? {
        if
            let responseHeaders = response.response?.allHeaderFields,
            let cookie = responseHeaders["Set-Cookie"] as? String
        {
            let filteredCookie = cookie.replacingOccurrences(of: "; Path=/", with: "")
            
            guard let sessionId = filteredCookie.components(separatedBy: "=").last else {
                return nil
            }
            
            return sessionId
        }
        
        return nil
    }
}
