-- ==========================================
-- StitchHub: Manual Payment Verification SQL
-- ==========================================

-- 1. Create Storage Bucket for Payment Proofs
insert into storage.buckets (id, name, public) 
values ('payment-proofs', 'payment-proofs', true)
on conflict (id) do nothing;

-- 2. Allow Public Access to view receipts
create policy "Public Access to Payment Proofs"
on storage.objects for select
using ( bucket_id = 'payment-proofs' );

-- 3. Allow Authenticated Users to upload receipts
create policy "Authenticated Users can upload proofs"
on storage.objects for insert
with check ( bucket_id = 'payment-proofs' and auth.role() = 'authenticated' );

-- 4. Payments Table (If not exists or missing columns)
-- Make sure the payments table has these fields or create it:
/*
create table if not exists public.payments (
    id uuid primary key default uuid_generate_v4(),
    order_id uuid references public.orders(id),
    customer_id uuid references auth.users(id),
    amount numeric not null,
    payment_method text,
    transaction_id text,
    status text default 'pending',
    failure_reason text,
    metadata jsonb,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);
*/

-- (Optional) If you already have a payments table but just need it ready for Realtime updates:
alter publication supabase_realtime add table payments;
