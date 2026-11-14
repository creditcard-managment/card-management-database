-- =============================================
-- Rollback: V15
-- Date: 2026-11-14
-- Description: revert the card-limits outbox
-- =============================================
-- ⚠️ Se pierden los eventos pendientes de publicar. Requiere volver a una versión de card-limits
-- sin outbox (con ddl-auto=validate, la actual no arranca sin la tabla).

DROP TABLE IF EXISTS credit_limit_outbox_events;

-- Quitar el registro de V15 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '15';
