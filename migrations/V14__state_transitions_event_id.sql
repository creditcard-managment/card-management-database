-- =============================================
-- Migration: V14
-- Date: 2026-11-13
-- Description: state_transitions.event_id for idempotent history from card events
-- =============================================

-- card-lifecycle registra el historial de transiciones exitosas consumiendo los eventos card.*
-- (at-least-once): el eventId del mensaje identifica cada fila y evita registrarla dos veces.
-- Las transiciones fallidas (y las anteriores a este cambio) no tienen evento: queda NULL.
ALTER TABLE state_transitions ADD COLUMN event_id VARCHAR(36);

-- Las transiciones CREATE ya guardaban el eventId de card.created en metadata ({"eventId":"…"})
UPDATE state_transitions
   SET event_id = metadata::json ->> 'eventId'
 WHERE event_id IS NULL
   AND metadata LIKE '{"eventId":"%"}';

-- Varios NULL permitidos; un mismo evento, una sola fila
CREATE UNIQUE INDEX uq_state_transitions_event_id ON state_transitions (event_id);

COMMENT ON COLUMN state_transitions.event_id IS 'eventId del evento card.* que originó la transición (NULL en fallidas)';
