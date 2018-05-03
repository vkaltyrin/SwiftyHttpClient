import Foundation
import Alamofire

// MARK: - DataProvider

public protocol DataProvider: class {
    func data(completion: @escaping (Data?) -> ())
}

// MARK: - DataTask
public protocol NetworkDataTask: class {
    func cancel()
}

public final class NetworkDataTaskImpl: NetworkDataTask {
    var request: Alamofire.Request?
    
    var isCancelled = false
    
    public func cancel() {
        guard !isCancelled else {
            return
        }
        
        request?.cancel()
        
        isCancelled = true
    }
}

// MARK: - ApiClient

public protocol ApiClient: class {
    @discardableResult
    func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    
    @discardableResult
    func upload<R: UploadMultipartFormDataRequest>(
        dataProvider: DataProvider,
        request: R,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion)
        -> Operation?
}

// MARK: - ApiClientImpl

public final class ApiClientImpl: ApiClient {
    
    // MARK: - Properties
    private let requestBuilder: RequestBuilder
    private let responseParser: ResponseParser
    
    // MARK: - Dependencies
    private let sessionInfoHolder: SessionInfoHolder
    
    // MARK: - Init
    init(requestBuilder: RequestBuilder,
         sessionInfoHolder: SessionInfoHolder,
         responseParser: ResponseParser)
    {
        self.requestBuilder = requestBuilder
        self.sessionInfoHolder = sessionInfoHolder
        self.responseParser = responseParser
    }
    
    // MARK: - ApiClient
    
    @discardableResult
    public func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    {
        let networkDataTask = NetworkDataTaskImpl()
        
        DispatchQueue.global(qos: .utility).async {
            self.send(networkDataTask: networkDataTask, request: request, completion: completion)
        }
        
        return networkDataTask
    }
    
    public func upload<R: UploadMultipartFormDataRequest>(
        dataProvider: DataProvider,
        request: R,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion)
        -> Operation?
    {
        let preparedRequestResult = requestBuilder.uploadRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            return nil

        case .data(let preparedRequest):
            let uploadOperation = UploadMultipartFormDataRequestOperation(
                request: preparedRequest,
                dataProvider: dataProvider,
                onProgressChange: onProgressChange,
                completion: completion
            )

            uploadQueue.addOperation(uploadOperation)

            return uploadOperation
        }
    }
    
    // MARK: - Private
    
    private let uploadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
    private func send<R: ApiRequest>(
        networkDataTask: NetworkDataTaskImpl,
        request: R,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion) {
        let preparedRequestResult = requestBuilder.apiRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            
        case .data(let urlRequest):
            let requestSession = sessionInfoHolder.session
            
            guard !networkDataTask.isCancelled else { return }
            
            networkDataTask.request = send(request, urlRequest: urlRequest) { result in
                result.onData { data in
                    DispatchQueue.dispatchToMain {
                        completion(.data(data))
                    }
                }
                
                result.onError { [weak self] networkRequestError in
                    DispatchQueue.dispatchToMain { [weak self] in
                        if networkRequestError.isUnauthenticated {
                            // Check if the session was refreshed before response was received
                            if let currentSession = self?.sessionInfoHolder.session, requestSession != currentSession {
                                
                                // Try to resend request with updated session
                                if !networkDataTask.isCancelled {
                                    networkDataTask.request = self?.send(
                                        request,
                                        urlRequest: urlRequest,
                                        completion: completion
                                    )
                                }
                            } else {
                                completion(.error(networkRequestError))
                            }
                        } else {
                            completion(.error(networkRequestError))
                        }
                    }
                }
            }
        }
    }
    
    @discardableResult
    private func send<R: ApiRequest>(
        _ request: R,
        urlRequest: URLRequest,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion)
        -> Alamofire.Request?
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
        
        return alamofireRequest
    }
}
