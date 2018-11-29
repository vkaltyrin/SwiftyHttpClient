import Foundation

struct UnwrappingError: Error {
}

public extension Optional {
    // Useful thing. Standard toString() func on optionals returns something like .Optional("text"), which is less readable in debugger
    var toStringByUnwrapping: String {
        return map { String(describing: $0) } ?? "nil"
    }
    
    // throws UnwrappingException
    func unwrap() throws -> Wrapped {
        if let unwrapped = self {
            return unwrapped
        } else {
            throw UnwrappingError()
        }
    }
}

public func isEqual<T>(_ a: T?, _ b: T?) -> Bool where T: Equatable {
    if let a = a, let b = b {
        return (a == b)
    } else {
        return (a == nil) && (b == nil)
    }
}

public func isEqual<T>(_ a: [T]?, _ b: [T]?) -> Bool where T: Equatable {
    if a?.count == b?.count {
        if let a = a, let b = b {
            for i in 0..<a.count {
                if a[i] != b[i] {
                    return false
                }
            }
        }
        return true
    } else {
        return false
    }
}
