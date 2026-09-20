import { createClient } from '@supabase/supabase-js';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Expect Bearer token from frontend
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Missing authorization header' });
  }

  const token = authHeader.replace('Bearer ', '');
  const targetUserId = req.body.userId;

  if (!targetUserId) {
    return res.status(400).json({ error: 'Missing target userId' });
  }

  const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://nyhgciaqvwptmsvrdshc.supabase.co';
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!serviceRoleKey) {
    return res.status(500).json({ error: 'Server configuration error' });
  }

  // Create an admin client bypassing RLS
  const adminSupabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  try {
    // 1. Verify who is making the request by using their JWT token
    const userClient = createClient(supabaseUrl, process.env.VITE_SUPABASE_ANON_KEY || 'dummy', {
      global: { headers: { Authorization: `Bearer ${token}` } }
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();

    if (authError || !user) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }

    // 2. Check if the requester is actually an admin
    const { data: requesterProfile, error: profileError } = await adminSupabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

    if (profileError || !requesterProfile || requesterProfile.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden. Requester is not an admin.' });
    }

    // 3. Promote the target user
    const { error: updateError } = await adminSupabase
      .from('users')
      .update({ role: 'admin' })
      .eq('id', targetUserId);

    if (updateError) {
      return res.status(500).json({ error: 'Failed to promote user' });
    }

    return res.status(200).json({ message: 'User promoted successfully' });
  } catch (err) {
    return res.status(500).json({ error: 'Internal server error' });
  }
}
