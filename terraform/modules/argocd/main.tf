resource "helm_release" "nginx_ingress_controller" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true
  timeout          = 600

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

    set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = "${var.dns_prefix}"
  }

  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

}

resource "helm_release" "argocd" {

  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.image.tag"
    value = "v2.7.15"
  }

  #because I can't pass "- --insecure" directly using set{}
  values = [
    file("${path.module}/chart/argocd/values.yaml")
  ]

}

resource "helm_release" "rootapp" {

  depends_on = [helm_release.argocd, helm_release.nginx_ingress_controller]


  name             = "rootapp"
  chart            = "${path.module}/chart/rootapp"
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
  set {
    name  = "ingress.host"
    value = var.dns_name
  }

}