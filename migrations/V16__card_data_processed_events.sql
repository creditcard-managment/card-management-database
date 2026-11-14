-- =============================================
-- Migration: V16
-- Date: 2026-11-14
-- Description: inbox of events already processed by card-data (idempotent consumers)
-- =============================================

-- card-data consume payment.processing.declined: un rechazo por fraude (responseCode 59) bloquea la
-- tarjeta. La entrega es at-least-once: el eventId se guarda en la misma transacción que el bloqueo,
-- así un mensaje repetido (o reinyectado desde la DLQ) no vuelve a bloquear una tarjeta que ya se desbloqueó.
CREATE TABLE card_data_processed_events (
    event_id        VARCHAR(36)     PRIMARY KEY,
    topic           VARCHAR(100)    NOT NULL,
    processed_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_card_data_processed_events_processed_at ON card_data_processed_events (processed_at);

COMMENT ON TABLE card_data_processed_events IS
    'Eventos de Kafka ya procesados por card-data (deduplicación por eventId)';
