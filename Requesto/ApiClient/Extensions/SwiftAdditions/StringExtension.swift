import Foundation

public extension String {
    func toUInt() -> UInt? {
        return UInt(self)
    }
    
    func toInt32() -> Int32? {
        let scanner = Scanner(string: self)
        var value: Int32 = 0
        if scanner.scanInt32(&value) {
            return value
        } else {
            return nil
        }
    }
    
    func toInt64() -> Int64? {
        let scanner = Scanner(string: self)
        var value: Int64 = 0
        if scanner.scanInt64(&value) {
            return value
        } else {
            return nil
        }
    }
    
    func toUInt64() -> UInt64? {
        let scanner = Scanner(string: self)
        var value: UInt64 = 0
        if scanner.scanUnsignedLongLong(&value) {
            return value
        } else {
            return nil
        }
    }
    
    var byCapitalizingFirstCharacter: String {
        if count >= 1 {
            let secondCharacterIndex = index(startIndex, offsetBy: 1)
            return self[..<secondCharacterIndex].toString().capitalized + self[secondCharacterIndex...].toString()
        } else {
            return self
        }
    }
    
    var byDecapitalizingFirstCharacter: String {
        if count >= 1 {
            let secondCharacterIndex = index(startIndex, offsetBy: 1)
            return self[..<secondCharacterIndex].toString().lowercased() + self[secondCharacterIndex...].toString()
        } else {
            return self
        }
    }
    
    func toUrl() -> URL? {
        return URL(string: self)
    }
    
    func toHttpUrl() -> URL? {
        return URL.httpURL(string: self)
    }
    
    func priceFormatted() -> String {
        let noSpacesString = replacingOccurrences(of: " ", with: "")
        var formattedString = ""
        var charNum = 0
        for character in noSpacesString.reversed() {
            charNum += 1
            let separator = (charNum > 1 && charNum % 3 == 1) ? " " : ""
            formattedString = String(character) + separator + formattedString
        }
        return formattedString
    }
    
    func trim() -> String {
        return trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
    
    // TODO: Revisit the algorithm
    // TODO: Rename, set pattern as a some kind of paramerer
    func strippingTags() -> String {
        var r: NSRange
        var s: NSString = self.copy() as? NSString ?? ""
        let pattern = "&[a-zA-Z]+;"
        
        r = s.range(of: pattern, options: .regularExpression)
        while r.location != NSNotFound {
            s = s.replacingCharacters(in: r, with: "") as NSString
            r = s.range(of: pattern, options: .regularExpression)
        }
        return s as String
    }
    
    func rangesOfString(_ string: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var sourceString = self
        
        while !sourceString.isEmpty {
            if let range = sourceString.range(of: string) {
                sourceString = sourceString[range.upperBound...].toString()
                ranges.append(range)
            } else {
                break
            }
        }
        
        return ranges
    }
    
    // Useful methods for creating CustomDebugStringConvertible
    private static let newLine = "\n"
    
    func indent(_ indentation: String = "    ") -> String {
        return self
            .components(separatedBy: String.newLine)
            .map { indentation + $0 }
            .joined(separator: String.newLine)
    }
    
    func wrapAndIndent(prefix: String = "", postfix: String = "", skipIfEmpty: Bool = true) -> String {
        if isEmpty && skipIfEmpty {
            return ""
        } else {
            return prefix + String.newLine
                + indent() + String.newLine
                + postfix
        }
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTestPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTestPredicate.evaluate(with: self)
    }

    func withoutNewLines() -> String {
        return replacingOccurrences(of: "\n", with: "")
    }
    
    var urlEncoded: String? {
        let charactersToBeEscaped = ":/?&=;+!@#$()~',*[] "
        
        let toBeEscapedSet = CharacterSet(charactersIn: charactersToBeEscaped).inverted
        let escapedString = addingPercentEncoding(withAllowedCharacters: toBeEscapedSet)
        
        return escapedString?.replacingOccurrences(of: "%20", with: "+")
    }
    
    var urlDecoded: String? {
        return replacingOccurrences(of: "+", with: " ").removingPercentEncoding
    }
    
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func appendingPathComponent(_ component: String) -> String {
        return (self as NSString).appendingPathComponent(component)
    }
    
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var removingLeadingSlash: String {
        if self.hasPrefix("/") {
            var result = self
            result.remove(at: result.startIndex)
            return result
        } else {
            return self
        }
    }
    
    func truncate(length: Int, trailing: String? = nil) -> String {
        if count > length {
            return prefix(length).toString() + (trailing ?? "")
        } else {
            return self   
        }
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

public extension NSString {
    @objc func urlDecodedString() -> NSString? {
        return (self as String).urlDecoded as NSString?
    }
}
