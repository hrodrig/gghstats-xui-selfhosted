# Docker (`docker run`)

← [Back to run/README](../README.md).

Run **only the xui dashboard** (BFF) without Compose. Point it at a gghstats instance you already run elsewhere (API-only or full serve — the xui only calls `/api/*`).

```bash
docker run -d \
  -e GGHSTATS_API_BASE=https://your-gghstats.example.com \
  -e GGHSTATS_API_TOKEN=your-shared-token \
  -p 3000:3000 \
  --name gghstats-xui \
  ghcr.io/hrodrig/gghstats-xui:v0.1.0
```

- **`GGHSTATS_API_BASE`** — the gghstats base URL (without `/api`), e.g. `https://stats.example.com` or `http://127.0.0.1:8080` for a local api-only backend.
- **`GGHSTATS_API_TOKEN`** — the token the backend requires on `/api/repos` and dogfood routes. Set the same value on the backend via `GGHSTATS_API_TOKEN`.

The image tag must match a published **GHCR** image from [gghstats-xui releases](https://github.com/hrodrig/gghstats-xui/releases) — same value as **`GGHSTATS_XUI_VERSION`** in **[`run/common/.env.example`](../common/.env.example)**.

The container listens on **3000** (`PORT=3000`, already set in the image); bind it to any host port with **`-p host:3000`**.

For the **two-container stack** (gghstats backend + xui on an internal network), use **`run/docker-compose/minimal/`** instead.

---

**[↑ Back to run/README](../README.md)**
