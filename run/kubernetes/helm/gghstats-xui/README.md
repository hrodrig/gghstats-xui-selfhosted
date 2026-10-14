# gghstats-xui (Helm chart)

| Resource | Image | Role | Exposed |
|----------|-------|------|---------|
| `…-backend` | `ghcr.io/hrodrig/gghstats:v1.6.6` | gghstats API-only + SQLite PVC | ClusterIP only (**optional**) |
| `…-ui` | `ghcr.io/hrodrig/gghstats-xui:v0.1.3` | BFF dashboard | ClusterIP (route it yourself) |

**Modes:**

| Mode | Values | Secrets |
|------|--------|---------|
| **In-cluster backend** (default) | `gghstats.enabled: true` | GitHub PAT **and** shared API token |
| **UI-only** → external gghstats (other VPS / network) | `gghstats.enabled: false` + `xui.env.apiBase` | Shared API token **only** (must match remote gghstats) |

Default: BFF targets `http://<release>-gghstats-xui-backend:8080`. Example UI-only values: [`../../examples/values.ui-only.example.yaml`](../../examples/values.ui-only.example.yaml).

### Chart scope (what Helm installs)

UI Deployment always. Backend Deployment / Service / PVC / GitHub Secret wiring only when **`gghstats.enabled`**. Image/env values.

### Out of scope (not in the chart)

**Ingress / IngressRoute**, DNS, TLS, cert resolvers, and the auth front door. Keep those in your own files (outside this repo). Clear Traefik example: [`../../examples/traefik-ingressroute.yaml`](../../examples/traefik-ingressroute.yaml).

## Operator path (Kubernetes)

### 1. Prerequisites

- Kubernetes cluster + **Helm 3**
- An ingress controller if the UI is public (this guide’s example uses **Traefik v3** / `traefik.io/v1alpha1`) — **you** configure it; the chart does not
- DNS for your UI hostname → Traefik load balancer (your ops, not this chart)
- Shared API token (always). [GitHub PAT](https://github.com/hrodrig/gghstats/blob/main/README.md) only if **`gghstats.enabled: true`**

### 2. Namespace and Secrets

Prefer **`existingSecret`** over putting tokens in `--set`.

**In-cluster backend** (default — needs PAT for the chart’s gghstats):

```bash
kubectl create namespace gghstats
kubectl create secret generic gghstats-xui-github-secret -n gghstats \
  --from-literal=github-token=YOUR_GITHUB_TOKEN
kubectl create secret generic gghstats-xui-api-secret -n gghstats \
  --from-literal=api-token=YOUR_SHARED_API_TOKEN
```

**UI-only** (external gghstats already has its own PAT elsewhere — skip the GitHub secret here):

```bash
kubectl create secret generic gghstats-xui-api-secret -n gghstats \
  --from-literal=api-token=SAME_TOKEN_AS_REMOTE_GGHSTATS
```

### 3. Install the chart (personal data directory)

Keep operator files under **`~/gghstats-xui-selfhosted-data/`** (same idea as Compose **`GGHSTATS_HOST_DATA`**: outside the clone). Day-to-day: no edits to this repository.

#### Recommended — Helm repository (GitHub Pages)

Published packages + [index.yaml](https://hrodrig.github.io/gghstats-xui-selfhosted/index.yaml) on Pages / [Releases](https://github.com/hrodrig/gghstats-xui-selfhosted/releases) as **`gghstats-xui-<chart-version>.tgz`**.

```bash
helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted
helm repo update
helm search repo gghstats-xui/gghstats-xui --versions | head

mkdir -p ~/gghstats-xui-selfhosted-data
cp run/kubernetes/examples/values.example.yaml ~/gghstats-xui-selfhosted-data/values.yaml
# edit ~/gghstats-xui-selfhosted-data/values.yaml — secrets refs, optional image tags

helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats --create-namespace \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
# optional pin: --version 0.2.0
```

Use **`helm show values gghstats-xui/gghstats-xui`** for defaults. Chart **`version:`** ≠ this repo’s Git tag **`v*`**.

#### Alternative — chart path from a git clone

Same values file. Useful before a chart version is on Pages, or while iterating on templates:

```bash
git clone https://github.com/hrodrig/gghstats-xui-selfhosted.git
cd gghstats-xui-selfhosted
# checkout the branch / tag that has the chart version you want

helm upgrade --install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
```

Production installs should prefer the **Helm repository** once the chart version is published.

### 4. Route the UI (out of chart scope)

Copy the example IngressRoute into the same personal directory, set host / service name / `certResolver`, apply:

```bash
cp run/kubernetes/examples/traefik-ingressroute.yaml ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
# edit: Host(`xui.example.com`), my-xui-gghstats-xui-ui, entryPoints, certResolver
kubectl apply -f ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
```

Example shape (placeholders — full file: [`../../examples/traefik-ingressroute.yaml`](../../examples/traefik-ingressroute.yaml)):

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: gghstats-xui
  namespace: gghstats
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host(`xui.example.com`)
      services:
        - name: my-xui-gghstats-xui-ui
          port: 3000
  tls:
    certResolver: your-resolver
```

- Service name = **`<release>-gghstats-xui-ui`** (release `my-xui` → `my-xui-gghstats-xui-ui`).
- **`entryPoints`** / **`certResolver`** must match your Traefik deployment.
- Other ingress (nginx, Gateway API, etc.): point at the same UI Service port **3000**.

> **CRD group trap:** Traefik v3 watches only `traefik.io/v1alpha1`. If the route silently does nothing, check `kubectl get ingressroute.traefik.io -n gghstats` — not `traefik.containo.us`.

### 5. Verify

```bash
kubectl get pods -n gghstats -l app.kubernetes.io/name=gghstats-xui
kubectl get svc -n gghstats -l app.kubernetes.io/name=gghstats-xui
# Then open https://xui.example.com (your host)
```

### 6. Auth boundary (public hosts)

The BFF allowlists `/api/*` paths and keeps the API token server-side, but it is **not** a login wall. If the hostname is public, put **Cloudflare Access**, reverse-proxy basic auth, or equivalent **in front** of Traefik (or as Traefik middleware).

### 7. Uninstall

```bash
helm uninstall my-xui -n gghstats
kubectl delete -f ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml   # if you applied it
# PVC may remain (helm.sh/resource-policy: keep) — delete manually if you want data gone
```

## Configuration

| Key | Default | Purpose |
|-----|---------|---------|
| `gghstats.enabled` | `true` | Deploy in-cluster gghstats; `false` = UI-only + require `xui.env.apiBase` |
| `gghstats.image.tag` | `v1.6.6` | Backend gghstats image |
| `xui.image.tag` | `v0.1.3` | Dashboard image |
| `gghstats.env.apiOnly` | `"true"` | API-only mode (leave `true` when backend enabled) |
| `gghstats.env.filter` | `"*"` | Repo filter for sync |
| `xui.env.apiBase` | `""` | External gghstats URL (required if `gghstats.enabled=false`) |
| `gghstats.persistence.*` | 5Gi / RWO | Backend SQLite PVC (`helm.sh/resource-policy: keep`) |
