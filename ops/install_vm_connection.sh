#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DATAMOON_ROOT:-/opt/datamoon}"
AGENT_ROOT="$ROOT/datamoon-online-agent"
SERVER_ROOT="$ROOT/datamoon-online-server"
ENV_DIR="$ROOT/env"
SERVER_STATE_DIR="/var/lib/datamoon"

test "$(id -u)" -eq 0 || { echo "Run as root." >&2; exit 1; }
for command in install nginx systemctl; do
  command -v "$command" >/dev/null 2>&1 || { echo "Missing command: $command" >&2; exit 1; }
done
test -d "$AGENT_ROOT/.git" || { echo "Missing $AGENT_ROOT" >&2; exit 1; }
test -d "$SERVER_ROOT/.git" || { echo "Missing $SERVER_ROOT" >&2; exit 1; }
test -f /etc/letsencrypt/live/gateway-pbe.datamoononline.com.br/fullchain.pem || { echo "Missing Gateway certificate." >&2; exit 1; }
test -f /etc/letsencrypt/live/gateway-pbe.datamoononline.com.br/privkey.pem || { echo "Missing Gateway private key." >&2; exit 1; }

if ! id datamoon >/dev/null 2>&1; then
  useradd --system --home "$SERVER_STATE_DIR" --shell /usr/sbin/nologin datamoon
fi
install -d -m 0750 -o root -g datamoon "$ENV_DIR"
install -d -m 0755 /etc/systemd/journald.conf.d
install -m 0644 "$AGENT_ROOT/ops/systemd/journald-datamoon.conf" /etc/systemd/journald.conf.d/datamoon.conf
install -d -m 0750 -o datamoon -g datamoon \
  "$SERVER_STATE_DIR" /var/lib/datamoon-auth /var/lib/datamoon-gateway \
  /var/lib/datamoon-web /var/lib/datamoon-web/storage

for service in api auth gateway server web; do
  install -m 0640 -o root -g datamoon \
    "$AGENT_ROOT/ops/env/datamoon-$service.env.example" \
    "$ENV_DIR/datamoon-$service.env"
done
for worker in overworld dungeon-1 dungeon-2; do
  install -m 0640 -o root -g datamoon \
    "$SERVER_ROOT/deploy/env/datamoon-server-$worker.env.example" \
    "$ENV_DIR/datamoon-server-$worker.env"
done

if test ! -e "$ENV_DIR/datamoon-api-secrets.env"; then
  "$AGENT_ROOT/ops/generate_vm_secrets.sh"
fi
for secret_file in api auth gateway server web; do
  test -f "$ENV_DIR/datamoon-$secret_file-secrets.env" || { echo "Missing secrets for $secret_file." >&2; exit 1; }
done

for service in api auth gateway web; do
  install -m 0644 "$AGENT_ROOT/ops/systemd/datamoon-$service.service" "/etc/systemd/system/datamoon-$service.service"
done
install -m 0644 "$SERVER_ROOT/deploy/systemd/datamoon-server@.service" /etc/systemd/system/datamoon-server@.service
install -m 0644 "$AGENT_ROOT/ops/datamoon-deploy.service" /etc/systemd/system/datamoon-deploy.service
install -m 0755 "$AGENT_ROOT/ops/update_vm.sh" /usr/local/sbin/datamoon-update

install -m 0644 "$AGENT_ROOT/ops/nginx/datamoon-gateway-limits.conf" /etc/nginx/conf.d/datamoon-gateway-limits.conf
install -m 0644 "$AGENT_ROOT/ops/nginx/datamoon-gateway.conf" /etc/nginx/sites-available/datamoon-gateway
ln -sfn /etc/nginx/sites-available/datamoon-gateway /etc/nginx/sites-enabled/datamoon-gateway
printf '#!/bin/sh\nsystemctl reload nginx\n' >/etc/letsencrypt/renewal-hooks/deploy/reload-nginx
chmod 0755 /etc/letsencrypt/renewal-hooks/deploy/reload-nginx

nginx -t
systemctl reload nginx
systemctl restart systemd-journald
systemctl daemon-reload
systemctl disable --now datamoon-server.service 2>/dev/null || true
systemctl disable --now datamoon-server@dungeon-2.service 2>/dev/null || true
systemctl enable datamoon-api.service datamoon-auth.service datamoon-gateway.service \
  datamoon-server@overworld.service datamoon-server@dungeon-1.service \
  datamoon-web.service
echo "Connection configuration installed. Run datamoon-update to deploy and activate it."
