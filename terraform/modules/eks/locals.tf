locals {
  oidc_issuer_hostpath = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

