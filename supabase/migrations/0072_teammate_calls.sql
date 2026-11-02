-- 0072_teammate_calls
-- User decision 2026-11-02 (docs/ARCHITECTURE.md §8c): teammates call each other too. The package rule follows the chat:
-- matched people need Eşleşme Sohbeti, teammates who are not matched need Ekip Arkadaşı. Everything else as in 0071.
-- owner: live

create or replace function private.call_blocker(caller uuid, callee uuid)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  matched boolean;
begin
  if caller is null or callee is null or caller = callee
     or not private.is_account_active(caller) or not private.is_account_active(callee) then
    return 'call_forbidden';
  end if;
  if not private.has_call_permission(caller) then return 'call_no_permission'; end if;
  if private.is_blocked_between(caller, callee) then return 'call_blocked'; end if;
  matched := private.are_matched(caller, callee);
  if not matched and not private.are_teammates(caller, callee) then return 'call_not_matched'; end if;
  if matched then
    if not private.has_matching_feature(caller, 'chat') then return 'call_chat_locked'; end if;
  elsif not private.has_matching_feature(caller, 'teammates') then
    return 'call_teammate_locked';
  end if;
  if not private.has_call_permission(callee) then return 'call_peer_no_permission'; end if;
  if matched then
    if not private.has_matching_feature(callee, 'chat') then return 'call_peer_chat_locked'; end if;
  elsif not private.has_matching_feature(callee, 'teammates') then
    return 'call_peer_teammate_locked';
  end if;
  return null;
end;
$$;

revoke all on function private.call_blocker(uuid, uuid) from public;

comment on table public.calls is
  'owner: live. Voice calls between two matched people or two teammates; written by the backend. No audio is recorded.';
