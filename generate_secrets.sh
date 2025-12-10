#!/bin/bash
# generate_secrets.sh

# Función para generar una clave segura (Base64 de 32 bytes = 44 caracteres)
generate_secret() {
  openssl rand -base64 32
}

set -euo pipefail

ENV_FILE=.env
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo "Comprobando .env actual y generando secretos..."

# Hacer backup si existe
if [ -f "$ENV_FILE" ]; then
  cp "$ENV_FILE" "${ENV_FILE}.bak.${TIMESTAMP}"
  echo "Backup creado: ${ENV_FILE}.bak.${TIMESTAMP}"
fi

# Cargar valores existentes (si existen) para preservar nombres/usuarios
_get() {
  local key="$1"
  if [ -f "$ENV_FILE" ]; then
    # extrae el valor si existe (ignora comentarios y espacios)
    grep -E "^${key}=" "$ENV_FILE" | tail -n1 | cut -d'=' -f2- || true
  fi
}

POSTGRES_USER=$(_get POSTGRES_USER)
POSTGRES_DB=$(_get POSTGRES_DB)
RABBITMQ_USER=$(_get RABBITMQ_USER)
MINIO_ROOT_USER=$(_get MINIO_ROOT_USER)

# Valores por defecto si no están presentes
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-app_db}
RABBITMQ_USER=${RABBITMQ_USER:-rabbituser}
MINIO_ROOT_USER=${MINIO_ROOT_USER:-minioadmin}

# Variables secretas (siempre regeneramos para mayor seguridad)
POSTGRES_PASSWORD=$(generate_secret)
RABBITMQ_PASS=$(generate_secret)
MINIO_ROOT_PASSWORD=$(generate_secret)
SECRET_KEY_BI=$(generate_secret)
LEGACY_DB_PASSWORD=$(generate_secret)

# Escribir nuevo .env
cat > "$ENV_FILE" <<EOF
# Variables de entorno generadas por generate_secrets.sh - backup: ${ENV_FILE}.bak.${TIMESTAMP}

# PostgreSQL
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}

# RabbitMQ
RABBITMQ_USER=${RABBITMQ_USER}
RABBITMQ_PASS=${RABBITMQ_PASS}

# MinIO
MINIO_ROOT_USER=${MINIO_ROOT_USER}
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}

# Metabase
SECRET_KEY_BI=${SECRET_KEY_BI}

# MariaDB Legacy
LEGACY_DB_PASSWORD=${LEGACY_DB_PASSWORD}
EOF

chmod 600 "$ENV_FILE"

echo "${ENV_FILE} generado/actualizado correctamente."
