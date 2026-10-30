# DevOps-SRE Assessment — DevSecOps, Kubernetes and Observability

A hands-on SRE project demonstrating secure container builds, CI security gates, Kubernetes deployment, GitOps and observability.

## Architecture

See [architecture](docs/architecture.md), [Kubernetes and Argo CD setup](k8s/README.md), and [observability setup](observability/README.md).

## Task 1 — Container and CI/CD

- Multi-stage Dockerfile keeps test tools out of the runtime image.
- Runtime runs as non-root and exposes an HTTP health endpoint at `/healthcheck`.
- Pull request CI runs pytest, full Flake8 lint, Bandit SAST, Gitleaks secret scanning, and Trivy image scanning.
- Release workflow builds and scans the runtime image before publishing.

### Required GitHub Actions secrets
- `DOCKERHUB_USERNAME`: Docker Hub username.
- `DOCKERHUB_TOKEN`: Docker Hub access token (not your account password).

Configure these under repository Settings → Secrets and variables → Actions.

## Task 2 — Kubernetes and GitOps

Kubernetes manifests are in `k8s/base`; the Argo CD Application template is in `gitops/argocd/application.yaml`.
Read [k8s/README.md](k8s/README.md) before deploying. Replace the image placeholder with your Docker Hub username and ensure the image exists.

## Task 3 — Observability and SRE

Prometheus alert rules are in `observability/prometheus/alert-rules.yaml`. Follow [observability/README.md](observability/README.md) for Prometheus/Grafana setup, app log inspection and Loki collector guidance.

## Local checks

```bash
python -m pip install -r requirements-dev.txt
python -m pytest -v
python -m flake8 app test --max-line-length=100 --statistics
python -m bandit -r app -s B104 -ll
docker build --target test -t devops-sre:test .
docker build --target runtime -t devops-sre:local .
```

## Project completion checklist

- [ ] PR checks pass, including secret and container scans.
- [ ] Release pipeline publishes an immutable commit-specific image.
- [ ] Kubernetes deployment and health check pass in a local cluster.
- [ ] Argo CD reports Synced and Healthy.
- [ ] Grafana dashboards and Prometheus alerts are verified.
- [ ] Centralized log collection is configured and tested.
- [ ] Screenshots/logs of validation are captured for submission.

Do not commit real secrets or claim a validation step is complete until it has been run.
