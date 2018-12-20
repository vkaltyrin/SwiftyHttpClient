import Foundation

/*
 Used to store all data associated with a serialized response of a data or upload request.
 */
public struct ResponseResult<T> {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let result: GenericResult<T>
    
    public init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        result: GenericResult<T>)
    {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}
