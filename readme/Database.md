
## Database & Migrations — Detailed Guide

This document explains the database schema decisions, migration workflow, and operational practices for the project's relational database (Postgres recommended). It covers modeling patterns, migrations, indexing, backup, and troubleshooting.

---

1) Schema overview & core tables

- `users`: user account information, hashed password, roles, profile info. Use UUID primary key (type `UUID`) to avoid coupling to a single DB instance.
- `sessions`: chat / app sessions with `session_id`, `user_id`, `started_at`, `last_active`.
- `conversations`, `messages`: chatbot conversation storage; messages include `sender`, `text`, `metadata`, and references to retrieved sources.
- `symptom_requests`: stores inputs to Symptom Checker and returned predictions for audit and retraining.
- `analytics_logs`: aggregated events used for monitoring and model evaluation.

Schema design notes

- Prefer normalized models for transactional data; use event logs for append-only analytics.
- Use foreign keys with `ON DELETE CASCADE` carefully — ensure admin cleanup operations handle cascading deletes.

---

2) Choosing UUIDs and indexing

- Primary keys: `UUID` for `users`, `sessions`, `conversations`.
- Indexes: add indexes on frequently queried columns (e.g., `user_id`, `created_at`, `session_id`).

Example index creation (Alembic)

```python
op.create_index('ix_messages_session_id', 'messages', ['session_id'])
```

---

3) Migrations best practices

- Use Alembic to create version-controlled migration scripts under `backend/alembic` or `backend/app/migrations`.
- Workflow:
	1. Create revision: `alembic revision --autogenerate -m "add column"
	2. Review and edit migration
	3. Run tests on staging
	4. Apply in production via migration job before app rollout

Breaking change strategy

- Avoid destructive changes in a single release; prefer phased migration: add new column, backfill, switch reads, then remove old column in a later release.

---

4) Backups & restores

- Schedule daily full backups and more frequent WAL shipping for point-in-time recovery.
- Test restores periodically to ensure backup integrity.

---

5) Performance & scaling

- Read replicas: use read replicas for analytics and heavy read workloads.
- Partitioning: for very large event tables, partition by time (monthly) to improve query performance and retention.

Query optimization

- Analyze slow queries and add indexes; prefer materialized views for expensive aggregations used in dashboards.

---

6) Data retention & GDPR/PII

- Determine retention windows for logs and audit data. Provide redaction and deletion endpoints for PII subject requests.

---

7) Example Alembic migration flow

```bash
cd backend
alembic upgrade head
```

If using CI/CD, run migrations as a job step before the new service is promoted.

---

8) Troubleshooting common DB issues

- Connection errors: check connection string (`DATABASE_URL`) and network access.
- Locking/contention: find long-running queries and add indexes or optimize transaction granularity.

---

9) Observability

- Monitor DB metrics: connections, slow queries, cache hit rate, write throughput.
- Alert on replication lag, long-running migrations, or backup failures.

---

10) File references

- Models: [backend/app/models](backend/app/models#L1)
- Migration scripts: [backend/alembic](backend/alembic#L1) or [backend/app/migrations](backend/app/migrations#L1)
