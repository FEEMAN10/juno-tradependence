-- ============================================================================
-- Juno Tradependence — guest-facing photo access (steps 5 & 6)
-- Run ONCE in Supabase SQL Editor. Requires faces.sql + people.sql first.
-- These are the ONLY photo functions exposed to the browser key (anon).
-- Each is gated by the guest's personal token, so a guest only ever sees
-- their own photos (+ the shared highlights). No table is directly readable.
-- ============================================================================

-- "Photos of You": every photo the guest (identified by their link token) appears in
create or replace function public.get_guest_photos(p_token text)
returns table(path text, phase text, taken_at timestamptz)
language sql security definer set search_path=public as $$
  select distinct p.path, p.phase, p.taken_at
  from public.invitations i
  join public.people pe on pe.guest_id = i.id
  join public.faces  f  on f.person_id = pe.id
  join public.photos p  on p.id = f.photo_id
  where i.token = p_token
  order by p.taken_at nulls last;
$$;

-- Shared "Event Highlights" (photos with no faces: venue, food, fireworks…).
-- Requires a valid token so it isn't world-readable.
create or replace function public.get_highlight_photos(p_token text)
returns table(path text, phase text, taken_at timestamptz)
language sql security definer set search_path=public as $$
  select p.path, p.phase, p.taken_at
  from public.photos p
  where p.is_highlight
    and exists (select 1 from public.invitations i where i.token = p_token)
  order by p.taken_at nulls last;
$$;

grant execute on function public.get_guest_photos(text)     to anon, authenticated;
grant execute on function public.get_highlight_photos(text)  to anon, authenticated;
