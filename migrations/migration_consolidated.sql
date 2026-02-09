-- SCRIPT DE MIGRAÇÃO CONSOLIDADO E ROBUSTO
-- PostgreSQL não suporta "CREATE OR REPLACE TABLE", então usamos "CREATE TABLE IF NOT EXISTS"
-- seguido de verificações para adicionar colunas faltantes (ALTER TABLE).

-- 1. Cria a tabela se não existir (Base)
CREATE TABLE IF NOT EXISTS public.proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 2. Adiciona colunas se não existirem (Garante a estrutura correta)
DO $$ 
BEGIN 
    -- Colunas principais
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='title') THEN 
        ALTER TABLE public.proposals ADD COLUMN title TEXT NOT NULL DEFAULT 'Sem Título'; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='company_name') THEN 
        ALTER TABLE public.proposals ADD COLUMN company_name TEXT NOT NULL DEFAULT 'Empresa'; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='custom_url') THEN 
        ALTER TABLE public.proposals ADD COLUMN custom_url TEXT; 
    END IF;

    -- Garante constraint UNIQUE em custom_url
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'proposals_custom_url_key') THEN
        ALTER TABLE public.proposals ADD CONSTRAINT proposals_custom_url_key UNIQUE (custom_url);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='content') THEN 
        ALTER TABLE public.proposals ADD COLUMN content JSONB NOT NULL DEFAULT '{}'::jsonb; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='status') THEN 
        ALTER TABLE public.proposals ADD COLUMN status TEXT NOT NULL DEFAULT 'rascunho'; 
    END IF;

    -- Colunas secundárias
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='date') THEN 
        ALTER TABLE public.proposals ADD COLUMN date TEXT NOT NULL DEFAULT '08/02/2026'; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='ai_context') THEN 
        ALTER TABLE public.proposals ADD COLUMN ai_context TEXT; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_edited_by_name') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_edited_by_name TEXT; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_edited_at') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_edited_at TIMESTAMPTZ; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_accessed_by_name') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_accessed_by_name TEXT; 
    END IF;
     IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_accessed_at') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_accessed_at TIMESTAMPTZ; 
    END IF;
END $$;


-- 3. Tabela Templates (Mesma lógica)
CREATE TABLE IF NOT EXISTS public.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='templates' AND column_name='title') THEN 
        ALTER TABLE public.templates ADD COLUMN title TEXT NOT NULL DEFAULT 'Novo Template'; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='templates' AND column_name='description') THEN 
        ALTER TABLE public.templates ADD COLUMN description TEXT; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='templates' AND column_name='content') THEN 
        ALTER TABLE public.templates ADD COLUMN content JSONB NOT NULL DEFAULT '{}'::jsonb; 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='templates' AND column_name='is_public') THEN 
        ALTER TABLE public.templates ADD COLUMN is_public BOOLEAN DEFAULT false; 
    END IF;
END $$;


-- 4. Row Level Security (Proposals)
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access for all proposals" ON public.proposals;
CREATE POLICY "Allow public read access for all proposals" ON public.proposals FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert their own proposals" ON public.proposals;
CREATE POLICY "Allow authenticated users to insert their own proposals" ON public.proposals FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to update their own proposals" ON public.proposals;
CREATE POLICY "Allow authenticated users to update their own proposals" ON public.proposals FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to delete their own proposals" ON public.proposals;
CREATE POLICY "Allow authenticated users to delete their own proposals" ON public.proposals FOR DELETE TO authenticated USING (auth.uid() = user_id);


-- 5. Row Level Security (Templates)
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access for public templates" ON public.templates;
CREATE POLICY "Allow public read access for public templates" ON public.templates FOR SELECT USING (is_public = true);

DROP POLICY IF EXISTS "Allow authenticated users to read their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to read their own templates" ON public.templates FOR SELECT TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to insert their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to insert their own templates" ON public.templates FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to update their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to update their own templates" ON public.templates FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to delete their own templates" ON public.templates;
CREATE POLICY "Allow authenticated users to delete their own templates" ON public.templates FOR DELETE TO authenticated USING (auth.uid() = user_id);


-- 6. Funções e Triggers
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.proposals;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.proposals FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_templates_updated_at ON public.templates;
CREATE TRIGGER set_templates_updated_at BEFORE UPDATE ON public.templates FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- 7. Índices e Constraints extras
CREATE INDEX IF NOT EXISTS idx_proposals_user_id ON public.proposals(user_id);
CREATE INDEX IF NOT EXISTS idx_templates_user_id ON public.templates(user_id);

-- Recarrega o Schema
NOTIFY pgrst, 'reload schema';
