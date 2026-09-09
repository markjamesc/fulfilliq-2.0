# FulfillIQ 2.0 — Stage 3 Phase 6/7 — Candidate Measurement Design (Revised)

**Document:** `CANDIDATE_MEASUREMENT_DESIGN.md`  
**Status:** Phase 7 AI3 clarifications after AI3 Phase 7 audit (PASS with clarifications); consolidates Phase 4 coordinator resolutions + Design A text where compatible  
**Date:** 2026-09-08 (America/Chicago)  
**Spec version:** `fulfilliq-2.0-stage3-candidate-v0.2.1`  
**Prior version:** `fulfilliq-2.0-stage3-candidate-v0.2` (Phase 7 AI1 revise)  
**Changelog:** `CHANGELOG_PHASE7_AI3_CLARIFY.md` (also `CHANGELOG_PHASE7_AI1_REVISE.md` for v0.1→v0.2)  
**Origin legend (every material field):**  
- **SR** = stakeholder requirement / locked Start–Framing  
- **AM** = accepted methodological choice (Phase 4 lock)  
- **PA** = provisional assumption (numeric cutoff; not an SLA)  
- **VF** = verified data fact (V1 read-only context)  
- **UL** = unresolved limitation (disclosed)  
- **PENDING-DB** = schema / live-DB claim awaiting Stage 4 verification (not established by business scope alone)

**Rules:** No executable SQL or R. No new thresholds beyond Designs A/B integers. Every numeric cutoff marked **provisional**. Non-RCT; no causal claims. **Approved decision and locked analytical question are not rewritten.**

---

## 1. Document purpose and version

This candidate consolidates Design A (primary spine), Design B (selected amendments), cross-reviews, and the Data Risk Dossier into one controlling measurement specification for Stage 4 contract drafting. It does **not** claim empirical validation or human lock approval (Gate 11). Framework structure: three-ai-measurement-design-framework.md §31.

**Phase 4 provenance (inspectable):** Controlling locks live in `DESIGN_RECONCILIATION_MATRIX.md` (Phase 4). Stakeholder-only leftovers live in `PHASE4_OPEN_QUESTIONS.md`. Independent designs: `Design_A_ChatGPT.md`, `Design_B_Grok.md`. Dossier: `Data_Risk_Dossier_DeepSeek.md`. Shared packet: `00_SHARED_DESIGN_PACKET.md`. Volume-skew VF context: `FulfillIQ_Data_Profile_V1_READONLY.md`.

---

## 2. Approved decision statement (verbatim — SR)

Maya Chen must decide which marketplace sellers if any to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms to reduce late customer deliveries under hard concurrent capacity about 20 (no padding; enroll fewer if fewer meet bar) by mid-month VP ops meeting; tiny-volume stay standard; featured placement out; ops enrollment not RCT; numeric cutoffs designed in Stage 3 only to serve enrollment.

**Provenance:** `00_SHARED_DESIGN_PACKET.md` §1; matrix “Hypothesis” / “Actions / cap” rows; do not rewrite.

---

## 3. Locked analytical question (verbatim — SR)

Under locked concurrent capacity about 20 with tiny-volume on standard terms which sellers if any have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer ops check-ins and seller corrective path rather than ordinary marketplace monitoring?

**Membership intent (SR):** yes/no eligibility first; if more than ~20 qualify, rank within cap; if fewer, enroll fewer; do not pad; tiny-volume never qualify.

**Provenance:** `00_SHARED_DESIGN_PACKET.md` §2; `DESIGN_RECONCILIATION_MATRIX.md` Hypothesis resolution (**LOCK** A-style pattern-warrant hierarchy).

---

## 4. Stakeholder constraints and exceptions (SR)

| Constraint | Handling in this candidate |
| --- | --- |
| Cap ~20 concurrent; no padding | Integer **C = 20** (AM); available slots **S** after occupancy (§17.3); select `min(S, Q)`; no fill-to-cap |
| Tiny-volume → standard | Post-exclusion `eligible_n < 30` → cannot qualify (AM; PA floor) |
| Featured placement / catalog out | **Out of business scope (SR).** Schema claim “not in DB” is **PENDING-DB**: Stage 4 must verify absence of featured/catalog fields in the live `fulfilliq` schema (`FulfillIQ_Database_Context_V1_READONLY.md` / live DESCRIBE). Do **not** invent featured columns. Packet hard constraint: `00_SHARED_DESIGN_PACKET.md` §3 (“Featured placement / catalog not in DB and out of scope”) — business exclusion stands regardless of PENDING-DB outcome. |
| Not RCT; not permanent offboarding | Recommendation table only; disclose non-RCT (AM #10) |
| Plan ~30 days | Business intervention definition, not a DB field (SR) |
| Numeric cutoffs serve enrollment | All cutoffs labeled **provisional** (PA) |

**Phase 4 lock excerpt (Actions / cap — matrix):** “**LOCK** membership-first, then rank only qualifiers; **C = 20** integer operationalization of “about 20”; **no padding**; enroll fewer if fewer meet bar.”

---

## 5. Intended conclusion type and ceiling (AM)

| Allowed | Forbidden |
| --- | --- |
| Associational / descriptive: seller cleared provisional pattern-warrant gates under this spec | Causal: “enrollment will reduce late deliveries,” treatment effects, RCT contrast |
| Prospective **recommendation** action codes for ops capacity allocation | Claiming the list is proof of fault or that the plan “fits” causally |
| Disclosure that YES = cleared these gates (proxy for “warrant”) | Interpreting WATCH as a second enrollment track |

**Ceiling:** descriptive ranking and membership under hard capacity. **Disclose non-RCT.** Output is a prospective enrollment recommendation table—not a historical enrolled-vs-standard comparison. External `seller_plan_enrollment` is **not** required for Stage 4 of this design (AM #10 Reject dossier blocker; matrix Enrollment-flag row).

---

## 6. Hypothesis hierarchy (AM — A spine)

**Decision hypothesis:** Some sellers may exhibit sufficiently material, repeated late customer deliveries, with an observable fulfillment-process signal, to warrant the documented improvement plan.

**Competing explanation:** Sparse volume, temporary episode, mix, promises, carrier ops, multi-seller shared outcomes, or measurement defects.

**Measurement hypotheses (aligned to actual gates — Phase 7 revise):**

- **H1 Materiality (PA):** ≥5 late seller–orders and full-window LFR at least **3 percentage points** above the seller-excluded leave-one-out comparator among assessable sellers.
- **H2 Persistence / parity-or-above in both halves (PA):** Customer-lateness elevation **or parity** versus the half comparator appears in **both** non-overlapping halves under the half floors (≥10 eligible, ≥2 late each half) and the half gate “LFR **≥** that half’s comparator (equality passes).” This is **parity-or-above persistence across halves**, **not** a claim of strict elevation above the comparator in each half. Aggregate half counts **do not** rule out a single pooled episode that straddles the April–May boundary; the gate only requires both halves to meet the stated floors and LFR≥comparator tests. Stronger anti-straddle persistence would need a new approved test (not invented here).
- **H3 Operational fit (PA):** Customer-lateness **repetition** (H2) applies to **customer lateness halves only**. Separately, a late carrier-handoff signal must meet the **full-window** membership handoff tests on single-seller-attributable late orders (§11.2). Handoff support is a **full-window membership test**, **not** a half-repeated requirement: all supporting handoff events may fall in one half and still pass H3 as specified. Ship-limit / carrier **summaries** are diagnostic-only (§11.3) and are **distinct** from the membership handoff path (§11.2).
- **H4 Intervention effectiveness:** Out of scope; cannot be established from this observational extract; **not** an enrollment prerequisite.

H1–H3 support provisional analytical membership. Failure of H1–H3 = insufficient support under this rule, **not** proof of acceptable performance. **REJECT** B band-P75 + market LFR + Wilson LB as sole membership (wrong question; matrix Hypothesis **REJECT**).

**Phase 4 lock excerpt (Hypothesis — matrix):** “**LOCK** A-style pattern-warrant hierarchy (elevation + repetition + fit). **REJECT** B N3 … as sole membership.”

---

## 7. Population and eligibility contract (AM + A text)

### 7.1 Reporting universe (AM — keep A)

Every distinct valid `seller_id` in `raw_sellers` in the frozen snapshot, **including** sellers with zero eligible observations. Tiny-volume and non-qualifiers remain in the judged table with reason codes.

**B_sellers minimum fields (AI3 clarification):** `B_sellers` must include at minimum `seller_id` (valid, non-null, unique key) and source-version audit fields. Additional approved attributes are optional for diagnostic context only. Stage 4 implementation must verify `seller_id` presence and uniqueness before proceeding.

### 7.2 Candidate seller–orders

Distinct seller–order associations from `raw_order_items` linked to an existing order and existing seller. Candidate delivered volume = those associations with delivered status and purchase timestamp inside the locked window, **before** delivery-date quality exclusions.

### 7.3 Eligible seller–order (primary denominator unit)

All of:

1. Valid association with existing seller and unique order record.  
2. Delivered status.  
3. Valid in-window purchase timestamp.  
4. Nonmissing, parseable actual customer-delivery and estimated-delivery values.  
5. Chronology OK: actual delivery and estimated delivery not earlier than purchase (full timestamp chronology after temporal semantics verified).  
6. ≥1 item row contributing the association.

**Chronology comparison precision (AI3 clarification):** Chronology validation compares full timestamp values (not date-truncated) when both fields are timestamps. If one field is date-only and the other timestamp, the source's recorded precision governs; convert both to comparable types per source documentation. All three fields (purchase, actual, estimated) must be parseable to the same temporal precision for equality boundary evaluation.

Nondelivered orders do **not** enter the primary denominator. Missing outcomes are **never** treated as on-time. Orphans / invalid keys audited separately (UL if unbounded).

### 7.4 Volume gate (AM #2)

After **all** eligibility exclusions: `eligible_n < 30` → standard terms / cannot analytically qualify. Floor **≥ 30 provisional (PA)**. Recompute seller counts inside the frozen window; do not cite full-extract “627 at 30” as the decision population (VF context only).

**Volume-skew VF provenance:** `FulfillIQ_Data_Profile_V1_READONLY.md` executive highlights / §6 — “median seller volume is only **6 delivered orders**; … **79.74%** have fewer than 30” (also restated ~80% in `00_SHARED_DESIGN_PACKET.md` §5). This is full-extract profile context, **not** the locked-window headcount.

**Phase 4 lock excerpt (Sample-size — matrix):** “**LOCK** B post-exclusion rule: after all Section eligibility exclusions, `eligible_n < 30` → standard / cannot qualify; floor **≥30 provisional**.”

---

## 8. Time-window and date contract (AM #1)

| Parameter | Locked value | Status |
| --- | --- | --- |
| Primary purchase window | `order_purchase_timestamp >= '2018-01-01 00:00:00'` AND `< '2018-09-01 00:00:00'` | **LOCK** Design B (8 months) |
| Repetition Half 1 | `>= '2018-01-01 00:00:00'` AND `< '2018-05-01 00:00:00'` (Jan–Apr) | **LOCK** non-overlapping |
| Repetition Half 2 | `>= '2018-05-01 00:00:00'` AND `< '2018-09-01 00:00:00'` (May–Aug) | **LOCK** non-overlapping |
| Cohort clock | Purchase time | AM |
| Post-window delivery | Still counts if purchase in window and outcome present in frozen snapshot | AM (historical retrospective) |
| Timezone | Source recorded convention; no speculative conversion | A text; verify in Stage 4 |

**REJECT** Design A’s six-month end `2018-07-01` and overlapping April blocks (Jan–Apr / Apr–Jul).

**Phase 4 lock excerpt (Population / window + Repetition blocks — matrix):** “**LOCK** Design B window: … `< 2018-09-01` … **LOCK** non-overlapping repetition halves … Half 1 Jan–Apr; Half 2 May–Aug.”

This candidate is a **retrospective, final-observed-status** analysis on a frozen snapshot—not a reconstruction of what was knowable on a live decision day. Record extract time, source version, and outcome-observation boundary. Operational reuse with live lookahead controls is **out of this historical-scoring spec** unless a new version is locked (UL / L001 disclosure).

---

## 9. Grain and join-cardinality contract (AM)

| Grain | Definition |
| --- | --- |
| Raw item | `(order_id, order_item_id)` — verify uniqueness; do not silently dedupe business-key collisions |
| Measurement | `(seller_id, order_id)` — multi-item same seller once; multi-seller order → one association **each**, **shared** order-level delivery outcome |
| Decision | One seller × one window × one spec version |

**Join path (non-executable):** validate identities → distinct seller–order from items → attach one order → eligibility/outcomes → aggregate to seller and half → attach to full seller universe.

**Forbidden in primary path:** payments, reviews, products, raw geolocation (R002). Optional diagnostics must use unique lookups and leave core counts unchanged.

**Cardinality rules:** collapse items before counting seller–orders; seller totals ≠ unique customer-order totals—report both. Carry **`multi_seller_order_flag`** on evidence and judged aggregates as required (AM #11; dossier SQL-A Conditional-Pass).

---

## 10. Primary KPI contract (AM #3)

**Name:** Seller Late-Fulfillment Rate (LFR)

For seller \(s\):

- \(n_s = \texttt{eligible_n}\): distinct eligible seller–orders (post-exclusion).  
- \(k_s = \texttt{late_n}\): eligible seller–orders with  
  `DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)`.  
- \(\mathrm{LFR}_s = k_s / n_s\) when \(n_s > 0\); **null** when \(n_s = 0\) (never display as 0% to mean “no volume”).

**Rules:** Same-day on time; **no grace period**; exact integer counts and unrounded comparisons; displayed percentages are not decision inputs.

**Mandatory timestamp twin + N5 action override:** On the same eligible population, late iff actual timestamp **strictly greater than** estimated timestamp. Retain twin fields. Full deterministic N5 procedure is in **§17.5** (exception to diagnostic-only sensitivity rule). Brief rule: if date-rule vs timestamp-rule pipelines would **change the derived action** (including capacity selection outcomes as specified in §17.5), set action = **INCONCLUSIVE**.

**Always print** the fraction `late_n/eligible_n` alongside any display rate.

**Phase 4 lock excerpt (KPI / lateness — matrix):** “**LOCK** calendar-date DATE rule as primary … Timestamp twin **mandatory**. If date-rule vs timestamp-rule would **change the derived action**, mark **INCONCLUSIVE** (adopt B N5).”

---

## 11. Guardrail, diagnostic, audit, and sensitivity metrics

### 11.1 Membership guardrails (PA unless noted)

| Metric | Rule | Status |
| --- | --- | --- |
| Measurement coverage | `eligible / candidate_delivered ≥ 95%`; zero candidate → fail | **KEEP** A provisional (AM #5) |
| Min late volume | `late_n ≥ 5` | PA (AM #4; not B’s ≥4) |
| Full-window elevation | LFR at least **3 pp** above leave-one-out comparator \(p_{-s}\) | PA |
| Half floors (customer lateness) | Each half: ≥10 eligible, ≥2 late; LFR **≥** that half’s comparator (**equality passes**) | PA; parity-or-above, not strict elevation |
| Handoff fit (full-window) | ≥3 supporting; supporting ≥50% of all eligible late; ≥90% of single-seller late evaluable; zero single-seller late fails | PA types (AM #6); definitions §11.2; **not** half-repeated |
| Multi-seller attribution | Fully specified N4 (§17.4) | AM #4; Design B N4 integers |
| Timestamp action override | Fully specified N5 (§17.5) | AM #3; Design B N5 |


**Coverage denominator clarification (AI3):** Coverage denominator `candidate_delivered_n` uses the §7.2 definition **before** the §7.3 delivery-date-quality exclusions. `eligible_n` uses the §7.3 definition. Thus coverage measures data-quality fallout from invalid/missing delivery dates, not volume filtering.

### 11.2 Handoff / operational-fit definitions (from Design A §8 — PA; not causation)

**Membership handoff path (gates enrollment fit — full-window only):**

- `single_seller_late_n`: eligible late seller–orders whose order has exactly one distinct valid seller and no unresolved seller association.  
- `handoff_evaluable_late_n`: those with valid carrier-handoff timestamp and valid shipping deadlines for every item; carrier between purchase and actual delivery; each deadline not before purchase.  
- `handoff_support_n`: evaluable orders where carrier receipt is **strictly later than** the **latest** item `shipping_limit_date` on that order.  
- Supporting share uses **all eligible late** as denominator for the 50% test; evaluability uses **single-seller late** as denominator for the 90% test (A).  

**Repetition vs handoff:** Half-repeated persistence (H2 / §17.1 step 5) applies only to **customer lateness** halves. Handoff support / evaluability thresholds are evaluated on the **full window**; there is **no** requirement that supporting handoff events appear in both halves.

**Disclose:** signal supports a handoff-focused corrective investigation; **does not prove** seller responsibility (AM #6). If required fields unavailable/unsuitable at Stage 4 verification → **block fit path**; do not invent substitutes or silently qualify from rates alone (A §3). Blocking the fit path is a Stage 4 readiness / operational-release matter (§14.1), not silent demotion inside membership SQL.

### 11.3 Diagnostics only (cannot enroll — AM #12 Reject)

These are **not** membership gates and must not be confused with §11.2:

- Median calendar days late among late orders.  
- Count with **>7 calendar days** late (PA band).  
- **Ship-limit / carrier miss summaries** (B stance: cannot enroll) — narrative / diagnostic aggregates distinct from the membership handoff counts in §11.2.  
- Wilson **95%** interval for each nonzero-denominator LFR — **descriptive only**; **not** an enrollment gate (A).

### 11.4 Prespecified sensitivities (PA stress tests)

Volume floor 20 and 50 vs 30; elevation 2 pp and 5 pp vs 3; single-seller-only outcome/reference (related to but not replacing N4); coverage 90% and 99% vs 95%; handoff-support share 1/3 and 2/3 vs 1/2 (A §17).

**Rule:** Ordinary sensitivities **do not override primary action** and are reporting-only.

**Exception (N5):** The mandatory date-vs-timestamp **action** comparison in §17.5 **does** override primary action to `INCONCLUSIVE` when the derived action disagrees. N5 is the sole prespecified sensitivity with action-override authority. Timestamp-vs-date rate disagreements that do **not** change action remain diagnostic twin fields only.

---

## 12. Comparison and baseline contract (AM — A spine)

**Assessable reference set:** sellers with `eligible_n ≥ 30` (PA) **and** passing coverage guardrail. Do not require high lateness, repetition, or handoff to enter the reference.

**Leave-one-out comparator** for seller \(s\):

\[
p_{-s}=\frac{\sum_{j\in \mathrm{reference},\,j\ne s}k_j}{\sum_{j\in \mathrm{reference},\,j\ne s}n_j}.
\]

**Comparator usability cutoffs (PA — controlling; also in parameter register):**

| Scope | Cutoff (PA) |
| --- | --- |
| Full-window | ≥20 other comparator sellers **and** ≥1,000 comparator eligible seller–orders |
| Each half | ≥200 comparator eligible seller–orders in **each** half |

**Half comparator seller-count clarification (AI3):** The ≥20 other-comparator-seller count applies **only** to full-window usability and does **not** extend to half comparators. Half usability is governed by the ≥200 comparator eligible seller–orders per half requirement (and, for N4 ss halves, the ss-scoped ≥200 per half — see §17.4). No additional other-seller count is invented for halves.

If usability fails for the seller’s required comparator(s), materiality/persistence gates that depend on that comparator **fail** (insufficient comparator)—seller cannot reach membership YES.

Context metrics (not interchangeable baselines): marketplace seller–order LFR, unique-order LFR, unweighted median seller LFR in reference, volume concentration. **No V1** rate/percentile/enrollment list as anchor.

**REJECT** B volume-band P75 + `LFR_mkt_weighted` + Wilson 80% LB as the **qualify** rule (may appear only as descriptive peer context if desired—**not** membership).

---

## 13. Segment contract (A text; exploratory)

Required interpretive segments (do not change primary num/den): eligible-volume bands 0 / 1–9 / 10–29 / 30–99 / ≥100 (**PA** reporting bands); purchase month and the two halves; single-seller vs multi-seller; coverage pass/fail; handoff evidence available/unavailable.

Optional verified dimensions: seller state, customer state, within- vs cross-state, product category (nonadditive category view). Sparse cells: retain counts; **30 observations provisional** for displayed segment-rate comparisons. Segments are not extra eligibility thresholds without a spec revision.

---

## 14. Confounder and competing-explanation ledger

| Threat | Implication | Control in design |
| --- | --- | --- |
| Multi-seller shared outcome (R001/L002) | Contaminates all-order LFR and LOO comparator | `multi_seller_order_flag`; single- vs multi KPIs; N4 → INCONCLUSIVE (§17.4) |
| Volume skew / rate instability (R005) | Thin n near floor | Floor ≥30 PA; ≥5 late; both-half persistence; disclose Wilson descriptive; VF path §7.4 |
| Delivered-only survivorship | Non-delivery hidden | Disclose construct: late among completed deliveries |
| Promise tightness / SLA mix | Inflates LFR without process failure | Severity/ship-limit **diagnostic** only; no severity enroll |
| Carrier / pickup / logging | Handoff proxy imperfect | Fit not causation; field-verification gate; operational-release hold (§14.1) |
| Marketplace-wide shocks | Common elevation | Purchase-month / half diagnostics |
| Geolocation zip explosion (R002) | Row multiplication | Keep geo out of primary path |
| Selection / non-RCT (R004/L003) | Causal misread of list | Conclusion ceiling; no plan-flag comparison in Stage 3 |
| Lookahead (L001) | Post-decision deliveries | Historical snapshot scoring only; disclose |

No regression adjustment controls membership. Analyst discretion **must not** replace the deterministic membership rule.

### 14.1 Operational-release hold (separate from membership — Phase 7)

Calculated membership, rank, selected, and action codes remain the deterministic analytical outputs. When handoff / data-quality diagnostics **materially undermine handoff interpretation** for operational use, apply an **operational-release hold**—not an analyst rewrite of gates.

| Element | Contract |
| --- | --- |
| **Trigger evidence (any one)** | (a) Stage 4 verification finds carrier-handoff / `shipping_limit_date` fields unavailable or semantically unsuitable for the §11.2 path; (b) audit shows unbounded orphans/key failures whose effect on membership/capacity cannot be bounded (§15); (c) documented marketplace-wide carrier or network incident in the locked window such that handoff_support counts are not interpretable as seller-corrective-path evidence; (d) A vs R(B) recon critical mismatch occurs; in this state, release is prohibited by recon contract (§23) and the hold is automatic until resolved. This is a **recon halt**, not a separate hold trigger. |
| **Owner** | **Mark** (human analyst) documents the trigger and places the hold; **ops** (Maya’s ops path / Mark coordinating with ops) owns release-to-enrollment decision. Stakeholder return only if business scope changes. |
| **Scope** | Holds **operational release** of the ENROLL_RECOMMENDED roster into live plan enrollment. Does **not** alter calculated membership codes, ranks, or the judged table’s analytical actions. WATCH / INCONCLUSIVE / STANDARD_NOT_QUALIFIED remain as calculated. |
| **Preserved artifacts** | Full judged tables, audits, gate failures, N4/N5 counterfactual fields, and recon packet remain frozen and citable. |
| **Clearing the hold** | Owner documents resolution (fields verified; bounds restored; incident disclosed as context without changing gates; or recon repaired via independent rebuild). Clearing does **not** by itself change membership. |
| **New spec version required when** | Resolution would change gate definitions, thresholds, window/halves, handoff demotion from membership to diagnostic-only, N4/N5 semantics, C, or action taxonomy. Evidence-clearance alone → no new version. |

---

## 15. Missingness, anomaly, and data-quality rules (A §13)

**Run-blocking:** unresolved duplicate order/item/seller business keys; missing required mappings; broken snapshot consistency; ambiguous parsing that could alter eligibility/linkage. Do not silently dedupe collisions.

**Row-level primary exclusions (additive reason order):** missing actual or estimated delivery; invalid required dates; actual before purchase; estimated before purchase.

**Diagnostic-only / fit-path:** missing/invalid carrier handoff or shipping deadlines → remove handoff evaluability only (does not remove the seller–order from LFR eligibility).

**Audit outside cohort:** invalid purchase timestamps; missing keys; orphans. Block **operational release** (§14.1) if effect on counts/membership/capacity cannot be bounded.

No winsorizing valid long delays; no imputing missing dates. Preserve raw, parsed, and reason codes.

---

## 16. Sample-size and uncertainty rules (AM #2)

| Rule | Value | Status |
| --- | --- | --- |
| Tiny-volume / floor | After exclusions, `eligible_n < 30` → standard; qualify needs ≥30 | AM / PA |
| Min late | ≥5 | PA |
| Wilson 95% | Descriptive; not enrollment gate | A |
| Coverage | ≥95% membership gate | PA (AM #5) |
| Comparator usability | ≥20 other sellers & ≥1,000 eligible orders full-window; ≥200/half (≥20 seller-count is full-window only) | PA (controlling) |

Contextual VF (not window headcount): median ~6 delivered; ~80% sellers below 30 — cite `FulfillIQ_Data_Profile_V1_READONLY.md` (79.74% < 30). **Recompute after exclusions** in the locked window.

---

## 17. Decision rules and capacity constraints (AM #4–7)

### 17.1 Analytical membership YES only if all pass (all numbers PA)

Evaluate on the **all-order** (primary) association set unless a step says otherwise:

1. `eligible_n ≥ 30` (post-exclusion).  
2. Coverage ≥ 95% (zero candidate → fail).  
3. Usable full-window and half comparators (§12).  
4. `late_n ≥ 5` **and** full-window LFR **at least 3 pp** above \(p_{-s}\) (exact rational / scaled integer cross-product; equality on the “at least 3 pp” boundary passes).  
5. **Each** half (customer lateness only): ≥10 eligible, ≥2 late, LFR **≥** that half’s comparator (equality passes). Thin half **fails** persistence (no B N6 “leave in qualify pool”). This does **not** claim a single boundary-straddling episode is impossible.  
6. Handoff requirements §11.2 (**full-window**; not half-repeated).  
7. Not tripped into INCONCLUSIVE by multi-seller N4 (§17.4) or date/timestamp action disagreement N5 (§17.5).

Otherwise membership **NO** (or **INCONCLUSIVE** when N4/N5 fire). Retain every failed gate. Distinguish “insufficient evidence” from “pattern does not meet bar.” Globally invalid run → no publishable membership table.

**No** severity-only override; **no** automatic top-twenty; **no** minimum enrollment count; **no** capacity-driven threshold relaxation; **no** fill-to-cap (AM #12).

### 17.2 Ranking (qualifiers only)

Only sellers with membership **YES** after N4/N5 enter the qualifier set \(Q\).

1. Descending excess burden \(e_s = k_s - n_s p_{-s}\) (exact rational; date-rule primary counts).  
2. Descending `handoff_support_n`.  
3. Descending `late_n`.  
4. Descending `eligible_n`.  
5. Ascending `seller_id` (frozen bytewise collation).

### 17.3 Cap, occupancy, and available slots S

| Symbol | Definition |
| --- | --- |
| **C** | Hard concurrent capacity integer = **20** (AM operationalization of “about 20”) |
| **O** | Existing concurrent plan occupancy (ops fact; count of sellers already on an active improvement plan at the decision moment) |
| **R** | Ops-held reservations against C (if any; else 0) |
| **S** | **Available new-plan slots after occupancy:** \(S = \max(0,\, C - O - R)\), with \(0 \leq S \leq C\) |

**Authoritative S for operational release:** Ops (Mark coordinating with ops / Maya’s ops path) supplies authoritative **O**, **R**, and thus **S** before a decision-ready release for a live VP meeting (`PHASE4_OPEN_QUESTIONS.md` item 1). Measurement must not invent occupancy from Olist.

**Simulation / dry-run:** Default **S = C = 20** is permitted **only** when explicitly labeled **“full-capacity simulation (occupancy treated as 0; not authoritative for live enrollment)”**. Simulation outputs are not operational-release packets.

**Selection:** Select first `min(S, Q)` qualifiers by §17.2; **no padding**. If S = 0 (full occupancy), Q may be nonempty but **selected count = 0**; all YES members receive `WATCH`.

**Non-enrolling actions:** `WATCH` and `INCONCLUSIVE` are **never** enrolled under this spec; they remain on **standard terms** for ops enrollment purposes (WATCH = analytically qualified but not selected / no seat; INCONCLUSIVE = unresolved attribution or clock-action disagreement). Only `ENROLL_RECOMMENDED` is the enrollment recommendation.

### 17.4 N4 — multi-seller counterfactual (fully specified; AM #4 / Design B N4)

**Purpose:** Prevent enrollment when all-order qualification may be an artifact of shared multi-seller delivery clocks.

**Definitions (PA integers from A/B only):**

- **Single-seller association:** eligible seller–order whose order has exactly one distinct valid seller and no unresolved seller association.  
- **`eligible_n_ss`, `late_n_ss`:** counts restricted to single-seller associations (full window and by half).  
- **`eligible_n_ms`, `late_n_ms`:** multi-seller association counts.  
- **Too thin (single-seller):** `eligible_n_ss < 30` (same PA volume floor as §7.4).  
- **Majority (multi-seller):** `eligible_n_ms / eligible_n > 0.5` when `eligible_n > 0` (strict majority of eligible seller–orders), **or** `late_n_ms / late_n > 0.5` when `late_n > 0` (late-majority). **Late-majority branch triggering (AI3 clarification):** The late-majority branch (`late_n_ms / late_n > 0.5`) triggers **regardless** of whether the eligible-majority branch triggers. Both flags are computed and emitted. If **either** branch is true **AND** `eligible_n_ss < 30` **AND** all-order would otherwise pass, N4 fires.  
- **Single-seller reference population:** sellers in the assessable reference set (§12) using **single-seller** late/eligible totals for LOO numerators/denominators (same seller membership in reference: all-order `eligible_n ≥ 30` and coverage pass). Leave-one-out \(p_{-s}^{(ss)}\) uses other reference sellers’ ss totals.  
- **Single-seller half comparators:** analogous LOO on ss half totals. **N4 half comparator usability (AI3 clarification):** For the single-seller half comparators in N4, the usability threshold per half is ≥200 comparator eligible seller–orders from single-seller associations in that half, **not** the full-window ≥1,000 threshold. The full-window ≥1,000 threshold applies only to the all-order comparator usability (§12) and does not govern half comparator availability. Half usability in N4 follows the same half-specific logic as §12 but applied to ss associations. The ≥20 other-seller count remains a full-window usability rule only (§12); it does not gate N4 half comparators. Full-window ss comparator usability (when needed for ss materiality) still uses ≥20 other reference sellers with ss volume contributing and ≥1,000 ss comparator eligible orders full-window.

**Gates recomputed on single-seller-only associations (counterfactual “rate-clear”):**

Recompute **only** these membership components on ss associations (date-rule primary inside Run D; timestamp-rule inside Run T):

1. Volume: `eligible_n_ss ≥ 30` (PA).  
2. Materiality: `late_n_ss ≥ 5` **and** ss LFR **at least 3 pp** above \(p_{-s}^{(ss)}\).  
3. Persistence: **each** half — `eligible_n_ss_half ≥ 10`, `late_n_ss_half ≥ 2`, ss half LFR **≥** that half’s ss comparator (equality passes).  

**Not recomputed inside N4:** coverage (remains all-order measurement-completeness gate); handoff §11.2 (already single-seller-scoped membership path); ranking/capacity (applied only after N4/N5 on final YES set).

**N4 fire conditions (→ membership INCONCLUSIVE, non-enrolling):**

- **Flip branch:** All-order path would pass §17.1 steps 1–6 (pre-N4/N5 YES), **but** the ss counterfactual fails any recomputed gate above → **INCONCLUSIVE**.  
- **Thin + majority branch:** All-order path would pass steps 1–6, **and** single-seller is **too thin** (`eligible_n_ss < 30`), **and** multi-seller **majority** holds (eligible-majority **or** late-majority; either flag suffices — both always emitted) → **INCONCLUSIVE** (do not enroll on contaminated all-order alone).

**Boundary — ss comparator unusable:** If ss comparator usability fails while evaluating the ss counterfactual, treat the ss path as **not rate-clearing**. If all-order would otherwise YES → **N4 INCONCLUSIVE** (conservative; do not enroll).

**If all-order would already fail steps 1–6:** N4 does not upgrade the seller; primary reason remains the failed all-order gate (`STANDARD_NOT_QUALIFIED` or prior failure codes).

**Precedence:** Apply N4 **after** all-order steps 1–6 and **before** ranking/capacity. N4 is evaluated **inside** each of Run D and Run T (§17.5). N4 and N5 may both annotate a seller; final action is `INCONCLUSIVE` if either fires. Primary reason precedence: … → handoff failures → **multi-seller inconclusive (N4)** → **clock-action inconclusive (N5)** → qualified.

### 17.5 N5 — timestamp override (fully specified; AM #3 / Design B N5)

**Exception to §11.4:** N5 **overrides** primary action; other sensitivities do not.

**Two comparison runs (same eligible population, same S, same C, same frozen snapshot/spec):**

| Run | Late definition | Pipeline |
| --- | --- | --- |
| **Run D** (authoritative clock) | DATE rule (§10) | Gates §17.1 steps 1–6 → N4 §17.4 → provisional membership → rank → select `min(S,Q)` → provisional action \(A_D\) |
| **Run T** (twin) | Timestamp strictly-greater rule | Same steps on timestamp late flags → provisional membership → rank → select → provisional action \(A_T\) |

**Freeze point:** N5 compares provisional **actions after capacity selection** in both runs (not merely pre-capacity membership). Capacity-only changes **do** count: if seller \(s\) has \(A_D[s] \neq A_T[s]\) for any action code (`ENROLL_RECOMMENDED` / `WATCH` / `STANDARD_NOT_QUALIFIED` / `INCONCLUSIVE`), seller \(s\) is an **N5 disagreer**.

**Removal / refill order (deterministic; prevents oscillation):**

1. Complete Run D and Run T independently (including N4 inside each).  
2. Mark every seller with \(A_D \neq A_T\) as N5-disagreer → force final analytical disposition **INCONCLUSIVE** (non-enrolling).  
3. **Do not** iterate Run T again.  
4. **Refill under Run D only:** From date-rule sellers with provisional membership YES who are **not** N4-INCONCLUSIVE and **not** N5-disagreers, re-rank by §17.2 and select `min(S, Q')`.  
5. Final actions: selected → `ENROLL_RECOMMENDED`; other remaining YES → `WATCH`; N4/N5 → `INCONCLUSIVE`; others → `STANDARD_NOT_QUALIFIED`.  
6. N5-disagreers **stay INCONCLUSIVE** even if they would have been refilled; no second twin comparison after refill.

**Interaction with N4:** N4 applies inside each run before provisional actions. A seller N4-INCONCLUSIVE in both runs → final INCONCLUSIVE (N4). Disagreement where one run is N4-INCONCLUSIVE and the other is ENROLL/WATCH/STANDARD → N5 disagreer → final INCONCLUSIVE; emit both reason flags; primary reason = clock-action inconclusive if action codes differ, else multi-seller inconclusive.

**Required counterfactual / recon output fields (A and R(B) judged schema):**

| Field | Purpose |
| --- | --- |
| `late_n`, `late_n_timestamp`, `date_timestamp_disagree_n` | Twin numerators / disagreement count on eligible set |
| `membership_D`, `membership_T` | Provisional membership after N4 in each run |
| `action_D_provisional`, `action_T_provisional` | Provisional actions **including** capacity selection |
| `selected_D_provisional`, `selected_T_provisional` | Provisional selected flags |
| `n5_action_disagree_flag` | True iff provisional actions differ |
| `n4_fire_D`, `n4_fire_T`, `n4_branch` (`flip` / `thin_majority` / none) | N4 audit |
| `eligible_n_ss`, `late_n_ss`, `p_ss` components, ss half counts | N4 counterfactual evidence |
| `majority_eligible_ms_flag`, `majority_late_ms_flag`, `too_thin_ss_flag` | N4 thin/majority evidence |
| `ss_comparator_usable_flag` | Boundary handling |
| `action` (final), `selected` (final), `n5_refill_selected_flag` | Post-removal/refill authoritative results |

Exact match on final `membership` / `rank` / `selected` / `action` plus these N4/N5 evidence fields is required for recon (§23).

### 17.6 Action taxonomy (harmonized AM #7)

| Action | Meaning | Enrolling? |
| --- | --- | --- |
| `ENROLL_RECOMMENDED` | Membership YES and selected within S | Yes (recommendation only) |
| `WATCH` | Membership YES but over-cap / not selected (A’s STANDARD_CAPACITY) | **No** — standard terms operationally |
| `STANDARD_NOT_QUALIFIED` | Membership NO under evidence rule (includes tiny-volume) | No |
| `INCONCLUSIVE` | N4 and/or N5; **non-enrolling** | **No** — standard terms operationally |

These are analytical recommendations, **not** records that enrollment occurred. Rank, membership, selected, and action remain separate columns. Live-DB critical failure (B N0) = **run halt**, not a per-seller action.

---

## 18. Measurement-risk register (summary)

| ID | Risk | Design response |
| --- | --- | --- |
| R001/L002 | Multi-seller attribution | Flag + dual KPI + N4 INCONCLUSIVE (§17.4) |
| R002 | Geo join explosion | Out of primary path |
| R004/L003 | Selection / causal misread | Ceiling; no plan-flag comparison; disclose non-RCT |
| R005 | Volume skew | Floor, min late, both-half persistence; VF `FulfillIQ_Data_Profile_V1_READONLY.md` |
| L001 | Lookahead | Historical snapshot only; disclose |
| G001 | No enrollment flag | **Reject as Stage 4 blocker** for this prospective design |
| G003 | No item-level delivery timeline | Handoff on order/carrier/shipping_limit proxy; verify fields; block fit / operational-release hold if unsuitable |

---

## 19. Non-executable implementation blueprint (A §19 adapted)

1. Verify schema mappings, temporal conventions, keys, source version, coverage; resolve PENDING-DB featured-field check.  
2. Lock parameter register, authoritative **S** (or label full-capacity simulation), and specification ID.  
3. Freeze common source snapshot for both extraction paths.  
3a. **Frozen snapshot consistency (AI3 clarification):** SQL A and R(B) must use the same frozen snapshot extraction for their respective builds. The source snapshot identity must be recorded in both A and R(B) manifests. If source extraction is done separately, both must use identical time-locked views. Mismatches due to extraction timing are treated as recon failures.  
4. Implement **SQL A** independently → judged seller table + audits (**must not read B/R(B)**).  
5. Implement **SQL B** as raw **B_orders + B_items + B_sellers** package—no eligibility/late/membership/rank/action.  
6. Provide only B + frozen spec/config to R(B) builder.  
7. R(B) validates, reconstructs associations, applies window/exclusions/gates, N4/N5, ranks/selects, emits same judged schema.  
8. Freeze A and R(B) with hashes before recon reads both.  
9. Reconcile; on mismatch neither ships; fix responsible path/spec; rebuild independently.  
10. Release decision-ready packet only after recon + substantive review + no open operational-release hold (§14.1).

---

## 20. SQL A output contract — judged seller table (AM #8/#11)

**Inputs:** frozen source tables + locked spec/config. **Forbidden:** B-derived judgments, R(B) outputs.

**Grain:** exactly one row per seller in validated seller universe (no prefilter to qualifiers).

| Field group | Required contents |
| --- | --- |
| Identity | seller_id, specification_id, window bounds, snapshot_id |
| Population | candidate_delivered_n, eligible_n, excluded_n, exclusion-reason counts, coverage num/den |
| Primary outcome | late_n, eligible_n, exact LFR pair, display LFR, on-time_n |
| Twin / N5 | late_n_timestamp, timestamp rate pair, date/timestamp disagreement_n; all §17.5 required fields |
| Multi-seller / N4 | **multi_seller_order_flag** aggregates (see below); single-/multi late_n & eligible_n; all §17.4 evidence fields |
| Repetition | eligible_n and late_n for Half 1 and Half 2 (customer lateness) |
| Reference | comparator seller count; late and eligible totals overall and by half; \(p_{-s}\) components; usability pass/fail |
| Fit | single_seller_late_n, handoff_evaluable_late_n, handoff_support_n |
| Decision | each gate pass/fail, membership yes/no/inconclusive reason, reason codes, primary reason |
| Capacity | excess-burden score pair, **rank** (or null), C, O, R, S, simulation_S_equals_C_flag, **selected** flag, **action** |
| Release | operational_release_hold_flag / reason (packet-level ok if constant per run) |
| Audit | run validity, source-quality flags |

**multi_seller_order_flag aggregation (AI3 clarification):** For each seller, provide: `multi_seller_association_n` = count of distinct eligible seller–orders where `multi_seller_order_flag` = TRUE (i.e., the order has >1 distinct seller association); `single_seller_association_n` = `eligible_n - multi_seller_association_n`; `late_n_ms` and `late_n_ss` as defined in §17.4.

Primary reason precedence (adapt A): no eligible volume → below volume floor → coverage failure → insufficient comparator → materiality failure → repetition failure → handoff evaluability failure → handoff support failure → multi-seller inconclusive (N4) → clock-action inconclusive (N5) → qualified. Capacity reasons separate.

Companion descriptive tables (Wilson, severity, ship-limit summaries) **must not** alter the core decision contract.

---

## 21. SQL B lower-grain output contract (AM #8 LOCK A package)

SQL B is one independently produced extraction package with **three** required relations:

- **B_orders:** raw projection of all order records in the frozen snapshot—identity, status, purchase, actual-delivery, estimated-delivery, carrier-handoff fields as present.  
- **B_items:** raw projection of all item records—order/item/seller keys, shipping_limit_date.  
- **B_sellers:** raw projection of all seller records—seller identity and approved attributes. **Minimum required:** `seller_id` (valid, non-null, unique key) and source-version audit fields. Additional approved attributes are optional for diagnostic context only. Stage 4 must verify `seller_id` presence and uniqueness before proceeding.

Full snapshot of required columns (not only in-window delivered). Preserve duplicates and invalids. **Must not** supply seller aggregates, eligibility flags, late flags, comparator totals, membership, ranks, or actions.

Manifest: source/snapshot identity, extraction timestamp, schema/type mappings, row counts, column order, encoding, delimiter/quoting, null encoding ≠ empty text, temporal precision, timezone convention, file hashes. No silent truncation.

**REJECT** B’s pre-built seller-order dump with late_date/late_ts flags as the controlling SQL B contract.

---

## 22. R(B) reconstruction contract (AM #8)

**Permitted:** B required relations + manifest + frozen spec/config (+ optional raw dims for optional diagnostics only).  
**Forbidden:** A, A intermediates, A baselines/lists, V1 decisions, recon feedback before first R(B) freeze.

R(B) independently: validate keys/types/integrity; reconstruct seller–orders and full seller universe; apply window/status/date-quality/chronology; compute DATE and timestamp outcomes; rebuild candidates/exclusions/half counts/handoff; rebuild reference and LOO comparators (all-order and ss); evaluate gates with exact comparisons; apply N4 and N5 per §17.4–§17.5; rank remaining qualifiers; apply S; emit **same judged schema as A** + audits.

Canonical LFR = integer numerator/denominator with explicit null for zero denom. Exact integer/rational arithmetic for thresholds and ranking (3 pp via scaled cross-products; same for 95%/90%/50% boundaries). Descriptive Wilson/severity do not feed membership unless spec revised.

---

## 23. Exact reconciliation contract (AM #9)

**Must match exactly between A and R(B):**

- Seller key sets, specification, snapshot, configuration, window.  
- Integer `late_n`, `eligible_n` (and single-/multi-seller pairs used in gates).  
- Canonical LFR num/den including null behavior.  
- Gate inputs, comparator totals, half counts, handoff counts.  
- N4/N5 evidence fields listed in §17.5.  
- **Membership**, **rank**, **selected**, **action**.  
- Deterministic tie handling and S application (including simulation flag).  
- Additive exclusions and source-audit totals.

Float display LFR is **not** authority. Optional separate standardized decimal check never compensates for count mismatch.

**Frozen snapshot consistency (AI3 clarification):** SQL A and R(B) must use the same frozen snapshot extraction for their respective builds. The source snapshot identity must be recorded in both A and R(B) manifests. If source extraction is done separately, both must use identical time-locked views. Mismatches due to extraction timing are treated as recon failures.

**Mismatch protocol:** critical fail; **neither list ships**; retain both outputs; diagnose at source-record level; never edit counts or copy judgments to force agreement. Spec change → new version; rebuild affected branches independently. Recon critical mismatch is a **recon halt** under this contract (§14.1(d)), not a separate discretionary hold process.

**Invariants (A):** nonnegative counts; late_n ≤ eligible_n; candidate = eligible + excluded; half counts partition the window (non-overlapping); handoff_support ≤ handoff_evaluable ≤ single_seller_late ≤ total late; selected count = min(S, Q_final); no nonqualifier selected; no padding; WATCH/INCONCLUSIVE never selected.

---

## 24. Multi-AI review and resolution record

| Phase | Artifact |
| --- | --- |
| Independent A | Design_A_ChatGPT.md |
| Independent B | Design_B_Grok.md |
| Independent dossier | Data_Risk_Dossier_DeepSeek.md |
| Cross-review packet | CROSS_REVIEW_PACKET.md |
| AI1 review | AI1_CROSS_REVIEW_ChatGPT.md |
| AI2 review | AI2_CROSS_REVIEW_Grok.md |
| AI3 review | AI3_CROSS_REVIEW_DeepSeek.md |
| Reconciliation | DESIGN_RECONCILIATION_MATRIX.md (Phase 4) |
| Open questions | PHASE4_OPEN_QUESTIONS.md |
| Data profile (VF) | FulfillIQ_Data_Profile_V1_READONLY.md |
| DB context (VF) | FulfillIQ_Database_Context_V1_READONLY.md |
| This candidate | CANDIDATE_MEASUREMENT_DESIGN.md (v0.2.1 Phase 7 AI3 clarifications) |
| Phase 7 AI1 audit | AI1_PHASE7_AUDIT_ChatGPT.md (REVISE → v0.2) |
| Phase 7 AI2 audit | AI2_PHASE7_AUDIT_Grok.md (Pass) |
| Phase 7 AI3 audit | AI3_PHASE7_AUDIT_DeepSeek.md (Pass + clarifications → v0.2.1) |
| Phase 7 AI1 changelog | CHANGELOG_PHASE7_AI1_REVISE.md |
| Phase 7 AI3 changelog | CHANGELOG_PHASE7_AI3_CLARIFY.md |
| Design Gate | DESIGN_GATE.md |
| Locked Stage 3 deliverable | Stage_03_Measurement_Design.md (copy of v0.2.1) |

Resolutions were **not** by majority vote; coordinator encoded controlling business + methodological rules (matrix). Material numeric cutoffs remain provisional pending human Design Gate / Mark approval.

---

## 25. Assumptions, open questions, and accepted limitations

**Assumptions:** Locked 8-month window and non-overlapping halves are the controlling calendar for this candidate; C=20 operationalizes “about 20”; A-style pattern warrant is the membership spine; SQL B remains raw three-table; S is available slots after occupancy.

**Accepted limitations:** Delivered-only construct; shared multi-seller outcomes; handoff is a proxy; historical 2018 extract ≠ current seller state at a live VP meeting; H4 untestable here; provisional thresholds are policy proposals, not validated optima or SLAs; H2 does not rule out boundary-straddling single episodes; H3 handoff is full-window not half-repeated.

**Open questions requiring Mark/Maya:** see `PHASE4_OPEN_QUESTIONS.md` (authoritative S; confirm C=20). Methodological items remain closed.

---

## 26. Stage 4 handoff and lock approval

**Ready to hand to Stage 4 builders only after:** human analyst Design Gate approval; parameter register acceptance; authoritative **S** (or explicit full-capacity simulation label); schema/handoff field verification (PENDING-DB items); frozen snapshot identity.

**Stage 4 must not:** write design choices into SQL; invent `seller_plan_enrollment` or featured fields; pad to 20; enroll on severity alone; claim causality; ship either branch on recon mismatch; have A read B; treat WATCH/INCONCLUSIVE as enrollment; silently replace N4/N5 with analyst discretion.

**Approval block (blank):**

| Role | Name | Date | Decision |
| --- | --- | --- | --- |
| Human analyst (Mark) | | | Approve / Revise / Reject |
| Stakeholder (Maya) if business change | | | N/A unless open questions fire |

---

### Provisional numeric parameter register (controlling choices consolidated)

**Legend:** Decision parameters control membership/action. Reporting bands do not. Diagnostic stress tests do not override action except N5 as specified.

| Parameter | Value | Kind | Status / approval | Boundary behavior |
| --- | --- | --- | --- | --- |
| Purchase window | 2018-01-01 incl → 2018-09-01 excl | Structural decision | **LOCK** (B); matrix Population/window | Purchases outside → not in primary denom |
| Half 1 / Half 2 | Jan–Apr / May–Aug as dated §8 | Structural decision | **LOCK** non-overlapping | Overlap rejected; thin half fails persistence |
| Tiny-volume / floor | eligible_n < 30 → standard; ≥30 to qualify | Decision (PA level) | AM; **PA** | After all exclusions; ss floor same integer for N4 |
| Coverage | ≥95%; 0 candidate → fail | Decision | PA (AM #5) | Fail → cannot YES |
| Elevation | ≥5 late; ≥3 pp vs LOO | Decision | PA (AM #4) | Equality on “at least 3 pp” passes |
| Half floors | ≥10 eligible; ≥2 late; LFR ≥ half comparator | Decision | PA | Equality passes; customer lateness only |
| Handoff membership | ≥3 support; ≥50% of all eligible late; ≥90% ss late evaluable; 0 ss late fails | Decision | PA (AM #6) | Full-window only; not half-repeated |
| Comparator usability (full) | ≥20 other comparator sellers **and** ≥1,000 comparator eligible seller–orders | Decision | PA | Fail → insufficient comparator; cannot YES |
| Comparator usability (half) | ≥200 comparator eligible seller–orders **each** half | Decision | PA | Fail → insufficient half comparator; ≥20 other-seller count is full-window only (AI3) |
| N4 ss too thin | eligible_n_ss < 30 | Decision (N4) | PA; §17.4 | With majority → INCONCLUSIVE if all-order would YES |
| N4 majority | eligible_n_ms/eligible_n > 0.5 **or** late_n_ms/late_n > 0.5 | Decision (N4) | PA; §17.4 | Strict >; see §17.4 branches |
| N4 ss gates recomputed | ss volume + materiality + half persistence; ss LOO reference | Decision (N4) | AM #4; §17.4 | Ss comparator unusable → ss not rate-clear → INCONCLUSIVE if all-order YES |
| N4 precedence | After steps 1–6; before rank; inside each Run D/T | Rule ref | §17.4 | Does not upgrade all-order failures |
| N5 twin runs | Run D date vs Run T timestamp full pipelines | Decision (N5) | AM #3; §17.5 | Action override exception to diagnostic-only rule |
| N5 freeze / capacity | Compare provisional actions **after** selection; capacity-only diffs count | Rule ref | §17.5 | Disagreers → INCONCLUSIVE |
| N5 removal/refill | Remove disagreers; refill once under Run D only; no T re-loop | Rule ref | §17.5 | Disagreers never refilled to ENROLL |
| Capacity C | 20 | Structural decision | AM integer of “about 20” | Change → new spec version |
| Available S | \(S=\max(0,C-O-R)\); authoritative for ops release | Decision / ops | `PHASE4_OPEN_QUESTIONS.md` #1 | S=0 → no selections; all YES → WATCH |
| Simulation S=C | Allowed only if labeled full-capacity simulation (O=0 assumption) | Simulation label | §17.3 | Not authoritative for live enrollment |
| WATCH / INCONCLUSIVE | Non-enrolling; standard terms operationally | Action rule | AM #7 | Never selected |
| Operational-release hold | §14.1 trigger/owner/scope; membership preserved | Ops process | Phase 7 | New spec only if gates change |
| Severe-delay band | >7 calendar days | Diagnostic only | PA | Cannot enroll |
| Volume reporting bands | 0 / 1–9 / 10–29 / 30–99 / ≥100 | Reporting only | PA | Not eligibility thresholds |
| Sensitivity stresses | floor 20/50; elev 2/5 pp; cov 90/99%; handoff 1/3 & 2/3 | Diagnostic only | PA | Do **not** override action (except N5) |
| Wilson 95% | Interval on LFR | Diagnostic only | A | Not enrollment gate |
| Ship-limit/carrier summaries | Diagnostic aggregates | Diagnostic only | AM #12 | Distinct from §11.2 membership handoff |

---

*End of CANDIDATE_MEASUREMENT_DESIGN.md — Phase 7 AI3 clarifications (v0.2.1). No executable SQL/R. All numeric cutoffs provisional. AI3 contract-gap clarifications applied. Approved decision (§2) and locked analytical question (§3) unchanged.*
