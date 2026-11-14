-- =============================================
-- Rollback: V14
-- Date: 2026-11-13
-- Description: revert state_transitions.event_id
-- =============================================
-- ⚠️ Requiere volver a una versión de card-lifecycle que no consuma los eventos de cambio de estado
-- (con ddl-auto=validate, la actual no arranca sin la columna).

DROP INDEX IF EXISTS uq_state_transitions_event_id;
ALTER TABLE state_transitions DROP COLUMN IF EXISTS event_id;

-- Quitar el registro de V14 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '14';
