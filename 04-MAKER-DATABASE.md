# Maker AI - Database Schema

## Schema Overview

O banco de dados do Maker AI é o repositório de TODOS os metadados do sistema. Cada tabela representa um aspecto diferente da aplicação.

## Core Tables Structure

### 1. FR_SISTEMA (Global System Config)
```sql
CREATE TABLE FR_SISTEMA (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome_projeto VARCHAR(255) NOT NULL,
    versao VARCHAR(50),
    descricao TEXT,
    autor VARCHAR(255),
    data_criacao DATETIME DEFAULT GETDATE(),
    data_modificacao DATETIME,
    configuracoes NVARCHAR(MAX),  -- JSON
    status VARCHAR(50)  -- 'DEVELOPMENT', 'PRODUCTION', etc.
);
```

**Exemplo de dados**:
```json
{
  "id": 1,
  "nome_projeto": "Sistema ERP",
  "versao": "1.0.0",
  "configuracoes": {
    "theme": "dark",
    "language": "pt-BR",
    "date_format": "DD/MM/YYYY",
    "decimal_separator": ",",
    "timeout": 3600
  }
}
```

### 2. FR_FORMULARIO (Forms Definition)
```sql
CREATE TABLE FR_FORMULARIO (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    titulo VARCHAR(255),
    largura INT DEFAULT 800,
    altura INT DEFAULT 600,
    posicao_x INT,
    posicao_y INT,
    redimensionavel BIT DEFAULT 1,
    minimizavel BIT DEFAULT 1,
    maximizavel BIT DEFAULT 1,
    modal BIT DEFAULT 0,
    cor_fundo VARCHAR(20),
    imagem_fundo VARCHAR(500),
    propriedades NVARCHAR(MAX),  -- JSON
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    created_by INT,
    updated_by INT
);
```

**Propriedades JSON**:
```json
{
  "show_toolbar": true,
  "show_statusbar": true,
  "icon": "form.png",
  "close_on_escape": true,
  "center_on_open": true,
  "load_flow_id": 1001,  -- Flow to execute on form load
  "close_flow_id": 1002  -- Flow to execute on form close
}
```

### 3. FR_COMPONENTE (UI Components)
```sql
CREATE TABLE FR_COMPONENTE (
    id INT PRIMARY KEY IDENTITY(1,1),
    formulario_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,  -- 'BUTTON', 'TEXTBOX', 'GRID', etc.
    nome VARCHAR(255) NOT NULL,
    label VARCHAR(255),
    posicao_x INT NOT NULL,
    posicao_y INT NOT NULL,
    largura INT NOT NULL,
    altura INT NOT NULL,
    tab_order INT,
    visivel BIT DEFAULT 1,
    habilitado BIT DEFAULT 1,
    obrigatorio BIT DEFAULT 0,
    somente_leitura BIT DEFAULT 0,
    propriedades NVARCHAR(MAX),  -- JSON
    estilo NVARCHAR(MAX),  -- JSON (CSS-like)
    validacao NVARCHAR(MAX),  -- JSON
    parent_id INT,  -- For nested components (panels, tabs)
    ordem INT,  -- Display order
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    
    FOREIGN KEY (formulario_id) REFERENCES FR_FORMULARIO(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES FR_COMPONENTE(id)
);

CREATE INDEX idx_componente_form ON FR_COMPONENTE(formulario_id);
CREATE INDEX idx_componente_parent ON FR_COMPONENTE(parent_id);
```

**Component Types**:
- `TEXTBOX`: Single-line text input
- `TEXTAREA`: Multi-line text input
- `BUTTON`: Action button
- `CHECKBOX`: Boolean checkbox
- `RADIOBUTTON`: Radio button (grouped)
- `COMBOBOX`: Dropdown select
- `LISTBOX`: List selection
- `GRID`: Data grid/table
- `DATEPICKER`: Date selection
- `TIMEPICKER`: Time selection
- `LABEL`: Static text
- `IMAGE`: Image display
- `PANEL`: Container
- `TABCONTROL`: Tab container
- `CHART`: Data visualization
- `TREEVIEW`: Hierarchical tree

**Example Component**:
```json
{
  "id": 1001,
  "formulario_id": 5,
  "tipo": "BUTTON",
  "nome": "btnSave",
  "label": "Salvar",
  "posicao_x": 100,
  "posicao_y": 400,
  "largura": 100,
  "altura": 35,
  "propriedades": {
    "icon": "save.png",
    "shortcut": "Ctrl+S",
    "default_button": true
  },
  "estilo": {
    "background_color": "#2ecc71",
    "text_color": "#ffffff",
    "font_family": "Roboto",
    "font_size": 14,
    "border_radius": 4
  }
}
```

### 4. FR_FLUXO (Flow Logic Header)
```sql
CREATE TABLE FR_FLUXO (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    categoria VARCHAR(100),  -- 'BUSINESS', 'UI', 'INTEGRATION', etc.
    tipo VARCHAR(50),  -- 'ACTION', 'FUNCTION', 'SCHEDULED', etc.
    parametros_entrada NVARCHAR(MAX),  -- JSON array
    parametros_saida NVARCHAR(MAX),  -- JSON array
    ativo BIT DEFAULT 1,
    versao INT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    created_by INT,
    updated_by INT
);

CREATE INDEX idx_fluxo_categoria ON FR_FLUXO(categoria);
CREATE INDEX idx_fluxo_tipo ON FR_FLUXO(tipo);
```

**Parâmetros exemplo**:
```json
{
  "parametros_entrada": [
    {"nome": "cliente_id", "tipo": "int", "obrigatorio": true},
    {"nome": "valor", "tipo": "decimal", "obrigatorio": true}
  ],
  "parametros_saida": [
    {"nome": "sucesso", "tipo": "bool"},
    {"nome": "mensagem", "tipo": "string"}
  ]
}
```

### 5. FR_FLUXO_ELEMENTO (Flow Nodes/Elements)
```sql
CREATE TABLE FR_FLUXO_ELEMENTO (
    id INT PRIMARY KEY IDENTITY(1,1),
    fluxo_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,  -- 'START', 'END', 'SQL', 'IF', 'LOOP', etc.
    nome VARCHAR(255),
    posicao_x INT NOT NULL,
    posicao_y INT NOT NULL,
    largura INT DEFAULT 120,
    altura INT DEFAULT 60,
    funcao VARCHAR(255),  -- Function to execute
    configuracao NVARCHAR(MAX),  -- JSON with function params
    proximo_elemento_id INT,  -- For sequential flow
    proximo_true_id INT,  -- For decision nodes (true branch)
    proximo_false_id INT,  -- For decision nodes (false branch)
    proximo_erro_id INT,  -- Error handler
    ordem INT,
    cor VARCHAR(20),  -- Node color for categorization
    icone VARCHAR(100),  -- Icon identifier
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    
    FOREIGN KEY (fluxo_id) REFERENCES FR_FLUXO(id) ON DELETE CASCADE
);

CREATE INDEX idx_fluxo_elem_flow ON FR_FLUXO_ELEMENTO(fluxo_id);
```

**Node Types**:
- `START`: Flow entry point
- `END`: Flow exit point
- `SQL_QUERY`: Execute SELECT
- `SQL_INSERT`: Insert data
- `SQL_UPDATE`: Update data
- `SQL_DELETE`: Delete data
- `IF`: Decision/branching
- `LOOP`: Iteration
- `FUNCTION`: Call custom function
- `OPEN_FORM`: Open UI form
- `CLOSE_FORM`: Close UI form
- `SHOW_MESSAGE`: Display message
- `SEND_EMAIL`: Email notification
- `CALL_API`: External API call
- `TRANSFORM`: Data transformation
- `AGGREGATE`: Data aggregation
- `EXPORT`: Export data (PDF, Excel, etc.)

**Example Node Configuration**:
```json
{
  "id": 2001,
  "fluxo_id": 100,
  "tipo": "SQL_QUERY",
  "nome": "Buscar Cliente",
  "posicao_x": 200,
  "posicao_y": 150,
  "funcao": "executar_sql",
  "configuracao": {
    "connection_id": "default",
    "query": "SELECT * FROM clientes WHERE id = @cliente_id",
    "params": ["@cliente_id"],
    "output_var": "cliente",
    "timeout": 30
  },
  "proximo_elemento_id": 2002,
  "proximo_erro_id": 2099
}
```

### 6. FR_EVENTO (Event Bindings)
```sql
CREATE TABLE FR_EVENTO (
    id INT PRIMARY KEY IDENTITY(1,1),
    componente_id INT,  -- NULL for form-level events
    formulario_id INT,
    tipo_evento VARCHAR(50) NOT NULL,  -- 'OnClick', 'OnChange', 'OnLoad', etc.
    fluxo_id INT NOT NULL,
    ordem INT DEFAULT 1,  -- Multiple events can be bound, execute in order
    condicao NVARCHAR(MAX),  -- Optional condition (expression)
    parametros NVARCHAR(MAX),  -- JSON with params to pass to flow
    ativo BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (componente_id) REFERENCES FR_COMPONENTE(id) ON DELETE CASCADE,
    FOREIGN KEY (formulario_id) REFERENCES FR_FORMULARIO(id) ON DELETE CASCADE,
    FOREIGN KEY (fluxo_id) REFERENCES FR_FLUXO(id)
);

CREATE INDEX idx_evento_comp ON FR_EVENTO(componente_id);
CREATE INDEX idx_evento_form ON FR_EVENTO(formulario_id);
CREATE INDEX idx_evento_tipo ON FR_EVENTO(tipo_evento);
```

**Event Types**:
- `OnLoad`: Form/component loaded
- `OnUnload`: Form/component unloaded
- `OnClick`: Mouse click
- `OnDoubleClick`: Mouse double-click
- `OnChange`: Value changed
- `OnFocus`: Component received focus
- `OnBlur`: Component lost focus
- `OnKeyPress`: Key pressed
- `OnKeyUp`: Key released
- `OnValidate`: Validation triggered
- `OnBeforeSave`: Before data save
- `OnAfterSave`: After data save
- `OnTimer`: Scheduled/periodic

**Example Event**:
```json
{
  "id": 3001,
  "componente_id": 1001,  -- btnSave
  "formulario_id": 5,
  "tipo_evento": "OnClick",
  "fluxo_id": 100,  -- Save flow
  "parametros": {
    "validate_before": true,
    "show_confirmation": false
  }
}
```

### 7. FR_CONEXAO (Database Connections)
```sql
CREATE TABLE FR_CONEXAO (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,  -- 'SQL_SERVER', 'MYSQL', 'POSTGRES', etc.
    host VARCHAR(255),
    porta INT,
    database_name VARCHAR(255),
    username VARCHAR(255),
    password_encrypted VARBINARY(500),  -- Encrypted
    connection_string NVARCHAR(MAX),  -- Optional full connection string
    propriedades NVARCHAR(MAX),  -- JSON
    ativo BIT DEFAULT 1,
    padrao BIT DEFAULT 0,  -- Is default connection
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME
);
```

### 8. FR_RELATORIO (Reports)
```sql
CREATE TABLE FR_RELATORIO (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    titulo VARCHAR(255),
    descricao TEXT,
    tipo VARCHAR(50),  -- 'LIST', 'DETAIL', 'CHART', 'DASHBOARD', etc.
    conexao_id INT,
    query_sql NVARCHAR(MAX),
    fluxo_dados_id INT,  -- Alternative: flow that provides data
    layout NVARCHAR(MAX),  -- JSON with layout definition
    parametros NVARCHAR(MAX),  -- JSON
    formato_exportacao VARCHAR(50),  -- 'PDF', 'EXCEL', 'HTML', etc.
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    
    FOREIGN KEY (conexao_id) REFERENCES FR_CONEXAO(id),
    FOREIGN KEY (fluxo_dados_id) REFERENCES FR_FLUXO(id)
);
```

### 9. FR_CONSULTA (Saved Queries)
```sql
CREATE TABLE FR_CONSULTA (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    conexao_id INT NOT NULL,
    query_sql NVARCHAR(MAX) NOT NULL,
    parametros NVARCHAR(MAX),  -- JSON array
    campos_retorno NVARCHAR(MAX),  -- JSON array describing return fields
    cached BIT DEFAULT 0,
    cache_duration_seconds INT,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME,
    
    FOREIGN KEY (conexao_id) REFERENCES FR_CONEXAO(id)
);
```

### 10. FR_HISTORICO (Change History/Versioning)
```sql
CREATE TABLE FR_HISTORICO (
    id INT PRIMARY KEY IDENTITY(1,1),
    object_type VARCHAR(100) NOT NULL,  -- 'FORM', 'FLOW', 'COMPONENT', etc.
    object_id INT NOT NULL,
    object_name VARCHAR(255),
    acao VARCHAR(50),  -- 'CREATE', 'UPDATE', 'DELETE', 'RESTORE'
    user_id INT,
    username VARCHAR(255),
    timestamp DATETIME DEFAULT GETDATE(),
    old_data NVARCHAR(MAX),  -- JSON snapshot before change
    new_data NVARCHAR(MAX),  -- JSON snapshot after change
    comentario TEXT
);

CREATE INDEX idx_historico_obj ON FR_HISTORICO(object_type, object_id);
CREATE INDEX idx_historico_user ON FR_HISTORICO(user_id);
CREATE INDEX idx_historico_time ON FR_HISTORICO(timestamp);
```

### 11. FR_USUARIO (Users)
```sql
CREATE TABLE FR_USUARIO (
    id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(500) NOT NULL,
    email VARCHAR(255),
    nome_completo VARCHAR(255),
    ativo BIT DEFAULT 1,
    admin BIT DEFAULT 0,
    ultimo_login DATETIME,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME
);
```

### 12. FR_PERMISSAO (Permissions)
```sql
CREATE TABLE FR_PERMISSAO (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT,
    object_type VARCHAR(100),
    object_id INT,
    permissao VARCHAR(50),  -- 'READ', 'WRITE', 'DELETE', 'EXECUTE'
    
    FOREIGN KEY (user_id) REFERENCES FR_USUARIO(id) ON DELETE CASCADE
);

CREATE INDEX idx_perm_user ON FR_PERMISSAO(user_id);
```

### 13. FR_VARIAVEL_GLOBAL (Global Variables)
```sql
CREATE TABLE FR_VARIAVEL_GLOBAL (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(255) NOT NULL UNIQUE,
    tipo VARCHAR(50),  -- 'STRING', 'INT', 'DECIMAL', 'DATE', 'BOOL'
    valor NVARCHAR(MAX),
    descricao TEXT,
    escopo VARCHAR(50),  -- 'SYSTEM', 'SESSION', 'USER'
    somente_leitura BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME
);
```

## Triggers for Auto-Versioning

### Form Versioning Trigger
```sql
CREATE TRIGGER trg_formulario_versioning
ON FR_FORMULARIO
AFTER UPDATE
AS
BEGIN
    INSERT INTO FR_HISTORICO (
        object_type,
        object_id,
        object_name,
        acao,
        timestamp,
        old_data,
        new_data
    )
    SELECT 
        'FORM',
        d.id,
        d.nome,
        'UPDATE',
        GETDATE(),
        (SELECT * FROM deleted d2 WHERE d2.id = d.id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT * FROM inserted i2 WHERE i2.id = i.id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;
```

### Flow Versioning Trigger
```sql
CREATE TRIGGER trg_fluxo_versioning
ON FR_FLUXO
AFTER UPDATE
AS
BEGIN
    INSERT INTO FR_HISTORICO (
        object_type,
        object_id,
        object_name,
        acao,
        timestamp,
        old_data,
        new_data
    )
    SELECT 
        'FLOW',
        d.id,
        d.nome,
        'UPDATE',
        GETDATE(),
        (SELECT * FROM deleted d2 WHERE d2.id = d.id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT * FROM inserted i2 WHERE i2.id = i.id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;
```

## Views for Easy Querying

### Complete Form with Components
```sql
CREATE VIEW vw_formulario_completo AS
SELECT 
    f.id AS form_id,
    f.nome AS form_name,
    f.titulo AS form_title,
    c.id AS component_id,
    c.tipo AS component_type,
    c.nome AS component_name,
    c.label AS component_label,
    c.propriedades AS component_props,
    e.id AS event_id,
    e.tipo_evento AS event_type,
    fl.id AS flow_id,
    fl.nome AS flow_name
FROM FR_FORMULARIO f
LEFT JOIN FR_COMPONENTE c ON f.id = c.formulario_id
LEFT JOIN FR_EVENTO e ON c.id = e.componente_id
LEFT JOIN FR_FLUXO fl ON e.fluxo_id = fl.id;
```

### Complete Flow with Nodes
```sql
CREATE VIEW vw_fluxo_completo AS
SELECT 
    f.id AS flow_id,
    f.nome AS flow_name,
    f.categoria,
    fe.id AS element_id,
    fe.tipo AS element_type,
    fe.nome AS element_name,
    fe.posicao_x,
    fe.posicao_y,
    fe.funcao,
    fe.configuracao
FROM FR_FLUXO f
INNER JOIN FR_FLUXO_ELEMENTO fe ON f.id = fe.fluxo_id;
```

## Sample Data

### Sample System Config
```sql
INSERT INTO FR_SISTEMA (nome_projeto, versao, configuracoes) VALUES (
    'Sistema ERP',
    '1.0.0',
    '{"theme":"dark","language":"pt-BR","timeout":3600}'
);
```

### Sample Form
```sql
INSERT INTO FR_FORMULARIO (nome, titulo, largura, altura, propriedades) VALUES (
    'frmClientes',
    'Cadastro de Clientes',
    800,
    600,
    '{"icon":"users.png","show_toolbar":true}'
);

-- Components for the form
INSERT INTO FR_COMPONENTE (formulario_id, tipo, nome, label, posicao_x, posicao_y, largura, altura, propriedades) VALUES
(1, 'TEXTBOX', 'txtNome', 'Nome:', 20, 20, 300, 30, '{"maxlength":255}'),
(1, 'TEXTBOX', 'txtEmail', 'E-mail:', 20, 60, 300, 30, '{"type":"email"}'),
(1, 'BUTTON', 'btnSalvar', 'Salvar', 20, 400, 100, 35, '{"icon":"save.png","shortcut":"Ctrl+S"}');
```

### Sample Flow
```sql
INSERT INTO FR_FLUXO (nome, descricao, categoria) VALUES (
    'OnSaveCliente',
    'Salva dados do cliente no banco',
    'BUSINESS'
);

-- Flow elements
INSERT INTO FR_FLUXO_ELEMENTO (fluxo_id, tipo, nome, posicao_x, posicao_y, funcao, configuracao, proximo_elemento_id) VALUES
(1, 'START', 'Início', 100, 50, NULL, '{}', 2),
(1, 'SQL_INSERT', 'Inserir Cliente', 100, 150, 'executar_sql', '{"query":"INSERT INTO clientes (nome, email) VALUES (@nome, @email)","params":["@nome","@email"]}', 3),
(1, 'SHOW_MESSAGE', 'Mensagem Sucesso', 100, 250, 'mostrar_mensagem', '{"message":"Cliente salvo com sucesso!","type":"success"}', 4),
(1, 'END', 'Fim', 100, 350, NULL, '{}', NULL);
```

### Sample Event Binding
```sql
INSERT INTO FR_EVENTO (componente_id, formulario_id, tipo_evento, fluxo_id, parametros) VALUES (
    3,  -- btnSalvar component_id
    1,  -- frmClientes form_id
    'OnClick',
    1,  -- OnSaveCliente flow_id
    '{"validate_before":true}'
);
```

## Database Creation Script

### Complete initialization
```sql
-- Create Database
CREATE DATABASE TESTE5;
GO

USE TESTE5;
GO

-- Create all tables (in correct order due to foreign keys)
-- [All CREATE TABLE statements from above]

-- Create triggers
-- [All CREATE TRIGGER statements from above]

-- Create views
-- [All CREATE VIEW statements from above]

-- Insert sample data (optional)
-- [All INSERT statements from above]
```

## Backup & Restore

### Backup Strategy
```sql
-- Full backup
BACKUP DATABASE TESTE5 
TO DISK = '/var/opt/mssql/backup/teste5_full.bak'
WITH FORMAT, NAME = 'Full Backup of TESTE5';

-- Differential backup
BACKUP DATABASE TESTE5 
TO DISK = '/var/opt/mssql/backup/teste5_diff.bak'
WITH DIFFERENTIAL, NAME = 'Differential Backup of TESTE5';
```

### Restore
```sql
RESTORE DATABASE TESTE5
FROM DISK = '/var/opt/mssql/backup/teste5_full.bak'
WITH REPLACE;
```

## Summary

O banco de dados do Maker AI:
1. **Armazena TUDO como dados** - não há código executável
2. **Usa JSON extensivamente** para propriedades flexíveis
3. **Mantém histórico completo** via triggers automáticos
4. **Suporta versionamento** com snapshots de estados
5. **É altamente normalizado** com referências claras
6. **Permite queries eficientes** via índices estratégicos
7. **É extensível** - novas propriedades podem ser adicionadas ao JSON sem alterar schema
