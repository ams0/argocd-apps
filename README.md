# Bootstrapping an AKS cluster with Terraform, ArgoCD and Helm Operator

## Deploy AKS with Terrafom

```console
tf init  
tf apply -auto-approve
```

The template will install AKS and call the ArgoCD module to install everything that is in this repo under the `/manifests` folder, including `cert-manager` and `ingress-nginx`. To allow for the certificates creation, you need to map the ingress public IP to a real wildcard DNS record in a DNS zone (in Azure):


```console
INGRESS_IP=`kg svc -n ingress ingress-nginx-controller --output=jsonpath="{.status.loadBalancer.ingress[0]['ip']}"`
az network dns record-set a delete  -g dns -z stackmasters.com -y -n "*.ingress"
az network dns record-set a add-record  -n "*.ingress" -g dns -z stackmasters.com --ipv4-address $INGRESS_IP
az network dns record-set a update  -n "*.ingress" -g dns -z stackmasters.com --set ttl=10
```

If you already have a cluster, you can install the ArgoCD server with:

```console
kubectl apply -f install.yaml -n argocd 
```

Note that I modify the official template to allow insecure connections (SSL is terminated at the ingress controller) and using the latest image.

- Run:

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

and use the `argocd` command line:

```console
kubectl port-forward svc/argocd-server 8080:80 --namespace argocd &
argocd login localhost:8080  --insecure
```


ToDo

- blobfuse-csi-driver [DONE]
- azurefile-csi-driver [DONE]
- vault {NEED PERSISTENCE with Consul}
- jenkins Helm chart
- OPA policies
- Prom operator
- Loki


### Note

The ArgoCD `install.yaml` differs from the official one, in that installs the `latest` version and enables ``--insecure` connections (as the connections is TLS-terminated at the ingress controller).

The Vault root token can be retrieved by:

```console
kubectl get secrets -n vault vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode|pbcopy
```