public extension Array {
    public var isNotEmpty: Bool {
        @inline(__always) get {
            return !isEmpty
        }
    }
}

public extension Dictionary {
    public var isNotEmpty: Bool {
        @inline(__always) get {
            return !isEmpty
        }
    }
}

public extension Set {
    public var isNotEmpty: Bool {
        @inline(__always) get {
            return !isEmpty
        }
    }
}
