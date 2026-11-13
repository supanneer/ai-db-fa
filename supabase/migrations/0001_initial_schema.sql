-- CZ AI Dashboard initial schema. Apply in Supabase SQL Editor.
create extension if not exists pgcrypto;
create type public.app_role as enum ('owner','admin','manager','staff');
create type public.task_status as enum ('todo','in_progress','review','done','blocked');
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role public.app_role not null default 'staff',
  department text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.clients (
  id uuid primary key default gen_random_uuid(), name text not null,
  website_url text, contact_name text, contact_email text, contact_phone text,
  notes text, created_by uuid references public.profiles(id), created_at timestamptz not null default now()
);
create table public.projects (
  id uuid primary key default gen_random_uuid(), client_id uuid references public.clients(id) on delete set null,
  name text not null, website_url text, department text not null default 'SEO',
  status text not null default 'active', description text,
  created_by uuid references public.profiles(id), created_at timestamptz not null default now()
);
create table public.tasks (
  id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete set null,
  title text not null, description text, status public.task_status not null default 'todo',
  priority text not null default 'normal', assignee_id uuid references public.profiles(id) on delete set null,
  due_at timestamptz, created_by uuid references public.profiles(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.task_logs (
  id uuid primary key default gen_random_uuid(), task_id uuid not null references public.tasks(id) on delete cascade,
  actor_id uuid references public.profiles(id), message text not null, created_at timestamptz not null default now()
);
create table public.activity_logs (
  id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id),
  action text not null, entity_type text not null, entity_id uuid, details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create or replace function public.current_app_role() returns public.app_role
language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() and is_active = true $$;
create or replace function public.is_manager_or_above() returns boolean
language sql stable security definer set search_path = public
as $$ select coalesce(public.current_app_role() in ('owner','admin','manager'), false) $$;
alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.task_logs enable row level security;
alter table public.activity_logs enable row level security;
create policy "active users can read profiles" on public.profiles for select to authenticated using (is_active = true or id = auth.uid());
-- Profile updates are intentionally disabled until a trusted admin-only update flow is implemented.
create policy "authenticated users read clients" on public.clients for select to authenticated using (true);
create policy "managers create clients" on public.clients for insert to authenticated with check (public.is_manager_or_above());
create policy "managers update clients" on public.clients for update to authenticated using (public.is_manager_or_above()) with check (public.is_manager_or_above());
create policy "authenticated users read projects" on public.projects for select to authenticated using (true);
create policy "managers manage projects" on public.projects for all to authenticated using (public.is_manager_or_above()) with check (public.is_manager_or_above());
create policy "authenticated users read tasks" on public.tasks for select to authenticated using (true);
create policy "authenticated users create tasks" on public.tasks for insert to authenticated with check (created_by = auth.uid());
create policy "assignee or manager update tasks" on public.tasks for update to authenticated using (assignee_id = auth.uid() or public.is_manager_or_above()) with check (assignee_id = auth.uid() or public.is_manager_or_above());
create policy "authenticated users read task logs" on public.task_logs for select to authenticated using (true);
create policy "users add task logs as themselves" on public.task_logs for insert to authenticated with check (actor_id = auth.uid());
create policy "users read activity logs" on public.activity_logs for select to authenticated using (true);
create policy "users add activity logs as themselves" on public.activity_logs for insert to authenticated with check (actor_id = auth.uid());
-- Create profile rows via a trusted server-side onboarding flow after user invitation.
