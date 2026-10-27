-- One entry per matched person (docs/ARCHITECTURE.md §3g, user decision 2026-10-27): a pair matched as friends and
-- as a couple shows once with both modes; ending one mode keeps the other, and the follows go only with the last.

-- ---------------------------------------------------------------------------
-- Matching: the user's matches, one per person, with every running mode
-- ---------------------------------------------------------------------------
create or replace function private.my_matches()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with mine as (
    select m.id, m.mode, m.created_at,
           case when m.user_a = (select auth.uid()) then m.user_b else m.user_a end as other
    from public.matches m
    where (select auth.uid()) in (m.user_a, m.user_b) and m.ended_at is null
  ), pairs as (
    select other,
           jsonb_agg(jsonb_build_object('match_id', id, 'mode', mode) order by mode desc) as modes,
           max(created_at) as matched_at
    from mine
    group by other
  )
  select case when private.has_matching_feature((select auth.uid()), 'reveal')
    then private.match_card((select auth.uid()), pairs.other)
      || jsonb_build_object('modes', pairs.modes, 'matched_at', pairs.matched_at, 'username', p.username, 'locked', false)
    else jsonb_build_object('modes', pairs.modes, 'matched_at', pairs.matched_at, 'locked', true)
  end
  from pairs
  join public.profiles p on p.id = pairs.other
  where private.is_account_active(p.id)
    and not private.is_blocked_between((select auth.uid()), p.id)
    and exists (select 1 from public.match_profiles t where t.user_id = p.id)
  order by pairs.matched_at desc;
$$;

-- ---------------------------------------------------------------------------
-- Social graph (owns follows): only the last running match takes the follows with it
-- ---------------------------------------------------------------------------
create or replace function private.unfollow_on_match_end()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if private.are_matched(new.user_a, new.user_b) then
    return null;
  end if;
  -- Nested in this trigger, the follow guards allow the clean-up.
  delete from public.follows
  where (follower_id, followee_id) in ((new.user_a, new.user_b), (new.user_b, new.user_a));
  delete from public.follow_requests
  where (requester_id, target_id) in ((new.user_a, new.user_b), (new.user_b, new.user_a));
  return null;
end;
$$;
