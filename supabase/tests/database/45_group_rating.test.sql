begin;
create extension if not exists pgtap with schema extensions;

select plan(9);

-- o1 owns group 5601; m1 went to two ended events and reviewed one; m2 went to none; a canceled event's review does
-- not count. Once the group is suspended, outsiders learn nothing of its rating.
insert into auth.users (id, email, aud, role) values
  ('00000000-0000-0000-0000-00000056d001', 'rating-owner@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000056c001', 'rating-m1@test.local', 'authenticated', 'authenticated'),
  ('00000000-0000-0000-0000-00000056c002', 'rating-m2@test.local', 'authenticated', 'authenticated');

insert into public.profiles (id, username, display_name) values
  ('00000000-0000-0000-0000-00000056d001', 'rating_owner', 'Owner'),
  ('00000000-0000-0000-0000-00000056c001', 'rating_m1', 'M1'),
  ('00000000-0000-0000-0000-00000056c002', 'rating_m2', 'M2');

create function pg_temp.act(uid text) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true);
$$;

select pg_temp.act('00000000-0000-0000-0000-00000056d001');
insert into public.groups (id, handle, name, category_slug, join_policy, owner_id) values
  ('00000000-0000-0000-0000-000000005601', 'rating.test', 'Puanlı Grup', 'running', 'open', '00000000-0000-0000-0000-00000056d001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005601', '00000000-0000-0000-0000-00000056d001');
select pg_temp.act('00000000-0000-0000-0000-00000056c001');
insert into public.group_members (group_id, user_id) values ('00000000-0000-0000-0000-000000005601', '00000000-0000-0000-0000-00000056c001');

-- Ended events, written with triggers off (the guard refuses past starts); e3 is canceled.
set local session_replication_role = replica;
insert into public.events (id, group_id, created_by, title, starts_at, location, canceled_at, cancel_reason) values
  ('00000000-0000-0000-0000-0000005600e1', '00000000-0000-0000-0000-000000005601', '00000000-0000-0000-0000-00000056d001',
   'Dünkü koşu', now() - interval '1 day', 'Sahil', null, null),
  ('00000000-0000-0000-0000-0000005600e2', '00000000-0000-0000-0000-000000005601', '00000000-0000-0000-0000-00000056d001',
   'Geçen haftaki koşu', now() - interval '7 days', 'Sahil', null, null),
  ('00000000-0000-0000-0000-0000005600e3', '00000000-0000-0000-0000-000000005601', '00000000-0000-0000-0000-00000056d001',
   'İptal edilen koşu', now() - interval '3 days', 'Sahil', now() - interval '4 days', 'Hava durumu');
insert into public.event_attendees (event_id, user_id, status) values
  ('00000000-0000-0000-0000-0000005600e1', '00000000-0000-0000-0000-00000056c001', 'going'),
  ('00000000-0000-0000-0000-0000005600e2', '00000000-0000-0000-0000-00000056c001', 'going'),
  ('00000000-0000-0000-0000-0000005600e3', '00000000-0000-0000-0000-00000056c001', 'going');
insert into public.event_reviews (event_id, user_id, rating) values
  ('00000000-0000-0000-0000-0000005600e2', '00000000-0000-0000-0000-00000056c001', 4),
  ('00000000-0000-0000-0000-0000005600e3', '00000000-0000-0000-0000-00000056c001', 1);
set local session_replication_role = origin;

-- The rating ------------------------------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000056c002');
set local role authenticated;
select is(public.group_events('00000000-0000-0000-0000-000000005601') #>> '{rating,avg}', '4.0', 'the average of the group''s reviews');
select is((public.group_events('00000000-0000-0000-0000-000000005601') #>> '{rating,count}')::int, 1, 'a canceled event''s review does not count');
select is(jsonb_array_length(public.group_events('00000000-0000-0000-0000-000000005601') -> 'to_review'), 0, 'nothing to review without going');
reset role;

-- What awaits the viewer's review -----------------------------------------------------------
select pg_temp.act('00000000-0000-0000-0000-00000056c001');
set local role authenticated;
select is(jsonb_array_length(public.group_events('00000000-0000-0000-0000-000000005601') -> 'to_review'), 1, 'only the unreviewed, open event');
select is(public.group_events('00000000-0000-0000-0000-000000005601') #>> '{to_review,0,title}', 'Dünkü koşu', 'the event to review');
insert into public.event_reviews (event_id, user_id, rating) values
  ('00000000-0000-0000-0000-0000005600e1', '00000000-0000-0000-0000-00000056c001', 5);
select is(jsonb_array_length(public.group_events('00000000-0000-0000-0000-000000005601') -> 'to_review'), 0, 'a review takes it off the list');
select is(public.group_events('00000000-0000-0000-0000-000000005601') #>> '{rating,avg}', '4.5', 'the new review joins the average');
reset role;

-- Visibility --------------------------------------------------------------------------------
set local role anon;
select is(public.group_events('00000000-0000-0000-0000-000000005601') #>> '{rating,count}', '2', 'a visible group''s rating is public');
reset role;

set local session_replication_role = replica;
update public.groups set status = 'suspended', suspended_at = now() where id = '00000000-0000-0000-0000-000000005601';
set local session_replication_role = origin;
select pg_temp.act('00000000-0000-0000-0000-00000056c002');
set local role authenticated;
select is(private.group_rating('00000000-0000-0000-0000-000000005601'), null, 'a suspended group''s rating is hidden from outsiders');
reset role;

select * from finish();
rollback;
