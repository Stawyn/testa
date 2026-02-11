# Maker AI - Análise de Arquitetura

## Conceito Central: Metadata Engine

O Maker AI não é um gerador de código tradicional. É um **interpretador de metadados** que funciona sob o princípio:

```
SQL Database (Metadata) → Runtime Interpreter → Application
```

## Arquitetura em Camadas

### Layer 1: Persistence (SQL Server)
**Responsabilidade**: Armazenar TUDO como dados estruturados

```
┌─────────────────────────────────────────┐
│         SQL Server Database             │
│  ┌───────────────────────────────────┐  │
│  │  FR_SISTEMA (Global Config)       │  │
│  │  FR_FORMULARIO (Forms)            │  │
│  │  FR_COMPONENTE (UI Components)    │  │
│  │  FR_FLUXO (Flow Logic)            │  │
│  │  FR_FLUXO_ELEMENTO (Flow Nodes)   │  │
│  │  FR_EVENTO (Event Bindings)       │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Características**:
- Não armazena código executável
- Armazena "receitas" do programa
- Usa JSON para estruturas complexas dentro de campos
- Triggers para versionamento automático

### Layer 2: Metadata Engine (Core)
**Responsabilidade**: Ler, interpretar e executar metadados

```
┌─────────────────────────────────────────┐
│       Metadata Engine (Core)            │
│  ┌───────────────────────────────────┐  │
│  │  Data Dictionary Reader           │  │
│  │  Form Renderer                    │  │
│  │  Flow Interpreter                 │  │
│  │  Event Manager                    │  │
│  │  Connection Pool Manager          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

**Componentes**:
1. **Data Dictionary Reader**
   - Conecta a bancos externos
   - Lê schemas (tabelas, colunas, tipos)
   - Cria objetos internos representando estruturas

2. **Form Renderer**
   - Lê FR_FORMULARIO e FR_COMPONENTE
   - Gera interface dinamicamente
   - Aplica estilos e posicionamentos

3. **Flow Interpreter**
   - Carrega FR_FLUXO e FR_FLUXO_ELEMENTO
   - Percorre nós do fluxograma
   - Executa funções associadas

4. **Event Manager**
   - Monitora interações do usuário
   - Consulta FR_EVENTO para binding
   - Dispara fluxos correspondentes

### Layer 3: Runtime Environment
**Responsabilidade**: Executar a aplicação interpretada

```
┌─────────────────────────────────────────┐
│         Runtime Environment             │
│  ┌───────────────────────────────────┐  │
│  │  Web Interface / Mobile App        │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  Rendered Forms             │  │  │
│  │  │  Active Flows               │  │  │
│  │  │  User Session State         │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Fluxo de Execução

### 1. Startup Sequence
```
1. Conectar ao SQL Server
2. Carregar FR_SISTEMA (configurações globais)
3. Inicializar Connection Pool
4. Carregar Data Dictionary (esquemas externos)
5. Preparar ambiente de runtime
```

### 2. Form Loading
```
User Request → Load FR_FORMULARIO
              ↓
         Load FR_COMPONENTE (children)
              ↓
         Load FR_EVENTO (bindings)
              ↓
         Render Interface
              ↓
         Attach Event Listeners
```

### 3. Event Handling
```
User Action (click, change, etc.)
         ↓
Event Manager lookup FR_EVENTO
         ↓
Retrieve associated FLUXO_ID
         ↓
Load FR_FLUXO + FR_FLUXO_ELEMENTO
         ↓
Flow Interpreter executes nodes
         ↓
Update UI / Database / etc.
```

### 4. Flow Execution
```
Start Node
    ↓
[Node 1: Query Database]
    ↓
[Node 2: Process Data]
    ↓
[Node 3: Decision] ─── Yes → [Node 4A]
    │                          
    └── No → [Node 4B]
                ↓
             End Node
```

## Princípios de Design

### 1. Everything is Data
**Problema**: Como representar um botão?
**Solução Maker**:
```sql
INSERT INTO FR_COMPONENTE VALUES (
    id: 1001,
    formulario_id: 5,
    tipo: 'BUTTON',
    propriedades: '{"text":"Save","color":"#2ecc71","x":100,"y":50}'
)
```

### 2. Logic as Traversable Graph
**Problema**: Como executar lógica complexa?
**Solução Maker**:
```sql
-- Flow Header
INSERT INTO FR_FLUXO VALUES (id: 2001, nome: 'OnSaveClick')

-- Flow Nodes
INSERT INTO FR_FLUXO_ELEMENTO VALUES (
    id: 3001,
    fluxo_id: 2001,
    tipo: 'SQL_QUERY',
    posicao_x: 100,
    posicao_y: 50,
    configuracao: '{"query":"SELECT * FROM users","next_node":3002}'
)
```

### 3. Dynamic Schema Discovery
**Problema**: Como permitir trabalhar com qualquer banco?
**Solução Maker**:
- Conecta ao banco via ODBC/JDBC
- Executa queries de sistema para ler INFORMATION_SCHEMA
- Constrói dicionário interno de dados
- Disponibiliza para dropdowns e assistentes

### 4. No Compilation Step
**Diferença de geradores tradicionais**:

**Gerador Tradicional**:
```
Design → Generate Code → Compile → Deploy → Run
```

**Maker AI**:
```
Design → Save Metadata → Run (Interpret)
```

**Vantagens**:
- Mudanças instantâneas (sem recompilação)
- Versionamento simplificado (diff de dados)
- Rollback imediato (restore de linhas)

## Data Dictionary Architecture

### Conceito
O sistema mantém uma representação interna de TODOS os bancos conectados:

```
┌─────────────────────────────────────────┐
│       Internal Data Dictionary          │
│                                          │
│  Database 1: ERP                        │
│    └── Table: customers                 │
│        ├── id (int, PK)                 │
│        ├── name (varchar)               │
│        └── email (varchar)              │
│                                          │
│  Database 2: CRM                        │
│    └── Table: contacts                  │
│        ├── contact_id (int, PK)         │
│        └── phone (varchar)              │
└─────────────────────────────────────────┘
```

### Refresh Mechanism
```python
def refresh_data_dictionary(connection_id):
    # 1. Connect to external database
    conn = get_connection(connection_id)
    
    # 2. Query metadata
    tables = conn.execute("""
        SELECT table_name 
        FROM information_schema.tables
        WHERE table_schema = 'dbo'
    """)
    
    # 3. For each table, get columns
    for table in tables:
        columns = conn.execute(f"""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = '{table.name}'
        """)
        
        # 4. Update internal dictionary
        update_internal_dict(connection_id, table, columns)
```

## Event-Driven Architecture

### Event Types
```
UI Events:
- OnClick
- OnDoubleClick
- OnChange (field modification)
- OnFocus / OnBlur
- OnLoad (form initialization)
- OnClose (form termination)

System Events:
- OnTimer (scheduled)
- OnDataChange (trigger-like)
- OnError
```

### Event Binding Table
```sql
CREATE TABLE FR_EVENTO (
    evento_id INT PRIMARY KEY,
    componente_id INT,  -- which UI element
    tipo_evento VARCHAR(50),  -- 'OnClick', etc.
    fluxo_id INT,  -- which flow to execute
    parametros TEXT  -- JSON with params
)
```

### Execution Flow
```
User clicks Button #1001
    ↓
Event Manager catches click
    ↓
Query: SELECT fluxo_id FROM FR_EVENTO 
       WHERE componente_id = 1001 AND tipo_evento = 'OnClick'
    ↓
Result: fluxo_id = 2001
    ↓
Flow Interpreter loads and executes Flow #2001
```

## Modular Function Library

### Concept
The Maker has hundreds of pre-built functions organized by category:

```
┌─────────────────────────────────────────┐
│        Function Library (API)           │
│                                          │
│  Database Operations                    │
│    ├── executar_sql()                   │
│    ├── abrir_transacao()                │
│    └── commit_transacao()               │
│                                          │
│  UI Operations                          │
│    ├── abrir_formulario()               │
│    ├── fechar_formulario()              │
│    ├── atualizar_campo()                │
│    └── mostrar_mensagem()               │
│                                          │
│  Data Manipulation                      │
│    ├── tratar_string()                  │
│    ├── formatar_data()                  │
│    └── calcular_expressao()             │
│                                          │
│  External Integration                   │
│    ├── enviar_email()                   │
│    ├── chamar_api()                     │
│    └── exportar_pdf()                   │
└─────────────────────────────────────────┘
```

### Function Node Mapping
Each flowchart node maps to one function:

```sql
INSERT INTO FR_FLUXO_ELEMENTO VALUES (
    elemento_id: 3001,
    tipo: 'DATABASE',
    funcao: 'executar_sql',
    parametros: '{"query":"SELECT * FROM users","output_var":"result_set"}'
)
```

## Multi-Database Connection Management

### Connection Pool
```python
connections = {
    'conn_1': {
        'type': 'SQL_SERVER',
        'host': 'localhost',
        'database': 'ERP',
        'pool': [connection_objects]
    },
    'conn_2': {
        'type': 'MYSQL',
        'host': 'remote.server.com',
        'database': 'CRM',
        'pool': [connection_objects]
    }
}
```

### Query Routing
When a flow node executes SQL:
```python
def executar_sql(query, connection_id='default'):
    conn = get_connection(connection_id)
    result = conn.execute(query)
    return result
```

## Summary

O Maker AI é fundamentalmente:
1. **Um interpretador** de estruturas de dados
2. **Uma camada de abstração** entre usuário e código
3. **Um sistema metadata-driven** onde dados = programa

A genialidade está em:
- Transformar complexidade de código em dados estruturados
- Permitir edição visual de dados
- Interpretar em tempo real sem compilação
- Manter tudo versionado e auditável no SQL
