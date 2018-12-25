import Foundation
import Alamofire
import HTTPClient

extension Alamofire.Result {
    func toGenericResult() -> GenericResult<Value> {
        switch self {
        case .success(let value):
            return GenericResult<Value>.data(value)
        case .failure(let error):
            return GenericResult<Value>.error(error)
        }
    }
}

extension Alamofire.DataResponse {
    func toResponseResult() -> ResponseResult<Value> {
        return ResponseResult<Value>(
            request: request,
            response: response,
            data: data,
            result: result.toGenericResult()
        )
    }
}
