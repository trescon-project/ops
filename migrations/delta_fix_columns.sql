-- RODE ESTE SCRIPT PARA CORRIGIR O ERRO "Could not find the 'date' column"

-- Adiciona a coluna 'date' se ela não existir
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='date') THEN 
        ALTER TABLE public.proposals ADD COLUMN date TEXT NOT NULL DEFAULT '08/02/2026'; 
    END IF;
END $$;

-- Garante que outras colunas recentes também existam (por precaução)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_edited_by_name') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_edited_by_name TEXT; 
    END IF;
END $$;

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_edited_at') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_edited_at TIMESTAMPTZ; 
    END IF;
END $$;

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_accessed_by_name') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_accessed_by_name TEXT; 
    END IF;
END $$;

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='proposals' AND column_name='last_accessed_at') THEN 
        ALTER TABLE public.proposals ADD COLUMN last_accessed_at TIMESTAMPTZ; 
    END IF;
END $$;

-- Atualiza o cache do schema (às vezes necessário)
NOTIFY pgrst, 'reload schema';
