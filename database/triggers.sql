-- Visual3 - Database Triggers for Auto-Versioning
-- These triggers automatically log changes to FR_HISTORICO

USE TESTE5;
GO

-- ============================================================================
-- Trigger: FR_FORMULARIO versioning
-- ============================================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_formulario_versioning')
    DROP TRIGGER trg_formulario_versioning;
GO

CREATE TRIGGER trg_formulario_versioning
ON FR_FORMULARIO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FR_HISTORICO (
        object_type,
        object_id,
        object_name,
        acao,
        username,
        timestamp,
        old_data,
        new_data
    )
    SELECT 
        'FORM',
        d.id,
        d.nome,
        'UPDATE',
        SYSTEM_USER,
        GETDATE(),
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;
GO

-- ============================================================================
-- Trigger: FR_FLUXO versioning
-- ============================================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_fluxo_versioning')
    DROP TRIGGER trg_fluxo_versioning;
GO

CREATE TRIGGER trg_fluxo_versioning
ON FR_FLUXO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FR_HISTORICO (
        object_type,
        object_id,
        object_name,
        acao,
        username,
        timestamp,
        old_data,
        new_data
    )
    SELECT 
        'FLOW',
        d.id,
        d.nome,
        'UPDATE',
        SYSTEM_USER,
        GETDATE(),
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;
GO

-- ============================================================================
-- Trigger: FR_COMPONENTE versioning
-- ============================================================================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_componente_versioning')
    DROP TRIGGER trg_componente_versioning;
GO

CREATE TRIGGER trg_componente_versioning
ON FR_COMPONENTE
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FR_HISTORICO (
        object_type,
        object_id,
        object_name,
        acao,
        username,
        timestamp,
        old_data,
        new_data
    )
    SELECT 
        'COMPONENT',
        d.id,
        d.nome,
        'UPDATE',
        SYSTEM_USER,
        GETDATE(),
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM deleted d
    INNER JOIN inserted i ON d.id = i.id;
END;
GO

PRINT 'Triggers created successfully.';
GO
