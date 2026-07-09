# Operations Runbook

> Status: Offline runbook complete. Commands are ready for use after the EKS
> cluster, Argo CD, and monitoring stack are deployed.

## Intended outcome

Provide tested, low-ambiguity actions for routine operations and incidents.

## 1. Confirm platform health

```powershell
kubectl get nodes -o wide
kubectl get pods -A
kubectl get applications -n argocd
kubectl get hpa,pdb -n aws-eks-platform
kubectl get servicemonitor,prometheusrule -n aws-eks-platform
```

Healthy baseline:

- nodes are `Ready`,
- Argo CD apps are `Synced` and `Healthy`,
- application pods are `Running` and ready,
- HPA has current CPU metrics,
- Prometheus has a discovered target for the app.

## 2. Inspect an unhealthy Argo CD application

```powershell
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
argocd app get <app-name>
argocd app diff <app-name>
```

Look for:

- missing CRDs,
- failed Helm rendering,
- invalid placeholders,
- namespace or RBAC denial,
- dependency installed after the workload that needs it.

Do not force-sync until the failing layer is understood.

## 3. Diagnose pending or restarting Pods

```powershell
kubectl describe pod <pod-name> -n aws-eks-platform
kubectl logs <pod-name> -n aws-eks-platform --previous
kubectl get events -n aws-eks-platform --sort-by=.lastTimestamp
```

Common causes:

- insufficient CPU or memory,
- image pull failure,
- readiness or liveness probe failure,
- NetworkPolicy blocking dependency traffic,
- secret missing or not synced.

## 4. Pause and resume GitOps synchronisation

Pause only during an active incident when automatic reconciliation would make
diagnosis harder:

```powershell
argocd app set aws-eks-platform-api --sync-policy none
```

Resume after the fix is committed:

```powershell
argocd app set aws-eks-platform-api --sync-policy automated --self-heal --auto-prune
argocd app sync aws-eks-platform-api
```

Record the pause and resume times in the incident timeline.

## 5. Roll back an application release through Git

Preferred rollback path:

1. Identify the last healthy image tag from Git history.
2. Revert or edit `gitops/applications/dev/application.yaml`.
3. Commit the rollback.
4. Let Argo CD reconcile the previous tag.

```powershell
git log -- gitops/applications/dev/application.yaml
git revert <bad-release-commit>
git push
argocd app sync aws-eks-platform-api
kubectl rollout status deployment/aws-eks-platform-api -n aws-eks-platform
```

Why: rollback through Git preserves auditability.

## 6. Respond to high error rate or high latency

```powershell
kubectl get pods -n aws-eks-platform
kubectl top pods -n aws-eks-platform
kubectl describe hpa aws-eks-platform-api -n aws-eks-platform
kubectl logs deployment/aws-eks-platform-api -n aws-eks-platform
```

Check:

- recent rollout,
- dependency or secret failure,
- CPU saturation,
- pod restarts,
- ingress errors,
- Prometheus alert annotations.

## 7. Rotate or refresh an application secret

1. Update the value in AWS Secrets Manager.
2. Wait for External Secrets Operator refresh interval.
3. Confirm the Kubernetes Secret changed.
4. Restart pods only if the app does not reload env vars dynamically.

```powershell
kubectl get externalsecret -n aws-eks-platform
kubectl describe externalsecret aws-eks-platform-api-runtime -n aws-eks-platform
kubectl rollout restart deployment/aws-eks-platform-api -n aws-eks-platform
```

Never paste secret values into terminal output intended for screenshots.

## 8. Collect incident evidence

Minimum evidence:

- start and end time,
- user-visible impact,
- alert name and query,
- Argo CD app state,
- relevant pod events,
- logs with secrets redacted,
- fix commit,
- follow-up action.
