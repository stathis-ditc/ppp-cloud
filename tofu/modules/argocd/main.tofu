locals {
  kubectl_apply_script_path = "${path.module}/scripts/kubectl-apply.sh"
  local_k8s_project_manifest_path = "${path.module}/manifests/projects/local-k8s.yaml"
  local_k8s_app_repo_manifest_path = "${path.module}/manifests/repositories/local-k8s-apps.yaml"
  k8s_config_manifest_path = "${path.module}/manifests/applications/k8s-config.yaml"
}

resource "null_resource" "projects" {

  triggers = {
    manifest_path = filesha256(local.local_k8s_project_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.local_k8s_project_manifest_path
    })
  }
}

resource "null_resource" "repositories" {

  triggers = {
    manifest_path = filesha256(local.local_k8s_app_repo_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.local_k8s_app_repo_manifest_path
    })
  }
  depends_on = [null_resource.projects]
}

resource "null_resource" "k8s-config-app" {

  triggers = {
    manifest_path = filesha256(local.k8s_config_manifest_path)
  }

  provisioner "local-exec" {
    command = local.kubectl_apply_script_path
    environment = merge({
      MANIFEST_PATH = local.k8s_config_manifest_path
    })
  }
  depends_on = [null_resource.repositories]
}