-- =============================================
-- Rollback: V8
-- Date: 2026-11-02
-- Description: revert align cards table with card-data
-- =============================================
-- ⚠️ Falla si existen tarjetas INFINITE o valores que excedan 200 caracteres
-- en holder_address / block_reason. Revisar antes de ejecutar:
--   SELECT id FROM cards WHERE category = 'INFINITE'
--      OR length(holder_address) > 200 OR length(block_reason) > 200;

ALTER TABLE cards ALTER COLUMN block_reason TYPE VARCHAR(200);
ALTER TABLE cards ALTER COLUMN holder_address TYPE VARCHAR(200);

ALTER TABLE cards DROP CONSTRAINT chk_category;
ALTER TABLE cards ADD CONSTRAINT chk_category
    CHECK (category IN ('CLASSIC', 'GOLD', 'PLATINUM', 'BLACK'));

-- Quitar el registro de V8 del historial de Flyway
DELETE FROM flyway_schema_history WHERE version = '8';
