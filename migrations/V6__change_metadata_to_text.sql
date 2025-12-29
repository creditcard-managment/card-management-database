-- V6: Asegurar que metadata sea TEXT (ya está aplicado, solo documentación)

-- La columna ya es TEXT, solo agregamos comentario
COMMENT ON COLUMN credit_limit_history.metadata
    IS 'Información adicional en formato JSON (almacenado como TEXT)';
