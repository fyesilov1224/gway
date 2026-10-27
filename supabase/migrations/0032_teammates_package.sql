-- The Ekip Arkadaşı package (docs/ARCHITECTURE.md §3g Ücretli paketler, §3f; user decision 2026-10-26):
-- sending a teammate request and writing to a teammate need it; seeing the list and accepting a request stay free.

-- ---------------------------------------------------------------------------
-- Billing: the package
-- ---------------------------------------------------------------------------
insert into public.personal_plans (slug, name, sort_order) values ('matching_teammates', 'Ekip Arkadaşı', 70);
insert into public.personal_plan_prices (plan_slug, currency, period, amount_minor) values
  ('matching_teammates', 'TRY', 'month', 4900), ('matching_teammates', 'TRY', 'year', 49000),
  ('matching_teammates', 'USD', 'month', 199), ('matching_teammates', 'USD', 'year', 1990);

create or replace function private.has_matching_feature(uid uuid, feature text)
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
        when 'teammates' then array['matching_teammates', 'matching_premium']
        else array[]::text[]
      end)
  );
$$;

create or replace function private.match_status()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as id)
  select jsonb_build_object(
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
-- Profile (owns teammate requests): sending one needs the package (as in 0022, plus the package)
-- ---------------------------------------------------------------------------
create or replace function private.teammate_requests_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.requester_id or not private.is_account_active(actor)
       or not private.is_account_active(new.target_id) then
      perform private.raise_profile_rule('teammate_forbidden');
    end if;
    if private.is_blocked_between(new.requester_id, new.target_id) then
      perform private.raise_profile_rule('blocked');
    end if;
    if not exists (select 1 from public.teammate_preferences p where p.user_id = new.target_id and p.looking) then
      perform private.raise_profile_rule('teammate_not_looking');
    end if;
    if private.are_teammates(new.requester_id, new.target_id) then
      perform private.raise_profile_rule('already_teammates');
    end if;
    if not private.has_matching_feature(actor, 'teammates') then
      perform private.raise_profile_rule('teammate_package_required');
    end if;
    if private.teammate_requests_sent(actor, new.target_id) > 0 then
      perform private.raise_profile_rule('teammate_recently_asked');
    end if;
    if private.teammate_requests_sent(actor, null) >= 20 then
      perform private.raise_profile_rule('teammate_rate_limited');
    end if;
    new.message := btrim(new.message);
    new.created_at := now();
    return new;
  end if;
  if tg_op = 'UPDATE' then
    perform private.raise_profile_rule('teammate_immutable');
  end if;
  if pg_trigger_depth() > 1 or actor in (old.requester_id, old.target_id) then
    return old;
  end if;
  perform private.raise_profile_rule('teammate_forbidden');
  return null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Messaging (owns this function): writing to a teammate needs the package too
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
  if not (private.are_teammates(uid, peer) and private.has_matching_feature(uid, 'teammates')) then
    if private.are_matched(uid, peer) then
      if not private.has_matching_feature(uid, 'chat') then
        return 'match_chat_locked';
      end if;
    elsif private.are_teammates(uid, peer) then
      return 'teammate_chat_locked';
    elsif private.match_ended_between(uid, peer) then
      return 'match_ended';
    else
      return 'message_not_allowed';
    end if;
  end if;
  -- An old request still holds until it is answered.
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
