import Foundation

 extension Data {
    var toJSON: [String: Any]? {
        if let json = toJsonObject as? [String: Any] {
            return json
        }
        
        return nil
    }
    
    var toJsonArray: [[String: Any]]? {
        if let jsonArray = toJsonObject as? [[String: Any]] {
            return jsonArray
        }
        
        return nil
    }
    
    private var toJsonObject: Any? {
        guard count > 0 else { return nil }
        
        do  {
            return try JSONSerialization.jsonObject(with: self, options: [.allowFragments])
        } catch {
            return nil
        }
    }
}
