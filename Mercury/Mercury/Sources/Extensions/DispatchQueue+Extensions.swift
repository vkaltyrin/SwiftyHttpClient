import Foundation

 extension DispatchQueue {
    static func dispatchToMain(block: @escaping () -> ()) {
        if Thread.isMainThread {
            block()
        } else {
            main.async(execute: block)
        }
    }
    
    static func dispatchToMainSync<T>(block: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try block()
        } else {
            return try main.sync(execute: block)
        }
    }
}

