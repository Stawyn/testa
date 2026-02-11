# Maker AI Recreation Project - Overview

## Objetivo do Projeto

Recriar um sistema Low-Code IDE completo, inspirado no Maker AI, utilizando:
- **Backend**: Python
- **Frontend**: JavaScript
- **Database**: SQL Server (Docker)
- **Metodologia**: SAP (Structural Analysis and Planning)

## Contexto do Maker AI

O Maker AI é uma IDE Low-Code onde:
- **Tudo é metadado**: A estrutura do programa, interface e lógica são armazenados no banco de dados SQL
- **Interpretação em tempo real**: Não há compilação; o sistema lê os metadados e interpreta em runtime
- **Motor de Metadados**: O core do sistema que transforma dados SQL em aplicações funcionais

## Localização dos Recursos

### Arquivos do Maker AI Original
- **Instalação Principal**: `C:\Program Files (x86)\Softwell Solutions\Maker AI`
- **Arquivos Adicionais**: `C:\Users\Raposa\Desktop\Outros`
- **Recursos Visuais (PNG)**: `C:\Users\Raposa\Documents\How to Create and Edit a Flowchart in FileMaker Pro Using FlowShare_export\PNG`

### Infraestrutura Docker
```bash
# SQL Server Container
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=SenhaForte123!" \
  -p 1433:1433 -v sqlserver_data:/var/opt/mssql \
  --name sqlserver -d mcr.microsoft.com/mssql/server:2017-latest

# Database Creation
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" -Q "CREATE DATABASE TESTE5"
```

### Pasta de Desenvolvimento
**Target**: `C:\Users\Raposa\Desktop\visual3`

## Estrutura da Documentação

Este projeto está documentado em múltiplos arquivos MD organizados por área:

### Análise do Sistema Original (Maker AI)
1. **01-MAKER-ARCHITECTURE.md** - Arquitetura geral do Maker AI
2. **02-MAKER-FRONTEND.md** - Análise do frontend do Maker
3. **03-MAKER-BACKEND.md** - Análise do backend do Maker
4. **04-MAKER-DATABASE.md** - Schema e estrutura de dados
5. **05-MAKER-FLOWCHART.md** - Sistema de fluxogramas

### Plano de Implementação
6. **10-IMPLEMENTATION-ARCHITECTURE.md** - Arquitetura do novo sistema
7. **11-IMPLEMENTATION-FRONTEND.md** - Plano de implementação do frontend
8. **12-IMPLEMENTATION-BACKEND.md** - Plano de implementação do backend
9. **13-IMPLEMENTATION-DATABASE.md** - Plano de schema e dados
10. **14-IMPLEMENTATION-FLOWCHART.md** - Implementação do editor de fluxogramas
11. **15-IMPLEMENTATION-DESIGN.md** - Guia de design e UI/UX

### Metodologia e Estrutura
12. **20-SAP-METHODOLOGY.md** - Metodologia SAP aplicada
13. **21-PROJECT-STRUCTURE.md** - Estrutura de pastas e organização
14. **22-DEVELOPMENT-PHASES.md** - Fases de desenvolvimento

## Princípios Fundamentais

### 1. Metadata-Driven Architecture
- Todo elemento visual é uma linha em uma tabela SQL
- Toda lógica é um fluxograma serializado em JSON no banco
- O sistema lê e interpreta, não compila

### 2. Interpretador vs Compilador
- **Maker AI**: Interpreta metadados em runtime
- **Nosso Sistema**: Seguirá o mesmo padrão

### 3. Dicionário de Dados Dinâmico
- O sistema lê a estrutura de qualquer banco conectado
- Cria objetos internos automaticamente baseados nas tabelas
- Permite trabalhar com múltiplos bancos simultaneamente

### 4. Persistência Total
- Posição de botões
- Cores de formulários
- Lógica de fluxogramas
- Tudo é salvo no SQL

## Componentes Principais a Implementar

### A. Interface do Usuário (Frontend)
- **Workspace Principal**: Sistema de abas, painéis laterais
- **Editor de Fluxogramas**: Canvas infinito, menu radial, linker de nós
- **Designer de Formulários**: WYSIWYG drag & drop

### B. Camada de Lógica (Backend)
- **Gerenciador de Conexões**: Múltiplos bancos
- **API de Funções**: Biblioteca de centenas de funções
- **Gerenciador de Eventos**: Vincula ações a fluxos

### C. Estrutura de Dados (SQL Schema)
- **FR_SISTEMA**: Dados globais
- **FR_FORMULARIO**: Definição de telas
- **FR_COMPONENTE**: Campos e controles
- **FR_FLUXO**: Cabeçalho de lógica
- **FR_FLUXO_ELEMENTO**: Nós do fluxograma
- **FR_EVENTO**: Ligação componente-evento-fluxo

### D. Ferramentas Especiais
- **SQL Assistant**: Geração visual de queries
- **Expression Builder**: Criação de fórmulas lógicas
- **Histórico e Versionamento**: Log de alterações
- **Módulo AI (Copilot)**: Geração por linguagem natural

## Stack Tecnológica

### Backend (Python)
```
- Flask/FastAPI (API REST)
- SQLAlchemy (ORM)
- pyodbc (SQL Server connection)
- JSON manipulation
- Event handling system
```

### Frontend (JavaScript)
```
- React/Vue.js (UI framework)
- D3.js/Konva.js (Canvas de fluxograma)
- Drag & Drop libraries
- State management (Redux/Vuex)
- Material-UI/Tailwind CSS
```

### Database
```
- SQL Server 2017+ (via Docker)
- Triggers e Stored Procedures
- JSON support
```

## Design Visual

### Paleta de Cores
- **Fundo**: `#1e1e1e` (Dark theme)
- **Acentos**: `#2ecc71` (Verde esmeralda)
- **Secundários**: Tons de cinza e azul

### Tipografia
- **Fonte**: Inter ou Roboto (sans-serif moderna)

### Estilo
- Bordas levemente arredondadas
- Modais com glassmorphism leve
- Ícones consistentes (FontAwesome/Material Icons)

## Próximos Passos

1. **Fase 1**: Análise e Documentação (ATUAL)
   - Estudar estrutura do Maker AI
   - Documentar todos os componentes
   - Criar planos detalhados

2. **Fase 2**: Setup e Infraestrutura
   - Criar estrutura de pastas
   - Setup Docker e SQL
   - Configurar ambiente de desenvolvimento

3. **Fase 3**: Implementação Core
   - Database schema
   - Backend API básica
   - Frontend scaffold

4. **Fase 4**: Componentes Principais
   - Editor de fluxogramas
   - Designer de formulários
   - Interpretador de metadados

5. **Fase 5**: Ferramentas e Polimento
   - SQL Assistant
   - Expression Builder
   - AI Copilot
   - UI/UX refinement

## Referências e Recursos

- Documentação original do Maker AI (a ser extraída dos arquivos)
- SQL Server documentation
- Python best practices
- JavaScript/Canvas drawing libraries
- Low-code platform patterns
