# Bootstrapping an AKS cluster with Terraform, ArgoCD and Helm Operator

- Deploy AKS [Add instructions for terraform+templates]

- Run:

```console
kubectl create namespace argocd
#the file here differ from the official one here: https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml because it's patched for insecure access, as TLS is terminated at the ingress-controller
kubectl apply -n argocd -f install.yaml
```

Create the bootstrap root application (apps-of-apps)

```console
kubectl apply -f manifests/root.yaml
```

To get the ingress work with the Let's Encrypt certificate, you need to map the ingress IP to a DNS zone. If you have one in Azure, you can use this:

```console
INGRESS_IP=`kubectl get svc -n ingress ingress-nginx-controller --output=jsonpath="{.status.loadBalancer.ingress[0]['ip']}"
ZONE=domain.com
DNS_RG=dns

az network dns record-set a delete  -g dns -z $ZONE -y -n "*.ingress"
az network dns record-set a add-record  -n "*.ingress" -g $DNS_RG -z $ZONE --ipv4-address $INGRESS_IP
az network dns record-set a update  -n "*.ingress" -g $DNS_RG -z $ZONE --set ttl=10
```

That's it! Argo will install recursively everything that is present in the `/manifests` folder, including cert-manager+ingress, giving Argo itself a TLS-secured endpoint for the its UI. You can retrieve the ArgoCD password (for 1.9+):

```console
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D
```

ToDo

- blobfuse-csi-driver
- azurefile-csi-driver
- vault
- jenkins operator
- OPA policies
- Prom operator
- Loki
