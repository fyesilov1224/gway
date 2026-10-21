using Npgsql;

namespace GrupX.Api.Tests;

/// <summary>
/// Local Supabase database (<c>supabase start</c>). Tests that need it are skipped when it is not running.
/// Each instance deletes the auth users it created; audit_log rows stay (append-only) until <c>supabase db reset</c>.
/// </summary>
public sealed class TestDatabase : IAsyncLifetime
{
    public const string ConnectionString = "Host=127.0.0.1;Port=54322;Username=postgres;Password=postgres;Database=postgres;Timeout=3";

    /// <summary>Superuser, only for cleanup that the group triggers would (rightly) refuse.</summary>
    private const string AdminConnectionString = "Host=127.0.0.1;Port=54322;Username=supabase_admin;Password=postgres;Database=postgres;Timeout=3";

    private static readonly Lazy<Task<bool>> Available = new(async () =>
    {
        try
        {
            await using var conn = new NpgsqlConnection(ConnectionString);
            await conn.OpenAsync();
            return true;
        }
        catch (NpgsqlException)
        {
            return false;
        }
    });

    private readonly List<Guid> _created = [];

    public NpgsqlDataSource Db { get; } = NpgsqlDataSource.Create(ConnectionString);

    public async ValueTask InitializeAsync() =>
        Assert.SkipUnless(await Available.Value, "Local Supabase is not running (supabase start).");

    public async ValueTask DisposeAsync()
    {
        if (_created.Count > 0 && await Available.Value)
        {
            await DeleteOwnedGroupsAsync();
            await using var cmd = Db.CreateCommand("delete from auth.users where id = any(@ids)");
            cmd.Parameters.AddWithValue("ids", _created.ToArray());
            await cmd.ExecuteNonQueryAsync();
        }
        await Db.DisposeAsync();
    }

    /// <summary>
    /// Groups restrict deleting their owner, so they go first, with triggers off (suspended groups included).
    /// Orders are never deleted in production; test orders go too.
    /// </summary>
    private async Task DeleteOwnedGroupsAsync()
    {
        await using var conn = new NpgsqlConnection(AdminConnectionString);
        await conn.OpenAsync();
        await using var tx = await conn.BeginTransactionAsync();
        await using var cmd = new NpgsqlCommand(
            """
            set local session_replication_role = replica;
            create temporary table doomed on commit drop as select id from public.groups where owner_id = any(@ids);
            create temporary table doomed_posts on commit drop as select id from public.posts where group_id in (select id from doomed);
            delete from public.sanction_appeals where sanction_id in (select id from public.sanctions where group_id in (select id from doomed));
            delete from public.sanctions where group_id in (select id from doomed);
            delete from public.case_votes where case_id in (select id from public.moderation_cases where group_id in (select id from doomed));
            delete from public.reports where group_id in (select id from doomed);
            delete from public.moderation_cases where group_id in (select id from doomed);
            delete from public.notifications where group_id in (select id from doomed);
            delete from public.notifications where post_id in (select id from doomed_posts)
              or live_id in (select id from public.live_broadcasts where group_id in (select id from doomed));
            delete from public.live_comments where broadcast_id in (select id from public.live_broadcasts where group_id in (select id from doomed));
            delete from public.live_kicks where broadcast_id in (select id from public.live_broadcasts where group_id in (select id from doomed));
            delete from public.live_reminders where broadcast_id in (select id from public.live_broadcasts where group_id in (select id from doomed));
            delete from public.live_broadcasts where group_id in (select id from doomed);
            delete from public.notifications where event_id in (select id from public.events where group_id in (select id from doomed));
            delete from public.poll_votes where poll_id in (select id from public.polls where group_id in (select id from doomed));
            delete from public.poll_options where poll_id in (select id from public.polls where group_id in (select id from doomed));
            delete from public.polls where group_id in (select id from doomed);
            delete from public.event_attendees where event_id in (select id from public.events where group_id in (select id from doomed));
            delete from public.event_reviews where event_id in (select id from public.events where group_id in (select id from doomed));
            delete from public.goal_completions where goal_id in (select id from public.goals where group_id in (select id from doomed));
            delete from public.goal_claims where goal_id in (select id from public.goals where group_id in (select id from doomed));
            delete from public.goal_team_members where goal_id in (select id from public.goals where group_id in (select id from doomed));
            delete from public.goal_teams where goal_id in (select id from public.goals where group_id in (select id from doomed));
            delete from public.notifications where goal_id in (select id from public.goals where group_id in (select id from doomed));
            delete from public.goals where group_id in (select id from doomed);
            update public.posts set event_id = null where event_id in (select id from public.events where group_id in (select id from doomed));
            delete from public.events where group_id in (select id from doomed);
            delete from public.comment_likes where comment_id in (select id from public.comments where post_id in (select id from doomed_posts));
            delete from public.comments where post_id in (select id from doomed_posts);
            delete from public.post_likes where post_id in (select id from doomed_posts);
            delete from public.saved_posts where post_id in (select id from doomed_posts);
            delete from public.post_hashtags where post_id in (select id from doomed_posts);
            delete from public.post_media where post_id in (select id from doomed_posts);
            delete from public.posts where id in (select id from doomed_posts);
            delete from public.group_follows where group_id in (select id from doomed);
            delete from storage.objects where bucket_id = 'media' and owner_id = any(@ids::text[]);
            delete from public.group_subscriptions where group_id in (select id from doomed);
            delete from public.billing_orders where buyer_id = any(@ids) or group_id in (select id from doomed);
            delete from public.group_member_roles where group_id in (select id from doomed);
            delete from public.group_members where group_id in (select id from doomed);
            delete from public.group_join_requests where group_id in (select id from doomed);
            delete from public.group_invitations where group_id in (select id from doomed);
            delete from public.groups where id in (select id from doomed);
            """, conn, tx);
        cmd.Parameters.AddWithValue("ids", _created.ToArray());
        await cmd.ExecuteNonQueryAsync();
        await tx.CommitAsync();
    }

    public async Task<Guid> CreateUserAsync(string? username = null)
    {
        var id = Guid.NewGuid();
        _created.Add(id);
        await ExecuteAsync(
            "insert into auth.users (id, email, aud, role, created_at) values (@id, @email, 'authenticated', 'authenticated', now())",
            ("id", id), ("email", $"{id:N}@test.local"));
        if (username is not null)
        {
            await ExecuteAsync(
                "insert into public.profiles (id, username, display_name) values (@id, @username, @username)",
                ("id", id), ("username", username));
        }
        return id;
    }

    /// <summary>Pretends <paramref name="path"/> was uploaded to the <c>media</c> bucket.</summary>
    public Task StoreMediaAsync(Guid owner, string path, string mime, long size = 100_000) =>
        ExecuteAsync(
            "insert into storage.objects (bucket_id, name, owner_id, metadata) values ('media', @path, @owner, @meta::jsonb)",
            ("path", path), ("owner", owner.ToString()), ("meta", $$"""{"size": {{size}}, "mimetype": "{{mime}}"}"""));

    /// <summary>Superuser write with triggers off, e.g. to move a deadline into the past.</summary>
    public async Task ExecuteWithoutTriggersAsync(string sql, params (string Name, object Value)[] parameters)
    {
        await using var conn = new NpgsqlConnection(AdminConnectionString);
        await conn.OpenAsync();
        await using var tx = await conn.BeginTransactionAsync();
        await using (var replica = new NpgsqlCommand("set local session_replication_role = replica", conn, tx)) await replica.ExecuteNonQueryAsync();
#pragma warning disable CA2100 // test-only SQL constants
        await using var cmd = new NpgsqlCommand(sql, conn, tx);
#pragma warning restore CA2100
        foreach (var (name, value) in parameters) cmd.Parameters.AddWithValue(name, value);
        await cmd.ExecuteNonQueryAsync();
        await tx.CommitAsync();
    }

    public Task MakeStaffAsync(Guid userId, string role) =>
        ExecuteAsync("insert into public.platform_staff (user_id, role) values (@id, @role)", ("id", userId), ("role", role));

    public async Task ExecuteAsync(string sql, params (string Name, object Value)[] parameters)
    {
        await using var cmd = CreateCommand(sql, parameters);
        await cmd.ExecuteNonQueryAsync();
    }

    public async Task<T?> ScalarAsync<T>(string sql, params (string Name, object Value)[] parameters)
    {
        await using var cmd = CreateCommand(sql, parameters);
        var value = await cmd.ExecuteScalarAsync();
        return value is null or DBNull ? default : (T)value;
    }

    private NpgsqlCommand CreateCommand(string sql, (string Name, object Value)[] parameters)
    {
#pragma warning disable CA2100 // test-only SQL constants
        var cmd = Db.CreateCommand(sql);
#pragma warning restore CA2100
        foreach (var (name, value) in parameters) cmd.Parameters.AddWithValue(name, value);
        return cmd;
    }
}
