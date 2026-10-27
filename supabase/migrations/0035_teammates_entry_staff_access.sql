-- User decisions 2026-10-27 (docs/ARCHITECTURE.md §3g Ücretli paketler):
-- 1. Platform admins have every paid feature, for support and testing; it is not sold to them.
-- 2. The teammates section is entered with the Ekip Arkadaşı package: the lists, suggestions and accepting a request
--    need it too. Without it the person sees only how many requests wait for them.

-- ---------------------------------------------------------------------------
-- Billing: features, with full access for platform admins (as in 0032, plus the admins)
-- ---------------------------------------------------------------------------
create function private.has_full_access(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.platform_staff s where s.user_id = uid and s.role = 'admin');
$$;

revoke all on function private.has_full_access(uuid) from public;
grant execute on function private.has_full_access(uuid) to authenticated, service_role;

create or replace function private.has_matching_feature(uid uuid, feature text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.has_full_access(uid) or exists (
    select 1 from public.user_subscriptions s
    where s.user_id = uid and s.starts_at <= now() and now() < s.ends_at
      and s.plan_slug = any (case feature
        when 'reveal' then array['matching_reveal', 'matching_chat', 'matching_premium']
        when 'chat' then array['matching_chat', 'matching_premium']
        when 'admirers' then array['matching_admirers', 'matching_premium']
        when 'unlimited' then array['matching_unlimited', 'matching_premium']
        when 'super' then array['matching_super', 'matching_premium']
        when 'boost' then array['matching_boost', 'matching_premium']
        when 'teammates' then array['matching_teammates', 'matching_premium']
        else array[]::text[]
      end)
  );
$$;

-- The status also says when everything is open without a package (as in 0032, plus full_access).
create or replace function private.match_status()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as id)
  select jsonb_build_object(
    'full_access', private.has_full_access(me.id),
    'features', (select coalesce(jsonb_agg(f), '[]')
                 from unnest(array['reveal', 'chat', 'admirers', 'unlimited', 'super', 'boost', 'teammates']) f
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
-- Profile (owns teammates): the section needs the package
-- ---------------------------------------------------------------------------
create or replace function public.teammate_suggestions()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select case when private.has_matching_feature((select auth.uid()), 'teammates') then private.teammate_suggestions() else '[]'::jsonb end;
$$;

-- How many teammate requests wait for uid (the rows themselves need the package).
create function private.teammate_requests_waiting(uid uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::int from public.teammate_requests r where r.target_id = uid;
$$;

revoke all on function private.teammate_requests_waiting(uuid) from public;
grant execute on function private.teammate_requests_waiting(uuid) to authenticated;

-- Locked: no names, only how many requests wait.
create or replace function public.my_teammates()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select case when private.has_matching_feature((select auth.uid()), 'teammates')
    then private.my_teammates() || jsonb_build_object('locked', false)
    else jsonb_build_object(
      'locked', true, 'teammates', '[]'::jsonb, 'incoming', '[]'::jsonb, 'outgoing', '[]'::jsonb,
      'incoming_count', private.teammate_requests_waiting((select auth.uid())))
  end;
$$;

drop policy teammate_requests_select_party on public.teammate_requests;
create policy teammate_requests_select_party on public.teammate_requests for select to authenticated
  using ((requester_id = (select auth.uid()) or target_id = (select auth.uid()))
         and (select private.has_matching_feature((select auth.uid()), 'teammates')));

drop policy teammates_select_party on public.teammates;
create policy teammates_select_party on public.teammates for select to authenticated
  using ((user_a = (select auth.uid()) or user_b = (select auth.uid()))
         and (select private.has_matching_feature((select auth.uid()), 'teammates')));

-- Accepting a request needs the package too (as in 0021, plus the package).
create or replace function private.teammates_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor not in (new.user_a, new.user_b) or not exists (
      select 1 from public.teammate_requests r
      where r.target_id = actor and r.requester_id = case when actor = new.user_a then new.user_b else new.user_a end
    ) then
      perform private.raise_profile_rule('teammate_forbidden');
    end if;
    if not private.has_matching_feature(actor, 'teammates') then
      perform private.raise_profile_rule('teammate_package_required');
    end if;
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_profile_rule('teammate_immutable');
  end if;
  if pg_trigger_depth() > 1 or actor in (old.user_a, old.user_b) then
    return old;
  end if;
  perform private.raise_profile_rule('teammate_forbidden');
  return null;
end;
$$;
