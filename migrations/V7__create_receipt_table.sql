-- =============================================
-- Migration: V7
-- Date: 2026-04-27
-- Description: create table transaction_receipts
-- =============================================

CREATE TABLE transaction_receipts (
    receipt_id      UUID            NOT NULL,
    transaction_id  UUID            NOT NULL,
    receipt_number  VARCHAR(50)     NOT NULL,
    receipt_type    VARCHAR(20)     NOT NULL,
    receipt_data    JSONB           NOT NULL,
    generated_at    TIMESTAMP       NOT NULL DEFAULT NOW(),
    delivered_at    TIMESTAMP,
    delivery_status VARCHAR(20),

    CONSTRAINT pk_transaction_receipts      PRIMARY KEY (receipt_id),
    CONSTRAINT uq_receipts_transaction_id   UNIQUE (transaction_id),
    CONSTRAINT uq_receipts_receipt_number   UNIQUE (receipt_number),
    CONSTRAINT fk_receipts_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_receipts_transaction_id ON transaction_receipts (transaction_id);
CREATE UNIQUE INDEX idx_receipts_receipt_number ON transaction_receipts (receipt_number);

