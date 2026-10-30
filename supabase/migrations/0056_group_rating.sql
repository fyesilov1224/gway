-- 0056: the group's rating is the average of the reviews of its events, shown on the group page; the events section also
-- lists what the viewer may still review (docs/ARCHITECTURE.md §3b, Organizasyon sonrası: Grubun puanı). Nothing is
-- rated on the group itself.

create function private.group_rating(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case when private.is_group_visible(target_group) then (
    select jsonb_build_object('avg', round(avg(r.rating), 1), 'count', count(*))
    from public.event_reviews r
    join public.events e on e.id = r.event_id
    where e.group_id = target_group and e.canceled_at is null
    having count(*) > 0
  ) end;
$$;

revoke all on function private.group_rating(uuid) from public;
grant execute on function private.group_rating(uuid) to anon, authenticated, service_role;

-- The viewer's ended events of the group that still await their review (newest first, at most three).
create function private.group_events_to_review(target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select jsonb_agg(private.event_card(x) order by x.starts_at desc)
    from public.events x
    where x.id in (
      select e.id from public.events e
      where e.group_id = target_group
        and private.can_review_event(e.id, (select auth.uid()))
        and not exists (select 1 from public.event_reviews r where r.event_id = e.id and r.user_id = (select auth.uid()))
      order by e.starts_at desc
      limit 3
    )), '[]'::jsonb);
$$;

revoke all on function private.group_events_to_review(uuid) from public;
grant execute on function private.group_events_to_review(uuid) to anon, authenticated, service_role;

create or replace function public.group_events(target_group uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'events', coalesce((select jsonb_agg(private.event_card(e) order by e.starts_at)
                        from public.events e where e.group_id = target_group and e.starts_at > now()), '[]'),
    'events_left', case when private.has_group_permission(target_group, 'events.manage')
                        then private.group_events_left(target_group) end,
    'rating', private.group_rating(target_group),
    'to_review', private.group_events_to_review(target_group)
  );
$$;
