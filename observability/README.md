# Task 3 — Observability and SRE

These steps assume a local Kubernetes cluster, kubectl and Helm 3.

## Prometheus and Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --wait
kubectl apply -f observability/prometheus/alert-rules.yaml
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Open http://localhost:3000. Retrieve the initial password directly in your terminal; never commit it:

```bash
kubectl -n monitoring get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

Use the Kubernetes dashboards for node, pod and cluster CPU/memory. Add a panel for
`container_memory_working_set_bytes{namespace="devops-sre"}`.

## Application logs

The app logs to stdout, so Kubernetes captures the logs:

```bash
kubectl -n devops-sre logs deployment/devops-sre --all-pods=true
```

For centralized logs, install Loki and configure a compatible log collector (such as Grafana Alloy) to forward container
stdout/stderr to Loki. Confirm the collector's values against the chart version installed; do not assume a deprecated
agent is supported by current charts.

## Alerting

The PrometheusRule alerts on pods that remain unready and containers whose last termination reason is OOMKilled.
Verify that kube-state-metrics exports `kube_pod_container_status_last_terminated_reason` in your version. Configure
a Grafana contact point and notification policy for `severity=warning` and `severity=critical`, then test a notification.

NetworkPolicies are enforced only if the cluster's CNI supports them. The application intentionally allocates memory over
time; the 400Mi limit is designed to let you observe memory pressure/restarts in a test cluster.
