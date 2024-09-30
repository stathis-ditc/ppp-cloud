locals {
  argocd_chart_version = "7.3.9"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
      shared-gateway-access = "true"
    }
  }
}

data "local_file" "argocd_helm_values" {
  filename = "${path.module}/helm/argocd/values.yaml"
}

resource "null_resource" "argocd" {

  triggers = {
    values_checksum = filemd5(data.local_file.argocd_helm_values.filename)
    argocd_chart_version = local.argocd_chart_version
  }


  provisioner "local-exec" {
    command = <<EOT
      helm repo add argo https://argoproj.github.io/argo-helm
      helm upgrade --install argocd argo/argo-cd \
      --version ${local.argocd_chart_version} \
      -f ${path.module}/helm/argocd/values.yaml \
      -n argocd
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "helm uninstall argocd --namespace argocd"
  }
}
