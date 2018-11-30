import Foundation
import Alamofire

final class AlamofireRequestDispatcher: RequestDispatcher {
    
    // MARK: - Dependencies:
    private let responseParser: ResponseParser
    
    // MARK: - Init
    init(responseParser: ResponseParser) {
        self.responseParser = responseParser
    }
    
    // MARK: - RequestDispatcher
    @discardableResult
    func send<R: ApiRequest>(
        _ request: R,
        urlRequest: URLRequest,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    {
        weak var alamofireRequest: Alamofire.Request?
        alamofireRequest = Alamofire.request(urlRequest as URLRequest).responseData(
            queue: DispatchQueue.global(qos: .utility),
            completionHandler: { [responseParser] response in
                responseParser.parse(
                    response: response,
                    for: request,
                    completion: completion
                )
            }
        )
        
        return AlamofireNetworkDataTask(request: alamofireRequest)
    }
}
