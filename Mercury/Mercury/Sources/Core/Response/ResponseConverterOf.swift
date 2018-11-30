import Foundation

public final class ResponseConverterOf<T>: ResponseConverter {
    public typealias ConversionResult = T
    
    private let decodeResponseDataFunction: (_ data: Data) -> ConversionResult?
    
     init<C: ResponseConverter>(_ converter: C) where C.ConversionResult == T {
        decodeResponseDataFunction = { data in
            return converter.decodeResponse(data: data)
        }
    }
    
    public func decodeResponse(data: Data) -> ConversionResult? {
        return decodeResponseDataFunction(data)
    }
}
