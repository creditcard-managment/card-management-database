-- =============================================
-- Seeds: Test State Transitions (Development)
-- Description: Datos de prueba para state_transitions
-- =============================================

-- =============================================
-- STATE_TRANSITIONS - Transiciones de Estado
-- =============================================

-- Ciclo completo: Tarjeta 1 (Juan Pérez) - REQUESTED → ACTIVE
-- Transición 1: REQUESTED → APPROVED
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Cliente cumple con todos los requisitos crediticios',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '6 months' + INTERVAL '1 hour',
    TRUE
);

-- Transición 2: APPROVED → ISSUED
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, metadata, successful
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión estándar de tarjeta física',
    'card-issuer@bank.com',
    NOW() - INTERVAL '6 months' + INTERVAL '2 days',
    '{"issuing_facility": "Buenos Aires", "delivery_method": "Courier"}',
    TRUE
);

-- Transición 3: ISSUED → ACTIVE
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    'ISSUED', 'ACTIVE', 'ACTIVATE',
    'Cliente activó tarjeta desde app móvil',
    'juan.perez@email.com',
    NOW() - INTERVAL '6 months' + INTERVAL '5 days',
    TRUE
);

-- Ciclo completo: Tarjeta 2 (María González) - REQUESTED → ACTIVE
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440002',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Aprobación automática por score crediticio excelente',
    'auto-approval-system@bank.com',
    NOW() - INTERVAL '1 year' + INTERVAL '30 minutes',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión prioritaria Platinum',
    'card-issuer@bank.com',
    NOW() - INTERVAL '1 year' + INTERVAL '1 day',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'ISSUED', 'ACTIVE', 'ACTIVATE',
    'Activación por sucursal bancaria',
    'branch-agent@bank.com',
    NOW() - INTERVAL '1 year' + INTERVAL '3 days',
    TRUE
);

-- Ciclo con bloqueo: Tarjeta 3 (Carlos Rodríguez) - ACTIVE → BLOCKED_FRAUD
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440003',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Aprobación estándar',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '3 months' + INTERVAL '1 hour',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión estándar',
    'card-issuer@bank.com',
    NOW() - INTERVAL '3 months' + INTERVAL '2 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'ISSUED', 'ACTIVE', 'ACTIVATE',
    'Activación telefónica',
    'call-center@bank.com',
    NOW() - INTERVAL '3 months' + INTERVAL '4 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'ACTIVE', 'BLOCKED_FRAUD', 'BLOCK_FRAUD',
    'Detección de múltiples transacciones sospechosas en ubicaciones geográficas distantes',
    'fraud-detection-ai@bank.com',
    NOW() - INTERVAL '15 days',
    TRUE
);

-- Ciclo parcial: Tarjeta 4 (Ana Martínez) - REQUESTED → ISSUED (pendiente activación)
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440004',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Aprobación premium para tarjeta Black',
    'premium-analyst@bank.com',
    NOW() - INTERVAL '7 days' + INTERVAL '2 hours',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión premium con courier especial',
    'premium-issuer@bank.com',
    NOW() - INTERVAL '7 days' + INTERVAL '6 hours',
    TRUE
);

-- Ciclo con rechazo: Tarjeta rechazada
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES (
    '550e8400-e29b-41d4-a716-446655440005',
    'REQUESTED', 'REJECTED', 'REJECT',
    'Score crediticio insuficiente - Rechazado automáticamente',
    'auto-approval-system@bank.com',
    NOW() - INTERVAL '2 days' + INTERVAL '10 minutes',
    TRUE
);

-- Ciclo con bloqueo temporal: Tarjeta 6 (Laura Sánchez)
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440006',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Aprobación estándar',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '8 months' + INTERVAL '1 hour',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión estándar',
    'card-issuer@bank.com',
    NOW() - INTERVAL '8 months' + INTERVAL '2 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    'ISSUED', 'ACTIVE', 'ACTIVATE',
    'Activación desde cajero automático',
    'atm-network@bank.com',
    NOW() - INTERVAL '8 months' + INTERVAL '5 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    'ACTIVE', 'BLOCKED', 'BLOCK',
    'Bloqueo temporal solicitado por cliente - Tarjeta extraviada',
    'laura.sanchez@email.com',
    NOW() - INTERVAL '5 days',
    TRUE
);

-- Transición fallida: Intento de activación sin límite de crédito
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful, error_message
) VALUES (
    '550e8400-e29b-41d4-a716-446655440010',
    'APPROVED', 'ACTIVE', 'ACTIVATE',
    'Intento de activación prematura',
    'system@bank.com',
    NOW() - INTERVAL '2 days',
    FALSE,
    'Cannot activate card: Credit limit not assigned'
);

-- Transición fallida: Intento de desbloqueo sin autorización
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful, error_message
) VALUES (
    '550e8400-e29b-41d4-a716-446655440003',
    'BLOCKED_FRAUD', 'ACTIVE', 'UNBLOCK',
    'Intento de desbloqueo sin verificación de identidad',
    'unauthorized-user@email.com',
    NOW() - INTERVAL '10 days',
    FALSE,
    'Unblock denied: Fraud verification pending'
);

-- Ciclo de cancelación: Tarjeta 7 (Diego López)
INSERT INTO state_transitions (
    card_id, from_state, to_state, event,
    reason, performed_by, transitioned_at, successful
) VALUES
(
    '550e8400-e29b-41d4-a716-446655440007',
    'REQUESTED', 'APPROVED', 'APPROVE',
    'Aprobación estándar',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '2 years' + INTERVAL '1 hour',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440007',
    'APPROVED', 'ISSUED', 'ISSUE',
    'Emisión estándar',
    'card-issuer@bank.com',
    NOW() - INTERVAL '2 years' + INTERVAL '2 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440007',
    'ISSUED', 'ACTIVE', 'ACTIVATE',
    'Activación telefónica',
    'call-center@bank.com',
    NOW() - INTERVAL '2 years' + INTERVAL '4 days',
    TRUE
),
(
    '550e8400-e29b-41d4-a716-446655440007',
    'ACTIVE', 'CANCELLED', 'CANCEL',
    'Cancelación solicitada por cliente - Cambio de banco',
    'diego.lopez@email.com',
    NOW() - INTERVAL '1 month',
    TRUE
);

-- Mensaje de confirmación
DO $$
DECLARE
    total_transitions INTEGER;
    successful_transitions INTEGER;
    failed_transitions INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_transitions FROM state_transitions;
    SELECT COUNT(*) INTO successful_transitions FROM state_transitions WHERE successful = TRUE;
    SELECT COUNT(*) INTO failed_transitions FROM state_transitions WHERE successful = FALSE;

    RAISE NOTICE '✅ Seeds aplicadas exitosamente!';
    RAISE NOTICE '   - % transiciones totales creadas', total_transitions;
    RAISE NOTICE '   - % transiciones exitosas', successful_transitions;
    RAISE NOTICE '   - % transiciones fallidas', failed_transitions;
    RAISE NOTICE '';
    RAISE NOTICE 'Eventos registrados:';
    RAISE NOTICE '   - APPROVE: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'APPROVE');
    RAISE NOTICE '   - ISSUE: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'ISSUE');
    RAISE NOTICE '   - ACTIVATE: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'ACTIVATE');
    RAISE NOTICE '   - BLOCK: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'BLOCK');
    RAISE NOTICE '   - BLOCK_FRAUD: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'BLOCK_FRAUD');
    RAISE NOTICE '   - REJECT: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'REJECT');
    RAISE NOTICE '   - CANCEL: %', (SELECT COUNT(*) FROM state_transitions WHERE event = 'CANCEL');
END $$;
