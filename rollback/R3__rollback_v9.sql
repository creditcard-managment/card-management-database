-- =============================================
-- Rollback: V9
-- Date: 2026-11-02
-- Description: revert PIN failed attempts and transactional outbox
-- =============================================
-- ⚠️ Se pierden los eventos pendientes del outbox y los contadores de intentos de PIN.
-- Revisar antes de ejecutar:
--   SELECT count(*) FROM outbox_events WHERE published_at IS NULL;

DROP TABLE IF EXISTS outbox_events;

ALTER TABLE cards DROP CONSTRAINT IF EXISTS chk_pin_failed_attempts;
ALTER TABLE cards DROP COLUMN IF EXISTS pin_failed_attempts;

-- Quitar el registro de V9 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '9';
