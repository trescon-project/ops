# Guia Técnico: Adicionando Novos Templates

Este guia descreve o processo para adicionar um novo template de proposta ao sistema.

## Visão Geral
O sistema utiliza um **Template Registry** centralizado em `src/config/templates.ts`. Cada template é composto por uma lista de componentes React (slides) e metadados.

## Passo a Passo

### 1. Criar Componentes do Slide
Crie uma nova pasta para o seu template em:
`src/components/slides/templates/[NomeDoTemplate]/`

Crie os arquivos `.tsx` para cada slide. Exemplo:
```tsx
// src/components/slides/templates/Comercial/CapaSlide.tsx
'use client';
import { useProposal } from '@/contexts/ProposalContext';

export default function CapaSlide({ editable }: { editable?: boolean }) {
    const { data } = useProposal();
    return (
        <div className="w-full h-full bg-blue-900 text-white p-20">
            <h1>{data.meta.title}</h1>
        </div>
    );
}
```

### 2. Registrar o Template
Edite o arquivo `src/config/templates.ts` e adicione uma nova entrada na lista `templates`:

```typescript
import CapaSlide from '@/components/slides/templates/Comercial/CapaSlide';
// ... outros imports

export const templates: TemplateConfig[] = [
    // ... outros templates
    {
        id: 'comercial-v1',
        name: 'Comercial Moderno',
        description: 'Template focado em vendas B2B.',
        // Lista ordenada de slides
        slides: [
            { component: CapaSlide, name: 'capa' },
            { component: SobreNosSlide, name: 'sobre_nos' },
            // Para slides que se repetem baseados em uma lista (ex: fases, semanas):
            { 
                component: DetalheSemanaSlide, 
                name: 'detalhe_semana', 
                drilldownKey: 'weeklyDetails' // Chave no JSON de dados
            },
        ],
        // Dados iniciais específicos para este template (opcional)
        defaultContent: {
            weeklyDetails: [] 
        }
    }
];
```

### 3. Testar
1. Acesse o Dashboard (`/dashboard/templates`).
2. O novo card deve aparecer.
3. Clique em "Usar Template" para criar uma proposta.
4. Verifique se o Editor carrega os slides corretos.

## Interface `TemplateConfig`

```typescript
export interface TemplateConfig {
    id: string;          // Identificador único (usado no banco)
    name: string;        // Nome exibido no card
    description: string; // Descrição curta
    thumbnail?: string;  // URL da imagem de capa (opcional)
    slides: {
        component: ComponentType<any>; // O componente React do slide
        name: string;                  // Nome interno para logs/debugging
        drilldownKey?: string;         // (Opcional) Chave p/ renderizar lista
    }[];
    defaultContent: any; // Objeto inicial caso o template precise de dados padrão
}
```
