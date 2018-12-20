import Foundation
import HTTPClient

struct GithubBasicAuthorizationRequest {
    // MARK: - Parameters
    private let username: String
    private let password: String
    
    // MARK: - Init
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

extension GithubBasicAuthorizationRequest: GithubRequest {
    typealias Result = GithubBasicAuthorizationResponse
    
    /*
     Look at https://developer.github.com/v3/auth/#via-username-and-password
     */
    var headers: [HttpHeader] {
        guard let userData = "\(username):\(password)".data(using: String.Encoding.utf8) else {
            return []
        }
        let basicAuthorizationHeaderValue = "Basic \(userData.base64EncodedString())"
        return [
            HttpHeader(name: "Authorization", value: basicAuthorizationHeaderValue)
        ]
    }
    
    var method: HttpMethod {
        return .post
    }
    
    var path: String {
        return "/user"
    }
    
    var params: [String : Any] {
        return [:]
    }
}

struct GithubBasicAuthorizationResponse: Decodable {
    let login: String
    let id: Int
    let name: String
    let url: String
}
