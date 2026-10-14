# How to run gghstats-xui (self-hosted)

← [Back to the repository README](../README.md).

Pick a mode below. Commands are documented in each subdirectory's `README.md`.

| Directory | When to use |
|-----------|-------------|
| [`common/`](common/) | Shared **environment template** for Compose. Copy to **`${GGHSTATS_HOST_DATA}/.env`**, set **`GGHSTATS_HOST_DATA`** inside that file, then `docker compose --env-file "${GGHSTATS_HOST_DATA}/.env" -f …` from the clone root (see [`common/.env.example`](common/.env.example)). |
| [`docker/`](docker/) | **`docker run`** with the GHCR xui image — dashboard only, pointing at an external gghstats. |
| [`docker-compose/minimal/`](docker-compose/minimal/) | **Two-container stack** — gghstats (API-only) + xui (BFF), internal network. The default self-hosted path. |
| [`kubernetes/helm/`](kubernetes/helm/) | **Helm chart** — two Deployments + PVC + Secret. No Ingress (route it yourself). |
| [`kubernetes/examples/`](kubernetes/examples/) | **Beside the chart** — e.g. Traefik `IngressRoute` → UI Service. |
Always use published image tags that match your desired releases:

- **`GGHSTATS_VERSION`** → [gghstats](https://github.com/hrodrig/gghstats/releases) backend image tag (e.g. `v1.6.6`).
- **`GGHSTATS_XUI_VERSION`** → [gghstats-xui](https://github.com/hrodrig/gghstats-xui) dashboard image tag (e.g. `v0.1.0`).

**Upgrade:** edit the matching var in **`${GGHSTATS_HOST_DATA}/.env`**, then **`pull`** + **`up -d`** (recreate). `restart` does not swap images.

---

**[↑ Back to the repository README](../README.md)**
