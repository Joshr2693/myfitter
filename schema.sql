-- Fitter V1 initial database. Run once in Supabase > SQL Editor.
create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'client' check (role in ('client','coach','admin')),
  location text,
  created_at timestamptz not null default now()
);

create table if not exists public.coach_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  bio text not null default '',
  hourly_rate numeric(8,2) check (hourly_rate >= 0),
  specialties text[] not null default '{}',
  years_experience integer check (years_experience >= 0),
  accepting_clients boolean not null default true,
  trusted_status text not null default 'pending' check (trusted_status in ('pending','verified','rejected')),
  updated_at timestamptz not null default now()
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id) on delete cascade,
  coach_id uuid not null references public.profiles(id) on delete cascade,
  starts_at timestamptz not null,
  session_type text not null,
  notes text,
  status text not null default 'pending' check (status in ('pending','confirmed','declined','cancelled','completed')),
  created_at timestamptz not null default now()
);

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id) on delete cascade,
  coach_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(client_id, coach_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid unique references public.bookings(id) on delete set null,
  client_id uuid not null references public.profiles(id) on delete cascade,
  coach_id uuid not null references public.profiles(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  body text not null,
  verification_status text not null default 'pending' check (verification_status in ('pending','trusted','rejected')),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    case when new.raw_user_meta_data->>'role' = 'coach' then 'coach' else 'client' end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.coach_profiles enable row level security;
alter table public.bookings enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.reviews enable row level security;

drop policy if exists "Profiles are readable" on public.profiles;
create policy "Profiles are readable" on public.profiles for select using (true);
drop policy if exists "Users update their profile" on public.profiles;
create policy "Users update their profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Coach profiles are readable" on public.coach_profiles;
create policy "Coach profiles are readable" on public.coach_profiles for select using (true);
drop policy if exists "Coaches manage their profile" on public.coach_profiles;
create policy "Coaches manage their profile" on public.coach_profiles for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Booking members can read" on public.bookings;
create policy "Booking members can read" on public.bookings for select using (auth.uid() in (client_id, coach_id));
drop policy if exists "Clients create bookings" on public.bookings;
create policy "Clients create bookings" on public.bookings for insert with check (auth.uid() = client_id);
drop policy if exists "Booking members update" on public.bookings;
create policy "Booking members update" on public.bookings for update using (auth.uid() in (client_id, coach_id));

drop policy if exists "Conversation members can read" on public.conversations;
create policy "Conversation members can read" on public.conversations for select using (auth.uid() in (client_id, coach_id));
drop policy if exists "Clients create conversations" on public.conversations;
create policy "Clients create conversations" on public.conversations for insert with check (auth.uid() = client_id);

drop policy if exists "Conversation members read messages" on public.messages;
create policy "Conversation members read messages" on public.messages for select using (
  exists (select 1 from public.conversations c where c.id = conversation_id and auth.uid() in (c.client_id, c.coach_id))
);
drop policy if exists "Conversation members send messages" on public.messages;
create policy "Conversation members send messages" on public.messages for insert with check (
  auth.uid() = sender_id and exists (select 1 from public.conversations c where c.id = conversation_id and auth.uid() in (c.client_id, c.coach_id))
);

drop policy if exists "Trusted reviews are public" on public.reviews;
create policy "Trusted reviews are public" on public.reviews for select using (verification_status = 'trusted' or auth.uid() in (client_id, coach_id));
drop policy if exists "Clients create reviews" on public.reviews;
create policy "Clients create reviews" on public.reviews for insert with check (auth.uid() = client_id);
