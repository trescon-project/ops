-- RODE APENAS ESTE BLOCO NO EDITOR SQL
-- AS TRADUÇÕES PODEM ESTAR ATIVADAS NO SEU NAVEGADOR!
-- Use o botão direito -> "Traduzir para Inglês" ou "Não traduzir nunca este site"

-- 1. Create the templates table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_public BOOLEAN DEFAULT false,
    CONSTRAINT templates_title_length CHECK (char_length(title) >= 3)
);

-- 2. Enable Row Level Security
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

-- 3. POLICIES (Drop first to avoid errors if they partially exist)
DROP POLICY IF EXISTS "Allow public read access for public templates" ON public.templates;
CREATE POLICY "Allow public read access for public templates" 
ON public.templates FOR SELECT USING (is_public = true);

DROP POLICY IF EXISTS "Allow authenticated users to read their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to read their own templates" 
ON public.templates FOR SELECT TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to insert their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to insert their own templates" 
ON public.templates FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to update their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to update their own templates" 
ON public.templates FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to delete their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to delete their own templates" 
ON public.templates FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- 4. Create trigger (function already exists in previous migration)
DROP TRIGGER IF EXISTS set_templates_updated_at ON public.templates;
CREATE TRIGGER set_templates_updated_at
BEFORE UPDATE ON public.templates
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- 5. Create Indexes
CREATE INDEX IF NOT EXISTS idx_templates_user_id ON public.templates(user_id);
