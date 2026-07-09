# Troubleshooting Guide

> Status: Offline troubleshooting guide complete. Use after deployment to move
> from symptom to evidence before changing the system.

## Diagnostic method

Troubleshooting will proceed from user-visible symptom to ingress, Service,
Pod, node, controller, and AWS infrastructure evidence. Changes will not be made
until the failing layer is identified.

## Scenario quick map

| Symptom | First evidence | Likely layer |
|---|---|---|
| Argo CD `OutOfSync` | `argocd app diff` | GitOps or Helm |
| Image pull failure | `kubectl describe pod` | ECR auth, tag, node IAM |
| Pod `Pending` | pod events | capacity, scheduling, PDB, topology |
| Probe failure | pod describe + app logs | app health or config |
| Ingress 404 | ingress rules | NGINX routing |
| Ingress 502 | service endpoints | Service, readiness, pod |
| NLB missing | AWS Load Balancer Controller logs | controller IAM/subnet tags |
| HPA not scaling | `kubectl describe hpa` | Metrics Server/resources |
| Secret missing | `kubectl describe externalsecret` | ESO, IRSA, Secrets Manager |
| Prometheus target down | Prometheus targets UI | ServiceMonitor labels/path |
| No CloudWatch logs | CloudWatch add-on pods | add-on/IAM/agent |
| Network blocked | temporary debug pod | NetworkPolicy |

## Argo CD is `OutOfSync` or `Degraded`

```powershell
argocd app get <app-name>
argocd app diff <app-name>
kubectl describe application <app-name> -n argocd
```

Check whether the desired manifest contains unresolved `REPLACE_*` tokens.

## Image pull fails from ECR

```powershell
kubectl describe pod <pod-name> -n aws-eks-platform
aws ecr describe-images --repository-name aws-eks-platform/application
```

Likely causes:

- image tag was not pushed,
- ECR repository URL is wrong,
- node role lacks ECR pull permissions,
- private registry auth problem.

## HPA does not scale

```powershell
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top pods -n aws-eks-platform
kubectl describe hpa aws-eks-platform-api -n aws-eks-platform
```

HPA needs:

- Metrics Server running,
- CPU requests on the container,
- sustained load above the target threshold.

## Prometheus target is down

```powershell
kubectl get servicemonitor -n aws-eks-platform
kubectl get endpoints -n aws-eks-platform
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
```

Check:

- ServiceMonitor labels match Prometheus selector,
- service port is named `http`,
- `/metrics` returns Prometheus text format,
- NetworkPolicy allows Prometheus scraping if tightened later.

## Logs do not reach CloudWatch

```powershell
kubectl get pods -n amazon-cloudwatch
kubectl describe addon amazon-cloudwatch-observability -n kube-system
aws logs describe-log-groups --log-group-name-prefix /aws/containerinsights
```

Check the CloudWatch Observability add-on, node IAM policy, and region.
