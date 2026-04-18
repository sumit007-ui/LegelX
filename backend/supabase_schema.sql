-- LegalX AI SQL Schema for Supabase

-- 1. Enable UUID extension
create extension if not exists "uuid-ossp";

-- 2. Create Documents table
create table public.documents (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references auth.users(id) on delete cascade not null,
    file_url text not null,
    file_name text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Create Clauses table (Segmented parts of document)
create table public.clauses (
    id uuid default uuid_generate_v4() primary key,
    document_id uuid references public.documents(id) on delete cascade not null,
    text text not null,
    risk_score float not null default 0.0,
    category text not null,
    explanation text,
    suggested_revision text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Create Analysis table (Summary and metrics)
create table public.analysis (
    id uuid default uuid_generate_v4() primary key,
    document_id uuid references public.documents(id) on delete cascade not null,
    summary text not null,
    overall_score int not null default 0,
    fairness_score int,
    clarity_score int,
    risk_level text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Row Level Security (RLS)
alter table public.documents enable row level security;
alter table public.clauses enable row level security;
alter table public.analysis enable row level security;

-- Policies
create policy "Users can view their own documents" on documents 
    for select using (auth.uid() = user_id);

create policy "Users can insert their own documents" on documents 
    for insert with check (auth.uid() = user_id);

create policy "Users can view clauses for their documents" on clauses 
    for select using (exists (
        select 1 from documents where documents.id = clauses.document_id and documents.user_id = auth.uid()
    ));

create policy "Users can view analysis for their documents" on analysis 
    for select using (exists (
        select 1 from documents where documents.id = analysis.document_id and documents.user_id = auth.uid()
    ));
