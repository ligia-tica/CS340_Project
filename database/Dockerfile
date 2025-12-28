# Custom MySQL image with initialization scripts baked in
FROM mysql:8.0

# Copy SQL initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY plsql.sql /docker-entrypoint-initdb.d/02-procedures.sql
