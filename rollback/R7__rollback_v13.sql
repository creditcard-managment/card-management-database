-- =============================================
-- Rollback: V13
-- Date: 2026-11-13
-- Description: revert optimistic locking for cards
-- =============================================
-- ⚠️ Requiere volver a una versión de card-data sin @Version en CardEntity
-- (con ddl-auto=validate, la actual no arranca sin la columna).

ALTER TABLE cards DROP COLUMN IF EXISTS version;

-- Quitar el registro de V13 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '13';
