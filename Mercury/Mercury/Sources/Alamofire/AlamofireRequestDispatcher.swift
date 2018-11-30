import Foundation
import Alamofire

final class AlamofireRequestDispatcher: RequestDispatcher {
    
    // MARK: - Dependencies:
    private let responseParser: ResponseParser
    private let loggerService: LoggerService
    
    init(responseParser: ResponseParser, loggerService: LoggerService) {
        self.responseParser = responseParser
        self.loggerService = loggerService
    }
    
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
            completionHandler: { [responseParser, weak self] response in
                
                self?.loggerService.logRequest(
                    cUrl: alamofireRequest?.debugDescription ?? "",
                    response: response.debugDescription
                )
                
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
