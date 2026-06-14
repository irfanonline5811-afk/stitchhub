-- ==========================================
-- StitchHub: Admin Config SQL
-- ==========================================

-- 1. Create table for system-wide manual wallet configurations
create table if not exists public.admin_settings (
    key text primary key,
    value text not null,
    updated_at timestamp with time zone default now()
);

-- 2. Insert default manual settings if not present
insert into public.admin_settings (key, value)
values 
('jazzcash_number', '03001234567'),
('jazzcash_title', 'Stitch Hub Admin'),
('easypaisa_number', '03451234567'),
('easypaisa_title', 'Stitch Hub Admin')
on conflict (key) do nothing;

-- 3. Enable realtime for admin settings
alter publication supabase_realtime add table admin_settings;

-- 4. Disable Row Level Security (RLS) to ensure seamless updates, and add permissive policies just in case
alter table public.admin_settings disable row level security;

drop policy if exists "Allow all access to admin_settings" on public.admin_settings;
create policy "Allow all access to admin_settings"
on public.admin_settings for all
using (true)
with check (true);

