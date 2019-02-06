import Foundation
import HTTPClient

struct GithubUserRepositoriesRequest {
    enum Visibility: String {
        case all
        case `public`
        case `private`
    }
    
    // MARK: - Parameters
    private let username: String
    private let password: String
    private let visibility: Visibility
    
    // MARK: - Init
    init(username: String, password: String, visibility: Visibility) {
        self.username = username
        self.password = password
        self.visibility = visibility
    }
}

extension GithubUserRepositoriesRequest: GithubRequest {
    typealias Result = [GithubRepository]
    
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
        return .get
    }
    
    var path: String {
        return "/user/repos"
    }
    
    var params: [String : Any] {
        return ["visibility" : visibility.rawValue]
    }
}

struct GithubRepository: Codable {
    let name: String
    let fork: Bool
}
