import Foundation

public final class ResponseConverterOf<T>: ResponseConverter {
    public typealias ConversionResult = T
    
    private let decodeResponseDataFunction: (_ data: Data) -> ConversionResult?
    private let decodeResponseJsonFunction: (_ json: [String: Any]) -> ConversionResult?
    private let decodeResponseJsonArrayFunction: (_ jsonArray: [[String: Any]]) -> ConversionResult?
    private let decodeResponseStatusCodeFunction: (_ statusCode: Int) -> ConversionResult?
    
     init<C: ResponseConverter>(_ converter: C) where C.ConversionResult == T {
        decodeResponseDataFunction = { data in
            return converter.decodeResponse(data: data)
        }
        decodeResponseJsonFunction = { json in
            return converter.decodeResponse(json: json)
        }
        decodeResponseJsonArrayFunction = { jsonArray in
            return converter.decodeResponse(jsonArray: jsonArray)
        }
        decodeResponseStatusCodeFunction = { statusCode in
            return converter.decodeResponse(statusCode: statusCode)
        }
    }
    
    public func decodeResponse(data: Data) -> ConversionResult? {
        return decodeResponseDataFunction(data)
    }
    
    public func decodeResponse(json: [String: Any]) -> ConversionResult? {
        return decodeResponseJsonFunction(json)
    }
    
    public func decodeResponse(jsonArray: [[String: Any]]) -> ConversionResult? {
        return decodeResponseJsonArrayFunction(jsonArray)
    }
    
    public func decodeResponse(statusCode: Int) -> ConversionResult? {
        return decodeResponseStatusCodeFunction(statusCode)
    }
}
