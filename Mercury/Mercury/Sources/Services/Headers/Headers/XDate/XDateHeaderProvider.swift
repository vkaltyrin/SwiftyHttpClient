protocol XDateHeaderProvider {
    func xDateHeader() -> HttpHeader?
}

final class XDateHeaderProviderImpl: XDateHeaderProvider {
    private let currentDateProvider: CurrentDateProvider
    
    init(currentDateProvider: CurrentDateProvider) {
        self.currentDateProvider = currentDateProvider
    }
    
    func xDateHeader() -> HttpHeader? {
        guard let timestamp = currentDateProvider.currentDate().timeIntervalSince1970.toInt() else {
            return nil
        }
        
        return HttpHeader(
            field: .xDate,
            value: String(describing: timestamp)
        )
    }
}
