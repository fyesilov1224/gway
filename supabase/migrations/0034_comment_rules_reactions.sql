-- Comments and emoji reactions on posts (docs/ARCHITECTURE.md §3c, user decision 2026-10-27).
-- On a personal photo or video only its author, the author's matches and teammates write comments; everyone who
-- sees it can leave one emoji reaction. Group posts keep their comments open to whoever sees them.
-- owner: feed

-- ---------------------------------------------------------------------------
-- Who writes a comment
-- ---------------------------------------------------------------------------
create function private.can_comment_as(uid uuid, target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.posts p
    where p.id = target and p.removed_at is null and not p.comments_disabled
      and (p.group_id is not null
           or p.author_id = uid
           or private.are_matched(uid, p.author_id)
           or private.are_teammates(uid, p.author_id))
  );
$$;

revoke all on function private.can_comment_as(uuid, uuid) from public;
grant execute on function private.can_comment_as(uuid, uuid) to authenticated, service_role;

create function private.comments_require_relation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not private.can_comment_as(new.author_id, new.post_id) then
    perform private.raise_feed_rule('comment_not_allowed');
  end if;
  return new;
end;
$$;

create trigger comments_require_relation
  before insert on public.comments
  for each row execute function private.comments_require_relation();

-- ---------------------------------------------------------------------------
-- Emoji reactions: one per person and post, the person's own simple write
-- ---------------------------------------------------------------------------
create table public.post_reactions (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  emoji      text not null check (emoji in ('😍', '😂', '😮', '👏', '🔥', '🙏')),
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

comment on table public.post_reactions is 'owner: feed. One emoji reaction per person and post; anyone who sees the post may react.';

create index post_reactions_user_idx on public.post_reactions (user_id, created_at desc);

alter table public.post_reactions enable row level security;
revoke all on public.post_reactions from anon, authenticated;
grant select on public.post_reactions to anon, authenticated;
grant insert (post_id, user_id, emoji), update (emoji), delete on public.post_reactions to authenticated;

create policy post_reactions_select_visible on public.post_reactions for select to anon, authenticated
  using (private.can_view_post(post_id) and not private.is_blocked_between(user_id, (select auth.uid())));
create policy post_reactions_insert_own on public.post_reactions for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and private.can_view_post(post_id)
  );
create policy post_reactions_update_own on public.post_reactions for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy post_reactions_delete_own on public.post_reactions for delete to authenticated
  using (user_id = (select auth.uid()));

create function private.post_reactions_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.created_at := now();
  return new;
end;
$$;

create trigger post_reactions_touch
  before insert or update on public.post_reactions
  for each row execute function private.post_reactions_touch();

-- ---------------------------------------------------------------------------
-- The card says whether the viewer may comment, and carries the reactions (as in 0016, plus both)
-- ---------------------------------------------------------------------------
create or replace function public.post_card(p public.posts)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id,
    'caption', p.caption,
    'created_at', p.created_at,
    'edited_at', p.edited_at,
    'comments_disabled', p.comments_disabled,
    'hide_like_count', p.hide_like_count,
    'like_count', case when p.hide_like_count and not private.can_manage_post(p.id) then null else p.like_count end,
    'comment_count', p.comment_count,
    'removed_at', p.removed_at,
    'author', (select jsonb_build_object('id', a.id, 'username', a.username, 'display_name', a.display_name,
                                         'avatar_path', a.avatar_path)
               from public.profiles a where a.id = p.author_id),
    'group', (select jsonb_build_object('id', g.id, 'handle', g.handle, 'name', g.name, 'logo_path', g.logo_path)
              from public.groups g where g.id = p.group_id),
    'event', (select jsonb_build_object('id', e.id, 'title', e.title) from public.events e where e.id = p.event_id),
    'media', coalesce((select jsonb_agg(jsonb_build_object('kind', m.kind, 'path', m.path, 'width', m.width, 'height', m.height,
                                                           'duration_ms', m.duration_ms, 'poster_path', m.poster_path,
                                                           'thumb_path', m.thumb_path)
                                        order by m.position)
                       from public.post_media m where m.post_id = p.id), '[]'::jsonb),
    'liked', exists (select 1 from public.post_likes l where l.post_id = p.id and l.user_id = (select auth.uid())),
    'saved', exists (select 1 from public.saved_posts s where s.post_id = p.id and s.user_id = (select auth.uid())),
    'can_manage', private.can_manage_post(p.id),
    'can_comment', (select auth.uid()) is not null and private.can_comment_as((select auth.uid()), p.id),
    'reactions', coalesce((select jsonb_object_agg(r.emoji, r.n)
                           from (select x.emoji, count(*) as n from public.post_reactions x
                                 where x.post_id = p.id group by x.emoji) r), '{}'::jsonb),
    'my_reaction', (select x.emoji from public.post_reactions x where x.post_id = p.id and x.user_id = (select auth.uid()))
  );
$$;
