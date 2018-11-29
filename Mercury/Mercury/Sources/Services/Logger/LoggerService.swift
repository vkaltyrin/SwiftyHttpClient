import Foundation

public protocol LoggerService: class {
    func logRequest(cUrl: String, response: String)
}
