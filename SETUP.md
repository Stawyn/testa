# Visual3 - Low-Code Platform

## 🚀 Setup Inicial Completo

Este é o projeto Visual3, uma plataforma Low-Code metadata-driven baseada no Maker AI.

### ✅ Fase 3 - Setup e Infraestrutura COMPLETA

A estrutura básica do projeto foi criada com:
- Docker Compose configuration
- Backend Python/FastAPI structure
- Frontend React/TypeScript structure  
- Database schema and seed data

## 📁 Estrutura Criada

```
visual3/
├── docker-compose.yml          # Orquestração Docker
├── .gitignore                  # Git ignore rules
│
├── database/                   # Database scripts
│   ├── schema.sql             # Tabelas FR_*
│   ├── triggers.sql           # Auto-versioning
│   └── seed.sql               # Dados de exemplo
│
├── backend/                    # Python FastAPI
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example
│   └── app/
│       ├── main.py            # FastAPI app
│       ├── core/
│       │   └── config.py      # Settings
│       └── services/
│           └── db_manager.py  # DB connection
│
└── frontend/                   # React TypeScript
    ├── Dockerfile
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    ├── index.html
    └── src/
        ├── main.tsx
        ├── App.tsx
        └── styles/
            └── globals.css
```

## 🐳 Como Executar

### 1. Iniciar o ambiente Docker

```bash
docker-compose up -d
```

Isso iniciará:
- SQL Server (porta 1433)
- Backend FastAPI (porta 8000)
- Frontend React (porta 3000)

### 2. Inicializar o banco de dados

O banco de dados será criado automaticamente no primeiro start. Os scripts em `database/` serão executados.

Para executar manualmente:

```bash
# Schema
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -i /docker-entrypoint-initdb.d/schema.sql

# Triggers
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -i /docker-entrypoint-initdb.d/triggers.sql

# Seed data
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -i /docker-entrypoint-initdb.d/seed.sql
```

### 3. Acessar os serviços

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## 🔧 Desenvolvimento Local (Opcional)

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

## 📊 Database

### Tabelas Criadas

O schema inclui 13 tabelas principais:

- `FR_SISTEMA` - Configuração global
- `FR_USUARIO` - Usuários
- `FR_CONEXAO` - Conexões de banco
- `FR_FORMULARIO` - Definição de formulários
- `FR_COMPONENTE` - Componentes UI
- `FR_FLUXO` - Cabeçalho de fluxos
- `FR_FLUXO_ELEMENTO` - Nós do fluxograma
- `FR_EVENTO` - Event bindings
- `FR_RELATORIO` - Relatórios
- `FR_CONSULTA` - Queries salvas
- `FR_HISTORICO` - Versionamento
- `FR_PERMISSAO` - Permissões
- `FR_VARIAVEL_GLOBAL` - Variáveis globais

### Dados de Exemplo

O seed inclui:
- Sistema configurado
- Usuário admin (admin/admin123)
- Conexão padrão
- Formulário de exemplo
- Fluxo de exemplo

## 🔐 Credenciais Padrão

### Banco de Dados
- **Host**: localhost
- **Port**: 1433
- **Database**: TESTE5
- **User**: sa
- **Password**: SenhaForte123!

### Aplicação
- **Username**: admin
- **Password**: admin123

## 🛠️ Comandos Úteis

### Docker

```bash
# Ver logs
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f backend

# Parar tudo
docker-compose down

# Rebuild
docker-compose up -d --build

# Resetar volumes (cuidado!)
docker-compose down -v
```

### Database

```bash
# Conectar ao SQL Server
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!"

# Backup
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -Q "BACKUP DATABASE TESTE5 TO DISK = '/var/opt/mssql/backup/teste5.bak'"
```

## 📝 Próximos Passos

### Fase 4: Backend Core (5-7 dias)
- [ ] Implementar MetadataService completo
- [ ] Implementar FlowEngine
- [ ] Implementar FunctionLibrary
- [ ] Criar endpoints REST (forms, flows, components)
- [ ] Adicionar testes

### Fase 5: Frontend Workspace (5-7 dias)
- [ ] Criar Workspace layout
- [ ] Implementar ObjectTree
- [ ] Implementar TabManager
- [ ] Implementar PropertyInspector
- [ ] Setup Redux store

### Fase 6: Form Designer (7-10 dias)
- [ ] Implementar canvas drag & drop
- [ ] Component palette
- [ ] Resize e position
- [ ] Property editing

### Fase 7: Flow Editor (10-15 dias)
- [ ] Canvas com Konva.js
- [ ] Tipos de nós
- [ ] Sistema de conexões
- [ ] Node configuration

## 🐛 Troubleshooting

### SQL Server não inicia
```bash
# Ver logs
docker-compose logs sqlserver

# Verificar status
docker-compose ps

# Reconstruir
docker-compose up -d --build sqlserver
```

### Backend não conecta no SQL
```bash
# Verificar health
curl http://localhost:8000/health

# Ver logs
docker-compose logs backend
```

### Frontend não carrega
```bash
# Ver logs
docker-compose logs frontend

# Verificar se node_modules foi criado
docker exec -it visual3-frontend ls -la /app/node_modules
```

## 📚 Documentação Completa

Consulte os arquivos de documentação para detalhes:

- `00-PROJECT-OVERVIEW.md` - Visão geral
- `01-MAKER-ARCHITECTURE.md` - Arquitetura do Maker AI
- `10-IMPLEMENTATION-ARCHITECTURE.md` - Arquitetura de implementação
- `20-SAP-METHODOLOGY.md` - Metodologia e fases
- `99-QUICK-START.md` - Guia rápido

## 📄 Licença

[A definir]

## 👥 Equipe

- Projeto baseado no Maker AI (Softwell Solutions)
- Implementação: Visual3 Team

---

**Status**: Fase 3 Completa ✅ | Próximo: Fase 4 - Backend Core
