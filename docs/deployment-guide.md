# Deployment Guide

> Status: Offline implementation guide. Cloud commands remain gated by AWS
> identity and budget approval.

## Intended outcome

An operator can provision, bootstrap, deploy, validate, and safely destroy the
platform from a clean workstation.

## Planned sections

1. Prerequisites and version checks
2. AWS authentication and account safety
3. Terraform backend bootstrap
4. Network and EKS provisioning
5. Platform-controller bootstrap
6. Application build and publication
7. Argo CD synchronisation
8. Post-deployment verification
9. Upgrade procedure
10. Ordered teardown and residual-resource checks

## CI/CD release flow

After AWS resources and GitHub repository variables exist, the manual release
workflow publishes a new application image:

```text
GitHub Actions -> ECR -> GitOps image tag update -> Argo CD sync -> EKS
```

Required GitHub repository variables:

- `AWS_REGION`
- `AWS_ROLE_TO_ASSUME`
- `ECR_REPOSITORY_URL`

The release workflow does not run `kubectl apply`. Argo CD deploys the GitOps
change after the workflow commits the new image tag.
