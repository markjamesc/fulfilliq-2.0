AI 3 Implementation-Contract Auditor Report
Document: CANDIDATE_MEASUREMENT_DESIGN.md (v0.2 Phase 7 revise)
Audit Date: 2026-09-08
Auditor: AI 3 (DeepSeek)

Executive Summary
This candidate Passes as a Stage 4 implementable specification. Contract gaps identified are clarifications, not blockers. No analytical decisions require invention. The design is sufficiently detailed for independent SQL A and R(B) implementation.

(1) Pass Items
Source Availability
Item	Status	Evidence
Required source tables identified	PASS	raw_orders, raw_order_items, raw_sellers (§7.1, §21)
Source version/snapshot requirements	PASS	Frozen snapshot, source identity, manifest (§8, §21)
PENDING-DB flagged for verification	PASS	Featured/catalog fields flagged PENDING-DB; Stage 4 must verify (§4)
Multi-AI review provenance	PASS	Complete artifact chain documented (§24)
Field Definitions
Item	Status	Evidence
Primary KPI (LFR) fully specified	PASS	§10 — late_n/eligible_n; null behavior; same-day on-time
Timestamp twin defined	PASS	§17.5; twin fields; action override mechanism
Single-seller/multi-seller definitions	PASS	§17.4; explicit numerator/denominator definitions
Handoff field definitions	PASS	§11.2; three-component support path with denominators
Action taxonomy unambiguous	PASS	§17.6 — four actions with enrollment semantics
Keys/Cardinalities
Item	Status	Evidence
Grain specified	PASS	§9: raw item (order_id, order_item_id); measurement (seller_id, order_id); decision one seller per window
Multi-seller handling	PASS	§9, §17.4: flag, dual KPIs, N4 INCONCLUSIVE
Join path documented	PASS	§9: validate identities → distinct seller–order from items → attach order → aggregate
Cardinality rules	PASS	§9: collapse items before counting; report both seller totals and unique customer-order totals
Grain Transitions
Item	Status	Evidence
Item to seller–order	PASS	§9: distinct seller–order association
Seller–order to seller aggregate	PASS	§9: one seller × one window × one spec version
Half aggregation	PASS	§8: non-overlapping halves; §17.1 step 5
Date Logic
Item	Status	Evidence
Date-rule late definition	PASS	§10: DATE(actual) > DATE(estimated)
Timestamp twin	PASS	§10, §17.5: strict timestamp >; mandatory twin comparison
Chronology rules	PASS	§7.3: actual/estimated not earlier than purchase
Window partitioning	PASS	§8: Jan–Apr / May–Aug non-overlapping; purchase time clock
Missingness/Anomaly Rules
Item	Status	Evidence
Run-blocking criteria	PASS	§15: duplicate keys, missing mappings, broken consistency
Row-level exclusions	PASS	§7.3, §15: missing dates, chronology violations
Missing outcomes never on-time	PASS	§7.3: nondelivered excluded from denominator
No imputation/winsorization	PASS	§15: preserve raw values; no imputation
SQL A/B/R(B)/Recon Contracts
Item	Status	Evidence
SQL A judged table schema	PASS	§20: all required field groups specified
SQL B raw extraction package	PASS	§21: three required relations; no aggregates/decisions
R(B) reconstruction constraints	PASS	§22: permitted inputs; independent rebuild; same judged schema
Reconciliation criteria	PASS	§23: exact match on key fields; mismatch protocol
Non-executable blueprint	PASS	§19: step-by-step implementation guidance
Stage 4 Buildable Without Invention
Item	Status	Evidence
All thresholds specified	PASS	PA cutoffs in parameter register; no "see analyst" gaps
Comparator construction	PASS	§12: leave-one-out; reference set; usability cutoffs
N4/N5 fully specified	PASS	§17.4–17.5: trigger conditions, branch logic, refill order
Ranking deterministic	PASS	§17.2: four-level tie hierarchy; seller_id as final tie-breaker
Capacity selection	PASS	§17.3: S = max(0, C-O-R); simulation label required
(2) Contract Gaps
Gap 1: raw_sellers Field Availability
Location: §7.1, §21
Issue: The spec references raw_sellers but does not define which fields are available/required for the seller universe. B_sellers contract (§21) says "seller identity and approved attributes" without listing specific columns.

Required Fix: Add to §7.1 or §21:

"B_sellers must include at minimum seller_id (valid, non-null, unique key) and source-version audit fields. Additional approved attributes are optional for diagnostic context only. Stage 4 implementation must verify seller_id presence and uniqueness before proceeding."

Impact: Clarification only; Stage 4 can infer minimum seller_id.

Gap 2: Date/Time Temporal Semantics for "Earlier Than"
Location: §7.3 (chronology OK: actual/estimated not earlier than purchase)
Issue: "Not earlier than" is ambiguous when comparing dates vs timestamps at different precisions.

Required Fix: Add to §7.3:

"Chronology validation compares full timestamp values (not date-truncated) when both fields are timestamps. If one field is date-only and the other timestamp, the source's recorded precision governs; convert both to comparable types per source documentation. All three fields (purchase, actual, estimated) must be parseable to the same temporal precision for equality boundary evaluation."

Impact: Prevents ambiguity in Stage 4 implementation.

Gap 3: N4 Half Comparator Usability Reference Population
Location: §17.4, "Single-seller half comparators" paragraph
Issue: The text says "usability cutoffs (§12) applied to ss comparator eligible orders" but §12 defines half usability as "≥200 comparator eligible seller–orders in each half." The §17.4 paragraph also references "≥1,000 ss comparator eligible orders full-window" but the half usability wording is ambiguous about whether the full-window threshold or the half threshold controls per half.

Required Fix: In §17.4, replace:

"usability cutoffs (§12) applied to ss comparator eligible orders (≥20 other reference sellers with ss volume contributing; ≥1,000 ss comparator eligible orders full-window; ≥200 ss comparator eligible orders each half)"

With explicit clarification:

"For the single-seller half comparators in N4, the usability threshold per half is ≥200 comparator eligible seller–orders from single-seller associations in that half, not the full-window ≥1,000 threshold. The full-window ≥1,000 threshold applies only to the all-order comparator usability (§12) and does not govern half comparator availability. Half usability in N4 follows the same half-specific logic as §12 but applied to ss associations."

Impact: Prevents implementation error where full-window threshold incorrectly gates half comparators.

Gap 4: Comparator Seller Count for Half Usability
Location: §12, §17.4
Issue: §12 requires "≥20 other comparator sellers" for full-window usability. The half usability specifies "≥200 comparator eligible seller–orders in each half" but does not specify a minimum other-seller count for half comparators.

Required Fix: Add to §12 in the half usability row:

"Half comparator usability: ≥200 comparator eligible seller–orders in each half and ≥10 other comparator sellers contributing to the half comparator pool." (PA)

Alternative: Explicitly state that the ≥20 other-seller count applies only to full-window and does not extend to half comparators.

Impact: Clarifies boundary behavior for sparse half-reference sets.

Gap 5: Coverage Denominator - "Candidate Delivered"
Location: §11.1, "Measurement coverage eligible / candidate_delivered ≥ 95%"
Issue: "Candidate delivered" is defined in §7.2 but the definition includes "delivered status and purchase timestamp inside the locked window" before delivery-date quality exclusions. §7.3 then applies additional exclusions (valid delivery dates, chronology). The coverage ratio uses eligible (post-§7.3) over candidate_delivered (pre-§7.3). This is clear but could be mistaken.

Required Fix: Add to §11.1:

"Coverage denominator candidate_delivered_n uses the §7.2 definition before the §7.3 delivery-date-quality exclusions. eligible_n uses the §7.3 definition. Thus coverage measures data-quality fallout from invalid/missing delivery dates, not volume filtering."

Impact: Clarification prevents denominator confusion.

Gap 6: N4 Thin+Majority Branch — Which Late Count?
Location: §17.4, Thin+Majority branch
Issue: The branch says "when eligible_n_ms / eligible_n > 0.5 or, when using the late composition for the thin branch narrative, late_n_ms / late_n > 0.5." This is ambiguous about when the late-majority branch triggers.

Required Fix: Explicitly state:

"The late-majority branch (late_n_ms / late_n > 0.5) triggers regardless of whether the eligible-majority branch triggers. Both flags are computed and emitted. If either branch is true AND eligible_n_ss < 30 AND all-order would otherwise pass, N4 fires."

Impact: Removes ambiguity about OR semantics.

Gap 7: Run A's Relationship to B_orders/B_items in Recon
Location: §23 reconciliation
Issue: Reconciliation requires exact match on key outputs, but the spec does not explicitly state whether SQL A uses the same B_orders/B_items package or queries the source directly. If SQL A queries the source and R(B) uses B, source extraction timing could create mismatch.

Required Fix: Add to §19 or §23:

"SQL A and R(B) must use the same frozen snapshot extraction for their respective builds. The source snapshot identity must be recorded in both A and R(B) manifests. If source extraction is done separately, both must use identical time-locked views. Mismatches due to extraction timing are treated as recon failures."

Impact: Prevents false recon mismatches from extraction timing.

Gap 8: multi_seller_order_flag Aggregation Detail
Location: §20, Field group "Multi-seller / N4"
Issue: The spec requires "multi_seller_order_flag aggregates" but does not specify whether this is a count of multi-seller orders, a count of seller-associations to multi-seller orders, or a boolean per seller.

Required Fix: In §20, specify:

"For each seller, provide: multi_seller_association_n = count of distinct eligible seller–orders where multi_seller_order_flag = TRUE (i.e., the order has >1 distinct seller association); single_seller_association_n = eligible_n - multi_seller_association_n; late_n_ms and late_n_ss as defined in §17.4."

Impact: Ensures N4 implementation has required counts.

Gap 9: Operational-Release Hold — Trigger (d) "Neither list ships"
Location: §14.1, Trigger evidence (d)
Issue: "(d) A vs R(B) recon critical mismatch (neither list ships—hold is automatic)" references a recon mismatch before the list is finalized. This creates a circularity: if A and R(B) mismatch, no list exists to ship, so "neither list ships" is tautological.

Required Fix: Reword:

"(d) A vs R(B) recon critical mismatch occurs; in this state, release is prohibited by recon contract (§23) and the hold is automatic until resolved. This is a recon halt, not a separate hold trigger."

Impact: Clarifies that recon failure is a halt, not an additional hold process.

(3) Verdict
PASS — with clarifications
Rationale: This candidate is implementable by Stage 4 without inventing analytical decisions. All gaps are clarifications that can be resolved by annotating the existing document. No gap requires changing the locked analytical question, numeric cutoffs, membership gates, N4/N5 logic, capacity selection, or action taxonomy.

Required fixes summary (concrete, non-discretionary):

Gap 1: Specify minimum B_sellers fields (seller_id required)

Gap 2: Specify chronology comparison precision

Gap 3: Clarify N4 half comparator usability thresholds

Gap 4: Add or clarify half comparator seller-count requirement

Gap 5: Clarify coverage denominator definition

Gap 6: Specify late-majority branch triggering

Gap 7: Specify frozen snapshot consistency between A and R(B)

Gap 8: Specify multi_seller_order_flag aggregation

Gap 9: Clarify recon mismatch as halt, not hold trigger

Approval path: The document is ready for Stage 4 handoff once these clarifications are annotated in the next version (v0.3). No material design change is required.

Appendix: Field-by-Field Verification Trace
Field/Concept	Section	Verifiable in Source?	Stage 4 Action
order_purchase_timestamp	§8	✓ Source	Extract raw
order_delivered_customer_date	§10	✓ Source	Parse date
order_estimated_delivery_date	§10	✓ Source	Parse date
shipping_limit_date	§11.2	PENDING-DB	Verify field exists
Carrier handoff timestamp	§11.2	PENDING-DB	Verify field exists
seller_plan_enrollment	§17.6	NOT REQUIRED	Do not invent
Featured/catalog fields	§4	PENDING-DB	Verify absence; do not invent
multi_seller_order_flag	§9, §17.4	Derived	Compute from join cardinality
Single-seller reference LOO	§17.4	Derived	Recompute from single-seller associations
End of Report


