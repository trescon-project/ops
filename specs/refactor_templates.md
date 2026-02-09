# Refatoração do Sistema de Templates (Registry Pattern)

## Contexto
Atualmente, o sistema de templates mistura a lógica de apresentação com a definição dos templates. Os componentes de slides estão soltos na pasta `components/templates`, e a renderização no Editor é "hardcoded" (fixa).

O objetivo é migrar para uma abordagem de **Template Registry**, onde templates são definidos via código (arquivos TSX), organizados em pastas, e o sistema (Editor/Dashboard) se adapta dinamicamente ao template selecionado.

## Mudanças Necessárias

### 1. Reorganização de Pastas
- Criar nova estrutura em `src/components/slides`:
  - `src/components/slides/shared/`: Componentes reutilizáveis entre templates (ex: Header, Footer, Blocos de texto padrão).
  - `src/components/slides/templates/[TemplateName]/`: Pasta para cada template específico contendo seus slides exclusivos.
    - Ex: `src/components/slides/templates/Default/` (Mover os slides atuais para cá).
    - Ex: `src/components/slides/templates/Commercial/` (Novo exemplo).

### 2. Template Registry (`src/config/templates.ts`)
- Criar um arquivo de configuração central que exporta uma lista/mapa de templates disponíveis.
- **Interface Sugerida:**
  ```typescript
  export interface TemplateConfig {
    id: string;
    name: string;
    description: string;
    thumbnail?: string;
    slides: React.ComponentType<any>[]; // Lista ordenada de componentes de slide
    defaultContent: any; // Objeto JSON inicial para popular o template
  }
  ```
- Registrar o template atual como "Default" ou "Standard".

### 3. Refatoração da Página de Templates (`app/dashboard/templates/page.tsx`)
- **Remover:** Botão e Modal de "Importar Template" (funcionalidade depreciada).
- **Listagem:** Iterar sobre o `TemplateRegistry` para exibir os cards.
- **Ação:** O botão "Usar Template" deve criar uma nova proposta no Supabase salvando o `templateId` nos metadados da proposta.

### 4. Refatoração do Editor (`app/editor/page.tsx`)
- **Dinâmico:** Remover a lista hardcoded de `<SwiperSlide>`.
- **Lógica:**
  1. Ler o `templateId` da proposta carregada (padrão para 'default' se nulo).
  2. Buscar a configuração no `src/config/templates.ts`.
  3. Mapear `templateConfig.slides.map(...)` para renderizar os componentes corretos dentro do Swiper.
- **Persistência:** Garantir que o `saveProposalAction` e `generateProposalAction` respeitem a estrutura de dados do template ativo.

### 5. Banco de Dados
- Garantir que a tabela `proposals` ou o campo `content` JSON suporte armazenar o `templateId`. (Se necessário, adicionar coluna ou usar campo `meta` existente dentro do JSON).

## Instruções para a IA Executora
1. Comece movendo os arquivos atuais de `components/templates/*.tsx` para `src/components/slides/templates/Default/`. Lembre-se de atualizar os imports em todo o projeto.
2. Crie o `src/config/templates.ts` e registre o template "Default".
3. Refatore `app/dashboard/templates/page.tsx` para usar o Registry.
4. Refatore `app/editor/page.tsx` para carregar slides dinamicamente.
5. Remova código morto (antigo modal de importação).

---
**Critérios de Aceite:**
- Usuário pode escolher um template na tela de Templates.
- Editor carrega os slides corretos baseado na escolha.
- Código organizado e extensível para novos templates no futuro.
