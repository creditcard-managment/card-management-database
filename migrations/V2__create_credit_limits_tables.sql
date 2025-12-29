-- =============================================
-- Credit Limits Module - Complete Schema
-- Version: V2
-- Date: 2025-12-28
-- Description: Tablas, constraints, FKs, e índices del módulo credit limits
-- =============================================

-- =============================================
-- TABLE: credit_limits
-- Description: Límites de crédito de las tarjetas
-- =============================================
CREATE TABLE IF NOT EXISTS credit_limits (
    -- Primary Key
    id VARCHAR(36) PRIMARY KEY,

    -- Card relationship (unique - one limit per card)
    card_id VARCHAR(36) NOT NULL UNIQUE,

    -- Purchase limit
    purchase_limit_amount DECIMAL(15,2) NOT NULL,
    purchase_limit_currency VARCHAR(3) NOT NULL DEFAULT 'ARS',

    -- Cash advance limit
    cash_advance_limit_amount DECIMAL(15,2) NOT NULL,
    cash_advance_limit_currency VARCHAR(3) NOT NULL DEFAULT 'ARS',

    -- Credit consumption
    consumed_credit_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    consumed_credit_currency VARCHAR(3) NOT NULL DEFAULT 'ARS',

    -- Available credit (calculated)
    available_credit_amount DECIMAL(15,2) NOT NULL,
    available_credit_currency VARCHAR(3) NOT NULL DEFAULT 'ARS',

    -- Daily limit
    daily_limit_amount DECIMAL(15,2),
    daily_limit_currency VARCHAR(3) DEFAULT 'ARS',
    daily_limit_consumed DECIMAL(15,2) DEFAULT 0.00,
    daily_limit_reset_date DATE,

    -- Monthly limit
    monthly_limit_amount DECIMAL(15,2),
    monthly_limit_currency VARCHAR(3) DEFAULT 'ARS',
    monthly_limit_consumed DECIMAL(15,2) DEFAULT 0.00,
    monthly_limit_reset_date DATE,

    -- Metadata
    assigned_by VARCHAR(100) NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP,

    -- Constraints
    CONSTRAINT chk_purchase_limit_positive CHECK (purchase_limit_amount > 0),
    CONSTRAINT chk_cash_advance_positive CHECK (cash_advance_limit_amount >= 0),
    CONSTRAINT chk_cash_advance_within_purchase CHECK (
        cash_advance_limit_amount <= purchase_limit_amount
    ),
    CONSTRAINT chk_consumed_not_negative CHECK (consumed_credit_amount >= 0),
    CONSTRAINT chk_consumed_within_limit CHECK (
        consumed_credit_amount <= purchase_limit_amount
    ),
    CONSTRAINT chk_available_not_negative CHECK (available_credit_amount >= 0),
    CONSTRAINT chk_available_calculated CHECK (
        available_credit_amount = purchase_limit_amount - consumed_credit_amount
    ),
    CONSTRAINT chk_daily_limit_positive CHECK (
        daily_limit_amount IS NULL OR daily_limit_amount > 0
    ),
    CONSTRAINT chk_daily_consumed_not_negative CHECK (
        daily_limit_consumed >= 0
    ),
    CONSTRAINT chk_daily_consumed_within_limit CHECK (
        daily_limit_amount IS NULL OR daily_limit_consumed <= daily_limit_amount
    ),
    CONSTRAINT chk_monthly_limit_positive CHECK (
        monthly_limit_amount IS NULL OR monthly_limit_amount > 0
    ),
    CONSTRAINT chk_monthly_consumed_not_negative CHECK (
        monthly_limit_consumed >= 0
    ),
    CONSTRAINT chk_monthly_consumed_within_limit CHECK (
        monthly_limit_amount IS NULL OR monthly_limit_consumed <= monthly_limit_amount
    ),
    CONSTRAINT chk_currency_valid CHECK (
        purchase_limit_currency IN ('ARS', 'USD', 'EUR', 'BRL') AND
        cash_advance_limit_currency IN ('ARS', 'USD', 'EUR', 'BRL') AND
        consumed_credit_currency IN ('ARS', 'USD', 'EUR', 'BRL') AND
        available_credit_currency IN ('ARS', 'USD', 'EUR', 'BRL')
    )
);

-- =============================================
-- TABLE: credit_limit_history
-- Description: Historial de cambios en límites de crédito
-- =============================================
CREATE TABLE IF NOT EXISTS credit_limit_history (
    -- Primary Key
    id BIGSERIAL PRIMARY KEY,

    -- Credit limit relationship
    credit_limit_id VARCHAR(36) NOT NULL,

    -- Change details
    limit_type VARCHAR(20) NOT NULL,
    action VARCHAR(20) NOT NULL,

    -- Values
    previous_value_amount DECIMAL(15,2),
    previous_value_currency VARCHAR(3),
    new_value_amount DECIMAL(15,2),
    new_value_currency VARCHAR(3),
    difference_amount DECIMAL(15,2),
    difference_currency VARCHAR(3),

    -- Metadata
    reason VARCHAR(500),
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Result
    successful BOOLEAN NOT NULL DEFAULT TRUE,
    error_message VARCHAR(500),

    -- Constraints
    CONSTRAINT chk_limit_type CHECK (limit_type IN (
        'PURCHASE', 'CASH_ADVANCE', 'DAILY', 'MONTHLY'
    )),
    CONSTRAINT chk_action CHECK (action IN (
        'ASSIGNED', 'INCREASED', 'DECREASED', 'UPDATED', 'CONSUMED', 'RELEASED'
    )),
    CONSTRAINT chk_successful_has_values CHECK (
        NOT successful OR (
            successful AND
            new_value_amount IS NOT NULL AND
            new_value_currency IS NOT NULL
        )
    ),
    CONSTRAINT chk_failed_has_error CHECK (
        successful OR (NOT successful AND error_message IS NOT NULL)
    )
);

-- =============================================
-- FOREIGN KEYS
-- =============================================

-- credit_limits → cards
ALTER TABLE credit_limits
ADD CONSTRAINT fk_credit_limit_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- credit_limit_history → credit_limits
ALTER TABLE credit_limit_history
ADD CONSTRAINT fk_history_credit_limit
FOREIGN KEY (credit_limit_id) REFERENCES credit_limits(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- =============================================
-- INDEXES - credit_limits table
-- =============================================

-- Basic indexes
CREATE UNIQUE INDEX idx_credit_limit_card_id
ON credit_limits(card_id)
WHERE deleted = FALSE;

CREATE INDEX idx_credit_limits_created_at
ON credit_limits(created_at DESC);

CREATE INDEX idx_credit_limits_deleted
ON credit_limits(deleted, deleted_at);

-- Partial indexes for queries
CREATE INDEX idx_credit_limits_low_available
ON credit_limits(card_id, available_credit_amount)
WHERE available_credit_amount < (purchase_limit_amount * 0.2)
  AND deleted = FALSE;

CREATE INDEX idx_credit_limits_high_consumption
ON credit_limits(card_id, consumed_credit_amount)
WHERE consumed_credit_amount > (purchase_limit_amount * 0.8)
  AND deleted = FALSE;

CREATE INDEX idx_credit_limits_daily_reset
ON credit_limits(daily_limit_reset_date)
WHERE daily_limit_amount IS NOT NULL
  AND daily_limit_consumed > 0
  AND deleted = FALSE;

CREATE INDEX idx_credit_limits_monthly_reset
ON credit_limits(monthly_limit_reset_date)
WHERE monthly_limit_amount IS NOT NULL
  AND monthly_limit_consumed > 0
  AND deleted = FALSE;

-- =============================================
-- INDEXES - credit_limit_history table
-- =============================================

CREATE INDEX idx_history_credit_limit_id
ON credit_limit_history(credit_limit_id, changed_at DESC);

CREATE INDEX idx_history_changed_at
ON credit_limit_history(changed_at DESC);

CREATE INDEX idx_history_limit_type
ON credit_limit_history(limit_type, changed_at DESC);

CREATE INDEX idx_history_action
ON credit_limit_history(action, changed_at DESC);

CREATE INDEX idx_history_changed_by
ON credit_limit_history(changed_by, changed_at DESC);

CREATE INDEX idx_history_successful
ON credit_limit_history(successful, changed_at DESC);

-- Composite index for common queries
CREATE INDEX idx_history_limit_type_action
ON credit_limit_history(credit_limit_id, limit_type, action, changed_at DESC)
WHERE successful = TRUE;

-- Unique constraint to prevent duplicate entries
CREATE UNIQUE INDEX idx_history_unique_change
ON credit_limit_history(
    credit_limit_id,
    limit_type,
    action,
    changed_at,
    new_value_amount
)
WHERE successful = TRUE;

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE credit_limits IS 'Límites de crédito asignados a las tarjetas';
COMMENT ON TABLE credit_limit_history IS 'Historial de cambios en límites de crédito';

-- Columns - credit_limits
COMMENT ON COLUMN credit_limits.id IS 'Identificador único UUID del límite';
COMMENT ON COLUMN credit_limits.card_id IS 'FK a la tarjeta (relación 1:1)';
COMMENT ON COLUMN credit_limits.purchase_limit_amount IS 'Límite total de compras';
COMMENT ON COLUMN credit_limits.cash_advance_limit_amount IS 'Límite para adelantos en efectivo';
COMMENT ON COLUMN credit_limits.consumed_credit_amount IS 'Crédito actualmente consumido';
COMMENT ON COLUMN credit_limits.available_credit_amount IS 'Crédito disponible (calculado automáticamente)';
COMMENT ON COLUMN credit_limits.daily_limit_amount IS 'Límite diario opcional';
COMMENT ON COLUMN credit_limits.monthly_limit_amount IS 'Límite mensual opcional';
COMMENT ON COLUMN credit_limits.daily_limit_reset_date IS 'Fecha del próximo reset diario';
COMMENT ON COLUMN credit_limits.monthly_limit_reset_date IS 'Fecha del próximo reset mensual';

-- Columns - credit_limit_history
COMMENT ON COLUMN credit_limit_history.credit_limit_id IS 'FK al límite modificado';
COMMENT ON COLUMN credit_limit_history.limit_type IS 'Tipo de límite (PURCHASE, CASH_ADVANCE, DAILY, MONTHLY)';
COMMENT ON COLUMN credit_limit_history.action IS 'Acción realizada (ASSIGNED, INCREASED, DECREASED, etc.)';
COMMENT ON COLUMN credit_limit_history.previous_value_amount IS 'Valor anterior del límite';
COMMENT ON COLUMN credit_limit_history.new_value_amount IS 'Valor nuevo del límite';
COMMENT ON COLUMN credit_limit_history.difference_amount IS 'Diferencia entre nuevo y anterior';

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_credit_limits_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_credit_limits_updated_at
    BEFORE UPDATE ON credit_limits
    FOR EACH ROW
    EXECUTE FUNCTION update_credit_limits_updated_at();

-- Trigger para calcular available_credit automáticamente
CREATE OR REPLACE FUNCTION calculate_available_credit()
RETURNS TRIGGER AS $$
BEGIN
    NEW.available_credit_amount = NEW.purchase_limit_amount - NEW.consumed_credit_amount;
    NEW.available_credit_currency = NEW.purchase_limit_currency;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_available_credit
    BEFORE INSERT OR UPDATE OF purchase_limit_amount, consumed_credit_amount
    ON credit_limits
    FOR EACH ROW
    EXECUTE FUNCTION calculate_available_credit();

-- Trigger para resetear límites diarios
CREATE OR REPLACE FUNCTION reset_daily_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.daily_limit_reset_date IS NOT NULL
       AND NEW.daily_limit_reset_date <= CURRENT_DATE THEN
        NEW.daily_limit_consumed = 0.00;
        NEW.daily_limit_reset_date = CURRENT_DATE + INTERVAL '1 day';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_reset_daily_limit
    BEFORE UPDATE ON credit_limits
    FOR EACH ROW
    EXECUTE FUNCTION reset_daily_limit();

-- Trigger para resetear límites mensuales
CREATE OR REPLACE FUNCTION reset_monthly_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.monthly_limit_reset_date IS NOT NULL
       AND NEW.monthly_limit_reset_date <= CURRENT_DATE THEN
        NEW.monthly_limit_consumed = 0.00;
        NEW.monthly_limit_reset_date = DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_reset_monthly_limit
    BEFORE UPDATE ON credit_limits
    FOR EACH ROW
    EXECUTE FUNCTION reset_monthly_limit();

COMMENT ON FUNCTION update_credit_limits_updated_at IS 'Actualiza automáticamente updated_at';
COMMENT ON FUNCTION calculate_available_credit IS 'Calcula automáticamente el crédito disponible';
COMMENT ON FUNCTION reset_daily_limit IS 'Resetea el límite diario cuando corresponde';
COMMENT ON FUNCTION reset_monthly_limit IS 'Resetea el límite mensual cuando corresponde';

-- =============================================
-- INITIAL DATA VALIDATION
-- =============================================

DO $$
DECLARE
    v_limits_count INTEGER;
    v_history_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_limits_count FROM information_schema.tables
    WHERE table_name = 'credit_limits' AND table_schema = 'public';

    SELECT COUNT(*) INTO v_history_count FROM information_schema.tables
    WHERE table_name = 'credit_limit_history' AND table_schema = 'public';

    IF v_limits_count = 1 AND v_history_count = 1 THEN
        RAISE NOTICE '✅ V2 Migration completed successfully!';
        RAISE NOTICE '   - credit_limits table created with % indexes', (
            SELECT COUNT(*) FROM pg_indexes
            WHERE tablename = 'credit_limits'
        );
        RAISE NOTICE '   - credit_limit_history table created with % indexes', (
            SELECT COUNT(*) FROM pg_indexes
            WHERE tablename = 'credit_limit_history'
        );
        RAISE NOTICE '   - % triggers created', 4;
    ELSE
        RAISE EXCEPTION '❌ Migration failed: Tables not created properly';
    END IF;
END $$;
