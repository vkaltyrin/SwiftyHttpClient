import Foundation

public protocol DataProvider: class {
    func data(completion: @escaping (Data?) -> ())
}
