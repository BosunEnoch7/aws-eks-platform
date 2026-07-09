# Cost Optimization Guide

> Status: Offline cost model complete. Exact prices must be checked in the AWS
> Pricing Calculator for the selected Region before provisioning.

## Expected cost drivers

- EKS cluster charge
- EC2 worker capacity
- NAT gateways and data processing
- Network Load Balancer
- CloudWatch log ingestion and retention
- ECR storage and scanning
- Cross-AZ and internet data transfer

## Cost controls implemented

- single NAT gateway option for development,
- small managed node group defaults,
- ECR lifecycle rules for old images,
- CloudWatch control-plane log retention set to 30 days,
- Prometheus persistence disabled in the first dev profile,
- manual release workflow to avoid accidental image pushes,
- explicit teardown checklist requirement.

Cost reduction will not be presented as optimization if it silently removes a
required reliability or security property.

## Learning profile

Use for portfolio validation:

- one EKS cluster,
- one small managed node group,
- single NAT gateway,
- short log and metrics retention,
- no production traffic,
- destroy when not actively testing.

Trade-off: cheaper, but not equivalent to a highly available production
environment.

## Production profile

Use for a real service:

- multiple NAT gateways or private endpoints,
- larger and autoscaled worker pools,
- persistent Prometheus storage or managed metrics,
- longer log retention based on compliance needs,
- real alert receivers,
- backup and recovery testing.

Trade-off: more expensive, but safer under failure and audit requirements.
