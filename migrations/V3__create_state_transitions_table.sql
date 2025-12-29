-- =============================================
-- Card Lifecycle Module - Complete Schema
-- Version: V3
-- Date: 2025-12-28
-- Description: Tablas, constraints, FKs, e índices del módulo lifecycle
-- =============================================

-- =============================================
-- TABLE: state_transitions
-- Description: Auditoría de transiciones de estado en el ciclo de vida de tarjetas
-- =============================================
CREATE TABLE IF NOT EXISTS state_transitions (
    -- Primary Key
    id BIGSERIAL PRIMARY KEY,

    -- Card relationship
    card_id VARCHAR(36) NOT NULL,

    -- Transition details
    from_state VARCHAR(20),
    to_state VARCHAR(20),
    event VARCHAR(20) NOT NULL,

    -- Context
    reason VARCHAR(500),
    performed_by VARCHAR(100),
    transitioned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Metadata (JSON)
    metadata TEXT,

    -- Result
    successful BOOLEAN NOT NULL DEFAULT TRUE,
    error_message VARCHAR(1000),

    -- Constraints
    CONSTRAINT chk_event CHECK (event IN (
        'APPROVE', 'REJECT', 'ISSUE', 'ACTIVATE',
        'BLOCK', 'BLOCK_FRAUD', 'UNBLOCK',
        'EXPIRE', 'CANCEL', 'FORCE_CANCEL'
    )),
    CONSTRAINT chk_from_state CHECK (from_state IS NULL OR from_state IN (
        'REQUESTED', 'APPROVED', 'REJECTED', 'ISSUED',
        'ACTIVE', 'BLOCKED', 'BLOCKED_FRAUD',
        'EXPIRED', 'CANCELLED'
    )),
    CONSTRAINT chk_to_state CHECK (to_state IS NULL OR to_state IN (
        'REQUESTED', 'APPROVED', 'REJECTED', 'ISSUED',
        'ACTIVE', 'BLOCKED', 'BLOCKED_FRAUD',
        'EXPIRED', 'CANCELLED'
    )),
    CONSTRAINT chk_successful_has_to_state CHECK (
        NOT successful OR (successful AND to_state IS NOT NULL)
    ),
    CONSTRAINT chk_failed_has_error CHECK (
        successful OR (NOT successful AND error_message IS NOT NULL)
    ),
    CONSTRAINT chk_different_states CHECK (
        from_state IS NULL OR to_state IS NULL OR from_state != to_state
    )
);

-- =============================================
-- FOREIGN KEYS
-- =============================================

-- state_transitions → cards
ALTER TABLE state_transitions
ADD CONSTRAINT fk_state_transition_card
FOREIGN KEY (card_id) REFERENCES cards(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- =============================================
-- INDEXES
-- =============================================

-- Basic indexes
CREATE INDEX idx_state_transition_card_id
ON state_transitions(card_id, transitioned_at DESC);

CREATE INDEX idx_state_transition_successful
ON state_transitions(successful);

CREATE INDEX idx_state_transition_date
ON state_transitions(transitioned_at DESC);

CREATE INDEX idx_state_transition_event
ON state_transitions(event, transitioned_at DESC);

CREATE INDEX idx_state_transition_from_state
ON state_transitions(from_state, transitioned_at DESC)
WHERE from_state IS NOT NULL;

CREATE INDEX idx_state_transition_to_state
ON state_transitions(to_state, transitioned_at DESC)
WHERE to_state IS NOT NULL;

CREATE INDEX idx_state_transition_performed_by
ON state_transitions(performed_by, transitioned_at DESC);

-- Composite indexes
CREATE INDEX idx_state_transition_card_success
ON state_transitions(card_id, successful, transitioned_at DESC);

CREATE INDEX idx_state_transition_card_event
ON state_transitions(card_id, event, transitioned_at DESC);

CREATE INDEX idx_state_transition_event_success
ON state_transitions(event, successful, transitioned_at DESC);

-- Partial indexes for specific queries
CREATE INDEX idx_state_transition_successful_only
ON state_transitions(card_id, to_state, transitioned_at DESC)
WHERE successful = TRUE;

CREATE INDEX idx_state_transition_failed_only
ON state_transitions(card_id, event, error_message, transitioned_at DESC)
WHERE successful = FALSE;

CREATE INDEX idx_state_transition_recent_failures
ON state_transitions(successful, event, transitioned_at DESC)
WHERE successful = FALSE;

-- Index for lifecycle analysis
CREATE INDEX idx_state_transition_flow
ON state_transitions(from_state, to_state, event)
WHERE successful = TRUE;

-- Full-text search on error messages
CREATE INDEX idx_state_transition_error_fulltext
ON state_transitions USING gin(to_tsvector('spanish', COALESCE(error_message, '')))
WHERE error_message IS NOT NULL;

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON TABLE state_transitions IS 'Auditoría completa de transiciones de estado del ciclo de vida de tarjetas';

COMMENT ON COLUMN state_transitions.id IS 'Identificador único de la transición';
COMMENT ON COLUMN state_transitions.card_id IS 'FK a la tarjeta que realizó la transición';
COMMENT ON COLUMN state_transitions.from_state IS 'Estado origen de la transición';
COMMENT ON COLUMN state_transitions.to_state IS 'Estado destino de la transición (NULL si falló)';
COMMENT ON COLUMN state_transitions.event IS 'Evento que disparó la transición';
COMMENT ON COLUMN state_transitions.reason IS 'Razón o justificación de la transición';
COMMENT ON COLUMN state_transitions.performed_by IS 'Usuario o sistema que ejecutó la transición';
COMMENT ON COLUMN state_transitions.transitioned_at IS 'Timestamp de cuando ocurrió la transición';
COMMENT ON COLUMN state_transitions.metadata IS 'Información adicional en formato JSON';
COMMENT ON COLUMN state_transitions.successful IS 'Indica si la transición fue exitosa';
COMMENT ON COLUMN state_transitions.error_message IS 'Mensaje de error si la transición falló';

-- =============================================
-- VIEWS (opcional - análisis de transiciones)
-- =============================================

-- Vista: Resumen de transiciones por tarjeta
CREATE OR REPLACE VIEW v_card_lifecycle_summary AS
SELECT
    card_id,
    COUNT(*) as total_transitions,
    COUNT(*) FILTER (WHERE successful = TRUE) as successful_transitions,
    COUNT(*) FILTER (WHERE successful = FALSE) as failed_transitions,
    MAX(transitioned_at) FILTER (WHERE successful = TRUE) as last_successful_transition,
    MAX(to_state) FILTER (WHERE successful = TRUE) as current_state,
    MIN(transitioned_at) as first_transition,
    MAX(transitioned_at) as last_transition
FROM state_transitions
GROUP BY card_id;

COMMENT ON VIEW v_card_lifecycle_summary IS 'Resumen del ciclo de vida por tarjeta';

-- Vista: Transiciones fallidas recientes (últimos 30 días)
CREATE OR REPLACE VIEW v_recent_failed_transitions AS
SELECT
    st.id,
    st.card_id,
    c.client_id,
    c.holder_first_name || ' ' || c.holder_last_name as holder_name,
    st.from_state,
    st.event,
    st.error_message,
    st.performed_by,
    st.transitioned_at
FROM state_transitions st
JOIN cards c ON st.card_id = c.id
WHERE st.successful = FALSE
  AND st.transitioned_at > CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY st.transitioned_at DESC;

COMMENT ON VIEW v_recent_failed_transitions IS 'Transiciones fallidas de los últimos 30 días';

-- Vista: Estadísticas de eventos
CREATE OR REPLACE VIEW v_event_statistics AS
SELECT
    event,
    COUNT(*) as total_executions,
    COUNT(*) FILTER (WHERE successful = TRUE) as successful_executions,
    COUNT(*) FILTER (WHERE successful = FALSE) as failed_executions,
    ROUND(
        COUNT(*) FILTER (WHERE successful = TRUE)::NUMERIC /
        COUNT(*)::NUMERIC * 100,
        2
    ) as success_rate_percentage,
    MAX(transitioned_at) as last_execution
FROM state_transitions
GROUP BY event
ORDER BY total_executions DESC;

COMMENT ON VIEW v_event_statistics IS 'Estadísticas de ejecución por tipo de evento';

-- =============================================
-- FUNCTIONS (análisis y reporting)
-- =============================================

-- Función: Obtener historial de una tarjeta
CREATE OR REPLACE FUNCTION get_card_lifecycle_history(p_card_id VARCHAR)
RETURNS TABLE (
    transition_id BIGINT,
    from_state VARCHAR,
    to_state VARCHAR,
    event VARCHAR,
    reason VARCHAR,
    performed_by VARCHAR,
    transitioned_at TIMESTAMP,
    successful BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id,
        from_state,
        to_state,
        event,
        reason,
        performed_by,
        transitioned_at,
        successful
    FROM state_transitions
    WHERE card_id = p_card_id
    ORDER BY transitioned_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_card_lifecycle_history IS 'Retorna el historial completo de transiciones de una tarjeta';

-- Función: Contar transiciones por periodo
CREATE OR REPLACE FUNCTION count_transitions_by_period(
    p_start_date TIMESTAMP,
    p_end_date TIMESTAMP
)
RETURNS TABLE (
    event VARCHAR,
    successful_count BIGINT,
    failed_count BIGINT,
    total_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        event,
        COUNT(*) FILTER (WHERE successful = TRUE) as successful_count,
        COUNT(*) FILTER (WHERE successful = FALSE) as failed_count,
        COUNT(*) as total_count
    FROM state_transitions
    WHERE transitioned_at BETWEEN p_start_date AND p_end_date
    GROUP BY event
    ORDER BY total_count DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION count_transitions_by_period IS 'Cuenta transiciones agrupadas por evento en un periodo';

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para validar transiciones lógicas
CREATE OR REPLACE FUNCTION validate_state_transition()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo validar transiciones exitosas
    IF NEW.successful = TRUE THEN
        -- Ejemplo de validación: REQUESTED solo puede ir a APPROVED o REJECTED
        IF NEW.from_state = 'REQUESTED' AND NEW.to_state NOT IN ('APPROVED', 'REJECTED') THEN
            RAISE EXCEPTION 'Invalid transition from REQUESTED to %', NEW.to_state;
        END IF;

        -- APPROVED solo puede ir a ISSUED o CANCELLED
        IF NEW.from_state = 'APPROVED' AND NEW.to_state NOT IN ('ISSUED', 'CANCELLED') THEN
            RAISE EXCEPTION 'Invalid transition from APPROVED to %', NEW.to_state;
        END IF;

        -- Estados finales no pueden transicionar
        IF NEW.from_state IN ('CANCELLED', 'REJECTED', 'EXPIRED') THEN
            RAISE EXCEPTION 'Cannot transition from final state %', NEW.from_state;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_state_transition
    BEFORE INSERT ON state_transitions
    FOR EACH ROW
    EXECUTE FUNCTION validate_state_transition();

COMMENT ON FUNCTION validate_state_transition IS 'Valida que las transiciones de estado sean lógicamente correctas';

-- =============================================
-- STATISTICS & VACUUM
-- =============================================

-- Actualizar estadísticas para el query planner
ANALYZE state_transitions;

-- =============================================
-- INITIAL DATA VALIDATION
-- =============================================

DO $$
DECLARE
    v_table_count INTEGER;
    v_index_count INTEGER;
    v_view_count INTEGER;
    v_function_count INTEGER;
BEGIN
    -- Verificar tabla
    SELECT COUNT(*) INTO v_table_count FROM information_schema.tables
    WHERE table_name = 'state_transitions' AND table_schema = 'public';

    -- Contar índices
    SELECT COUNT(*) INTO v_index_count FROM pg_indexes
    WHERE tablename = 'state_transitions';

    -- Contar vistas
    SELECT COUNT(*) INTO v_view_count FROM information_schema.views
    WHERE table_name LIKE 'v_%' AND table_schema = 'public';

    -- Contar funciones
    SELECT COUNT(*) INTO v_function_count FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname LIKE '%transition%';

    IF v_table_count = 1 THEN
        RAISE NOTICE '✅ V3 Migration completed successfully!';
        RAISE NOTICE '   - state_transitions table created';
        RAISE NOTICE '   - % indexes created', v_index_count;
        RAISE NOTICE '   - % views created', v_view_count;
        RAISE NOTICE '   - % functions created', v_function_count;
        RAISE NOTICE '   - 1 trigger created';
    ELSE
        RAISE EXCEPTION '❌ Migration failed: Table not created properly';
    END IF;
END $$;
