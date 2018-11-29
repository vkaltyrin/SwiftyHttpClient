protocol XSessionHeaderProvider {
    func xSessionHeader(sessionId: String) -> HttpHeader
}

final class XSessionHeaderProviderImpl: XSessionHeaderProvider {
    func xSessionHeader(sessionId: String) -> HttpHeader {
        return HttpHeader(
            field: .cookie,
            value: "session_id=\(sessionId)"
        )
    }
}
