# ADR-009: CI/CD and release automation

## Status

Accepted

## Context

The platform needs automated validation and a release path that reflects modern
Kubernetes platform practice. The repository should validate changes before
merge and publish application images without giving CI direct cluster-deploy
authority.

## Decision

Use GitHub Actions for:

1. pull-request validation,
2. Terraform formatting and validation,
3. application tests,
4. Helm/YAML validation,
5. Docker image build validation,
6. controlled ECR image publication,
7. GitOps image tag updates.

Use Argo CD, not GitHub Actions, as the deployment controller.

Use GitHub OIDC for AWS authentication instead of static AWS access keys.

## Why this decision

This mirrors a common production platform pattern:

```text
CI validates and publishes artifacts.
Git records desired state.
Argo CD deploys desired state.
```

It keeps AWS credentials short-lived and avoids granting CI broad Kubernetes
admin access.

## Trade-offs

- The release workflow needs an AWS OIDC role to exist before it can run.
- Committing GitOps changes from CI requires careful branch protection.
- Manual release dispatch is safer for a learning platform, but less automated
  than a fully trunk-based deployment pipeline.
- Major-version action pins are easier to maintain than commit-SHA pins, but
  commit-SHA pins are stricter for high-security environments.

## Consequences

The project now demonstrates:

- validation before merge,
- image build and publication automation,
- immutable image tag promotion,
- GitOps-based delivery,
- short-lived AWS authentication,
- clear separation between CI and CD ownership.
