import Foundation
import Alamofire
import HTTPClient

public final class AlamofireNetworkDataTask: NetworkDataTask {
    // MARK: - Dependencies
    let request: Alamofire.Request?
    
    // MARK: - Init
    init(request: Alamofire.Request?) {
        self.request = request
    }
    
    // MARK: - NetworkDataTask
    public var isCancelled = false
    
    public func cancel() {
        guard !isCancelled else {
            return
        }
        
        request?.cancel()
        
        isCancelled = true
    }
}
