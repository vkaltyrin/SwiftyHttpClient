import Foundation

extension String {
    func normalizedQueryPath() -> String {
        // remove leading and trailing `/` characters
        let components = self.components(separatedBy: "/")
        let nonEmptyComponents = components.filter { !$0.isEmpty }
        
        // return leading `/` character
        return "/" + nonEmptyComponents.joined(separator: "/")
    }
}
