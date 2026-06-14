-- 📜 Supabase Database Schema for Manual Payments Table
-- Run this script inside your Supabase SQL Editor to create the necessary table, constraints, and RLS policies.

-- 1. Create manual_payments table
CREATE TABLE IF NOT EXISTS public.manual_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method TEXT NOT NULL,
    transaction_id TEXT UNIQUE,
    screenshot_url TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.manual_payments ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies

-- Policy: Customers can view their own payments
CREATE POLICY "Users can view their own manual payments" 
ON public.manual_payments 
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.orders 
        WHERE public.orders.id = public.manual_payments.order_id 
        AND public.orders.customer_id = auth.uid()
    )
);

-- Policy: Customers can insert their own manual payments
CREATE POLICY "Users can insert their own manual payments" 
ON public.manual_payments 
FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders 
        WHERE public.orders.id = public.manual_payments.order_id 
        AND public.orders.customer_id = auth.uid()
    )
);

-- Policy: Tailors can view manual payments for orders placed with them
CREATE POLICY "Tailors can view manual payments for their orders" 
ON public.manual_payments 
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.orders 
        WHERE public.orders.id = public.manual_payments.order_id 
        AND public.orders.tailor_id = auth.uid()
    )
);

-- Policy: Tailors can update the status of manual payments for their orders
CREATE POLICY "Tailors can update manual payments for their orders" 
ON public.manual_payments 
FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM public.orders 
        WHERE public.orders.id = public.manual_payments.order_id 
        AND public.orders.tailor_id = auth.uid()
    )
);
