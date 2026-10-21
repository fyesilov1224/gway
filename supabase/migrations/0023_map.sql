-- 0023_map
-- Phase 14: provinces with their centers, a group's province, an event's meeting point and the
-- map query. Rules: docs/ARCHITECTURE.md §3d (Harita ile keşif).

-- ---------------------------------------------------------------------------
-- provinces
-- owner: core
-- ---------------------------------------------------------------------------
create table public.provinces (
  id   smallint primary key check (id between 1 and 81),
  name text not null unique,
  lat  double precision not null,
  lng  double precision not null
);

comment on table public.provinces is 'owner: core. Turkey''s 81 provinces by plate number, with the center of each.';

insert into public.provinces (id, name, lat, lng) values
  (1, 'Adana', 37.0000, 35.3213), (2, 'Adıyaman', 37.7648, 38.2786), (3, 'Afyonkarahisar', 38.7507, 30.5567),
  (4, 'Ağrı', 39.7191, 43.0503), (5, 'Amasya', 40.6499, 35.8353), (6, 'Ankara', 39.9334, 32.8597),
  (7, 'Antalya', 36.8969, 30.7133), (8, 'Artvin', 41.1828, 41.8183), (9, 'Aydın', 37.8560, 27.8416),
  (10, 'Balıkesir', 39.6484, 27.8826), (11, 'Bilecik', 40.1451, 29.9799), (12, 'Bingöl', 38.8847, 40.4939),
  (13, 'Bitlis', 38.4006, 42.1095), (14, 'Bolu', 40.7350, 31.6061), (15, 'Burdur', 37.7203, 30.2908),
  (16, 'Bursa', 40.1826, 29.0665), (17, 'Çanakkale', 40.1553, 26.4142), (18, 'Çankırı', 40.6013, 33.6134),
  (19, 'Çorum', 40.5506, 34.9556), (20, 'Denizli', 37.7765, 29.0864), (21, 'Diyarbakır', 37.9144, 40.2306),
  (22, 'Edirne', 41.6771, 26.5557), (23, 'Elazığ', 38.6810, 39.2264), (24, 'Erzincan', 39.7500, 39.5000),
  (25, 'Erzurum', 39.9043, 41.2679), (26, 'Eskişehir', 39.7767, 30.5206), (27, 'Gaziantep', 37.0662, 37.3833),
  (28, 'Giresun', 40.9128, 38.3895), (29, 'Gümüşhane', 40.4603, 39.4814), (30, 'Hakkari', 37.5744, 43.7408),
  (31, 'Hatay', 36.2025, 36.1606), (32, 'Isparta', 37.7648, 30.5566), (33, 'Mersin', 36.8121, 34.6415),
  (34, 'İstanbul', 41.0082, 28.9784), (35, 'İzmir', 38.4237, 27.1428), (36, 'Kars', 40.6013, 43.0975),
  (37, 'Kastamonu', 41.3887, 33.7827), (38, 'Kayseri', 38.7312, 35.4787), (39, 'Kırklareli', 41.7333, 27.2167),
  (40, 'Kırşehir', 39.1425, 34.1709), (41, 'Kocaeli', 40.7654, 29.9408), (42, 'Konya', 37.8746, 32.4932),
  (43, 'Kütahya', 39.4167, 29.9833), (44, 'Malatya', 38.3552, 38.3095), (45, 'Manisa', 38.6191, 27.4289),
  (46, 'Kahramanmaraş', 37.5858, 36.9371), (47, 'Mardin', 37.3212, 40.7245), (48, 'Muğla', 37.2153, 28.3636),
  (49, 'Muş', 38.7432, 41.5064), (50, 'Nevşehir', 38.6244, 34.7239), (51, 'Niğde', 37.9667, 34.6833),
  (52, 'Ordu', 40.9839, 37.8764), (53, 'Rize', 41.0201, 40.5234), (54, 'Sakarya', 40.7569, 30.3783),
  (55, 'Samsun', 41.2928, 36.3313), (56, 'Siirt', 37.9333, 41.9500), (57, 'Sinop', 42.0231, 35.1531),
  (58, 'Sivas', 39.7477, 37.0179), (59, 'Tekirdağ', 40.9833, 27.5167), (60, 'Tokat', 40.3167, 36.5500),
  (61, 'Trabzon', 41.0015, 39.7178), (62, 'Tunceli', 39.1079, 39.5401), (63, 'Şanlıurfa', 37.1591, 38.7969),
  (64, 'Uşak', 38.6823, 29.4082), (65, 'Van', 38.4891, 43.4089), (66, 'Yozgat', 39.8181, 34.8147),
  (67, 'Zonguldak', 41.4564, 31.7987), (68, 'Aksaray', 38.3687, 34.0370), (69, 'Bayburt', 40.2552, 40.2249),
  (70, 'Karaman', 37.1759, 33.2287), (71, 'Kırıkkale', 39.8468, 33.5153), (72, 'Batman', 37.8812, 41.1351),
  (73, 'Şırnak', 37.5164, 42.4611), (74, 'Bartın', 41.6344, 32.3375), (75, 'Ardahan', 41.1105, 42.7022),
  (76, 'Iğdır', 39.9237, 44.0450), (77, 'Yalova', 40.6500, 29.2667), (78, 'Karabük', 41.2061, 32.6204),
  (79, 'Kilis', 36.7184, 37.1212), (80, 'Osmaniye', 37.0742, 36.2478), (81, 'Düzce', 40.8438, 31.1565);

alter table public.provinces enable row level security;
revoke all on public.provinces from anon, authenticated;
grant select on public.provinces to anon, authenticated;
create policy provinces_select_all on public.provinces for select to anon, authenticated using (true);

-- ---------------------------------------------------------------------------
-- groups.province (groups)
-- ---------------------------------------------------------------------------
alter table public.groups add column province smallint references public.provinces (id);

comment on column public.groups.province is 'Optional; the group is shown at the province center on the map.';

create function private.groups_province_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.province is distinct from old.province and not private.has_group_permission(old.id, 'group.edit') then
    perform private.raise_group_rule('group_edit_forbidden');
  end if;
  return new;
end;
$$;

create trigger groups_province_guard
  before update of province on public.groups
  for each row execute function private.groups_province_guard();

-- ---------------------------------------------------------------------------
-- events meeting point (events)
-- ---------------------------------------------------------------------------
alter table public.events
  add column meeting_lat double precision check (meeting_lat between -90 and 90),
  add column meeting_lng double precision check (meeting_lng between -180 and 180),
  add constraint events_meeting_point_pair check ((meeting_lat is null) = (meeting_lng is null));

create index events_meeting_point_idx on public.events (meeting_lat, meeting_lng)
  where meeting_lat is not null and canceled_at is null;

-- Events: as in 0014, with the meeting point among the edited fields. Platform staff may remove
-- a meeting point (an inappropriate place) without the events.manage permission.
create or replace function private.events_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  staff_removes_point boolean;
begin
  if tg_op = 'DELETE' then
    if not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_event_rule('event_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.created_by or not private.has_group_permission(new.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if new.starts_at < now() + interval '14 minutes' or new.starts_at > now() + interval '1 year' then
      perform private.raise_event_rule('event_time_invalid');
    end if;
    -- Locking the group serializes concurrent creations against the monthly limit.
    perform 1 from public.groups where id = new.group_id for update;
    if private.group_events_left(new.group_id) <= 0 then
      perform private.raise_event_rule('monthly_limit_reached');
    end if;
    new.title := btrim(new.title);
    new.location := btrim(new.location);
    new.requirements := btrim(new.requirements);
    new.equipment := private.clean_equipment(new.equipment);
    new.going_count := 0;
    new.waitlist_count := 0;
    new.canceled_at := null;
    new.cancel_reason := null;
    new.reminded_day_at := null;
    new.reminded_hour_at := null;
    new.created_at := now();
    new.updated_at := now();
    return new;
  end if;

  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.group_id, new.created_at) is distinct from (old.id, old.group_id, old.created_at)
     or (new.created_by is distinct from old.created_by and new.created_by is not null)
     or (new.going_count, new.waitlist_count) is distinct from (old.going_count, old.waitlist_count) then
    perform private.raise_event_rule('event_immutable');
  end if;
  if (new.reminded_day_at, new.reminded_hour_at) is distinct from (old.reminded_day_at, old.reminded_hour_at) and actor is not null then
    perform private.raise_event_rule('event_immutable');
  end if;

  if new.canceled_at is distinct from old.canceled_at or new.cancel_reason is distinct from old.cancel_reason then
    if old.canceled_at is not null or new.canceled_at is null then
      perform private.raise_event_rule('event_already_canceled');
    end if;
    if not (private.has_group_permission(old.group_id, 'events.manage') or private.is_platform_staff(array['admin', 'moderator'])) then
      perform private.raise_event_rule('event_forbidden');
    end if;
    new.canceled_at := now();
  end if;

  staff_removes_point := old.meeting_lat is not null and new.meeting_lat is null and new.meeting_lng is null
    and private.is_platform_staff(array['admin', 'moderator']);

  if (new.title, new.description, new.starts_at, new.ends_at, new.location, new.link_url, new.capacity,
      new.fee_amount, new.fee_currency, new.fee_note, new.cover_path, new.requirements, new.equipment, new.approval_required)
     is distinct from
     (old.title, old.description, old.starts_at, old.ends_at, old.location, old.link_url, old.capacity,
      old.fee_amount, old.fee_currency, old.fee_note, old.cover_path, old.requirements, old.equipment, old.approval_required)
     or (not staff_removes_point and (new.meeting_lat, new.meeting_lng) is distinct from (old.meeting_lat, old.meeting_lng)) then
    if not private.has_group_permission(old.group_id, 'events.manage') then
      perform private.raise_event_rule('event_forbidden');
    end if;
    if old.canceled_at is not null or old.starts_at <= now() then
      perform private.raise_event_rule('event_closed');
    end if;
    if new.starts_at is distinct from old.starts_at
       and (new.starts_at < now() + interval '14 minutes' or new.starts_at > now() + interval '1 year') then
      perform private.raise_event_rule('event_time_invalid');
    end if;
    if new.capacity is not null and new.capacity < old.going_count then
      perform private.raise_event_rule('capacity_below_going');
    end if;
    new.title := btrim(new.title);
    new.location := btrim(new.location);
    new.requirements := btrim(new.requirements);
    new.equipment := private.clean_equipment(new.equipment);
    new.updated_at := now();
  end if;
  return new;
end;
$$;

-- As in 0016, with the meeting point.
create or replace function private.event_card(e public.events)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', e.id,
    'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path),
    'category', jsonb_build_object('slug', c.slug, 'name', c.name),
    'title', e.title,
    'description', e.description,
    'starts_at', e.starts_at,
    'ends_at', e.ends_at,
    'location', e.location,
    'meeting', case when e.meeting_lat is null then null
                    else jsonb_build_object('lat', e.meeting_lat, 'lng', e.meeting_lng) end,
    'link_url', e.link_url,
    'capacity', e.capacity,
    'fee_amount', e.fee_amount,
    'fee_currency', e.fee_currency,
    'fee_note', e.fee_note,
    'cover_path', e.cover_path,
    'requirements', e.requirements,
    'equipment', to_jsonb(e.equipment),
    'approval_required', e.approval_required,
    'going_count', e.going_count,
    'waitlist_count', e.waitlist_count,
    'canceled_at', e.canceled_at,
    'cancel_reason', e.cancel_reason,
    'rating_avg', (select round(avg(r.rating), 1) from public.event_reviews r where r.event_id = e.id),
    'rating_count', (select count(*) from public.event_reviews r where r.event_id = e.id),
    'posts_count', (select count(*) from public.posts p where p.event_id = e.id and p.removed_at is null),
    'my_status', (select a.status from public.event_attendees a where a.event_id = e.id and a.user_id = (select auth.uid())),
    'my_place', (select count(*) + 1 from public.event_attendees w, public.event_attendees me
                 where me.event_id = e.id and me.user_id = (select auth.uid()) and me.status = 'waitlisted'
                   and w.event_id = e.id and w.status = 'waitlisted' and (w.created_at, w.user_id) < (me.created_at, me.user_id))
  )
  from public.groups g
  join public.categories c on c.slug = g.category_slug
  where g.id = e.group_id;
$$;

-- ---------------------------------------------------------------------------
-- Map
-- ---------------------------------------------------------------------------

-- Active groups at their province center and upcoming events at their meeting point, inside the box.
create function private.map_items(south double precision, west double precision, north double precision,
                                  east double precision, category text default null)
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
        order by e.starts_at, e.id
        limit 200
      ) found), '[]'::jsonb)
  );
$$;

create function public.map_items(south double precision, west double precision, north double precision,
                                 east double precision, category text default null)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.map_items(south, west, north, east, category);
$$;

revoke all on function private.map_items(double precision, double precision, double precision, double precision, text) from public;
grant execute on function private.map_items(double precision, double precision, double precision, double precision, text) to authenticated;
revoke all on function public.map_items(double precision, double precision, double precision, double precision, text) from public, anon;
grant execute on function public.map_items(double precision, double precision, double precision, double precision, text) to authenticated;
