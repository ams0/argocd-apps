# Bootstrapping an AKS cluster with Terraform, ArgoCD and Helm Operator

- Deploy AKS [Add instructions for terraform+templates]

- Run:

```console
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Create the bootstrap root application (apps-of-apps)

```console
kubectl apply -f manifests/root.yaml
```

That's it!  Argo will install recursively everything that is present in the `/manifests` folder, including cert-manager+ingress, giving Argo itself a TLS-secured endpoint for the its UI.
