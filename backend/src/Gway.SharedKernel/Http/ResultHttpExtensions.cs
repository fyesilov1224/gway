using Microsoft.AspNetCore.Http;

namespace Gway.SharedKernel.Http;

/// <summary>Maps <see cref="Result"/> to HTTP responses; failures become RFC 9457 ProblemDetails.</summary>
public static class ResultHttpExtensions
{
    public static IResult ToHttpResult(this Result result) =>
        result.IsSuccess ? TypedResults.NoContent() : result.Error.ToProblem();

    public static IResult ToHttpResult<T>(this Result<T> result) =>
        result.IsSuccess ? TypedResults.Ok(result.Value) : result.Error.ToProblem();

    public static IResult ToProblem(this Error error) =>
        TypedResults.Problem(
            statusCode: StatusCodeOf(error.Type),
            title: error.Message,
            type: $"https://gway.app/errors/{error.Code}",
            extensions: new Dictionary<string, object?> { ["code"] = error.Code });

    public static int StatusCodeOf(ErrorType type) => type switch
    {
        ErrorType.Validation => StatusCodes.Status400BadRequest,
        ErrorType.Unauthorized => StatusCodes.Status401Unauthorized,
        ErrorType.Forbidden => StatusCodes.Status403Forbidden,
        ErrorType.NotFound => StatusCodes.Status404NotFound,
        ErrorType.Conflict => StatusCodes.Status409Conflict,
        ErrorType.RuleViolation => StatusCodes.Status422UnprocessableEntity,
        ErrorType.Unavailable => StatusCodes.Status503ServiceUnavailable,
        _ => throw new ArgumentOutOfRangeException(nameof(type), type, null),
    };
}
