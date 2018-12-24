import Foundation

public protocol Logger: class {
    func log(cUrl: String)
}

public final class DefaultLogger: Logger {
    public func log(cUrl: String) {
        print(cUrl)
    }
}
