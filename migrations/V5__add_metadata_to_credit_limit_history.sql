-- V5: Agregar columna metadata a credit_limit_history

ALTER TABLE credit_limit_history ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Índice para búsquedas en metadata
CREATE INDEX IF NOT EXISTS idx_credit_limit_history_metadata ON credit_limit_history USING GIN (metadata);

-- Comentario
COMMENT ON COLUMN credit_limit_history.metadata IS 'Información adicional en formato JSON';
