import Foundation
import HTTPClient

final class LoggerImpl: Logger {
    let onLogRequest: ((String) -> ())
    
    init(onLogRequest: @escaping ((String) -> ())) {
        self.onLogRequest = onLogRequest
    }
    
    func log(cUrl: String) {
        DispatchQueue.main.async {
            self.onLogRequest(cUrl)
        }
    }
}
