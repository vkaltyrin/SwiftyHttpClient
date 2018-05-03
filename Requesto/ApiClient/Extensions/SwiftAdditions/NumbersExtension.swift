import Foundation
import UIKit

public extension Double {
    // If you don't want your code crash on each overflow, use this function that operates on optionals
    // E.g.: Int(Double(Int.max) + 1) will crash:
    // fatal error: floating point value can not be converted to Int because it is greater than Int.max
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    func toInt32() -> Int32? {
        if self > Double(Int32.min) && self < Double(Int32.max) {
            return Int32(self)
        } else {
            return nil
        }
    }
    
    func toInt64() -> Int64? {
        if self > Double(Int64.min) && self < Double(Int64.max) {
            return Int64(self)
        } else {
            return nil
        }
    }
    
    func toUInt() -> UInt? {
        if self >= Double(UInt.min) && self < Double(UInt.max) {
            return UInt(self)
        } else {
            return nil
        }
    }
    
    func toUInt64() -> UInt64? {
        if self >= Double(UInt64.min) && self < Double(UInt64.max) {
            return UInt64(self)
        } else {
            return nil
        }
    }
    
    func toFloat() -> Float? {
        if self >= Double(-Float.greatestFiniteMagnitude) && self < Double(Float.greatestFiniteMagnitude) {
            return Float(self)
        } else {
            return nil
        }
    }
    
    // 4/5-rounding. 0.4 is 0, 0.5 is 1
    func roundToInt() -> Int? {
        return rounded(.toNearestOrAwayFromZero).toInt()
    }
    
    func roundToUInt() -> UInt? {
        return rounded(.toNearestOrAwayFromZero).toUInt()
    }
    
    func roundToInt64() -> Int64? {
        return rounded(.toNearestOrAwayFromZero).toInt64()
    }
    
    func roundToUInt64() -> UInt64? {
        return rounded(.toNearestOrAwayFromZero).toUInt64()
    }
}

public extension Int {
    func toDouble() -> Double {
        return Double(self)
    }
    
    func toUInt() -> UInt? {
        if self >= 0 {
            return UInt(self)
        } else {
            return nil
        }
    }

    func toInt32() -> Int32? {
        if self > Int(Int32.max) || self < Int(Int32.min) {
            return nil
        } else {
            return Int32(self)
        }
    }
    
    func toInt64() -> Int64 {
        return Int64(self)
    }
    
    func toUInt64() -> UInt64? {
        if self >= 0 {
            return UInt64(self)
        } else {
            return nil
        }
    }
    
    func toTimeInterval() -> TimeInterval {
        return TimeInterval(self)
    }
    
    static func random() -> Int {
        let random = arc4random()
        
        if let intValue = Int(exactly: random) {
            return intValue
        } else {
            // Int.max < UInt32.max (32-bit systems)
            let maxUintRepresentableByInt = UInt32(Int32.max)
            if random <= maxUintRepresentableByInt {
                return Int(random)
            } else {
                return Int(random % maxUintRepresentableByInt)
            }
        }
    }
}

public extension UInt {
    func toInt() -> Int? {
        if self <= UInt(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

public extension Float {
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    func toInt64() -> Int64? {
        if self > Float(Int64.min) && self < Float(Int64.max) {
            return Int64(self)
        } else {
            return nil
        }
    }
    
    func toUInt() -> UInt? {
        if self >= Float(UInt.min) && self < Float(UInt.max) {
            return UInt(self)
        } else {
            return nil
        }
    }
}

public extension CGFloat {
    func toInt() -> Int? {
        if self > CGFloat(Int.min) && self < CGFloat(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    func toUInt() -> UInt? {
        if self >= CGFloat(UInt.min) && self < CGFloat(UInt.max) {
            return UInt(self)
        } else {
            return nil
        }
    }
    
    // There are two builtin functions:
    //
    // min returns minimal positive value (as does FLT_MIN in Obj-C, or numeric_limits<float>.min() in C++)
    // max returns maximal positive value (as does FLT_MAX in Obj-C, or numeric_limits<float>.max() in C++)
    //
    // We added another useful one:
    //
    // lowest returns minimal value (as does numeric_limits<float>.lowest() in C++)
    //
    static var lowest: CGFloat {
        return -CGFloat.greatestFiniteMagnitude
    }
}

public extension NSNumber {
    func isBoolean() -> Bool {
        return self === kCFBooleanTrue || self === kCFBooleanFalse
    }
    
    func toInt() -> Int? {
        let int = intValue
        let overflow = self != NSNumber(value: int)
        return overflow ? nil : int
    }
    
    func toInt64() -> Int64? {
        let int64 = int64Value
        let overflow = self != NSNumber(value: int64)
        return overflow ? nil : int64
    }
    
    func toUInt64() -> UInt64? {
        let uint64 = uint64Value
        let overflow = self != NSNumber(value: uint64)
        return overflow ? nil : uint64
    }
    
    func toUInt() -> UInt? {
        let uint = uintValue
        let overflow = self != NSNumber(value: uint)
        return overflow ? nil : uint
    }
}

public extension String {
    func toInt() -> Int? {
        return Int(self)
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func toDate() -> Date? {
        if let timeInterval = TimeInterval(self) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
}

public extension Bool {
    func toBinaryString() -> String {
        return self == true  ? "1" : "0"
    }
    
    func toLongString() -> String {
        return self == true ? "true" : "false"
    }
}

public extension Int64 {
    func toInt() -> Int? {
        if self >= Int64(Int.min) && self <= Int64(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

public extension UInt64 {
    func toInt() -> Int? {
        if self <= UInt64(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

public extension DispatchTime {
    static var maximumInconspicuousPossibleDeadline: DispatchTime {
        return .now() + 0.1
    }
}
