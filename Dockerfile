# --- Stage 1: Builder ---
FROM postgres:16-alpine AS builder

WORKDIR /build

COPY migrations ./migrations
COPY scripts ./scripts

RUN chmod -R 755 /build/scripts

# --- Stage 2: Runtime ---
FROM postgres:16-alpine

ENV POSTGRES_DB=portaria \
    POSTGRES_USER=portaria_admin \
    POSTGRES_PORT=5432 \
    POSTGRES_INIT_APP_DB=portaria_app \
    POSTGRES_GRPC_TARGET=backend:8080 \
    PGDATA=/var/lib/postgresql/data/pgdata

WORKDIR /var/lib/postgresql

COPY --from=builder /build/migrations/ /docker-entrypoint-initdb.d/
COPY --from=builder /build/scripts/ /docker-entrypoint-initdb.d/

RUN chmod -R 755 /docker-entrypoint-initdb.d

EXPOSE 5432

VOLUME ["/var/lib/postgresql/data"]

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
