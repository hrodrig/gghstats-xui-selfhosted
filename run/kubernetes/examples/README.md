# Kubernetes examples

← [Back to run/README](../../README.md).

Anonymous operator templates. Copy into a **personal data directory** outside any clone — never commit real hosts, tokens, or filters.

**Recommended personal dir:** `~/gghstats-xui-selfhosted-data/`

## Chart scope vs out of scope

| In chart (Helm) | Out of scope (you own these) |
|-----------------|------------------------------|
| Deployments, Services, PVC, Secrets wiring | **Ingress / IngressRoute**, DNS, TLS, cert resolvers |
| Image tags, env, persistence via values | Auth front door (Cloudflare Access, basic auth, …) |

## Example files

| File | Purpose |
|------|---------|
| [`values.example.yaml`](values.example.yaml) | In-cluster gghstats **inside this chart** + xui (`gghstats.enabled: true`) |
| [`values.ui-only.example.yaml`](values.ui-only.example.yaml) | UI only → **remote** gghstats URL (`apiBase` https://…) |
| [`values.ui-only-clusterip.example.yaml`](values.ui-only-clusterip.example.yaml) | UI only → **same-cluster** gghstats from [gghstats-selfhosted](https://github.com/hrodrig/gghstats-selfhosted) chart |
| [`traefik-ingressroute.yaml`](traefik-ingressroute.yaml) | Traefik v3: HTTP→HTTPS redirect + TLS → UI Service **3000** |

## Install chart: Helm repo (recommended) vs local path

**Recommended** — published chart on GitHub Pages:

```bash
helm repo add gghstats-xui https://hrodrig.github.io/gghstats-xui-selfhosted
helm repo update
helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats --create-namespace \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
```

**Also supported** — chart directory from a git clone (pre-publish / template work):

```bash
helm upgrade --install my-xui ./run/kubernetes/helm/gghstats-xui -n gghstats --create-namespace \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
```

Prefer the **Helm repository** for production once the chart version is on Pages.

## Path A — single chart (backend + UI)

```bash
mkdir -p ~/gghstats-xui-selfhosted-data
cp run/kubernetes/examples/values.example.yaml ~/gghstats-xui-selfhosted-data/values.yaml
# edit filter / secret names / image tags

kubectl create namespace gghstats
kubectl create secret generic gghstats-xui-github-secret -n gghstats \
  --from-literal=github-token=YOUR_GITHUB_TOKEN
kubectl create secret generic gghstats-xui-api-secret -n gghstats \
  --from-literal=api-token=YOUR_SHARED_API_TOKEN

helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
```

## Path B — two charts (gghstats api-only + xui UI-only)

Use when the backend should come from **gghstats-selfhosted** (full env knobs, own release lifecycle) and xui only talks to its ClusterIP.

```bash
# 1) Backend — https://hrodrig.github.io/gghstats-selfhosted
helm repo add gghstats https://hrodrig.github.io/gghstats-selfhosted
helm repo update
# values: env.apiOnly=true, filter, githubToken + apiToken existingSecrets
# example shape: gghstats/gghstats values.api-only.example.yaml in that repo
helm upgrade --install gghstats-api gghstats/gghstats -n gghstats --create-namespace \
  -f ~/gghstats-xui-selfhosted-data/values-gghstats-api.yaml
# Service: gghstats-api-gghstats:8080

# 2) UI — this chart, gghstats.enabled=false
cp run/kubernetes/examples/values.ui-only-clusterip.example.yaml \
  ~/gghstats-xui-selfhosted-data/values.yaml
# confirm apiBase matches <release>-gghstats

helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats \
  -f ~/gghstats-xui-selfhosted-data/values.yaml
```

Shared **`api-token`** Secret must match both releases. Optional: restore an existing SQLite into the backend PVC (stop Deployment, copy `gghstats.db`, start) if you migrate history from another host.

## Route the UI (out of chart scope)

```bash
cp run/kubernetes/examples/traefik-ingressroute.yaml \
  ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
# edit Host(`xui.example.com`), service name, certResolver, middleware name
kubectl apply -f ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
```

- Put IngressRoute in the **same namespace as the UI Service** (example: `gghstats`).
- Traefik controller may run in another namespace; it still watches app-ns CRDs.
- DNS → Traefik LoadBalancer IP/hostname.

Full narrative: [helm/gghstats-xui/README.md](../helm/gghstats-xui/README.md).
