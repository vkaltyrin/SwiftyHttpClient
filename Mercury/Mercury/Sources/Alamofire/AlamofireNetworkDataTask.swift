import Foundation
import Alamofire

public final class AlamofireNetworkDataTask: NetworkDataTask {
    var request: Alamofire.Request?
    
    init(request: Alamofire.Request?) {
        self.request = request
    }
    
    public var isCancelled = false
    
    public func cancel() {
        guard !isCancelled else {
            return
        }
        
        request?.cancel()
        
        isCancelled = true
    }
}
