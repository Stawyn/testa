# Project Structure - Directory Organization

## Complete Directory Tree

```
C:\Users\Raposa\Desktop\visual3\
│
├── README.md                       # Project overview and setup instructions
├── .gitignore                      # Git ignore file
├── .env.example                    # Example environment variables
├── docker-compose.yml              # Docker orchestration
│
├── docs/                           # Documentation
│   ├── README.md
│   ├── architecture/               # Architecture documentation
│   │   ├── overview.md
│   │   ├── backend.md
│   │   ├── frontend.md
│   │   └── database.md
│   ├── api/                        # API documentation
│   │   ├── endpoints.md
│   │   └── swagger.json
│   ├── user-guide/                 # User manual
│   │   ├── getting-started.md
│   │   ├── form-designer.md
│   │   ├── flow-editor.md
│   │   └── faq.md
│   └── developer-guide/            # Developer documentation
│       ├── setup.md
│       ├── contributing.md
│       └── testing.md
│
├── database/                       # Database scripts
│   ├── README.md
│   ├── schema.sql                  # Main schema creation
│   ├── triggers.sql                # Trigger definitions
│   ├── views.sql                   # View definitions
│   ├── functions.sql               # Stored functions
│   ├── seed.sql                    # Sample data
│   ├── migrations/                 # Schema migrations
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_reports.sql
│   │   └── README.md
│   └── scripts/                    # Utility scripts
│       ├── backup.sh
│       ├── restore.sh
│       └── reset.sh
│
├── backend/                        # Python backend
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── requirements-dev.txt        # Development dependencies
│   ├── .env
│   ├── .env.example
│   ├── pytest.ini
│   ├── setup.py
│   ├── README.md
│   │
│   ├── app/                        # Main application
│   │   ├── __init__.py
│   │   ├── main.py                # FastAPI application
│   │   │
│   │   ├── api/                   # API endpoints
│   │   │   ├── __init__.py
│   │   │   ├── v1/               # API version 1
│   │   │   │   ├── __init__.py
│   │   │   │   ├── forms.py
│   │   │   │   ├── components.py
│   │   │   │   ├── flows.py
│   │   │   │   ├── flow_elements.py
│   │   │   │   ├── events.py
│   │   │   │   ├── connections.py
│   │   │   │   ├── dictionary.py
│   │   │   │   ├── reports.py
│   │   │   │   ├── queries.py
│   │   │   │   └── auth.py
│   │   │   └── deps.py           # Dependencies
│   │   │
│   │   ├── core/                  # Core functionality
│   │   │   ├── __init__.py
│   │   │   ├── config.py         # Configuration
│   │   │   ├── security.py       # Auth & security
│   │   │   ├── exceptions.py     # Custom exceptions
│   │   │   └── logging.py        # Logging setup
│   │   │
│   │   ├── models/                # Database models (if using ORM)
│   │   │   ├── __init__.py
│   │   │   ├── form.py
│   │   │   ├── component.py
│   │   │   ├── flow.py
│   │   │   ├── flow_element.py
│   │   │   ├── event.py
│   │   │   ├── connection.py
│   │   │   ├── report.py
│   │   │   └── user.py
│   │   │
│   │   ├── schemas/               # Pydantic schemas
│   │   │   ├── __init__.py
│   │   │   ├── form.py
│   │   │   ├── component.py
│   │   │   ├── flow.py
│   │   │   ├── flow_element.py
│   │   │   ├── event.py
│   │   │   ├── connection.py
│   │   │   ├── report.py
│   │   │   └── user.py
│   │   │
│   │   ├── services/              # Business logic
│   │   │   ├── __init__.py
│   │   │   ├── metadata_service.py
│   │   │   ├── flow_engine.py
│   │   │   ├── function_library.py
│   │   │   ├── db_manager.py
│   │   │   ├── data_dictionary.py
│   │   │   ├── event_manager.py
│   │   │   ├── versioning_service.py
│   │   │   └── report_service.py
│   │   │
│   │   └── utils/                 # Utilities
│   │       ├── __init__.py
│   │       ├── helpers.py
│   │       ├── validators.py
│   │       └── formatters.py
│   │
│   ├── tests/                     # Tests
│   │   ├── __init__.py
│   │   ├── conftest.py           # Test configuration
│   │   ├── test_api/
│   │   │   ├── test_forms.py
│   │   │   ├── test_flows.py
│   │   │   └── test_components.py
│   │   ├── test_services/
│   │   │   ├── test_metadata_service.py
│   │   │   ├── test_flow_engine.py
│   │   │   └── test_function_library.py
│   │   └── test_utils/
│   │       └── test_helpers.py
│   │
│   └── scripts/                   # Utility scripts
│       ├── init_db.py
│       ├── seed_data.py
│       └── run_tests.sh
│
├── frontend/                       # React frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── .env
│   ├── .env.example
│   ├── .eslintrc.json
│   ├── .prettierrc
│   ├── index.html
│   ├── README.md
│   │
│   ├── public/                    # Static files
│   │   ├── favicon.ico
│   │   ├── robots.txt
│   │   └── manifest.json
│   │
│   └── src/                       # Source code
│       ├── main.tsx              # Entry point
│       ├── App.tsx               # Main app component
│       ├── vite-env.d.ts
│       │
│       ├── assets/               # Assets
│       │   ├── icons/           # Icon files
│       │   ├── images/          # Image files
│       │   └── fonts/           # Font files
│       │
│       ├── components/           # React components
│       │   ├── common/          # Shared components
│       │   │   ├── Button.tsx
│       │   │   ├── Input.tsx
│       │   │   ├── Select.tsx
│       │   │   ├── Modal.tsx
│       │   │   ├── Tooltip.tsx
│       │   │   └── ...
│       │   │
│       │   ├── workspace/       # Workspace components
│       │   │   ├── Workspace.tsx
│       │   │   ├── Toolbar.tsx
│       │   │   ├── StatusBar.tsx
│       │   │   ├── ObjectTree.tsx
│       │   │   ├── TreeNode.tsx
│       │   │   ├── TabManager.tsx
│       │   │   ├── Tab.tsx
│       │   │   ├── PropertyInspector.tsx
│       │   │   └── PropertyEditor.tsx
│       │   │
│       │   ├── form-designer/   # Form designer components
│       │   │   ├── FormDesigner.tsx
│       │   │   ├── FormCanvas.tsx
│       │   │   ├── ComponentPalette.tsx
│       │   │   ├── PaletteItem.tsx
│       │   │   ├── ComponentWrapper.tsx
│       │   │   ├── SelectionBox.tsx
│       │   │   ├── ResizeHandles.tsx
│       │   │   └── components/  # Form components
│       │   │       ├── TextBox.tsx
│       │   │       ├── Button.tsx
│       │   │       ├── CheckBox.tsx
│       │   │       ├── ComboBox.tsx
│       │   │       ├── Grid.tsx
│       │   │       ├── DatePicker.tsx
│       │   │       ├── Label.tsx
│       │   │       └── ...
│       │   │
│       │   ├── flow-editor/     # Flow editor components
│       │   │   ├── FlowEditor.tsx
│       │   │   ├── FlowCanvas.tsx
│       │   │   ├── FlowNode.tsx
│       │   │   ├── FlowConnection.tsx
│       │   │   ├── RadialMenu.tsx
│       │   │   ├── NodePalette.tsx
│       │   │   ├── NodeConfigModal.tsx
│       │   │   └── nodes/       # Node types
│       │   │       ├── StartNode.tsx
│       │   │       ├── EndNode.tsx
│       │   │       ├── IfNode.tsx
│       │   │       ├── SqlQueryNode.tsx
│       │   │       └── ...
│       │   │
│       │   ├── assistants/      # Assistant tools
│       │   │   ├── SQLAssistant.tsx
│       │   │   ├── ExpressionBuilder.tsx
│       │   │   ├── TableSelector.tsx
│       │   │   ├── FieldSelector.tsx
│       │   │   └── ConditionBuilder.tsx
│       │   │
│       │   ├── report-designer/  # Report designer
│       │   │   ├── ReportDesigner.tsx
│       │   │   ├── ReportCanvas.tsx
│       │   │   └── ReportElements.tsx
│       │   │
│       │   └── auth/            # Authentication
│       │       ├── Login.tsx
│       │       ├── Register.tsx
│       │       └── ProtectedRoute.tsx
│       │
│       ├── hooks/               # Custom React hooks
│       │   ├── useAPI.ts
│       │   ├── useForms.ts
│       │   ├── useFlows.ts
│       │   ├── useDragDrop.ts
│       │   ├── useCanvas.ts
│       │   ├── useSelection.ts
│       │   ├── useKeyboard.ts
│       │   └── useLocalStorage.ts
│       │
│       ├── services/            # Services
│       │   ├── api/            # API calls
│       │   │   ├── client.ts
│       │   │   ├── forms.ts
│       │   │   ├── components.ts
│       │   │   ├── flows.ts
│       │   │   ├── flow-elements.ts
│       │   │   ├── events.ts
│       │   │   ├── connections.ts
│       │   │   ├── dictionary.ts
│       │   │   └── auth.ts
│       │   │
│       │   └── flow-engine/    # Client-side flow renderer
│       │       ├── renderer.ts
│       │       └── evaluator.ts
│       │
│       ├── store/              # Redux store
│       │   ├── index.ts
│       │   ├── store.ts
│       │   ├── slices/
│       │   │   ├── workspace.ts
│       │   │   ├── forms.ts
│       │   │   ├── components.ts
│       │   │   ├── flows.ts
│       │   │   ├── flow-elements.ts
│       │   │   ├── selection.ts
│       │   │   ├── clipboard.ts
│       │   │   ├── history.ts   # Undo/Redo
│       │   │   └── auth.ts
│       │   │
│       │   └── middleware/
│       │       ├── api.ts
│       │       └── logger.ts
│       │
│       ├── types/              # TypeScript types
│       │   ├── form.types.ts
│       │   ├── component.types.ts
│       │   ├── flow.types.ts
│       │   ├── flow-element.types.ts
│       │   ├── event.types.ts
│       │   ├── connection.types.ts
│       │   ├── report.types.ts
│       │   ├── user.types.ts
│       │   └── api.types.ts
│       │
│       ├── utils/              # Utility functions
│       │   ├── helpers.ts
│       │   ├── validators.ts
│       │   ├── formatters.ts
│       │   ├── constants.ts
│       │   └── canvas-utils.ts
│       │
│       ├── styles/             # Styles
│       │   ├── globals.css
│       │   ├── theme.ts
│       │   ├── colors.ts
│       │   └── mixins.ts
│       │
│       └── routes/             # Routing
│           ├── index.tsx
│           └── routes.tsx
│
├── assets/                     # Shared assets (outside containers)
│   ├── icons/                 # Node and component icons
│   │   ├── nodes/
│   │   │   ├── start.png
│   │   │   ├── end.png
│   │   │   ├── sql.png
│   │   │   ├── if.png
│   │   │   └── ...
│   │   │
│   │   └── components/
│   │       ├── textbox.png
│   │       ├── button.png
│   │       ├── checkbox.png
│   │       └── ...
│   │
│   ├── images/                # UI images
│   │   ├── logo.png
│   │   ├── splash.png
│   │   └── ...
│   │
│   └── templates/             # Templates
│       ├── form-templates/
│       └── flow-templates/
│
├── scripts/                   # Project scripts
│   ├── setup.sh              # Initial setup
│   ├── start.sh              # Start all services
│   ├── stop.sh               # Stop all services
│   ├── reset.sh              # Reset database
│   ├── backup.sh             # Backup database
│   ├── test.sh               # Run all tests
│   └── deploy.sh             # Deploy to production
│
└── .github/                  # GitHub specific (optional)
    ├── workflows/            # CI/CD workflows
    │   ├── test.yml
    │   ├── build.yml
    │   └── deploy.yml
    │
    └── ISSUE_TEMPLATE/       # Issue templates
        ├── bug_report.md
        └── feature_request.md
```

## Key Directories Explained

### `/backend/app/api/`
REST API endpoints organized by resource. Each file contains CRUD operations for a specific entity.

### `/backend/app/services/`
Business logic layer. Contains the core functionality:
- **metadata_service.py**: CRUD operations on metadata tables
- **flow_engine.py**: Flow execution interpreter
- **function_library.py**: Library of executable functions
- **db_manager.py**: Database connection management

### `/frontend/src/components/`
React components organized by feature:
- **workspace/**: Main IDE layout
- **form-designer/**: WYSIWYG form editor
- **flow-editor/**: Flowchart canvas and nodes
- **assistants/**: Helper tools (SQL Assistant, Expression Builder)

### `/frontend/src/store/`
Redux Toolkit state management:
- **slices/**: State slices for each feature
- **middleware/**: Custom middleware for API calls and logging

### `/database/`
SQL scripts for database setup:
- **schema.sql**: Main schema
- **triggers.sql**: Automatic versioning triggers
- **migrations/**: Versioned schema changes

## File Naming Conventions

### Backend (Python)
- **Files**: `snake_case.py`
- **Classes**: `PascalCase`
- **Functions**: `snake_case()`
- **Constants**: `UPPER_SNAKE_CASE`

### Frontend (TypeScript/React)
- **Components**: `PascalCase.tsx`
- **Hooks**: `usePascalCase.ts`
- **Types**: `camelCase.types.ts`
- **Utils**: `camelCase.ts`
- **Constants**: `UPPER_SNAKE_CASE`

### Database (SQL)
- **Tables**: `FR_UPPER_SNAKE_CASE`
- **Columns**: `lower_snake_case`
- **Files**: `kebab-case.sql`

## Import/Export Patterns

### Backend
```python
# Absolute imports from app root
from app.services.metadata_service import metadata_service
from app.core.config import settings
```

### Frontend
```typescript
// Absolute imports from src root
import { Button } from '@/components/common/Button';
import { useAPI } from '@/hooks/useAPI';
import type { Form } from '@/types/form.types';
```

## Environment Files

### Backend `.env`
```
DATABASE_HOST=sqlserver
DATABASE_PORT=1433
DATABASE_NAME=TESTE5
DATABASE_USER=sa
DATABASE_PASSWORD=SenhaForte123!
SECRET_KEY=your-secret-key-here
DEBUG=True
```

### Frontend `.env`
```
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Visual3
VITE_APP_VERSION=1.0.0
```

## Volume Mounts

### Docker Compose Volumes
```yaml
volumes:
  sqlserver_data:        # SQL Server data persistence
    driver: local
  backend_cache:         # Python cache
    driver: local
```

## Port Mapping

```
Service       Internal    External    Purpose
---------     --------    --------    -------
SQL Server    1433        1433        Database access
Backend       8000        8000        API endpoints
Frontend      3000        3000        Web interface (dev)
Frontend      80          80          Web interface (prod)
```

## Build Artifacts (to ignore)

### Backend
```
__pycache__/
*.pyc
*.pyo
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
```

### Frontend
```
node_modules/
dist/
build/
.cache/
.vite/
*.log
```

### Database
```
*.bak
*.trn
*.ldf (if not needed)
```

## Summary

Esta estrutura fornece:
1. **Separação clara** de responsabilidades
2. **Escalabilidade** fácil adição de features
3. **Manutenibilidade** código organizado e navegável
4. **Testabilidade** estrutura que facilita testes
5. **Documentação** lugar claro para docs
6. **Deployment** scripts para automatização

Esta é a base sobre a qual construiremos todo o sistema Visual3.
