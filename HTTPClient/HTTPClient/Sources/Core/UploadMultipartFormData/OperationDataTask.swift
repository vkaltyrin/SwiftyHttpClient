import Foundation

final class OperationDataTask: NetworkDataTask {
    private let operation: Operation
    
    init(operation: Operation) {
        self.operation = operation
    }
    
    // MARK: - NetworkDataTask
    
    func cancel() {
        operation.cancel()
    }
    
    var isCancelled: Bool {
        return operation.isCancelled
    }
}
