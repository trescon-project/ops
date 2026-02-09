
-- Create the proposals table
CREATE TABLE IF NOT EXISTS public.proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    company_name TEXT NOT NULL,
    custom_url TEXT UNIQUE NOT NULL,
    date TEXT NOT NULL DEFAULT '08/02/2026',
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    ai_context TEXT,
    status TEXT NOT NULL DEFAULT 'rascunho',
    last_edited_by_name TEXT,
    last_edited_at TIMESTAMPTZ,
    last_accessed_by_name TEXT,
    last_accessed_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT custom_url_length CHECK (char_length(custom_url) >= 3),
    CONSTRAINT valid_status CHECK (status IN ('rascunho', 'aprovada', 'reprovada', 'em análise'))
);

-- Enable Row Level Security
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

-- POLICIES

-- 1. Everyone can view proposals (for public sharing)
CREATE POLICY "Allow public read access for all proposals" 
ON public.proposals 
FOR SELECT 
USING (true);

-- 2. Authenticated users can create their own proposals
CREATE POLICY "Allow authenticated users to insert their own proposals" 
ON public.proposals 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- 3. Authenticated users can update their own proposals
CREATE POLICY "Allow authenticated users to update their own proposals" 
ON public.proposals 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Authenticated users can delete their own proposals
CREATE POLICY "Allow authenticated users to delete their own proposals" 
ON public.proposals 
FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- Create a function to update the updated_at column
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the function before each update
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.proposals
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_proposals_custom_url ON public.proposals(custom_url);
CREATE INDEX IF NOT EXISTS idx_proposals_user_id ON public.proposals(user_id);

-- Create the templates table
CREATE TABLE IF NOT EXISTS public.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_public BOOLEAN DEFAULT false,
    
    -- Constraints
    CONSTRAINT templates_title_length CHECK (char_length(title) >= 3)
);

-- Enable Row Level Security
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

-- POLICIES for templates

-- 1. Everyone can view public templates
CREATE POLICY "Allow public read access for public templates" 
ON public.templates 
FOR SELECT 
USING (is_public = true);

-- 2. Authenticated users can view their own templates
CREATE POLICY "Allow authenticated users to read their own templates" 
ON public.templates 
FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

-- 3. Authenticated users can create their own templates
CREATE POLICY "Allow authenticated users to insert their own templates" 
ON public.templates 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- 4. Authenticated users can update their own templates
CREATE POLICY "Allow authenticated users to update their own templates" 
ON public.templates 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. Authenticated users can delete their own templates
CREATE POLICY "Allow authenticated users to delete their own templates" 
ON public.templates 
FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- Create a trigger for updated_at on templates (reusing the function)
CREATE TRIGGER set_templates_updated_at
BEFORE UPDATE ON public.templates
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- INDEXES for templates
CREATE INDEX IF NOT EXISTS idx_templates_user_id ON public.templates(user_id);

