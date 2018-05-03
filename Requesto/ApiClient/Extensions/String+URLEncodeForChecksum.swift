import Foundation
import UIKit

extension String {

    func byAddingCustomPercentEncodingForChecksumCalculation() -> String {
        if UIDevice.iosVersion.majorVersion > 8 {
            return byAddingCustomPercentEncodingForChecksumCalculation(splitLimit: nil)
        } else {
            return byAddingCustomPercentEncodingForChecksumCalculation(splitLimit: 200)
        }
    }
    
    // The separate function created for testing
    func byAddingCustomPercentEncodingForChecksumCalculation(splitLimit: Int?) -> String {
        if let splitLimit = splitLimit {
            return split(count: splitLimit)
                .flatMap { $0.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet()) }
                .joined()
        } else {
            return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet()) ?? self
        }
    }
    
    private func split(count: Int) -> [String] {
        return stride(from: 0, to: utf16.count, by: count).map { i -> String in
            let startIndex = self.index(self.startIndex, offsetBy: i)
            let endIndex = self.index(startIndex, offsetBy: count, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[startIndex..<endIndex])
        }
    }
    
    // http://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
    // Alamofire leave ? and / characters unescaped,
    // but this breaks our checksum calculation and we get 403 error
    // So use this hack instead of Alamofire's `UrlEncoding` `escape` function
    private func allowedCharacterSet() -> CharacterSet {
        let unreserved = "-._~"
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: unreserved)
        return characterSet
    }
}
