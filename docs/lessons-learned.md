# Lessons Learned

> Status: Living document.

## Entry format

- Date:
- Assumption:
- Evidence:
- What changed:
- Reusable lesson:

## Initial lesson

Architecture ownership must be decided before implementation. Terraform,
GitHub Actions, Helm, and Argo CD can all change system state, but allowing them
to manage overlapping resources creates drift and an unclear recovery path.

## Additional lessons

- Date: Phase 10
  Assumption: Kubernetes Secrets were enough for secret management.
  Evidence: Secrets are only Kubernetes objects and should not contain values in
  Git.
  What changed: AWS Secrets Manager plus External Secrets Operator became the
  design.
  Reusable lesson: store secret values outside Git and sync only what workloads
  need.

- Date: Phase 11
  Assumption: HPA alone demonstrated resilience.
  Evidence: HPA does not protect rollouts, node drains, or scheduling spread.
  What changed: Added PDB, topology spread, rollout deadlines, and Metrics
  Server.
  Reusable lesson: scaling is only one part of resilience.

- Date: Phase 12
  Assumption: CloudWatch and Prometheus might compete.
  Evidence: CloudWatch fits AWS/EKS logs; Prometheus fits Kubernetes metrics and
  alert rules.
  What changed: Split logging and metrics responsibilities.
  Reusable lesson: observability tools should have explicit ownership.

- Date: Phase 13
  Assumption: CI/CD could deploy directly.
  Evidence: Direct CI deploys blur audit and privilege boundaries.
  What changed: GitHub Actions publishes images and updates GitOps; Argo CD
  deploys.
  Reusable lesson: CI should publish artifacts, CD should reconcile desired
  state.
