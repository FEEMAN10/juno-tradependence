/* =====================================================================
   Juno Tradependence Invitation — configuration
   ---------------------------------------------------------------------
   These two values come from your Supabase project:
     Supabase dashboard -> Project Settings -> API
       - Project URL      -> SUPABASE_URL
       - anon public key   -> SUPABASE_ANON_KEY   (safe to expose; the
                              database is protected by RLS + functions)

   Leave them BLANK to run the site in demo mode (no data is saved).
   NEVER put the "service_role" key here. That one is admin-level.
===================================================================== */
window.JUNO_CONFIG = {
  SUPABASE_URL: "https://dbqfrrgcfxpdyjukiqrw.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicWZycmdjZnhwZHlqdWtpcXJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1OTg1NDAsImV4cCI6MjEwMjE3NDU0MH0.NSrknWJalmmoyhoIPyBd7XQjzOHli0Y0uu3J5u9p9Ws"
};
