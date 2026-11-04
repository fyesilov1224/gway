-- 0078_user_presence
-- Live users in the admin panel (docs/ARCHITECTURE.md §8b, Canlı kullanıcılar; user request 2026-11-04): who has the
-- app open right now. One row per person, no history, no device or location data.
-- owner: identity

create table public.user_presence (
  user_id uuid primary key references auth.users (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'web')),
  online_since timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  left_at timestamptz
);

comment on table public.user_presence is
  'Online when left_at is null and last_seen_at is under 2 minutes old. Clients write only through touch_presence and leave_presence; only the API (platform staff) reads.';

create index user_presence_last_seen_idx on public.user_presence (last_seen_at desc);

-- Deny by default: no policy, so clients can neither read nor write the table directly.
alter table public.user_presence enable row level security;

-- The app is in front: a new session starts the "online since" clock, a beat keeps it.
create function private.touch_presence(device_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := auth.uid();
begin
  if me is null then
    raise exception 'presence_unauthenticated' using errcode = '42501';
  end if;
  if device_platform not in ('android', 'ios', 'web') then
    raise exception 'presence_invalid_platform' using errcode = '22023';
  end if;
  insert into public.user_presence as p (user_id, platform)
  values (me, device_platform)
  on conflict (user_id) do update
    set platform = excluded.platform,
        online_since = case
          when p.left_at is not null or p.last_seen_at < now() - interval '2 minutes' then now()
          else p.online_since end,
        last_seen_at = now(),
        left_at = null;
end;
$$;

-- The app went to the background or signed out: off the list at once.
create function private.leave_presence()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.user_presence set left_at = now(), last_seen_at = now()
  where user_id = auth.uid() and left_at is null;
$$;

-- What the app calls; the work runs as the owner in private (no security definer in the exposed schema).
create function public.touch_presence(device_platform text)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.touch_presence(device_platform);
$$;

create function public.leave_presence()
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.leave_presence();
$$;

revoke all on function private.touch_presence(text), public.touch_presence(text),
  private.leave_presence(), public.leave_presence() from public, anon;
grant execute on function private.touch_presence(text), public.touch_presence(text),
  private.leave_presence(), public.leave_presence() to authenticated;
