-- Visual3 - Sample Data for Testing

USE TESTE5;
GO

-- ============================================================================
-- Insert default system configuration
-- ============================================================================
IF NOT EXISTS (SELECT * FROM FR_SISTEMA WHERE id = 1)
BEGIN
    INSERT INTO FR_SISTEMA (nome_projeto, versao, descricao, configuracoes, status) 
    VALUES (
        'Visual3 Platform',
        '1.0.0',
        'Low-Code Development Platform',
        '{"theme":"dark","language":"pt-BR","date_format":"DD/MM/YYYY","timeout":3600}',
        'DEVELOPMENT'
    );
    PRINT 'System configuration inserted.';
END
GO

-- ============================================================================
-- Insert default admin user
-- ============================================================================
IF NOT EXISTS (SELECT * FROM FR_USUARIO WHERE username = 'admin')
BEGIN
    -- Password hash for 'admin123' (bcrypt)
    INSERT INTO FR_USUARIO (username, password_hash, email, nome_completo, ativo, admin)
    VALUES (
        'admin',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lWq5n/MBdoiW',
        'admin@visual3.local',
        'Administrator',
        1,
        1
    );
    PRINT 'Admin user inserted.';
END
GO

-- ============================================================================
-- Insert default database connection (self-reference)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM FR_CONEXAO WHERE nome = 'default')
BEGIN
    INSERT INTO FR_CONEXAO (nome, tipo, host, porta, database_name, username, ativo, padrao)
    VALUES (
        'default',
        'SQL_SERVER',
        'sqlserver',
        1433,
        'TESTE5',
        'sa',
        1,
        1
    );
    PRINT 'Default connection inserted.';
END
GO

-- ============================================================================
-- Insert sample form
-- ============================================================================
IF NOT EXISTS (SELECT * FROM FR_FORMULARIO WHERE nome = 'frmExemplo')
BEGIN
    DECLARE @form_id INT;
    
    INSERT INTO FR_FORMULARIO (nome, titulo, largura, altura, propriedades)
    VALUES (
        'frmExemplo',
        'Formulário de Exemplo',
        800,
        600,
        '{"icon":"form.png","show_toolbar":true,"show_statusbar":true}'
    );
    
    SET @form_id = SCOPE_IDENTITY();
    
    -- Insert sample components
    INSERT INTO FR_COMPONENTE (formulario_id, tipo, nome, label, posicao_x, posicao_y, largura, altura, propriedades, estilo)
    VALUES 
        (@form_id, 'LABEL', 'lblTitulo', 'Exemplo de Formulário', 20, 20, 760, 30, '{}', '{"font_size":18,"font_weight":"bold"}'),
        (@form_id, 'TEXTBOX', 'txtNome', 'Nome:', 20, 70, 300, 30, '{"maxlength":255}', '{}'),
        (@form_id, 'TEXTBOX', 'txtEmail', 'E-mail:', 20, 120, 300, 30, '{"type":"email"}', '{}'),
        (@form_id, 'BUTTON', 'btnSalvar', 'Salvar', 20, 500, 100, 35, '{"icon":"save.png"}', '{"background_color":"#2ecc71","text_color":"#ffffff"}'),
        (@form_id, 'BUTTON', 'btnCancelar', 'Cancelar', 130, 500, 100, 35, '{}', '{"background_color":"#95a5a6","text_color":"#ffffff"}');
    
    PRINT 'Sample form and components inserted.';
END
GO

-- ============================================================================
-- Insert sample flow
-- ============================================================================
IF NOT EXISTS (SELECT * FROM FR_FLUXO WHERE nome = 'FlowExemplo')
BEGIN
    DECLARE @flow_id INT;
    
    INSERT INTO FR_FLUXO (nome, descricao, categoria, parametros_entrada, parametros_saida)
    VALUES (
        'FlowExemplo',
        'Fluxo de exemplo simples',
        'EXAMPLE',
        '[{"nome":"mensagem","tipo":"string","obrigatorio":true}]',
        '[{"nome":"resultado","tipo":"bool"}]'
    );
    
    SET @flow_id = SCOPE_IDENTITY();
    
    -- Insert flow elements
    DECLARE @start_id INT, @show_msg_id INT, @end_id INT;
    
    INSERT INTO FR_FLUXO_ELEMENTO (fluxo_id, tipo, nome, posicao_x, posicao_y, configuracao, ordem, cor)
    VALUES (@flow_id, 'START', 'Início', 100, 50, '{}', 1, '#27ae60');
    SET @start_id = SCOPE_IDENTITY();
    
    INSERT INTO FR_FLUXO_ELEMENTO (fluxo_id, tipo, nome, posicao_x, posicao_y, funcao, configuracao, ordem, cor)
    VALUES (@flow_id, 'SHOW_MESSAGE', 'Mostrar Mensagem', 100, 150, 'mostrar_mensagem', '{"message":"@mensagem","type":"info"}', 2, '#3498db');
    SET @show_msg_id = SCOPE_IDENTITY();
    
    INSERT INTO FR_FLUXO_ELEMENTO (fluxo_id, tipo, nome, posicao_x, posicao_y, configuracao, ordem, cor)
    VALUES (@flow_id, 'END', 'Fim', 100, 250, '{"return_value":true}', 3, '#c0392b');
    SET @end_id = SCOPE_IDENTITY();
    
    -- Connect the nodes
    UPDATE FR_FLUXO_ELEMENTO SET proximo_elemento_id = @show_msg_id WHERE id = @start_id;
    UPDATE FR_FLUXO_ELEMENTO SET proximo_elemento_id = @end_id WHERE id = @show_msg_id;
    
    PRINT 'Sample flow inserted.';
END
GO

PRINT 'Seed data insertion completed successfully.';
GO
