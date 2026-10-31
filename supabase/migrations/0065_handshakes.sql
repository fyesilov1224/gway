-- 0065_handshakes
-- Faz 18e: El Sıkış (user decision, 2026-10-31; docs/ARCHITECTURE.md §3d, El sıkış).
-- Two people going to the same event meet by scanning each other's QR code (or typing its short code) from an hour
-- before the start until six hours after the end. The code is the backend's, changes every few minutes and names
-- only its owner and the event. A handshake records "met at this event" on both sides; it gives no messaging right.
-- Only the two see who they met; others see the count with the contributions, and handshakes earn two badges.

-- ---------------------------------------------------------------------------
-- handshake_codes, handshakes (owner: events)
-- ---------------------------------------------------------------------------
create table public.handshake_codes (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  code       text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{6}$'),
  expires_at timestamptz not null,
  primary key (event_id, user_id)
);

comment on table public.handshake_codes is
  'owner: events. The current short-lived handshake code of a person at an event; written and read by the backend only.';

alter table public.handshake_codes enable row level security;
revoke all on table public.handshake_codes from anon, authenticated;

create table public.handshakes (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_a     uuid not null references public.profiles (id) on delete cascade,
  user_b     uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_id, user_a, user_b),
  constraint handshakes_pair check (user_a < user_b)
);

comment on table public.handshakes is 'owner: events. Two people who met at an event (smaller id first); written by the backend.';

create index handshakes_user_a_idx on public.handshakes (user_a, created_at desc);
create index handshakes_user_b_idx on public.handshakes (user_b, created_at desc);

alter table public.handshakes enable row level security;
revoke all on table public.handshakes from anon, authenticated;
grant select on table public.handshakes to authenticated;

create policy handshakes_select_own on public.handshakes for select to authenticated
  using ((select auth.uid()) in (user_a, user_b));

-- ---------------------------------------------------------------------------
-- Rules
-- ---------------------------------------------------------------------------
-- From an hour before the start until six hours after the end (two hours long without an end).
create function private.handshake_open(e public.events)
returns boolean
language sql
stable
set search_path = ''
as $$
  select e.canceled_at is null
     and now() between e.starts_at - interval '1 hour' and coalesce(e.ends_at, e.starts_at + interval '2 hours') + interval '6 hours';
$$;

create function private.can_handshake(uid uuid, target_event uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_account_active(uid) and private.is_going(uid, target_event)
     and exists (select 1 from public.events e where e.id = target_event and private.handshake_open(e));
$$;

revoke all on function private.handshake_open(public.events), private.can_handshake(uuid, uuid) from public;

create function private.raise_handshake_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

create function private.handshake_codes_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is distinct from new.user_id then
    perform private.raise_handshake_rule('handshake_forbidden');
  end if;
  if not private.can_handshake(new.user_id, new.event_id) then
    perform private.raise_handshake_rule('handshake_closed');
  end if;
  return new;
end;
$$;

create trigger handshake_codes_guard
  before insert or update on public.handshake_codes
  for each row execute function private.handshake_codes_guard();

create function private.handshakes_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op <> 'INSERT' then
    -- Deleting an account or an event cascades here; nothing else changes a handshake.
    if tg_op = 'DELETE' and pg_trigger_depth() > 1 then
      return old;
    end if;
    perform private.raise_handshake_rule('handshake_immutable');
  end if;
  if actor is null or actor not in (new.user_a, new.user_b) then
    perform private.raise_handshake_rule('handshake_forbidden');
  end if;
  if not (private.can_handshake(new.user_a, new.event_id) and private.can_handshake(new.user_b, new.event_id)) then
    perform private.raise_handshake_rule('handshake_closed');
  end if;
  if private.is_blocked_between(new.user_a, new.user_b) then
    perform private.raise_handshake_rule('blocked');
  end if;
  if (select count(*) from public.handshakes h
      where actor in (h.user_a, h.user_b) and h.created_at > now() - interval '1 day') >= 200 then
    perform private.raise_handshake_rule('handshake_rate_limited');
  end if;
  new.created_at := now();
  return new;
end;
$$;

create trigger handshakes_guard
  before insert or update or delete on public.handshakes
  for each row execute function private.handshakes_guard();

-- ---------------------------------------------------------------------------
-- The other person is told
-- ---------------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked',
                  'welcome_requested', 'welcome_matched', 'welcome_released', 'welcome_withdrawn', 'welcome_thanked',
                  'league_result', 'event_series_limit', 'tonight_table_invite', 'tonight_table_ready',
                  'event_venue_revealed', 'handshake'));

create function private.handshakes_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
  other uuid := case when actor = new.user_a then new.user_b else new.user_a end;
begin
  if private.is_account_active(other) then
    insert into public.notifications (recipient_id, actor_id, type, event_id) values (other, actor, 'handshake', new.event_id);
  end if;
  return null;
end;
$$;

revoke all on function private.handshakes_after_insert() from public;

create trigger handshakes_after_insert
  after insert on public.handshakes
  for each row execute function private.handshakes_after_insert();

-- ---------------------------------------------------------------------------
-- "Tanıştıklarım": only the person's own handshakes
-- ---------------------------------------------------------------------------
create function private.my_handshakes()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'person', private.person(case when h.user_a = (select auth.uid()) then h.user_b else h.user_a end),
           'event', jsonb_build_object('id', e.id, 'title', e.title, 'starts_at', e.starts_at,
                                       'group', jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name)),
           'created_at', h.created_at) order by h.created_at desc), '[]'::jsonb)
  from (select * from public.handshakes
        where (select auth.uid()) in (user_a, user_b)
        order by created_at desc
        limit 500) h
  join public.events e on e.id = h.event_id
  join public.groups g on g.id = e.group_id
  where private.is_account_active(case when h.user_a = (select auth.uid()) then h.user_b else h.user_a end);
$$;

create function public.my_handshakes()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.my_handshakes();
$$;

revoke all on function private.my_handshakes(), public.my_handshakes() from public, anon;
grant execute on function private.my_handshakes(), public.my_handshakes() to authenticated;

-- ---------------------------------------------------------------------------
-- Contributions (0048) count handshakes, with two badges
-- ---------------------------------------------------------------------------
create or replace function public.badge_catalog()
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select '[
    {"slug": "first_step", "name": "İlk adım", "metric": "attended", "threshold": 1, "description": "İlk organizasyonuna katıl."},
    {"slug": "regular", "name": "Müdavim", "metric": "attended", "threshold": 10, "description": "10 organizasyona katıl."},
    {"slug": "companion", "name": "Yol arkadaşı", "metric": "attended", "threshold": 25, "description": "25 organizasyona katıl."},
    {"slug": "explorer", "name": "Kâşif", "metric": "groups", "threshold": 3, "description": "3 farklı grubun organizasyonuna katıl."},
    {"slug": "organizer", "name": "Düzenleyici", "metric": "organized", "threshold": 1, "description": "En az 2 kişinin katıldığı bir organizasyon düzenle."},
    {"slug": "master_organizer", "name": "Usta düzenleyici", "metric": "organized", "threshold": 10, "description": "En az 2 kişinin katıldığı 10 organizasyon düzenle."},
    {"slug": "storyteller", "name": "Anı biriktiren", "metric": "memories", "threshold": 5, "description": "Katıldığın organizasyonlara 5 anı ekle."},
    {"slug": "feedback", "name": "Geri bildirimci", "metric": "reviews", "threshold": 5, "description": "Katıldığın 5 organizasyonu değerlendir."},
    {"slug": "door_opener", "name": "Kapı açan", "metric": "welcomed", "threshold": 1, "description": "Bir organizasyonda ilk kez gelen birini karşıla."},
    {"slug": "host", "name": "Ev sahibi", "metric": "welcomed", "threshold": 5, "description": "İlk kez gelen 5 kişiyi karşıla."},
    {"slug": "community_heart", "name": "Topluluğun kalbi", "metric": "welcomed", "threshold": 20, "description": "İlk kez gelen 20 kişiyi karşıla."},
    {"slug": "friendly", "name": "Tanışkan", "metric": "handshakes", "threshold": 5, "description": "Organizasyonlarda 5 kişiyle el sıkış."},
    {"slug": "social_butterfly", "name": "Sosyal kelebek", "metric": "handshakes", "threshold": 25, "description": "Organizasyonlarda 25 kişiyle el sıkış."},
    {"slug": "category", "name": "tutkunu", "metric": "category", "threshold": 5, "description": "Bir kategoride 5 organizasyona katıl (ör. Yürüyüş tutkunu)."}
  ]'::jsonb;
$$;

create or replace function private.contribution_counts(uid uuid, target_group uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with attended as (
    select e.id, e.group_id, g.category_slug
    from public.event_attendees a
    join public.events e on e.id = a.event_id
    join public.groups g on g.id = e.group_id
    where a.user_id = uid and a.status = 'going' and a.no_show_at is null
      and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
      and (target_group is null or e.group_id = target_group)
  )
  select jsonb_build_object(
    'attended', (select count(*) from attended),
    'groups', (select count(distinct group_id) from attended),
    'organized', (
      select count(*) from public.events e
      where e.created_by = uid and e.canceled_at is null and coalesce(e.ends_at, e.starts_at + interval '2 hours') <= now()
        and (target_group is null or e.group_id = target_group)
        and (select count(*) from public.event_attendees a
             where a.event_id = e.id and a.status = 'going' and a.no_show_at is null and a.user_id <> uid) >= 2),
    'memories', (
      select count(*) from public.posts p join public.events e on e.id = p.event_id
      where p.author_id = uid and p.removed_at is null and (target_group is null or e.group_id = target_group)),
    'reviews', (
      select count(*) from public.event_reviews r join public.events e on e.id = r.event_id
      where r.user_id = uid and (target_group is null or e.group_id = target_group)),
    'welcomed', (
      select count(*) from public.event_welcomes w join attended a on a.id = w.event_id
      where w.greeter_id = uid and private.attended_event(w.newcomer_id, w.event_id)),
    'handshakes', (
      select count(*) from public.handshakes h join public.events e on e.id = h.event_id
      where uid in (h.user_a, h.user_b) and (target_group is null or e.group_id = target_group)),
    'categories', coalesce((select jsonb_object_agg(category_slug, n) from (
      select category_slug, count(*) as n from attended group by category_slug) c), '{}'::jsonb)
  );
$$;
