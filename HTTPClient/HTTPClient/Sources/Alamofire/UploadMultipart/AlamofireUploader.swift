import Foundation
import Alamofire

public protocol AlamofireUploader: class {
    func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders?,
        encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?
    )
}
