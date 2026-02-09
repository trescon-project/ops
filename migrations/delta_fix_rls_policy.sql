-- MIGRAÇÃO PARA CORRIGIR POLÍTICAS RLS E GARANTIR UPSERT

-- 1. Garantir que custom_url seja UNIQUE (Necessário para o ON CONFLICT funcionar corretamente)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'proposals_custom_url_key') THEN 
        -- Tenta adicionar a constraint unique. Se falhar por duplicatas, o usuário precisará limpar os dados antes.
        ALTER TABLE public.proposals ADD CONSTRAINT proposals_custom_url_key UNIQUE (custom_url);
    END IF;
END $$;

-- 2. Recriar as políticas RLS para garantir permissões corretas
ALTER TABLE public.proposals ENABLE ROW LEVEL SECURITY;

-- 2.1 SELECT (Leitura)
DROP POLICY IF EXISTS "Allow public read access for all proposals" ON public.proposals;
-- Permite leitura pública (para visualizar propostas compartilhadas)
CREATE POLICY "Allow public read access for all proposals" ON public.proposals FOR SELECT USING (true);

-- 2.2 INSERT (Criação)
DROP POLICY IF EXISTS "Allow authenticated users to insert their own proposals" ON public.proposals;
-- Permite inserir se o user_id bater com o usuário autenticado
CREATE POLICY "Allow authenticated users to insert their own proposals" ON public.proposals FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- 2.3 UPDATE (Atualização)
DROP POLICY IF EXISTS "Allow authenticated users to update their own proposals" ON public.proposals;
-- Permite atualizar se o user_id bater
CREATE POLICY "Allow authenticated users to update their own proposals" ON public.proposals FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 2.4 DELETE (Exclusão)
DROP POLICY IF EXISTS "Allow authenticated users to delete their own proposals" ON public.proposals;
-- Permite deletar se o user_id bater
CREATE POLICY "Allow authenticated users to delete their own proposals" ON public.proposals FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- 3. Atualiza o cache do schema do Supabase/PostgREST
NOTIFY pgrst, 'reload schema';
