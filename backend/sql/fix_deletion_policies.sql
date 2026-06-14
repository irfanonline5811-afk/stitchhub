-- =========================================================================
-- StitchHub: SQL Script to Fix Silent Deletion Failures (RLS Bypass)
-- Run this in your Supabase SQL Editor to allow permanent deletions!
-- =========================================================================

-- Disable Row Level Security (RLS) on all tables to ensure the Admin 
-- and profiles can permanently delete records without silent RLS blocks.

ALTER TABLE IF EXISTS public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.tailors DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.order_tracking DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.reviews DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.favorites DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.measurements DISABLE ROW LEVEL SECURITY;

-- Just in case RLS is re-enabled, drop existing restrictive policies 
-- and create full permissive policies for seamless operation.

-- 1. Users Table
DROP POLICY IF EXISTS "Allow all access to users" ON public.users;
CREATE POLICY "Allow all access to users" ON public.users FOR ALL USING (true) WITH CHECK (true);

-- 2. Tailors Table
DROP POLICY IF EXISTS "Allow all access to tailors" ON public.tailors;
CREATE POLICY "Allow all access to tailors" ON public.tailors FOR ALL USING (true) WITH CHECK (true);

-- 3. Orders Table
DROP POLICY IF EXISTS "Allow all access to orders" ON public.orders;
CREATE POLICY "Allow all access to orders" ON public.orders FOR ALL USING (true) WITH CHECK (true);

-- 4. Order Tracking Table
DROP POLICY IF EXISTS "Allow all access to order_tracking" ON public.order_tracking;
CREATE POLICY "Allow all access to order_tracking" ON public.order_tracking FOR ALL USING (true) WITH CHECK (true);

-- 5. Payments Table
DROP POLICY IF EXISTS "Allow all access to payments" ON public.payments;
CREATE POLICY "Allow all access to payments" ON public.payments FOR ALL USING (true) WITH CHECK (true);

-- 6. Reviews Table
DROP POLICY IF EXISTS "Allow all access to reviews" ON public.reviews;
CREATE POLICY "Allow all access to reviews" ON public.reviews FOR ALL USING (true) WITH CHECK (true);

-- 7. Appointments Table
DROP POLICY IF EXISTS "Allow all access to appointments" ON public.appointments;
CREATE POLICY "Allow all access to appointments" ON public.appointments FOR ALL USING (true) WITH CHECK (true);

-- 8. Messages Table
DROP POLICY IF EXISTS "Allow all access to messages" ON public.messages;
CREATE POLICY "Allow all access to messages" ON public.messages FOR ALL USING (true) WITH CHECK (true);

-- 9. Favorites Table
DROP POLICY IF EXISTS "Allow all access to favorites" ON public.favorites;
CREATE POLICY "Allow all access to favorites" ON public.favorites FOR ALL USING (true) WITH CHECK (true);

-- 10. Measurements Table
DROP POLICY IF EXISTS "Allow all access to measurements" ON public.measurements;
CREATE POLICY "Allow all access to measurements" ON public.measurements FOR ALL USING (true) WITH CHECK (true);
