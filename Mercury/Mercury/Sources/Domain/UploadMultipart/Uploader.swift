import Foundation
import Alamofire

public protocol Uploader: class {
    func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?
    )
}

extension SessionManager {
    static let background: SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "ru.eva.domclick.upload")
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
}

final class BackgroundUploader: Uploader {
    
    func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?)
    {
        return SessionManager.background.upload(
            multipartFormData: multipartFormData,
            usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
            to: url,
            method: method,
            headers: headers,
            encodingCompletion: encodingCompletion
        )
    }
}
