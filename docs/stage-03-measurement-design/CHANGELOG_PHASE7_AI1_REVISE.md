# CHANGELOG — Phase 7 AI1 REVISE

**Document revised:** `CANDIDATE_MEASUREMENT_DESIGN.md`  
**From:** `fulfilliq-2.0-stage3-candidate-v0.1` (Phase 6 draft)  
**To:** `fulfilliq-2.0-stage3-candidate-v0.2` (Phase 7 revise)  
**Audit:** `AI1_PHASE7_AUDIT_ChatGPT.md` (verdict **REVISE**)  
**Date:** 2026-09-08 (America/Chicago)  
**Constraint honored:** Approved decision (§2) and locked analytical question (§3) **not rewritten**. No executable SQL/R. All numeric cutoffs remain **provisional**.

Provenance consulted: `DESIGN_RECONCILIATION_MATRIX.md`, `PHASE4_OPEN_QUESTIONS.md`, `00_SHARED_DESIGN_PACKET.md`, `FulfillIQ_Data_Profile_V1_READONLY.md`, Designs A/B.

---

## Gap closures (all 8)

### 1) Provenance / schema / volume skew
- Added inspectable Phase 4 provenance paths and short matrix lock excerpts in §§1–4, 6–8, 10.
- Featured “not in DB” marked **PENDING-DB** (live schema verification) while business-scope exclusion remains SR.
- Volume-skew VF explicitly cites `FulfillIQ_Data_Profile_V1_READONLY.md` (median 6 delivered; 79.74% < 30) as profile context, not locked-window headcount.
- §24 artifact table expanded with profile, DB context, audit, and changelog paths.

### 2) H2 vs gate
- Rewrote H2 as **parity-or-above persistence** aligned to “LFR ≥ half comparator (equality passes).”
- Explicitly states the gate does **not** claim strict elevation and does **not** rule out a single pooled episode straddling the April–May boundary.
- §17.1 step 5 and §11.1 wording aligned.

### 3) H3 vs handoff
- Stated repetition (halves) applies to **customer lateness only**.
- Handoff membership = **full-window** test (not half-repeated).
- Distinguished §11.2 membership handoff path from §11.3 ship-limit/carrier **diagnostic summaries**.

### 4) N4 multi-seller counterfactual (fully specified)
- New §17.4: gates recomputed on single-seller associations (ss volume ≥30; ≥5 late & ≥3 pp vs ss LOO; both-half ss persistence).
- Reference population = assessable set with ss LOO totals; same PA usability integers on ss comparator.
- **Too thin:** `eligible_n_ss < 30`. **Majority:** `eligible_n_ms/eligible_n > 0.5` or `late_n_ms/late_n > 0.5`.
- Ss comparator unusable → ss not rate-clearing → INCONCLUSIVE if all-order would YES.
- Precedence: after steps 1–6, before rank, inside each Run D/T; does not upgrade all-order failures.

### 5) N5 timestamp override (fully specified)
- New §17.5: two runs (Run D date, Run T timestamp); freeze **after** capacity selection; capacity-only action diffs **count**.
- Removal of disagreers → single refill under Run D only; no T re-loop; disagreers never refilled to ENROLL.
- Interaction with N4 defined; N5 stated as **exception** to diagnostic-only sensitivity rule (§11.4).
- Required counterfactual/recon output fields listed for A and R(B).

### 6) Available capacity S
- §17.3 defines \(S = \max(0, C - O - R)\) as available **new-plan** slots after occupancy/reservations.
- Authoritative S required for operational release; simulation S=C explicitly labeled full-capacity simulation.
- WATCH and INCONCLUSIVE confirmed **non-enrolling** (standard terms operationally).

### 7) Operational-release hold
- Replaced discretionary §14 language with defined **§14.1 operational-release hold**: trigger evidence, owner (Mark documents; ops release path), scope (holds live enrollment release only), calculated membership preserved, when a new spec version is required.

### 8) Parameter register expanded
- Consolidated controlling parameters including comparator usability cutoffs, N4/N5 rule references, authoritative S / simulation label, WATCH/INCONCLUSIVE non-enroll, and operational-release hold.
- Distinguished decision parameters vs reporting bands vs diagnostic stress tests (N5 sole action-override exception).

---

## Sections touched (map)

| Area | Sections |
| --- | --- |
| Header / provenance | 1, 4, 24, register |
| Hypotheses | 6 |
| Population / VF | 7.4, 16 |
| KPI / sensitivities | 10, 11.1–11.4 |
| Confounders / hold | 14, 14.1, 15 |
| Decision / N4 / N5 / S | 17.1–17.6 |
| Contracts | 20, 22, 23 |
| Handoff / assumptions | 25, 26 |

---

## Not changed

- Verbatim approved decision and locked analytical question.
- Structural locks: 8-month window, non-overlapping halves, C=20, A-style membership spine, raw three-table SQL B, exact recon, reject P75-alone / fill-to-cap / severity-only / causal claims.
- No new numeric cutoffs beyond existing A/B integers; all PA levels remain provisional.

---

*End of CHANGELOG_PHASE7_AI1_REVISE.md*
