-- 0011_poll_results_invoker
-- Keeps SECURITY DEFINER out of the exposed public schema (docs/ARCHITECTURE.md §6):
-- group_polls becomes a security invoker wrapper around private.group_polls,
-- which counts votes that RLS hides on anonymous polls. Visitors (anon) read
-- event pages, so they may run the permission check (false without a user).

grant execute on function private.has_group_permission(uuid, text), private.group_events_left(uuid) to anon;

drop function if exists public.group_polls(uuid, uuid);

create or replace function private.group_polls(target_group uuid, target_event uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when not (private.is_group_member(target_group) or private.is_platform_staff()) then '[]'::jsonb else coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', p.id,
      'event_id', p.event_id,
      'question', p.question,
      'allows_multiple', p.allows_multiple,
      'is_anonymous', p.is_anonymous,
      'closes_at', p.closes_at,
      'is_open', private.is_poll_open(p),
      'created_at', p.created_at,
      'voters', (select count(distinct v.user_id) from public.poll_votes v where v.poll_id = p.id),
      'options', (select jsonb_agg(jsonb_build_object(
                    'id', o.id,
                    'label', o.label,
                    'votes', (select count(*) from public.poll_votes v where v.option_id = o.id),
                    'mine', exists (select 1 from public.poll_votes v where v.option_id = o.id and v.user_id = (select auth.uid()))
                  ) order by o.position) from public.poll_options o where o.poll_id = p.id)
    ) order by private.is_poll_open(p) desc, p.created_at desc)
    from (select * from public.polls
          where group_id = target_group
            and (target_event is null or event_id = target_event)
          order by created_at desc limit 20) p
  ), '[]') end;
$$;

revoke all on function private.group_polls(uuid, uuid) from public;
grant execute on function private.group_polls(uuid, uuid) to authenticated;

-- Polls of a group (or of one event) with results; members and staff only. Anonymous polls never reveal voters.
create function public.group_polls(target_group uuid, target_event uuid default null)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.group_polls(target_group, target_event);
$$;

revoke all on function public.group_polls(uuid, uuid) from public;
grant execute on function public.group_polls(uuid, uuid) to authenticated;
