# Changelog

All notable changes to **gghstats-xui-selfhosted** (deployment manifests, docs, and tooling for this repository only) are documented here. For the applications, see [gghstats-xui CHANGELOG](https://github.com/hrodrig/gghstats-xui/blob/main/CHANGELOG.md) and [gghstats CHANGELOG](https://github.com/hrodrig/gghstats/blob/main/CHANGELOG.md).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Document **Helm repo** install from GitHub Pages (`helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted`).
- Harden **Release Charts**: `skip_existing`, bootstrap **`.nojekyll`** on first **`gh-pages`**.
- **Kubernetes operator path:** step-by-step chart README (secrets → helm → route → verify → auth → uninstall).
- Document **Ingress / IngressRoute as out of chart scope**; examples to copy outside the clone: [`values.example.yaml`](run/kubernetes/examples/values.example.yaml) + [`traefik-ingressroute.yaml`](run/kubernetes/examples/traefik-ingressroute.yaml) (generic `xui.example.com`).
- Root README **Pick a path** + hero [`assets/gghstats-xui-selfhosted-hero.png`](assets/gghstats-xui-selfhosted-hero.png); gitignore allowlist for **`assets/`**.

## [0.1.0] - 2026-10-12

### Added

- **`run/`** layout: `common/`, `docker/`, `docker-compose/minimal/`.
- **Two-container Compose stack** — `gghstats` (API-only backend, internal network) + `xui` (BFF dashboard, host port 3000), sharing an `internal: true` bridge network.
- **Helm chart** ([`run/kubernetes/helm/gghstats-xui`](run/kubernetes/helm/gghstats-xui)) — two Deployments (`…-backend` + `…-ui`), PVC for backend SQLite, shared API token in a Secret, no Ingress (route it yourself; README documents a Traefik `IngressRoute` example).
- **Shared env template** ([`run/common/.env.example`](run/common/.env.example)) — gghstats backend vars (`GGHSTATS_VERSION`, `GGHSTATS_API_ONLY=true`, `GGHSTATS_API_TOKEN`, `GGHSTATS_GITHUB_TOKEN`, filter/sync) and xui vars (`GGHSTATS_XUI_VERSION`, `XUI_PORT`).
- **`docker run`** docs for running the xui BFF alone against an external gghstats.
- Root README, run/README, per-stack READMEs, `VERSION`, `data/.keep`, and `.gitignore` (deny-all with allowlist).

[Unreleased]: https://github.com/hrodrig/gghstats-xui-selfhosted/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hrodrig/gghstats-xui-selfhosted/releases/tag/v0.1.0
