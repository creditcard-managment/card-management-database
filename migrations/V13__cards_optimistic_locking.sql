-- =============================================
-- Migration: V13
-- Date: 2026-11-13
-- Description: optimistic locking for cards (CardEntity @Version)
-- =============================================

-- Cada UPDATE de card-data exige la versión que leyó y la incrementa. Si otra transacción
-- cambió la tarjeta mientras tanto (por ejemplo, el job de vencimiento y un PUT /status a la vez),
-- el guardado falla y la API responde 409 en lugar de pisar el cambio.
-- Las filas existentes arrancan en 0.
ALTER TABLE cards ADD COLUMN version BIGINT NOT NULL DEFAULT 0;

COMMENT ON COLUMN cards.version IS 'Versión para control de concurrencia optimista (JPA @Version)';
