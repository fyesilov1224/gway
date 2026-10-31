-- 0060: three rules opened after the 1000-user run (user decision, 2026-10-30; docs/ARCHITECTURE.md §3c, §7).
-- 1. Everyone who sees a post may comment on it; its owner can still turn comments off.
-- 2. Every member posts to the group's feed (not only the owner and Yöneticiler); a muted member cannot. The author or
--    a posts.publish holder edits and deletes a group post.
-- 3. The free plan allows 100 members and 4 events a month (was 50 and 2).

-- 1 ------------------------------------------------------------------------------------------------------------------
create or replace function private.can_comment_as(uid uuid, target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  -- Seeing the post is checked by the comments policy (private.can_view_post).
  select exists (
    select 1 from public.posts p
    where p.id = target and p.removed_at is null and not p.comments_disabled
  );
$$;

-- 2 ------------------------------------------------------------------------------------------------------------------
create function private.can_post_in_group(uid uuid, target_group uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.groups g where g.id = target_group and g.status = 'active')
    and exists (select 1 from public.group_members m where m.group_id = target_group and m.user_id = uid)
    and not private.is_group_muted(target_group, uid);
$$;

revoke all on function private.can_post_in_group(uuid, uuid) from public;
grant execute on function private.can_post_in_group(uuid, uuid) to authenticated, service_role;

create or replace function private.posts_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.author_id or not private.is_account_active(actor) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    if new.group_id is not null and not private.can_post_in_group(actor, new.group_id) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    if (select count(*) from public.posts p where p.author_id = actor and p.created_at > now() - interval '24 hours') >= 25 then
      perform private.raise_feed_rule('post_rate_limited');
    end if;
    new.caption := btrim(new.caption);
    new.like_count := 0;
    new.comment_count := 0;
    new.created_at := now();
    new.edited_at := null;
    new.removed_at := null;
    new.removed_reason := null;
    new.removed_by := null;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 or (old.group_id is not null and not exists (select 1 from public.groups g where g.id = old.group_id)) then
      return old;
    end if;
    if not private.can_manage_post(old.id) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    return old;
  end if;

  -- Counters and the author link (account deletion) change through nested triggers and cascades.
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.group_id, new.created_at) is distinct from (old.id, old.group_id, old.created_at)
     or (new.author_id is distinct from old.author_id and new.author_id is not null) then
    perform private.raise_feed_rule('post_immutable');
  end if;
  if (new.removed_at, new.removed_reason) is distinct from (old.removed_at, old.removed_reason) then
    if not private.is_platform_staff(array['admin', 'moderator']) then
      perform private.raise_feed_rule('post_removal_forbidden');
    end if;
    new.removed_by := actor;
  end if;
  if (new.caption, new.comments_disabled, new.hide_like_count) is distinct from (old.caption, old.comments_disabled, old.hide_like_count) then
    if not private.can_manage_post(old.id) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    new.caption := btrim(new.caption);
    if new.caption is distinct from old.caption then
      new.edited_at := now();
    end if;
  end if;
  if (new.like_count, new.comment_count) is distinct from (old.like_count, old.comment_count) then
    perform private.raise_feed_rule('post_immutable');
  end if;
  return new;
end;
$$;

create or replace function private.can_manage_post(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.posts p
    where p.id = target
      and (p.author_id = (select auth.uid())
           or (p.group_id is not null and private.has_group_permission(p.group_id, 'posts.publish')))
  );
$$;

create or replace function public.my_publishable_groups()
returns table (id uuid, name text, handle text, logo_path text)
language sql
stable
security invoker
set search_path = ''
as $$
  select g.id, g.name, g.handle, g.logo_path
  from public.groups g
  join public.group_members m on m.group_id = g.id and m.user_id = (select auth.uid())
  where private.can_post_in_group((select auth.uid()), g.id)
  order by g.name;
$$;

update public.group_permissions set description = 'Grubun bütün gönderilerini düzenleme ve silme; grup gönderilerindeki yorumları silme'
where slug = 'posts.publish';

-- 3 ------------------------------------------------------------------------------------------------------------------
-- The plans guard admits only a platform admin's session; a migration speaks for the platform.
alter table public.plans disable trigger plans_guard;
update public.plans set max_members = 100, monthly_events = 4 where slug = 'free';
alter table public.plans enable trigger plans_guard;
