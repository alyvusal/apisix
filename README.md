# [APISIX](https://apisix.apache.org/)

- apisix: it is proxy server to receive incmoing traffic and route to backend
- APISIX Ingress Controller for Kubernetes: create rules for apisix from ingress, httproute and ApisixRoute CRDs

## APISIX

apisix + ingress controller

```bash
helm repo add apisix https://charts.apiseven.com

# apisix and ingress controller at the same time
helm upgrade -i apisix apisix/apisix \
  --create-namespace --namespace apisix-ingress \
  --version 2.11.3 \
  -f k8s/helm/apisix-etcd.yaml

kubectl -n apisix-ingress wait --for=condition=Ready pod -l app.kubernetes.io/instance=apisix --timeout 10m

# check gw
kubectl port-forward svc/apisix-gateway 9080:80
curl -sI "http://127.0.0.1:9080" | grep Server
```

## APISIX Ingress Controller for Kubernetes

install Ingress Controller separately (better for customization)

Note: APISIX Ingress Controller will try to establish a connection with APISIX admin in the location specified by apisix.serviceName and apisix.serviceNamespace values following the naming convention <serviceName.serviceNamespace.svc.clusterDomain>. You can override this behavior to specify a fully custom location by setting the apisix.serviceFullname value.

```bash
helm upgrade -i apisix-ingress-controller apisix/apisix-ingress-controller \
  --create-namespace --namespace apisix-ingress \
  --version 1.0.3 \
  -f k8s/helm/apisix-ingress-controller.yaml

kubectl -n apisix-ingress wait --for=condition=Ready pod -l app.kubernetes.io/instance=apisix-ingress-controller --timeout 10m

# check if routes injected
curl -s -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' http://apisix-admin-172.18.0.2.nip.io/apisix/admin/services | jq .list.[].value.name
```

## Dashboard

Requries apisix installed in etcd mode

```bash
helm upgrade -i apisix-dashboard apisix/apisix-dashboard \
  --create-namespace --namespace apisix-ingress \
  --version 0.8.3 \
  -f k8s/helm/apisix-dashboard.yaml
```

## Cleanup

```bash
helm ls --short | xargs helm uninstall
sleep 3
for i in {0..2}; do kubectl delete pvc data-apisix-etcd-$i; done
sleep 10
kubectl get pv
```

## [Demo](./docs/demo.md)

## REFERENCE

- [CRDs update](https://apisix.apache.org/docs/helm-chart/apisix-ingress-controller/#crd)
- [Configuration Examples](https://apisix.apache.org/docs/ingress-controller/reference/apisix-ingress-controller/examples/)
- [Admin API](https://apisix.apache.org/docs/apisix/admin-api)
- [Plugins](https://apisix.apache.org/docs/apisix/plugins/ai-proxy/)
