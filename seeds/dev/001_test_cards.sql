-- =============================================
-- Seeds: Test Cards (Development)
-- Description: Datos de prueba para cards y card_audit
-- =============================================

-- =============================================
-- CARDS - Datos de Prueba
-- =============================================

-- Tarjeta 1: ACTIVE - Visa Gold
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    '20123456789',
    'Juan', 'Pérez', '20123456789',
    'juan.perez@email.com', '+54 11 1234-5678', '1990-05-15', 'Av. Corrientes 1234, CABA',
    'VISA', 'GOLD',
    'encrypted_pan_4532123456789012', '9012', 'encrypted_cvv_123', '$2a$12$hashedpin1234',
    12, 2028,
    'ACTIVE', NOW() - INTERVAL '6 months', NOW()
);

-- Tarjeta 2: ACTIVE - Mastercard Platinum
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440002',
    '27987654321',
    'María', 'González', '27987654321',
    'maria.gonzalez@email.com', '+54 11 8765-4321', '1985-08-22', 'Av. Santa Fe 5678, CABA',
    'MASTERCARD', 'PLATINUM',
    'encrypted_pan_5412345678901234', '1234', 'encrypted_cvv_456', '$2a$12$hashedpin5678',
    6, 2027,
    'ACTIVE', NOW() - INTERVAL '1 year', NOW()
);

-- Tarjeta 3: BLOCKED - Visa Classic (Bloqueada por fraude)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, block_reason, blocked_at, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440003',
    '23456789012',
    'Carlos', 'Rodríguez', '23456789012',
    'carlos.rodriguez@email.com', '+54 11 2345-6789', '1992-03-10', 'Av. Rivadavia 9012, CABA',
    'VISA', 'CLASSIC',
    'encrypted_pan_4916123456789012', '9012', 'encrypted_cvv_789', '$2a$12$hashedpin9012',
    3, 2026,
    'BLOCKED_FRAUD', 'Transacciones sospechosas detectadas', NOW() - INTERVAL '15 days',
    NOW() - INTERVAL '3 months', NOW() - INTERVAL '15 days'
);

-- Tarjeta 4: ISSUED - Amex Black (Emitida pero no activada)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440004',
    '20111222333',
    'Ana', 'Martínez', '20111222333',
    'ana.martinez@email.com', '+54 11 1112-2233', '1988-11-30', 'Av. Libertador 3456, CABA',
    'AMEX', 'BLACK',
    'encrypted_pan_378282246310005', '0005', 'encrypted_cvv_1234', '$2a$12$hashedpin3456',
    9, 2029,
    'ISSUED', NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days'
);

-- Tarjeta 5: REQUESTED - Cabal Gold (Solicitada, pendiente aprobación)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440005',
    '24567890123',
    'Roberto', 'Fernández', '24567890123',
    'roberto.fernandez@email.com', '+54 11 4567-8901', '1995-07-18', 'Av. Cabildo 7890, CABA',
    'CABAL', 'GOLD',
    'REQUESTED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'
);

-- Tarjeta 6: BLOCKED - Naranja Platinum (Bloqueada temporalmente)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, block_reason, blocked_at, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440006',
    '26789012345',
    'Laura', 'Sánchez', '26789012345',
    'laura.sanchez@email.com', '+54 11 6789-0123', '1991-12-05', 'Av. Callao 2345, CABA',
    'NARANJA', 'PLATINUM',
    'encrypted_pan_5896123456789012', '9012', 'encrypted_cvv_567', '$2a$12$hashedpin6789',
    11, 2027,
    'BLOCKED', 'Bloqueo temporal por pérdida de tarjeta', NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '8 months', NOW() - INTERVAL '5 days'
);

-- Tarjeta 7: CANCELLED - Visa Infinite (Cancelada por cliente)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at, deleted, deleted_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440007',
    '25678901234',
    'Diego', 'López', '25678901234',
    'diego.lopez@email.com', '+54 11 5678-9012', '1987-04-25', 'Av. Las Heras 4567, CABA',
    'VISA', 'INFINITE',
    'encrypted_pan_4539123456789012', '9012', 'encrypted_cvv_890', '$2a$12$hashedpin7890',
    5, 2026,
    'CANCELLED', NOW() - INTERVAL '2 years', NOW() - INTERVAL '1 month', TRUE, NOW() - INTERVAL '1 month'
);

-- Tarjeta 8: ACTIVE - Visa Classic (Cliente joven)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440008',
    '28901234567',
    'Sofía', 'Ramírez', '28901234567',
    'sofia.ramirez@email.com', '+54 11 8901-2345', '2000-09-14', 'Av. Belgrano 6789, CABA',
    'VISA', 'CLASSIC',
    'encrypted_pan_4024123456789012', '9012', 'encrypted_cvv_234', '$2a$12$hashedpin8901',
    8, 2026,
    'ACTIVE', NOW() - INTERVAL '4 months', NOW()
);

-- Tarjeta 9: EXPIRED - Mastercard Gold (Vencida)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    card_number_encrypted, last_four_digits, cvv_encrypted, pin_hash,
    expiration_month, expiration_year,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440009',
    '22345678901',
    'Martín', 'Torres', '22345678901',
    'martin.torres@email.com', '+54 11 2345-6789', '1983-06-20', 'Av. 9 de Julio 1234, CABA',
    'MASTERCARD', 'GOLD',
    'encrypted_pan_5105123456789012', '9012', 'encrypted_cvv_345', '$2a$12$hashedpin2345',
    1, 2025,
    'EXPIRED', NOW() - INTERVAL '5 years', NOW() - INTERVAL '11 months'
);

-- Tarjeta 10: APPROVED - Visa Platinum (Aprobada, pendiente emisión)
INSERT INTO cards (
    id, client_id,
    holder_first_name, holder_last_name, holder_document_number,
    holder_email, holder_phone_number, holder_birth_date, holder_address,
    type, category,
    status, created_at, updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440010',
    '29012345678',
    'Lucía', 'Morales', '29012345678',
    'lucia.morales@email.com', '+54 11 9012-3456', '1993-02-28', 'Av. Córdoba 8901, CABA',
    'VISA', 'PLATINUM',
    'APPROVED', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'
);

-- =============================================
-- CARD_AUDIT - Auditoría de Cambios
-- =============================================

-- Auditoría: Cambio de email en tarjeta 1
INSERT INTO card_audit (
    card_id, field_name, old_value, new_value,
    changed_by, changed_at, change_reason
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    'holder_email',
    'juan.perez.old@email.com',
    'juan.perez@email.com',
    'admin@bank.com',
    NOW() - INTERVAL '30 days',
    'Actualización de contacto solicitada por cliente'
);

-- Auditoría: Cambio de teléfono en tarjeta 2
INSERT INTO card_audit (
    card_id, field_name, old_value, new_value,
    changed_by, changed_at, change_reason
) VALUES (
    '550e8400-e29b-41d4-a716-446655440002',
    'holder_phone_number',
    '+54 11 0000-0000',
    '+54 11 8765-4321',
    'system@bank.com',
    NOW() - INTERVAL '60 days',
    'Verificación y actualización de datos de contacto'
);

-- Auditoría: Cambio de estado en tarjeta 3 (ACTIVE → BLOCKED_FRAUD)
INSERT INTO card_audit (
    card_id, field_name, old_value, new_value,
    changed_by, changed_at, change_reason
) VALUES (
    '550e8400-e29b-41d4-a716-446655440003',
    'status',
    'ACTIVE',
    'BLOCKED_FRAUD',
    'fraud-detection@bank.com',
    NOW() - INTERVAL '15 days',
    'Sistema de detección de fraude detectó actividad sospechosa'
);

-- Auditoría: Cambio de dirección en tarjeta 2
INSERT INTO card_audit (
    card_id, field_name, old_value, new_value,
    changed_by, changed_at, change_reason
) VALUES (
    '550e8400-e29b-41d4-a716-446655440002',
    'holder_address',
    'Av. Santa Fe 1000, CABA',
    'Av. Santa Fe 5678, CABA',
    'maria.gonzalez@email.com',
    NOW() - INTERVAL '45 days',
    'Mudanza notificada por el cliente'
);

-- Auditoría: Reset de PIN en tarjeta 1
INSERT INTO card_audit (
    card_id, field_name, old_value, new_value,
    changed_by, changed_at, change_reason
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001',
    'pin_hash',
    '$2a$12$oldhashedpin',
    '$2a$12$hashedpin1234',
    'juan.perez@email.com',
    NOW() - INTERVAL '10 days',
    'Reseteo de PIN solicitado por cliente desde app móvil'
);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✅ Seeds aplicadas exitosamente!';
    RAISE NOTICE '   - 10 tarjetas creadas';
    RAISE NOTICE '   - 5 registros de auditoría creados';
    RAISE NOTICE '';
    RAISE NOTICE 'Estados de tarjetas:';
    RAISE NOTICE '   - ACTIVE: 3 tarjetas';
    RAISE NOTICE '   - BLOCKED: 1 tarjeta';
    RAISE NOTICE '   - BLOCKED_FRAUD: 1 tarjeta';
    RAISE NOTICE '   - ISSUED: 1 tarjeta';
    RAISE NOTICE '   - REQUESTED: 1 tarjeta';
    RAISE NOTICE '   - APPROVED: 1 tarjeta';
    RAISE NOTICE '   - CANCELLED: 1 tarjeta';
    RAISE NOTICE '   - EXPIRED: 1 tarjeta';
END $$;
