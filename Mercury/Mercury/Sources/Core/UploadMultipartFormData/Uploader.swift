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
