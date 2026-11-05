-- 0079: the person's language (docs/ARCHITECTURE.md §11, Sunucu).
--
-- The app writes it when the person picks a language or signs in; push texts and server
-- messages follow it. A simple write of one's own data, like the other profile columns.

alter table public.profiles add column locale text not null default 'tr'
  check (locale in ('tr', 'en', 'de', 'fr', 'nl', 'es', 'pt', 'it', 'ru', 'ar', 'az', 'uk'));

comment on column public.profiles.locale is
  'App language (one of the 12); push texts and server messages use it.';

grant insert (locale), update (locale) on public.profiles to authenticated;
