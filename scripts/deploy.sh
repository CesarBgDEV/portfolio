#!/usr/bin/env bash
# deploy.sh — Primer deploy del portfolio en el servidor
# Uso: bash scripts/deploy.sh

set -euo pipefail

echo "==> Verificando dependencias..."
command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker no está instalado."; exit 1; }
command -v git    >/dev/null 2>&1 || { echo "ERROR: Git no está instalado."; exit 1; }

# Directorio raíz del proyecto (un nivel arriba de /scripts)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Directorio: $ROOT"
echo "==> Construyendo imagen Docker..."
docker compose build --no-cache

echo "==> Levantando contenedor..."
docker compose up -d

echo ""
echo "✓ Deploy completado. El sitio está corriendo en el puerto 3000."
