resource "azurerm_resource_group" "sm" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "sm" {
  name                = "sm"
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  address_space       = var.vnet_address_prefix

}

resource "azurerm_subnet" "sm" {
  name                 = "sm"
  resource_group_name  = azurerm_resource_group.sm.name
  virtual_network_name = azurerm_virtual_network.sm.name
  address_prefixes     = var.subnet_address_prefix
}

module "aks" {
  source                         = "Azure/aks/azurerm"
  resource_group_name            = var.resource_group_name
  kubernetes_version             = var.kubernetes_version
  orchestrator_version           = "1.19.3"
  prefix                         = "sm"
  network_plugin                 = "kubenet"
  public_ssh_key                 = var.public_ssh_key
  vnet_subnet_id                 = azurerm_subnet.sm.id
  enable_log_analytics_workspace = false


  agents_count = var.agents_count
  agents_size  = var.agents_size

  network_policy = "calico"

  depends_on = [azurerm_subnet.sm]

}

module "argocd" {

  source = "./modules/argocd"

  argocd_depens_on = [module.aks.aks_id]

  bootstrap_repo_url     = var.bootstrap_repo_url
  bootstrap_repo_path    = var.bootstrap_repo_path
  bootstrap_repo_branch  = var.bootstrap_repo_branch
  host                   = module.aks.host
  client_key             = module.aks.client_key
  client_certificate     = module.aks.client_certificate
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}