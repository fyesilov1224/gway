-- Faz 15.6b: Eşleşme Premium (docs/ARCHITECTURE.md §3g Freemium, §7 Kişisel ürünler).
-- Billing sells a personal product and keeps the entitlement; matching asks private.has_matching_premium.
-- Matching adds super likes, boosts, rewinds (backend), the people who liked you and Premium filters.

-- ---------------------------------------------------------------------------
-- Billing: personal plans
-- owner: billing
-- ---------------------------------------------------------------------------
create table public.personal_plans (
  slug       text primary key check (slug ~ '^[a-z_]+$'),
  name       text not null check (char_length(btrim(name)) between 2 and 40),
  is_active  boolean not null default true,
  updated_at timestamptz not null default now()
);

comment on table public.personal_plans is 'owner: billing. Products a person buys for themselves (not for a group).';

create table public.personal_plan_prices (
  plan_slug    text not null references public.personal_plans (slug) on delete cascade,
  currency     text not null check (currency in ('TRY', 'USD')),
  period       text not null check (period in ('month', 'year')),
  amount_minor int  not null check (amount_minor > 0),
  primary key (plan_slug, currency, period)
);

comment on table public.personal_plan_prices is 'owner: billing. List prices in minor units. Orders copy the amount.';

insert into public.personal_plans (slug, name) values ('matching_premium', 'Eşleşme Premium');

insert into public.personal_plan_prices (plan_slug, currency, period, amount_minor) values
  ('matching_premium', 'TRY', 'month', 14900), ('matching_premium', 'TRY', 'year', 149000),
  ('matching_premium', 'USD', 'month',   599), ('matching_premium', 'USD', 'year',    5990);

-- Orders carry either a group plan or a personal plan.
alter table public.billing_orders
  add column personal_plan_slug text references public.personal_plans (slug),
  alter column group_name drop not null,
  alter column group_handle drop not null,
  alter column plan_slug drop not null,
  add constraint billing_orders_product check (
    (personal_plan_slug is null and plan_slug is not null and group_name is not null and group_handle is not null)
    or (personal_plan_slug is not null and plan_slug is null and group_id is null and group_name is null and group_handle is null)
  );

comment on column public.billing_orders.personal_plan_slug is 'Set for a personal product; the group columns are then empty.';

-- Each person's prepaid time per personal plan: back-to-back slices, from an order or granted by an admin.
create table public.user_subscriptions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles (id) on delete cascade,
  plan_slug     text not null references public.personal_plans (slug),
  period        text check (period in ('month', 'year')),
  order_id      uuid unique references public.billing_orders (id),
  granted_by    uuid references public.profiles (id) on delete set null,
  grant_reason  text check (char_length(grant_reason) between 3 and 500),
  starts_at     timestamptz not null,
  ends_at       timestamptz not null,
  canceled_at   timestamptz,
  cancel_reason text check (cancel_reason in ('admin')),
  created_at    timestamptz not null default now(),
  constraint user_subscriptions_range check (ends_at >= starts_at),
  constraint user_subscriptions_source check ((order_id is null) = (grant_reason is not null)),
  constraint user_subscriptions_period check ((order_id is null) = (period is null)),
  constraint user_subscriptions_cancel_consistent check ((canceled_at is null) = (cancel_reason is null)),
  constraint user_subscriptions_no_overlap
    exclude using gist (user_id with =, plan_slug with =, tstzrange(starts_at, ends_at) with &&)
);

comment on table public.user_subscriptions is
  'owner: billing. Personal plan slices per person; written by the backend (paid order or admin grant).';

create index user_subscriptions_user_idx on public.user_subscriptions (user_id, plan_slug, ends_at desc);

alter table public.personal_plans enable row level security;
alter table public.personal_plan_prices enable row level security;
alter table public.user_subscriptions enable row level security;

revoke all on public.personal_plans, public.personal_plan_prices, public.user_subscriptions from anon, authenticated;
grant select on public.personal_plans, public.personal_plan_prices to anon, authenticated;
grant select on public.user_subscriptions to authenticated;

create policy personal_plans_select_all on public.personal_plans for select to anon, authenticated using (true);
create policy personal_plan_prices_select_all on public.personal_plan_prices for select to anon, authenticated using (true);
create policy user_subscriptions_select_own_or_staff on public.user_subscriptions for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_platform_staff()));

-- Personal plans and prices change only on behalf of a platform admin; new plans come with migrations.
create function private.personal_plans_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    perform private.raise_group_rule('plan_delete_forbidden');
  end if;
  if not private.is_platform_staff(array['admin']) then
    perform private.raise_group_rule('plan_update_forbidden');
  end if;
  if tg_table_name = 'personal_plans' then
    if new.slug is distinct from old.slug then
      perform private.raise_group_rule('plan_identity_immutable');
    end if;
    new.name := btrim(new.name);
    new.updated_at := now();
  elsif (new.plan_slug, new.currency, new.period) is distinct from (old.plan_slug, old.currency, old.period) then
    perform private.raise_group_rule('price_identity_immutable');
  end if;
  return new;
end;
$$;

create trigger personal_plans_guard
  before update or delete on public.personal_plans
  for each row execute function private.personal_plans_guard();

create trigger personal_plan_prices_guard
  before update or delete on public.personal_plan_prices
  for each row execute function private.personal_plans_guard();

-- Orders: a group plan is opened by the group's billing manager, a personal plan by the buyer, at the list price.
create or replace function private.billing_orders_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'DELETE' then
    perform private.raise_group_rule('order_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.buyer_id
       or (new.personal_plan_slug is null and not private.user_has_group_permission(actor, new.group_id, 'billing.manage')) then
      perform private.raise_group_rule('order_forbidden');
    end if;
    if new.status <> 'pending' or new.paid_at is not null or new.provider_payment_id is not null then
      perform private.raise_group_rule('order_must_start_pending');
    end if;
    if new.personal_plan_slug is null and not exists (
      select 1 from public.plans p
      join public.plan_prices pp on pp.plan_slug = p.slug
      where p.slug = new.plan_slug and p.is_active
        and pp.currency = new.currency and pp.period = new.period and pp.amount_minor = new.amount_minor
    ) or new.personal_plan_slug is not null and not exists (
      select 1 from public.personal_plans p
      join public.personal_plan_prices pp on pp.plan_slug = p.slug
      where p.slug = new.personal_plan_slug and p.is_active
        and pp.currency = new.currency and pp.period = new.period and pp.amount_minor = new.amount_minor
    ) then
      perform private.raise_group_rule('order_price_mismatch');
    end if;
    new.updated_at := now();
    return new;
  end if;

  if (new.id, new.buyer_id, new.plan_slug, new.personal_plan_slug, new.period, new.provider, new.country, new.currency,
      new.amount_minor, new.billing_details, new.sales_terms_version, new.client_ip, new.group_name, new.group_handle, new.created_at)
     is distinct from
     (old.id, old.buyer_id, old.plan_slug, old.personal_plan_slug, old.period, old.provider, old.country, old.currency,
      old.amount_minor, old.billing_details, old.sales_terms_version, old.client_ip, old.group_name, old.group_handle, old.created_at) then
    perform private.raise_group_rule('order_immutable');
  end if;
  -- group_id only goes to null, through the foreign key when the group is deleted.
  if new.group_id is distinct from old.group_id and new.group_id is not null then
    perform private.raise_group_rule('order_immutable');
  end if;
  if new.provider_token is distinct from old.provider_token and old.provider_token is not null then
    perform private.raise_group_rule('order_immutable');
  end if;

  if new.status is distinct from old.status then
    if not (
      (old.status = 'pending' and new.status in ('paid', 'failed'))
      or (old.status = 'failed' and new.status = 'paid')
      or (old.status = 'paid' and new.status = 'refunded' and private.is_platform_staff(array['admin']))
    ) then
      perform private.raise_group_rule('order_status_invalid');
    end if;
    if new.status = 'paid' then
      new.paid_at := coalesce(new.paid_at, now());
      new.failure_reason := null;
    end if;
  elsif new.paid_at is distinct from old.paid_at then
    perform private.raise_group_rule('order_immutable');
  end if;

  new.updated_at := now();
  return new;
end;
$$;

-- Slices: opened by their paid order or by a platform admin's grant, then only shortened (admin cancel).
create function private.user_subscriptions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    -- Cascade from a deleted account.
    if not exists (select 1 from public.profiles p where p.id = old.user_id) then
      return old;
    end if;
    perform private.raise_group_rule('subscription_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if new.order_id is not null and not exists (
      select 1 from public.billing_orders o
      where o.id = new.order_id and o.status = 'paid' and o.buyer_id = new.user_id
        and o.personal_plan_slug = new.plan_slug and o.period = new.period
    ) then
      perform private.raise_group_rule('subscription_order_mismatch');
    end if;
    if new.order_id is null and (new.granted_by is distinct from (select auth.uid()) or not private.is_platform_staff(array['admin'])) then
      perform private.raise_group_rule('subscription_grant_forbidden');
    end if;
    if new.ends_at <= new.starts_at or new.canceled_at is not null then
      perform private.raise_group_rule('subscription_invalid');
    end if;
    return new;
  end if;

  if (new.id, new.user_id, new.plan_slug, new.period, new.order_id, new.granted_by, new.grant_reason, new.starts_at, new.created_at)
     is distinct from
     (old.id, old.user_id, old.plan_slug, old.period, old.order_id, old.granted_by, old.grant_reason, old.starts_at, old.created_at)
     -- An admin's account going away nulls granted_by.
     and not (new.granted_by is null and old.granted_by is not null
              and (new.id, new.user_id, new.plan_slug, new.period, new.order_id, new.grant_reason, new.starts_at, new.ends_at,
                   new.canceled_at, new.created_at)
                  is not distinct from
                  (old.id, old.user_id, old.plan_slug, old.period, old.order_id, old.grant_reason, old.starts_at, old.ends_at,
                   old.canceled_at, old.created_at)) then
    perform private.raise_group_rule('subscription_immutable');
  end if;
  if new.ends_at is distinct from old.ends_at or new.canceled_at is distinct from old.canceled_at then
    if old.canceled_at is not null or new.canceled_at is null or new.ends_at > old.ends_at
       or not private.is_platform_staff(array['admin']) then
      perform private.raise_group_rule('subscription_cancel_invalid');
    end if;
  end if;
  return new;
end;
$$;

create trigger user_subscriptions_guard
  before insert or update or delete on public.user_subscriptions
  for each row execute function private.user_subscriptions_guard();

-- The entitlement other modules ask about.
create function private.personal_plan_until(uid uuid, plan text)
returns timestamptz
language sql
stable
security definer
set search_path = ''
as $$
  select max(s.ends_at) from public.user_subscriptions s
  where s.user_id = uid and s.plan_slug = plan and s.ends_at > now() and s.ends_at > s.starts_at;
$$;

create function private.has_matching_premium(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.user_subscriptions s
    where s.user_id = uid and s.plan_slug = 'matching_premium' and s.starts_at <= now() and now() < s.ends_at
  );
$$;

revoke all on function private.personal_plan_until(uuid, text), private.has_matching_premium(uuid) from public;
grant execute on function private.personal_plan_until(uuid, text), private.has_matching_premium(uuid) to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Matching: super likes, boosts
-- owner: matching
-- ---------------------------------------------------------------------------
alter table public.matching_settings
  add column daily_free_super_likes int not null default 1 check (daily_free_super_likes between 0 and 100),
  add column daily_premium_super_likes int not null default 5 check (daily_premium_super_likes between 0 and 100),
  add column boost_minutes int not null default 30 check (boost_minutes between 5 and 180);

alter table public.match_swipes
  add column super boolean not null default false,
  add constraint match_swipes_super_is_like check (not super or liked);

comment on column public.match_swipes.super is 'A super like: the liked person sees it first and is told.';

create table public.match_boosts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  starts_at  timestamptz not null default now(),
  ends_at    timestamptz not null,
  constraint match_boosts_range check (ends_at > starts_at)
);

comment on table public.match_boosts is 'owner: matching. Premium boosts: the person comes first in decks until ends_at. Written by the backend.';

create index match_boosts_user_idx on public.match_boosts (user_id, starts_at desc);
create index match_boosts_live_idx on public.match_boosts (ends_at);

alter table public.match_boosts enable row level security;
revoke all on public.match_boosts from anon, authenticated;
grant select on public.match_boosts to authenticated;
create policy match_boosts_select_own on public.match_boosts for select to authenticated using (user_id = (select auth.uid()));

-- Midnight of Turkey's day, when daily allowances renew.
create function private.match_day_start()
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
$$;

create function private.match_super_likes_left(uid uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select greatest(
    (select case when private.has_matching_premium(uid) then s.daily_premium_super_likes else s.daily_free_super_likes end
     from public.matching_settings s)
    - (select count(*)::int from public.match_swipes w
       where w.swiper_id = uid and w.super and w.created_at >= private.match_day_start()),
    0);
$$;

-- People who liked uid in the mode and are waiting: still in uid's pool, not swiped by uid, not matched.
create function private.match_admirers_of(uid uuid, deck text)
returns table (user_id uuid, super boolean, liked_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select s.swiper_id, s.super, s.created_at
  from public.match_swipes s
  where s.target_id = uid and s.mode = deck and s.liked
    and not exists (select 1 from public.match_swipes mine
                    where mine.swiper_id = uid and mine.target_id = s.swiper_id and mine.mode = deck)
    and not exists (select 1 from public.matches m
                    where m.user_a = least(uid, s.swiper_id) and m.user_b = greatest(uid, s.swiper_id) and m.mode = deck)
    and private.match_fits(uid, s.swiper_id, deck);
$$;

revoke all on function private.match_day_start(), private.match_super_likes_left(uuid), private.match_admirers_of(uuid, text) from public;
grant execute on function private.match_day_start() to authenticated, service_role;
grant execute on function private.match_super_likes_left(uuid) to service_role;

-- The card also says whether the person super liked the viewer.
create or replace function private.match_card(viewer uuid, target uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'user_id', t.user_id,
    'display_name', p.display_name,
    'age', private.match_age(t.birth_date),
    'gender', t.gender,
    'province', t.province,
    'about', t.about,
    'job', t.job,
    'education', t.education,
    'photos', coalesce((select jsonb_agg(jsonb_build_object('id', f.id, 'path', f.path) order by f.position)
                        from public.match_photos f where f.user_id = t.user_id), '[]'),
    'interests', coalesce((select jsonb_agg(i.category_slug order by i.category_slug)
                           from public.profile_interests i where i.user_id = t.user_id), '[]'),
    'shared_interests', coalesce((select jsonb_agg(i.category_slug order by i.category_slug)
                                  from public.profile_interests i
                                  join public.profile_interests mine on mine.category_slug = i.category_slug and mine.user_id = viewer
                                  where i.user_id = t.user_id), '[]'),
    'shared_groups', coalesce((select jsonb_agg(jsonb_build_object('name', g.name, 'handle', g.handle) order by g.name)
                               from public.groups g where g.id in (select private.shared_groups(viewer, t.user_id))), '[]'),
    'super_liked_me', exists (select 1 from public.match_swipes s
                              where s.swiper_id = t.user_id and s.target_id = viewer and s.super)
  )
  from public.match_profiles t
  join public.profiles p on p.id = t.user_id
  where t.user_id = target;
$$;

-- The deck, now with Premium filters. Order: those who super liked you, boosted people, most shared groups, recent.
drop function public.match_deck(text, int);
drop function private.match_deck(text, int);

create function private.match_deck(deck text, page_size int, min_age int, max_age int, in_province int, with_interest text, in_group uuid)
returns setof jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if (min_age is not null or max_age is not null or in_province is not null or with_interest is not null or in_group is not null)
     and not private.has_matching_premium(me) then
    perform private.raise_match_rule('premium_required');
  end if;

  return query
  with pool as (
    select t.user_id,
           (select count(*) from private.shared_groups(me, t.user_id)) as shared,
           exists (select 1 from public.match_swipes s where s.swiper_id = t.user_id and s.target_id = me and s.mode = deck and s.super) as super_liked,
           exists (select 1 from public.match_boosts b where b.user_id = t.user_id and now() between b.starts_at and b.ends_at) as boosted,
           t.updated_at
    from public.match_profiles t
    where t.user_id <> me
      and private.match_fits(me, t.user_id, deck)
      and not exists (
        select 1 from public.match_swipes s
        where s.swiper_id = me and s.target_id = t.user_id and s.mode = deck
          and (s.liked or s.created_at > now() - interval '90 days')
      )
      and not exists (
        select 1 from public.matches m
        where m.user_a = least(me, t.user_id) and m.user_b = greatest(me, t.user_id) and m.mode = deck
      )
      and private.match_age(t.birth_date) between coalesce(min_age, 18) and coalesce(max_age, 99)
      and (in_province is null or t.province = in_province)
      and (with_interest is null or exists (select 1 from public.profile_interests i
                                            where i.user_id = t.user_id and i.category_slug = with_interest))
      and (in_group is null or in_group in (select private.shared_groups(me, t.user_id)))
  )
  select private.match_card(me, pool.user_id)
  from pool
  order by pool.super_liked desc, pool.boosted desc, pool.shared desc, pool.updated_at desc, pool.user_id
  limit least(greatest(page_size, 1), 50);
end;
$$;

create function public.match_deck(
  deck text, page_size int default 20, min_age int default null, max_age int default null,
  in_province int default null, with_interest text default null, in_group uuid default null)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.match_deck(deck, page_size, min_age, max_age, in_province, with_interest, in_group);
$$;

-- Who liked the signed-in user (Premium): super likes first, newest first.
create function private.match_admirers(deck text, page_size int)
returns setof jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if not private.has_matching_premium(me) then
    perform private.raise_match_rule('premium_required');
  end if;
  return query
  select private.match_card(me, a.user_id) || jsonb_build_object('liked_at', a.liked_at)
  from private.match_admirers_of(me, deck) a
  order by a.super desc, a.liked_at desc
  limit least(greatest(page_size, 1), 100);
end;
$$;

create function public.match_admirers(deck text, page_size int default 50)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.match_admirers(deck, page_size);
$$;

-- Everything the swipe screen shows about the user's allowances, in one read.
create function private.match_status()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (select (select auth.uid()) as id, private.has_matching_premium((select auth.uid())) as premium)
  select jsonb_build_object(
    'premium', me.premium,
    'premium_until', private.personal_plan_until(me.id, 'matching_premium'),
    'likes_left', case when me.premium then null else private.match_likes_left() end,
    'super_likes_left', private.match_super_likes_left(me.id),
    'boost_ends_at', (select max(b.ends_at) from public.match_boosts b where b.user_id = me.id and b.ends_at > now()),
    'boost_used_today', exists (select 1 from public.match_boosts b where b.user_id = me.id and b.starts_at >= private.match_day_start()),
    'boost_minutes', (select s.boost_minutes from public.matching_settings s),
    'admirers', jsonb_build_object(
      'friend', (select count(*) from private.match_admirers_of(me.id, 'friend')),
      'dating', (select count(*) from private.match_admirers_of(me.id, 'dating')))
  )
  from me;
$$;

create function public.match_status()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.match_status();
$$;

revoke all on function private.match_deck(text, int, int, int, int, text, uuid),
  public.match_deck(text, int, int, int, int, text, uuid), private.match_admirers(text, int), public.match_admirers(text, int),
  private.match_status(), public.match_status() from public;
grant execute on function private.match_deck(text, int, int, int, int, text, uuid),
  public.match_deck(text, int, int, int, int, text, uuid), private.match_admirers(text, int), public.match_admirers(text, int),
  private.match_status(), public.match_status() to authenticated;

-- ---------------------------------------------------------------------------
-- Notifications: a super like (notifications owns the table)
-- ---------------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type_check;
alter table public.notifications add constraint notifications_type_check
  check (type in ('like', 'comment', 'reply', 'comment_like', 'mention', 'follow', 'follow_request', 'follow_accepted',
                  'live_scheduled', 'live_started', 'event_promoted', 'event_updated', 'event_canceled', 'event_reminder',
                  'case_vote', 'sanction_applied', 'appeal_submitted', 'appeal_decided',
                  'event_approved', 'event_declined', 'event_review', 'goal_completed',
                  'teammate_request', 'teammate_accepted', 'match_created', 'match_super_liked'));

create or replace function private.wants_notification(uid uuid, kind text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select case kind
             when 'event_reminder_day' then p.event_reminder_day
             when 'event_reminder_hour' then p.event_reminder_hour
             when 'event_updated' then p.event_updates
             when 'event_canceled' then p.event_updates
             when 'event_review' then p.event_review_requests
             when 'live_scheduled' then p.live_broadcasts
             when 'live_started' then p.live_broadcasts
             when 'match_created' then p.match_alerts
             when 'match_super_liked' then p.match_alerts
             else true
           end
    from public.notification_preferences p where p.user_id = uid
  ), true);
$$;

create function private.notify_match_super_liked()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if private.wants_notification(new.target_id, 'match_super_liked') then
    insert into public.notifications (recipient_id, actor_id, type)
    values (new.target_id, new.swiper_id, 'match_super_liked');
  end if;
  return null;
end;
$$;

revoke all on function private.notify_match_super_liked() from public;

create trigger notify_match_super_liked
  after insert on public.match_swipes
  for each row when (new.super)
  execute function private.notify_match_super_liked();

create trigger notify_match_super_liked_again
  after update of super on public.match_swipes
  for each row when (new.super and not old.super)
  execute function private.notify_match_super_liked();
