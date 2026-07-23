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

Third-party asset licenses and their bundled READMEs stay next to the assets and
are not project documentation.
