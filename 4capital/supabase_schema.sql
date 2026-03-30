-- ============================================================
-- 4Capital Supabase Schema
-- Run this entire file in your Supabase SQL Editor
-- ============================================================

-- USERS (matches your 4 co-founders)
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  name text not null,
  initials text not null,
  role text not null,
  avatar_color text default '#1a47cc',
  created_at timestamptz default now()
);

-- TRADES (portfolio tracker)
create table if not exists trades (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('BUY','SELL')),
  symbol text not null,
  company_name text not null,
  shares numeric not null check (shares > 0),
  price numeric not null check (price > 0),
  trade_date date not null,
  created_by uuid references users(id),
  created_at timestamptz default now()
);

-- EVENTS (agenda / meetings)
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  type text not null check (type in ('Virtual','In-Person','Phone')),
  event_date date not null,
  event_time text not null,
  duration text default '1 hour',
  location text,
  notes text,
  color text default 'blue',
  created_by uuid references users(id),
  created_at timestamptz default now()
);

-- EVENT ATTENDEES
create table if not exists event_attendees (
  event_id uuid references events(id) on delete cascade,
  user_id uuid references users(id) on delete cascade,
  primary key (event_id, user_id)
);

-- ANNOUNCEMENTS
create table if not exists announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  pip_color text default '#1a47cc',
  created_by uuid references users(id),
  created_at timestamptz default now()
);

-- ── Seed users ──
insert into users (email, name, initials, role, avatar_color) values
  ('nathan@4capital.com',  'Nathan',  'NB', 'President',         '#1a47cc'),
  ('kevin@4capital.com',   'Kévin',   'YK', 'Vice President',    '#7c3aed'),
  ('jeff@4capital.com',    'Jeff',    'JD', 'Data Analyst',      '#059669'),
  ('robin@4capital.com',   'Robin',   'RB', 'Financial Manager', '#d97706')
on conflict (email) do nothing;

-- ── Seed announcements ──
insert into announcements (title, body, pip_color) values
  ('Research Phase Complete',    'After 12 months of sector research, 4Capital is ready to deploy our initial €2,000 capital.',                          '#1a47cc'),
  ('Nathan wins Moot Court Europe', 'Congratulations to our president on winning the prestigious Moot Court Europe competition.',                       '#c9a84c'),
  ('First Trade Executed',       '4Capital opens its first position — see the Portfolio tab for details.',                                             '#059669')
on conflict do nothing;

-- ── Row Level Security ──
-- Everyone authenticated can read everything
alter table users         enable row level security;
alter table trades        enable row level security;
alter table events        enable row level security;
alter table event_attendees enable row level security;
alter table announcements enable row level security;

-- Read policies (all authenticated users can read all data)
create policy "read users"         on users         for select using (true);
create policy "read trades"        on trades        for select using (true);
create policy "read events"        on events        for select using (true);
create policy "read attendees"     on event_attendees for select using (true);
create policy "read announcements" on announcements for select using (true);

-- Write policies (authenticated users can insert/update/delete)
create policy "write trades"       on trades        for all using (true) with check (true);
create policy "write events"       on events        for all using (true) with check (true);
create policy "write attendees"    on event_attendees for all using (true) with check (true);
create policy "write announcements" on announcements for all using (true) with check (true);
