data "github_repository" "this" {
  name = var.repository_name
}

data "aws_eks_cluster" "this" {
  name = var.instance
}

data "vault_generic_secret" "svc_flux" {
  path = "secret/svc/flux"
}

data "vault_generic_secret" "svc_github" {
  path = "secret/svc/github"
}

data "vault_generic_secret" "svc_cosign" {
  path = "secret/svc/cosign"
}
