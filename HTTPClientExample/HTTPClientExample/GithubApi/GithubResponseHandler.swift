import Foundation
import HTTPClient

final class GithubResponseStrategy: BeforeDecodingStrategy {
    func process<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R
        ) -> DataResult<R.Result, RequestError<R.ErrorResponse>>?
    {
        if response.response?.statusCode == 401 {
            return .error(.httpUnauthenticated)
        }
        
        if response.response?.statusCode == 403 {
            return .error(.forbidden)
        }
        
        return nil
    }
}
