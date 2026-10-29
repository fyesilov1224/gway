-- 0050: welcome trial — a person's first group gives them 30 days of every personal package once
-- (docs/ARCHITECTURE.md §3g, Hoş geldin denemesi; user decision 2026-10-29). Direct messages keep their rule:
-- only matches and teammates; the trial only meets the package condition.

-- ---------------------------------------------------------------------------
-- Billing: the trial slice
-- ---------------------------------------------------------------------------
alter table public.user_subscriptions
  add column welcome_trial boolean not null default false,
  add constraint user_subscriptions_welcome_trial check (
    not welcome_trial or (plan_slug = 'matching_premium' and order_id is null and granted_by is null));

comment on column public.user_subscriptions.welcome_trial is
  'The one-time 30-day trial given when the person joins their first group (no order, no admin).';

create unique index user_subscriptions_one_welcome_trial on public.user_subscriptions (user_id) where welcome_trial;

-- As in 0029, plus the trial: written only by the trigger below, never changed into or out of.
create or replace function private.user_subscriptions_guard()
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
    if new.welcome_trial then
      -- An admin may still cancel it later (ends_at moves to now).
      if new.ends_at <> new.starts_at + interval '30 days'
         or not exists (select 1 from public.group_members m where m.user_id = new.user_id) then
        perform private.raise_group_rule('subscription_grant_forbidden');
      end if;
    elsif new.order_id is null and (new.granted_by is distinct from (select auth.uid()) or not private.is_platform_staff(array['admin'])) then
      perform private.raise_group_rule('subscription_grant_forbidden');
    end if;
    if new.ends_at <= new.starts_at or new.canceled_at is not null then
      perform private.raise_group_rule('subscription_invalid');
    end if;
    return new;
  end if;

  if (new.id, new.user_id, new.plan_slug, new.period, new.order_id, new.granted_by, new.grant_reason, new.starts_at, new.created_at,
      new.welcome_trial)
     is distinct from
     (old.id, old.user_id, old.plan_slug, old.period, old.order_id, old.granted_by, old.grant_reason, old.starts_at, old.created_at,
      old.welcome_trial)
     -- An admin's account going away nulls granted_by.
     and not (new.granted_by is null and old.granted_by is not null
              and (new.id, new.user_id, new.plan_slug, new.period, new.order_id, new.grant_reason, new.starts_at, new.ends_at,
                   new.canceled_at, new.created_at, new.welcome_trial)
                  is not distinct from
                  (old.id, old.user_id, old.plan_slug, old.period, old.order_id, old.grant_reason, old.starts_at, old.ends_at,
                   old.canceled_at, old.created_at, old.welcome_trial)) then
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

-- Gives the trial once; it follows any Hepsi Bir Arada time the person already has.
create function private.grant_welcome_trial(uid uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  starts timestamptz;
  trial_id uuid;
begin
  -- The same lock as the backend's adding time (PersonalTimeline).
  perform pg_advisory_xact_lock(hashtextextended(uid::text || ':matching_premium', 11));
  if exists (select 1 from public.user_subscriptions s where s.user_id = uid and s.welcome_trial) then
    return;
  end if;
  starts := greatest(now(), coalesce(private.personal_plan_until(uid, 'matching_premium'), now()));
  insert into public.user_subscriptions (user_id, plan_slug, grant_reason, starts_at, ends_at, welcome_trial)
  values (uid, 'matching_premium', 'Hoş geldin denemesi', starts, starts + interval '30 days', true)
  returning id into trial_id;
  insert into public.audit_log (actor_id, actor_kind, action, target_type, target_id, data)
  values (null, 'system', 'personal_plan.welcome_trial', 'user_subscription', trial_id::text,
          jsonb_build_object('userId', uid, 'plan', 'matching_premium', 'days', 30, 'startsAt', starts,
                             'endsAt', starts + interval '30 days'));
end;
$$;

revoke all on function private.grant_welcome_trial(uuid) from public;

create function private.group_members_welcome_trial()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.grant_welcome_trial(new.user_id);
  return null;
end;
$$;

revoke all on function private.group_members_welcome_trial() from public;

create trigger group_members_welcome_trial
  after insert on public.group_members
  for each row execute function private.group_members_welcome_trial();

-- People already in a group get it today.
select private.grant_welcome_trial(u.user_id)
from (select distinct m.user_id from public.group_members m) u;
