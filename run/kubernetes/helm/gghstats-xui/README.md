# gghstats-xui (Helm chart)

Two Deployments on Kubernetes:

| Resource | Image | Role | Exposed |
|----------|-------|------|---------|
| `…-backend` | `ghcr.io/hrodrig/gghstats:v1.6.6` | gghstats in API-only mode, SQLite on a PVC | ClusterIP only |
| `…-ui` | `ghcr.io/hrodrig/gghstats-xui:v0.1.0` | BFF dashboard | ClusterIP (route it yourself) |

The BFF auto-targets the in-cluster backend at `http://<release>-gghstats-xui-backend:8080` (override via `xui.env.apiBase`). The shared API token is set on both containers from a Secret.

## Install from the Helm repository (recommended)

After the first chart publish (annotated tag **`v*`** on **`main`** → chart-releaser → **`gh-pages`**), install without cloning:

```bash
helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted
helm repo update
helm search repo gghstats-xui -l
```

**Secrets — prefer `existingSecret` over `value`** (don't put tokens in `--set`):

```bash
kubectl create namespace gghstats
kubectl create secret generic gghstats-xui-github-secret -n gghstats \
  --from-literal=github-token=YOUR_GITHUB_TOKEN
kubectl create secret generic gghstats-xui-api-secret -n gghstats \
  --from-literal=api-token=YOUR_SHARED_API_TOKEN

helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.existingSecret=gghstats-xui-github-secret \
  --set apiToken.existingSecret=gghstats-xui-api-secret
```

Use **`helm show values gghstats-xui/gghstats-xui`** for defaults. Pin with **`--version`** from **`helm search`** (chart **`version:`**, not the repo tag). If **`helm repo add`** fails, the index may not be live yet — use **from a git clone** below.

Index: [index.yaml](https://hrodrig.github.io/gghstats-xui-selfhosted/index.yaml) · packages on [Releases](https://github.com/hrodrig/gghstats-xui-selfhosted/releases) as **`gghstats-xui-<chart-version>.tgz`**.

## Install from a git clone

From the repository root of [gghstats-xui-selfhosted](https://github.com/hrodrig/gghstats-xui-selfhosted):

```bash
helm upgrade --install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.existingSecret=gghstats-xui-github-secret \
  --set apiToken.existingSecret=gghstats-xui-api-secret
```

Quick path with inline values (dev only — prefer secrets above):

```bash
helm install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.value=YOUR_GITHUB_TOKEN \
  --set apiToken.value=YOUR_SHARED_API_TOKEN
```

## Routing (Traefik IngressRoute)

The chart ships **no Ingress** — only a `ClusterIP` Service for the UI. Route it yourself. If you run Traefik as your ingress (as in the CBPI stack), apply an `IngressRoute` in the `traefik.io/v1alpha1` group:

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

Replace `my-xui-gghstats-xui-ui` with your release's UI Service name (`<release>-gghstats-xui-ui`). The exact `entryPoints` / `certResolver` names depend on your Traefik deployment — match them to your cluster.

> **CRD group trap:** Traefik v3 watches only `traefik.io/v1alpha1`. If the route silently does nothing, verify the resource lives in that group, not `traefik.containo.us/v1alpha1` (`kubectl get ingressroute.traefik.io -n gghstats`).

**Check:** `kubectl get pods -n gghstats -l app.kubernetes.io/name=gghstats-xui` and your route URL.

**Remove:** `helm uninstall my-xui -n gghstats`

## Configuration

| Key | Default | Purpose |
|-----|---------|---------|
| `gghstats.image.tag` | `v1.6.6` | Backend gghstats image |
| `xui.image.tag` | `v0.1.0` | Dashboard image |
| `gghstats.env.apiOnly` | `"true"` | API-only mode (leave `true`) |
| `gghstats.env.filter` | `"*"` | Repo filter for sync |
| `xui.env.apiBase` | `""` | Override backend URL (empty = in-cluster auto) |
| `gghstats.persistence.*` | 5Gi / RWO | Backend SQLite PVC (`helm.sh/resource-policy: keep`) |
