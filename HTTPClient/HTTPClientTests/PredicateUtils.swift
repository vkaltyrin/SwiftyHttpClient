import Foundation
import Quick
import Nimble
@testable import HTTPClient

func beData<T,E>(_ test: @escaping (T) -> Void = { _ in }) -> Predicate<DataResult<T, E>> {
    return Predicate.define("be <data>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .data(value) = actual {
            test(value)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

func beError<T,E>(_ test: @escaping (E) -> Void = { _ in }) -> Predicate<DataResult<T, E>> {
    return Predicate.define("be <error>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .error(error) = actual {
            test(error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
