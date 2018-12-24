import Foundation

extension Encodable {
    var log: String {
        if
            let jsonData = try? JSONEncoder().encode(self),
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        {
            return "\(jsonString)\n"
        }
        return "Failed to encode json"
    }
}
