# 🌱 Seeds - Datos de Prueba (Development)

## Descripción

Scripts SQL para poblar la base de datos con datos de prueba realistas.

## Orden de Ejecución

**IMPORTANTE:** Ejecutar en este orden para respetar las Foreign Keys:
```
1. 001_test_cards.sql              (10 tarjetas + 5 auditorías)
2. 002_test_credit_limits.sql      (4 límites + 8 históricos)
3. 003_test_state_transitions.sql  (25+ transiciones)
```

## Ejecutar Seeds

### Opción A: Con Make (Recomendado)
```bash
make seed-dev
```

### Opción B: Manualmente
```bash
# Ejecutar cada archivo
docker exec -i card-db-postgres psql -U postgres -d card_management_db < seeds/dev/001_test_cards.sql
docker exec -i card-db-postgres psql -U postgres -d card_management_db < seeds/dev/002_test_credit_limits.sql
docker exec -i card-db-postgres psql -U postgres -d card_management_db < seeds/dev/003_test_state_transitions.sql
```

## Datos Creados

### Tarjetas (10)

| ID | Titular | Tipo | Categoría | Estado | Límite |
|----|---------|------|-----------|--------|--------|
| ...001 | Juan Pérez | VISA | GOLD | ACTIVE | $50,000 |
| ...002 | María González | MASTERCARD | PLATINUM | ACTIVE | $100,000 |
| ...003 | Carlos Rodríguez | VISA | CLASSIC | BLOCKED_FRAUD | $30,000 |
| ...004 | Ana Martínez | AMEX | BLACK | ISSUED | - |
| ...005 | Roberto Fernández | CABAL | GOLD | REQUESTED | - |
| ...006 | Laura Sánchez | NARANJA | PLATINUM | BLOCKED | - |
| ...007 | Diego López | VISA | INFINITE | CANCELLED | - |
| ...008 | Sofía Ramírez | VISA | CLASSIC | ACTIVE | $20,000 |
| ...009 | Martín Torres | MASTERCARD | GOLD | EXPIRED | - |
| ...010 | Lucía Morales | VISA | PLATINUM | APPROVED | - |

### Escenarios de Prueba

1. **Ciclo completo (REQUESTED → ACTIVE):**
    - Tarjeta 1 (Juan Pérez)
    - Tarjeta 2 (María González)

2. **Bloqueo por fraude:**
    - Tarjeta 3 (Carlos Rodríguez)

3. **Pendiente de activación:**
    - Tarjeta 4 (Ana Martínez)

4. **Rechazada:**
    - Tarjeta 5 (Roberto Fernández)

5. **Bloqueada temporalmente:**
    - Tarjeta 6 (Laura Sánchez)

6. **Cancelada:**
    - Tarjeta 7 (Diego López)

7. **Transiciones fallidas:**
    - Intentos de activación sin límite
    - Intentos de desbloqueo no autorizados

## Limpiar Datos
```bash
# Eliminar solo datos de seeds (mantener schema)
docker exec -it card-db-postgres psql -U postgres -d card_management_db << EOF
TRUNCATE TABLE state_transitions CASCADE;
TRUNCATE TABLE credit_limit_history CASCADE;
TRUNCATE TABLE credit_limits CASCADE;
TRUNCATE TABLE card_audit CASCADE;
TRUNCATE TABLE cards CASCADE;
EOF
```

## Notas

- ⚠️ **Solo para desarrollo** - NO usar en producción
- 🔒 PINs y CVVs son **ficticios** y están encriptados
- 📊 Datos realistas basados en casos de uso reales
- 🔗 Respeta todas las Foreign Keys y constraints