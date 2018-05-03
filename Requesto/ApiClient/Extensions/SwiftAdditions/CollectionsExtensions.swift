import Foundation

public func stripNils<T>(_ elements: [T?]) -> [T] {
    var filtered = [T]()
    for element in elements {
        if let element = element {
            filtered.append(element)
        }
    }
    return filtered
}

public func stripNils<T>(_ elements: T?...) -> [T] {
    var filtered = [T]()
    for element in elements {
        if let element = element {
            filtered.append(element)
        }
    }
    return filtered
}

// TODO: make generic version
public func joinStrippingNils(_ separator: String, elements: [String?]) -> String? {
    return stripNils(elements).joined(separator: separator)
}

public func joinStrippingNils(_ separator: String, elements: String?...) -> String? {
    return stripNils(elements).joined(separator: separator)
}

public func isEmptyOrNil(_ string: String?) -> Bool {
    return string.map { $0.isEmpty } ?? true
}

public func isEmptyOrNil<C: Collection>(_ collection: C?) -> Bool {
    return collection.map { $0.isEmpty } ?? true
}

public func isEmptyOrNil(_ array: NSArray?) -> Bool {
    return (array?.count ?? 0) == 0
}

public extension Optional where Wrapped: Collection {
    func isEmptyOrNil() -> Bool {
        if let wrapped = self {
            return wrapped.isEmpty
        } else {
            return true
        }
    }
}

public extension NSAttributedString {
    var isEmpty: Bool {
        return length == 0
    }
}

public extension Collection {
    // Returns element at index or nil if index is out of range
    func elementAtIndex(_ index: Index) -> Iterator.Element? {
        let intIndex = distance(from: startIndex, to: index)

        if intIndex >= 0 && intIndex < count {
            return self[index]
        } else {
            return nil
        }
    }
}

public extension Collection {
    func first(_ match: (Self.Iterator.Element) throws -> Bool)
        -> Self.Iterator.Element?
    {
        for element in self {
            let matches = try? match(element)
            
            if matches == true {
                return element
            }
        }
        
        return nil
    }
    
    func last(_ match: (Self.Iterator.Element) throws -> Bool)
        -> Self.Iterator.Element?
    {
        for element in self.reversed() {
            let matches = try? match(element)
            
            if matches == true {
                return element
            }
        }
        
        return nil
    }
    
    func firstNonNil<T>(_ transform: (Self.Iterator.Element) throws -> T?) -> T? {
        for element in self {
            if let transformedOrNil = try? transform(element) {
                if let transformed = transformedOrNil {
                    return transformed
                }
            }
        }
        
        return nil
    }
    
    func lastNonNil<T>(_ transform: (Self.Iterator.Element) throws -> T?) -> T? {
        for element in self.reversed() {
            if let transformedOrNil = try? transform(element) {
                if let transformed = transformedOrNil {
                    return transformed
                }
            }
        }
        
        return nil
    }
    
    func allElementsSatisfy(_ check: (Element) -> Bool) -> Bool {
        return !contains { !check($0) }
    }
}

public extension Array {
    @discardableResult
    mutating func removeFirst(_ match: (Element) throws -> Bool)
        -> Element?
    {
        for (index, element) in self.enumerated() {
            let matches = try? match(element)
            
            if matches == true {
                return remove(at: index)
            }
        }
        
        return nil
    }
    
    @discardableResult
    mutating func removeLast(_ match: (Element) throws -> Bool)
        -> Element?
    {
        for (index, element) in self.reversed().enumerated() {
            let matches = try? match(element)
            
            if matches == true {
                return remove(at: count - index - 1)
            }
        }
        
        return nil
    }
    
    @discardableResult
    mutating func removeAll(match: (Iterator.Element) -> (Bool)) -> [Iterator.Element] {
        var removedElements: [Iterator.Element] = []
        for (index, element) in enumerated() {
            if match(element) {
                removedElements.append(remove(at: index))
            }
        }
        return removedElements
    }
}

public extension Array {
    func subarray(_ range: Range<Int>) -> Array? {
        if range.lowerBound >= 0 && range.upperBound < count {
            return Array(self[range])
        } else {
            return nil
        }
    }
}

public extension Array {
    mutating func moveElement(from sourceIndex: Int, to destinationIndex: Int) {
        if let itemToMove = elementAtIndex(sourceIndex), 0 <= destinationIndex && destinationIndex < count {
            remove(at: sourceIndex)
            insert(itemToMove, at: destinationIndex)
        }
    }
}

public extension ArraySlice {
    // swiftlint:disable:next syntactic_sugar
    func toArray() -> Array<Iterator.Element> {
        return Array(self)
    }
}

// Zips 2 arrays, pads arrays if they aren't of same length
public func zip<T>(_ a: [T], _ b: [T], pad: T) -> Zip2Sequence<[T], [T]> {
    var a = a
    var b = b
    
    while a.count < b.count {
        a.append(pad)
    }
    while a.count > b.count {
        b.append(pad)
    }
    
    return zip(a, b)
}

// [1, 2] + ["a"] == [(1, "a"), (2, nil)]
public func zipAddingNils<A, B>(_ a: [A], _ b: [B]) -> Zip2Sequence<[A?], [B?]> {
    // swiftlint:disable:next array_init
    var a: [A?] = a.map { $0 }
    // swiftlint:disable:next array_init
    var b: [B?] = b.map { $0 }
    
    while a.count < b.count {
        a.append(nil)
    }
    while a.count > b.count {
        b.append(nil)
    }
    
    return zip(a, b)
}
