# Visual3 - Low-Code Platform Documentation

## 📋 Visão Geral

Este repositório contém a **documentação completa** para o projeto Visual3, uma plataforma Low-Code metadata-driven inspirada no Maker AI.

**Status**: Fase 1, 2 e 3 do SAP CONCLUÍDAS ✅ | Infraestrutura pronta para execução!

## 🎯 Objetivo do Projeto

Recriar um sistema Low-Code IDE completo onde:
- Interface e lógica são definidas visualmente
- Tudo é armazenado como metadados no SQL Server
- Execução acontece por interpretação em runtime (sem compilação)
- Desenvolvimento rápido de aplicações sem escrever código

## 📚 Estrutura da Documentação

### Parte 1: Análise do Maker AI (Como o sistema original funciona)

| Arquivo | Descrição | Tamanho |
|---------|-----------|---------|
| [00-PROJECT-OVERVIEW.md](./00-PROJECT-OVERVIEW.md) | Visão geral, contexto e estrutura do projeto | 5.9K |
| [01-MAKER-ARCHITECTURE.md](./01-MAKER-ARCHITECTURE.md) | Arquitetura metadata-driven do Maker AI | 12K |
| [02-MAKER-FRONTEND.md](./02-MAKER-FRONTEND.md) | Análise completa do frontend (Workspace, Editors) | 21K |
| [03-MAKER-BACKEND.md](./03-MAKER-BACKEND.md) | Backend, Flow Engine, Function Library | 25K |
| [04-MAKER-DATABASE.md](./04-MAKER-DATABASE.md) | Schema SQL completo com todas as tabelas | 18K |
| [05-MAKER-FLOWCHART.md](./05-MAKER-FLOWCHART.md) | Sistema de fluxogramas e tipos de nós | 17K |

### Parte 2: Plano de Implementação (Como recriar com Python e JavaScript)

| Arquivo | Descrição | Tamanho |
|---------|-----------|---------|
| [10-IMPLEMENTATION-ARCHITECTURE.md](./10-IMPLEMENTATION-ARCHITECTURE.md) | Arquitetura Docker, Stack, API design | 23K |
| [11-IMPLEMENTATION-FRONTEND.md](./11-IMPLEMENTATION-FRONTEND.md) | React components, Redux, Material-UI, Konva | 21K |
| [12-IMPLEMENTATION-BACKEND.md](./12-IMPLEMENTATION-BACKEND.md) | FastAPI, Services, Flow Engine, pyodbc | 26K |

### Parte 3: Metodologia e Estrutura

| Arquivo | Descrição | Tamanho |
|---------|-----------|---------|
| [20-SAP-METHODOLOGY.md](./20-SAP-METHODOLOGY.md) | Fases, timeline, milestones, riscos | 14K |
| [21-PROJECT-STRUCTURE.md](./21-PROJECT-STRUCTURE.md) | Estrutura completa de diretórios | 18K |
| [99-QUICK-START.md](./99-QUICK-START.md) | Guia de início rápido | 8.4K |

**Total**: 12 arquivos, ~209 KB de documentação técnica

## 🏗️ Stack Tecnológica

### Backend
- **Python 3.11+** - Linguagem principal
- **FastAPI** - Framework web moderno e rápido
- **pyodbc** - Conexão SQL Server
- **Pydantic** - Validação de dados

### Frontend
- **React 18+** - UI framework
- **TypeScript** - Type safety
- **Material-UI** - Component library
- **Konva.js** - Canvas para fluxogramas
- **Redux Toolkit** - State management

### Database
- **SQL Server 2017+** - Database principal
- Tabelas `FR_*` para metadados
- JSON para propriedades flexíveis
- Triggers para versionamento automático

### DevOps
- **Docker & Docker Compose** - Containerização
- 3 containers: SQL Server, Backend, Frontend
- Volume persistence para dados

## 📁 Estrutura do Projeto ✅ IMPLEMENTADA

```
visual3/
├── docker-compose.yml          # ✅ Orquestração Docker
├── .gitignore                  # ✅ Git ignore rules
│
├── database/                   # ✅ Database scripts
│   ├── schema.sql             # ✅ 13 tabelas FR_*
│   ├── triggers.sql           # ✅ Auto-versioning
│   └── seed.sql               # ✅ Dados de exemplo
│
├── backend/                    # ✅ Python FastAPI
│   ├── Dockerfile             # ✅
│   ├── requirements.txt       # ✅
│   ├── .env.example          # ✅
│   └── app/
│       ├── main.py            # ✅ FastAPI app
│       ├── core/
│       │   └── config.py      # ✅ Settings
│       └── services/
│           └── db_manager.py  # ✅ DB connection
│
└── frontend/                   # ✅ React TypeScript
    ├── Dockerfile             # ✅
    ├── package.json           # ✅
    ├── tsconfig.json          # ✅
    ├── vite.config.ts         # ✅
    ├── index.html             # ✅
    └── src/
        ├── main.tsx           # ✅
        ├── App.tsx            # ✅
        └── styles/
            └── globals.css    # ✅
```
│       ├── hooks/       # Custom hooks
│       └── types/       # TypeScript types
│
├── database/            # SQL scripts
│   ├── schema.sql      # Table definitions
│   ├── triggers.sql    # Triggers
│   └── seed.sql        # Sample data
│
└── docker-compose.yml  # Orchestration
```

## 🚀 Como Executar (Pronto!)

### Requisitos
- Docker e Docker Compose instalados
- Portas 1433, 3000, 8000 disponíveis

### Quick Start

```bash
# Clone o repositório
git clone https://github.com/Stawyn/testa.git
cd testa

# Iniciar todos os serviços
docker-compose up -d

# Aguardar inicialização (~1 minuto)
docker-compose logs -f

# Verificar status
docker-compose ps
```

### Acessar
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

### Credenciais
- **Database**: sa / SenhaForte123!
- **App**: admin / admin123

Para mais detalhes, consulte [SETUP.md](./SETUP.md)

## 📋 Status do Projeto

### ✅ Fase 3: Setup e Infraestrutura - COMPLETA
- [x] Docker Compose configurado
- [x] SQL Server com database TESTE5
- [x] Backend FastAPI funcionando
- [x] Frontend React funcionando
- [x] 13 tabelas FR_* criadas
- [x] Triggers de versionamento
- [x] Dados de exemplo (seed)
- [x] Health check endpoints

Ver [PHASE3-COMPLETE.md](./PHASE3-COMPLETE.md) para detalhes.

## 🎯 Próximos Passos

### Fase 4: Backend Core (5-7 dias)
- [ ] DatabaseConnectionManager
- [ ] MetadataService (CRUD)
- [ ] Flow Engine básico
- [ ] API REST endpoints
- [ ] Testes unitários

### Fase 5: Frontend Workspace (5-7 dias)
- [ ] Layout principal (Workspace)
- [ ] Object Tree (navegação)
- [ ] Tab Manager
- [ ] Property Inspector
- [ ] State management (Redux)

### Fases 6-11: Implementação Completa (~50 dias)
Ver [20-SAP-METHODOLOGY.md](./20-SAP-METHODOLOGY.md) para detalhes completos.

## ⏱️ Timeline Atualizado

```
Fase 1-2: Análise e Planejamento    ✅ CONCLUÍDO (7 dias)
Fase 3: Setup e Infraestrutura      ✅ CONCLUÍDO (1 dia)
Fase 4: Backend Core                ⏳ PRÓXIMO (5-7 dias)
Fase 5-11: Implementação            ⏳ PENDENTE (~50 dias)

TOTAL: ~3 meses (63 dias úteis)
```

## 🎯 Componentes Principais a Implementar

### 1. Form Designer (WYSIWYG)
- Canvas com drag & drop
- Component palette (TextBox, Button, Grid, etc.)
- Property inspector
- Grid e snap
- Undo/Redo

### 2. Flow Editor (Canvas de Fluxogramas)
- Canvas infinito com Konva.js
- Tipos de nós (SQL, IF, LOOP, etc.)
- Smart routing de conexões
- Radial menu para adicionar nós
- Configuração de nós

### 3. SQL Assistant
- Seleção visual de tabelas
- Seleção de campos
- WHERE builder
- Preview de SQL
- Validação

### 4. Expression Builder
- Field selector
- Operator buttons
- Function library
- Validation

### 5. Flow Engine (Interpretador)
- Carrega fluxo do banco
- Percorre nós sequencialmente
- Executa funções associadas
- Gerencia contexto/variáveis
- Error handling

## 📊 Database Schema Principal

```sql
FR_SISTEMA          -- Configurações globais
FR_FORMULARIO       -- Definição de formulários
FR_COMPONENTE       -- Componentes UI (botões, campos, etc.)
FR_FLUXO            -- Cabeçalho de fluxos
FR_FLUXO_ELEMENTO   -- Nós do fluxograma
FR_EVENTO           -- Bindings evento -> fluxo
FR_CONEXAO          -- Conexões de banco de dados
FR_RELATORIO        -- Relatórios
FR_CONSULTA         -- Queries salvas
FR_HISTORICO        -- Versionamento
FR_USUARIO          -- Usuários
FR_PERMISSAO        -- Permissões
FR_VARIAVEL_GLOBAL  -- Variáveis globais
```

## 🔧 Comandos Úteis (quando implementado)

```bash
# Iniciar todo o ambiente
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar tudo
docker-compose down

# Rebuild
docker-compose up -d --build

# Backend (local)
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload

# Frontend (local)
cd frontend
npm install
npm run dev

# Executar testes
pytest                    # Backend
npm test                  # Frontend
```

## 📖 Como Usar Esta Documentação

### Para Executar o Projeto:
1. Leia `SETUP.md` para instruções completas
2. Execute `docker-compose up -d`
3. Acesse http://localhost:3000 (frontend)
4. Acesse http://localhost:8000/docs (API docs)

### Para Entender o Sistema Original:
1. Leia `00-PROJECT-OVERVIEW.md` para contexto
2. Leia `01-MAKER-ARCHITECTURE.md` para conceitos fundamentais
3. Explore os outros arquivos `0X-MAKER-*.md` conforme necessário

### Para Implementar o Sistema:
1. Leia `99-QUICK-START.md` para visão rápida
2. Leia `20-SAP-METHODOLOGY.md` para entender as fases
3. Leia `10-IMPLEMENTATION-ARCHITECTURE.md` para setup
4. Leia `21-PROJECT-STRUCTURE.md` para organização
5. Consulte `11-*.md` e `12-*.md` durante implementação

### Para Desenvolvedores:
- Use esta documentação como referência técnica
- Cada arquivo contém exemplos de código
- Arquitetura e padrões estão documentados
- Consulte conforme implementa cada feature

## 🎓 Conceitos Importantes

### Metadata-Driven
Tudo é dado no SQL, não código executável:
```
Tradicional: Código → Compilar → Executar
Visual3:     Metadados → Interpretar → Executar
```

### Interpretação em Runtime
- Não há fase de compilação
- Changes são instantâneos
- Versionamento é diff de dados
- Rollback é restore de linhas

### Dicionário de Dados Dinâmico
- Sistema lê schemas de bancos externos
- Cria objetos internos automaticamente
- Disponibiliza em dropdowns e assistentes

### Event-Driven
- Componentes geram eventos (OnClick, OnChange)
- Eventos são vinculados a fluxos
- Fluxos executam lógica de negócio

## 🔒 Segurança

- Autenticação JWT
- Passwords com bcrypt
- SQL injection prevention (parameterized queries)
- Expression evaluation com sandbox
- Role-based access control (planejado)

## 🧪 Testes

### Backend
- Testes unitários com pytest
- Testes de API com TestClient
- Testes de integração com database

### Frontend
- Testes de componentes com React Testing Library
- Testes de integração
- E2E tests (opcional)

## 📈 Métricas de Sucesso

- [x] Docker funcionando
- [x] Database criado e populado
- [x] API respondendo (todos endpoints básicos)
- [x] Frontend renderizando
- [ ] Form designer funcional
- [ ] Flow editor funcional
- [ ] Flows executando corretamente
- [ ] Event system funcionando
- [ ] SQL Assistant operacional
- [ ] Sistema integrado end-to-end
- [ ] Testes passando
- [x] Documentação completa
- [ ] Deploy possível

## 🤝 Contribuindo

Este projeto segue a metodologia SAP (Structural Analysis and Planning):
1. Análise profunda antes de código
2. Documentação detalhada
3. Implementação em fases
4. Testes contínuos
5. Revisão e validação

## 📝 Licença

[A definir]

## 👥 Autores

- Documentação e Planejamento: GitHub Copilot Agent
- Projeto Base: Inspirado no Maker AI (Softwell Solutions)

## 🔗 Links Úteis

- FastAPI: https://fastapi.tiangolo.com/
- React: https://react.dev/
- Material-UI: https://mui.com/
- Konva: https://konvajs.org/
- SQL Server: https://docs.microsoft.com/sql/

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Consulte a documentação relevante
2. Verifique `99-QUICK-START.md` para problemas comuns
3. Revise os logs do Docker
4. Abra uma issue no GitHub

---

**Status Atual**: Infraestrutura completa e pronta para desenvolvimento! 🎉

**Última Atualização**: 2026-02-11 - Phase 3 Complete
