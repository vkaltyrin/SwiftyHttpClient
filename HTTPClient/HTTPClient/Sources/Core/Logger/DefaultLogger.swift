import Foundation

public final class DefaultLogger: Logger {
    
    public init() {}
    
    public func log(cUrl: String) {
        print(cUrl)
    }
}
