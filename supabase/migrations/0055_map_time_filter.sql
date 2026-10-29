-- 0055: the map shows what starts soon — events before a time ("Bugün", "7 gün içinde"); groups, which have no time,
-- drop out of such a view (docs/ARCHITECTURE.md §3d, Harita ile keşif; Faz 18m). Distance is measured on the device from
-- the map's center; nobody's location is used.

drop function public.map_items(double precision, double precision, double precision, double precision, text);
drop function private.map_items(double precision, double precision, double precision, double precision, text);

create function private.map_items(south double precision, west double precision, north double precision,
                                  east double precision, category text default null,
                                  starts_before timestamptz default null)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'groups', coalesce((
      select jsonb_agg(item order by members desc, id)
      from (
        select g.id, g.member_count as members, jsonb_build_object(
          'id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path, 'member_count', g.member_count,
          'category', jsonb_build_object('slug', c.slug, 'name', c.name),
          'province', p.id, 'lat', p.lat, 'lng', p.lng) as item
        from public.groups g
        join public.provinces p on p.id = g.province
        join public.categories c on c.slug = g.category_slug
        where g.status = 'active'
          and p.lat between map_items.south and map_items.north and p.lng between map_items.west and map_items.east
          and (map_items.category is null or g.category_slug = map_items.category)
          and map_items.starts_before is null
        order by g.member_count desc, g.id
        limit 200
      ) found), '[]'::jsonb),
    'events', coalesce((
      select jsonb_agg(item order by starts, id)
      from (
        select e.id, e.starts_at as starts, jsonb_build_object(
          'id', e.id, 'title', e.title, 'starts_at', e.starts_at, 'location', e.location,
          'going_count', e.going_count, 'capacity', e.capacity, 'lat', e.meeting_lat, 'lng', e.meeting_lng,
          'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
          'category', jsonb_build_object('slug', c.slug, 'name', c.name)) as item
        from public.events e
        join public.groups g on g.id = e.group_id
        join public.categories c on c.slug = g.category_slug
        where g.status = 'active' and e.canceled_at is null and e.starts_at > now() and e.meeting_lat is not null
          and e.meeting_lat between map_items.south and map_items.north and e.meeting_lng between map_items.west and map_items.east
          and (map_items.category is null or g.category_slug = map_items.category)
          and (map_items.starts_before is null or e.starts_at < map_items.starts_before)
        order by e.starts_at, e.id
        limit 200
      ) found), '[]'::jsonb)
  );
$$;

create function public.map_items(south double precision, west double precision, north double precision,
                                 east double precision, category text default null,
                                  starts_before timestamptz default null)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.map_items(south, west, north, east, category, starts_before);
$$;

revoke all on function private.map_items(double precision, double precision, double precision, double precision, text, timestamptz) from public;
grant execute on function private.map_items(double precision, double precision, double precision, double precision, text, timestamptz) to authenticated;
revoke all on function public.map_items(double precision, double precision, double precision, double precision, text, timestamptz) from public, anon;
grant execute on function public.map_items(double precision, double precision, double precision, double precision, text, timestamptz) to authenticated;
