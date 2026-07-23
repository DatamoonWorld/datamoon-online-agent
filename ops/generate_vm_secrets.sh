#!/usr/bin/env bash
set -Eeuo pipefail

ENV_DIR="${DATAMOON_ENV_DIR:-/opt/datamoon/env}"
GROUP="${DATAMOON_GROUP:-datamoon}"
FILES=(
  datamoon-api-secrets.env
  datamoon-auth-secrets.env
  datamoon-gateway-secrets.env
  datamoon-server-secrets.env
  datamoon-web-secrets.env
)

test "$(id -u)" -eq 0 || { echo "Run as root." >&2; exit 1; }
for command in openssl install; do
  command -v "$command" >/dev/null 2>&1 || { echo "Missing command: $command" >&2; exit 1; }
done
getent group "$GROUP" >/dev/null || { echo "Missing group: $GROUP" >&2; exit 1; }
for file in "${FILES[@]}"; do
  test ! -e "$ENV_DIR/$file" || { echo "Refusing to overwrite $ENV_DIR/$file" >&2; exit 1; }
done

if test -z "${MYSQL_PASSWORD:-}"; then
  read -r -s -p "Current MySQL password for datamoon_api: " MYSQL_PASSWORD
  echo
fi
test -n "$MYSQL_PASSWORD" || { echo "MySQL password is required." >&2; exit 1; }
case "$MYSQL_PASSWORD" in
  *$'\n'*|*$'\r'*) echo "MySQL password must be a single line." >&2; exit 1 ;;
esac
MYSQL_PASSWORD_ESCAPED="${MYSQL_PASSWORD//\\/\\\\}"
MYSQL_PASSWORD_ESCAPED="${MYSQL_PASSWORD_ESCAPED//\"/\\\"}"

AUTH_TOKEN="$(openssl rand -hex 32)"
GATEWAY_TOKEN="$(openssl rand -hex 32)"
SERVER_TOKEN="$(openssl rand -hex 32)"
WEB_TOKEN="$(openssl rand -hex 32)"
SIGNING_KEY="$(openssl rand -hex 48)"
SESSION_SECRET="$(openssl rand -hex 48)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

cat >"$TEMP_DIR/datamoon-api-secrets.env" <<EOF
INTERNAL_API_AUTH_TOKEN=$AUTH_TOKEN
INTERNAL_API_GATEWAY_TOKEN=$GATEWAY_TOKEN
INTERNAL_API_SERVER_TOKEN=$SERVER_TOKEN
INTERNAL_API_WEB_TOKEN=$WEB_TOKEN
DATAMOON_TOKEN_SIGNING_KEY=$SIGNING_KEY
MYSQL_PASSWORD="$MYSQL_PASSWORD_ESCAPED"
EOF
printf 'DATAMOON_INTERNAL_API_TOKEN=%s\n' "$AUTH_TOKEN" >"$TEMP_DIR/datamoon-auth-secrets.env"
printf 'DATAMOON_INTERNAL_API_TOKEN=%s\n' "$GATEWAY_TOKEN" >"$TEMP_DIR/datamoon-gateway-secrets.env"
printf 'DATAMOON_INTERNAL_API_TOKEN=%s\n' "$SERVER_TOKEN" >"$TEMP_DIR/datamoon-server-secrets.env"
printf 'DATAMOON_INTERNAL_API_TOKEN=%s\nSESSION_SECRET=%s\n' "$WEB_TOKEN" "$SESSION_SECRET" >"$TEMP_DIR/datamoon-web-secrets.env"

install -d -m 0750 -o root -g "$GROUP" "$ENV_DIR"
for file in "${FILES[@]}"; do
  install -m 0600 -o root -g root "$TEMP_DIR/$file" "$ENV_DIR/$file"
done
echo "Scoped service secrets installed in $ENV_DIR. Values were not printed."
