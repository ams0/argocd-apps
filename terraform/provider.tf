provider "azurerm" {
  features {}
}


provider "kubernetes" {
  host                   = moduke.aks.host
  client_key             = base64decode(module.aks.client_key)
  client_certificate     = base64decode(module.aks.client_certificate)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)

}

provider "helm" {
  kubernetes {
    host                 = module.aks.host
  client_key             = base64decode(module.aks.client_key)
  client_certificate     = base64decode(module.aks.client_certificate)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)

  }
}