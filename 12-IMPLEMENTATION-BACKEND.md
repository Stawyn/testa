# Implementation Plan - Backend

## Visão Geral

Implementação do backend usando Python 3.11+, FastAPI e pyodbc para SQL Server.

## Estrutura do Backend

### 1. Main Application (main.py)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import forms, flows, components, connections, dictionary, events
from app.core.config import settings

app = FastAPI(
    title="Visual3 Low-Code Platform API",
    description="Backend API for metadata-driven low-code platform",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(forms.router, prefix="/api/v1/forms", tags=["forms"])
app.include_router(flows.router, prefix="/api/v1/flows", tags=["flows"])
app.include_router(components.router, prefix="/api/v1/components", tags=["components"])
app.include_router(connections.router, prefix="/api/v1/connections", tags=["connections"])
app.include_router(dictionary.router, prefix="/api/v1/dictionary", tags=["dictionary"])
app.include_router(events.router, prefix="/api/v1/events", tags=["events"])

@app.get("/")
async def root():
    return {"message": "Visual3 API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### 2. Configuration (config.py)

```python
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Database
    DATABASE_HOST: str = "localhost"
    DATABASE_PORT: int = 1433
    DATABASE_NAME: str = "TESTE5"
    DATABASE_USER: str = "sa"
    DATABASE_PASSWORD: str = "SenhaForte123!"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]
    
    # Application
    DEBUG: bool = True
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### 3. Database Connection Manager

```python
# app/services/db_manager.py
import pyodbc
from typing import Dict, List, Any, Optional
from app.core.config import settings

class DatabaseConnectionManager:
    def __init__(self):
        self.connections: Dict[str, pyodbc.Connection] = {}
        self.connection_configs: Dict[str, Dict] = {}
        
        # Add default connection
        self.add_connection('default', {
            'host': settings.DATABASE_HOST,
            'port': settings.DATABASE_PORT,
            'database': settings.DATABASE_NAME,
            'user': settings.DATABASE_USER,
            'password': settings.DATABASE_PASSWORD
        })
    
    def add_connection(self, conn_id: str, config: Dict):
        """Register a new database connection configuration"""
        self.connection_configs[conn_id] = config
    
    def get_connection(self, conn_id: str = 'default') -> pyodbc.Connection:
        """Get or create a database connection"""
        if conn_id not in self.connections or not self._is_connection_alive(conn_id):
            self._create_connection(conn_id)
        return self.connections[conn_id]
    
    def _create_connection(self, conn_id: str):
        """Create a new database connection"""
        config = self.connection_configs[conn_id]
        
        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={config['host']},{config['port']};"
            f"DATABASE={config['database']};"
            f"UID={config['user']};"
            f"PWD={config['password']}"
        )
        
        self.connections[conn_id] = pyodbc.connect(conn_str)
    
    def _is_connection_alive(self, conn_id: str) -> bool:
        """Check if connection is still alive"""
        try:
            if conn_id in self.connections:
                cursor = self.connections[conn_id].cursor()
                cursor.execute("SELECT 1")
                return True
        except:
            return False
        return False
    
    def execute_query(
        self, 
        query: str, 
        params: Optional[List] = None,
        conn_id: str = 'default'
    ) -> List[Dict]:
        """Execute a SELECT query and return results as list of dicts"""
        conn = self.get_connection(conn_id)
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        # Get column names
        columns = [column[0] for column in cursor.description]
        
        # Fetch all rows and convert to dict
        results = []
        for row in cursor.fetchall():
            results.append(dict(zip(columns, row)))
        
        return results
    
    def execute_non_query(
        self,
        query: str,
        params: Optional[List] = None,
        conn_id: str = 'default'
    ) -> int:
        """Execute INSERT/UPDATE/DELETE and return affected rows"""
        conn = self.get_connection(conn_id)
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        conn.commit()
        return cursor.rowcount
    
    def test_connection(self, conn_id: str = 'default') -> bool:
        """Test if connection is working"""
        try:
            conn = self.get_connection(conn_id)
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            return True
        except Exception as e:
            print(f"Connection test failed: {e}")
            return False
    
    def close_all(self):
        """Close all connections"""
        for conn in self.connections.values():
            try:
                conn.close()
            except:
                pass
        self.connections.clear()

# Global instance
db_manager = DatabaseConnectionManager()
```

### 4. Metadata Service

```python
# app/services/metadata_service.py
import json
from typing import List, Dict, Optional
from app.services.db_manager import db_manager

class MetadataService:
    def __init__(self):
        self.db = db_manager
    
    # === FORMS ===
    
    def get_all_forms(self) -> List[Dict]:
        """Get all forms"""
        query = "SELECT * FROM FR_FORMULARIO ORDER BY nome"
        return self.db.execute_query(query)
    
    def get_form(self, form_id: int) -> Dict:
        """Get form by ID with all components"""
        form_query = "SELECT * FROM FR_FORMULARIO WHERE id = ?"
        forms = self.db.execute_query(form_query, [form_id])
        
        if not forms:
            raise ValueError(f"Form {form_id} not found")
        
        form = forms[0]
        
        # Get components
        components_query = """
            SELECT * FROM FR_COMPONENTE 
            WHERE formulario_id = ?
            ORDER BY ordem
        """
        components = self.db.execute_query(components_query, [form_id])
        
        # Parse JSON fields
        for component in components:
            if component['propriedades']:
                component['propriedades'] = json.loads(component['propriedades'])
            if component['estilo']:
                component['estilo'] = json.loads(component['estilo'])
        
        form['components'] = components
        
        # Parse form properties
        if form['propriedades']:
            form['propriedades'] = json.loads(form['propriedades'])
        
        return form
    
    def create_form(self, form_data: Dict) -> Dict:
        """Create new form"""
        query = """
            INSERT INTO FR_FORMULARIO (
                nome, titulo, largura, altura,
                propriedades, created_at, updated_at
            )
            OUTPUT INSERTED.*
            VALUES (?, ?, ?, ?, ?, GETDATE(), GETDATE())
        """
        
        props_json = json.dumps(form_data.get('propriedades', {}))
        
        result = self.db.execute_query(query, [
            form_data['nome'],
            form_data.get('titulo', ''),
            form_data.get('largura', 800),
            form_data.get('altura', 600),
            props_json
        ])
        
        return result[0] if result else None
    
    def update_form(self, form_id: int, form_data: Dict) -> Dict:
        """Update existing form"""
        query = """
            UPDATE FR_FORMULARIO
            SET nome = ?,
                titulo = ?,
                largura = ?,
                altura = ?,
                propriedades = ?,
                updated_at = GETDATE()
            WHERE id = ?
        """
        
        props_json = json.dumps(form_data.get('propriedades', {}))
        
        self.db.execute_non_query(query, [
            form_data['nome'],
            form_data.get('titulo', ''),
            form_data.get('largura', 800),
            form_data.get('altura', 600),
            props_json,
            form_id
        ])
        
        return self.get_form(form_id)
    
    def delete_form(self, form_id: int) -> bool:
        """Delete form (cascade deletes components and events)"""
        query = "DELETE FROM FR_FORMULARIO WHERE id = ?"
        rows = self.db.execute_non_query(query, [form_id])
        return rows > 0
    
    # === COMPONENTS ===
    
    def create_component(self, form_id: int, component_data: Dict) -> Dict:
        """Create new component"""
        query = """
            INSERT INTO FR_COMPONENTE (
                formulario_id, tipo, nome, label,
                posicao_x, posicao_y, largura, altura,
                propriedades, estilo, created_at, updated_at
            )
            OUTPUT INSERTED.*
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())
        """
        
        props_json = json.dumps(component_data.get('propriedades', {}))
        style_json = json.dumps(component_data.get('estilo', {}))
        
        result = self.db.execute_query(query, [
            form_id,
            component_data['tipo'],
            component_data['nome'],
            component_data.get('label', ''),
            component_data['posicao_x'],
            component_data['posicao_y'],
            component_data['largura'],
            component_data['altura'],
            props_json,
            style_json
        ])
        
        return result[0] if result else None
    
    # === FLOWS ===
    
    def get_all_flows(self) -> List[Dict]:
        """Get all flows"""
        query = "SELECT * FROM FR_FLUXO ORDER BY nome"
        return self.db.execute_query(query)
    
    def get_flow(self, flow_id: int) -> Dict:
        """Get flow by ID with all elements"""
        flow_query = "SELECT * FROM FR_FLUXO WHERE id = ?"
        flows = self.db.execute_query(flow_query, [flow_id])
        
        if not flows:
            raise ValueError(f"Flow {flow_id} not found")
        
        flow = flows[0]
        
        # Get flow elements
        elements_query = """
            SELECT * FROM FR_FLUXO_ELEMENTO
            WHERE fluxo_id = ?
            ORDER BY ordem
        """
        elements = self.db.execute_query(elements_query, [flow_id])
        
        # Parse JSON configurations
        for element in elements:
            if element['configuracao']:
                element['configuracao'] = json.loads(element['configuracao'])
        
        flow['elements'] = elements
        
        # Parse flow parameters
        if flow['parametros_entrada']:
            flow['parametros_entrada'] = json.loads(flow['parametros_entrada'])
        if flow['parametros_saida']:
            flow['parametros_saida'] = json.loads(flow['parametros_saida'])
        
        return flow
    
    def create_flow(self, flow_data: Dict) -> Dict:
        """Create new flow"""
        query = """
            INSERT INTO FR_FLUXO (
                nome, descricao, categoria,
                parametros_entrada, parametros_saida,
                created_at, updated_at
            )
            OUTPUT INSERTED.*
            VALUES (?, ?, ?, ?, ?, GETDATE(), GETDATE())
        """
        
        params_in = json.dumps(flow_data.get('parametros_entrada', []))
        params_out = json.dumps(flow_data.get('parametros_saida', []))
        
        result = self.db.execute_query(query, [
            flow_data['nome'],
            flow_data.get('descricao', ''),
            flow_data.get('categoria', 'BUSINESS'),
            params_in,
            params_out
        ])
        
        return result[0] if result else None

# Global instance
metadata_service = MetadataService()
```

### 5. Flow Engine

```python
# app/services/flow_engine.py
from typing import Dict, Any, Optional
from app.services.metadata_service import metadata_service
from app.services.function_library import function_library
import json

class FlowEngine:
    def __init__(self):
        self.metadata = metadata_service
        self.functions = function_library
        self.context = {}
    
    def execute(
        self, 
        flow_id: int, 
        initial_params: Optional[Dict] = None
    ) -> Dict:
        """Execute a flow"""
        # Load flow structure
        flow = self.metadata.get_flow(flow_id)
        elements = flow['elements']
        
        # Initialize context
        self.context = {
            'input_params': initial_params or {},
            'variables': {},
            'system': {
                'flow_id': flow_id,
                'flow_name': flow['nome']
            }
        }
        
        # Find START node
        current_element = self._find_start_element(elements)
        
        if not current_element:
            raise ValueError(f"Flow {flow_id} has no START node")
        
        # Execute flow
        max_iterations = 1000  # Safety limit
        iterations = 0
        
        while current_element and iterations < max_iterations:
            try:
                # Execute current element
                result = self._execute_element(current_element)
                
                # Determine next element
                current_element = self._get_next_element(
                    current_element,
                    result,
                    elements
                )
                
                iterations += 1
                
            except Exception as e:
                # Handle errors
                error_handler = self._get_error_handler(current_element, elements)
                if error_handler:
                    self.context['variables']['last_error'] = str(e)
                    current_element = error_handler
                else:
                    raise
        
        if iterations >= max_iterations:
            raise RuntimeError(f"Flow exceeded maximum iterations ({max_iterations})")
        
        return self.context
    
    def _find_start_element(self, elements: list) -> Optional[Dict]:
        """Find the START element"""
        for element in elements:
            if element['tipo'] == 'START':
                return element
        return None
    
    def _execute_element(self, element: Dict) -> Any:
        """Execute a single element"""
        element_type = element['tipo']
        config = element['configuracao'] or {}
        
        # Special handling for control flow elements
        if element_type == 'START':
            return True
        elif element_type == 'END':
            return self.context.get('variables', {})
        elif element_type == 'IF':
            # Evaluate condition
            condition = config.get('condition', '')
            return self._evaluate_condition(condition)
        
        # Get function to execute
        function_name = element.get('funcao') or config.get('function')
        
        if not function_name:
            raise ValueError(f"Element {element['id']} has no function defined")
        
        func = self.functions.get(function_name)
        if not func:
            raise ValueError(f"Function {function_name} not found")
        
        # Prepare parameters
        params = self._prepare_params(config, self.context)
        
        # Execute function
        result = func(**params)
        
        # Store output if specified
        output_var = config.get('output_var')
        if output_var:
            self.context['variables'][output_var] = result
        
        return result
    
    def _evaluate_condition(self, condition: str) -> bool:
        """Safely evaluate a condition expression"""
        # Replace @ variables with context lookups
        # This is simplified - production needs proper parsing
        try:
            # Create safe namespace
            safe_dict = {
                '__builtins__': {},
                **self.context['input_params'],
                **self.context['variables']
            }
            return bool(eval(condition.replace('@', ''), safe_dict))
        except:
            return False
    
    def _prepare_params(self, config: Dict, context: Dict) -> Dict:
        """Prepare function parameters from config and context"""
        params = {}
        for key, value in config.items():
            if key in ['output_var', 'next_node', 'next_true', 'next_false']:
                continue  # Skip meta parameters
            
            # Resolve variables (values starting with @)
            if isinstance(value, str) and value.startswith('@'):
                var_path = value[1:].split('.')
                resolved = context
                for part in var_path:
                    resolved = resolved.get(part, {})
                params[key] = resolved
            else:
                params[key] = value
        
        return params
    
    def _get_next_element(
        self,
        current_element: Dict,
        result: Any,
        all_elements: list
    ) -> Optional[Dict]:
        """Determine the next element to execute"""
        # For IF nodes, check result
        if current_element['tipo'] == 'IF':
            if result:
                next_id = current_element.get('proximo_true_id')
            else:
                next_id = current_element.get('proximo_false_id')
        else:
            next_id = current_element.get('proximo_elemento_id')
        
        if not next_id:
            return None  # End of flow
        
        # Find element by ID
        for element in all_elements:
            if element['id'] == next_id:
                return element
        
        return None
    
    def _get_error_handler(
        self,
        current_element: Dict,
        all_elements: list
    ) -> Optional[Dict]:
        """Get error handler element if defined"""
        error_id = current_element.get('proximo_erro_id')
        if not error_id:
            return None
        
        for element in all_elements:
            if element['id'] == error_id:
                return element
        
        return None

# Global instance
flow_engine = FlowEngine()
```

### 6. Function Library (Sample Functions)

```python
# app/services/function_library.py
from typing import Dict, Any, List, Optional
from app.services.db_manager import db_manager

class FunctionLibrary:
    def __init__(self):
        self.functions = {}
        self._register_all_functions()
    
    def _register_all_functions(self):
        """Register all available functions"""
        # Database operations
        self.register('executar_sql', self.executar_sql)
        self.register('abrir_transacao', self.abrir_transacao)
        self.register('commit_transacao', self.commit_transacao)
        
        # UI operations
        self.register('abrir_formulario', self.abrir_formulario)
        self.register('fechar_formulario', self.fechar_formulario)
        self.register('mostrar_mensagem', self.mostrar_mensagem)
        
        # Data manipulation
        self.register('tratar_string', self.tratar_string)
        self.register('formatar_data', self.formatar_data)
        self.register('calcular_expressao', self.calcular_expressao)
    
    def register(self, name: str, function):
        """Register a function"""
        self.functions[name] = function
    
    def get(self, name: str):
        """Get a function by name"""
        return self.functions.get(name)
    
    # === Database Functions ===
    
    def executar_sql(
        self,
        query: str,
        connection_id: str = 'default',
        params: Optional[List] = None
    ) -> List[Dict]:
        """Execute SQL query"""
        if query.strip().upper().startswith('SELECT'):
            return db_manager.execute_query(query, params, connection_id)
        else:
            rows = db_manager.execute_non_query(query, params, connection_id)
            return {'rows_affected': rows}
    
    def abrir_transacao(self, connection_id: str = 'default') -> bool:
        """Begin transaction"""
        conn = db_manager.get_connection(connection_id)
        # pyodbc auto-starts transactions
        return True
    
    def commit_transacao(self, connection_id: str = 'default') -> bool:
        """Commit transaction"""
        conn = db_manager.get_connection(connection_id)
        conn.commit()
        return True
    
    # === UI Functions ===
    
    def abrir_formulario(
        self,
        form_id: int,
        params: Optional[Dict] = None
    ) -> Dict:
        """Open a form (sends event to frontend)"""
        return {
            'action': 'open_form',
            'form_id': form_id,
            'params': params
        }
    
    def fechar_formulario(self, form_id: int) -> Dict:
        """Close a form"""
        return {
            'action': 'close_form',
            'form_id': form_id
        }
    
    def mostrar_mensagem(
        self,
        mensagem: str,
        tipo: str = 'info'
    ) -> Dict:
        """Show message to user"""
        return {
            'action': 'show_message',
            'message': mensagem,
            'type': tipo
        }
    
    # === Data Manipulation ===
    
    def tratar_string(self, texto: str, operacao: str) -> str:
        """String manipulation"""
        operations = {
            'upper': lambda s: s.upper(),
            'lower': lambda s: s.lower(),
            'trim': lambda s: s.strip(),
            'capitalize': lambda s: s.capitalize()
        }
        return operations.get(operacao, lambda s: s)(texto)
    
    def formatar_data(self, data: str, formato: str) -> str:
        """Format date"""
        from datetime import datetime
        dt = datetime.fromisoformat(data)
        return dt.strftime(formato)
    
    def calcular_expressao(
        self,
        expressao: str,
        variaveis: Dict
    ) -> Any:
        """Evaluate expression safely"""
        safe_dict = {
            '__builtins__': {},
            **variaveis
        }
        return eval(expressao, safe_dict)

# Global instance
function_library = FunctionLibrary()
```

### 7. API Endpoints Example

```python
# app/api/forms.py
from fastapi import APIRouter, HTTPException, Depends
from typing import List
from pydantic import BaseModel
from app.services.metadata_service import metadata_service

router = APIRouter()

class FormCreate(BaseModel):
    nome: str
    titulo: str
    largura: int = 800
    altura: int = 600
    propriedades: dict = {}

class FormUpdate(BaseModel):
    nome: str
    titulo: str
    largura: int
    altura: int
    propriedades: dict

@router.get("/")
async def list_forms():
    """Get all forms"""
    try:
        forms = metadata_service.get_all_forms()
        return forms
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{form_id}")
async def get_form(form_id: int):
    """Get form by ID"""
    try:
        form = metadata_service.get_form(form_id)
        return form
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/")
async def create_form(form: FormCreate):
    """Create new form"""
    try:
        new_form = metadata_service.create_form(form.dict())
        return new_form
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{form_id}")
async def update_form(form_id: int, form: FormUpdate):
    """Update form"""
    try:
        updated_form = metadata_service.update_form(form_id, form.dict())
        return updated_form
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{form_id}")
async def delete_form(form_id: int):
    """Delete form"""
    try:
        success = metadata_service.delete_form(form_id)
        if not success:
            raise HTTPException(status_code=404, detail="Form not found")
        return {"message": "Form deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

## Testing

### Test Setup
```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    return TestClient(app)
```

### API Tests
```python
# tests/test_api.py
def test_list_forms(client):
    response = client.get("/api/v1/forms/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_form(client):
    form_data = {
        "nome": "test_form",
        "titulo": "Test Form",
        "largura": 800,
        "altura": 600
    }
    response = client.post("/api/v1/forms/", json=form_data)
    assert response.status_code == 200
    assert response.json()["nome"] == "test_form"
```

## Summary

O backend implementa:
1. **FastAPI** com endpoints RESTful
2. **Database manager** com pyodbc
3. **Metadata service** para CRUD
4. **Flow engine** para execução
5. **Function library** extensível
6. **Error handling** robusto
7. **Type safety** com Pydantic
8. **Testável** com pytest
