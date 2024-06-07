variable "role" {
  type = string
}

variable "instance" {
  type = string
}

variable "aws_account_id" {
  description = "default aws account id"
  type        = string

  validation {
    condition     = length(var.aws_account_id) == 12 && can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "Invalid AWS account ID"
  }
}

variable "aws_region" {
  type = string
}

variable "aws_assume_role" {
  type = string
}

variable "github_org" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "vault_addr" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "management_node_group_name" {
  type = string
}

variable "management_node_group_role" {
  type = string
}

variable "irsa_aws_load_balancer_controller" {
  type = string
}

variable "irsa_cert_manager" {
  type = string
}

variable "irsa_karpenter_controller" {
  type = string
}

variable "irsa_external_dns" {
  type = string
}

variable "istio_ingressgateway_name" {
  type = string
}

variable "istio_intragateway_name" {
  type = string
}

variable "karpenter_default_instance_profile" {
  type = string
}

variable "namespaces" {
  type = set(string)
}
