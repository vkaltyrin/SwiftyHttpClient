import Unbox

enum ResponseCode: String, UnboxableEnum {
    // Success response
    case ok = "ok"
    
    // Base errors
    case unauthenticated = "unauthenticated"
    case unauthorized = "unauthorized"
    case forbidden = "forbidden"
    case badRequest = "bad-request"
    case internalError = "internal-error"
    case notFound = "not-found"
}
