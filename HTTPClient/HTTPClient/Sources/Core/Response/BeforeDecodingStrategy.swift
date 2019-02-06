import Foundation

/*
 Use BeforeDecodingStrategy to customize decoding behaviour.
 */
public protocol BeforeDecodingStrategy {
    func process<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R
        ) -> DataResult<R.Result, RequestError<R.ErrorResponse>>?
}

public final class DefaultBeforeDecodingStrategy: BeforeDecodingStrategy {
    public func process<R: ApiRequest>(
        response: ResponseResult<Data>,
        for request: R
        ) -> DataResult<R.Result, RequestError<R.ErrorResponse>>? {
        return nil
    }
}
