# Docker Compose minimal

← [Back to run/README](../README.md).

Two containers on an internal network — the default self-hosted path:

- **`gghstats`** — backend in API-only mode (`GGHSTATS_API_ONLY=true`), SQLite in `/data`, **not** exposed to the host.
- **`xui`** — BFF + dashboard. The only public surface, on host port `${XUI_PORT:-3000}`.

```bash
export GGHSTATS_HOST_DATA=/home/gghstats/gghstats-data
mkdir -p "$GGHSTATS_HOST_DATA"
cp run/common/.env.example "${GGHSTATS_HOST_DATA}/.env"
# Edit "${GGHSTATS_HOST_DATA}/.env": GGHSTATS_GITHUB_TOKEN, GGHSTATS_API_TOKEN,
# and GGHSTATS_HOST_DATA (same absolute path as above).

docker compose --env-file "${GGHSTATS_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml up -d
```

**Check:** `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/` (or your `XUI_PORT`).

**Remove:**

```bash
docker compose --env-file "${GGHSTATS_HOST_DATA}/.env" -f run/docker-compose/minimal/docker-compose.yml down
```

## Notes

- The internal network is **`internal: true`** — the `gghstats` container has no outbound/inbound path from the host except through the `xui` BFF. This means `GITHUB_TOKEN` sync and the API are reachable only via the BFF.
- The **shared `GGHSTATS_API_TOKEN`** must be identical in both containers; otherwise the BFF gets `403` from the backend on proxied `/api/*` calls.
- `GGHSTATS_HOST_DATA` is bind-mounted to `/data` on the gghstats container (SQLite).

---

**[↑ Back to run/README](../README.md)**
