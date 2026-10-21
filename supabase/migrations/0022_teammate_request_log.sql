-- 0022_teammate_request_log
-- Phase 13 fix: withdrawing a request deleted its row, so the daily limit could be dodged and the same
-- person asked again and again. Every sent request is now logged for 24 hours; notifications follow the
-- request (gone when it is withdrawn or declined, one per pair when accepted).

-- ---------------------------------------------------------------------------
-- teammate_request_log
-- owner: profile
-- ---------------------------------------------------------------------------
create table public.teammate_request_log (
  requester_id uuid not null references public.profiles (id) on delete cascade,
  target_id    uuid not null references public.profiles (id) on delete cascade,
  sent_at      timestamptz not null default now()
);

comment on table public.teammate_request_log is
  'owner: profile. Teammate requests sent in the last 24 hours, for the rate limit; written only by triggers.';

create index teammate_request_log_requester_idx on public.teammate_request_log (requester_id, sent_at);

alter table public.teammate_request_log enable row level security;
revoke all on public.teammate_request_log from anon, authenticated;

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

-- Requests sent in the last 24 hours, to one person or (target null) to anyone.
create function private.teammate_requests_sent(requester uuid, target uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::int from public.teammate_request_log l
  where l.requester_id = requester and l.sent_at > now() - interval '24 hours'
    and (target is null or l.target_id = target);
$$;

revoke all on function private.teammate_requests_sent(uuid, uuid) from public;
grant execute on function private.teammate_requests_sent(uuid, uuid) to authenticated, service_role;

create function private.log_teammate_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.teammate_request_log where requester_id = new.requester_id and sent_at <= now() - interval '24 hours';
  insert into public.teammate_request_log (requester_id, target_id) values (new.requester_id, new.target_id);
  return null;
end;
$$;

revoke all on function private.log_teammate_request() from public;

create trigger log_teammate_request
  after insert on public.teammate_requests
  for each row execute function private.log_teammate_request();

-- ---------------------------------------------------------------------------
-- Notifications follow the request
-- ---------------------------------------------------------------------------
create function private.unnotify_teammate_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.notifications
  where type = 'teammate_request' and actor_id = old.requester_id and recipient_id = old.target_id;
  return null;
end;
$$;

revoke all on function private.unnotify_teammate_request() from public;

create trigger unnotify_teammate_request
  after delete on public.teammate_requests
  for each row execute function private.unnotify_teammate_request();

create or replace function private.notify_teammate_accepted()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  requester uuid;
begin
  if actor = new.user_a then
    requester := new.user_b;
  else
    requester := new.user_a;
  end if;
  -- One "accepted" per pair, however often they part and meet again.
  delete from public.notifications where type = 'teammate_accepted' and recipient_id = requester and actor_id = actor;
  perform private.notify(requester, actor, 'teammate_accepted');
  delete from public.notifications
  where type = 'teammate_request' and recipient_id = actor and actor_id = requester;
  return null;
end;
$$;
