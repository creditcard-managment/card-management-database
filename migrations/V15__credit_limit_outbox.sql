-- =============================================
-- Migration: V15
-- Date: 2026-11-14
-- Description: transactional outbox for card-limits (credit-limit.* events)
-- =============================================

-- Outbox propio de card-limits: cada cambio de un límite (asignación, cambio de límites, consumo,
-- liberación) encola su evento en la misma transacción; el relay lo publica después del commit.
-- Misma estructura que outbox_events (card-data) y payment_outbox_events (payment-processing).
CREATE TABLE credit_limit_outbox_events (
    id              BIGSERIAL       PRIMARY KEY,
    event_id        VARCHAR(36)     NOT NULL,
    aggregate_id    VARCHAR(36)     NOT NULL,
    topic           VARCHAR(100)    NOT NULL,
    event_type      VARCHAR(100)    NOT NULL,
    payload         TEXT            NOT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at    TIMESTAMP,
    failed_at       TIMESTAMP,
    attempts        INTEGER         NOT NULL DEFAULT 0,
    last_error      VARCHAR(1000),

    CONSTRAINT uq_credit_limit_outbox_events_event_id UNIQUE (event_id),
    CONSTRAINT chk_credit_limit_outbox_attempts CHECK (attempts >= 0)
);

CREATE INDEX idx_credit_limit_outbox_pending ON credit_limit_outbox_events (id)
    WHERE published_at IS NULL AND failed_at IS NULL;
CREATE INDEX idx_credit_limit_outbox_published_at ON credit_limit_outbox_events (published_at)
    WHERE published_at IS NOT NULL;
CREATE INDEX idx_credit_limit_outbox_failed ON credit_limit_outbox_events (id)
    WHERE failed_at IS NOT NULL;

COMMENT ON TABLE credit_limit_outbox_events IS
    'Eventos de card-limits pendientes de publicar en Kafka (transactional outbox). Key = card_id';
COMMENT ON COLUMN credit_limit_outbox_events.failed_at IS
    'Error permanente: no se reintenta. Para reintentarlo: UPDATE credit_limit_outbox_events SET failed_at = NULL WHERE id = ...';
