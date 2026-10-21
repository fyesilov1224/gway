-- 0018_upsert_grants
-- The app saves preferences and reviews with an upsert, which updates the key columns too
-- (ON CONFLICT DO UPDATE). RLS still pins the row to the caller, and the review trigger
-- rejects any change of event or user (docs/ARCHITECTURE.md §3c Tercihler, §3d Organizasyon sonrası).

grant update (user_id) on public.notification_preferences to authenticated;
grant update (event_id, user_id) on public.event_reviews to authenticated;
