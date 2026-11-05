-- 0080: translations of the legal texts (docs/ARCHITECTURE.md §11, Hukuki metin çevirileri).
--
-- A translation is for information: the Turkish version stays the binding text and consents point to it
-- (kind, version). Everyone reads the translations of published versions; only the API (platform admins)
-- writes them, and every write goes to audit_log. Unlike the Turkish text a translation may be corrected
-- after people consented.

create table public.legal_document_translations (
  kind       text not null,
  version    int  not null,
  language   text not null check (language in ('en', 'de', 'fr', 'nl', 'es', 'pt', 'it', 'ru', 'ar', 'az', 'uk')),
  title      text not null check (length(title) between 3 and 200),
  body       text not null check (length(body) between 20 and 100000),
  updated_at timestamptz not null default now(),
  primary key (kind, version, language),
  foreign key (kind, version) references public.legal_documents (kind, version) on delete cascade
);

comment on table public.legal_document_translations is
  'owner: identity. Informational translations of legal_documents; the Turkish version is binding.';

alter table public.legal_document_translations enable row level security;
revoke all on public.legal_document_translations from anon, authenticated;
grant select on public.legal_document_translations to anon, authenticated;

create policy legal_document_translations_select_published
  on public.legal_document_translations for select to anon, authenticated
  using (exists (
    select 1 from public.legal_documents d
    where d.kind = legal_document_translations.kind and d.version = legal_document_translations.version
      and d.published_at <= now()
  ));
