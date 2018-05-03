import Unbox

public extension ApiMethod where Result: Unboxable {
     var resultConverter: ResponseConverterOf<Result> {
        return ResponseConverterOf(UnboxingResponseConverter<Result>())
    }
}

public extension ApiMethod where Result: Collection, Result.Iterator.Element: Unboxable {
     var resultConverter: ResponseConverterOf<Result> {
        return ResponseConverterOf(CollectionUnboxingResponseConverter<Result>())
    }
}
