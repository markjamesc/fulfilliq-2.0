# Version Change Ledger

Status: **active**. V1 rows are historical baseline only (read-only context from public https://github.com/markjamesc/fulfilliq). V2 rows record method deltas locked for this run. **V1 is NOT proof that any FulfillIQ 2.0 gate passed.**

---

## V1 historical baseline (read-only)

Source: public repository [markjamesc/fulfilliq](https://github.com/markjamesc/fulfilliq) (README and committed stage docs). Numbers below are V1-published facts only; nothing here is invented for 2.0.

### V1 decision locked

- **Decision owner (fictional):** Maya Chen, Director of Marketplace Seller Operations.
- **Decision:** Which sellers, if any, to enroll in a **~30-day late-fulfillment performance plan** rather than leave on standard terms.
- **Executed operational selection (V1):** enroll **~18 sellers** (within staffing capacity; deliberately under the approximate **~20** concurrent-plan cap; do not pad).
- **Population:** **delivered** orders only; purchases **2018-01-01 through 2018-08-31**.
- **Volume floor:** provisional **≥30** usable seller-orders (post-exclusion denominator in V1 design).
- **Peer rule:** P75 candidate set exceeded capacity → raise enroll bar to **P90**; do not pad.
- **Marketplace LFR (V1 executed):** overall late-fulfillment rate **~7.62%** (4,084 late / 53,611 eligible seller-orders).

Other V1 published outcomes (context only, not 2.0 gates): sellers meeting volume floor 393; pass P90 = 40; enroll 18; watch 63; inconclusive 36; standard terms 2,212.

### V1 Stage 4 recon LIMIT

- V1 Stage 4 treated the committed **seller-level CSV** as the analytical handoff consumed by R.
- **R rechecked / validated that SQL seller export (Clerk A path)** — one judged seller export, not an independent dual-clerk rebuild.
- **No Clerk B lower-grain dump** and no **R(B) rebuild from B only** in V1.
- V1 README boundary: committed SQL was the agreed MySQL specification; the repo demonstrates reviewed SQL construction plus executed R on the seller CSV; it does **not** claim independent live MySQL reproduction of the committed SQL file inside that repo alone.

### Explicit non-inheritance

V1 dialogue, measurement locks, SQL, R evidence, and the 18-seller roster are **historical baseline only**. They do **not** prove that any FulfillIQ **2.0** stage, execution, reconciliation, or gate has passed.

---

## V2 method deltas already locked

| Topic | Version 1 approach | Version 2 approach | Retained | Changed | Why | Framework | Practical improvement |
|---|---|---|---|---|---|---|---|
| Repository | `markjamesc/fulfilliq` | `markjamesc/fulfilliq-2.0` | V1 as historical baseline | New authoritative repo | Prompt requires separation | Master orchestration | Clear V1 vs V2 provenance |
| Stage 4 recon | R rechecked SQL seller CSV (Clerk A only); no Clerk B grain dump | **SQL A + SQL B + R(B) from B only**; exact A vs R(B) reconciliation | Same Olist / MySQL context expected | Independent lower-grain dump + rebuild | Reduce shared implementation error | Validation framework | Two implementations, one spec |
| AI instances | Mixed / partial three-AI use in V1 docs | **Three real AI instances** (separate contexts; no single-response role-play as three) | Three-role idea | Hard independence rule | Framework independence | All stage frameworks | Auditable independent review |
| Gates | Partial process record | **Gate log** + formal stage gates; human-owner approvals required | Decision-first intent | Explicit gate logging | Demonstrate methodology | Master orchestration + stage frameworks | Pass/fail provenance |
| Change control | Partial docs on V1 | **Version Change Ledger** (this file) | Continuity of Maya scenario as context only | Mandatory ledger rows | Prompt requires V1/V2 comparison | Master orchestration | Auditable method deltas |
| Power BI | Not the V1 primary publish path (Excel evidence pack) | **Power BI out of this run** | Evidence-bounded publish still required | No Power BI deliverable in 2.0 authorized scope | Scope lock for this run | Master orchestration / owner scope | Avoid unscoped tooling work |
| Process records | Partial docs on V1 | Full stage records, gates, ledgers, dialogue | Continuity of Maya scenario as context only | New dialogue and gates required | Demonstrate methodology | All stage frameworks | Auditable 2.0 run |
| Stages authorized at start | Full V1 portfolio path completed historically | Authorized 2.0 start: **Stages 1–2 only** until Start/Framing gates pass | Five-stage methodology | Do not begin Stage 3 early | Master prompt end instruction | Start and Framing | Prevent premature measurement/SQL |

Do not treat a blank cell, a V1 number, or a stub row as a passed **2.0** gate.
