begin;
create extension if not exists pgtap with schema extensions;

select plan(3);

select has_trigger('public', 'notifications', 'notifications_wake_push', 'a new notification wakes the push dispatcher');
select is(
  (select prosecdef from pg_proc where oid = 'private.wake_push_dispatcher()'::regprocedure), true,
  'the wake-up runs as its owner');

set local role authenticated;
select throws_ok(
  'select private.wake_push_dispatcher()', '42501', null,
  'clients cannot call the wake-up themselves');

select * from finish();
rollback;
