-- 0088_admin_call_permissions
-- The platform team decides voice call permissions again, beside the groups (docs/ARCHITECTURE.md §8c, Admin: Sesli
-- görüşme sekmesi; user decision 2026-11-06). The backend writes; this trigger is the second layer: admins and support
-- may open (also for someone who never asked), decline a waiting request and close an open permission. The panel reads
-- through the backend, so the read policy stays as it is (the person and the group's managers).

create or replace function private.call_permissions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  -- Written by another trigger (leaving the group).
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if new.status = 'requested' then
    if actor is null or actor <> new.user_id or new.group_id is null
       or not exists (select 1 from public.group_members m where m.group_id = new.group_id and m.user_id = actor)
       or not exists (select 1 from public.groups g where g.id = new.group_id and g.status = 'active') then
      raise exception 'call_forbidden' using errcode = 'P0001';
    end if;
    return new;
  end if;
  -- The platform team (admin, support), never on their own permission. No rank rule: that is the group's.
  if actor is not null and actor <> new.user_id and private.is_platform_staff(array['admin', 'support']) then
    if tg_op = 'INSERT' then
      if new.status <> 'active' then
        raise exception 'call_forbidden' using errcode = 'P0001';
      end if;
    elsif new.user_id <> old.user_id
       or not (old.status in ('requested', 'declined', 'revoked') and new.status = 'active'
               or old.status = 'requested' and new.status = 'declined'
               or old.status = 'active' and new.status = 'revoked') then
      raise exception 'call_forbidden' using errcode = 'P0001';
    end if;
    new.decided_by := actor;
    new.decided_at := now();
    return new;
  end if;
  if tg_op <> 'UPDATE' or actor is null or actor = new.user_id or old.group_id is null
     or new.group_id is distinct from old.group_id
     or not private.user_has_group_permission(actor, old.group_id, 'calls.manage')
     or not exists (select 1 from public.group_members m where m.group_id = old.group_id and m.user_id = new.user_id)
     or not (old.status = 'requested' and new.status in ('active', 'declined')
             or old.status = 'active' and new.status = 'revoked') then
    raise exception 'call_forbidden' using errcode = 'P0001';
  end if;
  if new.status in ('declined', 'revoked')
     and private.group_rank(old.group_id, actor) <= private.group_rank(old.group_id, new.user_id) then
    raise exception 'call_rank_violation' using errcode = 'P0001';
  end if;
  new.decided_by := actor;
  new.decided_at := now();
  return new;
end;
$$;

revoke all on function private.call_permissions_guard() from public;
