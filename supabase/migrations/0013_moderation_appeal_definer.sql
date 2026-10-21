-- 0013_moderation_appeal_definer
-- The appeal guard runs for the person's own insert (RLS) and reads the case and its
-- voters, which clients cannot read; it runs as the definer (docs/ARCHITECTURE.md §3e, İtiraz).

alter function private.sanction_appeals_guard() security definer;
revoke all on function private.sanction_appeals_guard() from public;
