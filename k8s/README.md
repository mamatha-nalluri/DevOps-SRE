# Task 2 — Kubernetes and Argo CD

## Prerequisites
- Docker Hub account with the runtime image pushed by the release workflow
- Docker Desktop Kubernetes, Kind or Minikube
- kubectl, Helm 3 and Argo CD

## Configure image name
Replace `DOCKERHUB_USERNAME` in `k8s/base/deployment.yaml` with your Docker Hub username for the first deployment.
The release workflow should subsequently update the image tag to a commit-specific tag.

## Validate and deploy

```bash
kubectl kustomize k8s/base
kubectl apply -k k8s/base
kubectl -n devops-sre get deployments,pods,svc,resourcequota,networkpolicy
kubectl -n devops-sre rollout status deployment/devops-sre
kubectl -n devops-sre port-forward svc/devops-sre 8080:80
curl -i http://localhost:8080/healthcheck
```

The Deployment uses two replicas, non-root execution, read-only root filesystem, dropped capabilities, readiness/liveness
probes, CPU/memory requests and limits. The app intentionally leaks memory. Inspect the behavior with
`kubectl -n devops-sre describe pod <pod-name>` and `kubectl -n devops-sre get pods`.

## Argo CD

Install Argo CD in the cluster using the official instructions. Then:

```bash
kubectl apply -f gitops/argocd/application.yaml
kubectl -n argocd get applications
```

The Application tracks the main branch and enables automated sync, pruning and self-healing. The application manifest
is a template; apply it only after the Kubernetes base manifests are validated and image tag exists.

## Security notes
- Do not commit credentials. The app currently does not require runtime secrets.
- NetworkPolicy enforcement depends on the cluster CNI.
- `LOG_LEVEL` is passed as an environment variable but the current app does not consume it.
