# Screenshots Checklist

Screenshots are evidence, not decoration. Each capture must hide account IDs,
credentials, secret values, and unrelated browser or terminal content.

## Evidence checklist

- [ ] Architecture diagram rendered clearly
- [ ] Terraform fmt/validate output
- [ ] Terraform plan summary with costs reviewed
- [ ] EKS cluster and healthy managed nodes
- [ ] ECR image with immutable release identifier
- [ ] Argo CD root app and child apps `Healthy` and `Synced`
- [ ] NGINX ingress serving the application through the AWS load balancer
- [ ] Healthy Deployment, Service, Pods, HPA, and PDB
- [ ] Successful rolling update
- [ ] Readiness probe preventing early traffic
- [ ] HPA scale-out and scale-in using `/work`
- [ ] NetworkPolicy allowed and denied traffic tests
- [ ] Secrets Manager integration without exposed values
- [ ] Prometheus healthy app target
- [ ] Grafana application dashboard
- [ ] Alertmanager test alert route
- [ ] CloudWatch control-plane and container logs
- [ ] GitHub Actions successful CI workflow
- [ ] GitHub Actions release workflow updating GitOps image tag
- [ ] Documented failure and troubleshooting evidence
- [ ] Ordered platform teardown

## Redaction rules

- Hide AWS account IDs unless intentionally public.
- Hide secret values, tokens, ARNs tied to private accounts if desired, and
  unrelated terminal history.
- Capture enough context to prove the result, not the entire desktop.
