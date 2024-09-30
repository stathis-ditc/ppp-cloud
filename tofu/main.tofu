module "bootstrap" {
  source = "./modules/bootstrap"
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [module.bootstrap]
}