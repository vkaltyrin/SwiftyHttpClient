public enum DataResult<T, E> {
    case data(T)
    case error(E)
    
    public typealias Completion = (DataResult) -> ()
    
    public func onData(_ closure: (T) -> ()) {
        switch self {
        case .error:
            break
        case .data(let data):
            closure(data)
        }
    }
    
    public func onError(_ closure: (E) -> ()) {
        switch self {
        case .error(let error):
            closure(error)
        case .data:
            break
        }
    }
}
