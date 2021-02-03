terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}


provider "kubernetes" {
  host                   = var.host
  client_key             = base64decode(var.client_key)
  client_certificate     = base64decode(var.client_certificate)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

}

provider "helm" {
  kubernetes {
    host                   = var.host
    client_key             = base64decode(var.client_key)
    client_certificate     = base64decode(var.client_certificate)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = var.host
  client_key             = base64decode(var.client_key)
  client_certificate     = base64decode(var.client_certificate)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}


resource "kubernetes_namespace" "argocd" {

  depends_on = [var.argocd_depens_on]

  metadata {

    name = var.namespace
  }
}

locals {
  resources = split("\n---\n", file("${path.module}/manifests/install.yaml"))
}

resource "kubectl_manifest" "install_argo" {

  depends_on = [kubernetes_namespace.argocd]

  count              = length(local.resources)
  yaml_body          = local.resources[count.index]
  override_namespace = var.namespace
  wait               = true
}


resource "helm_release" "rootapp" {

  depends_on = [kubectl_manifest.install_argo]


  name             = "argocd"
  chart            = "${path.module}/chart/argocd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "bootstrap.repo_path"
    value = var.bootstrap_repo_path
  }

  set {
    name  = "bootstrap.repo_url"
    value = var.bootstrap_repo_url
  }

  set {
    name  = "bootstrap.repo_branch"
    value = var.bootstrap_repo_branch
  }

}