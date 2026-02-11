# Maker AI - Sistema de Fluxogramas (Action Flow)

## Visão Geral

O editor de fluxogramas é o componente mais sofisticado do Maker AI. É onde a lógica de negócio é definida visualmente e depois interpretada pelo Flow Engine.

## Conceitos Fundamentais

### 1. Flow as Graph
Um fluxo é um **grafo direcionado** onde:
- **Nós (nodes)** = Ações/operações
- **Arestas (edges)** = Sequência de execução
- **Data** = Flui através dos nós via variáveis de contexto

```
     [START]
        ↓
    [SQL Query] → variables.customers
        ↓
    [IF count > 0]
      ↙    ↘
  [Yes]    [No]
    ↓       ↓
 [Process] [Alert]
    ↓       ↓
      [END]
```

### 2. Execution Context
Durante a execução, o fluxo mantém um **contexto** (namespace de variáveis):

```python
context = {
    'input_params': {...},      # Parâmetros de entrada
    'variables': {...},          # Variáveis criadas no fluxo
    'system': {                  # Variáveis do sistema
        'current_user': {...},
        'current_date': '2024-01-01',
        'session_id': '...'
    }
}
```

### 3. Node Execution Model
Cada nó:
1. Recebe o contexto atual
2. Executa sua função
3. Atualiza o contexto (se necessário)
4. Retorna resultado
5. Determina próximo nó

```python
def execute_node(node, context):
    # 1. Get inputs from context
    inputs = resolve_inputs(node.config, context)
    
    # 2. Execute function
    result = node.function(**inputs)
    
    # 3. Update context
    if node.output_var:
        context.variables[node.output_var] = result
    
    # 4. Determine next
    next_node = get_next_node(node, result)
    
    return next_node, context
```

## Tipos de Nós Detalhados

### 1. Control Flow Nodes

#### START Node
```json
{
  "tipo": "START",
  "nome": "Início",
  "icone": "🏁",
  "cor": "#27ae60",
  "configuracao": {
    "parametros_entrada": [
      {"nome": "cliente_id", "tipo": "int"},
      {"nome": "valor", "tipo": "decimal"}
    ]
  },
  "proximo_elemento_id": 2001
}
```
- Ponto de entrada do fluxo
- Define parâmetros esperados
- Sempre único por fluxo

#### END Node
```json
{
  "tipo": "END",
  "nome": "Fim",
  "icone": "🏁",
  "cor": "#c0392b",
  "configuracao": {
    "return_value": "@result",  // Variable to return
    "cleanup": true             // Clean temp vars
  }
}
```
- Ponto de saída do fluxo
- Pode retornar valores
- Pode haver múltiplos END nodes (diferentes caminhos)

#### IF Node (Decision)
```json
{
  "tipo": "IF",
  "nome": "Verificar Estoque",
  "icone": "❓",
  "cor": "#f39c12",
  "configuracao": {
    "condition": "@estoque > 0",  // Expression to evaluate
    "tipo_comparacao": "expression" // or "simple"
  },
  "proximo_true_id": 2002,   // If condition is true
  "proximo_false_id": 2003   // If condition is false
}
```

**Tipos de Comparação**:
1. **Simple**: Campo Operador Valor
   - `field: "estoque", operator: ">", value: 0`
2. **Expression**: Expressão completa
   - `"@estoque > 0 AND @preco < 100"`

#### LOOP Node (Iteration)
```json
{
  "tipo": "LOOP",
  "nome": "Para cada cliente",
  "icone": "🔁",
  "cor": "#9b59b6",
  "configuracao": {
    "tipo_loop": "FOR_EACH",    // or "WHILE", "FOR_RANGE"
    "collection": "@clientes",   // Array to iterate
    "item_var": "cliente",       // Variable name for each item
    "index_var": "index",        // Optional index variable
    "max_iterations": 1000       // Safety limit
  },
  "proximo_elemento_id": 2002,   // Loop body
  "proximo_fim_loop_id": 2005    // After loop completes
}
```

**Loop Types**:
- `FOR_EACH`: Iterate over collection
- `WHILE`: Loop while condition true
- `FOR_RANGE`: Loop N times

### 2. Database Nodes

#### SQL_QUERY Node
```json
{
  "tipo": "SQL_QUERY",
  "nome": "Buscar Clientes",
  "icone": "🗄️",
  "cor": "#3498db",
  "funcao": "executar_sql",
  "configuracao": {
    "connection_id": "default",
    "query": "SELECT * FROM clientes WHERE ativo = @ativo AND cidade = @cidade",
    "params": {
      "ativo": "@input.ativo",
      "cidade": "@input.cidade"
    },
    "output_var": "clientes",
    "timeout": 30,
    "max_rows": 1000
  },
  "proximo_elemento_id": 2002,
  "proximo_erro_id": 9999
}
```

**Query Builder Integration**:
```json
{
  "use_builder": true,
  "builder_config": {
    "tables": ["clientes"],
    "fields": ["id", "nome", "email"],
    "where": [
      {"field": "ativo", "op": "=", "value": "@input.ativo"},
      {"field": "cidade", "op": "=", "value": "@input.cidade"}
    ],
    "order_by": [{"field": "nome", "direction": "ASC"}],
    "limit": 100
  }
}
```

#### SQL_INSERT Node
```json
{
  "tipo": "SQL_INSERT",
  "nome": "Inserir Pedido",
  "icone": "➕",
  "funcao": "executar_sql",
  "configuracao": {
    "connection_id": "default",
    "table": "pedidos",
    "values": {
      "cliente_id": "@cliente.id",
      "data": "@system.current_date",
      "valor_total": "@carrinho.total",
      "status": "NOVO"
    },
    "return_id": true,
    "output_var": "pedido_id"
  },
  "proximo_elemento_id": 2003
}
```

#### SQL_UPDATE Node
```json
{
  "tipo": "SQL_UPDATE",
  "nome": "Atualizar Estoque",
  "icone": "✏️",
  "funcao": "executar_sql",
  "configuracao": {
    "connection_id": "default",
    "table": "produtos",
    "set": {
      "estoque": "@produto.estoque - @quantidade"
    },
    "where": {
      "id": "@produto.id"
    },
    "output_var": "rows_affected"
  },
  "proximo_elemento_id": 2004
}
```

#### TRANSACTION Node
```json
{
  "tipo": "TRANSACTION",
  "nome": "Iniciar Transação",
  "icone": "🔒",
  "cor": "#16a085",
  "funcao": "abrir_transacao",
  "configuracao": {
    "connection_id": "default",
    "isolation_level": "READ_COMMITTED"
  },
  "proximo_elemento_id": 2002
}
```

### 3. UI Nodes

#### OPEN_FORM Node
```json
{
  "tipo": "OPEN_FORM",
  "nome": "Abrir Cadastro Cliente",
  "icone": "🖼️",
  "cor": "#e74c3c",
  "funcao": "abrir_formulario",
  "configuracao": {
    "form_id": 5,           // or "form_name": "frmCliente"
    "mode": "MODAL",        // or "NORMAL", "MAXIMIZED"
    "params": {
      "cliente_id": "@selected_id",
      "readonly": false
    },
    "wait_for_close": true,  // Wait for user to close form
    "output_var": "form_result"
  },
  "proximo_elemento_id": 2003
}
```

#### CLOSE_FORM Node
```json
{
  "tipo": "CLOSE_FORM",
  "nome": "Fechar Formulário",
  "icone": "❌",
  "funcao": "fechar_formulario",
  "configuracao": {
    "form_id": "@current_form_id",  // or current form
    "return_value": "@result",
    "confirm_if_dirty": true  // Ask if unsaved changes
  },
  "proximo_elemento_id": 2004
}
```

#### SHOW_MESSAGE Node
```json
{
  "tipo": "SHOW_MESSAGE",
  "nome": "Alerta",
  "icone": "💬",
  "funcao": "mostrar_mensagem",
  "configuracao": {
    "message": "Operação concluída com sucesso!",
    "type": "SUCCESS",  // INFO, WARNING, ERROR, SUCCESS
    "title": "Sucesso",
    "buttons": ["OK"],  // or ["YES", "NO"], ["OK", "CANCEL"]
    "default_button": "OK",
    "timeout": 5000,    // Auto-close after 5s
    "output_var": "button_clicked"
  },
  "proximo_elemento_id": 2005
}
```

#### UPDATE_FIELD Node
```json
{
  "tipo": "UPDATE_FIELD",
  "nome": "Atualizar Campo Total",
  "icone": "📝",
  "funcao": "atualizar_campo",
  "configuracao": {
    "form_id": "@current_form",
    "component_name": "txtTotal",
    "value": "@calculated_total",
    "trigger_events": false  // Don't trigger OnChange event
  },
  "proximo_elemento_id": 2006
}
```

### 4. Logic & Data Nodes

#### CALCULATE Node
```json
{
  "tipo": "CALCULATE",
  "nome": "Calcular Total",
  "icone": "🧮",
  "funcao": "calcular_expressao",
  "configuracao": {
    "expression": "(@quantidade * @preco) * (1 - @desconto / 100)",
    "variables": {
      "quantidade": "@item.quantidade",
      "preco": "@item.preco_unitario",
      "desconto": "@cliente.desconto_percentual"
    },
    "output_var": "total"
  },
  "proximo_elemento_id": 2007
}
```

#### TRANSFORM Node
```json
{
  "tipo": "TRANSFORM",
  "nome": "Formatar Dados",
  "icone": "🔄",
  "configuracao": {
    "transformations": [
      {
        "input": "@cliente.nome",
        "operation": "UPPER",
        "output": "nome_upper"
      },
      {
        "input": "@cliente.cpf",
        "operation": "MASK",
        "mask": "###.###.###-##",
        "output": "cpf_formatado"
      },
      {
        "input": "@pedido.data",
        "operation": "FORMAT_DATE",
        "format": "DD/MM/YYYY",
        "output": "data_formatada"
      }
    ]
  },
  "proximo_elemento_id": 2008
}
```

#### AGGREGATE Node
```json
{
  "tipo": "AGGREGATE",
  "nome": "Totalizar Vendas",
  "icone": "📊",
  "configuracao": {
    "collection": "@vendas",
    "operations": [
      {"function": "SUM", "field": "valor", "output": "total"},
      {"function": "AVG", "field": "valor", "output": "media"},
      {"function": "COUNT", "field": "*", "output": "quantidade"},
      {"function": "MAX", "field": "valor", "output": "maior"},
      {"function": "MIN", "field": "valor", "output": "menor"}
    ]
  },
  "proximo_elemento_id": 2009
}
```

#### FILTER Node
```json
{
  "tipo": "FILTER",
  "nome": "Filtrar Ativos",
  "icone": "🔍",
  "configuracao": {
    "collection": "@clientes",
    "condition": "@item.ativo == true AND @item.saldo > 0",
    "output_var": "clientes_ativos"
  },
  "proximo_elemento_id": 2010
}
```

#### MAP Node
```json
{
  "tipo": "MAP",
  "nome": "Extrair IDs",
  "icone": "🗺️",
  "configuracao": {
    "collection": "@clientes",
    "expression": "@item.id",
    "output_var": "cliente_ids"
  },
  "proximo_elemento_id": 2011
}
```

### 5. Integration Nodes

#### SEND_EMAIL Node
```json
{
  "tipo": "SEND_EMAIL",
  "nome": "Enviar Confirmação",
  "icone": "📧",
  "funcao": "enviar_email",
  "configuracao": {
    "to": "@cliente.email",
    "cc": ["vendas@empresa.com"],
    "subject": "Pedido #@pedido.id Confirmado",
    "body": "@email_template",
    "body_html": true,
    "attachments": ["@pdf_path"],
    "smtp_config": "default",
    "output_var": "email_sent"
  },
  "proximo_elemento_id": 2012,
  "proximo_erro_id": 9998
}
```

#### CALL_API Node
```json
{
  "tipo": "CALL_API",
  "nome": "Consultar CEP",
  "icone": "🌐",
  "funcao": "chamar_api",
  "configuracao": {
    "url": "https://viacep.com.br/ws/@cep/json/",
    "method": "GET",
    "headers": {
      "Content-Type": "application/json"
    },
    "timeout": 10,
    "retry": 3,
    "output_var": "endereco",
    "error_on_http_error": true
  },
  "proximo_elemento_id": 2013,
  "proximo_erro_id": 9997
}
```

#### HTTP_REQUEST Node
```json
{
  "tipo": "HTTP_REQUEST",
  "nome": "POST to API",
  "icone": "📡",
  "funcao": "chamar_api",
  "configuracao": {
    "url": "https://api.example.com/orders",
    "method": "POST",
    "headers": {
      "Authorization": "Bearer @api_token",
      "Content-Type": "application/json"
    },
    "body": {
      "customer_id": "@cliente.id",
      "items": "@carrinho.items",
      "total": "@carrinho.total"
    },
    "output_var": "api_response"
  },
  "proximo_elemento_id": 2014
}
```

#### EXPORT_PDF Node
```json
{
  "tipo": "EXPORT_PDF",
  "nome": "Gerar Relatório",
  "icone": "📄",
  "funcao": "exportar_pdf",
  "configuracao": {
    "template": "relatorio_vendas",
    "data": "@vendas",
    "output_path": "/reports/@report_name.pdf",
    "orientation": "PORTRAIT",  // or LANDSCAPE
    "page_size": "A4",
    "output_var": "pdf_path"
  },
  "proximo_elemento_id": 2015
}
```

#### EXECUTE_SCRIPT Node
```json
{
  "tipo": "EXECUTE_SCRIPT",
  "nome": "Script Python",
  "icone": "🐍",
  "configuracao": {
    "language": "PYTHON",  // or JAVASCRIPT
    "code": "result = sum([item['valor'] for item in items])",
    "inputs": {
      "items": "@pedido.items"
    },
    "output_var": "result",
    "timeout": 30
  },
  "proximo_elemento_id": 2016
}
```

### 6. Sub-Flow Nodes

#### CALL_FLOW Node
```json
{
  "tipo": "CALL_FLOW",
  "nome": "Validar Cliente",
  "icone": "⚙️",
  "configuracao": {
    "flow_id": 200,  // or "flow_name": "ValidarCliente"
    "params": {
      "cliente_id": "@cliente.id"
    },
    "wait_for_completion": true,
    "output_var": "validacao_result",
    "propagate_context": false  // Share variables with sub-flow
  },
  "proximo_elemento_id": 2017
}
```

### 7. Error Handling Nodes

#### TRY_CATCH Node
```json
{
  "tipo": "TRY_CATCH",
  "nome": "Try Block",
  "icone": "🛡️",
  "configuracao": {
    "try_flow": 2002,      // First node of try block
    "catch_flow": 9001,    // First node of catch block
    "finally_flow": 9100,  // Optional finally block
    "error_var": "error_info"
  }
}
```

#### LOG Node
```json
{
  "tipo": "LOG",
  "nome": "Log Erro",
  "icone": "📝",
  "configuracao": {
    "level": "ERROR",  // DEBUG, INFO, WARNING, ERROR
    "message": "Erro ao processar pedido: @error.message",
    "data": {
      "pedido_id": "@pedido.id",
      "user_id": "@system.current_user.id",
      "stack_trace": "@error.stack"
    },
    "save_to_database": true
  },
  "proximo_elemento_id": 2018
}
```

## Canvas Features

### 1. Grid System
```javascript
const gridConfig = {
  enabled: true,
  size: 10,         // 10px grid
  snap: true,       // Snap to grid
  visible: true,    // Show grid lines
  color: '#2d2d30'  // Grid line color
};
```

### 2. Zoom & Pan
```javascript
const viewport = {
  zoom: 1.0,        // 100%
  min_zoom: 0.25,   // 25%
  max_zoom: 2.0,    // 200%
  pan_x: 0,
  pan_y: 0
};

// Zoom controls
function zoomIn() { viewport.zoom *= 1.1; }
function zoomOut() { viewport.zoom /= 1.1; }
function fitToScreen() { /* calculate zoom to fit all nodes */ }
```

### 3. Node Positioning
```javascript
// Absolute positioning
node.x = 100;
node.y = 200;

// Auto-layout (optional)
function autoLayout(nodes) {
  // Dagre or similar algorithm
  // Arrange nodes in optimal layout
}
```

### 4. Connection Routing
```javascript
// Smart routing to avoid overlaps
function routeConnection(nodeA, nodeB, allNodes) {
  // Calculate path that avoids other nodes
  // Use A* or similar pathfinding
  return pathPoints;
}
```

### 5. Selection & Multi-Select
```javascript
const selection = {
  nodes: [2001, 2002],  // Selected node IDs
  connections: [5001]    // Selected connection IDs
};

// Rectangle selection
function selectInRectangle(x1, y1, x2, y2) {
  // Find all nodes within rectangle
}
```

### 6. Copy/Paste
```javascript
function copyNodes(nodeIds) {
  clipboard = nodes.filter(n => nodeIds.includes(n.id));
}

function pasteNodes() {
  // Create new nodes with new IDs
  // Offset position slightly
  // Recreate connections between pasted nodes
}
```

### 7. Undo/Redo
```javascript
const history = {
  past: [],
  present: currentState,
  future: []
};

function undo() {
  if (history.past.length > 0) {
    history.future.unshift(history.present);
    history.present = history.past.pop();
  }
}
```

## Validation & Testing

### Flow Validation
```python
def validate_flow(flow):
    errors = []
    
    # Check for START node
    if not has_start_node(flow):
        errors.append("Flow must have a START node")
    
    # Check for orphan nodes
    orphans = find_orphan_nodes(flow)
    if orphans:
        errors.append(f"Orphan nodes found: {orphans}")
    
    # Check for unreachable nodes
    unreachable = find_unreachable_nodes(flow)
    if unreachable:
        errors.append(f"Unreachable nodes: {unreachable}")
    
    # Check for infinite loops
    if has_infinite_loop(flow):
        errors.append("Potential infinite loop detected")
    
    return errors
```

### Flow Testing
```python
def test_flow(flow_id, test_cases):
    results = []
    for test_case in test_cases:
        result = execute_flow(
            flow_id,
            test_case.input_params
        )
        passed = (result == test_case.expected_output)
        results.append({
            'test': test_case.name,
            'passed': passed,
            'output': result
        })
    return results
```

## Performance Optimization

### 1. Node Caching
```python
# Cache expensive operations
@lru_cache(maxsize=100)
def get_node_config(node_id):
    return db.query("SELECT * FROM FR_FLUXO_ELEMENTO WHERE id = ?", [node_id])
```

### 2. Lazy Loading
```javascript
// Load only visible nodes on canvas
function loadVisibleNodes(viewport) {
  const visible = nodes.filter(n => 
    isInViewport(n, viewport)
  );
  renderNodes(visible);
}
```

### 3. Connection Pooling
```python
# Reuse database connections
conn_pool = ConnectionPool(max_size=10)
```

## Summary

O sistema de fluxogramas do Maker AI:
1. **Representa lógica visualmente** como grafos
2. **Executa nós sequencialmente** com contexto compartilhado
3. **Suporta centenas de tipos de nós** para diferentes operações
4. **Permite composição** via sub-flows
5. **Integra com UI** através de event bindings
6. **É altamente visual e interativo** no editor
7. **Pode ser validado e testado** antes de usar em produção
