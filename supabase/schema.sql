-- ============================================================================
-- Juno Tradependence Invitation — database schema
-- Run this ONCE in: Supabase dashboard -> SQL Editor -> New query -> Run
-- ============================================================================

-- === invitations: one row per invited guest ===============================
create table if not exists public.invitations (
  id            uuid primary key default gen_random_uuid(),
  token         text unique not null,                 -- the ?g= value in each guest's link
  guest_name    text not null,                        -- "Mr. Andi Wijaya"
  guest_title   text,                                 -- optional: seat / table label
  email         text,                                 -- optional: for reminders
  rsvp_status   text check (rsvp_status in ('pending','accepted','declined')) default 'pending',
  rsvp_at       timestamptz,
  main_course   text,
  dessert       text,
  beverage      text check (beverage in ('Alcoholic','Non-Alcoholic')),
  dietary_flag  boolean default false,
  dietary_note  text,
  selection_at  timestamptz,
  language      text check (language in ('en','id')),
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index if not exists invitations_rsvp_idx on public.invitations (rsvp_status);

-- === menu_options: optional reference table (menu is also fixed in the app) =
create table if not exists public.menu_options (
  id          uuid primary key default gen_random_uuid(),
  category    text not null check (category in ('main','dessert','beverage')),
  label       text not null,
  subtitle    text,
  subtitle_id text,
  emoji       text,
  image_url   text,
  sort        int default 0,
  active      boolean default true
);

-- === Row Level Security =====================================================
alter table public.invitations enable row level security;
alter table public.menu_options enable row level security;

-- menu is public-readable (active rows only)
drop policy if exists "menu public read" on public.menu_options;
create policy "menu public read" on public.menu_options for select using (active = true);

-- invitations: NO direct anon access (the functions below are the only door)

-- === Secure functions (the only things the website can call) ================
create or replace function public.get_invitation(p_token text)
returns table (
  guest_name text, guest_title text, rsvp_status text,
  main_course text, dessert text, beverage text,
  dietary_flag boolean, dietary_note text
)
language sql security definer set search_path = public as $$
  select guest_name, guest_title, rsvp_status, main_course, dessert,
         beverage, dietary_flag, dietary_note
  from public.invitations where token = p_token
$$;

create or replace function public.set_rsvp(p_token text, p_status text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_status not in ('accepted','declined') then raise exception 'bad status'; end if;
  update public.invitations
     set rsvp_status = p_status, rsvp_at = now(), updated_at = now()
   where token = p_token;
end $$;

create or replace function public.submit_selection(
  p_token text, p_main text, p_dessert text, p_beverage text,
  p_dietary_flag boolean, p_dietary_note text
) returns void language plpgsql security definer set search_path = public as $$
begin
  update public.invitations
     set main_course = p_main, dessert = p_dessert, beverage = p_beverage,
         dietary_flag = p_dietary_flag,
         dietary_note = case when p_dietary_flag then p_dietary_note else null end,
         selection_at = now(), updated_at = now()
   where token = p_token
     and rsvp_status = 'accepted'    -- must accept first
     and selection_at is null;       -- ONE-TIME: final once saved, never overwritten
  if not found then
    raise exception 'not accepted, or selection already submitted (final)';
  end if;
end $$;

-- expose only these three to the browser (anon role)
grant execute on function public.get_invitation(text)   to anon;
grant execute on function public.set_rsvp(text,text)     to anon;
grant execute on function public.submit_selection(text,text,text,text,boolean,text) to anon;
