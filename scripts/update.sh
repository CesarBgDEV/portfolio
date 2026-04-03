#!/usr/bin/env bash
# update.sh — Jala los últimos cambios de Git y reconstruye el contenedor
# Uso: bash scripts/update.sh

set -euo pipefail

# Directorio raíz del proyecto (un nivel arriba de /scripts)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Directorio: $ROOT"

echo "==> Jalando últimos cambios..."
git pull origin main

echo "==> Reconstruyendo imagen Docker..."
docker compose build --no-cache

echo "==> Reiniciando contenedor..."
docker compose up -d

echo "==> Limpiando imágenes huérfanas..."
docker image prune -f

echo ""
echo "✓ Actualización completada. El sitio está corriendo con la versión más reciente."
