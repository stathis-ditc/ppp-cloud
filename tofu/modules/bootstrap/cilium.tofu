locals {
  cilium_chart_version = "1.16.1"
}

data "local_file" "cilium_helm_values" {
  filename = "${path.module}/helm/cilium/values.yaml"
}

resource "null_resource" "cilium" {
  triggers = {
    values_checksum = filemd5(data.local_file.cilium_helm_values.filename)
    cilium_chart_version = local.cilium_chart_version
  }

  provisioner "local-exec" {
    command = <<EOT
      helm repo add cilium https://helm.cilium.io/
      helm upgrade --install cilium cilium/cilium \
      --version ${local.cilium_chart_version} \
      -f ${path.module}/helm/cilium/values.yaml \
      -n kube-system
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "helm uninstall cilium --namespace kube-system"
  }
}