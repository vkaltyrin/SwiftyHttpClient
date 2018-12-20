import Foundation

final class URLSessionRequestDispatcher: RequestDispatcher {
    
    // MARK: - Dependencies
    private let session: URLSession
    private let responseDecoder: ResponseDecoder
    
    // MARK: - Init
    init(session: URLSession, responseDecoder: ResponseDecoder) {
        self.session = session
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
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let httpUrlResponse = response as? HTTPURLResponse else {
                completion(.error(RequestError.apiClientError(.decodingFailure)))
                return
            }
            
            let result: GenericResult<Data>
            if let data = data {
                result = GenericResult<Data>.data(data)
            } else if let error = error {
                result = GenericResult<Data>.error(error)
            } else {
                completion(.error(RequestError.apiClientError(.decodingFailure)))
                return
            }
            
            let responseResult = ResponseResult(
                request: urlRequest,
                response: httpUrlResponse,
                data: data,
                result: result
            )
            self?.responseDecoder.decode(
                response: responseResult,
                for: request,
                completion: completion
            )
        }
       
        return URLSessionNetworkDataTask(task: task)
    }
}
