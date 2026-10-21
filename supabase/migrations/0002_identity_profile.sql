-- 0002_identity_profile
-- Phase 1: categories, legal documents and consents, account status, profiles,
-- interests and profile image storage. Rules: docs/ARCHITECTURE.md §3a.

grant usage on schema private to anon;
grant execute on function private.is_platform_staff(text[]) to anon;

-- ---------------------------------------------------------------------------
-- categories
-- owner: core
-- Shared reference data: profile interests now, group categories in Phase 2.
-- ---------------------------------------------------------------------------
create table public.categories (
  slug       text primary key check (slug ~ '^[a-z_]+$'),
  name       text not null,
  sort_order int  not null
);

comment on table public.categories is 'owner: core. Interest and group categories.';

alter table public.categories enable row level security;
revoke all on public.categories from anon, authenticated;
grant select on public.categories to anon, authenticated;

create policy categories_select_all
  on public.categories for select to anon, authenticated
  using (true);

insert into public.categories (slug, name, sort_order) values
  ('music',        'Müzik',       10),
  ('hiking',       'Yürüyüş',     20),
  ('running',      'Koşu',        30),
  ('cycling',      'Bisiklet',    40),
  ('nature',       'Doğa',        50),
  ('sports',       'Spor',        60),
  ('art',          'Sanat',       70),
  ('photography',  'Fotoğraf',    80),
  ('dance',        'Dans',        90),
  ('books',        'Kitap',      100),
  ('games',        'Oyun',       110),
  ('travel',       'Seyahat',    120),
  ('food',         'Yemek',      130),
  ('technology',   'Teknoloji',  140),
  ('volunteering', 'Gönüllülük', 150);

-- ---------------------------------------------------------------------------
-- legal_documents
-- owner: identity
-- Versioned legal texts. The latest published version of each kind must be accepted.
-- ---------------------------------------------------------------------------
create table public.legal_documents (
  kind         text not null check (kind in ('terms', 'privacy_notice', 'explicit_consent')),
  version      int  not null check (version > 0),
  title        text not null,
  body         text not null,
  published_at timestamptz not null default now(),
  primary key (kind, version)
);

comment on table public.legal_documents is 'owner: identity. Versioned KVKK and terms texts.';

alter table public.legal_documents enable row level security;
revoke all on public.legal_documents from anon, authenticated;
grant select on public.legal_documents to anon, authenticated;

create policy legal_documents_select_published
  on public.legal_documents for select to anon, authenticated
  using (published_at <= now());

-- DRAFT texts: must be reviewed by a lawyer before launch.
insert into public.legal_documents (kind, version, title, body) values
(
  'terms', 1, 'Kullanım Koşulları',
  E'TASLAK — Hukuki inceleme gereklidir.\n\n'
  'GrupX''i kullanarak bu koşulları kabul etmiş olursun.\n\n'
  '1. Hesabın sana aittir; bilgilerinin doğru olmasından ve hesabının güvenliğinden sen sorumlusun.\n'
  '2. Başkalarının haklarını ihlal eden, yasa dışı, taciz edici veya yanıltıcı içerik paylaşamazsın.\n'
  '3. Grupların kendi kuralları vardır; grup yöneticileri ve disiplin kurulları bu kuralları uygular.\n'
  '4. GrupX, kurallara aykırı içerikleri kaldırabilir ve hesapları askıya alabilir.\n'
  '5. Hesabını dilediğin zaman silebilirsin; silme isteğinden 30 gün sonra verilerin kalıcı olarak silinir.'
),
(
  'privacy_notice', 1, 'KVKK Aydınlatma Metni',
  E'TASLAK — Hukuki inceleme gereklidir.\n\n'
  '6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, veri sorumlusu sıfatıyla GrupX olarak kişisel verilerini aşağıdaki şekilde işliyoruz.\n\n'
  'İşlenen veriler: e-posta adresi, kullanıcı adı, ad, profil ve kapak görseli, biyografi, ilgi alanları, paylaşımların ve platform içi etkileşimlerin, güvenlik amaçlı IP ve oturum kayıtları.\n\n'
  'Amaçlar: hesabının oluşturulması ve yönetimi, platform hizmetlerinin sunulması, güvenliğin sağlanması, yasal yükümlülüklerin yerine getirilmesi.\n\n'
  'Hukuki sebepler: sözleşmenin kurulması ve ifası, hukuki yükümlülük, meşru menfaat ve gerektiğinde açık rızan.\n\n'
  'Aktarım: Veriler, hizmet aldığımız altyapı sağlayıcılarının yurt dışındaki sunucularında işlenebilir. Bu aktarım için açık rızan istenir.\n\n'
  'Hakların: KVKK madde 11 kapsamında verilerine erişme, düzeltilmesini veya silinmesini isteme ve itiraz etme hakkın vardır. Hesabını uygulama içinden silebilirsin.'
),
(
  'explicit_consent', 1, 'Açık Rıza Metni',
  E'TASLAK — Hukuki inceleme gereklidir.\n\n'
  'KVKK Aydınlatma Metni''ni okudum. Kişisel verilerimin, GrupX''in hizmet aldığı altyapı sağlayıcılarının yurt dışında bulunan sunucularında işlenmesine ve saklanmasına açık rızam ile onay veriyorum.'
);

-- ---------------------------------------------------------------------------
-- consents
-- owner: identity
-- Append-only. Users add their own rows; accepted_at is always server time.
-- ---------------------------------------------------------------------------
create table public.consents (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  kind        text not null,
  version     int  not null,
  accepted_at timestamptz not null default now(),
  foreign key (kind, version) references public.legal_documents (kind, version),
  unique (user_id, kind, version)
);

comment on table public.consents is 'owner: identity. Accepted legal document versions per user.';

alter table public.consents enable row level security;
revoke all on public.consents from anon, authenticated;
grant select on public.consents to authenticated;
grant insert (user_id, kind, version) on public.consents to authenticated;

create policy consents_select_own
  on public.consents for select to authenticated
  using (user_id = (select auth.uid()));

create policy consents_insert_own
  on public.consents for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.legal_documents d
      where d.kind = consents.kind and d.version = consents.version and d.published_at <= now()
    )
  );

-- Latest published documents the current user has not accepted yet.
create function public.pending_legal_documents()
returns setof public.legal_documents
language sql
stable
security invoker
set search_path = ''
as $$
  select d.*
  from public.legal_documents d
  where d.published_at <= now()
    and d.version = (
      select max(l.version) from public.legal_documents l
      where l.kind = d.kind and l.published_at <= now()
    )
    and not exists (
      select 1 from public.consents c
      where c.user_id = (select auth.uid()) and c.kind = d.kind and c.version = d.version
    )
  order by d.kind;
$$;

revoke all on function public.pending_legal_documents() from public, anon;
grant execute on function public.pending_legal_documents() to authenticated;

-- ---------------------------------------------------------------------------
-- account_status
-- owner: identity
-- One row per auth user, written only by the backend.
-- ---------------------------------------------------------------------------
create table public.account_status (
  user_id                uuid primary key references auth.users (id) on delete cascade,
  status                 text not null default 'active'
                         check (status in ('active', 'suspended', 'pending_deletion')),
  suspended_until        timestamptz,
  suspension_reason      text,
  deletion_requested_at  timestamptz,
  deletion_scheduled_for timestamptz,
  updated_at             timestamptz not null default now(),
  constraint account_status_deletion_consistent
    check ((status = 'pending_deletion') = (deletion_scheduled_for is not null)),
  constraint account_status_suspension_consistent
    check (status = 'suspended' or (suspended_until is null and suspension_reason is null))
);

comment on table public.account_status is 'owner: identity. Account lifecycle state. Backend writes only.';

create index account_status_deletion_due_idx
  on public.account_status (deletion_scheduled_for)
  where status = 'pending_deletion';

alter table public.account_status enable row level security;
revoke all on public.account_status from anon, authenticated;
grant select on public.account_status to authenticated;

create policy account_status_select_own_or_staff
  on public.account_status for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_platform_staff()));

create function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.account_status (user_id) values (new.id) on conflict do nothing;
  return new;
end;
$$;

revoke all on function private.handle_new_auth_user() from public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_auth_user();

insert into public.account_status (user_id)
select id from auth.users
on conflict do nothing;

-- Active, or suspended with an expired suspension.
create function private.is_account_active(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce((
    select s.status = 'active'
        or (s.status = 'suspended' and s.suspended_until is not null and s.suspended_until <= now())
    from public.account_status s
    where s.user_id = uid
  ), false);
$$;

revoke all on function private.is_account_active(uuid) from public;
grant execute on function private.is_account_active(uuid) to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Username helpers
-- ---------------------------------------------------------------------------
create function private.reserved_usernames()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array[
    'admin', 'administrator', 'root', 'system', 'grupx', 'grup', 'destek', 'support',
    'yardim', 'help', 'yonetim', 'yonetici', 'moderator', 'mod', 'staff', 'ekip',
    'official', 'resmi', 'api', 'www', 'mail', 'null', 'undefined', 'me', 'settings',
    'ayarlar', 'profil', 'profile', 'login', 'giris', 'kayit', 'signup', 'explore', 'kesfet'
  ];
$$;

revoke all on function private.reserved_usernames() from public;
grant execute on function private.reserved_usernames() to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- profiles
-- owner: profile
-- ---------------------------------------------------------------------------
create table public.profiles (
  id                  uuid primary key references auth.users (id) on delete cascade,
  username            text not null unique
                      constraint profiles_username_format
                      check (username ~ '^[a-z0-9_.]{3,30}$' and username !~ '^\.|\.$|\.\.'),
  username_changed_at timestamptz,
  display_name        text not null
                      constraint profiles_display_name_length
                      check (char_length(btrim(display_name)) between 1 and 50),
  bio                 text not null default ''
                      constraint profiles_bio_length check (char_length(bio) <= 160),
  avatar_path         text check (avatar_path is null or avatar_path like id::text || '/%'),
  cover_path          text check (cover_path is null or cover_path like id::text || '/%'),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

comment on table public.profiles is 'owner: profile. Public user profile, created at the end of onboarding.';
comment on column public.profiles.username_changed_at is
  'Set by trigger on username change. Null until the first change after onboarding.';

alter table public.profiles enable row level security;
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to anon, authenticated;
grant insert (id, username, display_name, bio, avatar_path, cover_path) on public.profiles to authenticated;
grant update (username, display_name, bio, avatar_path, cover_path) on public.profiles to authenticated;

create policy profiles_select_visible
  on public.profiles for select to anon, authenticated
  using (
    id = (select auth.uid())
    or private.is_account_active(id)
    or (select private.is_platform_staff())
  );

create policy profiles_insert_own
  on public.profiles for insert to authenticated
  with check (id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create policy profiles_update_own
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create function private.profiles_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.display_name := btrim(new.display_name);
  new.bio := btrim(new.bio);

  if tg_op = 'INSERT' then
    new.username_changed_at := null;
    new.created_at := now();
  else
    new.created_at := old.created_at;
    if new.username is distinct from old.username then
      if old.username_changed_at is not null
         and old.username_changed_at > now() - interval '30 days' then
        raise exception 'username_change_too_soon' using errcode = 'P0001';
      end if;
      new.username_changed_at := now();
    else
      new.username_changed_at := old.username_changed_at;
    end if;
  end if;

  if (tg_op = 'INSERT' or new.username is distinct from old.username)
     and new.username = any (private.reserved_usernames()) then
    raise exception 'username_reserved' using errcode = 'P0001';
  end if;

  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_before_write
  before insert or update on public.profiles
  for each row execute function private.profiles_before_write();

create function private.is_username_taken(name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select name = any (private.reserved_usernames())
      or exists (select 1 from public.profiles p where p.username = name);
$$;

-- RPC: true when the name is well-formed, not reserved and not used by anyone
-- (hidden accounts included).
create function public.is_username_available(name text)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select name ~ '^[a-z0-9_.]{3,30}$'
     and name !~ '^\.|\.$|\.\.'
     and not private.is_username_taken(name);
$$;

revoke all on function private.is_username_taken(text) from public;
grant execute on function private.is_username_taken(text) to authenticated;
revoke all on function public.is_username_available(text) from public, anon;
grant execute on function public.is_username_available(text) to authenticated;

-- ---------------------------------------------------------------------------
-- profile_interests
-- owner: profile
-- ---------------------------------------------------------------------------
create table public.profile_interests (
  user_id       uuid not null references public.profiles (id) on delete cascade,
  category_slug text not null references public.categories (slug) on delete cascade,
  created_at    timestamptz not null default now(),
  primary key (user_id, category_slug)
);

comment on table public.profile_interests is 'owner: profile. Up to 10 interests per profile.';

alter table public.profile_interests enable row level security;
revoke all on public.profile_interests from anon, authenticated;
grant select on public.profile_interests to anon, authenticated;
grant insert (user_id, category_slug), delete on public.profile_interests to authenticated;

create policy profile_interests_select_visible
  on public.profile_interests for select to anon, authenticated
  using (
    user_id = (select auth.uid())
    or private.is_account_active(user_id)
    or (select private.is_platform_staff())
  );

create policy profile_interests_insert_own
  on public.profile_interests for insert to authenticated
  with check (user_id = (select auth.uid()) and (select private.is_account_active(auth.uid())));

create policy profile_interests_delete_own
  on public.profile_interests for delete to authenticated
  using (user_id = (select auth.uid()));

create function private.profile_interests_limit()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select count(*) from public.profile_interests i where i.user_id = new.user_id) >= 10 then
    raise exception 'interest_limit_reached' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger profile_interests_limit
  before insert on public.profile_interests
  for each row execute function private.profile_interests_limit();

-- ---------------------------------------------------------------------------
-- Storage: avatars and covers
-- owner: profile
-- Public read; users write only inside their own <uid>/ folder.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('covers',  'covers',  true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy profile_images_select_own
  on storage.objects for select to authenticated
  using (
    bucket_id in ('avatars', 'covers')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy profile_images_insert_own
  on storage.objects for insert to authenticated
  with check (
    bucket_id in ('avatars', 'covers')
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select private.is_account_active(auth.uid()))
  );

create policy profile_images_update_own
  on storage.objects for update to authenticated
  using (
    bucket_id in ('avatars', 'covers')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id in ('avatars', 'covers')
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and (select private.is_account_active(auth.uid()))
  );

create policy profile_images_delete_own
  on storage.objects for delete to authenticated
  using (
    bucket_id in ('avatars', 'covers')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
