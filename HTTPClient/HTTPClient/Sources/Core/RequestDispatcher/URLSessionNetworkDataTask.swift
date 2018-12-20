import Foundation

final class URLSessionNetworkDataTask: NetworkDataTask {
    private let task: URLSessionDataTask
    
    init(task: URLSessionDataTask) {
        self.task = task
    }
    
    // MARK: - NetworkDataTask
    
    func cancel() {
        task.cancel()
    }
    
    var isCancelled: Bool {
        switch task.state {
        case .canceling:
            return true
        default:
            return false
        }
    }
}
