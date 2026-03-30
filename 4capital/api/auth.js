// api/auth.js  — Vercel serverless function
// POST /api/auth  { email, password }
// Returns { ok, user } or { ok: false, error }

// Passwords stored here (move to Supabase users table + bcrypt in production)
const CREDENTIALS = {
  'nathan@4capital.com': { password: 'nathan2025', name: 'Nathan',  initials: 'NB', role: 'President'         },
  'kevin@4capital.com':  { password: 'kevin2025',  name: 'Kévin',   initials: 'YK', role: 'Vice President'    },
  'jeff@4capital.com':   { password: 'jeff2025',   name: 'Jeff',    initials: 'JD', role: 'Data Analyst'      },
  'robin@4capital.com':  { password: 'robin2025',  name: 'Robin',   initials: 'RB', role: 'Financial Manager' },
};

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { email, password } = req.body || {};
  const cred = CREDENTIALS[email?.toLowerCase()];
  if (!cred || cred.password !== password) {
    return res.status(401).json({ ok: false, error: 'Invalid credentials' });
  }
  return res.status(200).json({
    ok: true,
    user: { email, name: cred.name, initials: cred.initials, role: cred.role },
  });
}
