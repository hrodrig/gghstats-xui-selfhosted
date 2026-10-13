# Agent Guidelines (gghstats-xui-selfhosted)

- Use **English** for project artifacts (manifests, docs, commit messages, README).
- **Gitflow = same as [gghstats-selfhosted](https://github.com/hrodrig/gghstats-selfhosted)** / [gghstats](https://github.com/hrodrig/gghstats):
  - Work on **topic branches** from `develop` (`feature|fix|chore|docs|security/<name>`).
  - Land via **PR → `develop`**. Never commit or push directly to `develop` or `main`.
  - Ship: **PR `develop` → `main`**, then annotated tag `v*` on `main` (repo `VERSION`).
  - **No `uat`.** Marketing webs / GitLab only.
- **Never** merge to `main` or push a `v*` tag without **explicit user approval** in the current conversation.
- Show the proposed commit message and get approval before `git commit`.
- Out-of-date PR: `gh pr update-branch <N>` — not a local merge onto protected branches.

## Version names (do not mix)

| Name | Meaning |
|------|---------|
| Root **`VERSION`** + README badge + Git tag **`v*`** | Snapshot of **this** repo (manifests/docs). Semver **without** `v` in the file. |
| **`Chart.yaml` `version:`** | Helm **package** semver. Bump **only** when `run/kubernetes/helm/gghstats-xui/` should publish a new chart. May lag repo `VERSION`. |
| **`GGHSTATS_XUI_VERSION` / ui `image.tag` / `Chart.yaml` `appVersion`** | **gghstats-xui** image on GHCR (`ghcr.io/hrodrig/gghstats-xui:v0.1.0`). Align with a **published** [gghstats-xui](https://github.com/hrodrig/gghstats-xui/releases) tag (`v` prefix in env/image; `appVersion` often without `v`). |
| **`GGHSTATS_VERSION` / backend `image.tag`** | **gghstats** backend image on GHCR. Independent of this repo’s `VERSION`. |

## Pins after app releases

- After **gghstats-xui** ships: topic PR updating `GGHSTATS_XUI_VERSION`, Helm ui `image.tag` / `appVersion`, docs. Bump chart `version:` only if Helm templates/values structure changed.
- After **gghstats** ships (when this stack should follow): same for `GGHSTATS_VERSION` / backend tag.

## Validation

- Run `make gitflow` for the step list.
- Gate: `make release-check` (`docker compose … config`, `helm lint` / `helm template` when Helm is installed).
- **`.cursor/` is local-only** — keep shared policy in this `AGENTS.md`, `CONTRIBUTING.md`, and README.
