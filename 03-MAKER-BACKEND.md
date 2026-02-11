# Maker AI - Análise do Backend

## Arquitetura Backend

O backend do Maker AI é o **Metadata Engine** - o coração do sistema que interpreta e executa os metadados armazenados no SQL.

## Componentes Principais

### 1. API Server (REST)
**Responsabilidade**: Expor endpoints para o frontend

```
┌─────────────────────────────────────────┐
│           API Server (REST)             │
│                                         │
│  /api/forms                            │
│    GET    - List all forms             │
│    POST   - Create new form            │
│    PUT    - Update form                │
│    DELETE - Delete form                │
│                                         │
│  /api/forms/{id}/components            │
│    GET    - Get form components        │
│    POST   - Add component              │
│    PUT    - Update component           │
│                                         │
│  /api/flows                            │
│    GET    - List all flows             │
│    POST   - Create flow                │
│    GET    /{id}/execute - Run flow     │
│                                         │
│  /api/connections                      │
│    GET    - List database connections  │
│    POST   - Add connection             │
│    POST   /{id}/test - Test connection │
│                                         │
│  /api/dictionary                       │
│    GET    /{conn_id}/tables            │
│    GET    /{conn_id}/columns           │
│                                         │
└─────────────────────────────────────────┘
```

**Implementação Python (FastAPI)**:
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

@app.get("/api/forms")
async def list_forms():
    # Query FR_FORMULARIO
    return metadata_service.get_all_forms()

@app.post("/api/forms")
async def create_form(form: FormModel):
    # Insert into FR_FORMULARIO
    return metadata_service.create_form(form)

@app.get("/api/flows/{flow_id}/execute")
async def execute_flow(flow_id: int, params: dict):
    # Load flow and execute
    return flow_engine.execute(flow_id, params)
```

### 2. Metadata Service
**Responsabilidade**: CRUD operations on metadata tables

```python
class MetadataService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    # Forms
    def get_all_forms(self):
        return self.db.query("SELECT * FROM FR_FORMULARIO")
    
    def get_form(self, form_id):
        form = self.db.query(
            "SELECT * FROM FR_FORMULARIO WHERE id = ?", 
            [form_id]
        )
        components = self.db.query(
            "SELECT * FROM FR_COMPONENTE WHERE formulario_id = ?",
            [form_id]
        )
        return {
            "form": form,
            "components": components
        }
    
    def save_form(self, form_data):
        # Insert or update FR_FORMULARIO
        # Handle components
        pass
    
    # Flows
    def get_flow(self, flow_id):
        flow = self.db.query(
            "SELECT * FROM FR_FLUXO WHERE id = ?",
            [flow_id]
        )
        nodes = self.db.query(
            "SELECT * FROM FR_FLUXO_ELEMENTO WHERE fluxo_id = ?",
            [flow_id]
        )
        return {
            "flow": flow,
            "nodes": nodes
        }
    
    def save_flow(self, flow_data):
        # Insert or update FR_FLUXO
        # Handle flow elements
        pass
```

### 3. Flow Engine (Interpretador)
**Responsabilidade**: Executar fluxogramas

```python
class FlowEngine:
    def __init__(self, function_library, metadata_service):
        self.functions = function_library
        self.metadata = metadata_service
        self.context = {}  # Runtime variables
    
    def execute(self, flow_id, initial_params=None):
        """
        Main execution loop
        """
        # Load flow structure
        flow_data = self.metadata.get_flow(flow_id)
        nodes = flow_data['nodes']
        
        # Initialize context
        self.context = initial_params or {}
        
        # Find START node
        current_node = self._find_start_node(nodes)
        
        # Execute flow
        while current_node:
            try:
                # Execute current node
                result = self._execute_node(current_node)
                
                # Determine next node based on result
                current_node = self._get_next_node(
                    current_node, 
                    result, 
                    nodes
                )
                
            except Exception as e:
                # Handle errors
                error_node = self._get_error_handler(current_node)
                if error_node:
                    current_node = error_node
                else:
                    raise
        
        return self.context
    
    def _execute_node(self, node):
        """
        Execute a single node
        """
        node_type = node['tipo']
        config = json.loads(node['configuracao'])
        
        # Get the function to execute
        function_name = config.get('function')
        if not function_name:
            function_name = self._get_default_function(node_type)
        
        # Get function from library
        func = self.functions.get(function_name)
        if not func:
            raise Exception(f"Function {function_name} not found")
        
        # Prepare parameters
        params = self._prepare_params(config, self.context)
        
        # Execute
        result = func(**params)
        
        # Store output if specified
        output_var = config.get('output_var')
        if output_var:
            self.context[output_var] = result
        
        return result
    
    def _get_next_node(self, current_node, result, all_nodes):
        """
        Determine next node based on current result
        """
        config = json.loads(current_node['configuracao'])
        
        # For decision nodes
        if current_node['tipo'] == 'IF':
            if result:
                next_id = config.get('next_true')
            else:
                next_id = config.get('next_false')
        else:
            next_id = config.get('next_node')
        
        if not next_id:
            return None  # End of flow
        
        return self._find_node_by_id(all_nodes, next_id)
```

### 4. Function Library
**Responsabilidade**: Biblioteca de funções executáveis

```python
class FunctionLibrary:
    def __init__(self, db_connection_manager):
        self.db_manager = db_connection_manager
        self.functions = {}
        self._register_all_functions()
    
    def _register_all_functions(self):
        """
        Register all available functions
        """
        # Database operations
        self.register('executar_sql', self.executar_sql)
        self.register('abrir_transacao', self.abrir_transacao)
        self.register('commit_transacao', self.commit_transacao)
        
        # UI operations
        self.register('abrir_formulario', self.abrir_formulario)
        self.register('fechar_formulario', self.fechar_formulario)
        self.register('atualizar_campo', self.atualizar_campo)
        self.register('mostrar_mensagem', self.mostrar_mensagem)
        
        # Data manipulation
        self.register('tratar_string', self.tratar_string)
        self.register('formatar_data', self.formatar_data)
        self.register('calcular_expressao', self.calcular_expressao)
        
        # External integration
        self.register('enviar_email', self.enviar_email)
        self.register('chamar_api', self.chamar_api)
        self.register('exportar_pdf', self.exportar_pdf)
        
        # ... hundreds more
    
    def register(self, name, function):
        self.functions[name] = function
    
    def get(self, name):
        return self.functions.get(name)
    
    # === Database Functions ===
    
    def executar_sql(self, query, connection_id='default', params=None):
        """
        Execute SQL query
        """
        conn = self.db_manager.get_connection(connection_id)
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if query.strip().upper().startswith('SELECT'):
            results = cursor.fetchall()
            return [dict(row) for row in results]
        else:
            conn.commit()
            return cursor.rowcount
    
    def abrir_transacao(self, connection_id='default'):
        """
        Begin transaction
        """
        conn = self.db_manager.get_connection(connection_id)
        conn.begin()
        return True
    
    def commit_transacao(self, connection_id='default'):
        """
        Commit transaction
        """
        conn = self.db_manager.get_connection(connection_id)
        conn.commit()
        return True
    
    # === UI Functions ===
    
    def abrir_formulario(self, form_id, params=None):
        """
        Open a form (sends event to frontend)
        """
        return {
            'action': 'open_form',
            'form_id': form_id,
            'params': params
        }
    
    def mostrar_mensagem(self, mensagem, tipo='info'):
        """
        Show message (sends event to frontend)
        """
        return {
            'action': 'show_message',
            'message': mensagem,
            'type': tipo
        }
    
    def atualizar_campo(self, form_id, field_id, value):
        """
        Update field value
        """
        return {
            'action': 'update_field',
            'form_id': form_id,
            'field_id': field_id,
            'value': value
        }
    
    # === Data Manipulation ===
    
    def tratar_string(self, texto, operacao):
        """
        String manipulation
        operacao: 'upper', 'lower', 'trim', 'capitalize'
        """
        operations = {
            'upper': lambda s: s.upper(),
            'lower': lambda s: s.lower(),
            'trim': lambda s: s.strip(),
            'capitalize': lambda s: s.capitalize()
        }
        return operations[operacao](texto)
    
    def formatar_data(self, data, formato):
        """
        Format date
        """
        from datetime import datetime
        if isinstance(data, str):
            data = datetime.fromisoformat(data)
        return data.strftime(formato)
    
    def calcular_expressao(self, expressao, variaveis):
        """
        Evaluate expression safely
        """
        # Safe eval with restricted scope
        allowed_names = {
            '__builtins__': {},
            **variaveis
        }
        return eval(expressao, allowed_names)
    
    # === External Integration ===
    
    def enviar_email(self, destinatario, assunto, corpo):
        """
        Send email
        """
        import smtplib
        from email.mime.text import MIMEText
        
        msg = MIMEText(corpo)
        msg['Subject'] = assunto
        msg['To'] = destinatario
        
        # SMTP configuration from system settings
        # ... send email
        
        return True
    
    def chamar_api(self, url, method='GET', headers=None, body=None):
        """
        Call external API
        """
        import requests
        
        response = requests.request(
            method=method,
            url=url,
            headers=headers,
            json=body
        )
        
        return response.json()
    
    def exportar_pdf(self, dados, template):
        """
        Export to PDF
        """
        # Use library like ReportLab
        # ... generate PDF
        return 'path/to/generated.pdf'
```

### 5. Database Connection Manager
**Responsabilidade**: Gerenciar conexões a múltiplos bancos

```python
class DatabaseConnectionManager:
    def __init__(self):
        self.connections = {}
        self.connection_configs = {}
    
    def add_connection(self, conn_id, config):
        """
        Add a new database connection
        config = {
            'type': 'SQL_SERVER',  # or MYSQL, POSTGRES, etc.
            'host': 'localhost',
            'port': 1433,
            'database': 'ERP',
            'username': 'sa',
            'password': 'password'
        }
        """
        self.connection_configs[conn_id] = config
    
    def get_connection(self, conn_id='default'):
        """
        Get or create connection
        """
        if conn_id not in self.connections:
            self._create_connection(conn_id)
        
        return self.connections[conn_id]
    
    def _create_connection(self, conn_id):
        """
        Create actual database connection
        """
        config = self.connection_configs[conn_id]
        db_type = config['type']
        
        if db_type == 'SQL_SERVER':
            import pyodbc
            conn_str = (
                f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                f"SERVER={config['host']};"
                f"DATABASE={config['database']};"
                f"UID={config['username']};"
                f"PWD={config['password']}"
            )
            conn = pyodbc.connect(conn_str)
        
        elif db_type == 'MYSQL':
            import mysql.connector
            conn = mysql.connector.connect(
                host=config['host'],
                database=config['database'],
                user=config['username'],
                password=config['password']
            )
        
        # ... other database types
        
        self.connections[conn_id] = conn
    
    def test_connection(self, conn_id):
        """
        Test if connection is working
        """
        try:
            conn = self.get_connection(conn_id)
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            return True
        except Exception as e:
            return False
```

### 6. Data Dictionary Service
**Responsabilidade**: Ler schemas de bancos externos

```python
class DataDictionaryService:
    def __init__(self, db_manager):
        self.db_manager = db_manager
        self.cache = {}
    
    def get_tables(self, connection_id):
        """
        Get all tables from a database
        """
        cache_key = f"{connection_id}:tables"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        conn = self.db_manager.get_connection(connection_id)
        cursor = conn.cursor()
        
        # SQL Server specific
        cursor.execute("""
            SELECT 
                TABLE_SCHEMA,
                TABLE_NAME,
                TABLE_TYPE
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE'
            ORDER BY TABLE_NAME
        """)
        
        tables = [
            {
                'schema': row[0],
                'name': row[1],
                'type': row[2]
            }
            for row in cursor.fetchall()
        ]
        
        self.cache[cache_key] = tables
        return tables
    
    def get_columns(self, connection_id, table_name):
        """
        Get all columns for a table
        """
        cache_key = f"{connection_id}:{table_name}:columns"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        conn = self.db_manager.get_connection(connection_id)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 
                COLUMN_NAME,
                DATA_TYPE,
                CHARACTER_MAXIMUM_LENGTH,
                IS_NULLABLE,
                COLUMN_DEFAULT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = ?
            ORDER BY ORDINAL_POSITION
        """, [table_name])
        
        columns = [
            {
                'name': row[0],
                'type': row[1],
                'length': row[2],
                'nullable': row[3] == 'YES',
                'default': row[4]
            }
            for row in cursor.fetchall()
        ]
        
        self.cache[cache_key] = columns
        return columns
    
    def get_primary_keys(self, connection_id, table_name):
        """
        Get primary key columns
        """
        conn = self.db_manager.get_connection(connection_id)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE TABLE_NAME = ?
              AND CONSTRAINT_NAME LIKE 'PK_%'
        """, [table_name])
        
        return [row[0] for row in cursor.fetchall()]
    
    def get_foreign_keys(self, connection_id, table_name):
        """
        Get foreign key relationships
        """
        conn = self.db_manager.get_connection(connection_id)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 
                fk.name AS FK_NAME,
                OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
                COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
                OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
                COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
            FROM sys.foreign_keys AS fk
            INNER JOIN sys.foreign_key_columns AS fc 
                ON fk.object_id = fc.constraint_object_id
            WHERE OBJECT_NAME(fk.parent_object_id) = ?
        """, [table_name])
        
        return [
            {
                'name': row[0],
                'column': row[2],
                'referenced_table': row[3],
                'referenced_column': row[4]
            }
            for row in cursor.fetchall()
        ]
    
    def refresh_cache(self, connection_id=None):
        """
        Clear cache to force refresh
        """
        if connection_id:
            keys_to_delete = [
                k for k in self.cache.keys() 
                if k.startswith(f"{connection_id}:")
            ]
            for key in keys_to_delete:
                del self.cache[key]
        else:
            self.cache.clear()
```

### 7. Event Manager
**Responsabilidade**: Vincular eventos a fluxos

```python
class EventManager:
    def __init__(self, metadata_service, flow_engine):
        self.metadata = metadata_service
        self.flow_engine = flow_engine
    
    def handle_event(self, component_id, event_type, event_data):
        """
        Handle a UI event
        """
        # Query FR_EVENTO to find associated flow
        events = self.metadata.db.query("""
            SELECT fluxo_id, parametros
            FROM FR_EVENTO
            WHERE componente_id = ?
              AND tipo_evento = ?
        """, [component_id, event_type])
        
        if not events:
            return None  # No flow bound to this event
        
        # Execute associated flows
        results = []
        for event in events:
            flow_id = event['fluxo_id']
            params_json = event['parametros']
            params = json.loads(params_json) if params_json else {}
            
            # Merge event data with configured params
            params.update(event_data)
            
            # Execute flow
            result = self.flow_engine.execute(flow_id, params)
            results.append(result)
        
        return results
```

### 8. Versioning & History Service
**Responsabilidade**: Rastrear alterações

```python
class VersioningService:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def log_change(self, object_type, object_id, user_id, old_data, new_data):
        """
        Log a change to history table
        """
        self.db.execute("""
            INSERT INTO FR_HISTORICO (
                object_type,
                object_id,
                user_id,
                timestamp,
                old_data,
                new_data
            ) VALUES (?, ?, ?, GETDATE(), ?, ?)
        """, [
            object_type,
            object_id,
            user_id,
            json.dumps(old_data),
            json.dumps(new_data)
        ])
    
    def get_history(self, object_type, object_id):
        """
        Get change history for an object
        """
        return self.db.query("""
            SELECT 
                h.*,
                u.name as user_name
            FROM FR_HISTORICO h
            LEFT JOIN FR_USERS u ON h.user_id = u.id
            WHERE h.object_type = ?
              AND h.object_id = ?
            ORDER BY h.timestamp DESC
        """, [object_type, object_id])
    
    def restore_version(self, history_id):
        """
        Restore object to a previous version
        """
        history = self.db.query(
            "SELECT * FROM FR_HISTORICO WHERE id = ?",
            [history_id]
        )[0]
        
        old_data = json.loads(history['old_data'])
        
        # Apply old data based on object type
        # ... implementation specific to each object type
```

## Estrutura de Aplicação

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Configuration
│   │
│   ├── api/                    # REST endpoints
│   │   ├── __init__.py
│   │   ├── forms.py
│   │   ├── flows.py
│   │   ├── connections.py
│   │   └── dictionary.py
│   │
│   ├── services/               # Business logic
│   │   ├── __init__.py
│   │   ├── metadata_service.py
│   │   ├── flow_engine.py
│   │   ├── function_library.py
│   │   ├── db_manager.py
│   │   ├── data_dictionary.py
│   │   ├── event_manager.py
│   │   └── versioning.py
│   │
│   ├── models/                 # Pydantic models
│   │   ├── __init__.py
│   │   ├── form.py
│   │   ├── flow.py
│   │   └── component.py
│   │
│   └── utils/                  # Utilities
│       ├── __init__.py
│       ├── security.py
│       └── helpers.py
│
├── tests/
│   ├── test_api.py
│   ├── test_flow_engine.py
│   └── test_functions.py
│
├── requirements.txt
└── README.md
```

## Dependencies (requirements.txt)

```
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
sqlalchemy==2.0.23
pyodbc==5.0.1
mysql-connector-python==8.2.0
psycopg2-binary==2.9.9
requests==2.31.0
python-multipart==0.0.6
pyjwt==2.8.0
bcrypt==4.1.1
reportlab==4.0.7
jinja2==3.1.2
```

## Performance Considerations

### 1. Connection Pooling
```python
# Use connection pools instead of creating new connections
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    connection_string,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20
)
```

### 2. Caching
```python
# Cache metadata that doesn't change frequently
from functools import lru_cache
from datetime import timedelta
import time

class CachedMetadata:
    def __init__(self, ttl=300):  # 5 minutes
        self.cache = {}
        self.ttl = ttl
    
    def get(self, key):
        if key in self.cache:
            value, timestamp = self.cache[key]
            if time.time() - timestamp < self.ttl:
                return value
        return None
    
    def set(self, key, value):
        self.cache[key] = (value, time.time())
```

### 3. Async Operations
```python
# Use async for I/O operations
@app.get("/api/forms")
async def list_forms():
    return await metadata_service.get_all_forms_async()
```

## Security

### 1. Authentication
```python
from jose import JWTError, jwt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
```

### 2. SQL Injection Prevention
```python
# Always use parameterized queries
cursor.execute(
    "SELECT * FROM users WHERE id = ?",
    [user_id]  # Parameter
)

# Never:
# cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

### 3. Expression Evaluation Safety
```python
# Restrict eval scope
def safe_eval(expression, variables):
    allowed = {
        '__builtins__': {},
        'abs': abs,
        'min': min,
        'max': max,
        'sum': sum,
        **variables
    }
    return eval(expression, allowed)
```

## Summary

O backend do Maker AI:
1. **Interpreta metadados** armazenados no SQL
2. **Executa fluxogramas** como grafos percorríveis
3. **Gerencia múltiplas conexões** de banco
4. **Fornece biblioteca rica** de funções prontas
5. **Expõe API REST** para o frontend
6. **Mantém histórico** de todas as alterações
7. **Garante segurança** e performance
