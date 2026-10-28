using System.Net;
using System.Net.Http.Json;
using GrupX.Modules.Admin;
using GrupX.Modules.Events;
using GrupX.Modules.Feed;
using GrupX.Modules.Groups;
using Microsoft.Extensions.DependencyInjection;

namespace GrupX.Api.Tests;

public sealed class EventsTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public ValueTask DisposeAsync() => _db.DisposeAsync();

    private static string Unique(string prefix) => $"{prefix}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    /// <summary>Owner, Yönetici and two members of a fresh open group (free plan: two events a month).</summary>
    private sealed record Crew(Guid Group, Guid Owner, Guid Admin, Guid Member, Guid Other);

    private async Task<Crew> CrewAsync()
    {
        var (owner, admin, member, other) = (await User(), await User(), await User(), await User());
        var created = await factory.ClientFor(owner).PostAsJsonAsync(
            Path("/groups"), new CreateGroupRequest(Unique("g_"), "Doğa Yürüyüşü", "hiking", "open", null), Ct);
        var group = (await created.Content.ReadFromJsonAsync<CreatedGroup>(Ct))!.Id;
        foreach (var user in new[] { admin, member, other })
            (await factory.ClientFor(user).PostAsync(Path($"/groups/{group}/join"), null, Ct)).EnsureSuccessStatusCode();
        (await factory.ClientFor(owner).PutAsync(Path($"/groups/{group}/members/{admin}/roles/admin"), null, Ct)).EnsureSuccessStatusCode();
        return new Crew(group, owner, admin, member, other);

        Task<Guid> User() => _db.CreateUserAsync(Unique("e_"));
    }

    private static EventRequest Form(string title = "Belgrad Ormanı yürüyüşü", int? capacity = null, DateTimeOffset? startsAt = null,
        string? cover = null) =>
        new(title, "Sabah 9'da buluşuyoruz.", startsAt ?? DateTimeOffset.UtcNow.AddDays(2), null, "Bahçeköy girişi",
            "https://maps.example.com/bahcekoy", capacity, 15000, "TRY", "Yerinde nakit", cover);

    private async Task<HttpResponseMessage> CreateAsync(Guid actor, Guid group, EventRequest form) =>
        await factory.ClientFor(actor).PostAsJsonAsync(Path($"/groups/{group}/events"), form, Ct);

    private async Task<Guid> EventAsync(Crew crew, EventRequest form)
    {
        var response = await CreateAsync(crew.Admin, crew.Group, form);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreatedEvent>(Ct))!.Id;
    }

    private async Task<Attendance?> AttendAsync(Guid user, Guid ev)
    {
        var response = await factory.ClientFor(user).PostAsync(Path($"/events/{ev}/attendance"), null, Ct);
        return response.IsSuccessStatusCode ? await response.Content.ReadFromJsonAsync<Attendance>(Ct) : null;
    }

    private Task<long> CountAsync(string sql, params (string, object)[] p) => _db.ScalarAsync<long>(sql, p);

    // Events ----------------------------------------------------------------------------------

    [Fact]
    public async Task Managers_create_events_within_the_monthly_limit()
    {
        var crew = await CrewAsync();

        Assert.Equal(HttpStatusCode.Forbidden, (await CreateAsync(crew.Member, crew.Group, Form())).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await CreateAsync(crew.Admin, crew.Group, Form(title: "A"))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await CreateAsync(crew.Admin, crew.Group, Form(startsAt: DateTimeOffset.UtcNow.AddMinutes(5)))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await CreateAsync(crew.Admin, crew.Group, Form(cover: $"{crew.Group}/missing.jpg"))).StatusCode);

        var cover = $"{crew.Group}/{Guid.NewGuid()}.jpg";
        await _db.ExecuteAsync(
            "insert into storage.objects (bucket_id, name, metadata) values ('event-images', @p, '{\"mimetype\": \"image/jpeg\"}'::jsonb)", ("p", cover));
        await EventAsync(crew, Form(cover: cover));
        await EventAsync(crew, Form(title: "İkinci yürüyüş"));

        var third = await CreateAsync(crew.Owner, crew.Group, Form(title: "Üçüncü"));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, third.StatusCode);
        Assert.Contains("event.monthly_limit_reached", await third.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.Equal(2L, await CountAsync("select count(*) from public.audit_log where action = 'event.created' and group_id = @g", ("g", crew.Group)));
    }

    [Fact]
    public async Task A_full_event_has_a_waitlist_that_moves_up()
    {
        var crew = await CrewAsync();
        var outsider = await _db.CreateUserAsync(Unique("o_"));
        var ev = await EventAsync(crew, Form(capacity: 1));

        Assert.Equal(new Attendance("going", null), await AttendAsync(crew.Member, ev));
        Assert.Equal(new Attendance("waitlisted", 1), await AttendAsync(crew.Other, ev));
        Assert.Null(await AttendAsync(outsider, ev));

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Member).DeleteAsync(Path($"/events/{ev}/attendance"), Ct)).StatusCode);
        Assert.Equal("going", await _db.ScalarAsync<string>(
            "select status from public.event_attendees where event_id = @e and user_id = @u", ("e", ev), ("u", crew.Other)));
        Assert.Equal(1L, await CountAsync(
            "select count(*) from public.notifications where recipient_id = @u and type = 'event_promoted'", ("u", crew.Other)));
    }

    [Fact]
    public async Task Edits_keep_the_people_going_and_announce_a_new_time()
    {
        var crew = await CrewAsync();
        var oldCover = $"{crew.Group}/{Guid.NewGuid()}.jpg";
        var newCover = $"{crew.Group}/{Guid.NewGuid()}.png";
        foreach (var c in new[] { oldCover, newCover })
            await _db.ExecuteAsync("insert into storage.objects (bucket_id, name, metadata) values ('event-images', @p, '{\"mimetype\": \"image/png\"}'::jsonb)", ("p", c));
        var start = DateTimeOffset.UtcNow.AddDays(2);
        var ev = await EventAsync(crew, Form(capacity: 2, startsAt: start, cover: oldCover));
        await AttendAsync(crew.Member, ev);
        await AttendAsync(crew.Other, ev);

        var admin = factory.ClientFor(crew.Admin);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await admin.PutAsJsonAsync(Path($"/events/{ev}"), Form(capacity: 1, startsAt: start, cover: oldCover), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Member).PutAsJsonAsync(Path($"/events/{ev}"), Form(startsAt: start), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await admin.PutAsJsonAsync(Path($"/events/{ev}"), Form(capacity: 5, startsAt: start.AddDays(1), cover: newCover), Ct)).StatusCode);

        Assert.Equal(2L, await CountAsync("select count(*) from public.notifications where event_id = @e and type = 'event_updated'", ("e", ev)));
        Assert.Contains(("event-images", oldCover), factory.Storage.DeletedObjects);
    }

    [Fact]
    public async Task Cancellations_close_the_event_and_staff_can_cancel_too()
    {
        var crew = await CrewAsync();
        var (moderator, support) = (await _db.CreateUserAsync(Unique("s_")), await _db.CreateUserAsync(Unique("s_")));
        await _db.MakeStaffAsync(moderator, "moderator");
        await _db.MakeStaffAsync(support, "support");
        var first = await EventAsync(crew, Form());
        var second = await EventAsync(crew, Form(title: "Gece yürüyüşü"));
        await AttendAsync(crew.Member, first);

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Member).PostAsJsonAsync(Path($"/events/{first}/cancellation"), new CancelEventRequest("Hava kötü"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/events/{first}/cancellation"), new CancelEventRequest("Hava kötü"), Ct)).StatusCode);
        Assert.Equal(1L, await CountAsync("select count(*) from public.notifications where event_id = @e and type = 'event_canceled'", ("e", first)));
        Assert.Null(await AttendAsync(crew.Other, first));

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(support).PostAsJsonAsync(Path($"/admin/events/{second}/cancellation"), new CancelAdminEventRequest("Spam"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(moderator).PostAsJsonAsync(Path($"/admin/events/{second}/cancellation"), new CancelAdminEventRequest("Dolandırıcılık şüphesi"), Ct)).StatusCode);
        Assert.Equal(1L, await CountAsync("select count(*) from public.audit_log where action = 'event.canceled_by_admin' and group_id = @g", ("g", crew.Group)));

        var page = await factory.ClientFor(support).GetFromJsonAsync<PagedResult<AdminEvent>>(Path($"/admin/events?status=canceled&q={Uri.EscapeDataString("Gece")}"), Ct);
        Assert.Contains(page!.Items, e => e.Id == second && e.CancelReason == "Dolandırıcılık şüphesi");
    }

    [Fact]
    public async Task Reminders_go_once_to_the_people_going()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form(startsAt: DateTimeOffset.UtcNow.AddMinutes(30)));
        await AttendAsync(crew.Member, ev);
        var events = factory.Services.GetRequiredService<EventService>();

        await events.SendRemindersAsync(Ct);
        await events.SendRemindersAsync(Ct);

        Assert.Equal(1L, await CountAsync(
            "select count(*) from public.notifications where event_id = @e and recipient_id = @u and type = 'event_reminder'", ("e", ev), ("u", crew.Member)));
    }

    // Approval and the calendar file (Faz 8) -------------------------------------------------

    [Fact]
    public async Task Approval_events_take_requests_that_managers_decide()
    {
        var crew = await CrewAsync();
        Assert.Equal(HttpStatusCode.BadRequest,
            (await CreateAsync(crew.Admin, crew.Group, Form() with { Equipment = ["Kask", ""] })).StatusCode);
        var ev = await EventAsync(crew, Form(capacity: 1) with
        {
            Requirements = " En az 1 yıllık ehliyet ", Equipment = [" Kask ", "Mont"], ApprovalRequired = true,
        });
        Assert.Equal("En az 1 yıllık ehliyet", await _db.ScalarAsync<string>("select requirements from public.events where id = @e", ("e", ev)));

        Assert.Equal("requested", (await AttendAsync(crew.Member, ev))!.Status);
        Assert.Equal("requested", (await AttendAsync(crew.Other, ev))!.Status);
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Member).PostAsync(
            Path($"/events/{ev}/requests/{crew.Other}/approval"), null, Ct)).StatusCode);

        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Admin).PostAsync(
            Path($"/events/{ev}/requests/{crew.Member}/approval"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Admin).DeleteAsync(
            Path($"/events/{ev}/requests/{crew.Other}"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await factory.ClientFor(crew.Admin).DeleteAsync(
            Path($"/events/{ev}/requests/{crew.Other}"), Ct)).StatusCode);

        Assert.Equal("going", await _db.ScalarAsync<string>(
            "select status from public.event_attendees where event_id = @e and user_id = @u", ("e", ev), ("u", crew.Member)));
        Assert.Equal(1L, await CountAsync("select count(*) from public.notifications where type = 'event_declined' and recipient_id = @u",
            ("u", crew.Other)));
        Assert.Equal(2L, await CountAsync(
            "select count(*) from public.audit_log where action in ('event.attendee_approved', 'event.attendee_declined') and target_id = @e",
            ("e", ev.ToString())));
    }

    [Fact]
    public async Task Anyone_can_add_a_public_event_to_their_calendar()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form(title: "Pazar sabahı; uzun, keyifli bir yürüyüş"));

        using var visitor = factory.CreateClient();
        var response = await visitor.GetAsync(Path($"/events/{ev}/calendar.ics"), Ct);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("text/calendar", response.Content.Headers.ContentType!.MediaType);
        var ics = await response.Content.ReadAsStringAsync(Ct);
        Assert.StartsWith("BEGIN:VCALENDAR\r\n", ics, StringComparison.Ordinal);
        Assert.Contains($"UID:{ev}@grupx.app", ics, StringComparison.Ordinal);
        Assert.Contains(@"SUMMARY:Pazar sabahı\; uzun\, keyifli bir yürüyüş", ics, StringComparison.Ordinal);
        Assert.Contains("STATUS:CONFIRMED", ics, StringComparison.Ordinal);
        Assert.All(ics.Split("\r\n"), line => Assert.True(System.Text.Encoding.UTF8.GetByteCount(line) <= 75, line));

        Assert.Equal(HttpStatusCode.NotFound, (await visitor.GetAsync(Path($"/events/{Guid.NewGuid()}/calendar.ics"), Ct)).StatusCode);
    }

    // After the event (Faz 10) --------------------------------------------------------------

    [Fact]
    public async Task Attendees_share_memories_and_are_asked_for_a_review()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        await AttendAsync(crew.Member, ev);

        async Task<HttpStatusCode> MemoryAsync(Guid author)
        {
            var path = $"{author}/{Guid.NewGuid():N}.jpg";
            await _db.StoreMediaAsync(author, path, "image/jpeg");
            var post = new CreatePostRequest("Harika bir gündü", [new PostMediaInput("image", path, 1080, 1350, null, null, null)],
                null, false, false, ev);
            return (await factory.ClientFor(author).PostAsJsonAsync(Path("/posts"), post, Ct)).StatusCode;
        }

        Assert.Equal(HttpStatusCode.Forbidden, await MemoryAsync(crew.Member));
        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '3 hours' where id = @e", ("e", ev));
        Assert.Equal(HttpStatusCode.Forbidden, await MemoryAsync(crew.Other));
        Assert.Equal(HttpStatusCode.OK, await MemoryAsync(crew.Member));
        Assert.Equal(1L, await CountAsync("select count(*) from public.posts where event_id = @e", ("e", ev)));

        await factory.Services.GetRequiredService<EventService>().SendRemindersAsync(Ct);
        Assert.Equal(1L, await CountAsync("select count(*) from public.notifications where type = 'event_review' and recipient_id = @u and event_id = @e",
            ("u", crew.Member), ("e", ev)));
    }

    [Fact]
    public async Task Managers_take_the_roll_within_a_week_after_the_end()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        await AttendAsync(crew.Member, ev);
        var mark = Path($"/events/{ev}/no-shows/{crew.Member}");

        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(crew.Admin).PutAsync(mark, null, Ct)).StatusCode);
        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '1 day' where id = @e", ("e", ev));
        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Other).PutAsync(mark, null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Admin).PutAsync(mark, null, Ct)).StatusCode);
        Assert.Equal(0, await _db.ScalarAsync<int>("select (private.contribution_counts(@u, null)->>'attended')::int", ("u", crew.Member)));
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Admin).DeleteAsync(mark, Ct)).StatusCode);
        Assert.Equal(1, await _db.ScalarAsync<int>("select (private.contribution_counts(@u, null)->>'attended')::int", ("u", crew.Member)));
        Assert.Equal(2L, await CountAsync(
            "select count(*) from public.audit_log where action in ('event.no_show_marked', 'event.no_show_cleared') and target_id = @e",
            ("e", ev.ToString())));

        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '10 days' where id = @e", ("e", ev));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await factory.ClientFor(crew.Admin).PutAsync(mark, null, Ct)).StatusCode);
    }

    // Goals (Faz 12) ---------------------------------------------------------------------------

    private static GoalRequest Goal(string kind, string? metric = "attended", int? target = 1, string title = "Ekim yürüyüşleri") =>
        new(title, "Bu ay birlikte yürüyelim.", kind, metric, target, DateTimeOffset.UtcNow.AddDays(-5), DateTimeOffset.UtcNow.AddDays(20));

    private async Task<Guid> GoalAsync(Crew crew, GoalRequest goal)
    {
        var response = await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/groups/{crew.Group}/goals"), goal, Ct);
        response.EnsureSuccessStatusCode();
        return (await response.Content.ReadFromJsonAsync<CreatedGoal>(Ct))!.Id;
    }

    [Fact]
    public async Task Managers_open_goals_that_complete_from_real_attendance()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        await AttendAsync(crew.Member, ev);
        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '1 day' where id = @e", ("e", ev));

        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Member).PostAsJsonAsync(Path($"/groups/{crew.Group}/goals"), Goal("personal"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/groups/{crew.Group}/goals"), Goal("task"), Ct)).StatusCode);
        var personal = await GoalAsync(crew, Goal("personal"));
        var team = await GoalAsync(crew, Goal("team", target: 1, title: "Takım yarışı"));
        var task = await GoalAsync(crew, Goal("task", metric: null, target: null, title: "Yeni üyeye rota anlat"));

        var teams = Path($"/goals/{team}/teams");
        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(crew.Admin).PostAsJsonAsync(
            teams, new TeamRequest("Kuzey", [crew.Member, Guid.NewGuid()]), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await factory.ClientFor(crew.Admin).PostAsJsonAsync(teams, new TeamRequest("Kuzey", [crew.Member]), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await factory.ClientFor(crew.Admin).PostAsJsonAsync(
            teams, new TeamRequest("Güney", [crew.Member]), Ct)).StatusCode);

        await _db.ExecuteAsync(
            "select set_config('request.jwt.claims', json_build_object('sub', @u::text)::text, true); insert into public.goal_claims (goal_id, user_id) values (@g, @u)",
            ("u", crew.Other), ("g", task));
        Assert.Equal(HttpStatusCode.Forbidden,
            (await factory.ClientFor(crew.Member).PostAsync(Path($"/goals/{task}/claims/{crew.Other}/approval"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent,
            (await factory.ClientFor(crew.Admin).PostAsync(Path($"/goals/{task}/claims/{crew.Other}/approval"), null, Ct)).StatusCode);

        await factory.Services.GetRequiredService<EventService>().SendRemindersAsync(Ct);
        Assert.Equal(1L, await CountAsync("select count(*) from public.goal_completions where goal_id = @g and user_id = @u", ("g", personal), ("u", crew.Member)));
        Assert.Equal(1L, await CountAsync("select count(*) from public.goal_completions where goal_id = @g and user_id = @u", ("g", team), ("u", crew.Member)));
        Assert.Equal(1L, await CountAsync("select count(*) from public.goal_completions where goal_id = @g and user_id = @u", ("g", task), ("u", crew.Other)));
        Assert.Equal(3L, await CountAsync("select count(*) from public.notifications where type = 'goal_completed' and group_id = @g", ("g", crew.Group)));

        var staff = await _db.CreateUserAsync(Unique("s_"));
        await _db.MakeStaffAsync(staff, "moderator");
        var goals = await factory.ClientFor(staff).GetFromJsonAsync<PagedResult<AdminGoal>>(Path("/admin/goals?status=running"), Ct);
        Assert.Contains(goals!.Items, g => g.Id == personal && g.Completions == 1);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(staff).PostAsync(Path($"/admin/goals/{personal}/cancellation"), null, Ct)).StatusCode);
        Assert.Equal(1L, await CountAsync("select count(*) from public.audit_log where action = 'goal.canceled_by_admin' and target_id = @g", ("g", personal.ToString())));
    }

    // Polls -----------------------------------------------------------------------------------

    [Fact]
    public async Task Managers_open_close_and_delete_polls()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        var poll = new CreatePollRequest("Hangi gün?", ["Cumartesi", "Pazar"], AllowsMultiple: false, IsAnonymous: true,
            DateTimeOffset.UtcNow.AddDays(1), ev);

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Member).PostAsJsonAsync(Path($"/groups/{crew.Group}/polls"), poll, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/groups/{crew.Group}/polls"), poll with { Options = ["Tek"] }, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/groups/{crew.Group}/polls"), poll with { Options = ["Pazar", "pazar"] }, Ct)).StatusCode);

        var created = await factory.ClientFor(crew.Admin).PostAsJsonAsync(Path($"/groups/{crew.Group}/polls"), poll, Ct);
        var id = (await created.Content.ReadFromJsonAsync<CreatedPoll>(Ct))!.Id;
        Assert.Equal(2L, await CountAsync("select count(*) from public.poll_options where poll_id = @p", ("p", id)));

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(crew.Member).PostAsync(Path($"/polls/{id}/close"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Admin).PostAsync(Path($"/polls/{id}/close"), null, Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await factory.ClientFor(crew.Owner).DeleteAsync(Path($"/polls/{id}"), Ct)).StatusCode);
        Assert.Equal(0L, await CountAsync("select count(*) from public.polls where id = @p", ("p", id)));
        Assert.Equal(3L, await CountAsync(
            "select count(*) from public.audit_log where action in ('poll.created', 'poll.closed', 'poll.deleted') and target_id = @p", ("p", id.ToString())));
    }

    // Welcome ---------------------------------------------------------------------------------

    [Fact]
    public async Task A_first_timer_is_greeted_and_thanks_the_greeter()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @a)::text, true);
            insert into public.group_greeters (group_id, user_id) values (@g, @a);
            """, ("a", crew.Admin), ("g", crew.Group));
        foreach (var user in new[] { crew.Admin, crew.Member, crew.Other })
            Assert.NotNull(await AttendAsync(user, ev));
        var newcomer = factory.ClientFor(crew.Member);
        var greeter = factory.ClientFor(crew.Admin);

        var asked = await newcomer.PostAsJsonAsync(Path($"/events/{ev}/welcome"), new WelcomeRequest("Mavi çantalıyım"), Ct);
        var askedAgain = await newcomer.PostAsJsonAsync(Path($"/events/{ev}/welcome"), new WelcomeRequest(null), Ct);
        var notGreeter = await factory.ClientFor(crew.Other).PutAsJsonAsync(
            Path($"/events/{ev}/welcome/{crew.Member}/greeter"), new WelcomeTakeRequest("Girişte"), Ct);
        var shortNote = await greeter.PutAsJsonAsync(Path($"/events/{ev}/welcome/{crew.Member}/greeter"), new WelcomeTakeRequest("A"), Ct);
        var taken = await greeter.PutAsJsonAsync(
            Path($"/events/{ev}/welcome/{crew.Member}/greeter"), new WelcomeTakeRequest("Girişteki kafe, 08:45"), Ct);
        var earlyThanks = await newcomer.PostAsync(Path($"/events/{ev}/welcome/thanks"), null, Ct);

        Assert.Equal(HttpStatusCode.NoContent, asked.StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, askedAgain.StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, notGreeter.StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, shortNote.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, taken.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, earlyThanks.StatusCode);
        Assert.Equal(1L, await CountAsync(
            "select count(*) from public.notifications where recipient_id = @u and type = 'welcome_matched'", ("u", crew.Member)));

        await _db.ExecuteWithoutTriggersAsync("update public.events set starts_at = now() - interval '1 day' where id = @e", ("e", ev));
        var thanks = await newcomer.PostAsync(Path($"/events/{ev}/welcome/thanks"), null, Ct);
        var thanksAgain = await newcomer.PostAsync(Path($"/events/{ev}/welcome/thanks"), null, Ct);
        var lateRelease = await greeter.DeleteAsync(Path($"/events/{ev}/welcome/{crew.Member}/greeter"), Ct);

        Assert.Equal(HttpStatusCode.NoContent, thanks.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, thanksAgain.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, lateRelease.StatusCode);
        Assert.Equal(1L, await CountAsync(
            "select (private.contribution_counts(@u, null)->>'welcomed')::bigint", ("u", crew.Admin)));
    }

    [Fact]
    public async Task A_greeter_who_steps_back_reopens_the_request()
    {
        var crew = await CrewAsync();
        var ev = await EventAsync(crew, Form());
        await _db.ExecuteAsync(
            """
            select set_config('request.jwt.claims', json_build_object('sub', @a)::text, true);
            insert into public.group_greeters (group_id, user_id) values (@g, @a);
            """, ("a", crew.Admin), ("g", crew.Group));
        Assert.NotNull(await AttendAsync(crew.Admin, ev));
        Assert.NotNull(await AttendAsync(crew.Member, ev));
        var greeter = factory.ClientFor(crew.Admin);
        (await factory.ClientFor(crew.Member).PostAsJsonAsync(Path($"/events/{ev}/welcome"), new WelcomeRequest(null), Ct)).EnsureSuccessStatusCode();
        (await greeter.PutAsJsonAsync(Path($"/events/{ev}/welcome/{crew.Member}/greeter"), new WelcomeTakeRequest("Otoparkta"), Ct))
            .EnsureSuccessStatusCode();

        var released = await greeter.DeleteAsync(Path($"/events/{ev}/welcome/{crew.Member}/greeter"), Ct);
        var releasedAgain = await greeter.DeleteAsync(Path($"/events/{ev}/welcome/{crew.Member}/greeter"), Ct);
        var withdrawn = await factory.ClientFor(crew.Member).DeleteAsync(Path($"/events/{ev}/welcome"), Ct);

        Assert.Equal(HttpStatusCode.NoContent, released.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, releasedAgain.StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, withdrawn.StatusCode);
        Assert.Equal(1L, await CountAsync(
            "select count(*) from public.notifications where recipient_id = @u and type = 'welcome_released'", ("u", crew.Member)));
        Assert.Equal(0L, await CountAsync("select count(*) from public.event_welcomes where event_id = @e", ("e", ev)));
    }
}
