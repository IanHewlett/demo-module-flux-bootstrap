provider "flux" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.instance, "--region", var.aws_region, "--role-arn", "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"]
      command     = "aws"
    }
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.repository_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = var.instance
  repository = data.github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path            = "clusters/${var.instance}"
  toleration_keys = ["dedicated"]
}
