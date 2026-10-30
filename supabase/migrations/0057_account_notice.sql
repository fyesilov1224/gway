-- 0057: a suspension with an end date leaves the profile visible with a notice; one without (a ban) hides the account
-- everywhere. The suspended person signs in to a locked screen with the reason instead of being refused by Supabase Auth:
-- the token hook gives a suspended account the `unverified` role, which reads and writes nothing
-- (docs/ARCHITECTURE.md §3a, Hesap yaşam döngüsü; §3h).

-- Visible to others: active, or suspended until a date (in effect or passed). A ban (no end date) and an account being
-- deleted are not.
create function private.is_account_visible(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select s.status = 'active' or (s.status = 'suspended' and s.suspended_until is not null)
    from public.account_status s
    where s.user_id = uid
  ), false);
$$;

revoke all on function private.is_account_visible(uuid) from public;
grant execute on function private.is_account_visible(uuid) to anon, authenticated, service_role;

drop policy profiles_select_visible on public.profiles;
create policy profiles_select_visible
  on public.profiles for select to anon, authenticated
  using (
    id = (select auth.uid())
    or (select private.is_platform_staff())
    or (
      private.is_account_visible(id)
      and not private.has_blocked(id, (select auth.uid()))
    )
  );

-- The notice on a suspended profile: only the end date; the reason stays with the person and the platform team.
create function private.account_notice(target_user uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object('suspended_until', s.suspended_until)
  from public.account_status s
  where s.user_id = target_user
    and s.status = 'suspended' and s.suspended_until > now()
    and not private.has_blocked(target_user, (select auth.uid()));
$$;

create function public.account_notice(target_user uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.account_notice(target_user);
$$;

revoke all on function private.account_notice(uuid), public.account_notice(uuid) from public;
grant execute on function private.account_notice(uuid), public.account_notice(uuid) to anon, authenticated;

-- A suspension in effect always restricts the token, whether or not security enforcement is on.
create or replace function private.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  uid uuid := (event ->> 'user_id')::uuid;
  sid uuid := nullif(event -> 'claims' ->> 'session_id', '')::uuid;
begin
  if exists (
    select 1 from public.account_status s
    where s.user_id = uid and s.status = 'suspended' and (s.suspended_until is null or s.suspended_until > now())
  ) then
    return jsonb_set(event, '{claims,role}', '"unverified"');
  end if;
  if not coalesce((select s.enforce from public.security_settings s), false) then
    return event;
  end if;
  if private.is_session_verified(uid, sid) then
    return event;
  end if;
  return jsonb_set(event, '{claims,role}', '"unverified"');
end;
$$;

-- The app hears its own suspension at once (RLS: own row).
alter publication supabase_realtime add table public.account_status;

-- Suspensions no longer ban in Supabase Auth; lift the bans earlier suspensions set so those people can read why.
update auth.users u set banned_until = null
from public.account_status s
where s.user_id = u.id and s.status = 'suspended' and u.banned_until is not null;
