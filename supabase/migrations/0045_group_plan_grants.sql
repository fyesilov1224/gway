-- 0045: platform admins give a group a plan, and every admin cancellation keeps its reason
-- (docs/ARCHITECTURE.md §7, Yönetici işlemleri).
--
-- A granted slice has no order and no period; it carries who gave it and why. An admin
-- cancellation stores its reason on the slice too (it was only in audit_log before).

alter table public.group_subscriptions
  alter column order_id drop not null,
  alter column period drop not null,
  add column granted_by uuid references public.profiles (id) on delete set null,
  add column grant_reason text check (char_length(grant_reason) between 3 and 500),
  add column cancel_note text check (char_length(cancel_note) between 3 and 500),
  add constraint group_subscriptions_source check ((order_id is null) = (grant_reason is not null)),
  add constraint group_subscriptions_period check ((order_id is null) = (period is null)),
  add constraint group_subscriptions_cancel_note check (cancel_note is null or cancel_reason = 'admin');

comment on column public.group_subscriptions.grant_reason is 'Set when a platform admin gave the slice (no order).';
comment on column public.group_subscriptions.cancel_note is 'Reason a platform admin gave when cancelling.';

-- Subscriptions: opened by their paid order or by a platform admin, then only shortened (cancel).
create or replace function private.group_subscriptions_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' then
    -- Cascade from a deleted group.
    if not exists (select 1 from public.groups g where g.id = old.group_id) then
      return old;
    end if;
    perform private.raise_group_rule('subscription_delete_forbidden');
  end if;

  if tg_op = 'INSERT' then
    if new.order_id is not null and not exists (
      select 1 from public.billing_orders o
      where o.id = new.order_id and o.status = 'paid' and o.group_id = new.group_id
        and o.plan_slug = new.plan_slug and o.period = new.period
    ) then
      perform private.raise_group_rule('subscription_order_mismatch');
    end if;
    if new.order_id is null and (new.granted_by is distinct from (select auth.uid()) or not private.is_platform_staff(array['admin'])) then
      perform private.raise_group_rule('subscription_grant_forbidden');
    end if;
    if new.plan_slug = 'free' or new.ends_at <= new.starts_at or new.canceled_at is not null or new.cancel_note is not null then
      perform private.raise_group_rule('subscription_invalid');
    end if;
    return new;
  end if;

  if (new.id, new.group_id, new.plan_slug, new.period, new.order_id, new.granted_by, new.grant_reason, new.starts_at,
      new.credit_seconds, new.created_at)
     is distinct from
     (old.id, old.group_id, old.plan_slug, old.period, old.order_id, old.granted_by, old.grant_reason, old.starts_at,
      old.credit_seconds, old.created_at)
     -- An admin's account going away nulls granted_by.
     and not (new.granted_by is null and old.granted_by is not null
              and (new.id, new.group_id, new.plan_slug, new.period, new.order_id, new.grant_reason, new.starts_at, new.ends_at,
                   new.credit_seconds, new.canceled_at, new.cancel_reason, new.cancel_note, new.created_at)
                  is not distinct from
                  (old.id, old.group_id, old.plan_slug, old.period, old.order_id, old.grant_reason, old.starts_at, old.ends_at,
                   old.credit_seconds, old.canceled_at, old.cancel_reason, old.cancel_note, old.created_at)) then
    perform private.raise_group_rule('subscription_immutable');
  end if;
  if (new.ends_at, new.canceled_at, new.cancel_reason, new.cancel_note)
     is distinct from (old.ends_at, old.canceled_at, old.cancel_reason, old.cancel_note) then
    if old.canceled_at is not null or new.canceled_at is null or new.ends_at > old.ends_at then
      perform private.raise_group_rule('subscription_cancel_invalid');
    end if;
    if new.cancel_reason = 'admin' and not private.is_platform_staff(array['admin']) then
      perform private.raise_group_rule('subscription_cancel_forbidden');
    end if;
  end if;
  return new;
end;
$$;
