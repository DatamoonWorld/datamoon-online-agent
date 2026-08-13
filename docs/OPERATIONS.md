# Runtime And VM Operations

This is the canonical operational reference. Runtime repositories must keep only
machine-readable examples such as `.env.example` and systemd unit files.

## Service Layout

- `/opt/datamoon/datamoon-online-mysqlapi`: Go persistence API, loopback `3000`.
- `/opt/datamoon/datamoon-online-auth`: Godot Auth, loopback UDP `5200`.
- `/opt/datamoon/datamoon-online-gateway`: Godot WebSocket gateway, loopback `5100`.
- `/opt/datamoon/datamoon-online-server`: Godot ENet workers.
- `/opt/datamoon/datamoon-online-web`: web portal, loopback `3101`.
- `datamoon-mailer`: isolated SES sender over `/run/datamoon-mailer/mailer.sock`.

Active PBE systemd units are `datamoon-api`, `datamoon-auth`,
`datamoon-gateway`, `datamoon-server@overworld`,
`datamoon-server@dungeon-1`, `datamoon-mailer` and `datamoon-web`. The legacy non-templated
`datamoon-server.service` and `datamoon-server@dungeon-2` remain disabled to
reduce resource usage during testing. The dungeon-2 environment template stays
available for a future capacity increase.

## Required Security Configuration

- MySQL API listens on `127.0.0.1:3000`.
- Auth binds `127.0.0.1:5200`.
- PBE uses `wss://gateway-pbe.datamoononline.com.br` on TCP `443`.
- Nginx terminates TLS and proxies WebSocket to `ws://127.0.0.1:5100`.
- Nginx answers `GET /healthz` with `204` and rejects non-WebSocket requests
  with `426` before they reach the Godot Gateway.
- Gateway binds `127.0.0.1`, sets `DATAMOON_GATEWAY_REQUIRE_TLS=false` and never
  reads the certificate private key. Local development may also use loopback WS.
- Nginx owns public connection/IP limits because proxied peers appear as
  loopback to Godot. Gateway owns per-session login/register cooldown.
- API requires unique `INTERNAL_API_AUTH_TOKEN`, `INTERNAL_API_GATEWAY_TOKEN`,
  `INTERNAL_API_SERVER_TOKEN` and `INTERNAL_API_WEB_TOKEN`; there is no shared
  rollout fallback. Every token must contain at least 32 characters; API
  startup fails when one is missing, short or duplicated.
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
- Web never talks to SES directly. It submits one of five fixed transactional
  templates over a group-restricted Unix socket. `datamoon-mailer` has no API,
  database or session secret and is the only Web-side process allowed outbound
  network access. It receives temporary AWS credentials through the EC2 role;
  static AWS access keys are forbidden.
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

The installer creates missing root-owned `0640` runtime configuration and `0600`
secret files under `/opt/datamoon/env`. On later runs it preserves every existing
environment and secret, adding only newly required defaults that are absent.
Systemd injects only the secret file declared by each unit. The installer also
installs units and the canonical Nginx proxy/rate limits, validates Nginx and
leaves activation to the coordinated updater.

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

Character world persistence requires `dm_characters.space_id`. A clean install
gets the column from `001_create_characters.sql`. For an existing PBE database,
apply this additive change before deploying the API/Server release that reads
the column:

```sql
ALTER TABLE dm_characters
  ADD COLUMN space_id VARCHAR(128) NOT NULL DEFAULT 'digital_center' AFTER posy;
```

Existing rows intentionally start in `digital_center`; after the release, the
next runtime checkpoint or clean logout records each character's current
registered overworld map. Do not persist `dungeon:*` instance IDs manually.

Link star progression adds persistent cap and MAX state to `dm_datamoons`. A
clean install gets the final columns from `002_create_datamoons.sql`. Existing
PBE databases must apply the following additive change before deploying the
API/Server release that reads these columns:

```sql
ALTER TABLE dm_datamoons
  ADD COLUMN link_star_cap TINYINT UNSIGNED NOT NULL DEFAULT 5 AFTER link_exp,
  ADD COLUMN link_max_unlocked TINYINT(1) NOT NULL DEFAULT 0 AFTER link_star_cap,
  ADD COLUMN link_max_unlocked_at TIMESTAMP NULL DEFAULT NULL AFTER link_max_unlocked,
  ADD CONSTRAINT chk_dm_datamoons_link_star_cap
    CHECK (link_star_cap >= 1 AND link_star_cap <= 10);

UPDATE dm_datamoons
SET link_exp = LEAST(link_exp, 30000),
    link_star_cap = 5,
    link_max_unlocked = 0,
    link_max_unlocked_at = NULL;
```

The update deliberately normalizes current Code-form Datamoons to the five-star
cap under the new individual-cost curve. Future permanent evolution unlocks
promote `link_star_cap` to `7` (Nex) and `10` (Omega); temporary transformation
must never lower it. Run the coordinated updater only after this SQL succeeds.

The beta dungeon day resets at midnight in Brasilia (`03:00 UTC`). Existing VM
environment files override application defaults, so both
`datamoon-api.env` and `datamoon-server.env` must contain:

```env
DATAMOON_SERVER_RESET_HOUR_UTC=3
```

Restart through the coordinated updater after changing this value.

### Choosing The Deployment Path

Use the coordinated deployment above whenever a release changes more than the
Web application, or changes any Web dependency outside its repository. This
includes MySQL API contracts, Auth/Gateway behavior, database migrations,
Nginx, systemd units, environment/secrets, Node.js dependencies or files under
`datamoon-online-agent/ops`. It is the default and safest release path.

A Web-only deployment is allowed only when the intended commit changes files
inside `datamoon-online-web`, keeps the existing API contract and runtime
configuration, and requires no dependency installation. It restarts only
`datamoon-web.service`; game sessions, Auth, Gateway, API and game workers stay
online. Run the following as root:

```bash
WEB_REPO=/opt/datamoon/datamoon-online-web
exec 9>/var/lock/datamoon-deploy.lock
flock -n 9
test -z "$(git -C "$WEB_REPO" status --porcelain)"
PREVIOUS_WEB_COMMIT="$(git -C "$WEB_REPO" rev-parse HEAD)"
git -C "$WEB_REPO" switch main
git -C "$WEB_REPO" pull --ff-only origin main
node --check "$WEB_REPO/src/app.js"
systemctl restart datamoon-web.service
systemctl is-active --quiet datamoon-web.service
curl --fail --silent --show-error http://127.0.0.1:3101/health
journalctl -u datamoon-web.service --since "2 minutes ago" --no-pager
git -C "$WEB_REPO" rev-parse --short HEAD
flock -u 9
```

Stop immediately if the clean-tree check, fast-forward pull or syntax check
fails. If activation or health validation fails after the pull, inspect the
journal and roll back the exact Web commit captured above:

```bash
git -C "$WEB_REPO" reset --hard "$PREVIOUS_WEB_COMMIT"
node --check "$WEB_REPO/src/app.js"
systemctl restart datamoon-web.service
systemctl is-active --quiet datamoon-web.service
curl --fail --silent --show-error http://127.0.0.1:3101/health
flock -u 9
```

The hard reset is safe here only because the procedure first proved that this
specific repository was clean and the target is an exact commit captured in the
same shell. Never use this rollback against a dirty tree or a broad directory.
Changing only `MAINTENANCE_MODE` or `REGISTRATION_ENABLED` in the existing Web
environment file is not a code deployment; restart `datamoon-web.service` and
validate health after the edit.

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
TRANSACTIONAL_EMAIL_ENABLED=false
```

`REGISTRATION_ENABLED=false` removes the registration link and returns `404`
for both `GET` and `POST /register`. This controls only the website; disabling
account creation in the game client requires a coordinated Auth/Gateway/API
control. `MAINTENANCE_MODE=true` keeps `/health` available but returns a public
maintenance page with HTTP `503` and `Retry-After` for every user route. Restart
`datamoon-web.service` after changing either value.

Registration fails closed at startup if it is enabled while transactional
e-mail is disabled. To activate account e-mail after SES is ready, set:

```env
TRANSACTIONAL_EMAIL_ENABLED=true
DATAMOON_MAILER_SOCKET=/run/datamoon-mailer/mailer.sock
AWS_REGION=us-east-1
SES_FROM_EMAIL=no-reply@datamoononline.com.br
SES_FROM_NAME=Datamoons Online
SUPPORT_NOTIFICATION_EMAIL=datamoon.game+support@gmail.com
```

The SES identity, DKIM and custom MAIL FROM must all be `SUCCESS`. While SES is
in sandbox, only verified recipients can receive mail; keep public registration
closed. The EC2 role may call `ses:SendEmail` only when `ses:FromAddress` is
exactly `no-reply@datamoononline.com.br`. `Resource: "*"` is required while SES
evaluates verified sandbox recipients; the From condition prevents sender
spoofing. Never put AWS keys in either environment file.

### Account E-mail Lifecycle

The MySQL API owns verification, reset and e-mail-change state. Public tokens
contain 32 random bytes, expire after 15 minutes, are single-use and are stored
only as SHA-256 hashes. Authenticated password and e-mail changes use six-digit
codes sent to the current address. Codes expire after 10 minutes, permit at most
five attempts, replace prior challenges of the same purpose and are also stored
only as SHA-256 hashes. Pending passwords are persisted only as bcrypt hashes.
Authenticated challenges use a 60-second cooldown and a limit of five deliveries
per purpose and address per day. Public recovery limits remain separate. A new
challenge invalidates the previous code; consuming it does not erase rate-limit
history.
Password/e-mail changes increment `credential_version`, which
invalidates every existing signed account session. An already-consumed gameplay
ticket remains governed by the worker lease until disconnect. Public request
responses are generic and do not reveal whether an account exists.

Persistent emission limits are three requests per target per 24 hours, one per
target per 15 minutes, three per source hash per 15 minutes and 100 actual
deliveries globally per 24 hours. The mailer independently caps itself at 100
deliveries/day, ten account messages per recipient/day and 50 support messages
per recipient/day. Support traffic never consumes the recipient quota reserved
for account security. Nginx limits e-mail endpoints to
three requests/minute. Token landing routes have Nginx access logging disabled
because query strings contain credentials; application logs also exclude token,
password, e-mail and raw IP values.

Password changes require the current password and a code delivered to the
current e-mail. E-mail changes require the current password, a code delivered to
the old address and then a single-use link delivered to the new address. The
database address changes only after the new-address link is confirmed.

E-mail-link `GET` only renders a confirmation page. Token consumption happens
on same-origin `POST` with CSRF, preventing mail scanners from confirming or
resetting accounts while previewing a link.

### Support Desk

The account portal includes an authenticated support desk. The MySQL API is the
authority for ticket ownership, staff authorization and every state mutation.
The Web service renders forms, validates same-origin CSRF and calls only scoped
support routes. A normal account can list, read and reply only to its own
tickets. Accounts mirrored with `dm_users.is_admin=1` in the game database see
the administrative queue and can update status, priority and assignment.

Ticket IDs contain 64 random bits and use `DM-XXXXXXXXXXXXXXXX`. New tickets are
limited to five per account per 24 hours and replies to ten per account per
minute. Subjects contain 4-120 bytes, messages contain 2-4096 bytes and
attachments are intentionally unavailable. A response carries at most the 12
latest messages so the existing 64 KiB Web/API contract cannot be exceeded.
The portal indicates when older history exists.

Support content is stored only in `dm_support_messages`. Journald receives the
ticket ID, actor user ID, role, action, state and result, never message bodies or
e-mail addresses. `dm_support_events` stores state/priority changes separately
from conversation content. There is no automatic deletion during beta; define
the legal/privacy retention period before public production, then delete only
closed tickets in bounded batches. Cascading foreign keys remove their messages
and events together.

SES sends notifications but does not receive ticket replies. Every message
links back to `/support/ticket`, where the authenticated player responds. New
tickets and player replies notify `SUPPORT_NOTIFICATION_EMAIL`; administrator
replies and state changes notify the account's current e-mail. A mail failure is
logged without rolling back the already-persisted ticket action.

The Web remains server-rendered. Shared account styles stay in `account.css`,
support-specific styles stay in `support.css`, and the router concatenates them
into one cached `/styles.css` response. Pages do not receive JavaScript unless a
future interaction genuinely requires client-side behavior.

Validate manually with one normal and one admin account:

- create up to one ticket in each category and confirm ownership isolation;
- confirm another normal account receives `404` for the ticket ID;
- reply as player and observe `waiting_support`;
- reply as admin and observe `waiting_player` plus an account notification;
- change priority, assign the ticket, resolve, close and confirm closed replies
  return `409`;
- confirm the sixth ticket in 24 hours and eleventh reply in one minute return
  `429`;
- inspect `journalctl -u datamoon-web -u datamoon-mailer -u datamoon-api` and
  verify that message content and e-mail addresses are absent.

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

### Web Spam And Brute-Force Protection

The beta Web entry point uses layered limits. Nginx accepts an average of 10
authentication requests per minute per source IP, with a burst of 10, and caps
each IP at 20 simultaneous Web connections. The application blocks an IP for
15 minutes after 30 login attempts in a 15-minute window and blocks a target
account for 15 minutes after 8 invalid passwords in the same window. Public
registration is disabled; if it is deliberately enabled later, its application
limit is 5 attempts per IP per hour followed by a one-hour block.

Application and Nginx blocks return HTTP `429`. Check both protection layers:

```bash
journalctl -u datamoon-web.service --since "1 hour ago" --no-pager | grep 'rate_limit'
grep -i 'limiting requests' /var/log/nginx/error.log | tail -n 100
```

Residual risks are accepted only for closed beta: application counters are
in-memory and reset with the Web process; a distributed attack can rotate many
IP addresses; and repeated failures against a known username can intentionally
deny that user access. AWS Security Groups restrict ports but do not provide
HTTP brute-force detection.

Before public production, connect remaining structured events to external
operator notifications and place distributed rate limiting/WAF protection at
the public edge and use a shared limiter such as Redis if multiple Web instances
are deployed. Review account-target limits so attackers cannot maintain an
indefinite victim lockout. Never create automatic permanent IP bans: residential
and mobile addresses are commonly shared or reassigned; prefer temporary,
progressive blocks with an operator-visible audit trail.

Password recovery, e-mail verification and confirmed e-mail changes are
implemented, deployed and manually validated. SES production access, domain
identity, DKIM and custom MAIL FROM were confirmed in 2026-08. Fail2ban uses
15-minute temporary bans after repeated Nginx rate-limit violations and is
installed and validated with:

```bash
sudo /opt/datamoon/datamoon-online-agent/ops/install_vm_security.sh
sudo fail2ban-client status datamoon-web-rate-limit
```

The following controls remain deferred:

- Database backup: before production, implement automated encrypted MySQL
  backups, off-host retention, restricted restore credentials and a tested
  restore procedure. A backup that has not been restored in a drill is not a
  verified backup.
- OS/runtime patching: Ubuntu, Node.js and Nginx updates remain manual for beta.
  Record the installed versions, review security advisories, take/verify a
  backup, patch in a maintenance window and run the release verification list.
- Admin application: expose scoped, paginated audit queries for inventory,
  rewards, Guild and moderation without granting generic database access.
- Online index scaling: replace deeper local character scans only when measured
  concurrency shows the current lookup cost is material.
- Production edge hardening: WAF/distributed rate limiting remains future work.
  Redis/shared limiter state is needed only when more than one Web instance is
  deployed; encrypted local sessions remain appropriate for the current single VM.

### Manual Account Validation

Run this matrix before enabling registration: new account receives verification,
unverified login is rejected, confirmation works once, repeated/expired links
fail, unknown reset requests look identical, password reset revokes old sessions,
password change requires the current password plus the current-address code,
wrong codes lock after five attempts, e-mail change requires the old-address code
and new-address link, and all account sessions are revoked afterward. Confirm that
`journalctl -u datamoon-web -u datamoon-mailer -u datamoon-api` contains only
event names/user IDs and never token, password, address or raw IP data.

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

### Manual social validation

For Chat and Party changes, validate at minimum:

- the fifth message in two seconds is blocked with a two-second timeout and a
  remaining-seconds message;
- slow mode allows one message every two seconds and reports the remaining wait;
- mute persists through reconnect/restart and unmute restores sending;
- a normal disconnect removes party membership after the configured lifecycle;
- an overworld-to-dungeon handoff preserves membership and shows remote members
  gray without an `OFFLINE` label;
- handoff failure logs identify reservation, source, target, session, party version
  and rollback outcome without exposing tickets or tokens.

The game database owns account administrator status. After migration `029` is
applied, grant or revoke access by username; never identify administrators by a
character name or environment allowlist:

```sql
UPDATE dm_users SET is_admin = 1 WHERE username = 'YOUR_ACCOUNT';
UPDATE dm_users SET is_admin = 0 WHERE username = 'YOUR_ACCOUNT';
```

Available in-game commands are `/mute Player duration_ms|permanent [reason]`,
`/unmute Player`, `/slow channel [milliseconds]`, and `/normal channel`. Every
command is re-authorized by the MySQL API against `dm_users.is_admin` and audited.

### Manual gameplay persistence validation

For Equipment, Fishing, Hatchery and recipe activity changes, validate at minimum:

- clicking a filled Equipment NPC slot clears only the UI selection;
- a material slot displays the sum of all matching inventory stacks and continues
  with the next stack when the selected row is consumed;
- upgrade/alternate consume exactly one material and preserve generated metadata;
- stale or repeated Fishing session IDs do not grant a second reward;
- a repeated Hatchery claim with the same operation ID returns the cached result;
- Craft and Cooking use their domain catalogs through the shared recipe engine;
- inventory, reward and mutation logs include the operation ID without secrets.

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

The MySQL API retains inventory, reward, value-change, Chat moderation and Guild
audit plus inventory/reward idempotency records for 180 days by default. It
starts cleanup with the API, runs daily and deletes indexed rows in batches of
1,000, up to 20 batches per table per run.
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
                     'dm_value_audit', 'dm_chat_moderation_audit',
                     'dm_guild_audit', 'dm_datamoon_evolution_audit')
ORDER BY total_mb DESC;
```

Third-party asset licenses and their bundled READMEs stay next to the assets and
are not project documentation.
