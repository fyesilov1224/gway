-- 0005_support
-- Phase 3.5: support tickets (problems, requests, suggestions), their
-- conversation and private screenshots. Rules: docs/ARCHITECTURE.md §7b.
--
-- Users write their own tickets and replies straight through Supabase (RLS).
-- Staff replies and status changes go through the C# API, which names the
-- staff member in request.jwt.claims; triggers check it a second time.

-- ---------------------------------------------------------------------------
-- support_tickets, support_messages
-- owner: support
-- ---------------------------------------------------------------------------
create table public.support_tickets (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  group_id        uuid references public.groups (id) on delete set null,
  kind            text not null check (kind in ('problem', 'request', 'suggestion')),
  subject         text not null check (char_length(btrim(subject)) between 3 and 120),
  status          text not null default 'open' check (status in ('open', 'in_progress', 'resolved', 'closed')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  last_message_at timestamptz not null default now(),
  last_message_by text not null default 'user' check (last_message_by in ('user', 'staff')),
  user_read_at    timestamptz not null default now()
);

comment on table public.support_tickets is
  'owner: support. Messages from users to the platform team. Deleted with the account.';
comment on column public.support_tickets.group_id is 'Optional group the sender manages (group.edit).';
comment on column public.support_tickets.user_read_at is 'Last time the sender opened the ticket; drives the unread reply mark.';

create index support_tickets_user_idx on public.support_tickets (user_id, last_message_at desc);
create index support_tickets_status_idx on public.support_tickets (status, last_message_at desc);
create index support_tickets_group_idx on public.support_tickets (group_id) where group_id is not null;

create table public.support_messages (
  id          bigint generated always as identity primary key,
  ticket_id   uuid not null references public.support_tickets (id) on delete cascade,
  author_id   uuid,
  author_kind text not null default 'user' check (author_kind in ('user', 'staff')),
  body        text not null check (char_length(btrim(body)) between 1 and 4000),
  attachments text[] not null default '{}' check (cardinality(attachments) <= 3),
  created_at  timestamptz not null default now()
);

comment on table public.support_messages is 'owner: support. Conversation of a ticket, oldest first.';
comment on column public.support_messages.author_id is
  'auth.users id of the user or staff member. No foreign key: staff replies outlive staff accounts.';
comment on column public.support_messages.attachments is
  'Paths in the private support-attachments bucket: <user_id>/<ticket_id>-<n>.<ext>.';

create index support_messages_ticket_idx on public.support_messages (ticket_id, created_at);

-- ---------------------------------------------------------------------------
-- RLS: owners read and write their own; staff read everything
-- ---------------------------------------------------------------------------
alter table public.support_tickets enable row level security;
alter table public.support_messages enable row level security;

revoke all on public.support_tickets, public.support_messages from anon, authenticated;
grant select on public.support_tickets, public.support_messages to authenticated;
grant insert (id, user_id, group_id, kind, subject) on public.support_tickets to authenticated;
grant update (user_read_at) on public.support_tickets to authenticated;
grant insert (ticket_id, body, attachments) on public.support_messages to authenticated;

create policy support_tickets_select_own_or_staff
  on public.support_tickets for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_platform_staff()));

create policy support_tickets_insert_own
  on public.support_tickets for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and (group_id is null or private.has_group_permission(group_id, 'group.edit'))
  );

-- Only user_read_at is granted; the policy limits it to the sender.
create policy support_tickets_update_own_read_mark
  on public.support_tickets for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy support_messages_select_own_or_staff
  on public.support_messages for select to authenticated
  using (
    exists (select 1 from public.support_tickets t where t.id = ticket_id and t.user_id = (select auth.uid()))
    or (select private.is_platform_staff())
  );

create policy support_messages_insert_own
  on public.support_messages for insert to authenticated
  with check (
    author_kind = 'user'
    and author_id = (select auth.uid())
    and exists (select 1 from public.support_tickets t where t.id = ticket_id and t.user_id = (select auth.uid()))
  );

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_support_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- New tickets start open; at most 5 per user per 24 hours.
create function private.support_tickets_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select count(*) from public.support_tickets t
      where t.user_id = new.user_id and t.created_at > now() - interval '24 hours') >= 5 then
    perform private.raise_support_rule('ticket_rate_limited');
  end if;
  new.subject := btrim(new.subject);
  new.status := 'open';
  new.created_at := now();
  new.updated_at := now();
  new.last_message_at := now();
  new.last_message_by := 'user';
  new.user_read_at := now();
  return new;
end;
$$;

create trigger support_tickets_before_insert
  before insert on public.support_tickets
  for each row execute function private.support_tickets_before_insert();

-- Status changes on behalf of platform staff only, or by the message trigger below.
create function private.support_tickets_before_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (new.id, new.user_id, new.kind, new.subject, new.created_at)
     is distinct from (old.id, old.user_id, old.kind, old.subject, old.created_at) then
    perform private.raise_support_rule('ticket_immutable');
  end if;
  -- group_id only goes to null, through the foreign key when the group is deleted.
  if new.group_id is distinct from old.group_id and new.group_id is not null then
    perform private.raise_support_rule('ticket_immutable');
  end if;
  if new.status is distinct from old.status then
    if pg_trigger_depth() = 1 and not private.is_platform_staff() then
      perform private.raise_support_rule('ticket_status_forbidden');
    end if;
    new.updated_at := now();
  end if;
  return new;
end;
$$;

create trigger support_tickets_before_update
  before update on public.support_tickets
  for each row execute function private.support_tickets_before_update();

-- Who wrote it, where the files are, and the abuse limit.
create function private.support_messages_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  t public.support_tickets;
  path text;
  pattern text;
begin
  select * into t from public.support_tickets where id = new.ticket_id;
  if t.id is null then
    perform private.raise_support_rule('ticket_not_found');
  end if;

  new.body := btrim(new.body);
  new.created_at := now();

  if new.author_kind = 'staff' then
    if not private.is_platform_staff() then
      perform private.raise_support_rule('staff_reply_forbidden');
    end if;
    new.author_id := (select auth.uid());
    if cardinality(new.attachments) > 0 then
      perform private.raise_support_rule('staff_attachments_not_supported');
    end if;
    return new;
  end if;

  -- Users cannot name the author; it is always the caller.
  new.author_id := (select auth.uid());
  if new.author_id is distinct from t.user_id then
    perform private.raise_support_rule('reply_forbidden');
  end if;
  if t.status = 'closed' then
    perform private.raise_support_rule('ticket_closed');
  end if;
  if (select count(*) from public.support_messages m
      join public.support_tickets x on x.id = m.ticket_id
      where x.user_id = t.user_id and m.author_kind = 'user' and m.created_at > now() - interval '1 hour') >= 20 then
    perform private.raise_support_rule('reply_rate_limited');
  end if;

  pattern := '^' || t.user_id::text || '/' || t.id::text || '-[1-9][0-9]*\.(jpg|jpeg|png|webp)$';
  foreach path in array new.attachments loop
    if path !~ pattern then
      perform private.raise_support_rule('attachment_path_invalid');
    end if;
  end loop;
  return new;
end;
$$;

create trigger support_messages_before_insert
  before insert on public.support_messages
  for each row execute function private.support_messages_before_insert();

-- Keeps the ticket's summary in step with its conversation. SECURITY DEFINER:
-- users may only touch user_read_at themselves.
create function private.support_messages_after_insert()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.support_tickets t
  set last_message_at = new.created_at,
      last_message_by = new.author_kind,
      updated_at = now(),
      status = case
        when new.author_kind = 'staff' and t.status = 'open' then 'in_progress'
        when new.author_kind = 'user' and t.status = 'resolved' then 'open'
        else t.status
      end,
      user_read_at = case when new.author_kind = 'user' then now() else t.user_read_at end
  where t.id = new.ticket_id;
  return null;
end;
$$;

create trigger support_messages_after_insert
  after insert on public.support_messages
  for each row execute function private.support_messages_after_insert();

-- Messages are a record of the conversation: no edits, no deletes except the cascade.
create function private.support_messages_block_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'DELETE' and not exists (select 1 from public.support_tickets t where t.id = old.ticket_id) then
    return old;
  end if;
  perform private.raise_support_rule('message_immutable');
  return null;
end;
$$;

create trigger support_messages_block_change
  before update or delete on public.support_messages
  for each row execute function private.support_messages_block_change();

-- ---------------------------------------------------------------------------
-- RPCs (SECURITY INVOKER: they run under the caller's RLS)
-- ---------------------------------------------------------------------------

-- Opens a ticket and its first message in one transaction. The client picks
-- the id so screenshots can be uploaded under it first.
create function public.create_support_ticket(
  ticket_id uuid,
  kind text,
  subject text,
  body text,
  target_group uuid default null,
  attachments text[] default '{}'
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.support_tickets (id, user_id, group_id, kind, subject)
  values (ticket_id, (select auth.uid()), target_group, kind, subject);
  insert into public.support_messages (ticket_id, body, attachments)
  values (ticket_id, body, coalesce(attachments, '{}'));
  return ticket_id;
end;
$$;

revoke all on function public.create_support_ticket(uuid, text, text, text, uuid, text[]) from public, anon;
grant execute on function public.create_support_ticket(uuid, text, text, text, uuid, text[]) to authenticated;

-- Groups the caller may attach to a ticket (owner or Yönetici).
create function public.my_managed_groups()
returns table (id uuid, name text, handle text)
language sql
stable
security invoker
set search_path = ''
as $$
  select g.id, g.name, g.handle
  from public.groups g
  join public.group_members m on m.group_id = g.id and m.user_id = (select auth.uid())
  where private.has_group_permission(g.id, 'group.edit')
  order by g.name;
$$;

revoke all on function public.my_managed_groups() from public, anon;
grant execute on function public.my_managed_groups() to authenticated;

-- ---------------------------------------------------------------------------
-- Storage: support-attachments
-- owner: support
-- Private. Users write and read inside <uid>/; platform staff read all.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('support-attachments', 'support-attachments', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy support_attachments_select_own_or_staff
  on storage.objects for select to authenticated
  using (
    bucket_id = 'support-attachments'
    and ((storage.foldername(name))[1] = (select auth.uid())::text or (select private.is_platform_staff()))
  );

create policy support_attachments_insert_own
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select private.is_account_active(auth.uid()))
  );

create policy support_attachments_delete_own
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
