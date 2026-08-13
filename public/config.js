/* =====================================================================
   Juno Tradependence Invitation — configuration
   ---------------------------------------------------------------------
   Paste the two values from your Supabase project here:
     Supabase dashboard -> Project Settings -> API
       - Project URL      -> SUPABASE_URL
       - anon public key   -> SUPABASE_ANON_KEY   (safe to expose; the
                              database is protected by RLS + functions)

   Leave them BLANK to run the site in demo mode (no data is saved) —
   useful for previewing before your Supabase project exists.
   NEVER put the "service_role" key here. That one is admin-level.
===================================================================== */
window.JUNO_CONFIG = {
  SUPABASE_URL: "",
  SUPABASE_ANON_KEY: ""
};
