import Foundation

// Brief: to make date-time functions testable
protocol CurrentDateProvider {
    func currentDate() -> Date
}

final class CurrentDateProviderImpl: CurrentDateProvider {
    init() {}
    
    func currentDate() -> Date {
        return Date()
    }
}
