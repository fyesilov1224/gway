-- 0067_push_device_cleanup
-- Push device rows no longer pile up (docs/ARCHITECTURE.md §3c, Push, Cihaz kaydının temizliği):
-- a row belongs to the session that registered it and goes with it on sign-out, one row per session,
-- and the backend probes tokens daily and drops devices not opened for 60 days.

alter table public.push_devices
  add column session_id uuid references auth.sessions (id) on delete cascade,
  -- Last FCM probe (validate_only); null until the first one.
  add column last_checked_at timestamptz;

create index push_devices_session_idx on public.push_devices (session_id) where session_id is not null;
create index push_devices_check_idx on public.push_devices (last_checked_at nulls first);

comment on column public.push_devices.session_id is
  'The auth session that registered the token; signing out deletes the session and with it this row.';

create or replace function private.register_push_device(device_token text, device_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  sid uuid := nullif((select auth.jwt()) ->> 'session_id', '')::uuid;
begin
  if me is null or not private.is_account_active(me) then
    raise exception 'push_forbidden' using errcode = 'P0001';
  end if;
  begin
    insert into public.push_devices (token, user_id, platform, session_id, updated_at)
    values (device_token, me, device_platform, sid, clock_timestamp())
    on conflict (token) do update
      set user_id = excluded.user_id, platform = excluded.platform, session_id = excluded.session_id,
          updated_at = excluded.updated_at;
  exception when foreign_key_violation then
    -- The session was already signed out (its token stays valid for up to an hour): nothing to push to.
    return;
  end;
  -- One device per session: a refreshed FCM token replaces the previous one.
  if sid is not null then
    delete from public.push_devices d where d.session_id = sid and d.token <> device_token;
  end if;
  delete from public.push_devices d
  where d.user_id = me
    and d.token not in (select k.token from public.push_devices k where k.user_id = me order by k.updated_at desc limit 10);
end;
$$;
