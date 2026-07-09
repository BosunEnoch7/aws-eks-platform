# CI/CD Guide

> Status: Phase 13 baseline complete. Workflows are defined but have not been
> executed in GitHub yet.

## Delivery model

This project separates continuous integration from continuous delivery:

```text
Pull request -> validate app, Terraform, Helm, YAML, Docker build
Main release -> build image -> push ECR -> update GitOps desired state
Argo CD      -> reconciles desired state into EKS
```

GitHub Actions does not deploy directly to the cluster. Argo CD remains the
deployment controller.

## Workflows

### `ci.yml`

Runs on pull requests and pushes to `main`.

It validates:

- FastAPI tests,
- Terraform formatting and validation,
- YAML parsing,
- Helm chart lint/render,
- Docker image build without push.

### `release.yml`

Runs manually through `workflow_dispatch`.

It:

1. resolves an immutable image tag,
2. assumes an AWS role through GitHub OIDC,
3. logs in to Amazon ECR,
4. builds and pushes the image,
5. updates the Argo CD Application image repository/tag,
6. commits the GitOps change back to the repository.

## Required repository variables

Configure these GitHub repository variables before running the release workflow:

| Variable | Example |
|---|---|
| `AWS_REGION` | `eu-west-1` |
| `AWS_ROLE_TO_ASSUME` | `arn:aws:iam::123456789012:role/aws-eks-platform-github-actions` |
| `ECR_REPOSITORY_URL` | `123456789012.dkr.ecr.eu-west-1.amazonaws.com/aws-eks-platform/application` |

These are identifiers, not secret values.

## Why GitHub OIDC

GitHub OIDC avoids long-lived AWS access keys. The workflow receives a short
lived identity token and exchanges it for an AWS role session.

The AWS role should be scoped to:

- push and describe the application ECR repository,
- read minimal AWS account metadata if required,
- no direct Kubernetes deployment permission.

## Release tag strategy

The default image tag is the first 12 characters of the commit SHA. A manual
tag can be supplied during `workflow_dispatch`.

Why: SHA-based tags are traceable. `latest` is also pushed for convenience, but
GitOps should use the immutable tag.

## GitOps update strategy

The release workflow updates:

```text
gitops/applications/dev/application.yaml
```

Argo CD observes that Git change and performs the deployment. This preserves a
clear audit trail:

```text
image built -> Git desired state changed -> Argo CD reconciled
```

## Safety notes

- The release workflow is manual by default to avoid accidental ECR pushes.
- AWS resources must exist before release can succeed.
- The AWS safety gate still applies before any real cloud provisioning.
- Branch protection should require `ci.yml` before merging.
