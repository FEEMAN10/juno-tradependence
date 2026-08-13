-- ============================================================================
-- Juno Tradependence Invitation — ADMIN back-end
-- Run this ONCE in: Supabase dashboard -> SQL Editor -> New query -> Run
--
-- Security model: these functions are the ONLY way the admin dashboard touches
-- the guest table. Each one refuses to run unless the caller is signed in as the
-- admin email below. The public anon key CANNOT call them (the gate rejects it),
-- so nobody can scrape or edit your guest list with the browser key.
--
-- To change who counts as admin, edit the email in public.is_admin() and re-run.
-- ============================================================================

-- Who is allowed to run admin functions (checks the signed-in user's email).
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public as $$
  select lower(coalesce(auth.jwt() ->> 'email','')) = 'fh.r@junomarkets.com'
$$;

-- List every invitation (for the responses view). Admin only.
create or replace function public.admin_list_invitations()
returns setof public.invitations
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  return query select * from public.invitations order by created_at asc;
end $$;

-- Add a guest; auto-generates a unique token and returns the created row
-- (the dashboard turns token -> personal link). Admin only.
create or replace function public.admin_add_guest(
  p_name text, p_title text default null, p_email text default null
)
returns public.invitations
language plpgsql security definer set search_path = public as $$
declare r public.invitations;
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  if coalesce(btrim(p_name),'') = '' then raise exception 'guest name required'; end if;
  insert into public.invitations (token, guest_name, guest_title, email)
  values (replace(gen_random_uuid()::text,'-',''),
          btrim(p_name),
          nullif(btrim(coalesce(p_title,'')),''),
          nullif(btrim(coalesce(p_email,'')),''))
  returning * into r;
  return r;
end $$;

-- Remove a guest by id. Admin only.
create or replace function public.admin_delete_guest(p_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  delete from public.invitations where id = p_id;
end $$;

-- Escape hatch: clear a guest's submitted meal choice so they (or you) can
-- redo it. Admin only. (Guests normally can't change a submitted choice.)
create or replace function public.admin_reset_selection(p_id uuid)
returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then raise exception 'not authorized'; end if;
  update public.invitations
     set main_course=null, dessert=null, beverage=null,
         dietary_flag=false, dietary_note=null, selection_at=null, updated_at=now()
   where id = p_id;
end $$;

-- Grants: only signed-in (authenticated) sessions may call the admin functions.
-- is_admin is granted to anon too so RLS/other checks can reference it safely.
grant execute on function public.is_admin()                       to anon, authenticated;
grant execute on function public.admin_list_invitations()         to authenticated;
grant execute on function public.admin_add_guest(text,text,text)  to authenticated;
grant execute on function public.admin_delete_guest(uuid)         to authenticated;
grant execute on function public.admin_reset_selection(uuid)      to authenticated;
