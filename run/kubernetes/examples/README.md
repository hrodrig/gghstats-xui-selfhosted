# Kubernetes examples

← [Back to run/README](../../README.md).

Manifests you apply **beside** the Helm chart (the chart does **not** create Ingress resources).

| File | Purpose |
|------|---------|
| [`traefik-ingressroute.yaml`](traefik-ingressroute.yaml) | Traefik v3 `IngressRoute` → UI Service port **3000** |

**Flow:** install the chart → edit placeholders in the example → `kubectl apply` → point DNS at your Traefik load balancer.

Full steps: [helm/gghstats-xui/README.md](../helm/gghstats-xui/README.md).
