# Development environment

The active development desired state is composed by the explicit Argo CD
applications in `gitops/applications/dev`.

Environment-specific values remain visible at their owning layer:

- controller configuration: `platform/*/values.yaml`
- workload defaults: `helm/application/values.yaml`
- deployed image identity: `gitops/applications/dev/application.yaml`

This avoids copying whole Helm values files into an overlay. Argo CD multi-source
applications fetch a third-party chart and a values file from this repository.

The empty `prod` directory is intentionally not active. Production will not be
created by copying dev blindly; it needs its own availability, access, data,
cost, and promotion decisions.
