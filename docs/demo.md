# Demo

## [Configure Routes](https://apisix.apache.org/docs/ingress-controller/getting-started/configure-routes/) ([doc](https://apisix.apache.org/docs/apisix/getting-started/configure-routes/))

```bash
# deploy sample upstream
kubectl apply -f examples/routes/deployment.yaml  # kubectl apply -f https://raw.githubusercontent.com/apache/apisix-ingress-controller/refs/heads/v2.0.0/examples/httpbin/deployment.yaml

# If you are using Gateway API (needed for HTTPRoute), you should first configure the GatewayClass and Gateway resources:
kubectl apply -f examples/routes/gateway.yaml

# create HTTPRoute, Ingress or ApisixRoute
kubectl apply -f examples/routes/route-apisixroute.yaml
kubectl apply -f examples/routes/route-httproute.yaml
kubectl apply -f examples/routes/route-ingress.yaml

# verify
kubectl port-forward svc/apisix-gateway 9080:80
curl http://127.0.0.1:9080/ip

curl -s -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' http://apisix-admin-172.18.0.2.nip.io/apisix/admin/services | jq
```

curl example

```bash
# create upstream
curl http://apisix-admin-172.18.0.2.nip.io/apisix/admin/upstreams/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "type": "roundrobin",
    "key": "remote_addr",
    "nodes": {
        "192.168.1.151:8000": 1
    }
}'

# create route
curl http://apisix-admin-172.18.0.2.nip.io/apisix/admin/routes/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "uri": "*",
    "upstream_id": 1
}'
```

## [Load Balancing](https://apisix.apache.org/docs/ingress-controller/getting-started/load-balancing/) ([doc](https://apisix.apache.org/docs/apisix/getting-started/load-balancing/))

The main reason to use ApisixUpstream in ApisixRoute, even though the backends field also supports load balancing, is to provide richer and more advanced upstream features and to improve maintainability and flexibility.

Key points:

- Advanced Features: ApisixUpstream is a dedicated Kubernetes CRD that allows you to configure advanced upstream features such as custom load balancing algorithms (e.g., ewma, chash), health checks, retries, and timeouts. These features go beyond the basic load balancing that can be set via the backends field in ApisixRoute. For example, you can specify sticky sessions or use consistent hashing based on specific headers, which is not possible with just the backends field ApisixUpstream concept.
- Separation of Concerns and Reusability: By defining upstream configuration in ApisixUpstream, you decouple the upstream logic from the route logic. This means multiple routes can reference the same upstream configuration, reducing duplication and making updates easier. If you need to change the upstream settings (like load balancing type or health check), you only need to update the ApisixUpstream resource, not every ApisixRoute that uses it Upstream Terminology.
- Support for External Services and Service Discovery: ApisixUpstream enables integration with external services (via externalNodes) and service discovery mechanisms (via discovery field), which cannot be achieved with the backends field alone. This is especially useful for scenarios where your backend is not a Kubernetes service but an external domain or a service discovered via DNS or other mechanisms External Services Tutorial, Service Discovery Tutorial.
- Maintainability: When you have repetitive configurations (e.g., the same load balancing or health check settings across multiple routes), using ApisixUpstream avoids the need to update each route individually, making your configuration more maintainable and less error-prone Route Terminology.

In summary, while the backends field in ApisixRoute provides basic load balancing, ApisixUpstream is used for more advanced, reusable, and maintainable upstream configurations, especially when you need features like custom load balancing, health checks, retries, or integration with external services and service discovery.

```bash
kubectl apply -f examples/lb/lb-route.yaml

kubectl -n apisix-ingress port-forward svc/apisix-gateway 9080:80
resp=$(seq 50 | xargs -I{} curl "http://127.0.0.1:9080/headers" -sL) && \
  count_httpbin=$(echo "$resp" | grep "httpbin.org" | wc -l) && \
  count_mockapi7=$(echo "$resp" | grep "mock.api7.ai" | wc -l) && \
  echo httpbin.org: $count_httpbin, mock.api7.ai: $count_mockapi7

# TODO: fix apisix-172.18.0.2.nip.io
resp=$(seq 50 | xargs -I{} curl "http://apisix-172.18.0.2.nip.io/headers" -sL) && \
  count_httpbin=$(echo "$resp" | grep "httpbin.org" | wc -l) && \
  count_mockapi7=$(echo "$resp" | grep "mock.api7.ai" | wc -l) && \
  echo httpbin.org: $count_httpbin, mock.api7.ai: $count_mockapi7
```

## [Key Authentication](https://apisix.apache.org/docs/ingress-controller/getting-started/key-authentication/) ([doc](https://apisix.apache.org/docs/apisix/getting-started/key-authentication/))

## [Rate Limiting](https://apisix.apache.org/docs/ingress-controller/getting-started/rate-limiting/) ([doc](https://apisix.apache.org/docs/apisix/getting-started/rate-limiting/))
