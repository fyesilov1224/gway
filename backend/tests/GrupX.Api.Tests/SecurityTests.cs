using System.Net;
using System.Net.Http.Json;
using System.Security.Cryptography;
using GrupX.Modules.Identity;
using GrupX.Modules.Identity.Contracts;
using Microsoft.Extensions.DependencyInjection;

namespace GrupX.Api.Tests;

/// <summary>Security verification (docs/ARCHITECTURE.md §3h). One collection: the enforcement switch is global.</summary>
[Collection("Security")]
public sealed class SecurityTests(ApiFactory factory) : IClassFixture<ApiFactory>, IAsyncLifetime
{
    private readonly TestDatabase _db = new();
    private static CancellationToken Ct => TestContext.Current.CancellationToken;

    private static readonly (double Lat, double Lon) Istanbul = (41.0082, 28.9784);
    private static readonly (double Lat, double Lon) Berlin = (52.52, 13.405);

    public ValueTask InitializeAsync() => _db.InitializeAsync();

    public async ValueTask DisposeAsync()
    {
        await _db.ExecuteAsync("update public.security_settings set enforce = false");
        await _db.DisposeAsync();
    }

    private static string Unique(string p) => $"{p}{Guid.NewGuid():N}"[..20];

    private static Uri Path(string path) => new(path, UriKind.Relative);

    private static string Digits(int n) => string.Concat(Enumerable.Range(0, n).Select(_ => RandomNumberGenerator.GetInt32(10)));

    private static string TrMobile() => "+90532" + Digits(7);

    private static string DeMobile() => "+49151" + Digits(8);

    private async Task<(Guid User, Guid Session, HttpClient Client)> NewUserAsync(string? role = null)
    {
        var user = await _db.CreateUserAsync(Unique("sec_"));
        if (role is not null) await _db.MakeStaffAsync(user, role);
        var session = await NewSessionAsync(user);
        return (user, session, factory.ClientFor(user, session));
    }

    private async Task<Guid> NewSessionAsync(Guid user)
    {
        var session = Guid.NewGuid();
        await _db.ExecuteAsync("insert into auth.sessions (id, user_id, created_at, updated_at) values (@s, @u, now(), now())",
            ("s", session), ("u", user));
        return session;
    }

    private static async Task<HttpResponseMessage> LocateAsync(
        HttpClient client, (double Lat, double Lon) at, string ipCountry = "TR", bool mocked = false, bool vpn = false, string? sim = null)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, Path("/security/location"))
        {
            Content = JsonContent.Create(new LocationSignals(at.Lat, at.Lon, 12, mocked, vpn, sim, "android")),
        };
        request.Headers.Add(ApiFactory.CountryHeader, ipCountry);
        return await client.SendAsync(request, Ct);
    }

    private static async Task<SecurityStatus> StatusAsync(HttpClient client) =>
        (await client.GetFromJsonAsync<SecurityStatus>(Path("/security/status"), Ct))!;

    /// <summary>Clean location in Türkiye, then a verified Turkish mobile number on this session.</summary>
    private async Task<string> VerifyPhoneAsync(HttpClient client)
    {
        (await LocateAsync(client, Istanbul)).EnsureSuccessStatusCode();
        var phone = TrMobile();
        Assert.Equal(HttpStatusCode.NoContent, (await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(phone), Ct)).StatusCode);
        (await client.PostAsJsonAsync(Path("/security/phone/verify"), new PhoneVerifyRequest(phone, FakeSms.Code), Ct)).EnsureSuccessStatusCode();
        return phone;
    }

    private Task<string?> AccountStatusAsync(Guid user) =>
        _db.ScalarAsync<string>("select status from public.account_status where user_id = @u", ("u", user));

    [Fact]
    public async Task An_unverified_session_reaches_only_the_security_steps()
    {
        var user = await _db.CreateUserAsync(Unique("sec_"));
        var unverified = factory.ClientFor(user, await NewSessionAsync(user), "unverified");

        Assert.Equal(HttpStatusCode.Forbidden, (await unverified.GetAsync(Path("/me"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await unverified.GetAsync(Path("/notifications"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await unverified.GetAsync(Path("/security/status"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await unverified.GetAsync(Path("/account"), Ct)).StatusCode);
    }

    [Fact]
    public async Task A_clean_check_locks_the_phone_to_the_country_and_verifies_the_session()
    {
        await _db.ExecuteAsync("update public.security_settings set enforce = true");
        var (user, _, client) = await NewUserAsync();

        Assert.Equal(SecuritySteps.Location, (await StatusAsync(client)).Step);

        var located = await (await LocateAsync(client, Istanbul)).Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.Equal("TR", located!.AllowedCountry);
        Assert.Equal(90, located.CallingCode);
        Assert.Equal(SecuritySteps.Phone, located.Step);

        // A landline is refused before any SMS; a wrong code does not verify.
        Assert.Equal(HttpStatusCode.BadRequest,
            (await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest("+902121234567"), Ct)).StatusCode);
        var phone = TrMobile();
        Assert.Equal(HttpStatusCode.NoContent, (await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(phone), Ct)).StatusCode);
        Assert.Contains(phone, factory.Sms.Sent);
        Assert.Equal(HttpStatusCode.BadRequest,
            (await client.PostAsJsonAsync(Path("/security/phone/verify"), new PhoneVerifyRequest(phone, "000000"), Ct)).StatusCode);

        var verified = await (await client.PostAsJsonAsync(Path("/security/phone/verify"), new PhoneVerifyRequest(phone, FakeSms.Code), Ct))
            .Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.True(verified!.SessionVerified);
        Assert.Equal(SecuritySteps.Done, verified.Step);
        Assert.EndsWith(phone[^2..], verified.PhoneMasked, StringComparison.Ordinal);

        // The hook would now issue `authenticated` for this session.
        var session = await _db.ScalarAsync<Guid>("select session_id from public.verified_sessions where user_id = @u", ("u", user));
        var claims = await _db.ScalarAsync<string>(
            "select private.custom_access_token_hook(jsonb_build_object('user_id', @u::text, 'claims', jsonb_build_object('role', 'authenticated', 'session_id', @s::text))) #>> '{claims,role}'",
            ("u", user), ("s", session));
        Assert.Equal("authenticated", claims);

        // One account per number.
        var (_, _, other) = await NewUserAsync();
        (await LocateAsync(other, Istanbul)).EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.Conflict, (await other.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(phone), Ct)).StatusCode);
    }

    [Fact]
    public async Task A_number_from_another_country_bans_and_blocks_the_number()
    {
        var (user, _, client) = await NewUserAsync();
        (await LocateAsync(client, Istanbul)).EnsureSuccessStatusCode();

        var foreign = DeMobile();
        var response = await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(foreign), Ct);
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        Assert.Contains("security.banned", await response.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
        Assert.DoesNotContain(foreign, factory.Sms.Sent);
        Assert.Equal("suspended", await AccountStatusAsync(user));
        Assert.Equal(foreign, await _db.ScalarAsync<string>("select phone from public.phone_bans where phone = @p", ("p", foreign)));
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'security.banned' and target_id = @u", ("u", user.ToString())));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from auth.sessions where user_id = @u", ("u", user)));
    }

    [Fact]
    public async Task A_mocked_location_bans_but_only_restricts_staff()
    {
        var (user, _, client) = await NewUserAsync();
        Assert.Equal(HttpStatusCode.Forbidden, (await LocateAsync(client, Istanbul, mocked: true)).StatusCode);
        Assert.Equal("suspended", await AccountStatusAsync(user));

        var (staff, _, staffClient) = await NewUserAsync("moderator");
        var status = await (await LocateAsync(staffClient, Istanbul, mocked: true)).Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.Equal("active", await AccountStatusAsync(staff));
        Assert.Equal("restricted", await _db.ScalarAsync<string>("select state from public.user_security where user_id = @u", ("u", staff)));
        Assert.Equal(SecuritySteps.Done, status!.Step); // enforcement is off in this test
    }

    [Fact]
    public async Task Uncertain_signals_restrict_until_staff_approve_with_an_exemption()
    {
        await _db.ExecuteAsync("update public.security_settings set enforce = true");
        var (user, _, client) = await NewUserAsync();

        // GPS in Germany, IP in Türkiye: restricted, the phone step is closed, a review is open.
        var status = await (await LocateAsync(client, Berlin, ipCountry: "TR")).Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.Equal(SecuritySteps.Restricted, status!.Step);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(DeMobile()), Ct)).StatusCode);

        // A VPN on the next check joins the same review.
        await LocateAsync(client, Berlin, ipCountry: "DE", vpn: true);
        var signals = await _db.ScalarAsync<string[]>("select signals from public.security_reviews where user_id = @u and status = 'open'", ("u", user));
        Assert.Equal(["ip_mismatch", "vpn"], signals!.Order().ToArray());

        var moderator = await _db.CreateUserAsync(Unique("mod_"));
        await _db.MakeStaffAsync(moderator, "moderator");
        var staff = factory.ClientFor(moderator);
        var reviews = await staff.GetFromJsonAsync<List<SecurityReviewItem>>(Path("/admin/security/reviews?status=open"), Ct);
        var review = reviews!.Single(r => r.UserId == user);
        Assert.Equal("DE", review.Check!.GpsCountry);

        Assert.Equal(HttpStatusCode.BadRequest, (await staff.PostAsJsonAsync(Path($"/admin/security/reviews/{review.Id}/approval"),
            new ReviewApprovalRequest(91, null), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await staff.PostAsJsonAsync(Path($"/admin/security/reviews/{review.Id}/approval"),
            new ReviewApprovalRequest(30, "Almanya'da yaşıyor"), Ct)).StatusCode);
        Assert.Equal(HttpStatusCode.Conflict, (await staff.PostAsJsonAsync(Path($"/admin/security/reviews/{review.Id}/ban"),
            new ReviewBanRequest(null), Ct)).StatusCode);

        // Exempt: the same signals no longer restrict, and the phone is locked to Germany now.
        var after = await (await LocateAsync(client, Berlin, ipCountry: "TR", vpn: true)).Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.Equal(SecuritySteps.Phone, after!.Step);
        Assert.Equal("DE", after.AllowedCountry);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'security.review_approved' and target_id = @u", ("u", user.ToString())));
    }

    [Fact]
    public async Task Staff_ban_a_reviewed_account_but_never_staff()
    {
        var (user, _, client) = await NewUserAsync();
        await LocateAsync(client, Istanbul, sim: "DE");
        var admin = await _db.CreateUserAsync(Unique("adm_"));
        await _db.MakeStaffAsync(admin, "admin");
        var staff = factory.ClientFor(admin);

        var review = (await staff.GetFromJsonAsync<List<SecurityReviewItem>>(Path("/admin/security/reviews?status=open"), Ct))!
            .Single(r => r.UserId == user);
        Assert.Equal(["sim_mismatch"], review.Signals);
        Assert.Equal(HttpStatusCode.NoContent,
            (await staff.PostAsJsonAsync(Path($"/admin/security/reviews/{review.Id}/ban"), new ReviewBanRequest("Sahte hesap"), Ct)).StatusCode);
        Assert.Equal("suspended", await AccountStatusAsync(user));

        var (_, _, modClient) = await NewUserAsync("moderator");
        await LocateAsync(modClient, Istanbul, vpn: true);
        var staffReview = (await staff.GetFromJsonAsync<List<SecurityReviewItem>>(Path("/admin/security/reviews?status=open"), Ct))!
            .Single(r => r.Signals.Contains("vpn") && r.Status == "open" && r.UserId != user);
        Assert.Equal(HttpStatusCode.UnprocessableEntity,
            (await staff.PostAsJsonAsync(Path($"/admin/security/reviews/{staffReview.Id}/ban"), new ReviewBanRequest(null), Ct)).StatusCode);

        // Support may look at a user's security, not at reviews.
        var supportUser = await _db.CreateUserAsync(Unique("sup_"));
        await _db.MakeStaffAsync(supportUser, "support");
        var support = factory.ClientFor(supportUser);
        Assert.Equal(HttpStatusCode.Forbidden, (await support.GetAsync(Path("/admin/security/reviews"), Ct)).StatusCode);
        var view = await support.GetFromJsonAsync<UserSecurityView>(Path($"/admin/users/{user}/security"), Ct);
        Assert.Equal("restricted", view!.State);
        Assert.Equal("DE", view.Checks[0].SimCountry);
    }

    [Fact]
    public async Task A_new_session_needs_the_second_factor_by_sms_or_authenticator()
    {
        await _db.ExecuteAsync("update public.security_settings set enforce = true");
        var (user, _, first) = await NewUserAsync();
        var phone = await VerifyPhoneAsync(first);

        // Authenticator setup from the verified session.
        var setup = await (await first.PostAsync(Path("/security/totp"), null, Ct)).Content.ReadFromJsonAsync<TotpSetup>(Ct);
        Assert.StartsWith("otpauth://totp/GrupX?secret=", setup!.Uri, StringComparison.Ordinal);
        var secret = await _db.ScalarAsync<byte[]>("select secret from public.totp_factors where user_id = @u", ("u", user));
        var now = DateTimeOffset.UtcNow;
        Assert.Equal(HttpStatusCode.NoContent, (await first.PostAsJsonAsync(Path("/security/totp/confirm"),
            new TotpCodeRequest(Totp.Code(secret!, Totp.StepAt(now))), Ct)).StatusCode);

        // Second login by SMS.
        var second = factory.ClientFor(user, await NewSessionAsync(user), "unverified");
        Assert.Equal(SecuritySteps.SecondFactor, (await StatusAsync(second)).Step);
        Assert.Equal(HttpStatusCode.NoContent, (await second.PostAsync(Path("/security/second-factor/start"), null, Ct)).StatusCode);
        Assert.Equal(phone, factory.Sms.Sent.Last());
        var bySms = await (await second.PostAsJsonAsync(Path("/security/second-factor/verify"), new SecondFactorRequest("sms", FakeSms.Code), Ct))
            .Content.ReadFromJsonAsync<SecurityStatus>(Ct);
        Assert.Equal(SecuritySteps.Done, bySms!.Step);

        // Third login by the next authenticator code; the same code cannot be used twice.
        var third = factory.ClientFor(user, await NewSessionAsync(user), "unverified");
        var code = Totp.Code(secret!, Totp.StepAt(now) + 1);
        Assert.Equal(HttpStatusCode.OK,
            (await third.PostAsJsonAsync(Path("/security/second-factor/verify"), new SecondFactorRequest("totp", code), Ct)).StatusCode);
        var fourth = factory.ClientFor(user, await NewSessionAsync(user), "unverified");
        Assert.Equal(HttpStatusCode.BadRequest,
            (await fourth.PostAsJsonAsync(Path("/security/second-factor/verify"), new SecondFactorRequest("totp", code), Ct)).StatusCode);
        Assert.Equal(3L, await _db.ScalarAsync<long>("select count(*) from public.verified_sessions where user_id = @u", ("u", user)));

        // A stale location closes the steps again (24 hours, as in the hook).
        await _db.ExecuteAsync("update public.user_security set location_checked_at = now() - interval '25 hours' where user_id = @u", ("u", user));
        Assert.Equal(SecuritySteps.Location, (await StatusAsync(first)).Step);
    }

    [Fact]
    public async Task Only_an_admin_switches_enforcement_and_it_is_audited()
    {
        var admin = await _db.CreateUserAsync(Unique("adm_"));
        await _db.MakeStaffAsync(admin, "admin");
        var moderator = await _db.CreateUserAsync(Unique("mod_"));
        await _db.MakeStaffAsync(moderator, "moderator");

        Assert.Equal(HttpStatusCode.Forbidden, (await factory.ClientFor(moderator).PutAsJsonAsync(Path("/admin/security/settings"),
            new SecuritySettingsRequest(true), Ct)).StatusCode);
        var settings = await (await factory.ClientFor(admin).PutAsJsonAsync(Path("/admin/security/settings"),
            new SecuritySettingsRequest(true), Ct)).Content.ReadFromJsonAsync<SecuritySettingsView>(Ct);
        Assert.True(settings!.Enforce);
        Assert.True(settings.SmsConfigured);
        Assert.Equal(1L, await _db.ScalarAsync<long>(
            "select count(*) from public.audit_log where action = 'security.enforce_changed' and actor_id = @a", ("a", admin)));
    }

    [Fact]
    public async Task Virtual_numbers_are_refused_after_lookup()
    {
        var (_, _, client) = await NewUserAsync();
        (await LocateAsync(client, Istanbul)).EnsureSuccessStatusCode();
        var voip = TrMobile();
        factory.Sms.VoipNumbers[voip] = true;
        var response = await client.PostAsJsonAsync(Path("/security/phone/start"), new PhoneStartRequest(voip), Ct);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("security.phone_not_mobile", await response.Content.ReadAsStringAsync(Ct), StringComparison.Ordinal);
    }

    [Fact]
    public async Task Old_checks_and_sends_are_purged_after_90_days()
    {
        var (user, _, _) = await NewUserAsync();
        await _db.ExecuteAsync(
            """
            insert into public.location_checks (user_id, checked_at, platform, is_mocked, vpn, verdict)
            values (@u, now() - interval '91 days', 'web', false, false, 'ok'), (@u, now(), 'web', false, false, 'ok');
            insert into public.sms_sends (user_id, phone, purpose, sent_at) values (@u, '+905320000000', 'phone', now() - interval '91 days');
            """, ("u", user));
        await factory.Services.GetRequiredService<SecurityService>().PurgeExpiredAsync(Ct);
        Assert.Equal(1L, await _db.ScalarAsync<long>("select count(*) from public.location_checks where user_id = @u", ("u", user)));
        Assert.Equal(0L, await _db.ScalarAsync<long>("select count(*) from public.sms_sends where user_id = @u", ("u", user)));
    }
}

public sealed class SecurityRulesTests
{
    [Theory]
    [InlineData(41.0082, 28.9784, "TR")] // İstanbul
    [InlineData(39.9334, 32.8597, "TR")] // Ankara
    [InlineData(52.52, 13.405, "DE")] // Berlin
    [InlineData(40.7128, -74.006, "US")] // New York
    [InlineData(41.0255, 28.9744, "TR")] // Haliç (Golden Horn): water at 1:50m, near the coast
    [InlineData(38.4237, 27.1428, "TR")] // İzmir
    [InlineData(34.6786, 33.0413, "CY")] // Limassol
    [InlineData(35.3364, 33.3199, "TR")] // Girne: KKTC uses +90 numbers, so it counts as TR here
    [InlineData(30.0, -40.0, null)] // Atlantic
    public void Coordinates_map_to_countries(double lat, double lon, string? expected) =>
        Assert.Equal(expected, CountryLocator.Load().CountryAt(lat, lon));

    [Theory]
    [InlineData("+90 532 123 45 67", "TR", "+905321234567", "TR")]
    [InlineData("0532 123 45 67", "TR", "+905321234567", "TR")]
    [InlineData("+49 151 23456789", "TR", "+4915123456789", "DE")]
    public void Mobile_numbers_parse_with_their_country(string input, string defaultCountry, string e164, string country)
    {
        var parsed = PhoneRules.Parse(input, defaultCountry);
        Assert.True(parsed.IsSuccess);
        Assert.Equal(new ParsedPhone(e164, country), parsed.Value);
    }

    [Theory]
    [InlineData("+90 212 123 45 67", "security.phone_not_mobile")] // İstanbul landline
    [InlineData("12", "security.phone_invalid")]
    [InlineData("", "security.phone_invalid")]
    public void Other_numbers_are_refused(string input, string code) =>
        Assert.Equal(code, PhoneRules.Parse(input, "TR").Error!.Code);

    [Fact]
    public void Totp_matches_the_rfc_6238_vector_and_refuses_replays()
    {
        // RFC 6238 appendix B, SHA-1, T = 59 s: 94287082 (the last six digits for six-digit codes).
        var secret = "12345678901234567890"u8.ToArray();
        Assert.Equal("287082", Totp.Code(secret, 1));
        var at = DateTimeOffset.FromUnixTimeSeconds(59);
        Assert.Equal(1, Totp.Verify(secret, "287082", at, null));
        Assert.Null(Totp.Verify(secret, "287082", at, lastStep: 1));
        Assert.Null(Totp.Verify(secret, "287082", DateTimeOffset.FromUnixTimeSeconds(59 + 120), null));
        Assert.Equal("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", Totp.Base32(secret));
    }
}
