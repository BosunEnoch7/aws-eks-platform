# ADR-003: EKS VPC Networking Model

- Status: Accepted for offline implementation
- Date: 2026-07-04
- Decision owners: Olatubosun Enoch David and platform engineering

## Context

EKS needs routable IP capacity for nodes, Pods, load balancers, and control-plane
communication. The network must demonstrate production isolation and
multi-Availability-Zone design while giving the learning environment an
explicit way to control NAT gateway cost.

## Decision

### Use a dedicated VPC

The platform receives a dedicated `10.0.0.0/16` VPC rather than using the
account's default VPC. This provides deliberate CIDR planning, tagging,
routing, and lifecycle ownership.

### Use three Availability Zones

Each selected Availability Zone receives:

- One public subnet for internet-facing AWS load balancers and NAT gateways
- One private subnet for EKS managed nodes and application Pods

The initial subnet plan is:

| Purpose | CIDRs |
|---|---|
| Public | `10.0.0.0/24`, `10.0.1.0/24`, `10.0.2.0/24` |
| Private | `10.0.10.0/24`, `10.0.11.0/24`, `10.0.12.0/24` |

The gaps are intentional. They make the visual boundary between public and
private ranges obvious and leave room for future subnet classes.

### Keep worker nodes private

Managed nodes will not receive public IP addresses. Internet-bound traffic from
private subnets uses NAT. Public subnets exist for load balancers and NAT
gateways, not for application nodes.

### Support two NAT topologies

- The development profile uses one NAT gateway to reduce recurring cost.
- The production profile uses one NAT gateway per Availability Zone to avoid a
  single-AZ dependency and reduce cross-AZ egress paths.

The single-NAT profile is a conscious reliability compromise, not a production
best practice.

### Use native Terraform resources

The first VPC module uses AWS provider resources directly rather than a
community VPC module. This makes route tables, gateways, subnet tags, and NAT
trade-offs visible for learning.

A mature organisation may prefer the widely used community module to reduce
maintenance. We can compare the two after the native implementation is
understood and tested.

### Add Kubernetes subnet-discovery tags

Public subnets receive `kubernetes.io/role/elb = 1`. Private subnets receive
`kubernetes.io/role/internal-elb = 1`.

These tags let AWS-integrated Kubernetes controllers discover the correct
subnet class without relying on ambiguous route-table inference.

## Consequences

### Benefits

- Nodes and Pods remain off the public internet.
- Three Availability Zones support failure-domain-aware scheduling.
- Subnet roles are explicit and controller-discoverable.
- The NAT cost/resilience decision is configurable and documented.
- Native resources expose the mechanics a Kubernetes platform engineer must
  understand.

### Costs and risks

- A single development NAT gateway is an Availability Zone dependency.
- NAT gateways incur hourly and data-processing charges.
- `/24` private subnets provide limited Pod address capacity at large scale.
- Native modules require more testing and maintenance than established
  community modules.
- Availability Zone names are account-relative; Terraform will select from the
  zones available to the target account at plan time.

## Future considerations

- Add S3 and ECR VPC endpoints to reduce NAT data processing and improve private
  access paths.
- Evaluate secondary VPC CIDRs or IPv6 before Pod address capacity becomes a
  constraint.
- Enable VPC Flow Logs with an explicit retention and cost policy.
- Use one NAT gateway per Availability Zone for a production environment.
- Evaluate a fully private EKS API endpoint and controlled operator access.

