-- ==============================================================================
-- UNOFFICIAL NOTES DATABASE TABLE & POLICIES FOR SUPABASE
-- Run this in your Supabase Dashboard:
-- 1. Open your Supabase Project: https://supabase.com/dashboard/project/nyhgciaqvwptmsvrdshc
-- 2. Go to "SQL Editor" on the left sidebar
-- 3. Click "New Query", paste this entire script and click "RUN"
-- ==============================================================================

-- 1. Create the unofficial_notes table
CREATE TABLE IF NOT EXISTS public.unofficial_notes (
    id TEXT PRIMARY KEY,
    category TEXT DEFAULT 'unofficial',
    year TEXT NOT NULL,
    semester TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    drive_link TEXT NOT NULL,
    creator_name TEXT NOT NULL,
    instagram_username TEXT,
    instagram_link TEXT,
    upi_qr_image_link TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.unofficial_notes ENABLE ROW LEVEL SECURITY;

-- 3. Policy: Allow anyone (students/guests) to read/view notes
CREATE POLICY "Allow public read access on unofficial_notes" 
ON public.unofficial_notes 
FOR SELECT 
USING (true);

-- 4. Policy: Allow inserts
CREATE POLICY "Allow insert on unofficial_notes" 
ON public.unofficial_notes 
FOR INSERT 
WITH CHECK (true);

-- 5. Policy: Allow updates
CREATE POLICY "Allow update on unofficial_notes" 
ON public.unofficial_notes 
FOR UPDATE 
USING (true);

-- 6. Policy: Allow deletes
CREATE POLICY "Allow delete on unofficial_notes" 
ON public.unofficial_notes 
FOR DELETE 
USING (true);

-- 7. Create indexes for rapid filtering
CREATE INDEX IF NOT EXISTS idx_unofficial_notes_year_sem ON public.unofficial_notes (year, semester);
CREATE INDEX IF NOT EXISTS idx_unofficial_notes_creator ON public.unofficial_notes (creator_name);

-- 8. Insert initial sample unofficial notes (optional test data)
INSERT INTO public.unofficial_notes (id, category, year, semester, subject_name, drive_link, creator_name, instagram_username, instagram_link, upi_qr_image_link)
VALUES 
(
    'unnote_sample_1',
    'unofficial',
    '2',
    'odd',
    'Engineering Mathematics III - Complete Formulas & Solved Examples',
    'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs/view',
    'Aditya Sharma',
    '@aditya_codes',
    'https://instagram.com/aditya_codes',
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400&q=80'
),
(
    'unnote_sample_2',
    'unofficial',
    '2',
    'odd',
    'Data Structures & Algorithms - Handwritten Exam Revision Notes',
    'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs/view',
    'Sneha Roy',
    '@sneha.tech',
    'https://instagram.com/sneha.tech',
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400&q=80'
),
(
    'unnote_sample_3',
    'unofficial',
    '2',
    'odd',
    'Digital Electronics - K-Map & Logic Gates Short Notes',
    'https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs/view',
    'Aditya Sharma',
    '@aditya_codes',
    'https://instagram.com/aditya_codes',
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400&q=80'
)
ON CONFLICT (id) DO NOTHING;
