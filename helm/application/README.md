# Application Helm Chart

This chart packages the sample workload for Kubernetes.

It includes:

- `Deployment` with rolling-update settings
- `Service` for stable in-cluster networking
- `Ingress` for NGINX-based HTTP routing
- `ConfigMap` for application configuration
- `HorizontalPodAutoscaler` for CPU-based scaling
- tuned HPA scale-up and scale-down behavior
- `PodDisruptionBudget` for voluntary disruption protection
- topology spread constraints across zones and nodes
- `NetworkPolicy` for namespace-scoped ingress and egress boundaries
- optional `ExternalSecret` integration with AWS Secrets Manager
- security contexts and resource requests/limits

## Why Helm here?

Raw YAML is fine for learning individual Kubernetes objects, but production
teams need repeatable packaging. Helm lets us keep one workload template and
change environment-specific values without copying manifests.

In this project, Helm is the packaging format. Argo CD, added in the next
phase, will become the delivery engine that applies this chart to EKS.

## Secret handling

The chart can consume a Kubernetes Secret through `envFrom.secretRef`, but it
does not store secret values in Git.

When `externalSecret.enabled=true`, the chart creates:

- a namespaced `SecretStore` pointing to AWS Secrets Manager,
- an `ExternalSecret` that syncs selected properties into a Kubernetes Secret,
- a Deployment reference to that synced Secret.

The service account must be annotated with the IRSA role created by Terraform.
That role is scoped to one AWS Secrets Manager secret.

## Network policy

The default policy allows HTTP ingress only from the `ingress-nginx` namespace.
Egress is limited to DNS and HTTPS. HTTPS is intentionally broad at this stage
because AWS service endpoints are still reached through normal regional
endpoints; a future phase can tighten this further with VPC endpoints.

## Resilience settings

The chart uses:

- `maxUnavailable: 0` and `maxSurge: 1` for zero-downtime rolling updates,
- `minReadySeconds` so a pod must stay ready before it counts as available,
- `progressDeadlineSeconds` so stuck rollouts fail visibly,
- `PodDisruptionBudget` so voluntary disruption keeps at least most replicas
  available,
- topology spread constraints so replicas are not packed onto one node or zone,
- HPA behavior settings to scale up quickly but scale down more cautiously.

These controls do not replace load testing. They create sane defaults that can
be verified during the operational testing phase.

## Render locally

```powershell
helm template platform-application . --namespace workloads
```

## Install manually after the cluster exists

Manual installs are useful for local testing, but they are not the final
delivery model of this project:

```powershell
helm upgrade --install platform-application . `
  --namespace workloads `
  --create-namespace `
  --set image.repository=<account-id>.dkr.ecr.<region>.amazonaws.com/aws-eks-platform/app `
  --set image.tag=0.1.0
```
