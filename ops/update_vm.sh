#!/usr/bin/env bash
set -Eeuo pipefail
export GODOT_SILENCE_ROOT_WARNING=1

ROOT="${DATAMOON_ROOT:-/opt/datamoon}"
GODOT="${GODOT_BIN:-/usr/local/bin/godot}"
LOCK_FILE="${DATAMOON_DEPLOY_LOCK:-/var/lock/datamoon-deploy.lock}"
API_REPO="$ROOT/datamoon-online-mysqlapi"
API_BINARY="$API_REPO/datamoon-api"
BACKUP_DIR="$(mktemp -d)"
ACTIVATED=0
SOURCE_UPDATED=0

REPOS=(datamoon-online-agent datamoon-online-auth datamoon-online-gateway datamoon-online-mysqlapi datamoon-online-server datamoon-online-web)
GODOT_REPOS=(datamoon-online-auth datamoon-online-gateway datamoon-online-server)
UNITS=(datamoon-gateway.service datamoon-auth.service datamoon-server@overworld.service datamoon-server@dungeon-1.service datamoon-api.service datamoon-web.service)

declare -A REPO_BRANCHES=(
  [datamoon-online-agent]="${DATAMOON_AGENT_BRANCH:-main}"
  [datamoon-online-auth]="${DATAMOON_RUNTIME_BRANCH:-pbe}"
  [datamoon-online-gateway]="${DATAMOON_RUNTIME_BRANCH:-pbe}"
  [datamoon-online-mysqlapi]="${DATAMOON_RUNTIME_BRANCH:-pbe}"
  [datamoon-online-server]="${DATAMOON_RUNTIME_BRANCH:-pbe}"
  [datamoon-online-web]="${DATAMOON_WEB_BRANCH:-main}"
)

cleanup() { rm -rf "$BACKUP_DIR"; }
trap cleanup EXIT
exec 9>"$LOCK_FILE"
flock -n 9 || { echo "Another Datamoon deployment is running." >&2; exit 1; }

for command in git go node find curl systemctl "$GODOT"; do
  command -v "$command" >/dev/null 2>&1 || { echo "Missing command: $command" >&2; exit 1; }
done

declare -A OLD_REFS
rollback() {
  test "$SOURCE_UPDATED" -eq 1 || return 0
  echo "Deployment failed; restoring the previous release." >&2
  if test "$ACTIVATED" -eq 1; then
    systemctl stop "${UNITS[@]}" || true
  fi
  for repo in "${REPOS[@]}"; do git -C "$ROOT/$repo" reset --hard "${OLD_REFS[$repo]}" || true; done
  for repo in "${GODOT_REPOS[@]}"; do "$GODOT" --headless --editor --quit --path "$ROOT/$repo" || true; done
  if test "$ACTIVATED" -eq 1; then
    test ! -f "$BACKUP_DIR/datamoon-api.previous" || install -m 0755 "$BACKUP_DIR/datamoon-api.previous" "$API_BINARY"
    systemctl start datamoon-api.service || true
    systemctl start datamoon-auth.service datamoon-gateway.service || true
    systemctl start datamoon-server@overworld.service datamoon-server@dungeon-1.service || true
    systemctl start datamoon-web.service || true
  fi
}
trap rollback ERR

for repo in "${REPOS[@]}"; do
  path="$ROOT/$repo"
  test -d "$path/.git" || { echo "Missing repository: $path" >&2; exit 1; }
  test -z "$(git -C "$path" status --porcelain)" || { echo "Dirty repository: $repo" >&2; exit 1; }
  OLD_REFS["$repo"]="$(git -C "$path" rev-parse HEAD)"
  git -C "$path" fetch --prune origin
  git -C "$path" rev-parse --verify "origin/${REPO_BRANCHES[$repo]}" >/dev/null
done

SOURCE_UPDATED=1
for repo in "${REPOS[@]}"; do
  branch="${REPO_BRANCHES[$repo]}"
  git -C "$ROOT/$repo" switch "$branch"
  git -C "$ROOT/$repo" reset --hard "origin/$branch"
done
for repo in "${GODOT_REPOS[@]}"; do "$GODOT" --headless --editor --quit --path "$ROOT/$repo"; done
while IFS= read -r -d '' javascript_file; do
  node --check "$javascript_file"
done < <(find "$ROOT/datamoon-online-web/src" -type f -name '*.js' -print0)

pushd "$API_REPO" >/dev/null
test -z "$(gofmt -l .)" || { echo "Go files require gofmt." >&2; false; }
go vet ./...
go build -trimpath -o "$BACKUP_DIR/datamoon-api.next" ./cmd/api
popd >/dev/null
test ! -f "$API_BINARY" || cp -a "$API_BINARY" "$BACKUP_DIR/datamoon-api.previous"
systemctl stop datamoon-web.service
systemctl stop datamoon-gateway.service datamoon-auth.service
systemctl stop datamoon-server@overworld.service datamoon-server@dungeon-1.service
systemctl stop datamoon-api.service
install -m 0755 "$BACKUP_DIR/datamoon-api.next" "$API_BINARY"
ACTIVATED=1
systemctl start datamoon-api.service
for attempt in {1..30}; do
  curl --fail --silent http://127.0.0.1:3000/ready >/dev/null && break
  test "$attempt" -lt 30 || false
  sleep 1
done
systemctl start datamoon-auth.service datamoon-gateway.service
systemctl start datamoon-server@overworld.service datamoon-server@dungeon-1.service
systemctl start datamoon-web.service

for unit in "${UNITS[@]}"; do systemctl is-active --quiet "$unit"; done
for repo in "${REPOS[@]}"; do
  test "$(git -C "$ROOT/$repo" rev-parse HEAD)" = "$(git -C "$ROOT/$repo" rev-parse "origin/${REPO_BRANCHES[$repo]}")"
done
ACTIVATED=0
SOURCE_UPDATED=0
trap - ERR
echo "Datamoon deployment completed at $(date -u +%FT%TZ)."
