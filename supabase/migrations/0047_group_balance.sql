-- 0047: balance between groups of the same kind (docs/ARCHITECTURE.md §3b, Gruplar arası denge).
--
-- Members stay free to join any group; what one group sees of another is limited. A membership
-- row is visible to the person, to the group's own members and to platform staff; the group's
-- team (owner and role holders) stays public, and a person may make all their memberships
-- public. Groups send at most 50 invitations a day.

alter table public.profiles add column groups_public boolean not null default false;

comment on column public.profiles.groups_public is
  'When false (default) a membership is shown only to members of that group; the group team is always public.';

grant update (groups_public) on public.profiles to authenticated;

-- Owner or role holder of the group: the public team.
create function private.is_group_team(target_group uuid, uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.groups g where g.id = target_group and g.owner_id = uid)
      or exists (select 1 from public.group_member_roles r where r.group_id = target_group and r.user_id = uid);
$$;

create function private.are_groups_public(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((select p.groups_public from public.profiles p where p.id = uid), false);
$$;

revoke all on function private.is_group_team(uuid, uuid) from public;
revoke all on function private.are_groups_public(uuid) from public;
grant execute on function private.is_group_team(uuid, uuid) to anon, authenticated, service_role;
grant execute on function private.are_groups_public(uuid) to anon, authenticated, service_role;

drop policy group_members_select_visible on public.group_members;
create policy group_members_select_visible
  on public.group_members for select to anon, authenticated
  using (
    private.is_group_visible(group_id)
    and (
      user_id = (select auth.uid())
      or (select private.is_platform_staff())
      or (
        private.is_account_active(user_id)
        and (private.is_group_member(group_id) or private.is_group_team(group_id, user_id) or private.are_groups_public(user_id))
      )
    )
  );

-- Invitations sent by a group in the last 24 hours, revoked ones included.
create function private.group_invitations_sent_today(target_group uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::integer from public.audit_log a
  where a.group_id = target_group and a.action = 'group.invitation_sent' and a.occurred_at > now() - interval '24 hours';
$$;

revoke all on function private.group_invitations_sent_today(uuid) from public;
grant execute on function private.group_invitations_sent_today(uuid) to authenticated, service_role;

create or replace function private.group_invitations_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if not private.has_group_permission(new.group_id, 'members.invite')
       or not private.is_account_active(new.user_id)
       or exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = new.user_id) then
      perform private.raise_group_rule('invitation_not_allowed');
    end if;
    if private.group_invitations_sent_today(new.group_id) >= 50 then
      perform private.raise_group_rule('invitation_limit_reached');
    end if;
    new.invited_by := actor;
    new.created_at := now();
    return new;
  end if;

  if not exists (select 1 from public.groups g where g.id = old.group_id)
     or not exists (select 1 from public.profiles p where p.id = old.user_id) then
    return old;
  end if;
  if actor is distinct from old.user_id and not private.has_group_permission(old.group_id, 'members.invite') then
    perform private.raise_group_rule('invitation_forbidden');
  end if;
  return old;
end;
$$;

-- Other groups' events on the same day, same province and category (the event form shows the
-- number only). Null when the group has no province.
create function public.similar_events_count(target_group uuid, day_start timestamptz, day_end timestamptz)
returns integer
language sql
stable
security invoker
set search_path = ''
as $$
  select case when me.province is null then null else (
    select count(*)::integer
    from public.events e
    join public.groups g on g.id = e.group_id
    where g.id <> me.id and g.status = 'active' and g.category_slug = me.category_slug and g.province = me.province
      and e.canceled_at is null and e.starts_at >= day_start and e.starts_at < day_end
  ) end
  from public.groups me
  where me.id = target_group and day_end > day_start and day_end - day_start <= interval '2 days';
$$;

revoke all on function public.similar_events_count(uuid, timestamptz, timestamptz) from public, anon;
grant execute on function public.similar_events_count(uuid, timestamptz, timestamptz) to authenticated;
