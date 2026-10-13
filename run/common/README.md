# Shared environment (`run/common`)

← [Back to run/README](../README.md).

**This is the operator configuration template for the two-container stack** — gghstats backend (API-only) and xui dashboard (BFF), image tags, filters, sync, ports, and the shared API token.

Copy **[`.env.example`](.env.example)** to **`${GGHSTATS_HOST_DATA}/.env`** on the host (same directory as SQLite — outside the git clone). Set **`GGHSTATS_HOST_DATA`** in that file to the same absolute path, then run Compose with **`docker compose --env-file "${GGHSTATS_HOST_DATA}/.env" -f …`** from the repository root.

The template covers:

- **gghstats** — GitHub token, demo mode, API-only mode, API token, filter, sync interval, image tag (`GGHSTATS_VERSION`)
- **gghstats-xui** — image tag (`GGHSTATS_XUI_VERSION`) and host port (`XUI_PORT`)
- **Compose layout** — `GGHSTATS_HOST_DATA` (host path for SQLite)

**Two tokens, don't confuse them:**

- **`GGHSTATS_GITHUB_TOKEN`** — a GitHub PAT (classic or fine-grained, repo read scope). Lets gghstats sync traffic data. Not needed in demo mode.
- **`GGHSTATS_API_TOKEN`** — a shared secret you invent (e.g. `openssl rand -hex 32`). Must be **identical** in both the gghstats backend and the xui BFF; the BFF presents it as `x-api-token` on every proxied request. This is what keeps `/api/` from being called directly without auth.

---

**[↑ Back to run/README](../README.md)**
