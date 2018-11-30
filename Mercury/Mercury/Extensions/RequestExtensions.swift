import Foundation

public extension ApiRequest {
    func normalizedQueryPath() -> String {
        return path.normalizedQueryPath()
    }
    
    func fullQueryPath() -> String {
        return "\(endpoint)\(normalizedQueryPath())"
    }
    
    func cUrl() -> String {
        return ""
    }
    
    var errorConverter: ResponseConverterOf<ApiError> {
        return ResponseConverterOf(ApiErrorConverter())
    }
}
