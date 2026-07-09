# STAR Stories

> Status: Draft stories based on implemented offline evidence.

### Designing clear infrastructure and deployment ownership

- Situation: The platform used Terraform, Helm, GitHub Actions, and Argo CD,
  all of which can change infrastructure or Kubernetes state.
- Task: Prevent overlapping ownership and future drift.
- Action: Defined Terraform as AWS/IAM owner, Helm as package owner, Argo CD as
  Kubernetes desired-state owner, and GitHub Actions as validation/release owner.
- Result: The repo now has a clean operating model and ADRs documenting each
  boundary.
- Evidence: ADR-001, ADR-005, ADR-009, GitOps App-of-Apps layout.

### Diagnosing a failed Kubernetes release

- Situation: Helm validation was blocked locally because `helm` was not on PATH.
- Task: Continue validating without pretending the check passed.
- Action: Ran Terraform validation, YAML parsing, Python tests, and documented
  Helm as a tooling gap while adding Helm lint/render to GitHub Actions.
- Result: Local validation remained honest, and CI now performs the missing
  chart checks in a clean runner.
- Evidence: CI workflow and Phase 13 validation notes.

### Improving reliability through probes and autoscaling

- Situation: A basic Deployment with replicas is not enough to demonstrate
  production readiness.
- Task: Add resilience controls without overcomplicating the platform.
- Action: Added readiness/liveness probes, HPA behavior, Metrics Server,
  PodDisruptionBudget, topology spread constraints, and conservative rolling
  update settings.
- Result: The workload now has a realistic baseline for rollout and scaling
  tests.
- Evidence: Helm chart, ADR-007, resilience guide.

### Reducing AWS cost without hiding production trade-offs

- Situation: EKS learning environments can become expensive if left running.
- Task: Reduce development cost while keeping production trade-offs visible.
- Action: Used small node defaults, single NAT option, short retention, ECR
  lifecycle rules, no Prometheus persistence in dev, and explicit safety gates.
- Result: The design is cost-conscious without pretending the dev profile is
  fully production-equivalent.
- Evidence: cost guide, README safety gate, Terraform defaults.
