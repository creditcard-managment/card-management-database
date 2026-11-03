-- =============================================
-- Migration: V11
-- Date: 2026-11-03
-- Description: link refunds to the refunded transaction (payment-processing)
-- =============================================

-- Una devolución (transaction_type = 'REFUND') apunta a la transacción que devuelve.
-- payment-processing suma las devoluciones de una transacción para no devolver más que el original.
ALTER TABLE transactions ADD COLUMN original_transaction_id UUID;

ALTER TABLE transactions
    ADD CONSTRAINT fk_transactions_original
        FOREIGN KEY (original_transaction_id)
            REFERENCES transactions(transaction_id)
            ON DELETE RESTRICT;

-- Solo las devoluciones tienen original
ALTER TABLE transactions
    ADD CONSTRAINT chk_transactions_original_only_refunds
        CHECK (original_transaction_id IS NULL OR transaction_type = 'REFUND');

CREATE INDEX idx_transactions_original_transaction_id ON transactions (original_transaction_id)
    WHERE original_transaction_id IS NOT NULL;

COMMENT ON COLUMN transactions.original_transaction_id IS
    'Transacción devuelta (solo para REFUND). Las devoluciones previas a V11 quedan en NULL';
