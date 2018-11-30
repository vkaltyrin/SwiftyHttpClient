import Unbox

final class ApiErrorConverter: ResponseConverter {
    typealias ConversionResult = ApiError
    
    func decodeResponse(data: Data) -> ConversionResult? {
        guard let json = data.toJSON else {
            return nil
        }
        
        if let errors = json["errors"] as? [Any] {
            if let error = errors.first as? [String: Any] {
                return try? unbox(dictionary: error)
            }
        }
        
        return nil
    }
}
