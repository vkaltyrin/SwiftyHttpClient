import Unbox

final class ApiErrorConverter: ResponseConverter {
    typealias ConversionResult = ApiError
    
    func decodeResponse(data: Data) -> ConversionResult? {
        guard let json = data.toJSON else {
            return nil
        }
        
        if let errors = json["errors"] as? [Any] {
            if errors.count > 0 {
                return try? unbox(dictionary: json)
            }
        }
        
        return nil
    }
}
