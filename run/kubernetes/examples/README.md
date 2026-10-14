# Kubernetes examples

← [Back to run/README](../../README.md).

## Chart scope vs out of scope

| In chart (Helm) | Out of scope (you own these) |
|-----------------|------------------------------|
| Deployments, Services, PVC, Secrets wiring | **Ingress / IngressRoute**, DNS, TLS, cert resolvers |
| Image tags, env, persistence via values | Auth front door (Cloudflare Access, basic auth, …) |

Copy examples into a **personal data directory** outside the clone — recommended:

**`~/gghstats-xui-selfhosted-data/`**

| File | Purpose |
|------|---------|
| [`values.example.yaml`](values.example.yaml) | In-cluster gghstats + xui (`gghstats.enabled: true`) |
| [`values.ui-only.example.yaml`](values.ui-only.example.yaml) | UI only → external gghstats (`enabled: false` + `apiBase`) |
| [`traefik-ingressroute.yaml`](traefik-ingressroute.yaml) | Traefik v3 `IngressRoute` → UI Service port **3000** |

**Typical flow:**

```bash
mkdir -p ~/gghstats-xui-selfhosted-data

# Chart
cp run/kubernetes/examples/values.example.yaml ~/gghstats-xui-selfhosted-data/values.yaml
# edit ~/gghstats-xui-selfhosted-data/values.yaml
helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats \
  -f ~/gghstats-xui-selfhosted-data/values.yaml

# Routing (separate — out of chart scope)
cp run/kubernetes/examples/traefik-ingressroute.yaml ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
# edit Host(), service name, certResolver
kubectl apply -f ~/gghstats-xui-selfhosted-data/traefik-ingressroute.yaml
```

Full steps: [helm/gghstats-xui/README.md](../helm/gghstats-xui/README.md).
