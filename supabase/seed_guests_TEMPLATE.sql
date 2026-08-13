-- ============================================================================
-- Load your guest list. Each guest gets a random unguessable token automatically.
-- 1) Duplicate a line per guest, fill in name / email / seat.
-- 2) Run it in: SQL Editor -> New query -> Run
-- 3) Then run the SELECT at the bottom to get each guest's personal link.
--
-- Tip for a long list: put your guests in a spreadsheet, export CSV, and use
-- Supabase -> Table Editor -> invitations -> Import CSV instead (then run the
-- one-line UPDATE below to fill tokens).
-- ============================================================================

insert into public.invitations (token, guest_name, email, guest_title) values
  (encode(gen_random_bytes(12),'hex'), 'Mr. Andi Wijaya',   'andi@email.com',  'Table 1'),
  (encode(gen_random_bytes(12),'hex'), 'Ms. Sarah Tan',     'sarah@email.com', 'Table 2'),
  (encode(gen_random_bytes(12),'hex'), 'Mr. & Mrs. Pratama','prat@email.com',  'Table 3');

-- If you imported names via CSV WITHOUT tokens, give everyone a token in one go:
-- update public.invitations set token = encode(gen_random_bytes(12),'hex') where token is null;

-- ============================================================================
-- GET THE LINKS TO SEND  (replace YOUR-SITE with your Netlify address)
-- ============================================================================
select guest_name,
       'https://YOUR-SITE.netlify.app/?g=' || token as link
from public.invitations
order by guest_name;
