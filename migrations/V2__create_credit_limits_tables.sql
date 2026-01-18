-- V2: Crear tabla credit_limits (basado en CreditLimitEntity)
CREATE TABLE credit_limits (
    -- Identificadores
    id VARCHAR(36) PRIMARY KEY,
    card_id VARCHAR(36) NOT NULL UNIQUE,
    -- Límites principales
    purchase_limit_amount NUMERIC(15,2) NOT NULL,
    purchase_limit_currency VARCHAR(3) NOT NULL,
    cash_advance_limit_amount NUMERIC(15,2) NOT NULL,
    cash_advance_limit_currency VARCHAR(3) NOT NULL,
    -- Crédito actual (consumido y disponible)
    consumed_credit_amount NUMERIC(15,2) NOT NULL,
    consumed_credit_currency VARCHAR(3) NOT NULL,
    available_credit_amount NUMERIC(15,2) NOT NULL,
    available_credit_currency VARCHAR(3) NOT NULL,
    -- Límite diario
    daily_limit_amount NUMERIC(15,2) NOT NULL,
    daily_limit_currency VARCHAR(3) NOT NULL,
    daily_limit_consumed NUMERIC(15,2) NOT NULL,
    daily_limit_reset_date DATE NOT NULL,
    -- Límite mensual
    monthly_limit_amount NUMERIC(15,2) NOT NULL,
    monthly_limit_currency VARCHAR(3) NOT NULL,
    monthly_limit_consumed NUMERIC(15,2) NOT NULL,
    monthly_limit_reset_year INTEGER NOT NULL,
    monthly_limit_reset_month INTEGER NOT NULL,
    -- Auditoría
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT false,
    deleted_at TIMESTAMP
);
-- Índices
CREATE INDEX idx_credit_limit_card_id ON credit_limits(card_id);
CREATE INDEX idx_credit_limit_deleted ON credit_limits(deleted);
CREATE INDEX idx_credit_limits_monthly_reset ON credit_limits(monthly_limit_reset_year, monthly_limit_reset_month);
CREATE INDEX idx_credit_limits_daily_reset ON credit_limits(daily_limit_reset_date);
-- Foreign keys
ALTER TABLE credit_limits ADD CONSTRAINT fk_credit_limits_card
    FOREIGN KEY (card_id) REFERENCES cards(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Constraints
ALTER TABLE credit_limits ADD CONSTRAINT chk_monthly_reset_month
    CHECK (monthly_limit_reset_month BETWEEN 1 AND 12);
ALTER TABLE credit_limits ADD CONSTRAINT chk_consumed_not_negative
    CHECK (consumed_credit_amount >= 0 AND daily_limit_consumed >= 0 AND monthly_limit_consumed >= 0);
-- Comentarios
COMMENT ON TABLE credit_limits IS 'Límites de crédito por tarjeta';
COMMENT ON COLUMN credit_limits.purchase_limit_amount IS 'Límite total para compras';
COMMENT ON COLUMN credit_limits.cash_advance_limit_amount IS 'Límite para adelantos en efectivo';
COMMENT ON COLUMN credit_limits.consumed_credit_amount IS 'Crédito total consumido';
COMMENT ON COLUMN credit_limits.available_credit_amount IS 'Crédito total disponible';
COMMENT ON COLUMN credit_limits.daily_limit_amount IS 'Límite diario';
COMMENT ON COLUMN credit_limits.daily_limit_reset_date IS 'Fecha de reseteo del límite diario';
COMMENT ON COLUMN credit_limits.monthly_limit_amount IS 'Límite mensual';
COMMENT ON COLUMN credit_limits.monthly_limit_reset_year IS 'Año de reseteo del límite mensual';
COMMENT ON COLUMN credit_limits.monthly_limit_reset_month IS 'Mes de reseteo del límite mensual (1-12)';
