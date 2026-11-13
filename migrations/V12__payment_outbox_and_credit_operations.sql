-- =============================================
-- Migration: V12
-- Date: 2026-11-13
-- Description: transactional outbox for payment-processing and idempotent credit operations
--              (card-limits) with their journal in payment-processing
-- =============================================

-- 1. Outbox de payment-processing. Es una tabla propia: el relay de card-data lee outbox_events
--    y publicaría también los eventos de pagos con su propio productor.
CREATE TABLE payment_outbox_events (
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

    CONSTRAINT uq_payment_outbox_events_event_id UNIQUE (event_id),
    CONSTRAINT chk_payment_outbox_attempts CHECK (attempts >= 0)
);

CREATE INDEX idx_payment_outbox_pending ON payment_outbox_events (id)
    WHERE published_at IS NULL AND failed_at IS NULL;
CREATE INDEX idx_payment_outbox_published_at ON payment_outbox_events (published_at)
    WHERE published_at IS NOT NULL;
CREATE INDEX idx_payment_outbox_failed ON payment_outbox_events (id)
    WHERE failed_at IS NOT NULL;

COMMENT ON TABLE payment_outbox_events IS
    'Eventos de payment-processing pendientes de publicar en Kafka (transactional outbox). Key = card_id';
COMMENT ON COLUMN payment_outbox_events.failed_at IS
    'Error permanente: no se reintenta. Para reintentarlo: UPDATE payment_outbox_events SET failed_at = NULL WHERE id = ...';

-- 2. card-limits: operaciones de crédito idempotentes por operation_id.
--    Guarda lo que cada operación movió (deltas) para poder deshacerla exactamente.
--    Positivo = consumió, negativo = devolvió.
--    VOIDED: se canceló antes de aplicarse; si la operación llega después, se rechaza.
CREATE TABLE credit_operations (
    operation_id        VARCHAR(64)     PRIMARY KEY,
    credit_limit_id     VARCHAR(36)     NOT NULL,
    operation_type      VARCHAR(30),
    status              VARCHAR(20)     NOT NULL,
    credit_delta        NUMERIC(15,2)   NOT NULL DEFAULT 0,
    daily_delta         NUMERIC(15,2)   NOT NULL DEFAULT 0,
    monthly_delta       NUMERIC(15,2)   NOT NULL DEFAULT 0,
    currency            VARCHAR(3)      NOT NULL,
    applied_on          DATE            NOT NULL,
    description         VARCHAR(255),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at        TIMESTAMP,

    CONSTRAINT fk_credit_operations_credit_limit
        FOREIGN KEY (credit_limit_id) REFERENCES credit_limits (id),
    CONSTRAINT chk_credit_operations_status
        CHECK (status IN ('APPLIED', 'CANCELLED', 'VOIDED')),
    CONSTRAINT chk_credit_operations_type
        CHECK (operation_type IN ('CONSUME_PURCHASE', 'CONSUME_CASH_ADVANCE', 'RESTORE')
            OR (operation_type IS NULL AND status = 'VOIDED'))
);

CREATE INDEX idx_credit_operations_credit_limit ON credit_operations (credit_limit_id);

COMMENT ON TABLE credit_operations IS
    'Operaciones de crédito de card-limits identificadas por el cliente (idempotencia y cancelación)';

-- 3. payment-processing: registro de cada operación de crédito pedida a card-limits.
--    Se inserta PENDING antes de llamar y pasa a CONFIRMED en la misma transacción que guarda el pago.
--    Si esa transacción no confirma, la operación queda PENDING y se cancela en card-limits (COMPENSATED).
--    Sin FK a transactions: la transacción puede no haberse guardado nunca.
CREATE TABLE payment_credit_operations (
    operation_id        VARCHAR(64)     PRIMARY KEY,
    transaction_id      UUID            NOT NULL,
    card_id             VARCHAR(36)     NOT NULL,
    operation_type      VARCHAR(30)     NOT NULL,
    amount              NUMERIC(15,2)   NOT NULL,
    currency            VARCHAR(3)      NOT NULL,
    status              VARCHAR(20)     NOT NULL,
    attempts            INTEGER         NOT NULL DEFAULT 0,
    last_error          VARCHAR(1000),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_payment_credit_operations_status
        CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'COMPENSATED')),
    CONSTRAINT chk_payment_credit_operations_type
        CHECK (operation_type IN ('CONSUME_PURCHASE', 'CONSUME_CASH_ADVANCE', 'RESTORE')),
    CONSTRAINT chk_payment_credit_operations_attempts CHECK (attempts >= 0)
);

CREATE INDEX idx_payment_credit_operations_pending ON payment_credit_operations (created_at)
    WHERE status = 'PENDING';
CREATE INDEX idx_payment_credit_operations_transaction ON payment_credit_operations (transaction_id);

COMMENT ON TABLE payment_credit_operations IS
    'Operaciones de crédito pedidas a card-limits por payment-processing (saga: confirmación o compensación)';
