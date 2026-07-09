# NGINX Ingress Controller

ingress-nginx provides the shared HTTP routing tier behind an AWS Network Load
Balancer.

## Version

- Chart: `4.15.1`
- Controller: `1.15.1`

## Traffic ownership

- The AWS Load Balancer Controller watches this chart's `LoadBalancer` Service
  and creates an NLB.
- The NLB uses IP targets to send traffic to ingress-nginx Pods.
- ingress-nginx watches only Ingress resources whose class is `nginx`.
- Application Services remain internal `ClusterIP` Services.

## Initial limitations

- TLS is deliberately deferred until DNS and certificate ownership are defined.
- The NLB is internet-facing and incurs hourly and data-processing charges.
- Metrics are enabled, but `ServiceMonitor` remains disabled until the
  Prometheus operator is installed.
- NGINX snippets are disabled because arbitrary snippets can bypass platform
  routing and security controls.

## Reliability settings

- Two initial replicas
- HPA range of two to five replicas
- Pod disruption minimum availability of one
- Zone-aware scheduling preference
- Explicit requests and limits

