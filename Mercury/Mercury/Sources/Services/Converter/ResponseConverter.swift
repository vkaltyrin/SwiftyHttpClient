import Unbox

public protocol ResponseConverter {
    associatedtype ConversionResult
    
    func decodeResponse(data: Data) -> ConversionResult?
    func decodeResponse(json: [String: Any]) -> ConversionResult?
    func decodeResponse(jsonArray: [[String: Any]]) -> ConversionResult?
    func decodeResponse(statusCode: Int) -> ConversionResult?
}

extension ResponseConverter {
    func decodeResponse(data: Data) -> ConversionResult? {
        let string = String(data: data, encoding: .utf8)
        
        if let json = data.toJSON {
            return decodeResponse(json: json)
        } else if let jsonArray = data.toJsonArray {
            return decodeResponse(jsonArray: jsonArray)
        } else {
            return nil
        }
    }
    
    func decodeResponse(json: [String: Any]) -> ConversionResult? {
        return nil
    }
    
    func decodeResponse(jsonArray: [[String: Any]]) -> ConversionResult? {
        return nil
    }
    
    func decodeResponse(statusCode: Int) -> ConversionResult? {
        return nil
    }
}

final class UnboxingResponseConverter<T>: ResponseConverter
    where T: Unboxable
{
    typealias ConversionResult = T
    
    func decodeResponse(json: [String: Any]) -> ConversionResult? {
        do {
            let response: ConversionResult = try unbox(dictionary: json)
            return response
        } catch {
            print("Unable to Unbox Response Due to Error (\(error))")
            return nil
        }
    }
}

final class CollectionUnboxingResponseConverter<T>: ResponseConverter
    where T: Collection, T.Iterator.Element: Unboxable
{
    typealias ConversionResult = T
    
    func decodeResponse(jsonArray: [[String: Any]]) -> ConversionResult? {
        let responseElements: [ConversionResult.Iterator.Element] = jsonArray.flatMap {
            do {
                let item: ConversionResult.Iterator.Element = try unbox(dictionary: $0)
                return item
            } catch {
                print("Unable to Unbox Response Due to Error (\(error))")
                return nil
            }
        }
        
        let response = responseElements as? ConversionResult
        return response
    }
}

final class AnyDataExistsResponseConverter: ResponseConverter {
    typealias ConversionResult = Bool

    func decodeResponse(data: Data) -> ConversionResult? {
        return !data.isEmpty ? true : nil
    }
}
