# Quick Start Guide - Começando com Visual3

## Visão Geral Rápida

O Visual3 é uma plataforma Low-Code baseada em metadados que permite criar aplicações completas visualmente, sem escrever código.

## Conceitos Principais

### 1. Metadata-Driven
Tudo é armazenado como dados no SQL Server:
- Interface (formulários, componentes)
- Lógica (fluxogramas)
- Configurações
- Eventos

### 2. Interpretação em Runtime
Não há compilação - o sistema lê os metadados e executa em tempo real.

### 3. Componentes Principais
- **Form Designer**: Editor WYSIWYG de interfaces
- **Flow Editor**: Editor visual de lógica/fluxogramas
- **SQL Assistant**: Gerador visual de queries
- **Expression Builder**: Construtor de expressões

## Estrutura da Documentação

### Entendendo o Maker AI (Original)
- `01-MAKER-ARCHITECTURE.md` - Como o Maker funciona
- `02-MAKER-FRONTEND.md` - Interface do Maker
- `03-MAKER-BACKEND.md` - Backend do Maker
- `04-MAKER-DATABASE.md` - Schema do banco
- `05-MAKER-FLOWCHART.md` - Sistema de fluxos

### Plano de Implementação (Visual3)
- `10-IMPLEMENTATION-ARCHITECTURE.md` - Arquitetura do novo sistema
- `11-IMPLEMENTATION-FRONTEND.md` - Como implementar o frontend
- `12-IMPLEMENTATION-BACKEND.md` - Como implementar o backend
- `20-SAP-METHODOLOGY.md` - Metodologia e fases
- `21-PROJECT-STRUCTURE.md` - Organização de pastas

## Stack Tecnológica

### Backend
- **Python 3.11+** com FastAPI
- **pyodbc** para SQL Server
- **Pydantic** para validação

### Frontend
- **React 18+** com TypeScript
- **Material-UI** para componentes
- **Konva.js** para canvas de fluxogramas
- **Redux Toolkit** para state

### Database
- **SQL Server 2017+** via Docker
- Tabelas com prefixo `FR_*`
- JSON para propriedades flexíveis

### DevOps
- **Docker Compose** para orquestração
- 3 containers: SQL Server, Backend, Frontend

## Próximos Passos

### Para Começar a Implementar:

#### 1. Setup do Ambiente (1-2 dias)
```bash
# Criar estrutura de pastas
cd C:\Users\Raposa\Desktop
mkdir visual3
cd visual3

# Criar docker-compose.yml
# Criar estrutura backend/
# Criar estrutura frontend/
# Criar scripts database/
```

#### 2. Iniciar Database (0.5 dia)
```bash
# Subir SQL Server
docker-compose up -d sqlserver

# Executar scripts de schema
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -i /docker-entrypoint-initdb.d/schema.sql
```

#### 3. Backend Básico (2-3 dias)
```python
# Implementar:
# - FastAPI app básica
# - DatabaseConnectionManager
# - MetadataService (CRUD forms)
# - Endpoints /api/forms
```

#### 4. Frontend Básico (2-3 dias)
```typescript
// Implementar:
// - Workspace layout
// - Object tree
// - Tab manager
// - API client
```

#### 5. Form Designer (5-7 dias)
```typescript
// Implementar:
// - Canvas com drag & drop
// - Component palette
// - Property inspector
// - Biblioteca de componentes
```

#### 6. Flow Editor (10-12 dias)
```typescript
// Implementar:
// - Canvas Konva
// - Tipos de nós
// - Sistema de conexões
// - Configuração de nós
```

## Arquivos Importantes

### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2017-latest
    ports:
      - "1433:1433"
  backend:
    build: ./backend
    ports:
      - "8000:8000"
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
```

### Backend Main
```python
# backend/app/main.py
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def root():
    return {"message": "Visual3 API"}
```

### Frontend Main
```typescript
// frontend/src/App.tsx
import { Workspace } from './components/workspace/Workspace';

function App() {
  return <Workspace />;
}
```

## Comandos Úteis

### Docker
```bash
# Iniciar tudo
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar tudo
docker-compose down

# Rebuild
docker-compose up -d --build
```

### Backend
```bash
# Instalar dependências
cd backend
pip install -r requirements.txt

# Rodar localmente (dev)
uvicorn app.main:app --reload

# Rodar testes
pytest
```

### Frontend
```bash
# Instalar dependências
cd frontend
npm install

# Rodar localmente (dev)
npm run dev

# Build produção
npm run build
```

## Endpoints API Principais

```
GET    /api/v1/forms           # Listar formulários
POST   /api/v1/forms           # Criar formulário
GET    /api/v1/forms/{id}      # Obter formulário
PUT    /api/v1/forms/{id}      # Atualizar formulário
DELETE /api/v1/forms/{id}      # Deletar formulário

GET    /api/v1/flows           # Listar fluxos
POST   /api/v1/flows           # Criar fluxo
GET    /api/v1/flows/{id}      # Obter fluxo
POST   /api/v1/flows/{id}/execute  # Executar fluxo

GET    /api/v1/dictionary/{conn_id}/tables    # Listar tabelas
GET    /api/v1/dictionary/{conn_id}/columns   # Listar colunas
```

## Schema Principais Tabelas

```sql
-- Formulários
FR_FORMULARIO (id, nome, titulo, largura, altura, propriedades)

-- Componentes
FR_COMPONENTE (id, formulario_id, tipo, nome, posicao_x, posicao_y, propriedades)

-- Fluxos
FR_FLUXO (id, nome, descricao, categoria)

-- Elementos de Fluxo
FR_FLUXO_ELEMENTO (id, fluxo_id, tipo, nome, posicao_x, posicao_y, configuracao)

-- Eventos
FR_EVENTO (id, componente_id, tipo_evento, fluxo_id)

-- Conexões
FR_CONEXAO (id, nome, tipo, host, database_name)
```

## Checklist de Implementação

### Fase 1: Setup ⏳
- [ ] Criar estrutura de diretórios
- [ ] Configurar Docker Compose
- [ ] Configurar Git
- [ ] Criar .gitignore
- [ ] Configurar environment variables

### Fase 2: Database ⏳
- [ ] Executar schema.sql
- [ ] Executar triggers.sql
- [ ] Executar views.sql
- [ ] Executar seed.sql
- [ ] Testar conexão

### Fase 3: Backend Core ⏳
- [ ] FastAPI app básica
- [ ] DatabaseConnectionManager
- [ ] MetadataService
- [ ] Forms API (CRUD)
- [ ] Tests básicos

### Fase 4: Frontend Core ⏳
- [ ] React app com Vite
- [ ] Workspace layout
- [ ] Object Tree
- [ ] Tab Manager
- [ ] API client

### Fase 5: Form Designer ⏳
- [ ] Canvas drag & drop
- [ ] Component Palette
- [ ] Property Inspector
- [ ] Componentes básicos (TextBox, Button, etc.)
- [ ] Save/Load functionality

### Fase 6: Flow Editor ⏳
- [ ] Konva canvas
- [ ] Nós básicos (START, END, IF)
- [ ] Sistema de conexões
- [ ] Radial menu
- [ ] Save/Load functionality

### Fase 7: Integration ⏳
- [ ] Event system
- [ ] Flow execution
- [ ] Form preview
- [ ] SQL Assistant
- [ ] Expression Builder

## Recursos Adicionais

### Documentação Completa
- Leia todos os arquivos `*.md` criados
- Cada um detalha um aspecto específico

### Referências Externas
- FastAPI: https://fastapi.tiangolo.com/
- React: https://react.dev/
- Material-UI: https://mui.com/
- Konva: https://konvajs.org/

### Ferramentas Recomendadas
- **VS Code**: Editor principal
- **Postman**: Testar API
- **SQL Server Management Studio**: Database
- **React DevTools**: Debug frontend
- **Docker Desktop**: Gerenciar containers

## Suporte

### Problemas Comuns

**Docker não inicia:**
```bash
# Verificar se Docker está rodando
docker info

# Limpar containers antigos
docker-compose down -v
docker system prune -a
```

**Backend não conecta no SQL:**
```bash
# Verificar se SQL Server está rodando
docker-compose ps

# Ver logs do SQL Server
docker-compose logs sqlserver

# Testar conexão manualmente
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" -Q "SELECT 1"
```

**Frontend não carrega:**
```bash
# Limpar node_modules
cd frontend
rm -rf node_modules package-lock.json
npm install

# Verificar variáveis de ambiente
cat .env
```

## Timeline Resumida

```
Semana 1: Setup + Backend Core
Semana 2-3: Frontend Core + Form Designer
Semana 4-6: Flow Editor
Semana 7-8: Integration & Tools
Semana 9-10: Testing & Polish
Semana 11-12: Documentation & Deploy

Total: ~3 meses
```

## Métricas de Sucesso

✅ Docker funcionando
✅ Database criado
✅ API respondendo
✅ Frontend renderizando
✅ Form designer funcional
✅ Flow editor funcional
✅ Flows executando
✅ Sistema integrado end-to-end

## Conclusão

Esta documentação fornece:
1. **Análise completa** do Maker AI
2. **Plano detalhado** de implementação
3. **Estrutura clara** de projeto
4. **Guias práticos** para cada fase
5. **Referências técnicas** completas

Você está pronto para começar a implementação com confiança! 🚀

---

**Próximo passo**: Revisar a documentação e iniciar Fase 3 (Setup e Infraestrutura) do SAP.
