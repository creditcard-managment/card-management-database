# Imagen custom de Flyway con configuraciones específicas
FROM flyway/flyway:11.1.0-alpine

# Copiar migraciones
COPY migrations /flyway/sql

# Copiar configuración
COPY flyway.conf /flyway/conf/flyway.conf

# Variables de entorno por defecto
ENV FLYWAY_URL=jdbc:postgresql://postgres:5432/card_management_db
ENV FLYWAY_USER=postgres
ENV FLYWAY_PASSWORD=postgres

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD flyway info || exit 1

# Comando por defecto
CMD ["migrate"]
