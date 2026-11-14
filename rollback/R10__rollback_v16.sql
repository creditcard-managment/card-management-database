-- =============================================
-- Rollback: V16
-- Date: 2026-11-14
-- Description: revert the card-data processed events inbox
-- =============================================
-- ⚠️ Requiere volver a una versión de card-data sin el consumidor de payment.processing.declined
-- (con ddl-auto=validate, la actual no arranca sin la tabla).

DROP TABLE IF EXISTS card_data_processed_events;

-- Quitar el registro de V16 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '16';
