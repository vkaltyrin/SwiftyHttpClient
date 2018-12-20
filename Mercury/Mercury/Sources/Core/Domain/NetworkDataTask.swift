import Foundation

public protocol NetworkDataTask: class {
    func cancel()
    
    var isCancelled: Bool { get }
}
