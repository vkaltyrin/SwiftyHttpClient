import Foundation

// MARK: - ApiClientImpl

public final class ApiClientImpl: ApiClient {

    // MARK: - Dependencies
    private let requestBuilder: RequestBuilder
    private let uploader: Uploader
    private let requestRetrier: RequestRetrier
    private let requestDispatcher: RequestDispatcher
    
    // MARK: - Init
    init(requestBuilder: RequestBuilder,
         uploader: Uploader,
         requestRetrier: RequestRetrier,
         requestDispatcher: RequestDispatcher)
    {
        self.requestBuilder = requestBuilder
        self.uploader = uploader
        self.requestRetrier = requestRetrier
        self.requestDispatcher = requestDispatcher
    }
    
    // MARK: - ApiClient
    
    @discardableResult
    public func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask?
    {
        DispatchQueue.global(qos: .utility).async {
            self.send(request: request, completion: completion)
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
    
    private var networkDataTask: NetworkDataTask?
    
    private func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion) {
        let preparedRequestResult = requestBuilder.buildUrlRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            
        case .data(let urlRequest):
            guard networkDataTask?.isCancelled == false else { return }
            
            networkDataTask = requestDispatcher.send(request, urlRequest: urlRequest) { result in
                result.onData { data in
                    DispatchQueue.main.async {
                        completion(.data(data))
                    }
                }
                
                result.onError { [weak self] networkRequestError in
                    if self?.requestRetrier.shouldRetry(policy: request.retryPolicy, request: request) == true {
                        self?.networkDataTask = self?.requestDispatcher.send(
                            request,
                            urlRequest: urlRequest,
                            completion: completion
                        )
                    } else {
                        DispatchQueue.main.async {
                            completion(.error(networkRequestError))
                        }
                    }
                }
            }
        }
    }
}