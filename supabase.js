import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Simple login function
export async function loginUser(username, password) {
    // Query the database for the user
    const { data: user, error } = await supabase
        .from('users')
        .select('*')
        .eq('username', username)
        .eq('password', password)
        .single();

    if (error || !user) {
        return { success: false };
    }

    // Return user info with proper admin flag
    return { 
        role: user.role,
        success: true,
        isAdmin: user.role === 'admin',
        id: user.role === 'admin' ? 'admin' : user.id
    };
}