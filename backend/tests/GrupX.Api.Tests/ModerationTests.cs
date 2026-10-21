using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Groups;
using GrupX.Modules.Live;
using GrupX.Modules.Moderation;
using Microsoft.Extensions.DependencyInjection;

namespace GrupX.Api.Tests;

/// <summary>Runs after <see cref="LiveTests"/>, whose monitor runs would end this class's broadcasts.</summary>
[Collection("Live rooms")]
public sealed class ModerationTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>Owner, two Disiplin Kurulu members, a Moderatör, the person who misbehaves and a reporter.</summary>
    private sealed record Crew(Guid Group, Guid Owner, Guid Board1, Guid Board2, Guid Moderator, Guid Offender, Guid Reporter);

    private async Task<Crew> CrewAsync(bool board = true)
    {
        var people = new Guid[6];
        for (var i = 0; i < people.Length; i++) people[i] = await _db.CreateUserAsync(Unique("m_"));
        var (owner, board1, board2, moderator, offender, reporter) = (people[0], people[1], people[2], people[3], people[4], people[5]);
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Koşu Kulübü", "running", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        foreach (var user in people[1..])
            (await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        if (board)
        {
            await RoleAsync(board1, "discipline");
            await RoleAsync(board2, "discipline");
        }
        await RoleAsync(moderator, "moderator");
        return new Crew(group, owner, board1, board2, moderator, offender, reporter);

        async Task RoleAsync(Guid user, string role) =>
            (await factory.ClientFor(owner).PutAsync(Path($"/groups/{group}/members/{user}/roles/{role}"), null, Ct)).EnsureSuccessStatusCode();
    }

    /// <summary>A client's own write through Supabase: the triggers see the user as the actor.</summary>
    private Task AsUserAsync(Guid user, string sql, params (string, object)[] parameters) =>
        _db.ExecuteAsync($"select set_config('request.jwt.claims', json_build_object('sub', @actor::text)::text, true); {sql}",
            [("actor", user), .. parameters]);

    private async Task<Guid> ReportCommentAsync(Crew crew)
    {
        var (post, comment) = (Guid.NewGuid(), Guid.NewGuid());
        await AsUserAsync(crew.Owner, "insert into public.posts (id, author_id, group_id, caption) values (@p, @actor, @g, 'Pazar koşusu')",
            ("p", post), ("g", crew.Group));
        await AsUserAsync(crew.Offender, "insert into public.comments (id, post_id, author_id, body) values (@c, @p, @actor, 'Kaba bir yorum')",
            ("c", comment), ("p", post));
        await AsUserAsync(crew.Reporter,
            "insert into public.reports (reporter_id, target_type, target_id, reason) values (@actor, 'comment', @c, 'harassment')",
            ("c", comment.ToString()));
        return (await _db.ScalarAsync<Guid>("select id from public.reports where target_id = @c", ("c", comment.ToString())))!;
    }

    private async Task<HttpResponseMessage> OpenCaseAsync(Guid actor, Crew crew, OpenCaseRequest request) =>
        await factory.ClientFor(actor).PostAsJsonAsync(Path($"/groups/{crew.Group}/cases"), request, Ct);

    private async Task<Guid> CaseAsync(Guid actor, Crew crew, OpenCaseRequest request)
    {
        var response = await OpenCaseAsync(actor, crew, request);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreatedCase>(Ct))!.Id;
    }

    private async Task<CaseVoteResult?> VoteAsync(Guid voter, Guid caseId, bool approve)
    {
        var response = await factory.ClientFor(voter).PutAsJsonAsync(Path($"/cases/{caseId}/vote"), new CaseVoteRequest(approve), Ct);
        return response.IsSuccessStatusCode ? await response.Content.ReadFromJsonAsync<CaseVoteResult>(Ct) : null;
    }

    private Task<long> CountAsync(string sql, params (string, object)[] p) => _db.ScalarAsync<long>(sql, p);

    [Fact]
    public async Task Reviewers_dismiss_reports_and_remove_reported_comments()
    {
        var crew = await CrewAsync();
        var report = await ReportCommentAsync(crew);

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Reporter).PostAsync(Path($"/reports/{report}/dismissal"), null, Ct)).StatusCode);
        var removal = await factory.ClientFor(crew.Moderator).PostAsJsonAsync(
            Path($"/reports/{report}/removal"), new RemoveReportedRequest("Hakaret içeriyor"), Ct);
        Assert.Equal(HttpStatusCode.NoContent, removal.StatusCode);

        Assert.Equal("actioned", await _db.ScalarAsync<string>("select status from public.reports where id = @r", ("r", report)));
        Assert.Equal(1L, await CountAsync(
            "select count(*) from public.comments c join public.reports r on r.target_id = c.id::text where r.id = @r and c.removed_at is not null",
            ("r", report)));
        Assert.Equal(HttpStatusCode.Conflict,
            (await factory.ClientFor(crew.Moderator).PostAsync(Path($"/reports/{report}/dismissal"), null, Ct)).StatusCode);
        Assert.Equal(1L, await CountAsync("select count(*) from public.audit_log where action = 'report.content_removed' and group_id = @g",
            ("g", crew.Group)));
    }

    [Fact]
    public async Task The_board_votes_a_ban_and_the_emergency_mute_ends()
    {
        var crew = await CrewAsync();
        var report = await ReportCommentAsync(crew);
        var live = await factory.ClientFor(crew.Owner).PostAsJsonAsync(Path($"/groups/{crew.Group}/live"), new StartLiveRequest("Akşam sohbeti", null), Ct);
        var room = (await live.Content.ReadFromJsonAsync<LiveCreated>(Ct))!.Id;
        factory.LiveKit.Join(room, crew.Offender, "speaker");

        var ban = new OpenCaseRequest(crew.Offender, "ban", 7, "Üyelere tekrar tekrar hakaret etti.", report, MuteNow: true);
        Assert.Equal(HttpStatusCode.Forbidden, (await OpenCaseAsync(crew.Reporter, crew, ban)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await OpenCaseAsync(crew.Moderator, crew, ban with { DurationDays = 900 })).StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await OpenCaseAsync(crew.Moderator, crew, ban with { SubjectId = crew.Board1, ReportId = null })).StatusCode);

        var caseId = await CaseAsync(crew.Moderator, crew, ban);
        Assert.Equal(HttpStatusCode.Conflict, (await OpenCaseAsync(crew.Moderator, crew, ban with { ReportId = null })).StatusCode);
        Assert.Equal("actioned", await _db.ScalarAsync<string>("select status from public.reports where id = @r", ("r", report)));
        Assert.True(await _db.ScalarAsync<bool>("select private.is_group_muted(@g, @u)", ("g", crew.Group), ("u", crew.Offender)));
        var inRoom = factory.LiveKit.Find(room, crew.Offender)!;
        Assert.False(inRoom.CanPublish);
        Assert.Equal("1", inRoom.Attributes["muted"]);

        Assert.Null(await VoteAsync(crew.Moderator, caseId, approve: true));
        Assert.Equal("voting", (await VoteAsync(crew.Board1, caseId, approve: true))!.Status);
        Assert.Equal("approved", (await VoteAsync(crew.Board2, caseId, approve: true))!.Status);
        Assert.Null(await VoteAsync(crew.Board1, caseId, approve: false));

        Assert.Equal(0L, await CountAsync("select count(*) from public.group_members where group_id = @g and user_id = @u",
            ("g", crew.Group), ("u", crew.Offender)));
        Assert.False(await _db.ScalarAsync<bool>("select private.is_group_muted(@g, @u)", ("g", crew.Group), ("u", crew.Offender)));
        Assert.Contains((room.ToString(), crew.Offender.ToString()), factory.LiveKit.Removed);
        var rejoin = await factory.ClientFor(crew.Offender).PostAsync(Path($"/groups/{crew.Group}/join"), null, Ct);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, rejoin.StatusCode);
        Assert.Contains("group.banned", await rejoin.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.Equal(2L, await CountAsync("select count(*) from public.notifications where type = 'sanction_applied' and recipient_id = @u",
            ("u", crew.Offender)));
        Assert.Equal(1L, await CountAsync("select count(*) from public.audit_log where action = 'case.decided' and group_id = @g", ("g", crew.Group)));
    }

    [Fact]
    public async Task Appeals_go_to_the_owner_unless_the_owner_took_part()
    {
        var crew = await CrewAsync();
        var caseId = await CaseAsync(crew.Moderator, crew, new OpenCaseRequest(crew.Offender, "mute", 3, "Yorumlarda hakaret etti.", null, false));
        await VoteAsync(crew.Board1, caseId, approve: true);
        await VoteAsync(crew.Board2, caseId, approve: true);
        var sanction = (await _db.ScalarAsync<Guid>("select id from public.sanctions where case_id = @c", ("c", caseId)))!;
        await AsUserAsync(crew.Offender, "insert into public.sanction_appeals (sanction_id, user_id, body) values (@s, @actor, 'Yanlış anlaşıldım, özür dilerim.')",
            ("s", sanction));
        var appeal = (await _db.ScalarAsync<Guid>("select id from public.sanction_appeals where sanction_id = @s", ("s", sanction)))!;

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Board1).PostAsJsonAsync(
            Path($"/appeals/{appeal}/decision"), new AppealDecisionRequest(true, null), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Owner).PostAsJsonAsync(
            Path($"/appeals/{appeal}/decision"), new AppealDecisionRequest(true, "İkinci şans"), Ct)).StatusCode);
        Assert.False(await _db.ScalarAsync<bool>("select private.is_group_muted(@g, @u)", ("g", crew.Group), ("u", crew.Offender)));

        // The owner opened this one: the platform team decides the appeal.
        var warning = await CaseAsync(crew.Owner, crew, new OpenCaseRequest(crew.Reporter, "warning", null, "Kurallara uymadı.", null, false));
        await VoteAsync(crew.Board1, warning, approve: true);
        await VoteAsync(crew.Board2, warning, approve: true);
        var warned = (await _db.ScalarAsync<Guid>("select id from public.sanctions where case_id = @c", ("c", warning)))!;
        await AsUserAsync(crew.Reporter, "insert into public.sanction_appeals (sanction_id, user_id, body) values (@s, @actor, 'Uyarıyı hak etmedim.')",
            ("s", warned));
        var platformAppeal = (await _db.ScalarAsync<Guid>("select id from public.sanction_appeals where sanction_id = @s", ("s", warned)))!;
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Owner).PostAsJsonAsync(
            Path($"/appeals/{platformAppeal}/decision"), new AppealDecisionRequest(true, null), Ct)).StatusCode);

        var staff = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(staff, "moderator");
        var appeals = await factory.ClientFor(staff).GetFromJsonAsync<PagedResult<AdminAppeal>>(Path("/admin/appeals?status=pending"), Ct);
        Assert.Contains(appeals!.Items, a => a.Id == platformAppeal);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(staff).PostAsJsonAsync(
            Path($"/admin/appeals/{platformAppeal}/decision"), new AdminAppealDecision(false, "Uyarı yerinde"), Ct)).StatusCode);
        Assert.Equal("upheld", await _db.ScalarAsync<string>("select status from public.sanction_appeals where id = @a", ("a", platformAppeal)));
    }

    [Fact]
    public async Task Without_a_board_the_owner_decides_and_due_cases_close_on_the_votes_cast()
    {
        var crew = await CrewAsync(board: false);
        var kick = await CaseAsync(crew.Moderator, crew, new OpenCaseRequest(crew.Offender, "kick", null, "Grubu rahatsız ediyor.", null, false));
        Assert.Null(await VoteAsync(crew.Board1, kick, approve: true));
        Assert.Equal("approved", (await VoteAsync(crew.Owner, kick, approve: true))!.Status);
        Assert.Equal(0L, await CountAsync("select count(*) from public.group_members where group_id = @g and user_id = @u",
            ("g", crew.Group), ("u", crew.Offender)));
        // A kick is not a ban: the person may come back.
        (await factory.ClientFor(crew.Offender).PostAsync(Path($"/groups/{crew.Group}/join"), null, Ct)).EnsureSuccessStatusCode();

        var warning = await CaseAsync(crew.Moderator, crew, new OpenCaseRequest(crew.Reporter, "warning", null, "Kurallara uymadı.", null, false));
        await _db.ExecuteWithoutTriggersAsync("update public.moderation_cases set voting_ends_at = now() - interval '1 minute' where id = @c", ("c", warning));
        await factory.Services.GetRequiredService<ModerationService>().DecideDueCasesAsync(Ct);
        Assert.Equal("rejected", await _db.ScalarAsync<string>("select status from public.moderation_cases where id = @c", ("c", warning)));
        Assert.Equal(0L, await CountAsync("select count(*) from public.sanctions where case_id = @c", ("c", warning)));
    }

    [Fact]
    public async Task The_platform_team_sees_and_closes_reports()
    {
        var crew = await CrewAsync();
        await AsUserAsync(crew.Reporter,
            "insert into public.reports (reporter_id, target_type, target_id, reason, note) values (@actor, 'user', @u, 'spam', 'Reklam yapıyor')",
            ("u", crew.Offender.ToString()));
        var report = (await _db.ScalarAsync<Guid>("select id from public.reports where reporter_id = @r and target_type = 'user'", ("r", crew.Reporter)))!;
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Owner).PostAsync(Path($"/reports/{report}/dismissal"), null, Ct)).StatusCode);

        var (support, moderator) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(support, "support");
        await _db.MakeStaffAsync(moderator, "moderator");
        var page = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminReport>>(Path("/admin/reports?scope=platform&status=open"), Ct);
        var row = Assert.Single(page!.Items, r => r.Id == report);
        Assert.Equal(crew.Offender, row.SubjectId);
        Assert.Equal("Reklam yapıyor", row.Note);

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).PostAsync(Path($"/admin/reports/{report}/resolution"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).PostAsync(Path($"/admin/reports/{report}/resolution"), null, Ct)).StatusCode);
        Assert.Equal("actioned", await _db.ScalarAsync<string>("select status from public.reports where id = @r", ("r", report)));
    }

    [Fact]
    public async Task Only_the_owner_sets_the_board_threshold()
    {
        var crew = await CrewAsync();
        var request = new CaseThresholdRequest("two_thirds");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Board1).PutAsJsonAsync(Path($"/groups/{crew.Group}/case-threshold"), request, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(crew.Owner).PutAsJsonAsync(Path($"/groups/{crew.Group}/case-threshold"), new CaseThresholdRequest("most"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(crew.Owner).PutAsJsonAsync(Path($"/groups/{crew.Group}/case-threshold"), request, Ct)).StatusCode);
        Assert.Equal("two_thirds", await _db.ScalarAsync<string>("select case_threshold from public.groups where id = @g", ("g", crew.Group)));
    }
}
