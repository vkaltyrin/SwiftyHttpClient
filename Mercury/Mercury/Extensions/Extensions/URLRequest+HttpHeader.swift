import Foundation

extension URLRequest {
    mutating func appendHttpHeaders(_ headers: [HttpHeader]) {
        for header in headers {
            appendHeader(header)
        }
    }
    mutating func appendHeader(_ header: HttpHeader) {
        setValue(header.value, forHTTPHeaderField: header.name)
    }
}
