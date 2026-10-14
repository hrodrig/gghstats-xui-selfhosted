# gghstats-xui (Helm chart)

Two Deployments on Kubernetes:

| Resource | Image | Role | Exposed |
|----------|-------|------|---------|
| `…-backend` | `ghcr.io/hrodrig/gghstats:v1.6.6` | gghstats in API-only mode, SQLite on a PVC | ClusterIP only |
| `…-ui` | `ghcr.io/hrodrig/gghstats-xui:v0.1.0` | BFF dashboard | ClusterIP (route it yourself) |

The BFF auto-targets the in-cluster backend at `http://<release>-gghstats-xui-backend:8080` (override via `xui.env.apiBase`). The shared API token is set on both containers from a Secret.

The chart ships **no Ingress** — only ClusterIP Services. You add routing (see step 4).

## Operator path (Kubernetes)

### 1. Prerequisites

- Kubernetes cluster + **Helm 3**
- An ingress controller (this guide uses **Traefik v3** with `traefik.io/v1alpha1`)
- DNS for your UI hostname pointing at the Traefik load balancer
- A [GitHub PAT](https://github.com/hrodrig/gghstats/blob/main/README.md) for traffic sync, and a shared API token (any strong secret both containers will use)

### 2. Namespace and Secrets

Prefer **`existingSecret`** over putting tokens in `--set`:

```bash
kubectl create namespace gghstats
kubectl create secret generic gghstats-xui-github-secret -n gghstats \
  --from-literal=github-token=YOUR_GITHUB_TOKEN
kubectl create secret generic gghstats-xui-api-secret -n gghstats \
  --from-literal=api-token=YOUR_SHARED_API_TOKEN
```

### 3. Install the chart

**From the Helm repository (recommended):**

```bash
helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted
helm repo update
helm search repo gghstats-xui -l

helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.existingSecret=gghstats-xui-github-secret \
  --set apiToken.existingSecret=gghstats-xui-api-secret
```

Use **`helm show values gghstats-xui/gghstats-xui`** for defaults. Pin with **`--version`** from **`helm search`** (chart **`version:`**, not the repo Git tag).

Index: [index.yaml](https://hrodrig.github.io/gghstats-xui-selfhosted/index.yaml) · packages on [Releases](https://github.com/hrodrig/gghstats-xui-selfhosted/releases) as **`gghstats-xui-<chart-version>.tgz`**.

**From a git clone** (if the index is not live yet, or you are editing templates):

```bash
helm upgrade --install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.existingSecret=gghstats-xui-github-secret \
  --set apiToken.existingSecret=gghstats-xui-api-secret
```

Dev-only inline values (avoid in production):

```bash
helm install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  --set gghstats.githubToken.value=YOUR_GITHUB_TOKEN \
  --set apiToken.value=YOUR_SHARED_API_TOKEN
```

### 4. Route the UI (Traefik IngressRoute example)

Copy and edit the example manifest, then apply:

```bash
# Edit: Host(), service name (<release>-gghstats-xui-ui), entryPoints, certResolver
kubectl apply -f run/kubernetes/examples/traefik-ingressroute.yaml
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
kubectl delete -f run/kubernetes/examples/traefik-ingressroute.yaml   # if you applied it
# PVC may remain (helm.sh/resource-policy: keep) — delete manually if you want data gone
```

## Configuration

| Key | Default | Purpose |
|-----|---------|---------|
| `gghstats.image.tag` | `v1.6.6` | Backend gghstats image |
| `xui.image.tag` | `v0.1.0` | Dashboard image |
| `gghstats.env.apiOnly` | `"true"` | API-only mode (leave `true`) |
| `gghstats.env.filter` | `"*"` | Repo filter for sync |
| `xui.env.apiBase` | `""` | Override backend URL (empty = in-cluster auto) |
| `gghstats.persistence.*` | 5Gi / RWO | Backend SQLite PVC (`helm.sh/resource-policy: keep`) |
