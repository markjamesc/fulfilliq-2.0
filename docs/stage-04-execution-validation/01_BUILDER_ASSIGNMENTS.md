# Stage 4 Builder Assignments — FulfillIQ 2.0

**Status:** Kickoff assignments for execution / validation  
**Date:** 2026-09-08 (America/Chicago)  
**Controlling packet:** `00_STAGE4_SHARED_PACKET.md` (from locked `Stage_03_Measurement_Design.md` v0.2.1)  
**Coordinator:** Grok Bot  
**Rule:** Do **not** write executable SQL in this kickoff packet. Builders receive assignments and contracts only; implementation follows in separate builder prompts/artifacts.

---

## 1. Role map

| Role | Mode / builder | Deliverable | Independence |
| --- | --- | --- | --- |
| **AI1** | ChatGPT Work GPT-6 Astra High | **SQL A** — judged seller table + audits from frozen source + locked spec | Must **not** see SQL B or R(B) |
| **AI2** | Grok Expert | **SQL B** — raw `B_orders` + `B_items` + `B_sellers` package + manifest | Must **not** be A with columns dropped; no eligibility/late/membership/rank/action |
| **AI3** | DeepSeek DeepThink | **R(B)** — R reconstruction script from B + spec only | Must **not** see SQL A; run later on Mark PC MySQL/R |
| **Coordinator** | Grok Bot | Shared packet, assignments, recon orchestration, gate tracking | Coordinates; does not substitute for independent A / B / R(B) builds |

**R style reference for AI3:** `docs/orchestration/frameworks/ENGINE.md` (R Workflow Engine — tidyverse dialect, thin CONFIG, stage functions, runner).

---

## 2. Assignment briefs (no SQL yet)

### 2.1 AI1 — SQL A (ChatGPT Work GPT-6 Astra High)

**Inputs (when build is authorized):** frozen `fulfilliq` source snapshot + locked Stage 3 / Stage 4 shared packet + parameter register (simulation **S = C = 20**, labeled full-capacity simulation).

**Outputs:** judged seller table at one-row-per-seller grain covering identity, population, LFR + timestamp twin, N4/N5 evidence, half counts, reference/LOO, handoff, gate pass/fail, membership, rank, selected, action, simulation flag, audits — per §8.2 of `00_STAGE4_SHARED_PACKET.md`.

**Forbidden:** reading B or R(B); inventing featured/plan columns; padding; causal claims; skipping N4/N5.

### 2.2 AI2 — SQL B (Grok Expert)

**Inputs (when build is authorized):** same frozen snapshot identity as A.

**Outputs:** three raw relations (`B_orders`, `B_items`, `B_sellers`) + extraction manifest (snapshot id, timestamps, types, row counts, hashes, null/encoding/timezone conventions). Full required-column snapshot; preserve duplicates/invalids.

**Forbidden:** seller aggregates; eligibility/late/membership/rank/action flags; shipping “late” precomputes as controlling contract; any form of “A with columns dropped.”

### 2.3 AI3 — R(B) (DeepSeek DeepThink)

**Inputs (when build is authorized):** B package + manifest + frozen spec/config only. Style: `ENGINE.md`.

**Outputs:** R script that reconstructs associations, applies window/exclusions/gates, N4/N5, rank/select under simulation S=C=20, emits **same judged schema as A** + audits.

**Execution environment (later — Mark PC):** MySQL + local R (see §3). Script is authored for that environment; live run is **not** part of this kickoff artifact write.

**Forbidden:** reading A or A intermediates; recon feedback before first R(B) freeze; inventing thresholds; float-authority LFR.

### 2.4 Coordinator — Grok Bot

- Maintain Stage 4 shared packet and builder assignments  
- Enforce independence (A ↛ B; R ↛ A; B ≠ A-dropped)  
- Orchestrate freeze → recon → mismatch protocol  
- Track PENDING-DB verification (featured/catalog absence; handoff field suitability)  
- Label simulation S=C=20 clearly on all dry-run packets  
- Do not write builder SQL in place of AI1/AI2

---

## 3. MySQL and local R environment notes (Mark PC)

| Item | Value |
| --- | --- |
| Host machine | `DESKTOP-RPECRM9` |
| MySQL schema | `fulfilliq` |
| MySQL client login-path | `fulfilliq` |
| Local R working directory | `C:\Users\Mark\Documents\R Working Directory\fulfilliq2.0` |

**Notes for later R(B) run:**

- Connect via MySQL login-path `fulfilliq` against schema `fulfilliq` on `DESKTOP-RPECRM9`.  
- Place R project / script / B extracts / judged outputs under the local R folder above (or documented subfolders therein).  
- Record snapshot identity and extraction timestamps in both A and R(B) manifests so recon can verify identical frozen source.  
- Simulation default for this Stage 4 dry-run: **S = C = 20** with explicit label *full-capacity simulation (occupancy treated as 0; not authoritative for live enrollment)*.

---

## 4. Build sequence (orchestration reminder)

1. Verify schema mappings, keys, temporal conventions, PENDING-DB featured-field check, handoff field suitability.  
2. Lock parameter register + simulation S=C=20 label + specification ID.  
3. Freeze common source snapshot identity for A and B extractions.  
4. **AI1** builds SQL A independently (must not read B/R(B)).  
5. **AI2** builds SQL B raw three-table package independently.  
6. Provide only B + frozen spec/config to **AI3**.  
7. **AI3** builds R(B); later execute on Mark PC MySQL/R.  
8. Freeze A and R(B) with hashes before recon.  
9. Reconcile per exact-match contract; on mismatch neither ships; rebuild independently.  
10. Decision-ready release only after recon + substantive review + no open operational-release hold.

---

## 5. Kickoff checklist

| Item | Status |
| --- | --- |
| Locked Stage 3 design available | Yes — `Stage_03_Measurement_Design.md` |
| Stage 4 shared packet | This folder — `00_STAGE4_SHARED_PACKET.md` |
| Builder assignments | This file |
| Executable SQL A / SQL B | **Not yet** — deferred to builder prompts |
| R(B) script | **Not yet** — deferred to AI3 prompt; style from `ENGINE.md` |
| Live R(B) run on Mark PC | **Later** — after script + B package ready |
| Authoritative live S (O, R) | Ops open question — simulation S=C=20 for dry-run |

---

*End of Stage 4 Builder Assignments. Coordinator: Grok Bot. No executable SQL in this kickoff.*
