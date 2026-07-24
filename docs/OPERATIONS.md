# Runtime And VM Operations

This is the canonical operational reference. Runtime repositories must keep only
machine-readable examples such as `.env.example` and systemd unit files.

## Service Layout

- `/opt/datamoon/datamoon-online-mysqlapi`: Go persistence API, loopback `3000`.
- `/opt/datamoon/datamoon-online-auth`: Godot Auth, loopback UDP `5200`.
- `/opt/datamoon/datamoon-online-gateway`: Godot WebSocket gateway, loopback `5100`.
- `/opt/datamoon/datamoon-online-server`: Godot ENet workers.
- `/opt/datamoon/datamoon-online-web`: web portal, loopback `3101`.

Active PBE systemd units are `datamoon-api`, `datamoon-auth`,
`datamoon-gateway`, `datamoon-server@overworld`,
`datamoon-server@dungeon-1` and `datamoon-web`. The legacy non-templated
`datamoon-server.service` and `datamoon-server@dungeon-2` remain disabled to
reduce resource usage during testing. The dungeon-2 environment template stays
available for a future capacity increase.

## Required Security Configuration

- MySQL API listens on `127.0.0.1:3000`.
- Auth binds `127.0.0.1:5200`.
- PBE uses `wss://gateway-pbe.datamoononline.com.br` on TCP `443`.
- Nginx terminates TLS and proxies WebSocket to `ws://127.0.0.1:5100`.
- Gateway binds `127.0.0.1`, sets `DATAMOON_GATEWAY_REQUIRE_TLS=false` and never
  reads the certificate private key. Local development may also use loopback WS.
- Nginx owns public connection/IP limits because proxied peers appear as
  loopback to Godot. Gateway owns per-session login/register cooldown.
- API uses unique `INTERNAL_API_AUTH_TOKEN`, `INTERNAL_API_GATEWAY_TOKEN`,
  `INTERNAL_API_SERVER_TOKEN` and `INTERNAL_API_WEB_TOKEN`.
  `INTERNAL_API_TOKEN` is only a rollout fallback.
- Each Godot service receives only its corresponding token through
  `DATAMOON_INTERNAL_API_TOKEN`.
- Database, API, Auth and observability ports are blocked from the public network.
- Public ports are TCP `80/443` and worker UDP `5000/5010/5020`. Legacy Gateway
  UDP `5100` is removed only after successful WSS validation.
- Web binds only `127.0.0.1:3101`, talks only to the loopback MySQL API and must
  never be exposed directly. Nginx terminates HTTPS, overwrites `X-Real-IP` and
  applies public login/register request and connection limits.
- Web runs as the dedicated `datamoon-web` Unix account, not as the gameplay
  service account. Its systemd sandbox can read application code, write only its
  private state directory and open only loopback network connections.
- Web production startup requires `PUBLIC_ORIGIN` to exactly match its HTTPS
  origin. Session cookies use the `__Host-` prefix and the service state under
  `/var/lib/datamoon-web` contains encrypted, expiring server-side sessions.
- The canonical Web virtual host is `datamoononline.com.br`; its certificate
  must exist under `/etc/letsencrypt/live/datamoononline.com.br` before running
  the connection installer. The canonical Nginx files are
  `ops/nginx/datamoon-web.conf`, `datamoon-web-proxy.conf` and
  `datamoon-web-limits.conf`.

## First Connection Install

The certificate and renewal timer must already be valid. Pull only the two
repositories that contain the installer, then run it as root. It prompts for the
current MySQL password and creates separate random tokens without printing them.

```bash
git -C /opt/datamoon/datamoon-online-agent switch main
git -C /opt/datamoon/datamoon-online-agent pull --ff-only origin main
git -C /opt/datamoon/datamoon-online-server switch pbe
git -C /opt/datamoon/datamoon-online-server pull --ff-only origin pbe
sudo /opt/datamoon/datamoon-online-agent/ops/install_vm_connection.sh
```

The installer writes root-owned `0640` runtime configuration and `0600` secret
files under `/opt/datamoon/env`. Systemd injects only the secret file declared by
each unit. It also installs units and the canonical Nginx proxy/rate limits,
validates Nginx and leaves activation to the coordinated updater.

## Coordinated Update

Install `ops/update_vm.sh` from the agent repository and invoke it through the
provided oneshot unit. It performs an exclusive lock, remote fetch, clean-tree
preflight, exact branch checkout (`main` for Agent/Web and `pbe` for runtimes),
Godot imports, Web syntax checks, Go formatting/vet/build, ordered restart,
readiness checks and code/binary rollback on validation or activation failure.

```bash
sudo install -m 0755 /opt/datamoon/datamoon-online-agent/ops/update_vm.sh /usr/local/sbin/datamoon-update
sudo install -m 0644 /opt/datamoon/datamoon-online-agent/ops/datamoon-deploy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start datamoon-deploy.service
sudo journalctl -u datamoon-deploy.service -n 200 --no-pager
```

The updater intentionally aborts on dirty repositories. Schema migrations must
remain backward-compatible because code rollback cannot undo a destructive DB
migration.

## Release Verification

1. Confirm every repository HEAD equals the intended remote commit.
2. Confirm `/ready` succeeds before Auth/Gateway/workers start.
3. Confirm every systemd unit is active and inspect recent journal errors.
4. Confirm Gateway certificate validity and that Client uses the PBE WSS domain.
5. Exercise register, login, ticket consume, character join and one dungeon
   handoff before opening the deployment to players.
6. Rotate leaked historical DB/API credentials before production promotion.

## Web Beta Controls

Public account registration stays disabled during closed beta. The Web service
defaults to a fail-closed posture when these variables are absent:

```env
REGISTRATION_ENABLED=false
MAINTENANCE_MODE=false
```

`REGISTRATION_ENABLED=false` removes the registration link and returns `404`
for both `GET` and `POST /register`. This controls only the website; disabling
account creation in the game client requires a coordinated Auth/Gateway/API
control. `MAINTENANCE_MODE=true` keeps `/health` available but returns a public
maintenance page with HTTP `503` and `Retry-After` for every user route. Restart
`datamoon-web.service` after changing either value.

The Web service emits structured `WARN` events named `login_ip_rate_limit`,
`login_account_rate_limit` and `register_ip_rate_limit` when an application
limit first blocks an actor. Actor identifiers are keyed hashes; passwords,
tokens, usernames and raw IP addresses are not logged. Inspect them with:

```bash
journalctl -u datamoon-web.service --since today --no-pager | grep 'rate_limit'
```

These journal events are the alert source. Delivery to e-mail, Slack or an
incident platform remains an infrastructure task and must be configured before
public production; local logs alone do not notify an operator.

The following controls are intentionally deferred, not considered complete:

- Password recovery: use a random single-use token stored only as a hash, a
  short expiry, session revocation after reset and a generic response that does
  not reveal whether an e-mail exists.
- E-mail validation: use a single-use expiring token and do not trust a new
  address until ownership is confirmed. Requires a transactional mail provider
  and bounce/abuse handling.
- Database backup: before production, implement automated encrypted MySQL
  backups, off-host retention, restricted restore credentials and a tested
  restore procedure. A backup that has not been restored in a drill is not a
  verified backup.
- OS/runtime patching: Ubuntu, Node.js and Nginx updates remain manual for beta.
  Record the installed versions, review security advisories, take/verify a
  backup, patch in a maintenance window and run the release verification list.

Internal API tokens are high-entropy bearer secrets that identify Auth,
Gateway, Server and Web to the loopback MySQL API. They are not player login
tokens. Each service must receive only its own token and route scope; possession
of a token grants that service's API permissions. Keep them only in root-owned
secret environment files, never in Git, terminal transcripts or application
logs, and rotate them after suspected disclosure or service compromise.

## Manual Connection Validation

Follow the real connection path while streaming structured logs:

```bash
sudo journalctl -f \
  -u datamoon-api \
  -u datamoon-auth \
  -u datamoon-gateway \
  -u datamoon-server@overworld
```

Expected sequence: `gateway_client_connected`, `auth_login_completed`,
`gateway_login_answer_sent`, `game_route_selected` in the Client, ticket consume,
character join and worker presence. Credentials and tickets must never appear.
Use `sudo tail -f /var/log/nginx/access.log /var/log/nginx/error.log` for TLS and
upgrade failures.

There are no automated functional test files. Source gates are Godot headless
import, Go formatting/vet/build, Node syntax and Bash syntax. Gameplay acceptance
is manual and must be supported by structured event logs.

## Logging And Audit Retention

Runtime services emit structured logs only to stdout for collection by
`journald`. Canonical environments use `DATAMOON_LOG_STDOUT=true`,
`DATAMOON_LOG_FILES=false` and `DATAMOON_LOG_LEVEL=INFO`; do not re-enable JSONL
files on the VM because they duplicate the journal. Full metrics snapshots are
DEBUG-only and metrics remain available through each worker observability
endpoint.

Keep the journal compressed, capped at 200 MB, with 3 GB reserved for the system
and seven days of retention. Use a drop-in at
`/etc/systemd/journald.conf.d/datamoon.conf`, installed from
`ops/systemd/journald-datamoon.conf`, rather than editing the packaged
configuration. Verify that `systemd-analyze cat-config systemd/journald.conf`
shows both the main file and the Datamoon drop-in.

The MySQL API retains inventory, reward and value-change audit plus their
idempotency operation records for 180 days by default. It starts cleanup with
the API, runs daily and deletes indexed rows in batches of 1,000, up to 20
batches per table per run.
The canonical variables are:

```env
DATAMOON_AUDIT_RETENTION_DAYS=180
DATAMOON_AUDIT_CLEANUP_INTERVAL_SECONDS=86400
DATAMOON_AUDIT_CLEANUP_BATCH_SIZE=1000
DATAMOON_AUDIT_CLEANUP_MAX_BATCHES=20
```

Chat retention is separate and remains seven days. Persistent audit is reserved
for changes to inventory, currency, rewards and future administrative state.
Party, Guild, handoff, login/logout and automated protection events are retained
in structured logs unless they also change player-owned value. Never log chat
content, passwords, tokens or tickets.

Support can reconstruct item and balance changes using `operation_id` across
`dm_inventory_audit`, `dm_inventory_ops`, `dm_reward_audit`,
`dm_reward_operations` and `dm_value_audit`. Check table growth with:

```sql
SELECT table_name, table_rows,
       ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb
FROM information_schema.tables
WHERE table_schema = 'datamoon_game_server'
  AND table_name IN ('dm_inventory_audit', 'dm_inventory_ops',
                     'dm_reward_audit', 'dm_reward_operations',
                     'dm_value_audit')
ORDER BY total_mb DESC;
```

Third-party asset licenses and their bundled READMEs stay next to the assets and
are not project documentation.
