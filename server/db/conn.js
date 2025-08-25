const { createClient } = require("@supabase/supabase-js");

require('dotenv').config();

// Validate environment variables
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    throw new Error(
        "Missing Supabase environment variables. Please check SUPABASE_URL and SUPABASE_ANON_KEY."
    );
}

// Create connection options
const options = {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false,
    },
};

// Create a single Supabase client instance (singleton)
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, options);

// Export the singleton instance
module.exports = supabase;
