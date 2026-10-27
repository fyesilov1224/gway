-- Matching fixes (docs/ARCHITECTURE.md §3g, Kaydırma ve eşleşme; Bildirimler).
-- 1. A super like has its own allowance and no longer counts against the free likes.
-- 2. A swipe goes only to someone in the deck (private.match_in_deck), the same rule the deck reads with.
-- 3. "Seni beğenenler" forgets a pass after 90 days, like the deck.
-- 4. A super like's notification goes with its swipe (deleting matching data, account deletion).
-- owner: matching

-- ---------------------------------------------------------------------------
-- 1. Free likes left today: super likes have their own allowance
-- ---------------------------------------------------------------------------
create or replace function private.match_likes_left()
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest(
    (select s.daily_free_likes from public.matching_settings s)
    - (select count(*)::int from public.match_swipes w
       where w.swiper_id = (select auth.uid()) and w.liked and not w.super
         and w.created_at >= private.match_day_start()),
    0);
$$;

-- ---------------------------------------------------------------------------
-- 2. Who is in viewer's deck for the mode: fits, not liked, not passed in 90 days, not matched (even an ended match)
-- ---------------------------------------------------------------------------
create function private.match_in_deck(viewer uuid, target uuid, deck text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.match_fits(viewer, target, deck)
    and not exists (
      select 1 from public.match_swipes s
      where s.swiper_id = viewer and s.target_id = target and s.mode = deck
        and (s.liked or s.created_at > now() - interval '90 days')
    )
    and not exists (
      select 1 from public.matches m
      where m.user_a = least(viewer, target) and m.user_b = greatest(viewer, target) and m.mode = deck
    );
$$;

revoke all on function private.match_in_deck(uuid, uuid, text) from public;
grant execute on function private.match_in_deck(uuid, uuid, text) to service_role;

-- As in 0030, with the pool read through match_in_deck.
create or replace function private.match_deck(deck text, page_size int, min_age int, max_age int, in_province int, with_interest text, in_group uuid)
returns setof jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if (min_age is not null or max_age is not null or in_province is not null or with_interest is not null or in_group is not null)
     and not private.has_matching_feature(me, 'unlimited') then
    perform private.raise_match_rule('package_required');
  end if;

  return query
  with pool as (
    select t.user_id,
           (select count(*) from private.shared_groups(me, t.user_id)) as shared,
           exists (select 1 from public.match_swipes s where s.swiper_id = t.user_id and s.target_id = me and s.mode = deck and s.super) as super_liked,
           exists (select 1 from public.match_boosts b where b.user_id = t.user_id and now() between b.starts_at and b.ends_at) as boosted,
           t.updated_at
    from public.match_profiles t
    where t.user_id <> me
      and private.match_in_deck(me, t.user_id, deck)
      and private.match_age(t.birth_date) between coalesce(min_age, 18) and coalesce(max_age, 99)
      and (in_province is null or t.province = in_province)
      and (with_interest is null or exists (select 1 from public.profile_interests i
                                            where i.user_id = t.user_id and i.category_slug = with_interest))
      and (in_group is null or in_group in (select private.shared_groups(me, t.user_id)))
  )
  select private.match_card(me, pool.user_id)
  from pool
  order by pool.super_liked desc, pool.boosted desc, pool.shared desc, pool.updated_at desc, pool.user_id
  limit least(greatest(page_size, 1), 50);
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. People who liked uid and wait: as in 0029, a pass older than 90 days no longer hides them
-- ---------------------------------------------------------------------------
create or replace function private.match_admirers_of(uid uuid, deck text)
returns table (user_id uuid, super boolean, liked_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select s.swiper_id, s.super, s.created_at
  from public.match_swipes s
  where s.target_id = uid and s.mode = deck and s.liked
    and private.match_in_deck(uid, s.swiper_id, deck);
$$;

-- ---------------------------------------------------------------------------
-- 4. A super like's notification goes with its swipe (notifications owns the table, as in 0028's match clean-up)
-- ---------------------------------------------------------------------------
create function private.match_swipes_after_delete()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.notifications
  where type = 'match_super_liked' and recipient_id = old.target_id and actor_id = old.swiper_id;
  return null;
end;
$$;

revoke all on function private.match_swipes_after_delete() from public;

create trigger match_swipes_after_delete
  after delete on public.match_swipes
  for each row when (old.super)
  execute function private.match_swipes_after_delete();
