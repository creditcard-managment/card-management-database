-- =============================================
-- Migration: V8
-- Date: 2026-11-02
-- Description: align cards table with card-data (CardEntity / CardCategory)
-- =============================================

-- 1. Permitir la categoría INFINITE (definida en CardCategory)
ALTER TABLE cards DROP CONSTRAINT chk_category;
ALTER TABLE cards ADD CONSTRAINT chk_category
    CHECK (category IN ('CLASSIC', 'GOLD', 'PLATINUM', 'BLACK', 'INFINITE'));

-- 2. Dirección del titular: el request de alta admite hasta 500 caracteres
ALTER TABLE cards ALTER COLUMN holder_address TYPE VARCHAR(500);

-- 3. Motivo de bloqueo: CardEntity declara 500 caracteres
ALTER TABLE cards ALTER COLUMN block_reason TYPE VARCHAR(500);
