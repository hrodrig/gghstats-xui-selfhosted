# Kubernetes examples

← [Back to run/README](../../README.md).

## Chart scope vs out of scope

| In chart (Helm) | Out of scope (you own these) |
|-----------------|------------------------------|
| Deployments, Services, PVC, Secrets wiring | **Ingress / IngressRoute**, DNS, TLS, cert resolvers |
| Image tags, env, persistence via values | Auth front door (Cloudflare Access, basic auth, …) |

These files are **templates to copy**. Edit site-specific hosts and resolvers in a path **outside** the repository so day-to-day deploys do not touch this git clone.

| File | Purpose |
|------|---------|
| [`values.example.yaml`](values.example.yaml) | Helm values only — secrets refs / optional image pins |
| [`traefik-ingressroute.yaml`](traefik-ingressroute.yaml) | Traefik v3 `IngressRoute` → UI Service port **3000** |

**Typical local flow:**

```bash
# Chart
cp run/kubernetes/examples/values.example.yaml ~/gghstats-xui-values.yaml
# edit ~/gghstats-xui-values.yaml
helm upgrade --install my-xui gghstats-xui/gghstats-xui -n gghstats -f ~/gghstats-xui-values.yaml

# Routing (separate — out of chart scope)
cp run/kubernetes/examples/traefik-ingressroute.yaml ~/gghstats-xui-ingressroute.yaml
# edit Host(), service name, certResolver
kubectl apply -f ~/gghstats-xui-ingressroute.yaml
```

Full steps: [helm/gghstats-xui/README.md](../helm/gghstats-xui/README.md).
