# FulfillIQ 2.0 — Stage 3 Phase 4 — Open Questions (Mark / Maya only)

**Date:** 2026-09-08 (America/Chicago)  
**Rule:** Prefer locking without stakeholder return when the item is methodological. Only business / authority items remain here. Cross-review “unresolved Maya choices” on window, elevation bar, and corrective-path gate **types** were closed by coordinator resolutions in `DESIGN_RECONCILIATION_MATRIX.md` and encoded in `CANDIDATE_MEASUREMENT_DESIGN.md`.

---

## Still needs Mark / Maya

| # | Item | Why stakeholder / ops—not methodology | Default if unanswered before Stage 4 build |
| --- | --- | --- | --- |
| 1 | **Authoritative available-slot integer S** for the mid-month VP ops meeting (`0 ≤ S ≤ C`, with **C = 20** locked) | Concurrent capacity already occupied by ongoing plans is an **ops fact**, not a measurement choice. Design locks membership-first + no padding; it cannot invent occupancy from Olist. | Simulation / dry-run uses **S = C = 20**. Decision-ready release for a live meeting waits on ops-supplied S. |
| 2 | **Confirm C = 20** as the hard integer ceiling for locked “about 20” | Stakeholder phrasing was approximate; coordinator operationalized C = 20. Brief confirmation avoids a mid-Stage-4 capacity rewrite. | Proceed with **C = 20**; change requires a new spec version. |

---

## Explicitly closed without return (do not re-open as Maya choices)

| Topic | Closed as |
| --- | --- |
| Purchase window | LOCK B: 2018-01-01 incl → 2018-09-01 excl |
| Repetition halves | LOCK non-overlapping Jan–Apr vs May–Aug (fix A April overlap) |
| Volume floor | LOCK post-exclusion eligible_n < 30 → standard; ≥30 provisional |
| Lateness | LOCK DATE rule; twin mandatory; action disagree → INCONCLUSIVE |
| Elevation / membership spine | LOCK A-style warrant (elevation + repetition + fit); KEEP ≥5 late & ≥3pp vs LOO provisional; REJECT P75-alone |
| Multi-seller | ADOPT N4-style INCONCLUSIVE |
| Coverage | KEEP ≥95% provisional membership gate |
| Handoff gate types | KEEP ≥3 / ≥50% / ≥90% provisional + explicit definitions; not causation |
| Actions / cap | LOCK membership-first; ENROLL_RECOMMENDED \| WATCH \| STANDARD_NOT_QUALIFIED \| INCONCLUSIVE; no pad |
| SQL B | LOCK A raw B_orders+B_items+B_sellers; R(B) rebuilds; A ↛ B |
| Recon | Exact late_n, eligible_n, membership, rank, selected, action; neither ships on mismatch |
| seller_plan_enrollment | REJECT as Stage 4 blocker; output is prospective recommendation; disclose non-RCT |
| Fill-to-cap / severity-only / causal claims | REJECT |

---

## Not Mark/Maya — Stage 4 verification (analyst)

- Presence and semantics of `order_delivered_carrier_date` and item `shipping_limit_date` for the handoff path (if unsuitable → block fit path per candidate; do not invent fields).  
- Snapshot freeze, temporal types, key uniqueness, and recon fixtures.  
- These are Design Gate / Stage 4 readiness checks, not business rewrites of the locked question.

---

*If both rows in “Still needs Mark / Maya” are accepted as defaults, Phase 6 candidate may proceed to audit without a stakeholder round-trip.*
