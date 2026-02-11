-- Visual3 Low-Code Platform - Database Schema
-- SQL Server 2017+
-- Create all metadata tables

USE master;
GO

-- Create database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TESTE5')
BEGIN
    CREATE DATABASE TESTE5;
END
GO

USE TESTE5;
GO

-- ============================================================================
-- 1. FR_SISTEMA - Global System Configuration
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_SISTEMA')
BEGIN
    CREATE TABLE FR_SISTEMA (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome_projeto VARCHAR(255) NOT NULL,
        versao VARCHAR(50),
        descricao TEXT,
        autor VARCHAR(255),
        data_criacao DATETIME DEFAULT GETDATE(),
        data_modificacao DATETIME,
        configuracoes NVARCHAR(MAX),
        status VARCHAR(50) DEFAULT 'DEVELOPMENT'
    );
END
GO

-- ============================================================================
-- 2. FR_USUARIO - Users
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_USUARIO')
BEGIN
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
END
GO

-- ============================================================================
-- 3. FR_CONEXAO - Database Connections
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_CONEXAO')
BEGIN
    CREATE TABLE FR_CONEXAO (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome VARCHAR(255) NOT NULL UNIQUE,
        tipo VARCHAR(50) NOT NULL,
        host VARCHAR(255),
        porta INT,
        database_name VARCHAR(255),
        username VARCHAR(255),
        password_encrypted VARBINARY(500),
        connection_string NVARCHAR(MAX),
        propriedades NVARCHAR(MAX),
        ativo BIT DEFAULT 1,
        padrao BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME
    );
END
GO

-- ============================================================================
-- 4. FR_FORMULARIO - Forms Definition
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_FORMULARIO')
BEGIN
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
        propriedades NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        created_by INT,
        updated_by INT,
        FOREIGN KEY (created_by) REFERENCES FR_USUARIO(id),
        FOREIGN KEY (updated_by) REFERENCES FR_USUARIO(id)
    );
END
GO

-- ============================================================================
-- 5. FR_COMPONENTE - UI Components
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_COMPONENTE')
BEGIN
    CREATE TABLE FR_COMPONENTE (
        id INT PRIMARY KEY IDENTITY(1,1),
        formulario_id INT NOT NULL,
        tipo VARCHAR(50) NOT NULL,
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
        propriedades NVARCHAR(MAX),
        estilo NVARCHAR(MAX),
        validacao NVARCHAR(MAX),
        parent_id INT,
        ordem INT,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        FOREIGN KEY (formulario_id) REFERENCES FR_FORMULARIO(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES FR_COMPONENTE(id)
    );
    
    CREATE INDEX idx_componente_form ON FR_COMPONENTE(formulario_id);
    CREATE INDEX idx_componente_parent ON FR_COMPONENTE(parent_id);
END
GO

-- ============================================================================
-- 6. FR_FLUXO - Flow Logic Header
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_FLUXO')
BEGIN
    CREATE TABLE FR_FLUXO (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome VARCHAR(255) NOT NULL UNIQUE,
        descricao TEXT,
        categoria VARCHAR(100),
        tipo VARCHAR(50),
        parametros_entrada NVARCHAR(MAX),
        parametros_saida NVARCHAR(MAX),
        ativo BIT DEFAULT 1,
        versao INT DEFAULT 1,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        created_by INT,
        updated_by INT,
        FOREIGN KEY (created_by) REFERENCES FR_USUARIO(id),
        FOREIGN KEY (updated_by) REFERENCES FR_USUARIO(id)
    );
    
    CREATE INDEX idx_fluxo_categoria ON FR_FLUXO(categoria);
    CREATE INDEX idx_fluxo_tipo ON FR_FLUXO(tipo);
END
GO

-- ============================================================================
-- 7. FR_FLUXO_ELEMENTO - Flow Nodes/Elements
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_FLUXO_ELEMENTO')
BEGIN
    CREATE TABLE FR_FLUXO_ELEMENTO (
        id INT PRIMARY KEY IDENTITY(1,1),
        fluxo_id INT NOT NULL,
        tipo VARCHAR(50) NOT NULL,
        nome VARCHAR(255),
        posicao_x INT NOT NULL,
        posicao_y INT NOT NULL,
        largura INT DEFAULT 120,
        altura INT DEFAULT 60,
        funcao VARCHAR(255),
        configuracao NVARCHAR(MAX),
        proximo_elemento_id INT,
        proximo_true_id INT,
        proximo_false_id INT,
        proximo_erro_id INT,
        ordem INT,
        cor VARCHAR(20),
        icone VARCHAR(100),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        FOREIGN KEY (fluxo_id) REFERENCES FR_FLUXO(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_fluxo_elem_flow ON FR_FLUXO_ELEMENTO(fluxo_id);
END
GO

-- ============================================================================
-- 8. FR_EVENTO - Event Bindings
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_EVENTO')
BEGIN
    CREATE TABLE FR_EVENTO (
        id INT PRIMARY KEY IDENTITY(1,1),
        componente_id INT,
        formulario_id INT,
        tipo_evento VARCHAR(50) NOT NULL,
        fluxo_id INT NOT NULL,
        ordem INT DEFAULT 1,
        condicao NVARCHAR(MAX),
        parametros NVARCHAR(MAX),
        ativo BIT DEFAULT 1,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (componente_id) REFERENCES FR_COMPONENTE(id) ON DELETE CASCADE,
        FOREIGN KEY (formulario_id) REFERENCES FR_FORMULARIO(id) ON DELETE CASCADE,
        FOREIGN KEY (fluxo_id) REFERENCES FR_FLUXO(id)
    );
    
    CREATE INDEX idx_evento_comp ON FR_EVENTO(componente_id);
    CREATE INDEX idx_evento_form ON FR_EVENTO(formulario_id);
    CREATE INDEX idx_evento_tipo ON FR_EVENTO(tipo_evento);
END
GO

-- ============================================================================
-- 9. FR_RELATORIO - Reports
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_RELATORIO')
BEGIN
    CREATE TABLE FR_RELATORIO (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome VARCHAR(255) NOT NULL UNIQUE,
        titulo VARCHAR(255),
        descricao TEXT,
        tipo VARCHAR(50),
        conexao_id INT,
        query_sql NVARCHAR(MAX),
        fluxo_dados_id INT,
        layout NVARCHAR(MAX),
        parametros NVARCHAR(MAX),
        formato_exportacao VARCHAR(50),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        FOREIGN KEY (conexao_id) REFERENCES FR_CONEXAO(id),
        FOREIGN KEY (fluxo_dados_id) REFERENCES FR_FLUXO(id)
    );
END
GO

-- ============================================================================
-- 10. FR_CONSULTA - Saved Queries
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_CONSULTA')
BEGIN
    CREATE TABLE FR_CONSULTA (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome VARCHAR(255) NOT NULL UNIQUE,
        descricao TEXT,
        conexao_id INT NOT NULL,
        query_sql NVARCHAR(MAX) NOT NULL,
        parametros NVARCHAR(MAX),
        campos_retorno NVARCHAR(MAX),
        cached BIT DEFAULT 0,
        cache_duration_seconds INT,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME,
        FOREIGN KEY (conexao_id) REFERENCES FR_CONEXAO(id)
    );
END
GO

-- ============================================================================
-- 11. FR_HISTORICO - Change History/Versioning
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_HISTORICO')
BEGIN
    CREATE TABLE FR_HISTORICO (
        id INT PRIMARY KEY IDENTITY(1,1),
        object_type VARCHAR(100) NOT NULL,
        object_id INT NOT NULL,
        object_name VARCHAR(255),
        acao VARCHAR(50),
        user_id INT,
        username VARCHAR(255),
        timestamp DATETIME DEFAULT GETDATE(),
        old_data NVARCHAR(MAX),
        new_data NVARCHAR(MAX),
        comentario TEXT
    );
    
    CREATE INDEX idx_historico_obj ON FR_HISTORICO(object_type, object_id);
    CREATE INDEX idx_historico_user ON FR_HISTORICO(user_id);
    CREATE INDEX idx_historico_time ON FR_HISTORICO(timestamp);
END
GO

-- ============================================================================
-- 12. FR_PERMISSAO - Permissions
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_PERMISSAO')
BEGIN
    CREATE TABLE FR_PERMISSAO (
        id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT,
        object_type VARCHAR(100),
        object_id INT,
        permissao VARCHAR(50),
        FOREIGN KEY (user_id) REFERENCES FR_USUARIO(id) ON DELETE CASCADE
    );
    
    CREATE INDEX idx_perm_user ON FR_PERMISSAO(user_id);
END
GO

-- ============================================================================
-- 13. FR_VARIAVEL_GLOBAL - Global Variables
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FR_VARIAVEL_GLOBAL')
BEGIN
    CREATE TABLE FR_VARIAVEL_GLOBAL (
        id INT PRIMARY KEY IDENTITY(1,1),
        nome VARCHAR(255) NOT NULL UNIQUE,
        tipo VARCHAR(50),
        valor NVARCHAR(MAX),
        descricao TEXT,
        escopo VARCHAR(50),
        somente_leitura BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME
    );
END
GO

PRINT 'Schema creation completed successfully.';
GO
