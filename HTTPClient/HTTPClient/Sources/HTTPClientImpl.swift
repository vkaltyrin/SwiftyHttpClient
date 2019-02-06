import Foundation

public final class HTTPClientImpl: HTTPClient {

    // MARK: - Dependencies
    private let requestBuilder: RequestBuilder
    private let requestRetrier: RequestRetrier
    private let requestDispatcher: RequestDispatcher
    private let operationBuilder: UploadMultipartFormDataRequestOperationBuilder
    private let logger: Logger
    private let requestQueue: DispatchQueue
    private let responseQueue: DispatchQueue
    
    // MARK: - Init
    public init(requestBuilder: RequestBuilder,
                requestRetrier: RequestRetrier,
                requestDispatcher: RequestDispatcher,
                operationBuilder: UploadMultipartFormDataRequestOperationBuilder,
                logger: Logger,
                requestQueue: DispatchQueue,
                responseQueue: DispatchQueue)
    {
        self.requestBuilder = requestBuilder
        self.requestRetrier = requestRetrier
        self.requestDispatcher = requestDispatcher
        self.operationBuilder = operationBuilder
        self.logger = logger
        self.requestQueue = requestQueue
        self.responseQueue = responseQueue
    }
    
    public convenience init(requestBuilder: RequestBuilder,
                            requestRetrier: RequestRetrier,
                            requestDispatcher: RequestDispatcher,
                            operationBuilder: UploadMultipartFormDataRequestOperationBuilder,
                            logger: Logger) {
        self.init(
            requestBuilder: requestBuilder,
            requestRetrier: requestRetrier,
            requestDispatcher: requestDispatcher,
            operationBuilder: operationBuilder,
            logger: logger,
            requestQueue: DispatchQueue.global(qos: .utility),
            responseQueue: DispatchQueue.main
        )
    }
    
    public convenience init(
        commonHeadersProvider: CommonHeadersProvider,
        requestDispatcher: RequestDispatcher,
        logger: Logger) {
        self.init(
            requestBuilder: RequestBuilderImpl(commonHeadersProvider: commonHeadersProvider),
            requestRetrier: RequestRetrierImpl(),
            requestDispatcher: requestDispatcher,
            operationBuilder: URLSessionUploadMultipartFormDataRequestOperationBuilder(),
            logger: logger,
            requestQueue: DispatchQueue.global(qos: .utility),
            responseQueue: DispatchQueue.main
        )
    }
    
    public convenience init(
        commonHeadersProvider: CommonHeadersProvider,
        beforeDecodingStrategy: BeforeDecodingStrategy,
        logger: Logger) {
        self.init(
            commonHeadersProvider: commonHeadersProvider,
            requestDispatcher: URLSessionRequestDispatcher(
                session: URLSession.shared,
                responseDecoder: ResponseDecoderImpl(beforeDecodingStrategy: beforeDecodingStrategy)
            ),
            logger: logger
        )
    }
    
    public convenience init(
        beforeDecodingStrategy: BeforeDecodingStrategy) {
        self.init(
            commonHeadersProvider: CommonHeadersProviderImpl(),
            beforeDecodingStrategy: beforeDecodingStrategy,
            logger: DefaultLogger()
        )
    }
    
    public convenience init() {
        self.init(
            commonHeadersProvider: CommonHeadersProviderImpl(),
            requestDispatcher: URLSessionRequestDispatcher(
                session: URLSession.shared,
                responseDecoder: ResponseDecoderImpl()
            ),
            logger: DefaultLogger()
        )
    }
    
    // MARK: - HTTPClient
    @discardableResult
    public func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask? {
        requestQueue.async {
            self.send(request: request, completion: completion)
        }
        
        return networkDataTask
    }
    
    @discardableResult
    public func send<R: UploadMultipartFormDataRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask? {
        return self.upload(request: request, completion: completion)
    }
    
    // MARK: - Private
    private let uploadQueue: OperationQueue = {
        let requestQueue = OperationQueue()
        requestQueue.qualityOfService = .utility
        return requestQueue
    }()
    
    func upload<R: UploadMultipartFormDataRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion)
        -> NetworkDataTask? {
        requestQueue.async {
            let preparedRequestResult = self.requestBuilder.buildUploadRequest(from: request)
            
            switch preparedRequestResult {
            case .error(let error):
                completion(.error(error))
            case .data(let preparedRequest):
                let uploadOperation = self.operationBuilder.buildOperation(
                    request: preparedRequest,
                    dataProvider: request.dataProvider,
                    onProgressChange: request.onProgressChange,
                    completion: completion
                )
                
                self.uploadQueue.addOperation(uploadOperation)
                self.networkDataTask = OperationDataTask(operation: uploadOperation)
            }
        }
        
        return networkDataTask
    }
    
    private var networkDataTask: NetworkDataTask?
    
    private func send<R: ApiRequest>(
        request: R,
        completion: @escaping DataResult<R.Result, RequestError<R.ErrorResponse>>.Completion) {
        let preparedRequestResult = requestBuilder.buildUrlRequest(from: request)
        
        switch preparedRequestResult {
        case .error(let error):
            completion(.error(error))
        case .data(let urlRequest):
            
            if let networkDataTask = networkDataTask, networkDataTask.isCancelled == true {
                return
            }
            
            logger.log(cUrl: urlRequest.cURL)
            
            networkDataTask = requestDispatcher.send(request, urlRequest: urlRequest) { result in
                result.onData { [weak self] data in
                    self?.responseQueue.async {
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
                        self?.responseQueue.async {
                            completion(.error(networkRequestError))
                        }
                    }
                }
            }
        }
    }
}
