variable "namespace" {
  type        = string
  description = "ArgoCD namespaceo"
  default     = "argocd"
}


variable "bootstrap_repo_url" {
  type        = string
  description = "ArgoCD bootstrap repo"
  default     = ""
}

variable "bootstrap_repo_path" {
  type        = string
  description = "ArgoCD bootstrap repo folder"
  default     = ""
}

variable "bootstrap_repo_branch" {
  type        = string
  description = "ArgoCD bootstrap repo branch"
  default     = ""
}

variable "host" {
  description = "host"
  default     = ""
}

variable "client_certificate" {
  description = "client_certificate"
  default     = ""
}

variable "client_key" {
  description = "client_key"
  default     = ""
}

variable "cluster_ca_certificate" {
  description = "cluster_ca_certificate"
  default     = ""
}

variable "argocd_depens_on" {
  description = "argocd_depens_on"
  default     = ""
}