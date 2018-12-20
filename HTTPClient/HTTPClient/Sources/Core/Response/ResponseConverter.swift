import Foundation

public protocol ResponseConverter {
    associatedtype ConversionResult
    
    func decodeResponse(data: Data) -> ConversionResult?
}
