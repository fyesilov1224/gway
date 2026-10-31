namespace Gway.SharedKernel;

public enum ErrorType
{
    Validation,
    Unauthorized,
    Forbidden,
    NotFound,
    Conflict,
    RuleViolation,

    /// <summary>A dependency (e.g. a payment provider) cannot serve the request right now.</summary>
    Unavailable,
}

/// <summary>
/// An expected failure. <see cref="Code"/> is stable and machine-readable
/// (e.g. <c>group.member_limit_reached</c>); <see cref="Message"/> is safe to show to users.
/// </summary>
public sealed record Error(string Code, string Message, ErrorType Type)
{
    public static Error Validation(string code, string message) => new(code, message, ErrorType.Validation);

    public static Error Unauthorized(string code, string message) => new(code, message, ErrorType.Unauthorized);

    public static Error Forbidden(string code, string message) => new(code, message, ErrorType.Forbidden);

    public static Error NotFound(string code, string message) => new(code, message, ErrorType.NotFound);

    public static Error Conflict(string code, string message) => new(code, message, ErrorType.Conflict);

    public static Error RuleViolation(string code, string message) => new(code, message, ErrorType.RuleViolation);

    public static Error Unavailable(string code, string message) => new(code, message, ErrorType.Unavailable);
}
