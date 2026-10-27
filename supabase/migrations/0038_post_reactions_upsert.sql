-- 0038_post_reactions_upsert
-- The app saves an emoji reaction with an upsert, which updates the key columns too (ON CONFLICT DO UPDATE),
-- so without this grant every reaction was refused (as 0018 for preferences and reviews).
-- RLS pins the row to the caller; the trigger below keeps a reaction on its post.
-- owner: feed (docs/ARCHITECTURE.md §3c)

grant update (post_id, user_id) on public.post_reactions to authenticated;

-- As in 0034, plus: an update changes only the emoji.
create or replace function private.post_reactions_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and (new.post_id, new.user_id) is distinct from (old.post_id, old.user_id) then
    perform private.raise_feed_rule('reaction_immutable');
  end if;
  new.created_at := now();
  return new;
end;
$$;
