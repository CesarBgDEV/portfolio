#!/usr/bin/env bash
# setup-domain.sh — Configura Nginx + SSL para cesar-balderas.dev en el VPS de DigitalOcean
# Uso: sudo bash scripts/setup-domain.sh
# Requisitos: Ubuntu 22/24 LTS, Docker corriendo con el portfolio en el puerto 3000

set -euo pipefail

DOMAIN="cesar-balderas.dev"
WWW="www.cesar-balderas.dev"
EMAIL="cesar.softwared@gmail.com"
APP_PORT=3000

# ── Colores ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; exit 1; }
step() { echo -e "\n${BOLD}==> $*${NC}"; }

echo ""
echo -e "${BOLD}=============================================${NC}"
echo -e "${BOLD}  Setup dominio: $DOMAIN${NC}"
echo -e "${BOLD}=============================================${NC}"

# ── 1. Verificar root ──────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || err "Ejecuta con sudo: sudo bash scripts/setup-domain.sh"

# ── 2. Verificar que el contenedor Docker esté activo ─────────────────────────
step "[1/5] Verificando contenedor Docker en puerto $APP_PORT..."
if docker ps --format '{{.Ports}}' 2>/dev/null | grep -q ":${APP_PORT}->"; then
  ok "Contenedor activo en puerto $APP_PORT"
else
  warn "No se detectó el contenedor en el puerto $APP_PORT."
  warn "Ejecuta primero: bash scripts/deploy.sh"
  read -rp "  ¿Continuar de todas formas? (s/N): " ans
  [[ "${ans,,}" == "s" ]] || { echo "Abortado."; exit 1; }
fi

# ── 3. Instalar Nginx y Certbot ────────────────────────────────────────────────
step "[2/5] Instalando Nginx y Certbot..."
apt-get update -qq
apt-get install -y -qq nginx certbot python3-certbot-nginx
systemctl enable nginx
systemctl start nginx
ok "Nginx y Certbot instalados"

# ── 4. Configurar Nginx como reverse proxy (HTTP) ─────────────────────────────
# Certbot leerá este bloque y añadirá la configuración SSL automáticamente.
step "[3/5] Creando configuración Nginx para $DOMAIN..."

CONF="/etc/nginx/sites-available/$DOMAIN"

cat > "$CONF" <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN $WWW;

    # Reverse proxy al contenedor Docker
    location / {
        proxy_pass         http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_read_timeout 60s;
    }
}
NGINX

# Activar sitio y desactivar default
ln -sf "$CONF" /etc/nginx/sites-enabled/"$DOMAIN"
rm -f /etc/nginx/sites-enabled/default

nginx -t || err "Error en la configuración de Nginx. Revisa $CONF"
systemctl reload nginx
ok "Nginx configurado para $DOMAIN"

# ── 5. Obtener certificado SSL con Let's Encrypt ───────────────────────────────
step "[4/5] Obteniendo certificado SSL con Let's Encrypt..."
echo "  Esto puede tardar unos segundos..."

certbot --nginx \
  --non-interactive \
  --agree-tos \
  --redirect \
  --email  "$EMAIL" \
  -d "$DOMAIN" \
  -d "$WWW"

ok "Certificado SSL obtenido y configurado"

# ── 6. Agregar redirect www → apex en el bloque HTTPS ─────────────────────────
# Certbot ya habrá reescrito el conf con SSL. Añadimos server block para www→apex.
step "[5/5] Configurando redirect www → https://$DOMAIN..."

WWW_BLOCK="
# www → apex redirect
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $WWW;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    return 301 https://$DOMAIN\$request_uri;
}"

# Agregar solo si no existe todavía
if ! grep -q "return 301 https://$DOMAIN" "$CONF"; then
  echo "$WWW_BLOCK" >> "$CONF"
fi

nginx -t || err "Error al agregar redirect www. Revisa $CONF"
systemctl reload nginx
ok "Redirect www → https://$DOMAIN activo"

# ── 7. Renovación automática SSL ──────────────────────────────────────────────
if systemctl is-active --quiet certbot.timer 2>/dev/null; then
  ok "certbot.timer ya activo (renovación automática cada 12h)"
else
  # Fallback: cron mensual
  (crontab -l 2>/dev/null; echo "0 3 1 * * certbot renew --quiet && systemctl reload nginx") \
    | sort -u | crontab -
  ok "Cron de renovación SSL configurado (día 1 de cada mes, 3am)"
fi

# ── Resumen ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD}  ✓ Setup completado exitosamente.${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo ""
echo "  Sitio:       https://$DOMAIN"
echo "  Redirección: https://$WWW → https://$DOMAIN"
echo "  SSL:         Let's Encrypt (renovación automática)"
echo "  Puerto:      Nginx (80/443) → Docker ($APP_PORT)"
echo ""
echo "  Próximos pasos:"
echo "    · Para actualizar el sitio:  bash scripts/update.sh"
echo "    · Para ver logs de Nginx:    sudo journalctl -u nginx -f"
echo "    · Para verificar SSL:        certbot certificates"
echo ""
