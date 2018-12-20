import Foundation
import HTTPClient

struct GithubSearchRepositoriesRequest {
    enum SortKey: String {
        case stars
        case forks
        case updated
    }
    
    enum OrderKey: String {
        case asc
        case desc
    }
    
    // MARK: - Parameters
    private let query: String
    private let sort: SortKey
    private let order: OrderKey
    
    // MARK: - Init
    init(query: String, sort: SortKey, order: OrderKey) {
        self.query = query
        self.sort = sort
        self.order = order
    }
}

extension GithubSearchRepositoriesRequest: GithubRequest {
    typealias Result = GithubSearchRepositoriesResponse
    
    var method: HttpMethod {
        return .get
    }
    
    var path: String {
        return "/search/repositories"
    }
    
    var params: [String : Any] {
        return [
            "q" : query,
            "sort" : sort,
            "order" : order
        ]
    }
}

struct GithubSearchRepositoriesResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
    }
    
    let totalCount: Int
    let incompleteResults: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.totalCount = try container.decode(Int.self, forKey: .totalCount)
        self.incompleteResults = try container.decode(Bool.self, forKey: .incompleteResults)
    }
}
