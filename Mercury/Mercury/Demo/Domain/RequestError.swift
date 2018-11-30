public enum RequestBuilderError {
    case cantInitializeUrl
    case cantSerializeHttpBody
}

public enum ApiClientError {
    case parsingFailure
    case attemptToSendAuthorizedRequest
    case cantBuildUrl(RequestBuilderError)
}

public enum UploadMultipartError {
    case invalidData
    case cantDecodeSuccessResponse
    case cantDecodeFailureResponse
}

public enum RequestError<ApiErrorType> {
    case networkError(Error) // Got error from low level services
    case apiClientError(ApiClientError) // Emited error
    case httpUnauthenticated
    case apiError(ApiErrorType) // Got error from API
    case forbidden
    case cantUploadMultipart(UploadMultipartError)
    
    var isUnauthenticated: Bool {
        if case .httpUnauthenticated = self {
            return true
        } else {
            return false
        }
    }
}

typealias ApiResult<T> = DataResult<T, RequestError<Error>>
