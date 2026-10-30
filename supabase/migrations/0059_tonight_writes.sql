-- 0059: "Bu akşam boşum" is written through two functions instead of the table (docs/ARCHITECTURE.md §3d, Bu akşam
-- boşum ve küçük masa). The app's upsert also wrote user_id, which the table did not grant, so no status was ever
-- saved. The database now picks the evening, the end and the row; the app only says "free, with this note" or "not free".
-- The card also learns how many people a table could ask, from the same rule the table uses.

revoke insert, update on public.tonight_status from authenticated;
drop policy tonight_status_insert_own on public.tonight_status;
drop policy tonight_status_update_own on public.tonight_status;

create function private.set_tonight(note text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := (select auth.uid());
begin
  if uid is null or not private.is_account_active(uid) then
    perform private.raise_tonight_rule('tonight_forbidden');
  end if;
  if char_length(btrim(coalesce(note, ''))) > 80 then
    perform private.raise_tonight_rule('tonight_note_too_long');
  end if;
  -- The guard trigger sets the evening and the end; reopening the same evening clears closed_at.
  insert into public.tonight_status (user_id, note) values (uid, coalesce(note, ''))
  on conflict (user_id, evening) do update set note = excluded.note, closed_at = null;
end;
$$;

create function private.close_tonight()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.tonight_status set closed_at = now()
  where user_id = (select auth.uid()) and evening = private.tonight_evening() and closed_at is null;
$$;

create function public.set_tonight(note text default '')
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.set_tonight(note);
$$;

create function public.close_tonight()
returns void
language sql
security invoker
set search_path = ''
as $$
  select private.close_tonight();
$$;

revoke all on function private.set_tonight(text), private.close_tonight(), public.set_tonight(text), public.close_tonight() from public;
grant execute on function private.set_tonight(text), private.close_tonight(), public.set_tonight(text), public.close_tonight()
  to authenticated;

-- Who a founder may ask tonight, unordered: one rule for the count on the card and the table itself.
create function private.tonight_pool(founder uuid)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select s.user_id
  from public.tonight_status s
  where s.evening = private.tonight_evening() and s.closed_at is null and s.until > now()
    and s.user_id <> founder
    and private.is_account_active(s.user_id)
    and private.shares_group(founder, s.user_id)
    and not private.is_blocked_between(founder, s.user_id)
    and not exists (select 1 from public.tonight_table_invites i
                    where i.user_id = s.user_id and i.evening = s.evening and i.state = 'accepted');
$$;

revoke all on function private.tonight_pool(uuid) from public;
grant execute on function private.tonight_pool(uuid) to authenticated, service_role;

create or replace function private.tonight_candidates(founder uuid, max_people integer default 5)
returns setof uuid
language sql
volatile
security definer
set search_path = ''
as $$
  select pool.id
  from private.tonight_pool(founder) as pool(id)
  order by
    (select count(*) from public.group_members m1
     join public.group_members m2 on m2.group_id = m1.group_id and m2.user_id = pool.id
     where m1.user_id = founder) desc,
    (select count(*) from public.profile_interests a
     join public.profile_interests b on b.category_slug = a.category_slug and b.user_id = pool.id
     where a.user_id = founder) desc,
    random()
  limit max_people;
$$;

-- The card's numbers: who could be asked to a table; the people list comes from tonight_people.
create or replace function private.my_tonight()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'status', (select jsonb_build_object('note', s.note, 'until', s.until) from public.tonight_status s
               where s.user_id = (select auth.uid()) and s.evening = private.tonight_evening()
                 and s.closed_at is null and s.until > now()),
    'candidates', (select count(*) from private.tonight_pool((select auth.uid()))),
    'table', (select private.tonight_table_card(t, (select auth.uid())) from public.tonight_tables t
              join public.tonight_table_invites i on i.table_id = t.id
              where i.user_id = (select auth.uid()) and i.evening = private.tonight_evening() and i.state = 'accepted'),
    'invites', coalesce((select jsonb_agg(private.tonight_table_card(t, (select auth.uid())) order by i.created_at desc)
                         from public.tonight_tables t
                         join public.tonight_table_invites i on i.table_id = t.id
                         where i.user_id = (select auth.uid()) and i.evening = private.tonight_evening()
                           and i.state = 'pending' and t.closes_at > now()), '[]'::jsonb)
  );
$$;
