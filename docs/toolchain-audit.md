# Local Toolchain Audit

- Audit date: 2026-07-04
- Workstation: Windows 11, PowerShell
- Audit type: Read-only

## Results

| Tool | Observed state | Readiness |
|---|---|---|
| AWS CLI | `2.34.27` | Ready |
| Terraform | `1.14.8` | Ready |
| `kubectl` | `1.34.1` | Ready for EKS `1.33`–`1.35` |
| Helm | `4.2.2` installed during Phase 4 | Ready after opening a new terminal |
| Docker CLI | `29.5.3` | Installed; functional access still requires validation |
| Git | `2.52.0` | Ready |
| GitHub CLI | `2.95.0` | Ready |
| Argo CD CLI | Not found | Recommended, not a provisioning blocker |
| `eksctl` | Not found | Optional because Terraform owns EKS |

## AWS configuration

No active AWS profile, access key, or default Region was detected.

This is a safe initial condition, but an authenticated named profile must be
established and verified before Terraform can interact with AWS.

## Docker observation

The Docker CLI is installed, but the audit environment could not read the user
Docker configuration file. This may be a sandbox visibility issue rather than a
Docker installation failure.

Before the application phase, validate outside the restricted audit context
that:

- Docker Desktop or the intended Docker engine is running.
- `docker version` can reach the engine.
- A local image can be built and a container can run.
- Authentication configuration is not committed to Git.

## Required actions before Phase 4

1. Open a new terminal and confirm `helm version --short` reports `4.2.2`.
2. Configure the `aws-eks-platform-dev` AWS profile using temporary credentials
   where possible.
3. Set or explicitly pass `eu-west-1`.
4. Verify the intended AWS identity and account.
5. Establish an AWS Budget and billing notifications.
6. Decide whether to install the recommended Argo CD CLI now or defer it until
   the GitOps phase.

Software installation and credential creation require operator approval and are
not performed automatically by this audit.
