import Foundation
import Alamofire

public protocol RequestSender: class {
    
}

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
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    
    @discardableResult
    func upload<R: UploadMultipartFormDataRequest>(
        dataProvider: DataProvider,
        request: R,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> Operation?
}

// MARK: - ApiClientImpl

public final class ApiClientImpl: ApiClient {
    
    // MARK: - Properties
    private let requestBuilder: RequestBuilder
    private let responseParser: ResponseParser
    
    // MARK: - Dependencies
    private var loggerService: LoggerService?
    private let uploader: Uploader
    private let requestRetrier: RequestRetrier
    
    // MARK: - Init
    init(requestBuilder: RequestBuilder,
         responseParser: ResponseParser,
         loggerService: LoggerService?,
         uploader: Uploader,
         requestRetrier: RequestRetrier
         )
    {
        self.requestBuilder = requestBuilder
        self.responseParser = responseParser
        self.loggerService = loggerService
        self.uploader = uploader
        self.requestRetrier = requestRetrier
    }
    
    // MARK: - ApiClient
    
    @discardableResult
    public func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
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
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> Operation?
    {
        let preparedRequestResult = requestBuilder.buildUploadRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            return nil

        case .data(let preparedRequest):
            let uploadOperation = UploadMultipartFormDataRequestOperation(
                request: preparedRequest,
                dataProvider: dataProvider,
                uploader: uploader,
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
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion) {
        let preparedRequestResult = requestBuilder.buildUrlRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            
        case .data(let urlRequest):
            guard !networkDataTask.isCancelled else { return }
            
            networkDataTask.request = send(request, urlRequest: urlRequest) { result in
                result.onData { data in
                    DispatchQueue.dispatchToMain {
                        completion(.data(data))
                    }
                }
                
                result.onError { [weak self] networkRequestError in
                    if self?.requestRetrier.shouldRetry(policy: request.retryPolicy, request: request) == true {
                        networkDataTask.request = self?.send(
                            request,
                            urlRequest: urlRequest,
                            completion: completion
                        )
                    } else {
                        DispatchQueue.dispatchToMain {
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
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> Alamofire.Request?
    {
        weak var alamofireRequest: Alamofire.Request?
        
        alamofireRequest = Alamofire.request(urlRequest as URLRequest).responseData(
            queue: DispatchQueue.global(qos: .utility),
            completionHandler: { [responseParser, weak self] response in
                
                self?.loggerService?.logRequest(
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
        
        return alamofireRequest
    }
}
