-- V3: Crear tablas de transiciones de estado e historial de límites

-- Tabla de transiciones de estado (card-lifecycle)
CREATE TABLE state_transitions (
    id BIGSERIAL PRIMARY KEY,
    card_id VARCHAR(36) NOT NULL,
    from_state VARCHAR(20),
    to_state VARCHAR(20) NOT NULL,
    event VARCHAR(50) NOT NULL,
    reason TEXT,
    performed_by VARCHAR(100) NOT NULL,
    transitioned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    successful BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    metadata TEXT
);

-- Índices para state_transitions
CREATE INDEX idx_state_transitions_card_id ON state_transitions(card_id, transitioned_at DESC);
CREATE INDEX idx_state_transitions_event ON state_transitions(event, transitioned_at DESC);
CREATE INDEX idx_state_transitions_successful ON state_transitions(successful, transitioned_at DESC);
CREATE INDEX idx_state_transitions_performed_by ON state_transitions(performed_by, transitioned_at DESC);
CREATE INDEX idx_state_transitions_metadata ON state_transitions (metadata DESC);

-- Foreign key
ALTER TABLE state_transitions ADD CONSTRAINT fk_state_transitions_card
    FOREIGN KEY (card_id) REFERENCES cards(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- Tabla de historial de cambios de límites (card-limits)
CREATE TABLE credit_limit_history (
    id BIGSERIAL PRIMARY KEY,
    credit_limit_id VARCHAR(36) NOT NULL,
    limit_type VARCHAR(20) NOT NULL,
    action VARCHAR(20) NOT NULL,
    previous_value_amount NUMERIC(15,2),
    previous_value_currency VARCHAR(3),
    new_value_amount NUMERIC(15,2),
    new_value_currency VARCHAR(3),
    difference_amount NUMERIC(15,2),
    difference_currency VARCHAR(3),
    reason VARCHAR(500),
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    successful BOOLEAN NOT NULL DEFAULT true,
    error_message VARCHAR(500),
    metadata TEXT  -- ✅ TEXT en lugar de JSONB
);

-- Índices para credit_limit_history
CREATE INDEX idx_history_credit_limit_id ON credit_limit_history(credit_limit_id, changed_at DESC);
CREATE INDEX idx_history_limit_type ON credit_limit_history(limit_type, changed_at DESC);
CREATE INDEX idx_history_action ON credit_limit_history(action, changed_at DESC);
CREATE INDEX idx_history_changed_by ON credit_limit_history(changed_by, changed_at DESC);
CREATE INDEX idx_history_changed_at ON credit_limit_history(changed_at DESC);
CREATE INDEX idx_history_successful ON credit_limit_history(successful, changed_at DESC);

CREATE INDEX idx_history_limit_type_action
    ON credit_limit_history(credit_limit_id, limit_type, action, changed_at DESC)
    WHERE successful = true;

CREATE UNIQUE INDEX idx_history_unique_change
    ON credit_limit_history(credit_limit_id, limit_type, action, changed_at, new_value_amount)
    WHERE successful = true;

-- Foreign key
ALTER TABLE credit_limit_history ADD CONSTRAINT fk_history_credit_limit
    FOREIGN KEY (credit_limit_id) REFERENCES credit_limits(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- Constraints
ALTER TABLE credit_limit_history ADD CONSTRAINT chk_limit_type
    CHECK (limit_type IN ('PURCHASE', 'CASH_ADVANCE', 'DAILY', 'MONTHLY'));

ALTER TABLE credit_limit_history ADD CONSTRAINT chk_action
    CHECK (action IN ('ASSIGNED', 'INCREASED', 'DECREASED', 'UPDATED', 'CONSUMED', 'RELEASED'));

ALTER TABLE credit_limit_history ADD CONSTRAINT chk_successful_has_values
    CHECK (successful = false OR (successful = true AND new_value_amount IS NOT NULL AND new_value_currency IS NOT NULL));

ALTER TABLE credit_limit_history ADD CONSTRAINT chk_failed_has_error
    CHECK (successful = true OR (successful = false AND error_message IS NOT NULL));

-- Auditoría adicional
CREATE TABLE card_audit (
    id BIGSERIAL PRIMARY KEY,
    card_id VARCHAR(36) NOT NULL,
    entity_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);

CREATE INDEX idx_card_audit_card_id ON card_audit(card_id, changed_at DESC);
CREATE INDEX idx_card_audit_entity ON card_audit(entity_name, action, changed_at DESC);

-- Comentarios
COMMENT ON TABLE state_transitions IS 'Historial de transiciones de estado de tarjetas';
COMMENT ON TABLE credit_limit_history IS 'Historial de cambios en límites de crédito';
COMMENT ON TABLE card_audit IS 'Auditoría completa de todas las operaciones';
