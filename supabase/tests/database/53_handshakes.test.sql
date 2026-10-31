begin;
create extension if not exists pgtap with schema extensions;

select plan(18);

-- o1 owns group 5601. a, b and d go to the event starting soon; c is a member who does not go; a blocked d.
insert into auth.users (id, email, aud, role)
select ('00000000-0000-0000-0000-0000005600' || s)::uuid, 'hs-' || s || '@test.local', 'authenticated', 'authenticated'
from unnest(array['01', '0a', '0b', '0c', '0d']) s;
insert into public.profiles (id, username, display_name)
select ('00000000-0000-0000-0000-0000005600' || s)::uuid, 'hs_user_' || s, 'El ' || s
from unnest(array['01', '0a', '0b', '0c', '0d']) s;

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;
create function pg_temp.u(s text) returns uuid language sql as $$ select ('00000000-0000-0000-0000-0000005600' || s)::uuid $$;
create function pg_temp.ev() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000005600e1'::uuid $$;
create function pg_temp.later() returns uuid language sql as $$ select '00000000-0000-0000-0000-0000005600e2'::uuid $$;
create function pg_temp.pair(x text, y text) returns table (a uuid, b uuid) language sql as $$
  select least(pg_temp.u(x), pg_temp.u(y)), greatest(pg_temp.u(x), pg_temp.u(y));
$$;

select pg_temp.act(pg_temp.u('01')::text);
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id)
values ('00000000-0000-0000-0000-000000005601', 'handshake.test', 'Handshake', 'hiking', 'open', pg_temp.u('01'));
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005601', pg_temp.u('01'));
insert into public.events (id, group_id, created_by, title, starts_at, location) values
  (pg_temp.ev(), '00000000-0000-0000-0000-000000005601', pg_temp.u('01'), 'Akşam yürüyüşü', now() + interval '30 minutes', 'Sahil'),
  (pg_temp.later(), '00000000-0000-0000-0000-000000005601', pg_temp.u('01'), 'Hafta sonu', now() + interval '2 days', 'Orman');
do $$ begin
  for s in 1..4 loop
    perform pg_temp.act(pg_temp.u((array['0a', '0b', '0c', '0d'])[s])::text);
    insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005601', (select auth.uid()));
    if s <> 3 then
      insert into public.event_attendees (event_id, user_id) values (pg_temp.ev(), (select auth.uid()));
      insert into public.event_attendees (event_id, user_id) values (pg_temp.later(), (select auth.uid()));
    end if;
  end loop;
end $$;
select pg_temp.act(pg_temp.u('0a')::text);
insert into public.blocks (blocker_id, blocked_id) values (pg_temp.u('0a'), pg_temp.u('0d'));

-- Codes ----------------------------------------------------------------------------------------------------------
select lives_ok($$ insert into public.handshake_codes (event_id, user_id, code, expires_at)
                   values (pg_temp.ev(), pg_temp.u('0a'), 'ABC234', now() + interval '3 minutes') $$, 'someone going gets a code');
select throws_ok($$ insert into public.handshake_codes (event_id, user_id, code, expires_at)
                    values (pg_temp.ev(), pg_temp.u('0b'), 'XYZ234', now() + interval '3 minutes') $$,
  'P0001', 'handshake_forbidden', 'nobody makes a code for someone else');
select throws_ok($$ insert into public.handshake_codes (event_id, user_id, code, expires_at)
                    values (pg_temp.later(), pg_temp.u('0a'), 'DEF234', now() + interval '3 minutes') $$,
  'P0001', 'handshake_closed', 'not days before the event');
select pg_temp.act(pg_temp.u('0c')::text);
select throws_ok($$ insert into public.handshake_codes (event_id, user_id, code, expires_at)
                    values (pg_temp.ev(), pg_temp.u('0c'), 'GHJ234', now() + interval '3 minutes') $$,
  'P0001', 'handshake_closed', 'not by members who do not go');

-- Handshakes -----------------------------------------------------------------------------------------------------
select pg_temp.act(pg_temp.u('0b')::text);
select lives_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0a', '0b') $$,
  'two people going shake hands');
select is((select count(*)::int from public.notifications
           where type = 'handshake' and recipient_id = pg_temp.u('0a') and actor_id = pg_temp.u('0b')), 1, 'the other one is told');
select throws_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0a', '0b') $$,
  '23505', null, 'once per event');
select throws_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0b', '0c') $$,
  'P0001', 'handshake_closed', 'not with someone who does not go');
select throws_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0a', '0d') $$,
  'P0001', 'handshake_forbidden', 'nobody records a handshake for two others');
select pg_temp.act(pg_temp.u('0d')::text);
select throws_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0a', '0d') $$,
  'P0001', 'blocked', 'not across a block');
select throws_ok($$ delete from public.handshakes $$, 'P0001', 'handshake_immutable', 'a handshake stays');

-- Reading ----------------------------------------------------------------------------------------------------------
set local role authenticated;
select throws_ok($$ select * from public.handshake_codes $$, '42501', null, 'clients do not read codes');
select throws_ok($$ insert into public.handshakes (event_id, user_a, user_b) select pg_temp.ev(), a, b from pg_temp.pair('0a', '0d') $$,
  '42501', null, 'clients do not write handshakes');
select pg_temp.act(pg_temp.u('0c')::text);
select is((select count(*)::int from public.handshakes), 0, 'others do not see who met');
select pg_temp.act(pg_temp.u('0a')::text);
select is(public.my_handshakes() #>> '{0,person,username}', 'hs_user_0b', '"Tanıştıklarım" lists the other person');
reset role;

select is((private.contribution_counts(pg_temp.u('0a'), null) ->> 'handshakes')::int, 1, 'contributions count handshakes');
select ok(private.earned_badges('{"handshakes": 5}'::jsonb) @> '[{"slug": "friendly"}]', 'five handshakes earn a badge');

delete from auth.users where id = pg_temp.u('0b');
select is((select count(*)::int from public.handshakes where event_id = pg_temp.ev()), 0,
  'deleting an account takes its handshakes with it');

select finish();
rollback;
