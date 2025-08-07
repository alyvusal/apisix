#!/bin/bash

helm upgrade -i apisix apisix/apisix \
  --create-namespace --namespace apisix-ingress \
  --version 2.11.3 \
  -f k8s/helm/apisix-etcd.yaml && \

kubectl -n apisix-ingress wait --for=condition=Ready pod -l app.kubernetes.io/instance=apisix --timeout 10m && \

helm upgrade -i apisix-ingress-controller apisix/apisix-ingress-controller \
  --create-namespace --namespace apisix-ingress \
  --version 1.0.3 \
  -f k8s/helm/apisix-ingress-controller.yaml && \
kubectl -n apisix-ingress wait --for=condition=Ready pod -l app.kubernetes.io/instance=apisix-ingress-controller --timeout 10m && \

helm upgrade -i apisix-dashboard apisix/apisix-dashboard \
  --create-namespace --namespace apisix-ingress \
  --version 0.8.3 \
  -f k8s/helm/apisix-dashboard.yaml && \

sleep 60 && \

echo "" && \
echo "Routes created:" && \
curl -s -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' http://apisix-admin-172.18.0.2.nip.io/apisix/admin/services | jq -r .list.[].value.name
