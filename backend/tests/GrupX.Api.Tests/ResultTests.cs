using GrupX.SharedKernel;
using GrupX.SharedKernel.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace GrupX.Api.Tests;

public sealed class ResultTests
{
    [Fact]
    public void Success_has_value()
    {
        Result<int> result = 42;

        Assert.True(result.IsSuccess);
        Assert.Equal(42, result.Value);
    }

    [Fact]
    public void Failure_value_access_throws()
    {
        Result<int> result = Error.NotFound("group.not_found", "Grup bulunamadı.");

        Assert.False(result.IsSuccess);
        Assert.Throws<InvalidOperationException>(() => result.Value);
    }

    [Theory]
    [InlineData(ErrorType.Validation, StatusCodes.Status400BadRequest)]
    [InlineData(ErrorType.Unauthorized, StatusCodes.Status401Unauthorized)]
    [InlineData(ErrorType.Forbidden, StatusCodes.Status403Forbidden)]
    [InlineData(ErrorType.NotFound, StatusCodes.Status404NotFound)]
    [InlineData(ErrorType.Conflict, StatusCodes.Status409Conflict)]
    [InlineData(ErrorType.RuleViolation, StatusCodes.Status422UnprocessableEntity)]
    public void Error_types_map_to_status_codes(ErrorType type, int expected)
    {
        var http = Result.Failure(new Error("x.y", "Mesaj", type)).ToHttpResult();

        var problem = Assert.IsType<ProblemHttpResult>(http);
        Assert.Equal(expected, problem.StatusCode);
    }

    [Fact]
    public void Problem_details_carry_code_and_safe_message()
    {
        Result<int> result = Error.RuleViolation("group.member_limit_reached", "Grup üye limitine ulaştı.");

        var problem = Assert.IsType<ProblemHttpResult>(result.ToHttpResult());

        Assert.IsType<ProblemDetails>(problem.ProblemDetails);
        Assert.Equal("Grup üye limitine ulaştı.", problem.ProblemDetails.Title);
        Assert.Equal("group.member_limit_reached", problem.ProblemDetails.Extensions["code"]);
    }

    [Fact]
    public void Success_without_value_is_204()
    {
        Assert.IsType<NoContent>(Result.Success().ToHttpResult());
    }

    [Fact]
    public void Success_with_value_is_200()
    {
        Result<string> result = "ok";

        var ok = Assert.IsType<Ok<string>>(result.ToHttpResult());
        Assert.Equal("ok", ok.Value);
    }
}
