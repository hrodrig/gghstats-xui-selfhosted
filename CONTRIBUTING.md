# Contributing to gghstats-xui-selfhosted

## Branch policy

- Integration branch: **`develop`**
- Production snapshots: **`main`**
- Day-to-day: topic branch (`feature|fix|chore|docs|security/<name>`) → **PR into `develop`**
- Release: **PR `develop` → `main`**, then annotated tag **`v<semver>`** on `main` (matches root `VERSION`)
- **Never** push directly to `develop` or `main`. **No `uat`.**

See `make gitflow` and [AGENTS.md](AGENTS.md).

## Scope

This repo holds **deployment manifests only** (Compose, Helm, operator docs). Application code lives in [gghstats-xui](https://github.com/hrodrig/gghstats-xui) and [gghstats](https://github.com/hrodrig/gghstats).

## Checks

Before opening a PR that touches Compose/Helm:

```bash
make release-check
```

## Versioning

Keep **`VERSION`**, image pins (`GGHSTATS_XUI_VERSION`, `GGHSTATS_VERSION`), and Helm **`Chart.yaml` `version:` / `appVersion`** distinct — see AGENTS.md.
