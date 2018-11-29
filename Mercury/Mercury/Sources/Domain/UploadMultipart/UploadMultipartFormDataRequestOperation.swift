import Foundation
import Alamofire

final class UploadMultipartFormDataRequestOperation<R: UploadMultipartFormDataRequest>: Operation {
    
    // MARK: - State
    private let queue = DispatchQueue(label: "com.apiClient.UploadMultipartFormDataRequestOperation.queue")
    private var uploadRequest: Alamofire.Request?
    
    // MARK: - Dependencies
    private let request: R
    private let dataProvider: DataProvider
    private let uploader: Uploader
    private let onProgressChange: ((Progress) -> ())?
    private let completion: DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion
    
    // MARK: - Init
    
    init(
        request: R,
        dataProvider: DataProvider,
        uploader: Uploader,
        onProgressChange: ((Progress) -> ())?,
        completion: @escaping DataResult<R.Method.Result, RequestError<R.Method.ErrorResponse>>.Completion
        )
    {
        self.request = request
        self.uploader = uploader
        self.dataProvider = dataProvider
        self.onProgressChange = onProgressChange
        self.completion = completion
        
        super.init()
    }
    
    // MARK: - Operation
    private var _executing = false
    private var _finished = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func cancel() {
        queue.async {
            guard !self.isCancelled
                else { return }
            
            super.cancel()
            
            if self.isExecuting {
                self.uploadRequest?.cancel()
                self.finish()
            }
        }
    }
    
    override func start() {
        queue.async {
            self.performUpload()
        }
    }
    
    // MARK: - Private
    
    private func validateOperationState() -> Bool {
        if isCancelled == true {
            isFinished = true
            return true
        }
        return false
    }
    
    private func finish() {
        isExecuting = false
        isFinished = true
    }
    
    private func finishWithError(_ error: RequestError<R.Method.ErrorResponse>) {
        queue.async {
            DispatchQueue.main.async {
                self.completion(.error(error))
            }
            self.finish()
        }
    }
    
    private func finishWithResult(_ result: R.Method.Result) {
        queue.async {
            DispatchQueue.main.async {
                self.completion(.data(result))
            }
            self.finish()
        }
    }
    
    private func performUpload() {
        
        if validateOperationState() {
            return
        }
        
        isExecuting = true
        
        dataProvider.data { [weak self] data in
            
            if self?.validateOperationState() == true {
                return
            }
            
            guard let data = data else {
                self?.finishWithError(.cantUploadMultipart(.invalidData))
                return
            }
            
            self?.upload(data)
        }
    }
    
    private func upload(_ data: Data) {
        
        let multipartFormData: (MultipartFormData) -> Void = { multipartFormData in
            self.request.params.forEach { key, value in
                if
                    let valueString = value as? String,
                    let valueData = valueString.data(using: .utf8)
                {
                    multipartFormData.append(valueData, withName: key)
                }
            }
            
            multipartFormData.append(
                data,
                withName: self.request.name,
                fileName: self.request.fileName,
                mimeType: self.request.mimeType
            )
        }
        
        var headers: Alamofire.HTTPHeaders = [:]
        request.headers.forEach {
            headers[$0.name] = $0.value
        }
        
        print(request.url)
        
        uploader.upload(
            multipartFormData: multipartFormData,
            to: request.url,
            method: request.method.httpMethod.toAlamofireMethod,
            headers: headers,
            encodingCompletion: { [weak self] encodingResult in
                switch encodingResult {
                case .success(let uploadRequest, _, _):
                    self?.uploadRequest = uploadRequest
                    
                    uploadRequest
                        .uploadProgress(queue: DispatchQueue.main) { progress in
                            if self?.validateOperationState() == true {
                                return
                            }
                            self?.onProgressChange?(progress)
                        }
                        .validate()
                        .responseData(queue: DispatchQueue.global(qos: .utility)) { dataResponse in
                            if self?.validateOperationState() == true {
                                return
                            }
                            
                            let method = self?.request.method
                            switch dataResponse.result {
                            case .success(let value):
                                if let error = method?.errorConverter.decodeResponse(data: value) {
                                    self?.finishWithError(.apiError(error))
                                    return
                                } else if let result = method?.resultConverter.decodeResponse(data: value) {
                                    self?.finishWithResult(result)
                                    return
                                } else {
                                    self?.finishWithError(.cantUploadMultipart(.cantDecodeSuccessResponse))
                                }
                            case .failure(let error):
                                if
                                    let data = dataResponse.data,
                                    let decodedError = method?.errorConverter.decodeResponse(data: data)
                                {
                                    self?.finishWithError(.apiError(decodedError))
                                    return
                                } else if let nsError = error as NSError?,
                                    nsError.domain == NSURLErrorDomain,
                                    nsError.code == NSURLErrorNotConnectedToInternet
                                {
                                    self?.finishWithError(.networkError(error))
                                    return
                                } else {
                                    self?.finishWithError(.cantUploadMultipart(.cantDecodeFailureResponse))
                                    return
                                }
                            }
                        }
                    break
                case .failure(let error):
                    self?.finishWithError(.networkError(error))
                }
            }
        )
    }

}
