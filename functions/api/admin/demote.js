/**
 * Cloudflare Pages Function: POST /api/admin/demote
 *
 * Demotes a target user from admin role back to student role.
 * Requires the requester to already be an admin (verified via their JWT).
 *
 * Environment variables (set in Cloudflare Pages dashboard):
 *   VITE_SUPABASE_URL         - Supabase project URL
 *   VITE_SUPABASE_ANON_KEY    - Supabase anon/publishable key
 *   SUPABASE_SERVICE_ROLE_KEY - Supabase service role key (secret, bypasses RLS)
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

async function supabaseRequest(baseUrl, path, method, body, authToken) {
  const url = `${baseUrl}/rest/v1/${path}`;
  const headers = {
    'Content-Type': 'application/json',
    apikey: authToken,
    Authorization: `Bearer ${authToken}`,
    Prefer: 'return=minimal',
  };
  const res = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data = null;
  try { data = JSON.parse(text); } catch (_) { data = text; }
  return { ok: res.ok, status: res.status, data };
}

async function supabaseAuthGetUser(baseUrl, anonKey, jwt) {
  const res = await fetch(`${baseUrl}/auth/v1/user`, {
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${jwt}`,
    },
  });
  const data = await res.json();
  return { ok: res.ok, data };
}

export async function onRequest({ request, env }) {
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: CORS_HEADERS });
  }

  if (request.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Missing authorization header' }, 401);

  const token = authHeader.replace('Bearer ', '');

  let body;
  try {
    body = await request.json();
  } catch (_) {
    return json({ error: 'Invalid JSON body' }, 400);
  }

  const targetUserId = body?.userId;
  if (!targetUserId) return json({ error: 'Missing target userId' }, 400);

  const supabaseUrl = env.VITE_SUPABASE_URL || 'https://nyhgciaqvwptmsvrdshc.supabase.co';
  const anonKey = env.VITE_SUPABASE_ANON_KEY;
  const serviceRoleKey = env.SUPABASE_SERVICE_ROLE_KEY;

  if (!serviceRoleKey) return json({ error: 'Server configuration error' }, 500);

  // 1. Verify requesting user's JWT
  const { ok: authOk, data: userData } = await supabaseAuthGetUser(supabaseUrl, anonKey, token);
  if (!authOk || !userData?.id) return json({ error: 'Invalid or expired token' }, 401);

  // 2. Check requester is admin (using service role to bypass RLS)
  const checkRes = await supabaseRequest(
    supabaseUrl,
    `users?id=eq.${userData.id}&select=role`,
    'GET', null, serviceRoleKey
  );
  const requesterRole = Array.isArray(checkRes.data) ? checkRes.data[0]?.role : null;
  if (!requesterRole || requesterRole !== 'admin') {
    return json({ error: 'Forbidden. Requester is not an admin.' }, 403);
  }

  // 3. Demote target user
  const updateRes = await supabaseRequest(
    supabaseUrl,
    `users?id=eq.${targetUserId}`,
    'PATCH',
    { role: 'student' },
    serviceRoleKey
  );

  if (!updateRes.ok) return json({ error: 'Failed to demote user' }, 500);
  return json({ message: 'User demoted successfully' }, 200);
}
