-- =============================================
-- Migration: V10
-- Date: 2026-11-02
-- Description: outbox permanent failures and idempotent CREATE transitions
-- =============================================

-- 1. Outbox: eventos con error permanente (no se reintentan y quedan para revisión)
ALTER TABLE outbox_events ADD COLUMN failed_at TIMESTAMP;

-- El relay solo lee pendientes que no fallaron de forma permanente
DROP INDEX IF EXISTS idx_outbox_events_pending;
CREATE INDEX idx_outbox_events_pending ON outbox_events (id)
    WHERE published_at IS NULL AND failed_at IS NULL;

-- Limpieza de publicados por antigüedad y consulta de fallidos
CREATE INDEX idx_outbox_events_published_at ON outbox_events (published_at)
    WHERE published_at IS NOT NULL;
CREATE INDEX idx_outbox_events_failed ON outbox_events (id)
    WHERE failed_at IS NOT NULL;

COMMENT ON COLUMN outbox_events.failed_at IS
    'Error permanente: el evento no se reintenta. Para reintentarlo: UPDATE outbox_events SET failed_at = NULL WHERE id = ...';

-- 2. state_transitions: una sola transición CREATE por tarjeta (consumo idempotente de card.created)
-- Elimina duplicados previos conservando la primera transición registrada
DELETE FROM state_transitions a
    USING state_transitions b
    WHERE a.event = 'CREATE'
      AND b.event = 'CREATE'
      AND a.card_id = b.card_id
      AND a.id > b.id;

CREATE UNIQUE INDEX uq_state_transitions_create ON state_transitions (card_id)
    WHERE event = 'CREATE';
