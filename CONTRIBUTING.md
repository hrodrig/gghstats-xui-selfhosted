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

## Helm chart publish (GitHub Pages)

**`helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted`** expects **`index.yaml`** and **`gghstats-xui-<chart-version>.tgz`** on the **`gh-pages`** branch.

- **Automation:** [`.github/workflows/release-charts.yml`](.github/workflows/release-charts.yml) runs [chart-releaser](https://github.com/helm/chart-releaser-action) on annotated tag **`v*`** pushed to **`main`** (aligned with root **`VERSION`**). Packages the chart, creates a GitHub Release artifact, updates **`gh-pages`**. **`workflow_dispatch`** available for re-runs.
- **One-time setup:** **Settings → Pages → Build and deployment → Source:** branch **`gh-pages`**, folder **`/` (root)**. The workflow bootstraps **`gh-pages`** on first publish if missing.
- **“No chart changes detected”:** normal for docs/Compose-only tags. chart-releaser only publishes when **`run/kubernetes/helm/`** changed vs the previous chart baseline. To ship a new **`.tgz`**, bump **`Chart.yaml` `version:`**, merge, tag again.
