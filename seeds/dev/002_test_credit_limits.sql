-- =============================================
-- Seeds: Test Credit Limits (Development)
-- Description: Datos de prueba para credit_limits y credit_limit_history
-- =============================================

-- =============================================
-- CREDIT_LIMITS - Límites de Crédito
-- =============================================

-- Límite 1: Tarjeta 1 (Juan Pérez) - Visa Gold
INSERT INTO credit_limits (
    id, card_id,
    purchase_limit_amount, purchase_limit_currency,
    cash_advance_limit_amount, cash_advance_limit_currency,
    consumed_credit_amount, consumed_credit_currency,
    available_credit_amount, available_credit_currency,
    daily_limit_amount, daily_limit_currency, daily_limit_consumed, daily_limit_reset_date,
    monthly_limit_amount, monthly_limit_currency, monthly_limit_consumed, monthly_limit_reset_date,
    assigned_by, assigned_at, created_at, updated_at
) VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440001',
    50000.00, 'ARS',
    15000.00, 'ARS',
    12500.00, 'ARS',
    37500.00, 'ARS',
    10000.00, 'ARS', 2500.00, CURRENT_DATE + INTERVAL '1 day',
    50000.00, 'ARS', 12500.00, DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month',
    'admin@bank.com',
    NOW() - INTERVAL '6 months',
    NOW() - INTERVAL '6 months',
    NOW()
);

-- Límite 2: Tarjeta 2 (María González) - Mastercard Platinum
INSERT INTO credit_limits (
    id, card_id,
    purchase_limit_amount, purchase_limit_currency,
    cash_advance_limit_amount, cash_advance_limit_currency,
    consumed_credit_amount, consumed_credit_currency,
    available_credit_amount, available_credit_currency,
    daily_limit_amount, daily_limit_currency, daily_limit_consumed, daily_limit_reset_date,
    monthly_limit_amount, monthly_limit_currency, monthly_limit_consumed, monthly_limit_reset_date,
    assigned_by, assigned_at, created_at, updated_at
) VALUES (
    '660e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440002',
    100000.00, 'ARS',
    30000.00, 'ARS',
    5000.00, 'ARS',
    95000.00, 'ARS',
    20000.00, 'ARS', 1000.00, CURRENT_DATE + INTERVAL '1 day',
    100000.00, 'ARS', 5000.00, DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month',
    'admin@bank.com',
    NOW() - INTERVAL '1 year',
    NOW() - INTERVAL '1 year',
    NOW()
);

-- Límite 3: Tarjeta 3 (Carlos Rodríguez) - Visa Classic (Bloqueada)
INSERT INTO credit_limits (
    id, card_id,
    purchase_limit_amount, purchase_limit_currency,
    cash_advance_limit_amount, cash_advance_limit_currency,
    consumed_credit_amount, consumed_credit_currency,
    available_credit_amount, available_credit_currency,
    daily_limit_amount, daily_limit_currency, daily_limit_consumed, daily_limit_reset_date,
    assigned_by, assigned_at, created_at, updated_at
) VALUES (
    '660e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440003',
    30000.00, 'ARS',
    9000.00, 'ARS',
    28500.00, 'ARS',  -- Casi consumido completamente
    1500.00, 'ARS',
    5000.00, 'ARS', 5000.00, CURRENT_DATE + INTERVAL '1 day',
    'admin@bank.com',
    NOW() - INTERVAL '3 months',
    NOW() - INTERVAL '3 months',
    NOW() - INTERVAL '15 days'
);

-- Límite 4: Tarjeta 8 (Sofía Ramírez) - Visa Classic (Cliente joven)
INSERT INTO credit_limits (
    id, card_id,
    purchase_limit_amount, purchase_limit_currency,
    cash_advance_limit_amount, cash_advance_limit_currency,
    consumed_credit_amount, consumed_credit_currency,
    available_credit_amount, available_credit_currency,
    daily_limit_amount, daily_limit_currency, daily_limit_consumed, daily_limit_reset_date,
    monthly_limit_amount, monthly_limit_currency, monthly_limit_consumed, monthly_limit_reset_date,
    assigned_by, assigned_at, created_at, updated_at
) VALUES (
    '660e8400-e29b-41d4-a716-446655440008',
    '550e8400-e29b-41d4-a716-446655440008',
    20000.00, 'ARS',
    6000.00, 'ARS',
    3500.00, 'ARS',
    16500.00, 'ARS',
    3000.00, 'ARS', 500.00, CURRENT_DATE + INTERVAL '1 day',
    20000.00, 'ARS', 3500.00, DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month',
    'system@bank.com',
    NOW() - INTERVAL '4 months',
    NOW() - INTERVAL '4 months',
    NOW()
);

-- =============================================
-- CREDIT_LIMIT_HISTORY - Historial de Cambios
-- =============================================

-- Historial 1: Asignación inicial - Tarjeta 1
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    'PURCHASE', 'ASSIGNED',
    NULL, NULL,
    50000.00, 'ARS',
    50000.00, 'ARS',
    'Límite inicial asignado según perfil crediticio',
    'admin@bank.com',
    NOW() - INTERVAL '6 months',
    TRUE
);

-- Historial 2: Incremento de límite - Tarjeta 1
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    'PURCHASE', 'INCREASED',
    30000.00, 'ARS',
    50000.00, 'ARS',
    20000.00, 'ARS',
    'Incremento por buen comportamiento de pago',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '3 months',
    TRUE
);

-- Historial 3: Consumo de crédito - Tarjeta 1
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    'PURCHASE', 'CONSUMED',
    0.00, 'ARS',
    12500.00, 'ARS',
    12500.00, 'ARS',
    'Compra en comercio adherido',
    'transaction-processor@bank.com',
    NOW() - INTERVAL '5 days',
    TRUE
);

-- Historial 4: Asignación inicial - Tarjeta 2
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440002',
    'PURCHASE', 'ASSIGNED',
    NULL, NULL,
    100000.00, 'ARS',
    100000.00, 'ARS',
    'Límite inicial para tarjeta Platinum',
    'admin@bank.com',
    NOW() - INTERVAL '1 year',
    TRUE
);

-- Historial 5: Liberación de crédito - Tarjeta 2
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440002',
    'PURCHASE', 'RELEASED',
    10000.00, 'ARS',
    5000.00, 'ARS',
    -5000.00, 'ARS',
    'Pago de resumen mensual',
    'payment-processor@bank.com',
    NOW() - INTERVAL '10 days',
    TRUE
);

-- Historial 6: Intento fallido de incremento - Tarjeta 3
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful, error_message
) VALUES (
    '660e8400-e29b-41d4-a716-446655440003',
    'PURCHASE', 'INCREASED',
    30000.00, 'ARS',
    50000.00, 'ARS',
    20000.00, 'ARS',
    'Solicitud de incremento rechazada',
    'credit-analyst@bank.com',
    NOW() - INTERVAL '20 days',
    FALSE,
    'Cliente no cumple con requisitos de score crediticio mínimo'
);

-- Historial 7: Asignación de límite diario - Tarjeta 1
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    'DAILY', 'ASSIGNED',
    NULL, NULL,
    10000.00, 'ARS',
    10000.00, 'ARS',
    'Asignación de límite diario como medida de seguridad',
    'risk-manager@bank.com',
    NOW() - INTERVAL '2 months',
    TRUE
);

-- Historial 8: Reducción temporal - Tarjeta 3
INSERT INTO credit_limit_history (
    credit_limit_id, limit_type, action,
    previous_value_amount, previous_value_currency,
    new_value_amount, new_value_currency,
    difference_amount, difference_currency,
    reason, changed_by, changed_at, successful
) VALUES (
    '660e8400-e29b-41d4-a716-446655440003',
    'PURCHASE', 'DECREASED',
    50000.00, 'ARS',
    30000.00, 'ARS',
    -20000.00, 'ARS',
    'Reducción por detección de actividad fraudulenta',
    'fraud-detection@bank.com',
    NOW() - INTERVAL '15 days',
    TRUE
);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✅ Seeds aplicadas exitosamente!';
    RAISE NOTICE '   - 4 límites de crédito creados';
    RAISE NOTICE '   - 8 registros de historial creados';
    RAISE NOTICE '';
    RAISE NOTICE 'Límites de crédito:';
    RAISE NOTICE '   - Tarjeta 1 (Juan): $50,000 ARS (25%% consumido)';
    RAISE NOTICE '   - Tarjeta 2 (María): $100,000 ARS (5%% consumido)';
    RAISE NOTICE '   - Tarjeta 3 (Carlos): $30,000 ARS (95%% consumido)';
    RAISE NOTICE '   - Tarjeta 8 (Sofía): $20,000 ARS (17.5%% consumido)';
END $$;
