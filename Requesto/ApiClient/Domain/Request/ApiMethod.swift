import Unbox

public protocol ApiMethod {
    associatedtype Result
    associatedtype ErrorResponse
    
    // Pass `0` to prevent version from being added to the url. See `RequestBuilder`
    var version: Int { get } 
    
    // Do not override prefix for standard api requests
    var pathPrefix: String { get }
    
    var httpMethod: HttpMethod { get }
    var isAuthorizationRequired: Bool { get }
    
    var errorConverter: ResponseConverterOf<ErrorResponse> { get }
    var resultConverter: ResponseConverterOf<Result> { get }
    
    var pathDefinition: String { get }
}

public extension ApiMethod {
    
     var pathPrefix: String {
        return "api/v1"
    }
    
     var errorConverter: ResponseConverterOf<ApiError> {
        return ResponseConverterOf(ApiErrorConverter())
    }
}
