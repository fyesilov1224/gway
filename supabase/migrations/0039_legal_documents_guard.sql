-- 0039_legal_documents_guard
-- Legal texts become immutable once anyone has consented to a version (docs/ARCHITECTURE.md §3a KVKK, §8b).
-- The foreign key already blocks deleting a consented version; this guard also blocks changing its title/body,
-- so the exact text a user agreed to stays on record. Unreferenced versions (drafts, fresh publishes) stay editable.
-- owner: identity. Writes go through the C# admin API (service role); authenticated still has only select.

create function private.legal_documents_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  ref record;
begin
  ref := case when tg_op = 'DELETE' then old else new end;
  -- The kind set and audience pairing are already check constraints; this guard is only about consents.
  if exists (select 1 from public.consents c where c.kind = ref.kind and c.version = ref.version) then
    -- An unchanged row on UPDATE (e.g. re-publishing the same values) is allowed; a real change is not.
    if tg_op = 'DELETE'
       or (new.kind, new.version, new.title, new.body, new.published_at, new.audience)
          is distinct from (old.kind, old.version, old.title, old.body, old.published_at, old.audience) then
      raise exception 'legal_consented_immutable' using errcode = 'P0001';
    end if;
  end if;
  return ref;
end;
$$;

create trigger legal_documents_guard
  before update or delete on public.legal_documents
  for each row execute function private.legal_documents_guard();
