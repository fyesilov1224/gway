-- 0062_message_logs
-- Intentionally empty. The platform admin's message logs were withdrawn (user decision, 2026-11-01): nobody on the
-- platform team reads private messages. 0070 removes what earlier versions of this migration created on databases
-- that already ran it; the version stays so the migration history of those databases still matches.
select 1;
