-- =============================================
-- Rollback: V11
-- Date: 2026-11-03
-- Description: revert refund link to the original transaction
-- =============================================
-- ⚠️ Se pierde el vínculo de cada devolución con su transacción original y,
-- con él, el control del total devuelto en payment-processing.

DROP INDEX IF EXISTS idx_transactions_original_transaction_id;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS chk_transactions_original_only_refunds;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS fk_transactions_original;
ALTER TABLE transactions DROP COLUMN IF EXISTS original_transaction_id;

-- Quitar el registro de V11 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '11';
