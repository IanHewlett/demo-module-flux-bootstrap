resource "github_repository_file" "flux_system_helm_controller" {
  repository = data.github_repository.this.name
  file       = "clusters/${var.instance}/flux-system/helm-controller.yaml"
  content = templatefile("./config/cluster/flux-system/helm-controller.tfpl", {
    management_node_group_name = var.management_node_group_name
    management_node_group_role = var.management_node_group_role
  })
  overwrite_on_create = true

  depends_on = [
    flux_bootstrap_git.this
  ]
}

resource "github_repository_file" "flux_system_kustomize_controller" {
  repository = data.github_repository.this.name
  file       = "clusters/${var.instance}/flux-system/kustomize-controller.yaml"
  content = templatefile("./config/cluster/flux-system/kustomize-controller.tfpl", {
    management_node_group_name = var.management_node_group_name
    management_node_group_role = var.management_node_group_role
  })
  overwrite_on_create = true

  depends_on = [
    flux_bootstrap_git.this
  ]
}

resource "github_repository_file" "flux_system_notification_controller" {
  repository = data.github_repository.this.name
  file       = "clusters/${var.instance}/flux-system/notification-controller.yaml"
  content = templatefile("./config/cluster/flux-system/notification-controller.tfpl", {
    management_node_group_name = var.management_node_group_name
    management_node_group_role = var.management_node_group_role
  })
  overwrite_on_create = true

  depends_on = [
    flux_bootstrap_git.this
  ]
}

resource "github_repository_file" "flux_system_source_controller" {
  repository = data.github_repository.this.name
  file       = "clusters/${var.instance}/flux-system/source-controller.yaml"
  content = templatefile("./config/cluster/flux-system/source-controller.tfpl", {
    management_node_group_name = var.management_node_group_name
    management_node_group_role = var.management_node_group_role
  })
  overwrite_on_create = true

  depends_on = [
    flux_bootstrap_git.this
  ]
}

resource "github_repository_file" "flux_system_kustomization" {
  repository          = data.github_repository.this.name
  file                = "clusters/${var.instance}/flux-system/kustomization.yaml"
  content             = file("./config/cluster/flux-system/kustomization.yaml")
  overwrite_on_create = true

  depends_on = [
    github_repository_file.flux_system_helm_controller,
    github_repository_file.flux_system_kustomize_controller,
    github_repository_file.flux_system_notification_controller,
    github_repository_file.flux_system_source_controller
  ]
}

resource "github_repository_file" "namespace" {
  for_each = var.namespaces

  repository = data.github_repository.this.name
  file       = "clusters/${var.instance}/namespaces/${each.key}.yaml"
  content = templatefile("./config/cluster/namespaces/${each.key}.tfpl", {
    instance = var.instance
  })
  overwrite_on_create = true

  depends_on = [
    kubernetes_secret.git_clone_secret,
    kubernetes_secret.chart_pull_secret,
    kubernetes_secret.cosign_signing_key,
    kubernetes_secret.cluster_metadata,
    vault_generic_secret.cluster_metadata,
    github_repository_file.flux_system_kustomization
  ]
}

resource "github_repository_file" "services" {
  repository          = data.github_repository.this.name
  file                = "clusters/${var.instance}/services.yaml"
  content             = file("./config/cluster/services.yaml")
  overwrite_on_create = true

  depends_on = [
    github_repository_file.namespace
  ]
}

resource "github_repository_file" "applications" {
  repository          = data.github_repository.this.name
  file                = "clusters/${var.instance}/applications.yaml"
  content             = file("./config/cluster/applications.yaml")
  overwrite_on_create = true

  depends_on = [
    github_repository_file.services
  ]
}
