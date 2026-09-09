# Stage 4 Shared Packet — FulfillIQ 2.0 Execution / Validation Kickoff

**Status:** Condensed controlling packet for Stage 4 builders (from locked Stage 3)  
**Source:** `/workspace/fulfilliq-2.0/docs/stage-03-measurement-design/Stage_03_Measurement_Design.md` (locked Design Gate copy of candidate v0.2.1)  
**Spec version:** `fulfilliq-2.0-stage3-candidate-v0.2.1`  
**Date:** 2026-09-08 (America/Chicago)  
**Rule:** Do **not** rewrite the approved decision or locked analytical question. Do **not** write executable SQL/R in this packet. All numeric cutoffs are **provisional (PA)** unless marked structural LOCK/AM. Non-RCT; no causal claims.

**Origin legend:** SR = stakeholder requirement; AM = accepted methodological choice; PA = provisional assumption; VF = verified data fact; UL = unresolved limitation; PENDING-DB = awaiting Stage 4 schema verification.

---

## 1. Approved decision (verbatim — SR)

Maya Chen must decide which marketplace sellers if any to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms to reduce late customer deliveries under hard concurrent capacity about 20 (no padding; enroll fewer if fewer meet bar) by mid-month VP ops meeting; tiny-volume stay standard; featured placement out; ops enrollment not RCT; numeric cutoffs designed in Stage 3 only to serve enrollment.

## 2. Locked analytical question (verbatim — SR)

Under locked concurrent capacity about 20 with tiny-volume on standard terms which sellers if any have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer ops check-ins and seller corrective path rather than ordinary marketplace monitoring?

**Membership intent:** yes/no eligibility first; if more than ~20 qualify, rank within cap; if fewer, enroll fewer; do not pad; tiny-volume never qualify.

## 3. Hard constraints (SR / AM)

| Constraint | Handling |
| --- | --- |
| Cap ~20; no padding | **C = 20** (AM); available slots **S**; select `min(S, Q)`; no fill-to-cap |
| Tiny-volume → standard | Post-exclusion `eligible_n < 30` → cannot qualify (AM; PA floor) |
| Featured / catalog out | Out of business scope (SR). Schema “not in DB” is **PENDING-DB** — Stage 4 verify absence; do not invent featured columns |
| Not RCT; not permanent offboarding | Recommendation table only; disclose non-RCT |
| Plan ~30 days | Business intervention definition, not a DB field |
| Numeric cutoffs serve enrollment | All cutoffs labeled **provisional** |

**Conclusion ceiling:** Associational / descriptive membership and ranking under hard capacity. Forbidden: causal claims, treatment effects, interpreting WATCH as a second enrollment track.

---

## 4. Population, window, and grain

### 4.1 Reporting universe

Every distinct valid `seller_id` in `raw_sellers` in the frozen snapshot, **including** zero-eligible sellers. Tiny-volume and non-qualifiers remain in the judged table with reason codes.

**B_sellers minimum:** `seller_id` (valid, non-null, unique) + source-version audit fields. Stage 4 must verify presence/uniqueness before proceeding.

### 4.2 Time window (LOCK — Design B)

| Parameter | Locked value |
| --- | --- |
| Primary purchase window | `order_purchase_timestamp >= '2018-01-01 00:00:00'` AND `< '2018-09-01 00:00:00'` (8 months) |
| Half 1 (Jan–Apr) | `>= '2018-01-01 00:00:00'` AND `< '2018-05-01 00:00:00'` |
| Half 2 (May–Aug) | `>= '2018-05-01 00:00:00'` AND `< '2018-09-01 00:00:00'` |
| Cohort clock | Purchase time |
| Post-window delivery | Still counts if purchase in window and outcome present in frozen snapshot |
| Timezone | Source recorded convention; verify in Stage 4 — no speculative conversion |

**REJECT** six-month end `2018-07-01` and overlapping April blocks.

This analysis is **retrospective, final-observed-status** on a frozen snapshot — not a live decision-day reconstruction. Record extract time, source version, outcome-observation boundary.

### 4.3 Grain and join cardinality (AM)

| Grain | Definition |
| --- | --- |
| Raw item | `(order_id, order_item_id)` — verify uniqueness; do not silently dedupe collisions |
| Measurement | `(seller_id, order_id)` — multi-item same seller once; multi-seller order → one association **each**, **shared** order-level delivery outcome |
| Decision | One seller × one window × one spec version |

**Forbidden in primary path:** payments, reviews, products, raw geolocation. Carry `multi_seller_order_flag` on evidence and judged aggregates.

### 4.4 Eligible seller–order (primary denominator)

All of: valid association with existing seller and unique order; delivered status; valid in-window purchase; nonmissing parseable actual and estimated customer-delivery; chronology OK (actual and estimated not earlier than purchase — full timestamp chronology after temporal semantics verified); ≥1 item row.

Nondelivered orders do **not** enter the primary denominator. Missing outcomes are **never** on-time.

**Coverage denominator:** `candidate_delivered_n` = §7.2 associations with delivered + in-window purchase **before** delivery-date quality exclusions. Coverage = `eligible_n / candidate_delivered_n` (zero candidate → fail).

---

## 5. Primary KPI — Seller Late-Fulfillment Rate (LFR) (AM #3)

- \(n_s =\) `eligible_n`: distinct eligible seller–orders  
- \(k_s =\) `late_n`: eligible with `DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)`  
- \(\mathrm{LFR}_s = k_s / n_s\) when \(n_s > 0\); **null** when \(n_s = 0\) (never display as 0% for no volume)

**Rules:** Same-day on time; **no grace period**; exact integer counts and unrounded comparisons; always print `late_n/eligible_n` alongside display rate.

**Mandatory timestamp twin:** On the same eligible population, late iff actual timestamp **strictly greater than** estimated timestamp. If date-rule vs timestamp-rule pipelines would **change the derived action** (including capacity selection), N5 → action = **INCONCLUSIVE** (§8.5).

---

## 6. Comparison baseline (AM — A spine)

**Assessable reference:** sellers with `eligible_n ≥ 30` **and** coverage pass. Do not require high lateness / repetition / handoff to enter reference.

**Leave-one-out comparator:**  
\(p_{-s} = (\sum_{j \ne s} k_j) / (\sum_{j \ne s} n_j)\) over reference.

**Comparator usability (PA):**

| Scope | Cutoff |
| --- | --- |
| Full-window | ≥20 other comparator sellers **and** ≥1,000 comparator eligible seller–orders |
| Each half | ≥200 comparator eligible seller–orders in **each** half (no extra ≥20 seller-count on halves) |

Usability fail → materiality/persistence gates that depend on that comparator **fail** → cannot reach membership YES.

**REJECT** volume-band P75 + market LFR + Wilson LB as sole membership.

---

## 7. Membership gates, N4, N5, capacity (all numbers PA unless noted)

### 7.1 Analytical membership YES only if all pass

Evaluate on **all-order** associations unless a step says otherwise:

1. `eligible_n ≥ 30` (post-exclusion).  
2. Coverage ≥ 95% (zero candidate → fail).  
3. Usable full-window and half comparators (§6).  
4. `late_n ≥ 5` **and** full-window LFR **at least 3 pp** above \(p_{-s}\) (exact rational / scaled cross-product; equality on “at least 3 pp” boundary passes).  
5. **Each** half (customer lateness only): ≥10 eligible, ≥2 late, LFR **≥** that half’s comparator (equality passes). Thin half fails persistence.  
6. Handoff (full-window only; **not** half-repeated) — see §7.2.  
7. Not tripped into INCONCLUSIVE by N4 or N5.

Otherwise membership **NO** (or **INCONCLUSIVE** when N4/N5 fire). Retain every failed gate.

**No** severity-only override; **no** automatic top-twenty; **no** minimum enrollment; **no** capacity-driven threshold relaxation; **no** fill-to-cap.

### 7.2 Handoff / operational fit (membership path — PA)

- `single_seller_late_n`: eligible late seller–orders whose order has exactly one distinct valid seller and no unresolved seller association.  
- `handoff_evaluable_late_n`: those with valid carrier-handoff timestamp and valid shipping deadlines for every item; carrier between purchase and actual delivery; each deadline not before purchase.  
- `handoff_support_n`: evaluable where carrier receipt is **strictly later than** the **latest** item `shipping_limit_date` on that order.

**Gates:** ≥3 supporting; supporting ≥50% of **all eligible late**; ≥90% of **single-seller late** evaluable; zero single-seller late fails.

**Disclose:** signal supports handoff-focused corrective investigation; **does not prove** seller responsibility. If required fields unavailable/unsuitable at Stage 4 verification → **block fit path** / operational-release hold; do not invent substitutes.

**Diagnostics only (cannot enroll):** median days late; >7 calendar days late; ship-limit/carrier miss summaries; Wilson 95% intervals.

### 7.3 Ranking (qualifiers only)

Only membership **YES** after N4/N5 enter \(Q\):

1. Descending excess burden \(e_s = k_s - n_s p_{-s}\) (exact rational; date-rule primary).  
2. Descending `handoff_support_n`.  
3. Descending `late_n`.  
4. Descending `eligible_n`.  
5. Ascending `seller_id` (frozen bytewise collation).

### 7.4 Cap, occupancy, available slots S — simulation default

| Symbol | Definition |
| --- | --- |
| **C** | Hard concurrent capacity = **20** |
| **O** | Existing concurrent plan occupancy (ops fact) |
| **R** | Ops-held reservations against C (else 0) |
| **S** | \(S = \max(0,\, C - O - R)\), with \(0 \leq S \leq C\) |

**Authoritative S for live release:** Ops supplies O, R, S. Measurement must not invent occupancy from Olist.

**Stage 4 simulation / dry-run (this kickoff):** Default **S = C = 20**, explicitly labeled **“full-capacity simulation (occupancy treated as 0; not authoritative for live enrollment)”**. Simulation outputs are not operational-release packets.

**Selection:** first `min(S, Q)` by ranking; **no padding**. If S = 0, selected count = 0; all YES → `WATCH`.

### 7.5 N4 — multi-seller counterfactual (AM #4)

**Purpose:** Prevent enrollment when all-order qualification may be an artifact of shared multi-seller delivery clocks.

**Key definitions:** `eligible_n_ss` / `late_n_ss`; `eligible_n_ms` / `late_n_ms`; too thin = `eligible_n_ss < 30`; majority = `eligible_n_ms/eligible_n > 0.5` **or** `late_n_ms/late_n > 0.5` (either flag; both always emitted).

**Ss counterfactual recomputes only:** volume ≥30; materiality (≥5 late + ≥3 pp vs \(p_{-s}^{(ss)}\)); each-half persistence on ss halves. **Not** recomputed: coverage; handoff; ranking/capacity.

**Fire → INCONCLUSIVE (non-enrolling):**

- **Flip:** all-order would pass steps 1–6, but ss counterfactual fails any recomputed gate.  
- **Thin + majority:** all-order would pass 1–6, `eligible_n_ss < 30`, and multi-seller majority holds.  
- **Ss comparator unusable** while evaluating ss path → ss not rate-clearing → INCONCLUSIVE if all-order would YES.

Apply N4 **after** steps 1–6, **before** rank/capacity, **inside** each of Run D and Run T. N4 does not upgrade all-order failures.

### 7.6 N5 — timestamp action override (AM #3)

Two full pipelines on the same eligible population, same S, same C, same snapshot:

| Run | Late definition |
| --- | --- |
| **Run D** (authoritative) | DATE rule |
| **Run T** (twin) | Timestamp strictly-greater |

Compare provisional **actions after capacity selection**. Any seller with \(A_D \neq A_T\) → N5-disagreer → final **INCONCLUSIVE**.

**Removal / refill (deterministic):** Complete D and T independently (N4 inside each) → force disagreers INCONCLUSIVE → **do not** re-loop T → refill once under **Run D only** from remaining date-rule YES (not N4, not N5-disagreer) → select `min(S, Q')`. Disagreers stay INCONCLUSIVE even if they would have been refilled.

### 7.7 Action taxonomy (AM #7)

| Action | Meaning | Enrolling? |
| --- | --- | --- |
| `ENROLL_RECOMMENDED` | YES and selected within S | Yes (recommendation only) |
| `WATCH` | YES but over-cap / not selected | **No** — standard terms |
| `STANDARD_NOT_QUALIFIED` | Membership NO (includes tiny-volume) | No |
| `INCONCLUSIVE` | N4 and/or N5 | **No** — standard terms |

Only `ENROLL_RECOMMENDED` is the enrollment recommendation. Live-DB critical failure = **run halt**, not a per-seller action.

**Primary reason precedence (adapt):** no eligible volume → below volume floor → coverage failure → insufficient comparator → materiality failure → repetition failure → handoff evaluability failure → handoff support failure → multi-seller inconclusive (N4) → clock-action inconclusive (N5) → qualified. Capacity reasons separate.

---

## 8. SQL A / SQL B / R(B) / recon contracts

### 8.1 Independence rules (hard)

1. **SQL A must not see SQL B** (or B intermediates / B judgments).  
2. **R(B) must not see SQL A** (or A intermediates, A baselines/lists, V1 decisions, or recon feedback before first R(B) freeze).  
3. **SQL B must not be A with columns dropped** — B is an independently produced raw three-relation package with no eligibility/late/membership/rank/action.  
4. Freeze A and R(B) with hashes **before** recon reads both. On critical mismatch: **neither list ships**; diagnose at source-record level; never edit counts or copy judgments to force agreement; rebuild affected branches independently.

**Frozen snapshot consistency:** SQL A and R(B) must use the **same** frozen snapshot identity (recorded in both manifests). Extraction-timing mismatches = recon failures.

### 8.2 SQL A — judged seller table contract

**Inputs:** frozen source tables + locked spec/config. **Forbidden:** B-derived judgments, R(B) outputs.

**Grain:** exactly one row per seller in validated seller universe (no prefilter to qualifiers).

**Required field groups:**

| Group | Contents |
| --- | --- |
| Identity | seller_id, specification_id, window bounds, snapshot_id |
| Population | candidate_delivered_n, eligible_n, excluded_n, exclusion-reason counts, coverage num/den |
| Primary outcome | late_n, eligible_n, exact LFR pair, display LFR, on-time_n |
| Twin / N5 | late_n_timestamp, timestamp rate pair, date/timestamp disagreement_n; membership_D/T; action_D/T provisional; selected_D/T provisional; n5_action_disagree_flag; n5_refill_selected_flag; final action/selected |
| Multi-seller / N4 | multi_seller_association_n, single_seller_association_n; late_n_ms/ss, eligible_n_ms/ss; n4_fire_D/T, n4_branch; majority flags; too_thin_ss_flag; ss comparator components / usability |
| Repetition | eligible_n and late_n for Half 1 and Half 2 |
| Reference | comparator seller count; late/eligible totals overall and by half; \(p_{-s}\) components; usability pass/fail |
| Fit | single_seller_late_n, handoff_evaluable_late_n, handoff_support_n |
| Decision | each gate pass/fail, membership yes/no/inconclusive, reason codes, primary reason |
| Capacity | excess-burden score, **rank** (or null), C, O, R, S, **simulation_S_equals_C_flag**, **selected**, **action** |
| Release / audit | operational_release_hold_flag/reason; run validity; source-quality flags |

Companion descriptive tables (Wilson, severity, ship-limit summaries) **must not** alter the core decision contract.

### 8.3 SQL B — lower-grain raw package (AM #8 LOCK A package)

Independently produced extraction with **three** required relations:

- **B_orders:** raw projection of all order records in the frozen snapshot — identity, status, purchase, actual-delivery, estimated-delivery, carrier-handoff fields as present.  
- **B_items:** raw projection of all item records — order/item/seller keys, shipping_limit_date.  
- **B_sellers:** raw projection of all seller records — seller identity + approved attributes (min: `seller_id` + source-version audit).

Full snapshot of required columns (not only in-window delivered). Preserve duplicates and invalids.

**Must not** supply: seller aggregates, eligibility flags, late flags, comparator totals, membership, ranks, or actions.

**Manifest:** source/snapshot identity, extraction timestamp, schema/type mappings, row counts, column order, encoding, delimiter/quoting, null encoding ≠ empty text, temporal precision, timezone convention, file hashes. No silent truncation.

**REJECT** pre-built seller-order dump with late_date/late_ts flags as the controlling SQL B contract.

### 8.4 R(B) — reconstruction contract

**Permitted:** B required relations + manifest + frozen spec/config (+ optional raw dims for optional diagnostics only).  
**Forbidden:** A, A intermediates, A baselines/lists, V1 decisions, recon feedback before first R(B) freeze.

R(B) independently: validate keys/types/integrity; reconstruct seller–orders and full seller universe; apply window/status/date-quality/chronology; compute DATE and timestamp outcomes; rebuild candidates/exclusions/half counts/handoff; rebuild reference and LOO comparators (all-order and ss); evaluate gates with exact comparisons; apply N4 and N5; rank remaining qualifiers; apply S; emit **same judged schema as A** + audits.

Canonical LFR = integer numerator/denominator with explicit null for zero denom. Exact integer/rational arithmetic for thresholds and ranking (3 pp via scaled cross-products; same for 95%/90%/50% boundaries).

### 8.5 Exact reconciliation contract (AM #9)

**Must match exactly between A and R(B):**

- Seller key sets, specification, snapshot, configuration, window  
- Integer `late_n`, `eligible_n` (and single-/multi-seller pairs used in gates)  
- Canonical LFR num/den including null behavior  
- Gate inputs, comparator totals, half counts, handoff counts  
- N4/N5 evidence fields (§7.5–7.6 / Stage 3 §17.5)  
- **Membership**, **rank**, **selected**, **action**  
- Deterministic tie handling and S application (including simulation flag)  
- Additive exclusions and source-audit totals  

Float display LFR is **not** authority.

**Invariants:** nonnegative counts; late_n ≤ eligible_n; candidate = eligible + excluded; half counts partition the window (non-overlapping); handoff_support ≤ handoff_evaluable ≤ single_seller_late ≤ total late; selected count = min(S, Q_final); no nonqualifier selected; no padding; WATCH/INCONCLUSIVE never selected.

**Mismatch protocol:** critical fail; neither list ships; retain both outputs; diagnose at source-record level; recon critical mismatch = recon halt (also automatic operational-release hold trigger).

---

## 9. Missingness / DQ and operational-release hold (summary)

**Run-blocking:** unresolved duplicate business keys; missing required mappings; broken snapshot consistency; ambiguous parsing that could alter eligibility/linkage. Do not silently dedupe collisions. No winsorizing valid long delays; no imputing missing dates.

**Operational-release hold** (separate from membership): holds live enrollment release of `ENROLL_RECOMMENDED` roster; does **not** alter calculated membership/rank/selected/action. Triggers include unsuitable handoff fields, unbounded orphans, marketplace-wide carrier incident making handoff uninterpretable, or recon critical mismatch. Owner: Mark documents; ops owns release-to-enrollment. New spec version required only if resolution changes gates/thresholds/window/N4/N5/C/action taxonomy.

---

## 10. Stage 4 must not

- Write design choices into SQL as if inventing policy  
- Invent `seller_plan_enrollment` or featured fields  
- Pad to 20; enroll on severity alone; claim causality  
- Ship either branch on recon mismatch  
- Have A read B; have R read A; treat B as A-with-columns-dropped  
- Treat WATCH/INCONCLUSIVE as enrollment  
- Silently replace N4/N5 with analyst discretion  
- Use simulation S=C outputs as authoritative live enrollment packets without the simulation label

---

## 11. Provisional parameter register (controlling)

| Parameter | Value | Kind |
| --- | --- | --- |
| Purchase window | 2018-01-01 incl → 2018-09-01 excl | LOCK |
| Halves | Jan–Apr / May–Aug non-overlapping | LOCK |
| Volume floor | eligible_n < 30 → standard; ≥30 to qualify | PA / AM |
| Coverage | ≥95%; 0 candidate → fail | PA |
| Elevation | ≥5 late; ≥3 pp vs LOO | PA |
| Half floors | ≥10 eligible; ≥2 late; LFR ≥ half comparator | PA |
| Handoff | ≥3 support; ≥50% of all eligible late; ≥90% ss late evaluable; 0 ss late fails | PA |
| Comparator full | ≥20 other sellers & ≥1,000 eligible | PA |
| Comparator half | ≥200 eligible each half | PA |
| N4 ss thin / majority | ss < 30; ms/eligible > 0.5 or late_ms/late > 0.5 | PA |
| Capacity C | 20 | AM |
| Simulation S | **S = C = 20** (full-capacity simulation label required) | This kickoff |
| WATCH / INCONCLUSIVE | Non-enrolling | AM |

---

## 12. Source references

- Locked design: `docs/stage-03-measurement-design/Stage_03_Measurement_Design.md`  
- DB context (VF): `FulfillIQ_Database_Context_V1_READONLY.md`  
- Data profile (VF): `FulfillIQ_Data_Profile_V1_READONLY.md`  
- Open ops questions: `PHASE4_OPEN_QUESTIONS.md` (authoritative live S)  
- R style for R(B): `docs/orchestration/frameworks/ENGINE.md`

---

*End of Stage 4 Shared Packet. Condensed from locked Stage 3 v0.2.1. No executable SQL/R. Simulation S=C=20 for dry-run only.*
