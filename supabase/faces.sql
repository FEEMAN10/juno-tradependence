-- ============================================================================
-- Juno Tradependence — PHOTO LIBRARY + FACES schema (pgvector)
-- Run ONCE in: Supabase dashboard -> SQL Editor -> New query -> Run
-- Requires admin.sql to have been run first (uses public.is_admin()).
-- ============================================================================

create extension if not exists vector;   -- pgvector

-- one row per event photo (medium-res lives in Storage/Drive; here = metadata)
create table if not exists public.photos (
  id          uuid primary key default gen_random_uuid(),
  path        text unique not null,       -- where the displayable image lives
  taken_at    timestamptz,                -- from EXIF (for ordering / phases)
  phase       text,                        -- ARRIVE / CONNECT / DINE / CELEBRATE / FAREWELL
  width       int,
  height      int,
  face_count  int default 0,
  is_highlight boolean default false,      -- true when it has no faces (scenery) -> Event Highlights
  created_at  timestamptz default now()
);

-- a named "person" cluster; optionally linked to a real guest (your 61 invitations)
create table if not exists public.people (
  id            uuid primary key default gen_random_uuid(),
  name          text,
  guest_id      uuid references public.invitations(id) on delete set null,
  cover_face_id uuid,
  created_at    timestamptz default now()
);

-- one row per detected face; the 128-d face-api descriptor lives in `embedding`
create table if not exists public.faces (
  id         uuid primary key default gen_random_uuid(),
  photo_id   uuid references public.photos(id) on delete cascade,
  bbox       jsonb,                          -- {x,y,w,h} in the stored image's pixels
  embedding  vector(128),
  person_id  uuid references public.people(id) on delete set null,
  created_at timestamptz default now()
);
create index if not exists faces_embedding_idx on public.faces using hnsw (embedding vector_cosine_ops);
create index if not exists faces_person_idx on public.faces(person_id);
create index if not exists photos_phase_idx on public.photos(phase);

alter table public.photos enable row level security;
alter table public.people enable row level security;
alter table public.faces  enable row level security;
-- No anon/authenticated table access; everything goes through the functions below.

-- ---- admin ingest / query functions (all gated to the admin) --------------
create or replace function public.admin_add_photo(
  p_path text, p_taken_at timestamptz, p_phase text, p_width int, p_height int, p_face_count int
) returns uuid language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  insert into public.photos(path,taken_at,phase,width,height,face_count,is_highlight)
  values (p_path,p_taken_at,p_phase,p_width,p_height,coalesce(p_face_count,0),coalesce(p_face_count,0)=0)
  on conflict (path) do update set
    taken_at=excluded.taken_at, phase=excluded.phase, width=excluded.width,
    height=excluded.height, face_count=excluded.face_count, is_highlight=excluded.is_highlight
  returning id into v;
  delete from public.faces where photo_id=v;   -- replace faces on re-ingest
  return v;
end $$;

create or replace function public.admin_add_face(
  p_photo_id uuid, p_bbox jsonb, p_embedding text
) returns uuid language plpgsql security definer set search_path=public as $$
declare v uuid;
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  insert into public.faces(photo_id,bbox,embedding) values (p_photo_id,p_bbox,p_embedding::vector)
  returning id into v; return v;
end $$;

-- nearest faces to a given descriptor (cosine) — used later for clustering/naming
create or replace function public.admin_match_faces(p_embedding text, p_limit int default 5)
returns table(face_id uuid, person_id uuid, dist float)
language plpgsql security definer set search_path=public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  return query select f.id, f.person_id, (f.embedding <=> p_embedding::vector)::float
    from public.faces f order by f.embedding <=> p_embedding::vector limit p_limit;
end $$;

create or replace function public.admin_face_stats()
returns table(photos bigint, faces bigint, people bigint, unassigned bigint, highlights bigint)
language plpgsql security definer set search_path=public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  return query select
    (select count(*) from public.photos),
    (select count(*) from public.faces),
    (select count(*) from public.people),
    (select count(*) from public.faces where person_id is null),
    (select count(*) from public.photos where is_highlight);
end $$;

grant execute on function public.admin_add_photo(text,timestamptz,text,int,int,int) to authenticated;
grant execute on function public.admin_add_face(uuid,jsonb,text)                    to authenticated;
grant execute on function public.admin_match_faces(text,int)                        to authenticated;
grant execute on function public.admin_face_stats()                                 to authenticated;
