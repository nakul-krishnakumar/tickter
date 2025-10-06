const { createClient } = require("@supabase/supabase-js");

require('dotenv').config();

// Get the environment variables
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY; // Use the service key

// Validate that the required keys exist
if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    throw new Error(
        "Missing Supabase environment variables. Please check SUPABASE_URL and SUPABASE_SERVICE_KEY."
    );
}

// Create the Supabase client using the service key
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

// Export the singleton instance
module.exports = supabase;