import Foundation

public extension Array {
    public func randomItem() -> Element? {
        if count == 0 {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}
