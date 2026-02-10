-- Add columns if they don't exist
-- DO NOT REMOVE THESE LINES. They are required for the constraints below to work.
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS last_edited_by UUID;
ALTER TABLE public.proposals ADD COLUMN IF NOT EXISTS last_accessed_by UUID;

-- Add foreign key constraints explicitly
DO $$ 
BEGIN 
    -- Constraint for last_edited_by
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'proposals_last_edited_by_fkey') THEN 
        ALTER TABLE public.proposals 
        ADD CONSTRAINT proposals_last_edited_by_fkey 
        FOREIGN KEY (last_edited_by) 
        REFERENCES public.profiles(id);
    END IF;

    -- Constraint for last_accessed_by
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'proposals_last_accessed_by_fkey') THEN 
        ALTER TABLE public.proposals 
        ADD CONSTRAINT proposals_last_accessed_by_fkey 
        FOREIGN KEY (last_accessed_by) 
        REFERENCES public.profiles(id);
    END IF;
END $$;

-- Add avatar_url to profiles if it doesn't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_proposals_last_edited_by ON public.proposals(last_edited_by);
CREATE INDEX IF NOT EXISTS idx_proposals_last_accessed_by ON public.proposals(last_accessed_by);

-- Force schema reload for PostgREST
NOTIFY pgrst, 'reload schema';
