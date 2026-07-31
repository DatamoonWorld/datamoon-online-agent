#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${DATAMOON_ROOT:-/opt/datamoon}"
AGENT_ROOT="$ROOT/datamoon-online-agent"

test "$(id -u)" -eq 0 || { echo "Run as root." >&2; exit 1; }
test -d "$AGENT_ROOT/.git" || { echo "Missing $AGENT_ROOT" >&2; exit 1; }

if ! command -v fail2ban-client >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends fail2ban
fi

install -m 0644 "$AGENT_ROOT/ops/fail2ban/filter.d/datamoon-nginx-rate-limit.conf" /etc/fail2ban/filter.d/datamoon-nginx-rate-limit.conf
install -m 0644 "$AGENT_ROOT/ops/fail2ban/jail.d/datamoon-web.local" /etc/fail2ban/jail.d/datamoon-web.local
fail2ban-client -t
systemctl enable --now fail2ban.service
fail2ban-client reload
fail2ban-client status datamoon-web-rate-limit
