# PRD - Plataforma de Propostas de UX

Este documento define os requisitos e a direção técnica para a plataforma de geração de propostas de serviços de UX, utilizando como base o sistema visual e o editor pré-existente.

---

## 1. Visão Geral
A plataforma permite que equipes de design de UX criem, editem e gerenciem propostas profissionais. Combina automação por IA com edição manual granular, permitindo a exportação em PDF e o compartilhamento via link web (One Page).

## 2. Stack Técnica
- **Frontend:** Next.js (App Router), TypeScript, Tailwind CSS.
- **Backend/Auth:** Supabase (PostgreSQL + Supabase Auth).
- **Componentes UI:** Material UI (Ícones) + Swiper.js (Apresentação).
- **Exportação:** jsPDF + html2canvas.
- **IA:** Integração com LLMs para geração e refatoração de conteúdo.
- **Integração Design:** Preparado para expansão via Figma MCP.

## 3. Funcionalidades Principais
### 3.1 Autenticação e Gestão de Equipe
- Sistema de login via Supabase Auth.
- Gestão de usuários para uso em equipe.

### 3.2 Sistema de Templates (Registry)
- **Arquitetura:** Templates definidos via código em `src/config/templates.ts`.
- **Flexibilidade:** Cada template possui sua própria estrutura de slides (componentes React) e lógica de dados.
- **Extensibilidade:** Novos templates podem ser adicionados criando componentes na pasta `src/components/slides/templates/` e registrando-os.
- **Drilldown:** Suporte a slides que se repetem baseados em listas de dados (ex: Cronograma Semanal).

### 3.3 Editor de Propostas (Híbrido)
- **Seleção de Template:** Usuário escolhe o template ao criar a proposta.
- **Renderização Dinâmica:** O editor se adapta aos slides do template selecionado.
- **Edição Manual:** Capacidade de editar textos, valores e descrições diretamente nos slides.
- **Assistência por IA:** 
    - Geração inicial baseada em briefing.
    - Botão de "Melhorar com IA" para blocos de texto específicos.

### 3.4 Persistência e Compartilhamento
- **Banco de Dados:** Armazenamento de propostas (JSON do estado dos slides + metadados + `templateId`) no Supabase.
- **Link Compartilhável:** Geração de uma URL pública onde o cliente visualiza a proposta em formato "One Page".
- **Exportação:** Mantém a funcionalidade de download em PDF (1920x1080).

## 4. Requisitos de Experiência do Usuário (UX)
- **Estética Premium:** Manter o padrão visual de `gestao-propostas` (Dark mode, gradientes, tipografia Outfit/Inter).
- **Fluxo de Trabalho:** Transição fluida entre a geração automática e o ajuste fino manual.

## 5. Estrutura de Páginas e Rotas
### 5.1 Rotas Privadas (Authenticated)
- **`/dashboard`:** Visão geral e listagem de propostas.
- **`/dashboard/templates`:** Galeria para escolha de templates baseada no Registry.
- **`/editor`:** Interface principal de criação e edição com renderização dinâmica de slides.

### 5.2 Rotas Públicas (Unauthenticated)
- **`/public/[url]`:** Visualização da proposta em formato "One Page" para o cliente final, adaptada ao template.
- **`/auth/callback`:** Rota interna para processamento do fluxo de autenticação.

## 6. Documentação Técnica
- [Guia: Adicionando Novos Templates](docs/adding_new_template.md)

## 7. Roadmap de Implementação
1. Configuração do Supabase (Auth + Tabelas). [Concluído]
2. Implementação do fluxo de Login/Proteção de rotas. [Concluído]
3. Refatoração do Editor para suportar `contentEditable` nos slides. [Concluído]
4. Implementação da visualização "Public One Page". [Concluído]
5. Integração com IA para geração de texto dentro do editor. [Concluído]
6. Refatoração para Sistema de Templates (Registry Pattern). [Concluído]
