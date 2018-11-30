import Unbox

public extension ApiRequest where Result: Unboxable {
    var resultConverter: ResponseConverterOf<Result> {
        return ResponseConverterOf(UnboxingResponseConverter<Result>())
    }
}

public extension ApiRequest where Result: Collection, Result.Iterator.Element: Unboxable {
    var resultConverter: ResponseConverterOf<Result> {
        return ResponseConverterOf(CollectionUnboxingResponseConverter<Result>())
    }
}
