-- Faz 15.6b: matching features sold as separate packages (docs/ARCHITECTURE.md §3g, Ücretli paketler).
-- Free users swipe and learn that they matched; who it is, writing to them and the extras need a package.

-- ---------------------------------------------------------------------------
-- Billing: the packages (matching_premium becomes "Hepsi Bir Arada")
-- ---------------------------------------------------------------------------
alter table public.personal_plans add column sort_order int not null default 0;

-- The guards allow only a platform admin to change the catalog; this migration is the catalog change.
alter table public.personal_plans disable trigger personal_plans_guard;
alter table public.personal_plan_prices disable trigger personal_plan_prices_guard;

update public.personal_plans set name = 'Hepsi Bir Arada', sort_order = 100 where slug = 'matching_premium';
update public.personal_plan_prices set amount_minor = case currency || period
  when 'TRYmonth' then 24900 when 'TRYyear' then 249000 when 'USDmonth' then 999 else 9990 end
where plan_slug = 'matching_premium';

insert into public.personal_plans (slug, name, sort_order) values
  ('matching_reveal', 'Eşleşmelerim', 10),
  ('matching_chat', 'Eşleşme Sohbeti', 20),
  ('matching_admirers', 'Seni Beğenenler', 30),
  ('matching_unlimited', 'Sınırsız Beğeni', 40),
  ('matching_super', 'Süper Beğeni', 50),
  ('matching_boost', 'Öne Çık', 60);

-- Yearly = 10 × monthly (two months free).
insert into public.personal_plan_prices (plan_slug, currency, period, amount_minor)
select slug, currency, period, case period when 'year' then monthly * 10 else monthly end
from (values
  ('matching_reveal', 'TRY', 4900), ('matching_reveal', 'USD', 199),
  ('matching_chat', 'TRY', 9900), ('matching_chat', 'USD', 399),
  ('matching_admirers', 'TRY', 7900), ('matching_admirers', 'USD', 299),
  ('matching_unlimited', 'TRY', 7900), ('matching_unlimited', 'USD', 299),
  ('matching_super', 'TRY', 4900), ('matching_super', 'USD', 199),
  ('matching_boost', 'TRY', 6900), ('matching_boost', 'USD', 249)
) as p (slug, currency, monthly), unnest(array['month', 'year']) as period;

alter table public.personal_plans enable trigger personal_plans_guard;
alter table public.personal_plan_prices enable trigger personal_plan_prices_guard;

-- What a feature needs: its own package, a package that includes it, or everything.
create function private.has_matching_feature(uid uuid, feature text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_subscriptions s
    where s.user_id = uid and s.starts_at <= now() and now() < s.ends_at
      and s.plan_slug = any (case feature
        when 'reveal' then array['matching_reveal', 'matching_chat', 'matching_premium']
        when 'chat' then array['matching_chat', 'matching_premium']
        when 'admirers' then array['matching_admirers', 'matching_premium']
        when 'unlimited' then array['matching_unlimited', 'matching_premium']
        when 'super' then array['matching_super', 'matching_premium']
        when 'boost' then array['matching_boost', 'matching_premium']
        else array[]::text[]
      end)
  );
$$;

-- Any matching package (for counts).
create or replace function private.has_matching_premium(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_subscriptions s
    where s.user_id = uid and s.plan_slug like 'matching\_%' and s.starts_at <= now() and now() < s.ends_at
  );
$$;

revoke all on function private.has_matching_feature(uuid, text) from public;
grant execute on function private.has_matching_feature(uuid, text) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Matching: who you matched with needs reveal
-- ---------------------------------------------------------------------------
drop policy matches_select_own on public.matches;
create policy matches_select_own on public.matches for select to authenticated
  using ((select auth.uid()) in (user_a, user_b) and (select private.has_matching_feature((select auth.uid()), 'reveal')));

create or replace function private.can_view_match_profile(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select target = (select auth.uid())
    or (private.are_matched((select auth.uid()), target) and private.is_account_active(target)
        and private.has_matching_feature((select auth.uid()), 'reveal'))
    or private.match_fits((select auth.uid()), target, 'friend')
    or private.match_fits((select auth.uid()), target, 'dating')
    or private.is_platform_staff();
$$;

-- Without reveal a match is only a locked entry: when and in which mode.
create or replace function private.my_matches()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when private.has_matching_feature((select auth.uid()), 'reveal')
    then private.match_card((select auth.uid()), other.id)
      || jsonb_build_object('match_id', m.id, 'mode', m.mode, 'matched_at', m.created_at, 'username', other.username, 'locked', false)
    else jsonb_build_object('match_id', m.id, 'mode', m.mode, 'matched_at', m.created_at, 'locked', true)
  end
  from public.matches m
  cross join lateral (
    select p.id, p.username from public.profiles p
    where p.id = case when m.user_a = (select auth.uid()) then m.user_b else m.user_a end
  ) other
  where (select auth.uid()) in (m.user_a, m.user_b)
    and m.ended_at is null
    and private.is_account_active(other.id)
    and not private.is_blocked_between((select auth.uid()), other.id)
    and exists (select 1 from public.match_profiles t where t.user_id = other.id)
  order by m.created_at desc;
$$;

-- The match notice names nobody: its actor is the recipient.
create or replace function private.notify_match_created()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notifications (recipient_id, actor_id, type, match_id)
  select pair.recipient, pair.recipient, 'match_created', new.id
  from (values (new.user_a), (new.user_b)) as pair (recipient)
  where private.wants_notification(pair.recipient, 'match_created');
  return null;
end;
$$;

update public.notifications set actor_id = recipient_id where type = 'match_created';

-- ---------------------------------------------------------------------------
-- Allowances by feature
-- ---------------------------------------------------------------------------
create or replace function private.match_super_likes_left(uid uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest(
    (select case when private.has_matching_feature(uid, 'super') then s.daily_premium_super_likes else s.daily_free_super_likes end
     from public.matching_settings s)
    - (select count(*)::int from public.match_swipes w
       where w.swiper_id = uid and w.super and w.created_at >= private.match_day_start()),
    0);
$$;

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
      and private.match_fits(me, t.user_id, deck)
      and not exists (
        select 1 from public.match_swipes s
        where s.swiper_id = me and s.target_id = t.user_id and s.mode = deck
          and (s.liked or s.created_at > now() - interval '90 days')
      )
      and not exists (
        select 1 from public.matches m
        where m.user_a = least(me, t.user_id) and m.user_b = greatest(me, t.user_id) and m.mode = deck
      )
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

create or replace function private.match_admirers(deck text, page_size int)
returns setof jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if not private.has_matching_feature(me, 'admirers') then
    perform private.raise_match_rule('package_required');
  end if;
  return query
  select private.match_card(me, a.user_id) || jsonb_build_object('liked_at', a.liked_at)
  from private.match_admirers_of(me, deck) a
  order by a.super desc, a.liked_at desc
  limit least(greatest(page_size, 1), 100);
end;
$$;

-- Features the user has, each package's remaining time, and today's allowances.
create or replace function private.match_status()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as id)
  select jsonb_build_object(
    'features', (select coalesce(jsonb_agg(f), '[]') from unnest(array['reveal', 'chat', 'admirers', 'unlimited', 'super', 'boost']) f
                 where private.has_matching_feature(me.id, f)),
    'packages', (select coalesce(jsonb_object_agg(p.slug, private.personal_plan_until(me.id, p.slug)), '{}')
                 from public.personal_plans p
                 where p.slug like 'matching\_%' and private.personal_plan_until(me.id, p.slug) is not null),
    'likes_left', case when private.has_matching_feature(me.id, 'unlimited') then null else private.match_likes_left() end,
    'super_likes_left', private.match_super_likes_left(me.id),
    'boost_ends_at', (select max(b.ends_at) from public.match_boosts b where b.user_id = me.id and b.ends_at > now()),
    'boost_used_today', exists (select 1 from public.match_boosts b where b.user_id = me.id and b.starts_at >= private.match_day_start()),
    'boost_minutes', (select s.boost_minutes from public.matching_settings s),
    'admirers', jsonb_build_object(
      'friend', (select count(*) from private.match_admirers_of(me.id, 'friend')),
      'dating', (select count(*) from private.match_admirers_of(me.id, 'dating')))
  )
  from me;
$$;

-- ---------------------------------------------------------------------------
-- Messaging (messaging owns this function): writing to a match needs the chat package,
-- unless the two could write to each other anyway.
-- ---------------------------------------------------------------------------
create or replace function private.message_blocker(uid uuid, conv uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  c public.conversations;
  peer uuid;
  mine text;
  theirs text;
begin
  select * into c from public.conversations where id = conv;
  if c.id is null or uid is null or not private.is_account_active(uid) or not private.can_read_conversation_as(uid, conv) then
    return 'message_forbidden';
  end if;
  if c.kind = 'group' then
    if (select g.status from public.groups g where g.id = c.group_id) <> 'active' then
      return 'message_forbidden';
    end if;
    if private.is_group_muted(c.group_id, uid) then
      return 'message_muted';
    end if;
    if c.admins_only and not private.user_has_group_permission(uid, c.group_id, 'posts.publish') then
      return 'message_admins_only';
    end if;
    return null;
  end if;
  peer := private.conversation_peer(conv, uid);
  if private.is_blocked_between(uid, peer) then
    return 'blocked';
  end if;
  if not private.is_account_active(peer) then
    return 'message_forbidden';
  end if;
  if private.match_ended_between(uid, peer) then
    return 'match_ended';
  end if;
  if private.are_matched(uid, peer) then
    if private.has_matching_feature(uid, 'chat') or private.are_teammates(uid, peer)
       or (private.user_follows(uid, peer) and private.user_follows(peer, uid)) then
      return null;
    end if;
    return 'match_chat_locked';
  end if;
  select m.state into mine from public.conversation_members m where m.conversation_id = conv and m.user_id = uid;
  select m.state into theirs from public.conversation_members m where m.conversation_id = conv and m.user_id = peer;
  if mine = 'request' then
    return 'message_request_pending';
  end if;
  if theirs = 'declined' then
    return 'message_declined';
  end if;
  return null;
end;
$$;
