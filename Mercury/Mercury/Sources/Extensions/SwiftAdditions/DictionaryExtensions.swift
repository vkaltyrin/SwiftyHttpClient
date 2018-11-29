import Foundation

public extension Dictionary {
    
    func string(forKey key: Key) -> String? {
        guard let value = self[key] else {
            return nil
        }
        if let stringValue = value as? String {
            return stringValue
        }
        return String(describing: value)
    }
    
    func int(forKey key: Key) -> Int? {
        guard let value = self[key] else {
            return nil
        }
        if let intValue = value as? Int {
            return intValue
        } else if let stringValue = value as? String {
            return Int(stringValue)
        } else if let numberValue = value as? NSNumber {
            return numberValue.intValue
        }
        return nil
    }
    
    func bool(forKey key: Key) -> Bool? {
        guard let value = self[key] else {
            return nil
        }
        if let boolValue = value as? Bool {
            return boolValue
        } else if let numberValue = value as? NSNumber {
            return numberValue.boolValue
        } else if let intValue = value as? Int {
            return intValue != 0
        } else if let stringValue = value as? String {
            return stringValue == "true" || stringValue != "0"
        }
        return nil
    }
    
    func array(forKey key: Key) -> [[String: AnyObject]]? {
        guard let value = self[key] as? [[String: AnyObject]] else {
            return nil
        }
        return value
    }
    
    func enumFor<T: RawRepresentable>(key: Key) -> T? where T.RawValue == String {
        guard let value = self[key] as? String else {
            return nil
        }
        if let enumValue = T(rawValue: value) {
            return enumValue
        }
        return nil
    }
    
    func map<OutKey: Hashable, OutValue>(_ transform: (Element) -> (OutKey, OutValue)) -> [OutKey: OutValue] {
        var result = [OutKey: OutValue]()
        for keyValuePair in self {
            let (outKey, outValue) = transform(keyValuePair)
            result[outKey] = outValue
        }
        return result
    }
    
    // MARK: - Backward compatibility
    
    @available(*, renamed: "string(forKey:)")
    func stringFor(key: Key) -> String? {
        return string(forKey: key)
    }
    
    @available(*, renamed: "int(forKey:)")
    func intFor(key: Key) -> Int? {
        return int(forKey: key)
    }
    
    @available(*, renamed: "bool(forKey:)")
    func boolFor(key: Key) -> Bool? {
        return bool(forKey: key)
    }
    
    @available(*, renamed: "array(forKey:)")
    func arrayFor(key: Key) -> [[String: AnyObject]]? {
        return array(forKey: key)
    }
}

public extension Dictionary {
    mutating func addEntriesFromDictionary(_ anotherDictionary: Dictionary) {
        for (key, value) in anotherDictionary {
            updateValue(value, forKey: key)
        }
    }
}

func += <KeyType, ValueType> (left: inout [KeyType: ValueType], right: [KeyType: ValueType]) {
    left.addEntriesFromDictionary(right)
}

public func + <KeyType, ValueType>(left: [KeyType: ValueType], right: [KeyType: ValueType]) -> [KeyType: ValueType] {
    var map = [KeyType: ValueType]()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}
