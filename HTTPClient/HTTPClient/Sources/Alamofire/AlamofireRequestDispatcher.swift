import Foundation
import Alamofire

final class AlamofireRequestDispatcher: RequestDispatcher {
    
    // MARK: - Dependencies:
    private let responseDecoder: ResponseDecoder
    
    // MARK: - Init
    init(responseDecoder: ResponseDecoder) {
        self.responseDecoder = responseDecoder
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
            completionHandler: { [responseDecoder] response in
                responseDecoder.decode(
                    response: response.toResponseResult(),
                    for: request,
                    completion: completion
                )
            }
        )
        
        return AlamofireNetworkDataTask(request: alamofireRequest)
    }
}
