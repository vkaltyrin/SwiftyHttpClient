import Unbox

extension Unboxer {
    // Returns a string even if API gives us a number by mistake
    func unbox(key: String) throws -> String {
        if let string = dictionary[key] as? String {
            return string
        }
        
        if let number = dictionary[key] as? NSNumber {
            return number.stringValue
        }
        
        throw UnboxError.invalidData
    }
    
    // Returns an optional string even if API gives us a number by mistake
    func unbox(key: String) -> String? {
        if let string = dictionary[key] as? String {
            return string
        }
        
        if let number = dictionary[key] as? NSNumber {
            return number.stringValue
        }
        
        return nil
    }
    
    // Returns an array of strings even if API gives us an array of numbers by mistake
    func unbox(key: String) throws -> [String] {
        if let arrayOfStrings = dictionary[key] as? [String] {
            return arrayOfStrings
        }
        
        if let arrayOfNubmers = dictionary[key] as? [NSNumber] {
            return arrayOfNubmers.map { $0.stringValue }
        }
        
        throw UnboxError.invalidData
    }
    
    // Returns an optional array of strings even if API gives us an array of numbers by mistake
    func unbox(key: String) -> [String]? {
        if let arrayOfStrings = dictionary[key] as? [String] {
            return arrayOfStrings
        }
        
        if let arrayOfNubmers = dictionary[key] as? [NSNumber] {
            return arrayOfNubmers.map { $0.stringValue }
        }
        
        return nil
    }

    func unboxDateFromSeconds(key: String) throws -> Date {
        let seconds: Any? = dictionary[key]
        let timeInterval = seconds.flatMap { Unboxer.toDouble($0) }
        if let result = timeInterval.flatMap({ Date(timeIntervalSince1970: $0) }) {
            return result
        } else {
            throw UnboxError.invalidData
        }
    }
    
    func unboxDateFromSeconds(key: String) -> Date? {
        let seconds: Any? = dictionary[key]
        let timeInterval = seconds.flatMap { Unboxer.toDouble($0) }
        let result = timeInterval.flatMap { Date(timeIntervalSince1970: $0) }
        return result
    }
    
    func unboxDateFromTenMillionthsOfSeconds(key: String) throws -> Date {
        if let timestamp: UInt64 = Unboxer.toUInt64(dictionary[key]) {
            return Date(tenMillionthsOfSecondsSince1970: timestamp)
        } else {
            throw UnboxError.invalidData
        }
    }
    
    func unboxDateFromTenMillionthsOfSeconds(key: String) -> Date? {
        if let timestamp: UInt64 = Unboxer.toUInt64(dictionary[key]) {
            return Date(tenMillionthsOfSecondsSince1970: timestamp)
        } else {
            return nil
        }
    }
    
    // MARK: - Convenience
    func unbox<T: Unboxable>(key: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(key: key)) ?? fallbackValue()
    }
    
    func unbox<T: UnboxableCollection>(key: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(key: key, allowInvalidElements: true)) ?? fallbackValue()
    }
    
    func unbox<T: UnboxableCollection>(
        key: String,
        allowInvalidElements: Bool,
        fallbackValue: @autoclosure () -> T)
        -> T
    {
        return (try? unbox(key: key, allowInvalidElements: allowInvalidElements)) ?? fallbackValue()
    }
    
    func unbox<T: UnboxCompatible>(key: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(key: key)) ?? fallbackValue()
    }
    
    func unbox<T: Unboxable>(keyPath: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(keyPath: keyPath)) ?? fallbackValue()
    }
    
    func unbox<T: UnboxableCollection>(keyPath: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(keyPath: keyPath)) ?? fallbackValue()
    }
    
    func unbox<T: UnboxCompatible>(keyPath: String, fallbackValue: @autoclosure () -> T) -> T {
        return (try? unbox(keyPath: keyPath)) ?? fallbackValue()
    }
    
    // MARK: - Private static (converting)
    private static func toInt(_ any: Any?) -> Int? {
        switch any {
        case let number as NSNumber:
            // Bool is not Int
            return number.isBoolean() ? nil : number.toInt()
        case let string as String:
            // Double values also suit:
            // 0.0 => 0
            // 1.1 => 1
            
            // Convert string to int (lossless).
            // If failed, handle it as double (lossy, because it's double).
            
            return string.toInt() ?? stringToDouble(string)?.toInt()
        default:
            return nil
        }
    }
    
    private static func toInt64(_ any: Any?) -> Int64? {
        switch any {
        case let number as NSNumber:
            return number.isBoolean() ? nil : number.toInt64()
        case let string as String:
            return string.toInt64() ?? stringToDouble(string)?.toInt64()
        default:
            return nil
        }
    }
    
    private static func toUInt(_ any: Any?) -> UInt? {
        switch any {
        case let number as NSNumber:
            return number.isBoolean() ? nil : number.toUInt()
        case let string as String:
            return string.toUInt() ?? stringToDouble(string)?.toUInt()
        default:
            return nil
        }
    }
    
    private static func toUInt64(_ any: Any?) -> UInt64? {
        switch any {
        case let number as NSNumber:
            return number.isBoolean() ? nil : number.toUInt64()
        case let string as String:
            return string.toUInt64() ?? stringToDouble(string)?.toUInt64()
        default:
            return nil
        }
    }
    
    private static func toDateFromSeconds(_ any: Any?) -> Date? {
        if let timeIntervalSince1970 = toDouble(any) {
            return Date(timeIntervalSince1970: timeIntervalSince1970)
        } else {
            return nil
        }
    }
    
    private static func toBool(_ any: Any?) -> Bool? {
        switch any {
        case let number as NSNumber:
            // API sometimes send boolean true (we can compare it to kCFBooleanTrue), sometimes 1. Same for false and 0.
            switch number.doubleValue {
            case 0:
                return false
            case 1:
                return true
            default:
                return nil
            }
        case let string as NSString:
            switch string {
            case "0", "false":
                return false
            case "1", "true":
                return true
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    private static func toDouble(_ any: Any?) -> Double? {
        switch any {
        case let number as NSNumber:
            if number === kCFBooleanTrue || number === kCFBooleanFalse {
                // Bool is not Int
                return nil
            } else {
                return number.doubleValue
            }
        case let string as NSString:
            return stringToDouble(string as String)
        default:
            return nil
        }
    }
    
    private static func toString(_ any: Any?) -> String? {
        switch any {
        case let string as NSString:
            return string as String
        case let number as NSNumber:
            // WARNING: We can not guarantee that string will be same as in JSON.
            // E.g.: we got 'id = 1.00' from server. But after conversion to number and then back to string it will be '1', not '1.00'
            return number.stringValue
        default:
            return nil
        }
    }
    
    private static let numberFormatter: Foundation.NumberFormatter = {
        var numberFormatter = Foundation.NumberFormatter()
        // Server gives floating point numbers with dots, as in en_US_POSIX locale:
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        return numberFormatter
    }()
    
    private static func stringToDouble(_ string: String) -> Double? {
        if let numberValue = numberFormatter.number(from: string) {
            return numberValue.doubleValue
        }
        return nil
    }
}

/// Server sents time in "UNIX-time * 10.000.000" format
private let timestampTenMillionthsOfSecondsFactor: UInt64 = 10_000_000

private extension Date {
    init(tenMillionthsOfSecondsSince1970: UInt64) {
        let timeInterval = tenMillionthsOfSecondsSince1970 / timestampTenMillionthsOfSecondsFactor
        self.init(timeIntervalSince1970: TimeInterval(timeInterval))
    }
}
