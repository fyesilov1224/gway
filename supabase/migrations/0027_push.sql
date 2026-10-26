-- 0027_push
-- Push notifications over FCM: the devices of each user, and which notifications
-- the backend has already pushed and to how many devices.
-- Rules: docs/ARCHITECTURE.md §3c (Bildirimler, Push).

-- ---------------------------------------------------------------------------
-- push_devices
-- owner: notifications
-- ---------------------------------------------------------------------------
create table public.push_devices (
  token      text primary key check (char_length(token) between 20 and 4096),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  platform   text not null check (platform in ('android', 'ios', 'web')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index push_devices_user_idx on public.push_devices (user_id, updated_at desc);

comment on table public.push_devices is
  'owner: notifications. FCM tokens of signed-in devices; registered with register_push_device, read by the backend.';

alter table public.push_devices enable row level security;
revoke all on public.push_devices from anon, authenticated;
grant select, delete on public.push_devices to authenticated;

create policy push_devices_select_own on public.push_devices for select to authenticated
  using (user_id = (select auth.uid()));
create policy push_devices_delete_own on public.push_devices for delete to authenticated
  using (user_id = (select auth.uid()));

-- A token belongs to whoever signed in on that device last; at most 10 devices a person.
create function private.register_push_device(device_token text, device_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if me is null or not private.is_account_active(me) then
    raise exception 'push_forbidden' using errcode = 'P0001';
  end if;
  insert into public.push_devices (token, user_id, platform, updated_at)
  values (device_token, me, device_platform, clock_timestamp())
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform, updated_at = excluded.updated_at;
  delete from public.push_devices d
  where d.user_id = me
    and d.token not in (select k.token from public.push_devices k where k.user_id = me order by k.updated_at desc limit 10);
end;
$$;

create function public.register_push_device(device_token text, device_platform text)
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.register_push_device(device_token, device_platform);
$$;

revoke all on function private.register_push_device(text, text), public.register_push_device(text, text) from public;
grant execute on function private.register_push_device(text, text), public.register_push_device(text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Push queue: notifications without pushed_at are waiting for the backend
-- ---------------------------------------------------------------------------
alter table public.notifications add column pushed_at timestamptz;
-- How many devices accepted the push; read by the admin panel.
alter table public.notifications add column push_deliveries int not null default 0;
-- Earlier notifications are never pushed.
update public.notifications set pushed_at = created_at;
create index notifications_push_queue_idx on public.notifications (id) where pushed_at is null;
