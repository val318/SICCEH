-- SQL para crear tablas y columnas recomendadas en Supabase (Postgres)
-- Ejecutar en Supabase -> SQL Editor

-- Habilita extensión para gen_random_uuid si hace falta
create extension if not exists "pgcrypto";

-- Tabla profiles vinculada con auth.users (id = auth.users.id)
create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  email text,
  rango text default 'Principiante',
  colillas integer default 0,
  nivel integer default 0,
  is_admin boolean default false,
  created_at timestamptz default now()
);

-- Tabla de depósitos / historiales
create table if not exists deposits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  cant integer not null,
  container text,
  created_at timestamptz default now()
);

-- Índices útiles
create index if not exists idx_deposits_user on deposits(user_id);
create index if not exists idx_profiles_email on profiles(email);

-- Recomendación: habilitar RLS y crear políticas básicas
-- (ejecuta con cuidado; ajustar según necesidades)
-- Habilitar RLS:
-- alter table profiles enable row level security;
-- alter table deposits enable row level security;

-- Política ejemplo: cada usuario sólo puede seleccionar/insert/delete sus deposits
-- create policy "users can manage own deposits" on deposits
--   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Política para profiles: cada usuario puede ver/editar su profile
-- create policy "profiles: owner" on profiles
--   for select using (auth.uid() = id);
-- create policy "profiles: update own" on profiles
--   for update using (auth.uid() = id) with check (auth.uid() = id);

-- Para operaciones administrativas, crea una policy que permita a is_admin = true realizar select/update/delete globales,
-- o usa funciones server-side protegidas con service_role key.
