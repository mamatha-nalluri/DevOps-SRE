# DevSecOps & SRE project architecture

```text
Pull request
  -> pytest + full Flake8 + Bandit + Gitleaks
  -> Docker test stage + runtime build
  -> Trivy HIGH/CRITICAL scan
  -> merge to main
  -> release image build, scan and push
  -> commit-specific image tag update in Git
  -> Argo CD reconciliation
  -> Kubernetes Deployment, probes, resource limits and Service
  -> Prometheus/Grafana metrics and alerts
  -> Kubernetes stdout/stderr logs; optional Loki centralization
```

## Evidence checklist
- [ ] CI checks pass on a pull request.
- [ ] Docker Hub username and token are configured as GitHub Actions secrets.
- [ ] The immutable image tag exists in Docker Hub.
- [ ] Kubernetes Deployment is available and healthcheck returns HTTP 200.
- [ ] Resource limits and restart/OOM behavior are inspected.
- [ ] Argo CD Application is Synced and Healthy.
- [ ] Grafana dashboards show pod/node CPU and memory.
- [ ] Unready and OOMKilled alerts are visible in Prometheus.
- [ ] Centralized logs are searchable in Loki if the collector is installed.
- [ ] Notification delivery is tested.

The project is not considered end-to-end validated until these checks have been run against a real cluster and the results
recorded. Never commit registry tokens, Grafana passwords, or webhook URLs.
