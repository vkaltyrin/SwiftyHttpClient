import Unbox

public final class ApiError: Unboxable {
    public let code: String?
    public let message: String?
    public let detail: String?
    
    // MARK: - Unboxable
    public init(unboxer: Unboxer) throws {
        code = unboxer.unbox(key: "code")
        message = unboxer.unbox(key: "message")
        detail = unboxer.unbox(key: "detail")
    }
}
