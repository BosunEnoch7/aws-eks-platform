# Argo CD bootstrap

Argo CD cannot deploy itself from Git until an Argo CD control plane exists.
That one-time dependency is the GitOps bootstrap problem.

The operator will install pinned Argo CD `v3.4.2`, apply the two `AppProject`
resources, and apply `root-application.yaml`. After that handoff, the root
application discovers the child applications under `gitops/applications/dev`.

When the EKS cluster exists and all safety gates are satisfied, the bootstrap
sequence will be:

```powershell
kubectl apply -f gitops/bootstrap/namespace.yaml
kubectl apply --server-side --force-conflicts -n argocd `
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.4.2/manifests/install.yaml
kubectl rollout status deployment/argocd-server -n argocd --timeout=5m
kubectl apply -f gitops/bootstrap/projects.yaml
kubectl apply -f gitops/bootstrap/root-application.yaml
```

The remote install URL is deliberately version-pinned. Review the upstream
release notes and manifest before upgrading; never bootstrap from a moving
`stable` URL.

## Why App-of-Apps

This repository initially targets one cluster and one active environment.
Explicit child `Application` resources make ownership, ordering, and failure
domains easy to inspect. An `ApplicationSet` is a future improvement when the
same desired state must be generated across several clusters or environments.

## Pre-bootstrap substitutions

Replace every `REPLACE_*` token before applying anything:

```powershell
rg "REPLACE_" gitops platform helm
```

Values come from the Git remote and Terraform outputs:

| Token | Source |
|---|---|
| `REPLACE_GITHUB_REPOSITORY_URL` | `git remote get-url origin` |
| `REPLACE_EKS_CLUSTER_NAME` | `terraform output -raw eks_cluster_name` |
| `REPLACE_VPC_ID` | `terraform output -raw vpc_id` |
| `REPLACE_AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN` | Terraform platform IAM output |
| `REPLACE_WITH_ECR_REPOSITORY_URL` | `terraform output -raw ecr_repository_url` |
| `REPLACE_APPLICATION_RUNTIME_ROLE_ARN` | `terraform output -raw application_runtime_role_arn` |

Do not perform these substitutions with secrets. These values are identifiers,
not credentials.

## Ownership boundary

- Terraform owns AWS resources, IAM roles, and IRSA trust.
- The operator performs the one-time Argo CD bootstrap.
- Argo CD owns controller Helm releases and application Kubernetes resources.
- AWS controllers own cloud resources generated from Kubernetes intent.

The root application has automated pruning and self-healing because Git is the
desired-state authority. Deleting a manifest can therefore delete a live
resource; pull-request review is the safety control.
