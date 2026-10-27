-- Richer teammate preferences (docs/ARCHITECTURE.md §3c Ekip arkadaşı, user request 2026-10-27): activities, goals,
-- how often, group size, vehicle and equipment, and six time slots. Suggestions score the new answers too.
-- owner: profile

alter table public.teammate_preferences drop constraint teammate_preferences_availability_check;
alter table public.teammate_preferences
  add constraint teammate_preferences_availability_check check (availability <@ array[
    'weekday_morning', 'weekday_noon', 'weekday_evening', 'weekend_morning', 'weekend_afternoon', 'weekend_evening']),
  add column activities text[] not null default '{}' check (cardinality(activities) <= 8),
  add column goals text[] not null default '{}'
    check (goals <@ array['fun', 'fitness', 'competition', 'learning', 'mentoring', 'social']),
  add column frequency text check (frequency in ('monthly', 'weekly', 'few_weekly', 'daily')),
  add column group_sizes text[] not null default '{}' check (group_sizes <@ array['pair', 'small', 'large']),
  add column has_vehicle boolean not null default false,
  add column has_equipment boolean not null default false;

comment on column public.teammate_preferences.activities is 'Category slugs the person wants teammates for (up to 8).';

grant insert (activities, goals, frequency, group_sizes, has_vehicle, has_equipment),
  update (activities, goals, frequency, group_sizes, has_vehicle, has_equipment) on public.teammate_preferences to authenticated;

-- Activities must be categories; the note and lists are tidied (as in 0021, plus the activities).
create or replace function private.teammate_preferences_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if exists (select 1 from unnest(new.activities) a where not exists (select 1 from public.categories c where c.slug = a)) then
    perform private.raise_profile_rule('teammate_activity_invalid');
  end if;
  new.activities := array(select distinct a from unnest(new.activities) a order by a);
  new.goals := array(select distinct g from unnest(new.goals) g order by g);
  new.group_sizes := array(select distinct s from unnest(new.group_sizes) s order by s);
  new.note := btrim(new.note);
  new.updated_at := now();
  return new;
end;
$$;

-- Suggestions (as in 0021, plus shared activities, goals and frequency).
create or replace function private.teammate_suggestions()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (
    select (select auth.uid()) as uid,
           p.level, coalesce(p.availability, '{}') as availability, p.province,
           coalesce(p.activities, '{}') as activities, coalesce(p.goals, '{}') as goals, p.frequency
    from (select 1) one
    left join public.teammate_preferences p on p.user_id = (select auth.uid())
  ),
  candidates as (
    select c.user_id, c.level, c.availability, c.province, c.note, c.has_vehicle, c.has_equipment,
      array(select ci.category_slug from public.profile_interests ci join public.profile_interests mi
            on mi.category_slug = ci.category_slug and mi.user_id = me.uid where ci.user_id = c.user_id) as interests,
      array(select unnest(c.activities) intersect select unnest(me.activities)) as activities,
      array(select unnest(c.goals) intersect select unnest(me.goals)) as goals,
      array(select g.name from public.group_members cm join public.group_members mm
            on mm.group_id = cm.group_id and mm.user_id = me.uid
            join public.groups g on g.id = cm.group_id and g.status = 'active'
            where cm.user_id = c.user_id) as groups,
      array(select unnest(c.availability) intersect select unnest(me.availability)) as times,
      me.level = c.level as same_level,
      me.province is not null and me.province = c.province as same_province,
      me.frequency is not null and me.frequency = c.frequency as same_frequency
    from public.teammate_preferences c
    join public.profiles pr on pr.id = c.user_id
    cross join me
    where me.uid is not null and c.looking and c.user_id <> me.uid and not pr.is_private
      and private.is_account_active(c.user_id)
      and not private.is_blocked_between(c.user_id, me.uid)
      and not private.are_teammates(c.user_id, me.uid)
      and not exists (select 1 from public.teammate_requests r
                      where (r.requester_id = me.uid and r.target_id = c.user_id) or (r.requester_id = c.user_id and r.target_id = me.uid))
  ),
  scored as (
    select *, 3 * cardinality(interests) + 3 * cardinality(activities) + cardinality(goals) + 2 * cardinality(groups)
              + cardinality(times) + case when same_level then 2 else 0 end + case when same_province then 3 else 0 end
              + case when same_frequency then 1 else 0 end as score
    from candidates
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'person', jsonb_build_object('id', p.id, 'username', p.username, 'display_name', p.display_name, 'avatar_path', p.avatar_path,
                                 'bio', p.bio),
    'level', s.level,
    'note', s.note,
    'score', s.score,
    'interests', (select coalesce(jsonb_agg(cat.name order by cat.sort_order), '[]'::jsonb) from public.categories cat where cat.slug = any (s.interests)),
    'activities', (select coalesce(jsonb_agg(cat.name order by cat.sort_order), '[]'::jsonb) from public.categories cat where cat.slug = any (s.activities)),
    'goals', to_jsonb(s.goals),
    'groups', to_jsonb(s.groups),
    'times', to_jsonb(s.times),
    'same_level', coalesce(s.same_level, false),
    'same_province', s.same_province,
    'same_frequency', s.same_frequency,
    'has_vehicle', s.has_vehicle,
    'has_equipment', s.has_equipment
  ) order by s.score desc, p.display_name), '[]'::jsonb)
  from (select * from scored where score >= 3 order by score desc limit 30) s
  join public.profiles p on p.id = s.user_id;
$$;
