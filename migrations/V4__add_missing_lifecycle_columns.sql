-- V4: Agregar columnas faltantes para el ciclo de vida de tarjetas

-- Columnas de timestamps del ciclo de vida
ALTER TABLE cards ADD COLUMN IF NOT EXISTS activated_at TIMESTAMP;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS issued_at TIMESTAMP;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP;
ALTER TABLE cards ADD COLUMN IF NOT EXISTS expired_at TIMESTAMP;

-- Columna de razón de cancelación
ALTER TABLE cards ADD COLUMN IF NOT EXISTS cancelled_reason TEXT;

-- Índices para mejorar performance en queries frecuentes
CREATE INDEX IF NOT EXISTS idx_cards_activated_at ON cards(activated_at) WHERE activated_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cards_issued_at ON cards(issued_at) WHERE issued_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_cards_status ON cards(status) WHERE deleted = false;
CREATE INDEX IF NOT EXISTS idx_cards_client_id ON cards(client_id) WHERE deleted = false;

-- Comentarios para documentación
COMMENT ON COLUMN cards.activated_at IS 'Timestamp de cuando se activó la tarjeta';
COMMENT ON COLUMN cards.issued_at IS 'Timestamp de cuando se emitió la tarjeta';
COMMENT ON COLUMN cards.cancelled_at IS 'Timestamp de cuando se canceló la tarjeta';
COMMENT ON COLUMN cards.expired_at IS 'Timestamp de cuando expiró la tarjeta';
COMMENT ON COLUMN cards.cancelled_reason IS 'Razón de cancelación de la tarjeta';
