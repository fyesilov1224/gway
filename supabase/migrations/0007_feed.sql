-- 0007_feed
-- Phase 4: posts (photos, videos, carousel), hashtags, likes, comments with
-- replies, saves, stories with views, highlights, the media bucket and the
-- feed, explore and search RPCs. Rules: docs/ARCHITECTURE.md §3c.
--
-- Posts are written by the C# API (actor in request.jwt.claims). Likes,
-- comments, saves, stories and highlights are the user's own simple writes
-- (RLS). Triggers keep counters and re-check the rules.

-- ---------------------------------------------------------------------------
-- Permission: posts.publish (owner and Yönetici)
-- ---------------------------------------------------------------------------
insert into public.group_permissions (slug, description) values
  ('posts.publish', 'Grup adına gönderi paylaşma, düzenleme ve silme; grup gönderilerindeki yorumları silme');
insert into public.group_role_permissions (role, permission) values ('admin', 'posts.publish');

-- ---------------------------------------------------------------------------
-- posts, post_media, post_hashtags
-- owner: feed
-- ---------------------------------------------------------------------------
create table public.posts (
  id                uuid primary key default gen_random_uuid(),
  author_id         uuid references public.profiles (id) on delete set null,
  group_id          uuid references public.groups (id) on delete cascade,
  caption           text not null default '' check (char_length(caption) <= 2200),
  comments_disabled boolean not null default false,
  hide_like_count   boolean not null default false,
  like_count        int not null default 0,
  comment_count     int not null default 0,
  created_at        timestamptz not null default now(),
  edited_at         timestamptz,
  removed_at        timestamptz,
  removed_reason    text check (char_length(removed_reason) <= 500),
  removed_by        uuid,
  constraint posts_has_owner check (group_id is not null or author_id is not null),
  constraint posts_removal_consistent check ((removed_at is null) = (removed_reason is null))
);

comment on table public.posts is
  'owner: feed. Photo/video posts of a user, or of a group (group_id, author = the publishing manager).';
comment on column public.posts.author_id is
  'Null only for group posts whose publishing manager deleted their account.';

create index posts_author_idx on public.posts (author_id, created_at desc) where group_id is null;
create index posts_group_idx on public.posts (group_id, created_at desc) where group_id is not null;
create index posts_recent_idx on public.posts (created_at desc);

create table public.post_media (
  post_id     uuid not null references public.posts (id) on delete cascade,
  position    smallint not null check (position between 0 and 9),
  kind        text not null check (kind in ('image', 'video')),
  path        text not null unique,
  width       int not null check (width between 1 and 10000),
  height      int not null check (height between 1 and 10000),
  duration_ms int check (duration_ms between 1 and 60000),
  poster_path text,
  thumb_path  text,
  primary key (post_id, position),
  constraint post_media_video_fields check ((kind = 'video') = (duration_ms is not null)),
  constraint post_media_poster_only_video check (kind = 'video' or poster_path is null),
  constraint post_media_thumb_only_image check (kind = 'image' or thumb_path is null)
);
comment on table public.post_media is 'owner: feed. 1-10 photos or videos of a post, in order. Paths are in the media bucket.';
comment on column public.post_media.thumb_path is 'Small copy (480 px) made on the device, for grids and previews.';

create table public.post_hashtags (
  post_id uuid not null references public.posts (id) on delete cascade,
  tag     text not null check (tag ~ '^[[:alnum:]_]{1,50}$'),
  primary key (post_id, tag)
);
create index post_hashtags_tag_idx on public.post_hashtags (tag);
comment on table public.post_hashtags is 'owner: feed. #tags extracted from captions by trigger (lower case).';

-- ---------------------------------------------------------------------------
-- post_likes, comments, comment_likes, saved_posts
-- owner: feed
-- ---------------------------------------------------------------------------
create table public.post_likes (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index post_likes_user_idx on public.post_likes (user_id, created_at desc);
comment on table public.post_likes is 'owner: feed.';

create table public.comments (
  id             uuid primary key default gen_random_uuid(),
  post_id        uuid not null references public.posts (id) on delete cascade,
  author_id      uuid not null references public.profiles (id) on delete cascade,
  parent_id      uuid references public.comments (id) on delete cascade,
  body           text not null check (char_length(btrim(body)) between 1 and 2200),
  like_count     int not null default 0,
  created_at     timestamptz not null default now(),
  removed_at     timestamptz,
  removed_reason text check (char_length(removed_reason) <= 500),
  removed_by     uuid,
  constraint comments_removal_consistent check ((removed_at is null) = (removed_reason is null))
);
create index comments_post_idx on public.comments (post_id, created_at);
create index comments_parent_idx on public.comments (parent_id) where parent_id is not null;
comment on table public.comments is 'owner: feed. Comments; replies point at a top-level comment (one level).';

create table public.comment_likes (
  comment_id uuid not null references public.comments (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);
comment on table public.comment_likes is 'owner: feed.';

create table public.saved_posts (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index saved_posts_user_idx on public.saved_posts (user_id, created_at desc);
comment on table public.saved_posts is 'owner: feed. Private bookmarks.';

-- ---------------------------------------------------------------------------
-- stories, story_views, highlights, highlight_stories
-- owner: feed
-- ---------------------------------------------------------------------------
create table public.stories (
  id          uuid primary key default gen_random_uuid(),
  author_id   uuid not null references public.profiles (id) on delete cascade,
  kind        text not null check (kind in ('image', 'video')),
  path        text not null unique,
  width       int not null check (width between 1 and 10000),
  height      int not null check (height between 1 and 10000),
  duration_ms int check (duration_ms between 1 and 60000),
  poster_path text,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '24 hours',
  constraint stories_video_fields check ((kind = 'video') = (duration_ms is not null)),
  constraint stories_path_own check (path like author_id::text || '/%'),
  constraint stories_poster_own check (poster_path is null or poster_path like author_id::text || '/%')
);
create index stories_author_idx on public.stories (author_id, created_at desc);
comment on table public.stories is 'owner: feed. 24-hour stories; kept afterwards as the author''s archive and for highlights.';

create table public.story_views (
  story_id  uuid not null references public.stories (id) on delete cascade,
  viewer_id uuid not null references public.profiles (id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (story_id, viewer_id)
);
comment on table public.story_views is 'owner: feed. Who saw a story; only its author reads the list.';

create table public.highlights (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null references public.profiles (id) on delete cascade,
  title      text not null check (char_length(btrim(title)) between 1 and 30),
  created_at timestamptz not null default now()
);
create index highlights_owner_idx on public.highlights (owner_id, created_at);
comment on table public.highlights is 'owner: feed. Story albums kept on the profile.';

create table public.highlight_stories (
  highlight_id uuid not null references public.highlights (id) on delete cascade,
  story_id     uuid not null references public.stories (id) on delete cascade,
  added_at     timestamptz not null default now(),
  primary key (highlight_id, story_id)
);
comment on table public.highlight_stories is 'owner: feed.';

-- ---------------------------------------------------------------------------
-- Visibility
-- ---------------------------------------------------------------------------
create function private.can_view_post(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.posts p
    where p.id = target
      and (
        private.is_platform_staff()
        or (p.removed_at is null and case
              when p.group_id is not null then private.is_group_visible(p.group_id)
              else private.can_view_user_content(p.author_id)
            end)
      )
  );
$$;

-- Author of a personal post, or a publisher of the group for a group post.
create function private.can_manage_post(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.posts p
    where p.id = target
      and case
            when p.group_id is not null then private.has_group_permission(p.group_id, 'posts.publish')
            else p.author_id = (select auth.uid())
          end
  );
$$;

-- The personal author of a post (null for group posts): blocks apply to them.
create function private.post_owner(target uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select case when p.group_id is null then p.author_id end from public.posts p where p.id = target;
$$;

create function private.can_view_story(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.stories s
    where s.id = target
      and (
        s.author_id = (select auth.uid())
        or private.is_platform_staff()
        or (private.can_view_user_content(s.author_id)
            and (s.expires_at > now() or exists (select 1 from public.highlight_stories h where h.story_id = s.id)))
      )
  );
$$;

revoke all on function private.can_view_post(uuid), private.can_manage_post(uuid), private.post_owner(uuid),
  private.can_view_story(uuid) from public;
grant execute on function private.can_view_post(uuid), private.can_manage_post(uuid), private.post_owner(uuid),
  private.can_view_story(uuid) to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.posts enable row level security;
alter table public.post_media enable row level security;
alter table public.post_hashtags enable row level security;
alter table public.post_likes enable row level security;
alter table public.comments enable row level security;
alter table public.comment_likes enable row level security;
alter table public.saved_posts enable row level security;
alter table public.stories enable row level security;
alter table public.story_views enable row level security;
alter table public.highlights enable row level security;
alter table public.highlight_stories enable row level security;

revoke all on public.posts, public.post_media, public.post_hashtags, public.post_likes, public.comments,
  public.comment_likes, public.saved_posts, public.stories, public.story_views, public.highlights,
  public.highlight_stories from anon, authenticated;

grant select on public.posts, public.post_media, public.post_hashtags, public.post_likes, public.comments,
  public.comment_likes, public.stories, public.highlights, public.highlight_stories to anon, authenticated;
grant select on public.saved_posts, public.story_views to authenticated;
grant insert (post_id, user_id), delete on public.post_likes to authenticated;
grant insert (id, post_id, author_id, parent_id, body), delete on public.comments to authenticated;
grant insert (comment_id, user_id), delete on public.comment_likes to authenticated;
grant insert (user_id, post_id), delete on public.saved_posts to authenticated;
grant insert (id, author_id, kind, path, width, height, duration_ms, poster_path), delete on public.stories to authenticated;
grant insert (story_id, viewer_id) on public.story_views to authenticated;
grant insert (id, owner_id, title), update (title), delete on public.highlights to authenticated;
grant insert (highlight_id, story_id), delete on public.highlight_stories to authenticated;

create policy posts_select_visible on public.posts for select to anon, authenticated
  using (
    (select private.is_platform_staff())
    or (removed_at is null and case
          when group_id is not null then private.is_group_visible(group_id)
          else private.can_view_user_content(author_id)
        end)
  );

create policy post_media_select_visible on public.post_media for select to anon, authenticated
  using (private.can_view_post(post_id));
create policy post_hashtags_select_visible on public.post_hashtags for select to anon, authenticated
  using (private.can_view_post(post_id));

create policy post_likes_select_visible on public.post_likes for select to anon, authenticated
  using (private.can_view_post(post_id) and not private.is_blocked_between(user_id, (select auth.uid())));
create policy post_likes_insert_own on public.post_likes for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and private.can_view_post(post_id)
  );
create policy post_likes_delete_own on public.post_likes for delete to authenticated
  using (user_id = (select auth.uid()));

create policy comments_select_visible on public.comments for select to anon, authenticated
  using (
    (select private.is_platform_staff())
    or (removed_at is null and private.can_view_post(post_id)
        and not private.is_blocked_between(author_id, (select auth.uid())))
  );
create policy comments_insert_own on public.comments for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and private.can_view_post(post_id)
  );
create policy comments_delete_author_or_post_manager on public.comments for delete to authenticated
  using (author_id = (select auth.uid()) or private.can_manage_post(post_id));

create policy comment_likes_select_visible on public.comment_likes for select to anon, authenticated
  using (exists (select 1 from public.comments c where c.id = comment_id));
create policy comment_likes_insert_own on public.comment_likes for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (select private.is_account_active(auth.uid()))
    and exists (select 1 from public.comments c where c.id = comment_id)
  );
create policy comment_likes_delete_own on public.comment_likes for delete to authenticated
  using (user_id = (select auth.uid()));

create policy saved_posts_own on public.saved_posts for select to authenticated
  using (user_id = (select auth.uid()));
create policy saved_posts_insert_own on public.saved_posts for insert to authenticated
  with check (user_id = (select auth.uid()) and private.can_view_post(post_id));
create policy saved_posts_delete_own on public.saved_posts for delete to authenticated
  using (user_id = (select auth.uid()));

create policy stories_select_visible on public.stories for select to anon, authenticated
  using (private.can_view_story(id));
create policy stories_insert_own on public.stories for insert to authenticated
  with check (author_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));
create policy stories_delete_own on public.stories for delete to authenticated
  using (author_id = (select auth.uid()));

create policy story_views_select_author_or_own on public.story_views for select to authenticated
  using (
    viewer_id = (select auth.uid())
    or exists (select 1 from public.stories s where s.id = story_id and s.author_id = (select auth.uid()))
  );
create policy story_views_insert_own on public.story_views for insert to authenticated
  with check (viewer_id = (select auth.uid()) and private.can_view_story(story_id));

create policy highlights_select_visible on public.highlights for select to anon, authenticated
  using (private.can_view_user_content(owner_id));
create policy highlights_insert_own on public.highlights for insert to authenticated
  with check (owner_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));
create policy highlights_update_own on public.highlights for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy highlights_delete_own on public.highlights for delete to authenticated
  using (owner_id = (select auth.uid()));

create policy highlight_stories_select_visible on public.highlight_stories for select to anon, authenticated
  using (exists (select 1 from public.highlights h where h.id = highlight_id));
create policy highlight_stories_insert_own on public.highlight_stories for insert to authenticated
  with check (
    exists (select 1 from public.highlights h where h.id = highlight_id and h.owner_id = (select auth.uid()))
    and exists (select 1 from public.stories s where s.id = story_id and s.author_id = (select auth.uid()))
  );
create policy highlight_stories_delete_own on public.highlight_stories for delete to authenticated
  using (exists (select 1 from public.highlights h where h.id = highlight_id and h.owner_id = (select auth.uid())));

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create function private.raise_feed_rule(code text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception '%', code using errcode = 'P0001';
end;
$$;

-- Posts: written by the backend as the author; removal fields only on behalf of staff.
create function private.posts_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  actor uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    if actor is null or actor is distinct from new.author_id or not private.is_account_active(actor) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    if new.group_id is not null and not private.has_group_permission(new.group_id, 'posts.publish') then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    if (select count(*) from public.posts p where p.author_id = actor and p.created_at > now() - interval '24 hours') >= 25 then
      perform private.raise_feed_rule('post_rate_limited');
    end if;
    new.caption := btrim(new.caption);
    new.like_count := 0;
    new.comment_count := 0;
    new.created_at := now();
    new.edited_at := null;
    new.removed_at := null;
    new.removed_reason := null;
    new.removed_by := null;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if pg_trigger_depth() > 1 or (old.group_id is not null and not exists (select 1 from public.groups g where g.id = old.group_id)) then
      return old;
    end if;
    if not private.can_manage_post(old.id) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    return old;
  end if;

  -- Counters and the author link (account deletion) change through nested triggers and cascades.
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.group_id, new.created_at) is distinct from (old.id, old.group_id, old.created_at)
     or (new.author_id is distinct from old.author_id and new.author_id is not null) then
    perform private.raise_feed_rule('post_immutable');
  end if;
  if (new.removed_at, new.removed_reason) is distinct from (old.removed_at, old.removed_reason) then
    if not private.is_platform_staff(array['admin', 'moderator']) then
      perform private.raise_feed_rule('post_removal_forbidden');
    end if;
    new.removed_by := actor;
  end if;
  if (new.caption, new.comments_disabled, new.hide_like_count) is distinct from (old.caption, old.comments_disabled, old.hide_like_count) then
    if not private.can_manage_post(old.id) then
      perform private.raise_feed_rule('post_forbidden');
    end if;
    new.caption := btrim(new.caption);
    if new.caption is distinct from old.caption then
      new.edited_at := now();
    end if;
  end if;
  if (new.like_count, new.comment_count) is distinct from (old.like_count, old.comment_count) then
    perform private.raise_feed_rule('post_immutable');
  end if;
  return new;
end;
$$;

create trigger posts_guard
  before insert or update or delete on public.posts
  for each row execute function private.posts_guard();

-- #tags of the caption, lower case, at most 30.
create function private.posts_sync_hashtags()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.post_hashtags where post_id = new.id;
  insert into public.post_hashtags (post_id, tag)
  select distinct new.id, lower(m[1])
  from regexp_matches(new.caption, '#([[:alnum:]_]{1,50})', 'g') m
  limit 30;
  return null;
end;
$$;

create trigger posts_sync_hashtags
  after insert or update of caption on public.posts
  for each row execute function private.posts_sync_hashtags();

-- Personal posts go with the account; group posts stay with the group (author becomes null).
create function private.profiles_delete_posts()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.posts where author_id = old.id and group_id is null;
  return old;
end;
$$;

create trigger profiles_delete_posts
  before delete on public.profiles
  for each row execute function private.profiles_delete_posts();

-- Media rows only through the backend, in the author's folder, while the post is being created.
create function private.post_media_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  p public.posts;
begin
  select * into p from public.posts where id = new.post_id;
  if p.author_id is distinct from (select auth.uid())
     or new.path not like p.author_id::text || '/%'
     or (new.poster_path is not null and new.poster_path not like p.author_id::text || '/%')
     or (new.thumb_path is not null and new.thumb_path not like p.author_id::text || '/%') then
    perform private.raise_feed_rule('media_forbidden');
  end if;
  if p.created_at < now() - interval '5 minutes' then
    perform private.raise_feed_rule('media_immutable');
  end if;
  return new;
end;
$$;

create trigger post_media_guard
  before insert on public.post_media
  for each row execute function private.post_media_guard();

-- Likes: blocks and rate.
create function private.post_likes_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_blocked_between(new.user_id, private.post_owner(new.post_id)) then
    perform private.raise_feed_rule('blocked');
  end if;
  if (select count(*) from public.post_likes where user_id = new.user_id and created_at > now() - interval '1 hour')
     + (select count(*) from public.comment_likes where user_id = new.user_id and created_at > now() - interval '1 hour') >= 600 then
    perform private.raise_feed_rule('like_rate_limited');
  end if;
  new.created_at := now();
  return new;
end;
$$;

create trigger post_likes_before_insert
  before insert on public.post_likes
  for each row execute function private.post_likes_before_insert();

create function private.post_likes_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts set like_count = like_count + 1 where id = new.post_id;
  else
    update public.posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end;
$$;

create trigger post_likes_count
  after insert or delete on public.post_likes
  for each row execute function private.post_likes_count();

-- Comments: replies attach to the top-level comment; comments off, blocks, rate.
create function private.comments_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  parent public.comments;
begin
  if (select comments_disabled from public.posts where id = new.post_id) then
    perform private.raise_feed_rule('comments_disabled');
  end if;
  if private.is_blocked_between(new.author_id, private.post_owner(new.post_id)) then
    perform private.raise_feed_rule('blocked');
  end if;
  if new.parent_id is not null then
    select * into parent from public.comments where id = new.parent_id;
    if parent.id is null or parent.post_id <> new.post_id or parent.removed_at is not null then
      perform private.raise_feed_rule('reply_target_invalid');
    end if;
    new.parent_id := coalesce(parent.parent_id, parent.id);
    if private.is_blocked_between(new.author_id, parent.author_id) then
      perform private.raise_feed_rule('blocked');
    end if;
  end if;
  if (select count(*) from public.comments where author_id = new.author_id and created_at > now() - interval '1 hour') >= 120 then
    perform private.raise_feed_rule('comment_rate_limited');
  end if;
  new.body := btrim(new.body);
  new.like_count := 0;
  new.created_at := now();
  new.removed_at := null;
  new.removed_reason := null;
  new.removed_by := null;
  return new;
end;
$$;

create trigger comments_before_insert
  before insert on public.comments
  for each row execute function private.comments_before_insert();

-- Comments change only by admin removal (or counters from nested triggers).
create function private.comments_before_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if pg_trigger_depth() > 1 then
    return new;
  end if;
  if (new.id, new.post_id, new.author_id, new.parent_id, new.body, new.created_at, new.like_count)
     is distinct from (old.id, old.post_id, old.author_id, old.parent_id, old.body, old.created_at, old.like_count)
     or not private.is_platform_staff(array['admin', 'moderator']) then
    perform private.raise_feed_rule('comment_immutable');
  end if;
  new.removed_by := (select auth.uid());
  return new;
end;
$$;

create trigger comments_before_update
  before update on public.comments
  for each row execute function private.comments_before_update();

-- comment_count counts visible comments (replies included).
create function private.comments_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts set comment_count = comment_count + 1 where id = new.post_id;
  elsif tg_op = 'DELETE' then
    if old.removed_at is null then
      update public.posts set comment_count = greatest(comment_count - 1, 0) where id = old.post_id;
    end if;
  elsif old.removed_at is null and new.removed_at is not null then
    update public.posts set comment_count = greatest(comment_count - 1, 0) where id = new.post_id;
  elsif old.removed_at is not null and new.removed_at is null then
    update public.posts set comment_count = comment_count + 1 where id = new.post_id;
  end if;
  return null;
end;
$$;

create trigger comments_count
  after insert or delete or update of removed_at on public.comments
  for each row execute function private.comments_count();

create function private.comment_likes_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if private.is_blocked_between(new.user_id, (select author_id from public.comments where id = new.comment_id)) then
    perform private.raise_feed_rule('blocked');
  end if;
  new.created_at := now();
  return new;
end;
$$;

create trigger comment_likes_before_insert
  before insert on public.comment_likes
  for each row execute function private.comment_likes_before_insert();

create function private.comment_likes_count()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.comments set like_count = like_count + 1 where id = new.comment_id;
  else
    update public.comments set like_count = greatest(like_count - 1, 0) where id = old.comment_id;
  end if;
  return null;
end;
$$;

create trigger comment_likes_count
  after insert or delete on public.comment_likes
  for each row execute function private.comment_likes_count();

-- Stories: 24 hours from now, at most 50 a day.
create function private.stories_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select count(*) from public.stories where author_id = new.author_id and created_at > now() - interval '24 hours') >= 50 then
    perform private.raise_feed_rule('story_rate_limited');
  end if;
  new.created_at := now();
  new.expires_at := now() + interval '24 hours';
  return new;
end;
$$;

create trigger stories_before_insert
  before insert on public.stories
  for each row execute function private.stories_before_insert();

create function private.story_views_before_insert()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.viewed_at := now();
  return new;
end;
$$;

create trigger story_views_before_insert
  before insert on public.story_views
  for each row execute function private.story_views_before_insert();

create function private.highlights_limits()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_table_name = 'highlights' then
    new.title := btrim(new.title);
    if tg_op = 'INSERT' then
      new.created_at := now();
      if (select count(*) from public.highlights where owner_id = new.owner_id) >= 100 then
        perform private.raise_feed_rule('highlight_limit');
      end if;
    end if;
  elsif (select count(*) from public.highlight_stories where highlight_id = new.highlight_id) >= 100 then
    perform private.raise_feed_rule('highlight_full');
  end if;
  return new;
end;
$$;

create trigger highlights_limits
  before insert or update on public.highlights
  for each row execute function private.highlights_limits();
create trigger highlight_stories_limits
  before insert on public.highlight_stories
  for each row execute function private.highlights_limits();

-- ---------------------------------------------------------------------------
-- Storage: media
-- owner: feed
-- Public read with unguessable paths; users write only inside <uid>/.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('media', 'media', true, 52428800, array['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/quicktime'])
on conflict (id) do nothing;

create policy media_insert_own on storage.objects for insert to authenticated
  with check (
    bucket_id = 'media'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select private.is_account_active(auth.uid()))
  );
create policy media_select_own on storage.objects for select to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy media_delete_own on storage.objects for delete to authenticated
  using (bucket_id = 'media' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ---------------------------------------------------------------------------
-- Read models (SECURITY INVOKER: everything below runs under the caller's RLS)
-- ---------------------------------------------------------------------------

-- A post as the app shows it. Like counts hidden by the author are null for others.
create function public.post_card(p public.posts)
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
    'media', coalesce((select jsonb_agg(jsonb_build_object('kind', m.kind, 'path', m.path, 'width', m.width, 'height', m.height,
                                                           'duration_ms', m.duration_ms, 'poster_path', m.poster_path,
                                                           'thumb_path', m.thumb_path)
                                        order by m.position)
                       from public.post_media m where m.post_id = p.id), '[]'::jsonb),
    'liked', exists (select 1 from public.post_likes l where l.post_id = p.id and l.user_id = (select auth.uid())),
    'saved', exists (select 1 from public.saved_posts s where s.post_id = p.id and s.user_id = (select auth.uid())),
    'can_manage', private.can_manage_post(p.id)
  );
$$;

-- Home feed: own posts, followed users, followed or joined groups. Newest first, keyset paging.
create function public.home_feed(before_at timestamptz default null, before_id uuid default null, page_size int default 20)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  where (
      (p.group_id is null and (
        p.author_id = (select auth.uid())
        or exists (select 1 from public.follows f where f.follower_id = (select auth.uid()) and f.followee_id = p.author_id)))
      or (p.group_id is not null and (
        exists (select 1 from public.group_follows gf where gf.user_id = (select auth.uid()) and gf.group_id = p.group_id)
        or exists (select 1 from public.group_members gm where gm.user_id = (select auth.uid()) and gm.group_id = p.group_id)))
    )
    and (before_at is null or (p.created_at, p.id) < (before_at, before_id))
    and not private.is_blocked_between(p.author_id, (select auth.uid()))
  order by p.created_at desc, p.id desc
  limit least(greatest(page_size, 1), 50);
$$;

-- A user's own (non-group) posts, for the profile grid.
create function public.user_posts(target uuid, before_at timestamptz default null, before_id uuid default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  where p.author_id = target and p.group_id is null
    and (before_at is null or (p.created_at, p.id) < (before_at, before_id))
  order by p.created_at desc, p.id desc
  limit least(greatest(page_size, 1), 60);
$$;

create function public.group_posts(target uuid, before_at timestamptz default null, before_id uuid default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  where p.group_id = target
    and (before_at is null or (p.created_at, p.id) < (before_at, before_id))
  order by p.created_at desc, p.id desc
  limit least(greatest(page_size, 1), 60);
$$;

create function public.hashtag_posts(tag text, before_at timestamptz default null, before_id uuid default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  join public.post_hashtags h on h.post_id = p.id and h.tag = lower(hashtag_posts.tag)
  where (before_at is null or (p.created_at, p.id) < (before_at, before_id))
    and not private.is_blocked_between(p.author_id, (select auth.uid()))
  order by p.created_at desc, p.id desc
  limit least(greatest(page_size, 1), 60);
$$;

create function public.saved_feed(before_at timestamptz default null, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.saved_posts s
  join public.posts p on p.id = s.post_id
  where s.user_id = (select auth.uid()) and (before_at is null or s.created_at < before_at)
  order by s.created_at desc
  limit least(greatest(page_size, 1), 60);
$$;

create function public.post_by_id(target uuid)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p) from public.posts p where p.id = target;
$$;

-- Explore: popular recent posts from public accounts and groups the user does not follow.
create function public.explore_posts(page_offset int default 0, page_size int default 30)
returns setof jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select public.post_card(p)
  from public.posts p
  left join public.profiles a on a.id = p.author_id
  where p.created_at > now() - interval '14 days'
    and (p.author_id is distinct from (select auth.uid()))
    and (
      (p.group_id is null and not a.is_private
        and not exists (select 1 from public.follows f where f.follower_id = (select auth.uid()) and f.followee_id = p.author_id))
      or (p.group_id is not null
        and not exists (select 1 from public.group_follows gf where gf.user_id = (select auth.uid()) and gf.group_id = p.group_id))
    )
    and not private.is_blocked_between(p.author_id, (select auth.uid()))
  order by (p.like_count + 2 * p.comment_count + 1)
           / power(extract(epoch from now() - p.created_at) / 3600 + 2, 1.5) desc, p.id
  offset greatest(page_offset, 0)
  limit least(greatest(page_size, 1), 60);
$$;

create function public.search_hashtags(query text, max_results int default 20)
returns table (tag text, post_count bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select h.tag, count(*)
  from public.post_hashtags h
  where h.tag like lower(btrim(query, '# ')) || '%' and char_length(btrim(query, '# ')) > 0
  group by h.tag
  order by count(*) desc, h.tag
  limit least(greatest(max_results, 1), 50);
$$;

-- Account search: username or display name; RLS hides blocked and inactive accounts.
create function public.search_profiles(query text, max_results int default 20)
returns table (id uuid, username text, display_name text, avatar_path text, is_private boolean,
               i_follow boolean, requested boolean, follows_me boolean)
language sql
stable
security invoker
set search_path = ''
as $$
  select p.id, p.username, p.display_name, p.avatar_path, p.is_private,
         private.user_follows((select auth.uid()), p.id),
         exists (select 1 from public.follow_requests r where r.requester_id = (select auth.uid()) and r.target_id = p.id),
         private.user_follows(p.id, (select auth.uid()))
  from public.profiles p
  where char_length(btrim(query, '@ ')) > 0
    and (p.username like lower(btrim(query, '@ ')) || '%' or p.display_name ilike '%' || btrim(query, '@ ') || '%')
    and not private.is_blocked_between(p.id, (select auth.uid()))
  order by (p.username = lower(btrim(query, '@ '))) desc,
           (select count(*) from public.follows f where f.followee_id = p.id) desc, p.username
  limit least(greatest(max_results, 1), 50);
$$;

-- Accounts the user may know: followed by people they follow; otherwise popular public accounts.
create function public.suggested_profiles(max_results int default 10)
returns table (id uuid, username text, display_name text, avatar_path text, is_private boolean, mutual_count bigint)
language sql
stable
security invoker
set search_path = ''
as $$
  select p.id, p.username, p.display_name, p.avatar_path, p.is_private,
         (select count(*) from public.follows f1
          join public.follows f2 on f2.follower_id = f1.followee_id and f2.followee_id = p.id
          where f1.follower_id = (select auth.uid()))
  from public.profiles p
  where p.id <> (select auth.uid())
    and not private.user_follows((select auth.uid()), p.id)
    and not exists (select 1 from public.follow_requests r where r.requester_id = (select auth.uid()) and r.target_id = p.id)
    and not private.is_blocked_between(p.id, (select auth.uid()))
  order by 6 desc, (select count(*) from public.follows f where f.followee_id = p.id) desc, p.created_at desc
  limit least(greatest(max_results, 1), 30);
$$;

-- Story ring: the user and people they follow with unexpired stories; unseen first.
create function public.story_tray()
returns table (user_id uuid, username text, avatar_path text, story_count bigint, has_unseen boolean, latest_at timestamptz)
language sql
stable
security invoker
set search_path = ''
as $$
  select s.author_id, p.username, p.avatar_path, count(*),
         bool_or(not exists (select 1 from public.story_views v where v.story_id = s.id and v.viewer_id = (select auth.uid()))),
         max(s.created_at)
  from public.stories s
  join public.profiles p on p.id = s.author_id
  where s.expires_at > now()
    and (s.author_id = (select auth.uid())
         or exists (select 1 from public.follows f where f.follower_id = (select auth.uid()) and f.followee_id = s.author_id))
  group by s.author_id, p.username, p.avatar_path
  order by (s.author_id = (select auth.uid())) desc, 5 desc, 6 desc;
$$;

-- Profile counts are public even for private accounts (the lists are not).
create function private.profile_counts(target uuid)
returns table (posts bigint, followers bigint, following bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select (select count(*) from public.posts x where x.author_id = target and x.group_id is null and x.removed_at is null),
         (select count(*) from public.follows f where f.followee_id = target),
         (select count(*) from public.follows f where f.follower_id = target);
$$;

revoke all on function private.profile_counts(uuid) from public;
grant execute on function private.profile_counts(uuid) to anon, authenticated, service_role;

-- Counts and relationship shown on a profile.
create function public.profile_social(target uuid)
returns table (post_count bigint, follower_count bigint, following_count bigint, is_private boolean,
               i_follow boolean, requested boolean, follows_me boolean, blocked_by_me boolean, can_view boolean)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.posts, c.followers, c.following,
         p.is_private,
         private.user_follows((select auth.uid()), p.id),
         exists (select 1 from public.follow_requests r where r.requester_id = (select auth.uid()) and r.target_id = p.id),
         private.user_follows(p.id, (select auth.uid())),
         exists (select 1 from public.blocks b where b.blocker_id = (select auth.uid()) and b.blocked_id = p.id),
         private.can_view_user_content(p.id)
  from public.profiles p
  cross join lateral private.profile_counts(p.id) c
  where p.id = target;
$$;

-- Groups the user may post for (posts.publish).
create function public.my_publishable_groups()
returns table (id uuid, name text, handle text, logo_path text)
language sql
stable
security invoker
set search_path = ''
as $$
  select g.id, g.name, g.handle, g.logo_path
  from public.groups g
  join public.group_members m on m.group_id = g.id and m.user_id = (select auth.uid())
  where private.has_group_permission(g.id, 'posts.publish')
  order by g.name;
$$;

revoke all on function public.my_publishable_groups() from public, anon;
grant execute on function public.my_publishable_groups() to authenticated;

revoke all on function public.post_card(public.posts), public.home_feed(timestamptz, uuid, int),
  public.user_posts(uuid, timestamptz, uuid, int), public.group_posts(uuid, timestamptz, uuid, int),
  public.hashtag_posts(text, timestamptz, uuid, int), public.saved_feed(timestamptz, int), public.post_by_id(uuid),
  public.explore_posts(int, int), public.search_hashtags(text, int), public.search_profiles(text, int),
  public.suggested_profiles(int), public.story_tray(), public.profile_social(uuid) from public;
grant execute on function public.post_card(public.posts), public.user_posts(uuid, timestamptz, uuid, int),
  public.group_posts(uuid, timestamptz, uuid, int), public.hashtag_posts(text, timestamptz, uuid, int),
  public.post_by_id(uuid), public.explore_posts(int, int), public.search_hashtags(text, int),
  public.search_profiles(text, int), public.profile_social(uuid) to anon, authenticated;
grant execute on function public.home_feed(timestamptz, uuid, int), public.saved_feed(timestamptz, int),
  public.suggested_profiles(int), public.story_tray() to authenticated;
