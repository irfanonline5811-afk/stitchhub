-- 📜 Supabase Database Schema Update: Add Mobile Wallet Details to Tailors Table
-- Run this script inside your Supabase SQL Editor to append payment columns to the tailors table.

ALTER TABLE public.tailors 
ADD COLUMN IF NOT EXISTS jazzcash_number TEXT,
ADD COLUMN IF NOT EXISTS jazzcash_title TEXT,
ADD COLUMN IF NOT EXISTS easypaisa_number TEXT,
ADD COLUMN IF NOT EXISTS easypaisa_title TEXT;

-- Verify columns are successfully added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tailors' 
AND column_name IN ('jazzcash_number', 'jazzcash_title', 'easypaisa_number', 'easypaisa_title');
