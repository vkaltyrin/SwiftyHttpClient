import Foundation

public extension ApiRequest where Result: Decodable {
    var resultConverter: ResponseConverterOf<Result> {
        return ResponseConverterOf(DecodableResponseConverter<Result>())
    }
}

public extension ApiRequest where ErrorResponse: Decodable {
    var errorConverter: ResponseConverterOf<ErrorResponse> {
        return ResponseConverterOf(DecodableResponseConverter<ErrorResponse>())
    }
}

final class DecodableResponseConverter<T: Decodable>: ResponseConverter {
    typealias ConversionResult = T
    
    func decodeResponse(data: Data) -> T? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Unable to decode response due to error (\(error))")
            return nil
        }
    }
}
