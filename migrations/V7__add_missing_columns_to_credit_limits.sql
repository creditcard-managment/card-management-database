-- V7: Agregar columnas faltantes a credit_limits

-- Columnas para límites mensuales
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_amount NUMERIC(15,2);
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_currency VARCHAR(3);
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_consumed NUMERIC(15,2) DEFAULT 0;
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_reset_day INTEGER;
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_reset_month INTEGER;
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS monthly_limit_last_reset TIMESTAMP;

-- Columnas para límites diarios
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS daily_limit_amount NUMERIC(15,2);
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS daily_limit_currency VARCHAR(3);
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS daily_limit_consumed NUMERIC(15,2) DEFAULT 0;
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS daily_limit_last_reset TIMESTAMP;

-- Columnas de auditoría adicionales
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS last_updated_by VARCHAR(100);
ALTER TABLE credit_limits ADD COLUMN IF NOT EXISTS last_update_reason TEXT;

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_credit_limits_card_id ON credit_limits(card_id) WHERE deleted = false;
CREATE INDEX IF NOT EXISTS idx_credit_limits_monthly_reset ON credit_limits(monthly_limit_reset_day, monthly_limit_reset_month);

-- Comentarios
COMMENT ON COLUMN credit_limits.monthly_limit_reset_month IS 'Mes de reseteo del límite mensual (1-12)';
COMMENT ON COLUMN credit_limits.monthly_limit_reset_day IS 'Día de reseteo del límite mensual (1-31)';
COMMENT ON COLUMN credit_limits.daily_limit_last_reset IS 'Última vez que se reseteó el límite diario';
COMMENT ON COLUMN credit_limits.monthly_limit_last_reset IS 'Última vez que se reseteó el límite mensual';


