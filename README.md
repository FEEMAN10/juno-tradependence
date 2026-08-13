# Juno Tradependence Invitation — ready-to-deploy app

This is the **complete, working app** (not a prototype). Front-end is done and wired to Supabase.
Your only jobs are: create two free accounts, paste two keys, run some SQL, and drop a folder on Netlify.

```
juno-app/
├─ public/              <- this whole folder is the website
│  ├─ index.html
│  ├─ app.js            <- logic + Supabase calls (already wired)
│  ├─ config.js         <- ⬅ YOU paste your 2 Supabase keys here
│  └─ assets/           <- video, logo, dish photos, dress photos
├─ supabase/
│  ├─ schema.sql              <- run once (tables + security + functions)
│  ├─ seed_menu.sql           <- optional reference
│  └─ seed_guests_TEMPLATE.sql<- your guest list + link generator
└─ netlify.toml
```

## Preview it right now (no accounts needed)
Open `public/index.html` in a browser, or from a terminal:
```
cd public && python3 -m http.server 8080     # then open http://localhost:8080
```
With `config.js` blank it runs in **demo mode** — everything works but nothing is saved. Good for a look.

## Go live — 5 short steps

**1. Supabase (database).** Create a free project at supabase.com (region: Singapore).
   In **SQL Editor**, run `supabase/schema.sql`. (Optionally run `seed_menu.sql`.)
   Edit `supabase/seed_guests_TEMPLATE.sql` with your real guests and run it.

**2. Keys.** Supabase -> **Project Settings -> API**. Copy **Project URL** and **anon public** key
   into `public/config.js`. Save. (Never use the service_role key here.)

**3. Deploy.** Go to netlify.com -> **Add new site -> Deploy manually** -> drag in the **`public`** folder.
   You get a live address like `juno-tradependence.netlify.app`.
   (Prefer auto-updates? Push this folder to GitHub and "Import from Git" instead.)

**4. Send links.** In Supabase SQL Editor run the SELECT at the bottom of the guests file
   (put your real Netlify address in it), **Download CSV**, and send each guest **their own** `?g=…` link.

**5. Manage.** In Supabase **Table Editor -> invitations** you can watch responses live.
   For the caterer, run:
   ```sql
   select guest_name, guest_title as seat, main_course, dessert, beverage,
          case when dietary_flag then dietary_note else '' end as dietary
   from public.invitations where rsvp_status='accepted' order by main_course, guest_name;
   ```
   Guests can't change a submitted choice (it's final); if someone needs a change, edit their row here.

Full walkthrough with screenshots-worth of detail: `juno-invitation-golive-guide.md`.

## Notes
- The menu (with dish photos) and all copy are baked into `index.html`, in **English + Bahasa Indonesia**.
- Security: the browser only holds the anon key; the guest list can't be scraped because the tables are
  sealed behind three functions (`get_invitation`, `set_rsvp`, `submit_selection`).
- To change the event time/venue text later, edit `public/app.js` (the `I18N` block and `EV` calendar
  object) and redeploy.
