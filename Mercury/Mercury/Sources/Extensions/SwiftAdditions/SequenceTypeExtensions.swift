import Foundation

public extension Sequence where Iterator.Element == NSAttributedString {
    
    func joinWithSeparator(_ separator: String) -> NSAttributedString {
        return joinWithSeparator(NSAttributedString(string: separator))
    }
    
    func joinWithSeparator(_ separator: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for element in self {
            if result.length > 0 {
                result.append(separator)
            }
            result.append(element)
        }
        
        return result
    }
}
