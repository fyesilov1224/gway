-- 0043_birth_dates
-- 18+ age limit for the whole app (docs/ARCHITECTURE.md §3a, Yaş sınırı; Google Play target audience).
-- owner: identity. The user adds their own date once (simple write of own data); it is never shown to others.

create table public.birth_dates (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  birth_date date not null,
  created_at timestamptz not null default now()
);

comment on table public.birth_dates is 'owner: identity. Date of birth for the 18+ limit. Own row only; never public.';

create function private.birth_dates_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.birth_date < date '1900-01-01' then
    raise exception 'birth_date_invalid' using errcode = 'P0001';
  end if;
  -- Age on today's date in Türkiye.
  if extract(year from age((now() at time zone 'Europe/Istanbul')::date, new.birth_date)) < 18 then
    raise exception 'birth_date_under_18' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger birth_dates_guard
  before insert or update on public.birth_dates
  for each row execute function private.birth_dates_guard();

alter table public.birth_dates enable row level security;
revoke all on public.birth_dates from anon, authenticated;
grant select on public.birth_dates to authenticated;
grant insert (birth_date) on public.birth_dates to authenticated;

create policy birth_dates_select_own
  on public.birth_dates for select to authenticated
  using (user_id = (select auth.uid()));

create policy birth_dates_insert_own
  on public.birth_dates for insert to authenticated
  with check (user_id = (select auth.uid()));
