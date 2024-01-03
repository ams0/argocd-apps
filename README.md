# Bootstrapping an AKS cluster with Terraform, ArgoCD and Helm Operator

## Deploy AKS with Terrafom

```console
terraform init
cp terraform.tfvarsexample terraform.tfvars
terraform apply -auto-approve -var-file=terraform.tfvars
```

The template will install AKS and call the ArgoCD module to install everything that is in this repo under the `/apps` folder. For `cert-manager` to work this repo uses the cloudapp.azure.com DNS name to create a certificate for the ingress controller.

Note that I modify the official template to allow insecure connections (SSL is terminated at the ingress controller) and using the latest image.

- Run:

You can retrieve the ArgoCD password (for 1.9+):

```console
kubectl get secret -n argocd  argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D
```

You can point to the ingress IP or use the `argocd` command line:

```console
kubectl port-forward svc/argocd-server 8080:80 --namespace argocd &
argocd login localhost:8080  --insecure
```

## Notes


### Insecure ArgoCD

The ArgoCD `install.yaml` differs from the official one, in that installs the `latest` version and enables ``--insecure` connections (as the
connections is TLS-terminated at the ingress controller).

### Vault

The Vault root token can be retrieved by:

```console
kubectl get secrets -n vault vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode|pbcopy
```

### Use private git repository

Create a secret with your Github token (`repo` scope) and patch the `argocd-cm` ConfigMap:

```console
kubectl create secret generic -n argocd argocd-github-secret --from-literal=token=<token> --from-literal=username=<github_username>
kubectl patch cm -n argocd argocd-cm --patch-file patch-private-repos.yaml
```

## Tips

If an app get stuck and cannot be deleted, try:

```console
argocd app terminate-op cert-manager-crd
```
