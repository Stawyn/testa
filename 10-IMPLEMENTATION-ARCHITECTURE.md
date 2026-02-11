# Implementation Plan - System Architecture

## Visão Geral da Implementação

Este documento define a arquitetura do novo sistema Low-Code baseado no Maker AI, utilizando Python e JavaScript.

## Stack Tecnológica Completa

### Backend (Python)
```
Framework Web:
- FastAPI 0.104.1 (API REST moderna e rápida)
- Uvicorn (ASGI server)

Database:
- pyodbc 5.0.1 (SQL Server connector)
- SQLAlchemy 2.0.23 (ORM opcional para queries complexas)

Utilities:
- pydantic 2.5.0 (Validação de dados)
- python-jose[cryptography] (JWT tokens)
- passlib[bcrypt] (Password hashing)
- python-multipart (File uploads)

Integrations:
- requests 2.31.0 (HTTP client)
- aiohttp (Async HTTP)
- reportlab 4.0.7 (PDF generation)
- openpyxl (Excel generation)
- jinja2 3.1.2 (Templates)

Testing:
- pytest
- pytest-asyncio
- httpx (async test client)
```

### Frontend (JavaScript/TypeScript)
```
Framework:
- React 18+ ou Vue 3+ (escolher um)
- TypeScript 5.0+

State Management:
- Redux Toolkit (React) ou Pinia (Vue)
- React Query / Vue Query (server state)

UI Library:
- Material-UI v5 (React) ou Vuetify 3 (Vue)
- Tailwind CSS 3+ (utility classes)
- Styled Components / Emotion (CSS-in-JS)

Canvas/Drawing:
- Konva.js (canvas manipulation)
- React-Konva / Vue-Konva (framework wrapper)
- D3.js (data visualization, optional)

Drag & Drop:
- React DnD / Vue Draggable
- interact.js (baixo nível, alternativa)

Forms:
- React Hook Form / VeeValidate
- Yup ou Zod (validation schemas)

Utils:
- Axios (HTTP client)
- date-fns ou dayjs (date manipulation)
- lodash-es (utilities)

Build Tools:
- Vite 5+ (build tool, HMR)
- ESLint + Prettier (code quality)
```

### Database
```
SQL Server 2017+ (via Docker)
- ODBC Driver 17 for SQL Server
- JSON support nativo
- Full-text search
- Triggers e stored procedures
```

### DevOps & Tools
```
Docker & Docker Compose
- Backend container
- Frontend container (nginx)
- SQL Server container
- Volume management

Development:
- Git (version control)
- VS Code (IDE)
- Postman/Insomnia (API testing)
- SQL Server Management Studio (database)

CI/CD (future):
- GitHub Actions
- Docker Registry
```

## Arquitetura em Camadas

### Layer 1: Database (Persistence)
```
┌─────────────────────────────────────────┐
│     SQL Server (Docker Container)       │
│                                         │
│  Database: TESTE5                       │
│  ├── FR_* tables (metadata)            │
│  ├── Triggers (auto-versioning)        │
│  └── Views (convenience queries)       │
│                                         │
│  Volume: sqlserver_data                 │
└─────────────────────────────────────────┘
```

### Layer 2: Backend (Business Logic)
```
┌─────────────────────────────────────────┐
│   FastAPI Backend (Python Container)    │
│                                         │
│  API Layer                              │
│  ├── /api/forms                        │
│  ├── /api/flows                        │
│  ├── /api/connections                  │
│  └── /api/dictionary                   │
│                                         │
│  Service Layer                          │
│  ├── MetadataService                   │
│  ├── FlowEngine                        │
│  ├── FunctionLibrary                   │
│  ├── DBConnectionManager               │
│  └── DataDictionaryService             │
│                                         │
│  Port: 8000                             │
└─────────────────────────────────────────┘
```

### Layer 3: Frontend (Presentation)
```
┌─────────────────────────────────────────┐
│   React/Vue Frontend (Node Container)   │
│                                         │
│  Components                             │
│  ├── Workspace (main layout)           │
│  ├── ObjectTree (left panel)           │
│  ├── TabManager (center)               │
│  ├── PropertyInspector (right)         │
│  ├── FormDesigner (WYSIWYG)            │
│  └── FlowEditor (canvas)               │
│                                         │
│  Services                               │
│  ├── API Client                        │
│  ├── State Management                  │
│  └── Event Bus                         │
│                                         │
│  Port: 3000 (dev) / 80 (prod)          │
└─────────────────────────────────────────┘
```

## Estrutura de Diretórios

### Projeto Completo
```
C:\Users\Raposa\Desktop\visual3\
│
├── docker-compose.yml              # Orchestration
├── .env                            # Environment variables
├── .gitignore
├── README.md
│
├── backend/                        # Python backend
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                # FastAPI app
│   │   ├── config.py              # Settings
│   │   │
│   │   ├── api/                   # REST endpoints
│   │   │   ├── __init__.py
│   │   │   ├── forms.py
│   │   │   ├── flows.py
│   │   │   ├── components.py
│   │   │   ├── connections.py
│   │   │   ├── dictionary.py
│   │   │   ├── events.py
│   │   │   ├── reports.py
│   │   │   └── auth.py
│   │   │
│   │   ├── services/              # Business logic
│   │   │   ├── __init__.py
│   │   │   ├── metadata_service.py
│   │   │   ├── flow_engine.py
│   │   │   ├── function_library.py
│   │   │   ├── db_manager.py
│   │   │   ├── data_dictionary.py
│   │   │   ├── event_manager.py
│   │   │   └── versioning.py
│   │   │
│   │   ├── models/                # Pydantic models
│   │   │   ├── __init__.py
│   │   │   ├── form.py
│   │   │   ├── component.py
│   │   │   ├── flow.py
│   │   │   ├── flow_element.py
│   │   │   ├── event.py
│   │   │   └── user.py
│   │   │
│   │   ├── schemas/               # Request/Response schemas
│   │   │   ├── __init__.py
│   │   │   ├── form_schemas.py
│   │   │   └── flow_schemas.py
│   │   │
│   │   ├── core/                  # Core utilities
│   │   │   ├── __init__.py
│   │   │   ├── security.py
│   │   │   ├── dependencies.py
│   │   │   └── exceptions.py
│   │   │
│   │   └── utils/                 # Helper functions
│   │       ├── __init__.py
│   │       └── helpers.py
│   │
│   └── tests/                     # Backend tests
│       ├── test_api.py
│       ├── test_flow_engine.py
│       └── test_functions.py
│
├── frontend/                       # React/Vue frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── .env
│   ├── index.html
│   │
│   ├── src/
│   │   ├── main.tsx / main.ts    # Entry point
│   │   ├── App.tsx / App.vue
│   │   │
│   │   ├── components/           # React/Vue components
│   │   │   ├── workspace/
│   │   │   │   ├── Workspace.tsx
│   │   │   │   ├── ObjectTree.tsx
│   │   │   │   ├── TabManager.tsx
│   │   │   │   └── PropertyInspector.tsx
│   │   │   │
│   │   │   ├── form-designer/
│   │   │   │   ├── FormDesigner.tsx
│   │   │   │   ├── ComponentPalette.tsx
│   │   │   │   ├── Canvas.tsx
│   │   │   │   └── ComponentWrapper.tsx
│   │   │   │
│   │   │   ├── flow-editor/
│   │   │   │   ├── FlowEditor.tsx
│   │   │   │   ├── FlowCanvas.tsx
│   │   │   │   ├── FlowNode.tsx
│   │   │   │   ├── FlowConnection.tsx
│   │   │   │   └── RadialMenu.tsx
│   │   │   │
│   │   │   ├── common/          # Shared components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Modal.tsx
│   │   │   │   └── ...
│   │   │   │
│   │   │   └── assistants/
│   │   │       ├── SQLAssistant.tsx
│   │   │       └── ExpressionBuilder.tsx
│   │   │
│   │   ├── services/             # API & business logic
│   │   │   ├── api/
│   │   │   │   ├── client.ts    # Axios setup
│   │   │   │   ├── forms.ts
│   │   │   │   ├── flows.ts
│   │   │   │   └── ...
│   │   │   │
│   │   │   └── flow-engine/     # Client-side flow preview
│   │   │       └── renderer.ts
│   │   │
│   │   ├── store/                # State management
│   │   │   ├── index.ts
│   │   │   ├── workspace.ts
│   │   │   ├── forms.ts
│   │   │   ├── flows.ts
│   │   │   └── selection.ts
│   │   │
│   │   ├── hooks/                # Custom hooks (React)
│   │   │   ├── useAPI.ts
│   │   │   ├── useDragDrop.ts
│   │   │   └── useCanvas.ts
│   │   │
│   │   ├── types/                # TypeScript types
│   │   │   ├── form.types.ts
│   │   │   ├── flow.types.ts
│   │   │   └── component.types.ts
│   │   │
│   │   ├── utils/                # Utilities
│   │   │   ├── helpers.ts
│   │   │   └── constants.ts
│   │   │
│   │   └── styles/               # Global styles
│   │       ├── globals.css
│   │       └── theme.ts
│   │
│   └── public/                   # Static assets
│       ├── icons/
│       └── images/
│
├── database/                      # Database scripts
│   ├── schema.sql                # Create tables
│   ├── triggers.sql              # Create triggers
│   ├── views.sql                 # Create views
│   ├── seed.sql                  # Sample data
│   └── migrations/               # Schema migrations
│       ├── 001_initial.sql
│       └── 002_add_feature.sql
│
├── assets/                        # Shared assets
│   ├── icons/                    # Node icons
│   │   ├── start.png
│   │   ├── sql.png
│   │   └── ...
│   │
│   └── images/                   # UI images
│
└── docs/                         # Documentation
    ├── api/                      # API docs
    ├── architecture/             # Architecture docs
    └── user-guide/               # User manual
```

## Docker Compose Configuration

```yaml
# docker-compose.yml
version: '3.8'

services:
  # SQL Server Database
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2017-latest
    container_name: visual3-sqlserver
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=SenhaForte123!
      - MSSQL_PID=Developer
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
      - ./database:/docker-entrypoint-initdb.d
    networks:
      - visual3-network
    restart: unless-stopped

  # Python Backend API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: visual3-backend
    environment:
      - DATABASE_HOST=sqlserver
      - DATABASE_PORT=1433
      - DATABASE_NAME=TESTE5
      - DATABASE_USER=sa
      - DATABASE_PASSWORD=SenhaForte123!
      - SECRET_KEY=${SECRET_KEY}
      - ENVIRONMENT=development
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
      - backend_cache:/app/.cache
    depends_on:
      - sqlserver
    networks:
      - visual3-network
    restart: unless-stopped
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  # React/Vue Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: visual3-frontend
    environment:
      - VITE_API_URL=http://localhost:8000
      - NODE_ENV=development
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules  # Anonymous volume for node_modules
    depends_on:
      - backend
    networks:
      - visual3-network
    restart: unless-stopped
    command: npm run dev -- --host

volumes:
  sqlserver_data:
    driver: local
  backend_cache:
    driver: local

networks:
  visual3-network:
    driver: bridge
```

## Configuration Files

### Backend Dockerfile
```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    unixodbc \
    unixodbc-dev \
    curl \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

### Frontend Dockerfile
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application code
COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev", "--", "--host"]
```

## API Architecture

### RESTful Endpoints Structure
```
/api/v1/
├── /auth
│   ├── POST   /login
│   ├── POST   /logout
│   └── GET    /me
│
├── /forms
│   ├── GET    /              # List all forms
│   ├── POST   /              # Create form
│   ├── GET    /{id}          # Get form details
│   ├── PUT    /{id}          # Update form
│   ├── DELETE /{id}          # Delete form
│   └── GET    /{id}/preview  # Preview form
│
├── /components
│   ├── GET    /forms/{form_id}/components
│   ├── POST   /forms/{form_id}/components
│   ├── PUT    /components/{id}
│   └── DELETE /components/{id}
│
├── /flows
│   ├── GET    /              # List all flows
│   ├── POST   /              # Create flow
│   ├── GET    /{id}          # Get flow details
│   ├── PUT    /{id}          # Update flow
│   ├── DELETE /{id}          # Delete flow
│   ├── POST   /{id}/execute  # Execute flow
│   ├── POST   /{id}/validate # Validate flow
│   └── POST   /{id}/test     # Test flow
│
├── /flow-elements
│   ├── GET    /flows/{flow_id}/elements
│   ├── POST   /flows/{flow_id}/elements
│   ├── PUT    /elements/{id}
│   └── DELETE /elements/{id}
│
├── /events
│   ├── GET    /forms/{form_id}/events
│   ├── POST   /              # Create event binding
│   ├── PUT    /{id}          # Update event binding
│   └── DELETE /{id}          # Delete event binding
│
├── /connections
│   ├── GET    /              # List connections
│   ├── POST   /              # Create connection
│   ├── PUT    /{id}          # Update connection
│   ├── DELETE /{id}          # Delete connection
│   ├── POST   /{id}/test     # Test connection
│   └── GET    /{id}/refresh  # Refresh dictionary
│
├── /dictionary
│   ├── GET    /{conn_id}/tables
│   ├── GET    /{conn_id}/tables/{table}/columns
│   ├── GET    /{conn_id}/tables/{table}/keys
│   └── GET    /{conn_id}/tables/{table}/relations
│
├── /reports
│   ├── GET    /              # List reports
│   ├── POST   /              # Create report
│   ├── GET    /{id}          # Get report
│   ├── POST   /{id}/generate # Generate report
│   └── GET    /{id}/export   # Export report
│
└── /system
    ├── GET    /config        # Get system config
    ├── PUT    /config        # Update config
    ├── GET    /functions     # List available functions
    └── GET    /health        # Health check
```

## Security Architecture

### Authentication Flow
```
1. User login → POST /api/auth/login
2. Backend validates credentials
3. Generate JWT token
4. Return token to client
5. Client stores token (localStorage/sessionStorage)
6. Include token in all subsequent requests (Authorization header)
7. Backend validates token on each request
```

### Authorization Levels
```
1. Admin: Full access to everything
2. Developer: Can create/edit forms, flows, reports
3. User: Can only execute/view
```

## Communication Flow

### Form Designer Flow
```
Frontend                     Backend                      Database
   │                           │                            │
   │  GET /api/forms/5         │                            │
   ├──────────────────────────>│                            │
   │                           │  SELECT FROM FR_FORMULARIO │
   │                           ├───────────────────────────>│
   │                           │<───────────────────────────┤
   │  Form + Components        │                            │
   │<──────────────────────────┤                            │
   │                           │                            │
   │  User edits component     │                            │
   │  PUT /api/components/101  │                            │
   ├──────────────────────────>│                            │
   │                           │  UPDATE FR_COMPONENTE      │
   │                           ├───────────────────────────>│
   │                           │<───────────────────────────┤
   │  Success                  │                            │
   │<──────────────────────────┤                            │
```

### Flow Execution Flow
```
Frontend                     Backend                      Database
   │                           │                            │
   │  User clicks button       │                            │
   │  Event: OnClick           │                            │
   │  POST /api/events/handle  │                            │
   ├──────────────────────────>│                            │
   │                           │  SELECT FROM FR_EVENTO     │
   │                           ├───────────────────────────>│
   │                           │<───────────────────────────┤
   │                           │  Get flow_id = 100         │
   │                           │                            │
   │                           │  Load flow 100             │
   │                           ├───────────────────────────>│
   │                           │<───────────────────────────┤
   │                           │                            │
   │                           │  Execute flow nodes        │
   │                           │  (Flow Engine)             │
   │                           │                            │
   │  Flow result              │                            │
   │<──────────────────────────┤                            │
```

## Performance Considerations

### Backend Optimization
- Connection pooling for database
- Caching for metadata (forms, flows)
- Async operations where possible
- Pagination for large result sets

### Frontend Optimization
- Virtual scrolling for large lists
- Canvas optimization (only render visible)
- Debouncing for auto-save
- Code splitting & lazy loading

## Development Workflow

### 1. Setup Environment
```bash
cd C:\Users\Raposa\Desktop\visual3
docker-compose up -d
```

### 2. Initialize Database
```bash
docker exec -it visual3-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P "SenhaForte123!" \
  -i /docker-entrypoint-initdb.d/schema.sql
```

### 3. Access Services
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- SQL Server: localhost:1433

## Summary

Esta arquitetura fornece:
1. **Separação clara** entre frontend, backend e database
2. **Escalabilidade** via containers Docker
3. **Desenvolvimento ágil** com hot-reload
4. **API bem estruturada** com FastAPI
5. **Frontend moderno** com React/Vue
6. **Persistência robusta** com SQL Server
7. **Segurança** com autenticação JWT
8. **Extensibilidade** para features futuras
