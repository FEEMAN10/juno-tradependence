-- ============================================================================
-- Juno Tradependence — naming faces to guests (step 4)
-- Run ONCE in Supabase SQL Editor. Requires admin.sql + faces.sql first.
-- ============================================================================

-- list every face (with its photo, box, current person, and embedding as text)
create or replace function public.admin_list_faces()
returns table(id uuid, path text, phase text, bbox jsonb, person_id uuid, person_name text, guest_id uuid, embedding text)
language plpgsql security definer set search_path=public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  return query
    select f.id, p.path, p.phase, f.bbox, f.person_id, pe.name, pe.guest_id, f.embedding::text
    from public.faces f
    join public.photos p on p.id = f.photo_id
    left join public.people pe on pe.id = f.person_id
    order by p.taken_at nulls last, f.created_at;
end $$;

-- name a cluster: link a set of faces to a guest (one person row per guest, reused)
create or replace function public.admin_name_cluster(p_face_ids uuid[], p_guest_id uuid)
returns uuid language plpgsql security definer set search_path=public as $$
declare v uuid; gname text;
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  select guest_name into gname from public.invitations where id = p_guest_id;
  if gname is null then raise exception 'unknown guest'; end if;
  select id into v from public.people where guest_id = p_guest_id limit 1;
  if v is null then insert into public.people(name,guest_id) values (gname,p_guest_id) returning id into v;
  else update public.people set name = gname where id = v; end if;
  update public.faces set person_id = v where id = any(p_face_ids);
  return v;
end $$;

-- unassign faces (for split / "not this person")
create or replace function public.admin_unassign_faces(p_face_ids uuid[])
returns void language plpgsql security definer set search_path=public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  update public.faces set person_id = null where id = any(p_face_ids);
end $$;

grant execute on function public.admin_list_faces()                 to authenticated;
grant execute on function public.admin_name_cluster(uuid[],uuid)    to authenticated;
grant execute on function public.admin_unassign_faces(uuid[])       to authenticated;
