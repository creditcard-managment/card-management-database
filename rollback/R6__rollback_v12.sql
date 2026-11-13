-- =============================================
-- Rollback: V12
-- Date: 2026-11-13
-- Description: revert payment outbox and idempotent credit operations
-- =============================================
-- ⚠️ Se pierden los eventos de pagos no publicados y las operaciones de crédito pendientes de compensar.
-- Revisar antes de ejecutar:
--   SELECT count(*) FROM payment_outbox_events WHERE published_at IS NULL;
--   SELECT count(*) FROM payment_credit_operations WHERE status = 'PENDING';

DROP TABLE IF EXISTS payment_credit_operations;
DROP TABLE IF EXISTS credit_operations;
DROP TABLE IF EXISTS payment_outbox_events;

-- Quitar el registro de V12 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '12';
