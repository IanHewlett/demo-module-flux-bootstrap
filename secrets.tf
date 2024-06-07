provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.instance, "--region", var.aws_region, "--role-arn", "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"]
  }
}

resource "kubernetes_secret" "git_clone_secret" {
  metadata {
    name      = "git-clone-secret"
    namespace = flux_bootstrap_git.this.namespace
  }
  data = {
    identity       = data.vault_generic_secret.svc_flux.data["ssh_key"]
    "identity.pub" = data.vault_generic_secret.svc_flux.data["pub_key"]
    known_hosts    = data.vault_generic_secret.svc_flux.data["known_host"]
  }

  type = "Opaque"
}

resource "kubernetes_secret" "chart_pull_secret" {
  metadata {
    name      = "chart-pull-secret"
    namespace = "kube-system"
  }
  data = {
    username = data.vault_generic_secret.svc_github.data["token_username"]
    password = data.vault_generic_secret.svc_github.data["image_pull_token"]
  }

  type = "Opaque"
}

resource "kubernetes_secret" "cosign_signing_key" {
  metadata {
    name      = "cosign-signing-key"
    namespace = "kube-system"
  }
  data = {
    "key1.pub" = data.vault_generic_secret.svc_cosign.data["pub_key"]
  }

  type = "Opaque"
}

resource "kubernetes_secret" "cluster_metadata" {
  metadata {
    name      = "cluster-metadata"
    namespace = "kube-system"
  }
  data = {
    instance                           = var.instance
    role                               = var.role
    aws_account_id                     = var.aws_account_id
    aws_region                         = var.aws_region
    vault_addr                         = var.vault_addr
    cluster_endpoint                   = data.aws_eks_cluster.this.endpoint
    cluster_domain                     = var.cluster_domain
    management_node_group_name         = var.management_node_group_name
    management_node_group_role         = var.management_node_group_role
    irsa_aws_load_balancer_controller  = var.irsa_aws_load_balancer_controller
    irsa_cert_manager                  = var.irsa_cert_manager
    irsa_karpenter_controller          = var.irsa_karpenter_controller
    irsa_external_dns                  = var.irsa_external_dns
    istio_ingressgateway_name          = var.istio_ingressgateway_name
    istio_intragateway_name            = var.istio_intragateway_name
    karpenter_default_instance_profile = var.karpenter_default_instance_profile
  }

  type = "Opaque"
}

resource "vault_generic_secret" "cluster_metadata" {
  path = "secret/svc/cluster-metadata/${var.instance}"

  data_json = jsonencode({
    instance                           = var.instance
    role                               = var.role
    aws_account_id                     = var.aws_account_id
    aws_region                         = var.aws_region
    vault_addr                         = var.vault_addr
    cluster_endpoint                   = data.aws_eks_cluster.this.endpoint
    cluster_domain                     = var.cluster_domain
    management_node_group_name         = var.management_node_group_name
    management_node_group_role         = var.management_node_group_role
    irsa_aws_load_balancer_controller  = var.irsa_aws_load_balancer_controller
    irsa_cert_manager                  = var.irsa_cert_manager
    irsa_karpenter_controller          = var.irsa_karpenter_controller
    irsa_external_dns                  = var.irsa_external_dns
    istio_ingressgateway_name          = var.istio_ingressgateway_name
    istio_intragateway_name            = var.istio_intragateway_name
    karpenter_default_instance_profile = var.karpenter_default_instance_profile
  })
}
