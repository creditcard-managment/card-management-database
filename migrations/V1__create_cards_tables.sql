-- =============================================
-- Cards Module - Complete Schema
-- Version: V1
-- Date: 2025-12-28
-- Description: Tablas, constraints, FKs, e índices del módulo cards
-- =============================================

-- =============================================
-- TABLE: cards
-- Description: Tarjetas de crédito y débito
-- =============================================
CREATE TABLE IF NOT EXISTS cards (
    -- Primary Key
    id VARCHAR(36) PRIMARY KEY,

    -- Client relationship
    client_id VARCHAR(11) NOT NULL,

    -- Card holder information
    holder_first_name VARCHAR(100) NOT NULL,
    holder_last_name VARCHAR(100) NOT NULL,
    holder_document_number VARCHAR(20) NOT NULL,
    holder_email VARCHAR(100) NOT NULL,
    holder_phone_number VARCHAR(20),
    holder_birth_date DATE NOT NULL,
    holder_address VARCHAR(200),

    -- Card classification
    type VARCHAR(20) NOT NULL,
    category VARCHAR(20) NOT NULL,

    -- Card data (encrypted/hashed)
    card_number_encrypted TEXT,
    last_four_digits VARCHAR(4),
    cvv_encrypted TEXT,
    pin_hash VARCHAR(100),
    expiration_month INTEGER,
    expiration_year INTEGER,

    -- Status & metadata
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    block_reason VARCHAR(200),
    blocked_at TIMESTAMP,

    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP,

    -- Constraints
    CONSTRAINT chk_card_type CHECK (type IN (
        'VISA', 'MASTERCARD', 'AMEX', 'CABAL', 'NARANJA'
    )),
    CONSTRAINT chk_card_category CHECK (category IN (
        'CLASSIC', 'GOLD', 'PLATINUM', 'BLACK', 'INFINITE'
    )),
    CONSTRAINT chk_card_status CHECK (status IN (
        'REQUESTED', 'APPROVED', 'ISSUED', 'ACTIVE',
        'BLOCKED', 'BLOCKED_FRAUD', 'EXPIRED', 'CANCELLED'
    )),
    CONSTRAINT chk_expiration_month CHECK (
        expiration_month IS NULL OR (expiration_month BETWEEN 1 AND 12)
    ),
    CONSTRAINT chk_expiration_year CHECK (expiration_year IS NULL OR expiration_year >= 2025),

    CONSTRAINT chk_last_four_digits CHECK (
        last_four_digits IS NULL OR last_four_digits ~ '^[0-9]{4}$'
    )
);

-- =============================================
-- TABLE: card_audit
-- Description: Auditoría de cambios en tarjetas
-- =============================================
CREATE TABLE IF NOT EXISTS card_audit (
    -- Primary Key
    id BIGSERIAL PRIMARY KEY,

    -- Card relationship
    card_id VARCHAR(36) NOT NULL,

    -- Change tracking
    field_name VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,

    -- Audit metadata
    changed_by VARCHAR(100) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    change_reason VARCHAR(200),

    -- Constraints
    CONSTRAINT chk_audit_field_name CHECK (field_name IN (
        'status', 'holder_email', 'holder_phone_number',
        'holder_address', 'block_reason', 'pin_hash'
    ))
);

-- =============================================
-- FOREIGN KEYS
-- =============================================

-- card_audit → cards
ALTER TABLE card_audit
ADD CONSTRAINT fk_audit_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- =============================================
-- INDEXES - cards table
-- =============================================

-- Basic indexes
CREATE INDEX idx_cards_client_id
ON cards(client_id)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_status
ON cards(status)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_last_four
ON cards(last_four_digits)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_type
ON cards(type)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_category
ON cards(category)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_created_at
ON cards(created_at DESC);

CREATE INDEX idx_cards_deleted
ON cards(deleted, deleted_at);

-- Composite indexes
CREATE INDEX idx_cards_client_status
ON cards(client_id, status)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_client_type
ON cards(client_id, type, created_at DESC)
WHERE deleted = FALSE;

CREATE INDEX idx_cards_expiration
ON cards(expiration_year, expiration_month)
WHERE status IN ('ACTIVE', 'ISSUED') AND deleted = FALSE;

-- Partial indexes (performance optimizations)
CREATE INDEX idx_cards_active
ON cards(client_id, created_at DESC)
WHERE status = 'ACTIVE' AND deleted = FALSE;

CREATE INDEX idx_cards_blocked
ON cards(blocked_at DESC)
WHERE status IN ('BLOCKED', 'BLOCKED_FRAUD') AND deleted = FALSE;

CREATE INDEX idx_cards_expiring_soon
ON cards(status, expiration_year, expiration_month)
WHERE deleted = FALSE;

-- Full-text search index
CREATE INDEX idx_cards_holder_fulltext
ON cards USING gin(
    to_tsvector('spanish',
        holder_first_name || ' ' || holder_last_name || ' ' || holder_document_number
    )
)
WHERE deleted = FALSE;

-- =============================================
-- INDEXES - card_audit table
-- =============================================

CREATE INDEX idx_audit_card_id
ON card_audit(card_id, changed_at DESC);

CREATE INDEX idx_audit_changed_at
ON card_audit(changed_at DESC);

CREATE INDEX idx_audit_changed_by
ON card_audit(changed_by, changed_at DESC);

CREATE INDEX idx_audit_field_name
ON card_audit(field_name, changed_at DESC);

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE cards IS 'Tarjetas de crédito y débito del sistema';
COMMENT ON TABLE card_audit IS 'Registro de auditoría de cambios en tarjetas';

-- Columns - cards
COMMENT ON COLUMN cards.id IS 'Identificador único UUID de la tarjeta';
COMMENT ON COLUMN cards.client_id IS 'DNI/CUIL del cliente titular (7-11 dígitos)';
COMMENT ON COLUMN cards.card_number_encrypted IS 'PAN (Primary Account Number) encriptado con AES-256-GCM';
COMMENT ON COLUMN cards.last_four_digits IS 'Últimos 4 dígitos del PAN (para display)';
COMMENT ON COLUMN cards.cvv_encrypted IS 'CVV encriptado con AES-256-GCM';
COMMENT ON COLUMN cards.pin_hash IS 'PIN hasheado con BCrypt (strength 12)';
COMMENT ON COLUMN cards.status IS 'Estado actual de la tarjeta en su ciclo de vida';
COMMENT ON COLUMN cards.deleted IS 'Soft delete flag';

-- Columns - card_audit
COMMENT ON COLUMN card_audit.card_id IS 'FK a la tarjeta auditada';
COMMENT ON COLUMN card_audit.field_name IS 'Nombre del campo modificado';
COMMENT ON COLUMN card_audit.old_value IS 'Valor anterior del campo';
COMMENT ON COLUMN card_audit.new_value IS 'Valor nuevo del campo';
COMMENT ON COLUMN card_audit.changed_by IS 'Usuario o sistema que realizó el cambio';

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_cards_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cards_updated_at
    BEFORE UPDATE ON cards
    FOR EACH ROW
    EXECUTE FUNCTION update_cards_updated_at();

COMMENT ON FUNCTION update_cards_updated_at IS 'Actualiza automáticamente el campo updated_at';

-- =============================================
-- INITIAL DATA VALIDATION
-- =============================================

-- Verificar que las tablas se crearon correctamente
DO $$
DECLARE
    v_cards_count INTEGER;
    v_audit_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_cards_count FROM information_schema.tables
    WHERE table_name = 'cards' AND table_schema = 'public';

    SELECT COUNT(*) INTO v_audit_count FROM information_schema.tables
    WHERE table_name = 'card_audit' AND table_schema = 'public';

    IF v_cards_count = 1 AND v_audit_count = 1 THEN
        RAISE NOTICE '✅ V1 Migration completed successfully!';
        RAISE NOTICE '   - cards table created with % indexes', (
            SELECT COUNT(*) FROM pg_indexes
            WHERE tablename = 'cards'
        );
        RAISE NOTICE '   - card_audit table created with % indexes', (
            SELECT COUNT(*) FROM pg_indexes
            WHERE tablename = 'card_audit'
        );
    ELSE
        RAISE EXCEPTION '❌ Migration failed: Tables not created properly';
    END IF;
END $$;
