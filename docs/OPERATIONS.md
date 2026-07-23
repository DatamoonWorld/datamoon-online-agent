# Runtime And VM Operations

This is the canonical operational reference. Runtime repositories must keep only
machine-readable examples such as `.env.example` and systemd unit files.

## Service Layout

- `/opt/datamoon/datamoon-online-mysqlapi`: Go persistence API, loopback `3000`.
- `/opt/datamoon/datamoon-online-auth`: Godot Auth, loopback UDP `5200`.
- `/opt/datamoon/datamoon-online-gateway`: Godot WebSocket gateway, public WSS.
- `/opt/datamoon/datamoon-online-server`: Godot ENet workers.
- `/opt/datamoon/datamoon-online-web`: optional web portal, loopback `3101`.

Systemd units are `datamoon-api`, `datamoon-auth`, `datamoon-gateway`,
`datamoon-server@overworld` and `datamoon-server@dungeon-1`. The legacy
non-templated `datamoon-server.service` must remain disabled.

## Required Security Configuration

- MySQL API listens on `127.0.0.1:3000`.
- Auth binds `127.0.0.1:5200`.
- Gateway production uses a DNS name, valid certificate and `wss://`.
- Client production sets `DATAMOON_GATEWAY_URL=wss://<gateway-domain>:5100`.
- Gateway sets `DATAMOON_GATEWAY_REQUIRE_TLS=true`, bind `0.0.0.0`, certificate
  and private-key paths. Local development may use `ws://127.0.0.1:5100`.
- API uses unique `INTERNAL_API_AUTH_TOKEN`, `INTERNAL_API_GATEWAY_TOKEN`,
  `INTERNAL_API_SERVER_TOKEN` and `INTERNAL_API_WEB_TOKEN`.
  `INTERNAL_API_TOKEN` is only a rollout fallback.
- Each Godot service receives only its corresponding token through
  `DATAMOON_INTERNAL_API_TOKEN`.
- Database, API, Auth and observability ports are blocked from the public network.

## Coordinated Update

Install `ops/update_vm.sh` from the agent repository and invoke it through the
provided oneshot unit. It performs an exclusive lock, remote fetch, clean-tree
preflight, exact `origin/pbe` checkout for every VM repository, Godot imports,
Web syntax checks, Go tests/vet/build, ordered restart, readiness checks and
code/binary rollback on activation failure.

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
4. Confirm Gateway certificate validity and that remote `ws://` is rejected.
5. Exercise register, login, ticket consume, character join and one dungeon
   handoff before opening the deployment to players.
6. Rotate leaked historical DB/API credentials before production promotion.

## Local Validation

- Godot: headless editor import for Auth, Gateway, Server and Client.
- Server: `tools/run_quality_gates.ps1` with `GODOT_BIN` configured.
- Client: `tests/p1_snapshot_client_test.tscn`.
- API: `go test ./...`, `go vet ./...`, then `go build -trimpath ./cmd/api`.
- Web: run Node syntax/tests defined by the repository package.

Third-party asset licenses and their bundled READMEs stay next to the assets and
are not project documentation.
