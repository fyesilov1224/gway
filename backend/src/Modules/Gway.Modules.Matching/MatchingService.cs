using System.Security.Claims;
using Gway.Modules.Matching.Contracts;
using Gway.SharedKernel;
using Gway.SharedKernel.Auditing;
using Gway.SharedKernel.Database;
using Gway.SharedKernel.Http;
using Gway.SharedKernel.Supabase;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace Gway.Modules.Matching;

/// <summary>A super like is a like the other person sees first and is told about.</summary>
public sealed record SwipeRequest(Guid TargetId, string Mode, bool Like, bool Super = false);

/// <summary>What remains of today's allowances after this swipe; <see cref="LikesLeft"/> is null with Sınırsız Beğeni.</summary>
public sealed record SwipeResult(bool Matched, Guid? MatchId, int? LikesLeft, int SuperLikesLeft);

/// <summary>The pass taken back; the person is back in the deck.</summary>
public sealed record RewindResult(Guid TargetId, string Mode);

public sealed record BoostResult(DateTimeOffset EndsAt);

public static class MatchingModule
{
    public const string PhotoBucket = "match-photos";

    public static IServiceCollection AddMatchingModule(this IServiceCollection services)
    {
        services.AddSingleton<MatchingService>();
        services.AddSingleton<IMatchingAdministration>(sp => sp.GetRequiredService<MatchingService>());
        return services;
    }

    /// <summary>
    /// Matching (docs/ARCHITECTURE.md §3g). The profile and photos are the user's own writes through Supabase;
    /// swipes (daily limits, Premium), rewinds, boosts, ending a match and deleting everything go through here.
    /// </summary>
    public static IEndpointRouteBuilder MapMatchingEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/matching/swipes", async (SwipeRequest body, ClaimsPrincipal user, MatchingService matching, CancellationToken ct) =>
            (await matching.SwipeAsync(user.GetUserId(), body, ct)).ToHttpResult());

        app.MapPost("/matching/rewind", async (ClaimsPrincipal user, MatchingService matching, CancellationToken ct) =>
            (await matching.RewindAsync(user.GetUserId(), ct)).ToHttpResult());

        app.MapPost("/matching/boost", async (ClaimsPrincipal user, MatchingService matching, CancellationToken ct) =>
            (await matching.BoostAsync(user.GetUserId(), ct)).ToHttpResult());

        app.MapDelete("/matching/matches/{id:guid}", async (Guid id, ClaimsPrincipal user, MatchingService matching, CancellationToken ct) =>
            (await matching.EndMatchAsync(user.GetUserId(), id, ct)).ToHttpResult());

        app.MapDelete("/me/matching", async (ClaimsPrincipal user, MatchingService matching, CancellationToken ct) =>
            (await matching.DeleteAllAsync(user.GetUserId(), ct)).ToHttpResult());

        return app;
    }
}

internal sealed class MatchingService(NpgsqlDataSource db, ISupabaseStorage storage) : IMatchingAdministration
{
    private static readonly string[] Modes = ["friend", "dating"];

    private static readonly Error NotInDeck = Error.NotFound("match.not_in_deck", "Bu kişi artık listende değil.");
    private static readonly Error LikeLimit = Error.RuleViolation("match.like_limit", "Bugünkü beğeni hakkın bitti. Yarın yenilenir.");
    private static readonly Error SuperLikeLimit = Error.RuleViolation("match.super_like_limit", "Bugünkü süper beğeni hakkın bitti. Yarın yenilenir.");
    private static readonly Error PackageRequired = Error.RuleViolation("match.package_required", "Bu özellik bir eşleşme paketi gerektirir.");
    private static readonly Error RewindLocked = Error.RuleViolation("match.package_required", "Geri almak için Sınırsız Beğeni paketi gerekir.");
    private static readonly Error BoostLocked = Error.RuleViolation("match.package_required", "Öne çıkmak için Öne Çık paketi gerekir.");
    private static readonly Error NothingToRewind = Error.RuleViolation("match.nothing_to_rewind", "Geri alınacak bir geçiş yok.");
    private static readonly Error BoostUsed = Error.RuleViolation("match.boost_used", "Bugünkü öne çıkma hakkını kullandın. Yarın yenilenir.");
    private static readonly Error MatchNotFound = Error.NotFound("match.not_found", "Eşleşme bulunamadı.");
    private static readonly Error ProfileNotFound = Error.NotFound("match.profile_not_found", "Eşleşme profili bulunamadı.");
    private static readonly Error PhotoNotFound = Error.NotFound("match.photo_not_found", "Fotoğraf bulunamadı.");

    private static Error RuleError(string code) => code switch
    {
        "match_underage" => Error.RuleViolation("match.underage", "Eşleşme 18 yaşından büyükler içindir."),
        "package_required" => PackageRequired,
        _ => Error.RuleViolation($"match.{code}", "Bu işlem şu anda yapılamıyor. Sayfayı yenileyip tekrar dene."),
    };

    public Task<Result<SwipeResult>> SwipeAsync(Guid actor, SwipeRequest request, CancellationToken ct)
    {
        if (!Modes.Contains(request.Mode)) return Task.FromResult<Result<SwipeResult>>(Error.Validation("match.mode_invalid", "Geçersiz mod."));
        var like = request.Like || request.Super;

        return ActingTransaction.RunAsync<SwipeResult>(db, actor, async (conn, tx) =>
        {
            // One swipe at a time per person, so the daily limit holds under parallel requests.
            await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@actor::text, 7))", ct, ("actor", actor));
            // The deck's own rule: someone already liked, passed in the last 90 days or matched is not swiped again.
            var inDeck = (bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.match_in_deck(@actor, @target, @mode)", ct,
                ("actor", actor), ("target", request.TargetId), ("mode", request.Mode)))!;
            if (!inDeck) return NotInDeck;

            var unlimited = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                "select private.has_matching_feature(@actor, 'unlimited')", ct, ("actor", actor)))!;
            int? left = unlimited ? null : (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.match_likes_left()", ct))!;
            var superLeft = (int)(await ActingTransaction.ScalarAsync(conn, tx, "select private.match_super_likes_left(@actor)", ct, ("actor", actor)))!;
            if (request.Super && superLeft <= 0) return SuperLikeLimit;
            // A super like has its own allowance; a plain like counts against the free likes.
            if (like && !request.Super && left <= 0) return LikeLimit;

            await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.match_swipes (swiper_id, target_id, mode, liked, super) values (@actor, @target, @mode, @liked, @super)
                on conflict (swiper_id, target_id, mode) do update set liked = excluded.liked, super = excluded.super, created_at = now()
                """, ct, ("actor", actor), ("target", request.TargetId), ("mode", request.Mode), ("liked", like), ("super", request.Super));
            if (request.Super) superLeft--;
            else if (like && left is { } l) left = l - 1;
            if (!like) return new SwipeResult(false, null, left, superLeft);

            var mutual = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                select exists (select 1 from public.match_swipes
                               where swiper_id = @target and target_id = @actor and mode = @mode and liked)
                """, ct, ("actor", actor), ("target", request.TargetId), ("mode", request.Mode)))!;
            if (!mutual) return new SwipeResult(false, null, left, superLeft);

            var match = (Guid?)await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.matches (user_a, user_b, mode) values (least(@actor, @target), greatest(@actor, @target), @mode)
                on conflict (user_a, user_b, mode) do nothing
                returning id
                """, ct, ("actor", actor), ("target", request.TargetId), ("mode", request.Mode));
            return new SwipeResult(match is not null, match, left, superLeft);
        }, RuleError, ct);
    }

    /// <summary>Sınırsız Beğeni: takes back the person's last swipe when it was a pass.</summary>
    public Task<Result<RewindResult>> RewindAsync(Guid actor, CancellationToken ct) =>
        ActingTransaction.RunAsync<RewindResult>(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@actor::text, 7))", ct, ("actor", actor));
            if (!(bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.has_matching_feature(@actor, 'unlimited')", ct, ("actor", actor)))!)
                return RewindLocked;

            await using var cmd = new NpgsqlCommand(
                """
                with last as (
                  select swiper_id, target_id, mode, liked from public.match_swipes
                  where swiper_id = @actor order by created_at desc limit 1
                )
                delete from public.match_swipes s using last
                where not last.liked and s.swiper_id = last.swiper_id and s.target_id = last.target_id and s.mode = last.mode
                returning s.target_id, s.mode
                """, conn, tx);
            cmd.Parameters.AddWithValue("actor", actor);
            await using var r = await cmd.ExecuteReaderAsync(ct);
            return await r.ReadAsync(ct) ? new RewindResult(r.GetGuid(0), r.GetString(1)) : NothingToRewind;
        }, RuleError, ct);

    /// <summary>Öne Çık: once a day the person comes first in decks for the configured minutes.</summary>
    public Task<Result<BoostResult>> BoostAsync(Guid actor, CancellationToken ct) =>
        ActingTransaction.RunAsync<BoostResult>(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ScalarAsync(conn, tx, "select pg_advisory_xact_lock(hashtextextended(@actor::text, 7))", ct, ("actor", actor));
            if (!(bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.has_matching_feature(@actor, 'boost')", ct, ("actor", actor)))!)
                return BoostLocked;
            if (!(bool)(await ActingTransaction.ScalarAsync(conn, tx, "select private.is_match_profile_live(@actor)", ct, ("actor", actor)))!)
                return ProfileNotFound;
            var used = (bool)(await ActingTransaction.ScalarAsync(conn, tx,
                "select exists (select 1 from public.match_boosts where user_id = @actor and starts_at >= private.match_day_start())",
                ct, ("actor", actor)))!;
            if (used) return BoostUsed;

            var ends = (DateTime)(await ActingTransaction.ScalarAsync(conn, tx,
                """
                insert into public.match_boosts (user_id, ends_at)
                values (@actor, now() + make_interval(mins => (select boost_minutes from public.matching_settings)))
                returning ends_at
                """, ct, ("actor", actor)))!;
            return new BoostResult(new DateTimeOffset(DateTime.SpecifyKind(ends, DateTimeKind.Utc)));
        }, RuleError, ct);

    public Task<Result> EndMatchAsync(Guid actor, Guid matchId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            var ended = await ActingTransaction.ScalarAsync(conn, tx,
                """
                update public.matches set ended_at = now(), ended_by = @actor
                where id = @id and @actor in (user_a, user_b) and ended_at is null
                returning id
                """, ct, ("actor", actor), ("id", matchId));
            return ended is null ? MatchNotFound : Result.Success();
        }, RuleError, ct);

    /// <summary>
    /// Everything of the person's matching goes: profile, photos, swipes by and on them. Their matches end and stay
    /// as ended pairs only, so the chats they opened remain closed.
    /// </summary>
    public async Task<Result> DeleteAllAsync(Guid actor, CancellationToken ct)
    {
        var result = await ActingTransaction.RunAsync(db, actor, async (conn, tx) =>
        {
            await ActingTransaction.ScalarAsync(conn, tx,
                "update public.matches set ended_at = now(), ended_by = @actor where @actor in (user_a, user_b) and ended_at is null",
                ct, ("actor", actor));
            await ActingTransaction.ScalarAsync(conn, tx,
                "delete from public.match_swipes where swiper_id = @actor or target_id = @actor", ct, ("actor", actor));
            await ActingTransaction.ScalarAsync(conn, tx, "delete from public.match_boosts where user_id = @actor", ct, ("actor", actor));
            await ActingTransaction.ScalarAsync(conn, tx, "delete from public.match_profiles where user_id = @actor", ct, ("actor", actor));
            return Result.Success();
        }, RuleError, ct);
        if (result.IsSuccess) await storage.DeleteFolderAsync(MatchingModule.PhotoBucket, actor.ToString(), ct);
        return result;
    }

    // Platform team ------------------------------------------------------------------------------

    public async Task<MatchingStats> StatsAsync(CancellationToken ct)
    {
        await using var cmd = db.CreateCommand(
            """
            select
              (select count(*)::int from public.match_profiles),
              (select count(*)::int from public.match_profiles where friend),
              (select count(*)::int from public.match_profiles where dating),
              (select count(*)::int from public.match_profiles where gender = 'woman'),
              (select count(*)::int from public.match_profiles where gender = 'man'),
              (select count(*)::int from public.match_profiles where gender = 'nonbinary'),
              (select count(*)::int from public.match_profiles where paused),
              (select count(*)::int from public.match_profiles where suspended_until > now()),
              (select count(*)::int from public.match_swipes where liked and created_at > now() - interval '24 hours'),
              (select count(*)::int from public.match_swipes where not liked and created_at > now() - interval '24 hours'),
              (select count(*)::int from public.matches where created_at > now() - interval '24 hours'),
              (select count(*)::int from public.matches where ended_at is null),
              (select count(*)::int from public.reports where status = 'open' and target_type in ('match_profile', 'match_photo')),
              (select count(*)::int from public.match_profiles where private.has_matching_premium(user_id)),
              (select count(*)::int from public.match_swipes where super and created_at > now() - interval '24 hours'),
              (select count(*)::int from public.match_boosts where now() between starts_at and ends_at),
              s.daily_free_likes, s.daily_free_super_likes, s.daily_premium_super_likes, s.boost_minutes
            from public.matching_settings s
            """);
        await using var r = await cmd.ExecuteReaderAsync(ct);
        await r.ReadAsync(ct);
        int At(int i) => r.GetInt32(i);
        return new MatchingStats(At(0), At(1), At(2), At(3), At(4), At(5), At(6), At(7), At(8), At(9), At(10), At(11), At(12),
            At(13), At(14), At(15), new MatchingSettings(At(16), At(17), At(18), At(19)));
    }

    public Task<Result> SuspendAsync(Guid actorId, Guid userId, string reason, DateTimeOffset? until, CancellationToken ct)
    {
        reason = reason.Trim();
        if (reason.Length is < 3 or > 500) return Task.FromResult<Result>(Error.Validation("match.reason_invalid", "Gerekçe 3–500 karakter olmalı."));
        if (until is { } u && u <= DateTimeOffset.UtcNow) return Task.FromResult<Result>(Error.Validation("match.until_invalid", "Bitiş zamanı gelecekte olmalı."));

        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var found = await ActingTransaction.ScalarAsync(conn, tx,
                """
                update public.match_profiles
                set suspended_until = coalesce(@until::timestamptz, 'infinity'::timestamptz), suspension_reason = @reason
                where user_id = @user
                returning user_id
                """, ct, ("until", until), ("reason", reason), ("user", userId));
            if (found is null) return ProfileNotFound;
            await ActingTransaction.ScalarAsync(conn, tx,
                "update public.matches set ended_at = now() where @user in (user_a, user_b) and ended_at is null", ct, ("user", userId));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "match_profile.suspended", "match_profile",
                userId.ToString(), new { reason, until }), ct);
            return Result.Success();
        }, RuleError, ct);
    }

    public Task<Result> LiftSuspensionAsync(Guid actorId, Guid userId, CancellationToken ct) =>
        ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            var found = await ActingTransaction.ScalarAsync(conn, tx,
                """
                update public.match_profiles set suspended_until = null, suspension_reason = null
                where user_id = @user and suspended_until is not null
                returning user_id
                """, ct, ("user", userId));
            if (found is null) return ProfileNotFound;
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "match_profile.unsuspended", "match_profile",
                userId.ToString()), ct);
            return Result.Success();
        }, RuleError, ct);

    public async Task<Result> RemovePhotoAsync(Guid actorId, Guid photoId, string reason, CancellationToken ct)
    {
        reason = reason.Trim();
        if (reason.Length is < 3 or > 500) return Error.Validation("match.reason_invalid", "Gerekçe 3–500 karakter olmalı.");

        string? path = null;
        var result = await ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            await using (var cmd = new NpgsqlCommand("delete from public.match_photos where id = @id returning user_id, path", conn, tx))
            {
                cmd.Parameters.AddWithValue("id", photoId);
                await using var r = await cmd.ExecuteReaderAsync(ct);
                if (!await r.ReadAsync(ct)) return PhotoNotFound;
                var owner = r.GetGuid(0);
                path = r.GetString(1);
                await r.DisposeAsync();
                await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "match_photo.removed", "match_photo",
                    photoId.ToString(), new { reason, owner }), ct);
            }
            return Result.Success();
        }, RuleError, ct);
        if (result.IsSuccess && path is not null) await storage.DeleteObjectsAsync(MatchingModule.PhotoBucket, [path], ct);
        return result;
    }

    public Task<Result> UpdateSettingsAsync(Guid actorId, MatchingSettings settings, CancellationToken ct)
    {
        ArgumentNullException.ThrowIfNull(settings);
        if (settings.DailyFreeLikes is < 1 or > 1000)
            return Task.FromResult<Result>(Error.Validation("match.likes_invalid", "Günlük beğeni 1–1000 arasında olmalı."));
        if (settings.DailyFreeSuperLikes is < 0 or > 100 || settings.DailyPremiumSuperLikes is < 0 or > 100)
            return Task.FromResult<Result>(Error.Validation("match.super_likes_invalid", "Günlük süper beğeni 0–100 arasında olmalı."));
        if (settings.BoostMinutes is < 5 or > 180)
            return Task.FromResult<Result>(Error.Validation("match.boost_invalid", "Öne çıkma süresi 5–180 dakika olmalı."));
        return ActingTransaction.RunAsync(db, actorId, async (conn, tx) =>
        {
            await ActingTransaction.ScalarAsync(conn, tx,
                """
                update public.matching_settings
                set daily_free_likes = @likes, daily_free_super_likes = @freeSuper, daily_premium_super_likes = @premiumSuper,
                    boost_minutes = @boost, updated_at = now()
                """, ct, ("likes", settings.DailyFreeLikes), ("freeSuper", settings.DailyFreeSuperLikes),
                ("premiumSuper", settings.DailyPremiumSuperLikes), ("boost", settings.BoostMinutes));
            await AuditLog.AppendAsync(conn, tx, new AuditEntry(actorId, AuditActor.Staff, "matching.settings_updated", "matching_settings",
                null, settings), ct);
            return Result.Success();
        }, RuleError, ct);
    }
}
