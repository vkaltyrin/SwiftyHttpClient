import Foundation

public protocol UploadMultipartFormDataRequest: ApiRequest {
    var url: String { get set }
    
    var headers: [HttpHeader] { get set }
    var params: [String: Any] { get set }
    
    var name: String { get }
    var fileName: String { get }
    var mimeType: String { get }
    
    var dataProvider: DataProvider { get }
    var onProgressChange: ((Progress) -> ())? { get }
}
