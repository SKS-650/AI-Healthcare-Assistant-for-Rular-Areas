## Offline Sync & Offline Mode — Implementation Details

The Offline module defines the client-server synchronization protocol and client-side queuing strategy used by the mobile app. The goal is to make the mobile experience robust to network interruptions while preserving correctness and idempotency.

Problems solved

- Intermittent connectivity in field deployments
- Duplicate or out-of-order operations due to retries
- Conflict resolution for concurrent edits

---

1) Client-side architecture

- Offline queue: persistent ordered list of operations (create/update/delete) stored in local DB (SQLite/Hive).
- Worker: background service that attempts to flush queued operations to the server when network connectivity is restored.
- Local state: cached models and conversation history for responsive UI.

Operation envelope

- Each queued operation includes:
	- `op_id` (UUID)
	- `type` (create/update/delete)
	- `resource` (endpoint or resource type)
	- `payload` (operation data)
	- `idempotency_key` (for safe retries)
	- `timestamp`

---

2) Sync API contract

- Endpoint: `POST /api/v1/sync` accepts a batch of operations and returns per-item status and authoritative ids.

Request example

```json
{
	"operations": [
		{"op_id":"uuid", "endpoint":"/symptom-checker/predict","payload":{...}, "idempotency_key":"abc"}
	]
}
```

Response example

```json
{
	"results": [
		{"op_id":"uuid","status":"ok","server_id":"s123","message":"accepted"}
	]
}
```

Server behavior

- The server must honor `idempotency_key` to detect duplicate operations and return the previous result if present.
- For conflicting updates, server returns `conflict` with server version and optional merge hints.

---

3) Retry & backoff strategy

- Exponential backoff with jitter is used to avoid synchronized retries across many clients. Use capped max delay to keep UI responsive.

Formula (example)

$$
delay_k = \min(delay_{max}, base \cdot 2^{k}) + U(0, jitter)
$$

---

4) Conflict resolution strategies

- Last-write-wins (timestamp-based) for non-critical fields.
- Server-authoritative merging for records that require business logic.
- UI-driven manual resolution for critical conflicts (present both versions to user).

---

5) Idempotency and deduplication

- Use `idempotency_key` (client-generated) to allow safe retries of create operations without duplication.
- Server stores a small cache of recent idempotency keys mapped to results (with TTL).

---

6) Security considerations

- All queued payloads are stored encrypted on device if they contain PII.
- Authenticate sync requests using the user's access token; accept a refresh-token-based handshake if access token expired.

---

7) Observability & testing

- Log sync events and per-operation status to server-side analytics for monitoring success rate and latency.
- Integration tests: simulate offline mode by blocking network and ensuring queued operations flush and produce expected server-side state.

---

8) Example client-side pseudo-code

```python
def enqueue(op):
		db.insert(op)

async def sync_worker():
		while True:
				ops = db.fetch_batch()
				if not ops: await sleep()
				try:
						resp = http.post('/api/v1/sync', {"operations": ops})
						handle_results(resp)
				except NetworkError:
						await sleep(backoff())
```

---

9) Integration with mobile app

- The mobile app constructs idempotency keys for each user action and uses the offline queue for symptom submissions and chat messages when connection is lost.

---

10) Glossary

- Idempotency key: client-generated token to make retries safe
- Offline queue: persistent list of operations waiting for upload
