-- =============================================
-- Migration: V9
-- Date: 2026-11-02
-- Description: PIN failed attempts on cards and transactional outbox for card-data
-- =============================================

-- 1. Intentos fallidos de PIN consecutivos (card-data bloquea la tarjeta al llegar a 3)
ALTER TABLE cards ADD COLUMN pin_failed_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE cards ADD CONSTRAINT chk_pin_failed_attempts CHECK (pin_failed_attempts >= 0);

-- 2. Outbox de eventos de integración (OutboxRelay de card-data los publica en Kafka)
CREATE TABLE outbox_events (
    id              BIGSERIAL       PRIMARY KEY,
    event_id        VARCHAR(36)     NOT NULL,
    aggregate_id    VARCHAR(36)     NOT NULL,
    topic           VARCHAR(100)    NOT NULL,
    event_type      VARCHAR(100)    NOT NULL,
    payload         TEXT            NOT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at    TIMESTAMP,
    attempts        INTEGER         NOT NULL DEFAULT 0,
    last_error      VARCHAR(1000),

    CONSTRAINT uq_outbox_events_event_id UNIQUE (event_id),
    CONSTRAINT chk_outbox_attempts CHECK (attempts >= 0)
);

-- Pendientes en orden de inserción (lo que lee el relay)
CREATE INDEX idx_outbox_events_pending ON outbox_events (id) WHERE published_at IS NULL;
CREATE INDEX idx_outbox_events_aggregate ON outbox_events (aggregate_id);

COMMENT ON TABLE outbox_events IS 'Eventos pendientes de publicar en Kafka (transactional outbox)';
COMMENT ON COLUMN outbox_events.payload IS 'Evento serializado en JSON, se publica sin modificaciones';
COMMENT ON COLUMN cards.pin_failed_attempts IS 'Intentos fallidos de PIN consecutivos';
