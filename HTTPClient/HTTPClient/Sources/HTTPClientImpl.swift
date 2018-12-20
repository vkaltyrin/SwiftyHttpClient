import Foundation

public final class HTTPClientImpl: HTTPClient {

    // MARK: - Dependencies
    private let requestBuilder: RequestBuilder
    private let requestRetrier: RequestRetrier
    private let requestDispatcher: RequestDispatcher
    private let uploader: Uploader
    private let operationBuilder: UploadMultipartFormDataRequestOperationBuilder
    
    // MARK: - Init
    init(requestBuilder: RequestBuilder,
         requestRetrier: RequestRetrier,
         requestDispatcher: RequestDispatcher,
         uploader: Uploader,
         operationBuilder: UploadMultipartFormDataRequestOperationBuilder)
    {
        self.requestBuilder = requestBuilder
        self.requestRetrier = requestRetrier
        self.requestDispatcher = requestDispatcher
        self.uploader = uploader
        self.operationBuilder = operationBuilder
    }
    
    // MARK: - HTTPClient
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
        -> NetworkDataTask?
    {
        let preparedRequestResult = requestBuilder.buildUploadRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
            return nil
        case .data(let preparedRequest):
            let uploadOperation = operationBuilder.buildOperation(
                request: preparedRequest,
                dataProvider: dataProvider,
                uploader: uploader,
                onProgressChange: onProgressChange,
                completion: completion
            )

            uploadQueue.addOperation(uploadOperation)

            return OperationDataTask(operation: uploadOperation)
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
