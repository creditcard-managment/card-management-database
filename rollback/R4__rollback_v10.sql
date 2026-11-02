-- =============================================
-- Rollback: V10
-- Date: 2026-11-02
-- Description: revert outbox permanent failures and unique CREATE transitions
-- =============================================
-- ⚠️ Los eventos marcados como fallidos vuelven a quedar pendientes y el relay los reintentará.
-- Los duplicados de CREATE eliminados por V10 no se restauran.
-- Revisar antes de ejecutar:
--   SELECT count(*) FROM outbox_events WHERE failed_at IS NOT NULL;

DROP INDEX IF EXISTS uq_state_transitions_create;

DROP INDEX IF EXISTS idx_outbox_events_failed;
DROP INDEX IF EXISTS idx_outbox_events_published_at;
DROP INDEX IF EXISTS idx_outbox_events_pending;
ALTER TABLE outbox_events DROP COLUMN IF EXISTS failed_at;
CREATE INDEX idx_outbox_events_pending ON outbox_events (id) WHERE published_at IS NULL;

-- Quitar el registro de V10 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '10';
