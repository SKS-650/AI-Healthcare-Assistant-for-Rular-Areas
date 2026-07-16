
## Deployment & Operations — Practical Guide

This document covers deployment patterns, environment configuration, CI/CD, and operational best practices used by the project. It focuses on reproducible, containerized deployments and safe release procedures.

---

1) Supported deployment approaches

- Local development: `docker-compose.yml` orchestrates backend, database (Postgres), and optional services (Redis, vector store).
- Production: container images built and deployed to a container registry and run on Kubernetes / managed services.
- Serverless or PaaS: lighter deployments for smaller teams using managed Postgres and serverless containers.

---

2) Docker & compose

- `Dockerfile` in `backend/` builds the app image. `docker-compose.yml` wires up `backend`, `db`, `redis`, and optional `vector-db`.
- Use environment files (`.env`) to provide runtime secrets to containers in dev; never commit secrets to VCS.

Quick local start

```powershell
docker-compose up --build
```

Health checks

- Configure healthcheck endpoints (`/healthz`) and let orchestrators restart containers on failure.

---

3) CI/CD pipeline

- Repo provides `ci_cd/` with GitHub Actions workflows. Typical pipeline steps:
	- Lint and unit tests
	- Build backend image and push to registry
	- Build mobile artifacts and run integration tests
	- Deploy to staging environment and run smoke tests

Blue/green and canary deployments

- For production, prefer blue/green or canary deployments to reduce risk when promoting new model-aware code.

---

4) Configuration & secrets management

- Use environment variables for secrets and rotate them regularly.
- For production, use secret managers (Azure Key Vault, AWS Secrets Manager) and never store secrets in plain text in the repo.

---

5) Database migrations & release ordering

- Apply Alembic migrations before starting the new backend version if migrations are backward-compatible. Use the following general pattern:
	1. Deploy DB migration job
 2. Run migrations (with maintenance mode if needed)
 3. Deploy new service version

When removing columns or renaming fields, perform multi-step deploys: add new column, write data, migrate reads, remove old column in later deploy.

---

6) Model artifact management & deployment

- Model artifacts are versioned and stored in `ai_models/*/saved_models`. When deploying models:
	- Upload model artifact to storage or include in container image
	- Update `model_version` metadata in backend configuration
	- Run smoke tests verifying model outputs on a small test set before marking it as production

---

7) Monitoring, logging & alerting

- Metrics: instrument endpoints with Prometheus metrics (request latency, model latency, emergency events)
- Logs: structured JSON logs shipped to external log storage (ELK/Datadog)
- Alerts: set thresholds for SLO breaches, high emergency event surge, or model degradation

---

8) Disaster recovery & backups

- Database backups: schedule regular DB dumps and test restores.
- Model artifacts: back up model versions with metadata and data provenance.

---

9) Security & compliance checklist

- TLS for all endpoints
- Web application firewall for public endpoints
- Audit logging for admin actions and PII access
- Penetration testing and vulnerability scanning of dependencies

---

10) Rollback strategy

- Keep last known-good container/tag available to allow fast rollback.
- Run database-compatible schema changes or support rolling back app without schema downgrade where possible.

---

11) Example GitHub Actions snippet (high-level)

```yaml
name: CI
on: [push]
jobs:
	test:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v2
			- name: Run tests
				run: |
					pip install -r backend/requirements.txt
					pytest -q

	build:
		needs: test
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v2
			- name: Build & push image
				run: |
					docker build -t myrepo/backend:$GITHUB_SHA backend/
					docker push myrepo/backend:$GITHUB_SHA
```

---

12) Post-deploy validation

- Smoke tests for key endpoints (auth, symptom-checker predict, chatbot health)
- Canary sampling to evaluate model behavior vs baseline

---

13) References & files

- Docker compose: [docker-compose.yml](docker-compose.yml#L1)
- CI: [ci_cd/](ci_cd#L1)
