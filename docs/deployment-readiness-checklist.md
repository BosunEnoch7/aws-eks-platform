# Deployment Readiness Checklist

> Status: Required before any `terraform plan`, `terraform apply`, or live
> GitHub Actions release.

## AWS safety gate

- [ ] AWS CLI profile is authenticated.
- [ ] AWS account ID is confirmed.
- [ ] Operator IAM role is confirmed.
- [ ] Budget alert email is provided.
- [ ] Monthly budget target is confirmed or changed.
- [ ] Region is confirmed.
- [ ] Public EKS API CIDR is restricted to the operator IP range.

## Repository gate

- [ ] Git remote is configured.
- [ ] Branch protection is enabled.
- [ ] CI workflow is required before merge.
- [ ] GitHub repository variables are configured:
  - [ ] `AWS_REGION`
  - [ ] `AWS_ROLE_TO_ASSUME`
  - [ ] `ECR_REPOSITORY_URL`
- [ ] No secret values are committed.

## Local validation gate

- [ ] `terraform fmt -check -recursive`
- [ ] `terraform validate`
- [ ] Python tests pass.
- [ ] YAML parser passes.
- [x] Helm lint/render passes locally or in CI.
- [ ] Docker build passes locally or in CI.

## Deployment gate

- [ ] Terraform bootstrap reviewed.
- [ ] Terraform dev plan reviewed.
- [ ] Expected AWS cost reviewed.
- [ ] Argo CD bootstrap substitutions completed.
- [ ] Initial secret value created in AWS Secrets Manager manually or through an
  approved secure workflow.

## Evidence gate

- [ ] Screenshots checklist is ready.
- [ ] Teardown procedure is understood.
- [ ] Incident notes template is ready.
