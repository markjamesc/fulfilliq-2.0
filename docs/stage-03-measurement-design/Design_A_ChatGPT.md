# Design A — ChatGPT Work GPT-6 Astra High
Chat: https://chatgpt.com/c/6aa09d34-d528-83e8-8ce2-1c5233803473

# FulfillIQ 2.0 — Stage 3 — Design A

Author role: AI 1 Primary Measurement Architect.
Status: Complete Design A proposal, sections 1–23. No executable SQL or R. Not yet a locked or empirically validated measurement specification.

Model/mode: ChatGPT acting as Codex in Work Mode, Default collaboration mode. The exact underlying model identifier and reasoning setting are not exposed to this session.
Chat URL: Not available in the supplied session context; not invented.
Independence: Prepared from this Stage 3 brief, without consulting V1 enrollment lists, Grok, or DeepSeek.

The original framework's numbered section titles were not supplied. The 23 sections below provide a complete explicit mapping of the requested requirements; they do not claim to reproduce an unseen template.

**APPROVED DECISION — verbatim**

Maya Chen must decide which marketplace sellers if any to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms to reduce late customer deliveries under hard concurrent capacity about 20 (no padding; enroll fewer if fewer meet bar) by mid-month VP ops meeting; tiny-volume stay standard; featured placement out; ops enrollment not RCT; numeric cutoffs designed in Stage 3 only to serve enrollment.

**LOCKED QUESTION — verbatim**

Under locked concurrent capacity about 20 with tiny-volume on standard terms which sellers if any have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer ops check-ins and seller corrective path rather than ordinary marketplace monitoring?

## 1. Hypothesis hierarchy

**Decision hypothesis:** Some sellers may exhibit sufficiently material, repeated late customer deliveries, with an observable fulfillment-process signal, to warrant the documented improvement plan.

**Competing explanation:** Apparent poor performance may reflect sparse observations, a temporary episode, customer or product mix, delivery promises, carrier operations, or measurement defects. A high rate alone does not establish that this intervention fits.

**Measurement hypotheses:**

- H1, materiality: a seller's late-delivery rate materially exceeds a contemporaneous reference among assessable sellers.
- H2, repetition: the elevation occurs in both prespecified time blocks, rather than only one pooled episode.
- H3, operational fit: repeated late deliveries coincide with a late carrier-handoff signal on orders attributable to one seller.
- H4, intervention effectiveness: the plan subsequently reduces late deliveries.

H1–H3 support provisional analytical membership. H4 cannot be established from the historical observational extract and is not an enrollment prerequisite disguised as an experiment. Failure to establish H1–H3 means insufficient support under this rule, not proof of acceptable performance.

## 2. Decision scope and evidence standard

Membership is decided before capacity ranking. No seller qualifies merely by being among the worst twenty.

The rule supports a reversible, documented process-improvement intervention. It does not establish fault, justify a penalty, or estimate treatment benefit. All nonselected sellers remain on standard terms; their evidence and capacity reasons remain distinguishable.

Distinguish three outputs:

- **Analytical membership:** yes/no under the frozen measurement rule.
- **Capacity selection:** which qualifying sellers receive the available slots.
- **Operational enrollment:** Maya's recorded implementation decision.

The first two are derived outputs reproducible from the source extract and configuration. The third requires an external operations record and is not an Olist database field.

## 3. Source inventory and field verification

Primary source: MySQL schema fulfilliq, as supplied. Actual table structures, types, completeness, and engine version have not been inspected.

| Source | Permitted role |
| --- | --- |
| raw_orders | Order identity, status, purchase date, customer-delivery outcome, estimated delivery date, and proposed carrier-handoff diagnostic |
| raw_order_items | Seller–order association, item multiplicity, and proposed shipping-deadline diagnostic |
| raw_sellers | Seller universe and seller geography |
| raw_customers | Optional destination-state diagnostic |
| raw_products, raw_category_translation | Optional product-category diagnostic |
| raw_payments, raw_reviews | Excluded from the core measure and membership rule |
| raw_geolocation | Optional later geography work; excluded from the core joins |

Expected core mappings requiring Stage 4 verification are order_id, order_status, order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date; item order_id, order_item_id, seller_id; and seller seller_id.

The proposed operational-fit gate additionally requires verified meanings and availability of order_delivered_carrier_date in orders and shipping_limit_date in items. These are expected mappings, not claims about inspected local columns. If unavailable or semantically unsuitable, the operational-fit path is blocked; do not invent substitutes or silently qualify sellers from rates alone.

Expected optional mappings are order customer_id, customer customer_state, seller seller_state, item product_id, and product category. Verify names and relationships before use. No source field for featured placement or plan enrollment is assumed.

## 4. Seller population and exclusions

Reporting universe: every distinct valid seller identifier in raw_sellers in the frozen source snapshot, including sellers with no eligible observations.

Construct candidate seller–orders from distinct seller–order associations in items linked to an existing order. Candidate delivered volume consists of those associations with delivered status and purchase timestamps inside the chosen window, before delivery-date quality exclusions.

Primary eligibility requires:

- A valid association with an existing seller and unique order record.
- Delivered status.
- A valid in-window purchase timestamp.
- Nonmissing, parseable actual customer-delivery and estimated-delivery values.
- Actual delivery and promised delivery not earlier than purchase under the chronology rule in section 13.

Nondelivered orders do not enter the primary denominator. Missing outcomes are never interpreted as on-time outcomes. Missing or invalid associations are audited separately.

Retain tiny-volume sellers in the reporting table, with their observed counts and a standard-terms reason. Do not drop them merely because they cannot qualify.

## 5. Time window and observation boundary

**Provisional primary purchase window:** 1 January 2018 00:00:00 inclusive through 1 July 2018 00:00:00 exclusive.

**Provisional repetition blocks:**

- Block 1: 1 January through 1 April 2018, end exclusive.
- Block 2: 1 April through 1 July 2018, end exclusive.

Two full quarters allow the same repetition test for every seller. This is a Stage 3 proposal, chosen independently of V1 results. It sacrifices recency and may miss later problems; inspect coverage before locking it.

Cohort membership uses purchase time. A delivery after 30 June still contributes if its purchase qualifies and its outcome is observed in the frozen snapshot.

Use the source's recorded calendar convention without speculative timezone conversion. Verify temporal types, session timezone, precision, and serialization before extraction.

This is a retrospective, final-observed-status analysis, not a reconstruction of what was known on 1 July 2018. Record extract time, source version, outcome-observation boundary, and monthly delivered/nondelivered counts. Maximum observed delivery time alone does not establish complete follow-up.

If the snapshot cannot support adequately observed outcomes for this window, revise and relock the window before producing decision-ready results. Do not choose a replacement window by whichever produces twenty qualifiers.

## 6. Grain and join contract

Raw item grain is one source item record; expected business key is (order_id, order_item_id). Verify this key rather than assuming uniqueness.

Primary measurement grain is one (seller_id, order_id). Multiple items supplied by one seller in one order count once. Multiple sellers in an order each receive one association with the shared order-level delivery outcome.

Final judgment grain is one seller for one window and specification version.

Core relationship sequence:

1. Validate source identities and uniqueness.
2. Derive distinct seller–order associations from items.
3. Attach one order record to each association.
4. Calculate seller–order eligibility and outcomes.
5. Aggregate to seller and time block.
6. Attach results to the complete seller universe.

An order with several sellers can contribute several seller–orders. Therefore seller totals are not unique customer-order totals. Report both denominators explicitly.

Do not join payments, reviews, products, or raw geolocation into the counting path. Optional dimensions must first satisfy their own unique-key contracts and must leave core counts unchanged.

## 7. Primary KPI and companion outcome measures

**Seller Late-Fulfillment Rate (LFR)** is an association-based customer-delivery outcome, not a direct measure of seller dispatch culpability.

For seller \(s\):

- \(n_s=\text{eligible_n}\): distinct eligible seller–orders.
- \(k_s=\text{late_n}\): those eligible seller–orders whose actual customer-delivery calendar date is later than the estimated-delivery calendar date.
- \(\text{LFR}_s=k_s/n_s\), when \(n_s>0\).
- LFR is null when \(n_s=0\), never zero.

Same-day delivery is on time regardless of hour. There is no grace period. Decisions use exact counts and unrounded comparisons; displayed percentages are not decision inputs.

Mandatory timestamp twin: on the same eligible population, compare the full actual and estimated timestamps with strict greater-than. Retain late_n_timestamp, its exact rate pair, and the count of date/timestamp disagreements.

Companion severity measures use positive calendar days past the promise: median days late and count more than seven days late. The seven-day band is **provisional** and diagnostic only. Neither severity measure changes membership in Design A.

## 8. Guardrails and the operational-fit measure

**Measurement coverage guardrail:** eligible delivered seller–orders divided by candidate delivered seller–orders. Require at least **95% provisionally**. If candidate volume is zero, coverage is null and the gate fails.

**Operational-fit measure:** identify eligible late customer deliveries on single-seller orders with a valid carrier-handoff timestamp and valid shipping deadlines for every item. The carrier timestamp must fall between purchase and actual customer delivery; each deadline must not precede purchase. Otherwise handoff evidence is unavailable for that order.

For an evaluable single-seller order, define the conservative handoff signal as carrier receipt strictly later than the latest item shipping deadline. This avoids declaring the whole order late solely because one item had an earlier deadline, but can miss partial dispatch problems.

Define:

- single_seller_late_n: eligible late seller–orders whose order has exactly one distinct valid seller and no unresolved seller association.
- handoff_evaluable_late_n: those single-seller late orders with valid handoff evidence.
- handoff_support_n: those evaluable orders with the conservative late-handoff signal.

**Provisional fit requirements:** at least three supporting orders; supporting orders constitute at least 50% of all the seller's eligible late orders; and at least 90% of single-seller late orders have evaluable handoff evidence. Zero single-seller late orders fail this gate.

These requirements deliberately demand repeated process evidence. Carrier receipt timing also depends on pickup arrangements and logging. The signal supports a handoff-focused corrective investigation; it does not prove seller responsibility.

## 9. Comparison and baseline

Define the assessable reference set as sellers with at least **30 eligible seller–orders provisionally** and passing the coverage guardrail. Do not require high lateness, repetition, or handoff support to enter the reference.

For each seller, the comparator consists of reference-set sellers other than that seller. Require at least **20 comparator sellers and 1,000 comparator eligible seller–orders provisionally** for a usable full-window baseline.

Calculate the pooled, seller–order-weighted late rate:

\[
p_{-s}=\frac{\sum_{j\in \text{reference},\,j\ne s}k_j}
{\sum_{j\in \text{reference},\,j\ne s}n_j}.
\]

For each block, use the same comparator seller identities and their eligible block observations. Require at least **200 comparator seller–orders in each block provisionally**.

The seller cannot influence its own comparator. The same order can still appear through another seller in a multiseller order; disclose this dependence.

Also report marketplace seller–order LFR, unique-order LFR, the unweighted median seller LFR in the reference set, and reference volume concentration. These are context, not interchangeable baselines. No V1 rate, percentile, or enrollment count is an anchor.

## 10. Segments and diagnostic comparisons

Required segments, all derived without changing the primary numerator or denominator:

- Eligible-volume bands: 0, 1–9, 10–29, 30–99, and at least 100; **provisional reporting bands**.
- Purchase month and the two fixed blocks.
- Single-seller versus multiseller orders.
- Measurement coverage pass/fail and handoff evidence available/unavailable.

Optional verified dimensions: seller state, customer destination state, within-state versus cross-state delivery, and product category.

For category diagnostics, reduce items to distinct seller–order–category associations. Label this view nonadditive across categories; never sum it back into primary volume.

Sparse segment cells retain their counts but are not treated as reliable rankings. Use **30 observations provisionally** for displayed segment-rate comparisons. Missing dimensions remain an explicit unknown group rather than excluding the order.

Segments test interpretation. They do not become additional eligibility thresholds without a documented specification revision.

## 11. Confounders and alternative explanations

Evaluate whether an apparent seller problem is concentrated in destination routes, geography, product mix, time periods, unusually tight delivery promises, or multiseller orders.

Carrier performance, pickup schedules, seller processing, and promise construction can all influence customer-delivery outcomes. This design does not isolate them causally.

Purchase-month comparisons help detect marketplace-wide episodes. Single-seller diagnostics reduce one attribution problem but select a different order mix. Delivered-only selection can hide unresolved or canceled orders.

No regression adjustment or causal model controls membership in Design A. If diagnostics materially undermine the handoff interpretation, mark the recommendation as requiring resolution before operational release. Do not quietly replace the deterministic rule with analyst discretion.

## 12. Sample size and uncertainty

**Provisional tiny-volume definition:** fewer than 30 eligible seller–orders. Such sellers stay on standard terms under this design. Thirty is a policy floor for assessability, not a guarantee of precision.

The supplied median of approximately six delivered orders and approximately 80% of sellers below thirty are contextual estimates, not verified counts for this proposed window. Recompute the distribution after exclusions. Disclose what share of sellers and order volume the floor removes.

Report a 95% Wilson interval for each nonzero-denominator LFR. The interval is descriptive and is not a 95%-certainty enrollment gate. NIST describes the Wilson method for binomial proportions. genui{"citation":{"ref":"turn0search0"}}

Wilson intervals assume a binomial-style model that ignores much of the temporal and operational dependence here. They do not prove causal responsibility or adjust for screening many sellers. Report count-based evidence and sensitivity alongside them.

Repetition and handoff gates add conservatism but do not mathematically solve sampling uncertainty. Where intervals are wide, say so; do not describe a qualifying seller as certain to remain problematic.

## 13. Data-quality rules and failure handling

**Run-blocking defects:** unresolved duplicate order keys, duplicate item business keys, duplicate seller keys, missing required mappings, broken snapshot consistency, or ambiguous source parsing that could alter eligibility or linkage.

Do not silently deduplicate source business-key collisions. Resolve them with an auditable source rule before either branch produces a decision-ready table. Repeated seller–order associations across valid item keys are expected and are collapsed normally.

**Row-level primary exclusions:** missing actual or estimated delivery; invalid required dates; actual delivery earlier than purchase; estimated delivery earlier than purchase. Use full timestamp chronology after temporal semantics are verified. Preserve all failed checks and assign one primary exclusion reason in the stated order for additive reporting.

**Diagnostic-only defects:** missing carrier handoff, invalid handoff chronology, or missing/invalid shipping deadlines remove handoff evaluability, not otherwise valid primary outcomes.

Invalid purchase timestamps cannot safely be classified as in-window or out-of-window. Missing seller/order keys and orphan associations cannot safely be attributed. Audit these outside the cohort and block release if their possible effect on counts, membership, or capacity cannot be bounded and resolved.

For every seller, partition candidate delivered seller–orders into eligible and excluded counts. Audit other statuses separately. An order with no item association is retained in the order audit and has no invented seller.

Keep raw values, parsed values, and reason codes traceable. Do not winsorize valid long delays or impute missing dates.

## 14. Provisional numeric parameter register

Every numeric policy choice in this table is **PROVISIONAL** until Stage 3 review and lock.

| Parameter | Proposed value | Purpose |
| --- | --- | --- |
| Purchase window | 2018-01-01 inclusive to 2018-07-01 exclusive | Two full quarters |
| Tiny-volume floor | 30 eligible seller–orders | Minimum assessability |
| Coverage floor | 95% | Avoid selection from missing outcomes |
| Comparator sufficiency | 20 other sellers; 1,000 total eligible seller–orders | Avoid a tiny baseline |
| Comparator block sufficiency | 200 eligible seller–orders per block | Support repetition comparison |
| Full-window elevation | At least 3 percentage points above comparator | Require practical magnitude |
| Minimum late volume | 5 late seller–orders | Avoid rate-only enrollment |
| Repetition | At least 10 eligible and 2 late in each block; each block LFR strictly above its comparator | Require recurrence |
| Handoff support | At least 3 supporting orders and at least 50% of all late orders | Require operational fit |
| Handoff evaluability | At least 90% of single-seller late orders | Avoid selective supporting evidence |
| Capacity implementation | Integer \(C=20\) | Operationalize “about 20” as a hard ceiling |
| Available analytical slots | \(S=C\) for the simulation | Assumes no already occupied slots |
| Severe-delay reporting band | More than 7 calendar days | Diagnostic severity |

The approximately thirty-day plan, membership-first logic, no padding, tiny-volume exclusion in principle, and featured-placement exclusion come from the approved brief. The numerical definition of tiny volume and exact integer capacity still require a configuration lock.

No proposed value is claimed to be statistically optimal, validated against business costs, or selected to reproduce a desired cohort.

## 15. Membership decision rule

For a valid, evaluable run, analytical membership is **YES** only if all these gates pass:

1. At least 30 eligible seller–orders.
2. At least 95% measurement coverage.
3. Usable full-window and block comparators.
4. At least five late seller–orders and full-window LFR at least three percentage points above the seller-excluded comparator.
5. In each block, at least ten eligible seller–orders, at least two late seller–orders, and LFR strictly above that block's comparator.
6. All handoff-support and handoff-evaluability requirements in section 8.

All numbers above are **provisional**. Equality passes every “at least” condition. Equality fails the “strictly above” block condition.

Otherwise membership is **NO**, with every failed gate retained. “Insufficient evidence” is distinguished from “observed pattern does not meet the bar.” A globally invalid run has no publishable membership judgment; do not convert a failed run into a table of NO decisions.

There is no severity-only override, automatic top-twenty rule, minimum required enrollment count, or capacity-driven threshold relaxation.

## 16. Ranking and hard-cap application

Rank only YES members, using:

1. Descending excess late-order burden \(e_s=k_s-n_s p_{-s}\).
2. Descending handoff_support_n.
3. Descending late_n.
4. Descending eligible_n.
5. Ascending seller identifier using a specified bytewise ordering.

The first measure describes excess observed late seller–orders relative to the comparator; it is not a forecast of preventable deliveries.

Use exact rational comparisons for the first ranking key; do not rank rounded percentages or floating-point displays. Freeze identifier collation so SQL and R resolve ties identically.

Select the first \(\min(S,Q)\), where \(Q\) is the number of qualifying sellers and \(S\) is the available-slot configuration, bounded from zero through \(C\).

If actual ongoing plans already occupy capacity, operations must supply the authoritative available-slot integer before release. Do not infer current occupancy from Olist or subtract guessed commitments.

Derived action codes:

- ENROLL_RECOMMENDED: qualifies and selected within available slots.
- STANDARD_CAPACITY: qualifies but is outside available slots.
- STANDARD_NOT_QUALIFIED: does not qualify under the evidence rule.

These are analytical recommendations, not records that enrollment occurred. Rank, qualification, and action remain separate columns.

## 17. Sensitivity and measurement risks

Prespecify one-at-a-time checks, each recalculating the relevant reference set, membership, and capacity ranking:

- Volume floor 20 and 50 versus 30.
- Full-window excess threshold 2 and 5 percentage points versus 3.
- Timestamp lateness versus calendar-date lateness, with all lateness-dependent quantities recomputed.
- Single-seller orders only for the outcome and reference.
- Coverage 90% and 99% versus 95%.
- Handoff-support share one-third and two-thirds versus one-half.

These alternatives are **provisional stress tests**, not a menu from which to choose the desired enrollment count. They do not override the primary action.

Report membership changes, selected-set overlap, rank movements around capacity, and reasons. A change in selected sellers is a review flag, not proof that either definition is correct.

Material risks include sparse volume, dependence among orders, comparator dominance by large sellers, common shocks, promised-date quality, missingness, survivorship among delivered orders, multiseller attribution, historical staleness, and the handoff proxy's limited causal meaning.

## 18. Operational interpretation and thirty-day follow-up

For each selected seller, the evidence packet should identify the repeated late-delivery pattern, supporting handoff examples, alternative explanations, and a concrete issue for the seller's corrective path.

Operations should document the seller's stated cause, corrective steps, check-in dates, ownership, and plan start/end in a separate operational register. These are requested operational records, not invented source columns.

For a future live plan, monitor customer-delivery lateness, unresolved overdue orders, cancellations, promise-date changes, and handoff timeliness using current operational data. The historical extract does not supply plan exposure or preserve all status transitions.

A thirty-day plan can finish before all purchases made during it have mature delivery outcomes. Separate the process review at plan end from the later outcome readout.

Do not claim causal improvement from a simple before/after rate change. Do not impose an RCT, learning cohort, or minimum experiment size on this operational enrollment decision.

## 19. Non-executable Stage 4 blueprint

1. Verify schema mappings, temporal conventions, keys, source version, and source coverage.
2. Lock the parameter register, available slots, and specification identifier.
3. Freeze a common source snapshot accessible to both extraction paths.
4. Implement SQL A independently from the specification to produce the judged seller table and audit outputs.
5. Implement SQL B as the raw projection package defined below, without eligibility or judgment calculations.
6. Provide only B and the frozen specification/configuration to the R(B) builder.
7. In R(B), validate raw records, reconstruct seller–orders, compute all measures and gates, and rank/select.
8. Freeze A and R(B) outputs with hashes before the reconciliation process reads both.
9. Reconcile, diagnose any differences at the source-record level, correct the responsible path or specification, and rerun both affected outputs.
10. Release a decision-ready evidence packet only after reconciliation and substantive review pass.

This is a specification for later implementation. No SQL, R, enrollment execution, or messaging is performed in Design A.

## 20. SQL A contract — judged seller table

**Inputs:** independently accessed frozen source tables and the locked specification/configuration. A must not read B-derived judgments or R(B) outputs.

**Primary output grain:** exactly one row per seller in the validated seller universe. No prefilter to qualifying sellers.

**Required content:**

| Field group | Required contents |
| --- | --- |
| Identity | Seller ID, specification ID, window boundaries, snapshot ID |
| Population | Candidate delivered count, eligible count, excluded count, exclusion-reason counts, coverage numerator/denominator |
| Primary outcome | late_n, eligible_n, exact LFR pair, display LFR, on-time count |
| Alternative outcome | Timestamp late count and rate pair; date/timestamp disagreement count |
| Repetition | Eligible and late counts for each block |
| Reference | Comparator seller count, late and eligible totals overall and by block |
| Fit | Single-seller late count, evaluable handoff late count, supporting handoff count |
| Decision | Each gate, membership yes/no, all reason codes, primary reason |
| Capacity | Exact excess-burden score pair, qualifier rank or null, \(C\), \(S\), selected flag, action code |
| Audit | Run validity and source-quality flags |

Coverage and share fields must retain count pairs, not just decimals. Expected source fields and these explicitly derived output names must not be confused.

Include separate audit outputs for raw-table counts, duplicates, orphan records, cohort exclusions, status distribution, and unique-order totals. Optional descriptive intervals and severity statistics may be delivered in a companion table; they cannot alter the core decision contract.

Primary reason precedence: no eligible volume; below volume floor; coverage failure; insufficient comparator; materiality failure; repetition failure; handoff evaluability failure; handoff support failure; qualified. Capacity reasons are recorded separately.

## 21. SQL B contract — raw lower-grain evidence package

SQL B means one independently produced extraction package with three required relations:

- **B_orders:** raw projection of all order records in the frozen snapshot, preserving required identity, status, purchase, actual-delivery, estimated-delivery, and handoff fields.
- **B_items:** raw projection of all item records in the same snapshot, preserving order/item/seller keys and shipping deadlines.
- **B_sellers:** raw projection of all seller records in the snapshot, preserving seller identity and any approved seller attributes.

Use separate files or equivalent separate relations with one manifest. This explicit package avoids losing sellers with no orders, orders with no items, or orphan items in a joined-only dump. It is not A with columns removed.

Extract the full snapshot of the required columns, not just in-window delivered orders. R(B) must own the cohort filter, date parsing, exclusions, association deduplication, and classifications. If technical volume limits require narrowing, revise this contract before extraction and preserve the complete audit universe.

Preserve duplicate rows and invalid values for independent validation. B may serialize and project source columns; it must not supply seller aggregates, eligibility flags, late flags, comparator totals, membership, ranks, or actions.

A transport row ordinal is allowed solely for traceability; label it as extraction metadata, not an invented source business key.

Manifest: source and snapshot identity, extraction timestamp, schema/type mappings, row counts, column order, text encoding, delimiter and quoting rules, null encoding distinct from empty text, temporal precision, timezone convention, and file hashes. No silent row limits or truncation.

Optional raw dimension files can support diagnostics, but the three required relations and locked configuration must suffice to reconstruct every primary judgment. If a required operational-fit field is absent, report the block rather than fabricating a column.

## 22. R(B) contract — independent reconstruction

**Permitted inputs:** B's required raw relations, their manifest, the frozen specification/configuration, and approved optional raw dimensions for optional diagnostics.

**Forbidden inputs:** A, A-derived intermediate files, A's baseline totals, its enrollment list, V1 seller decisions, and any reconciliation feedback before the first R(B) output is frozen.

R(B) must independently:

- Validate source keys, types, referential integrity, and row counts.
- Reconstruct seller–order associations and the full seller universe.
- Apply the window, status, date-quality, and chronology rules.
- Calculate calendar-date and timestamp outcomes.
- Rebuild candidate counts, exclusions, block counts, and handoff evidence.
- Rebuild the reference set and seller-excluded comparator totals.
- Evaluate gates using exact comparisons.
- Rank only qualifying sellers and apply available capacity.
- Emit the same judged seller schema as A, plus independent audit and lineage outputs.

Represent LFR canonically as its integer numerator and denominator, with an explicit null representation for denominator zero. Use exact integer/rational arithmetic for threshold and ranking decisions. Choose safe numeric types during implementation; do not let large cross-products silently overflow.

For the three-percentage-point gate, compare the corresponding integer cross-products after scaling by 100 rather than comparing rounded rates. Use the same approach for 95%, 90%, and 50% boundaries.

R(B) may derive descriptive Wilson intervals, severity statistics, and diagnostic tables from B. Those outputs do not feed back into membership unless the specification is formally revised.

Reading A after the R(B) result is frozen belongs to the separate reconciliation process, not to the R(B) computation.

## 23. Reconciliation, acceptance, assumptions, and blockers

**Exact reconciliation requirements:**

- Identical seller key sets, specification, snapshot, configuration, and window.
- Exact integer equality of late_n and eligible_n for every seller.
- Exact equality of the canonical LFR numerator/denominator pair, including null behavior.
- Exact equality of gate inputs, comparator totals, block counts, handoff counts, membership, rank, selected flag, and action.
- Identical deterministic tie handling and available-capacity application.
- Matching additive exclusions and source-audit totals.

Floating-point display LFR is not the acceptance authority. If exported, compare a standardized decimal display separately; matching rounded percentages never compensates for mismatched counts.

**Required invariants:** nonnegative counts; late count no greater than eligible count; candidate delivered count equals eligible plus excluded count; block counts sum to whole-window counts; handoff support no greater than handoff evaluable no greater than single-seller late no greater than total late; selected count equals the smaller of available slots and qualifying count; no nonqualifier selected; no padding.

**Required semantic fixtures before acceptance:** same-day delivery after a midnight estimate; delivery exactly on estimate; missing dates; zero eligible volume; a seller with multiple items in one order; a multiseller order; window endpoints; threshold equality; missing handoff evidence; exact ranking ties; zero qualifiers; more qualifiers than slots; and zero available slots.

**Mismatch protocol:** fail reconciliation, retain both outputs, identify seller and source-record differences, and classify the cause as source mismatch, extraction, transformation, numeric precision, rule ambiguity, or ranking. Never edit counts or copy one branch's judgment merely to obtain agreement. A rule change requires a new specification version and affected outputs to be rebuilt independently.

Agreement verifies implementation consistency, not the truth of the measurement design. A separate substantive review must assess attribution, uncertainty, source completeness, threshold suitability, and whether the proposed corrective path fits the evidence.

**Assumptions and limitations:** the proposed six-month window, volume floor, reference requirements, evidence gates, and exact capacity are unvalidated policy proposals. The simulated extract is historical; it cannot establish seller conditions at a current VP meeting. Outcome rates concern delivered orders and seller associations. Handoff evidence is a proxy. Optional confounders are not fully controlled. Neither expected plan benefit nor actual enrollment is observed.

**Blockers to Stage 4 decision-ready execution:** verified schema and handoff semantics; a frozen accessible data snapshot and observation-boundary assessment; acceptance of provisional parameters and exact available capacity; and resolution of material source-quality defects if discovered. These do not prevent delivery of this complete proposal, but prevent claiming executable readiness or an evidence-backed enrollment list today.

**Blockers to exact framework-title matching and metadata:** the original numbered framework headings and current chat URL were not supplied; the exact model identifier is not exposed. No substitute is invented.

**Completion declaration:** Design A is complete, with all sections 1–23 present, and is not truncated. No V1 enrollment list was used. No executable SQL/R was written. Grok and DeepSeek were not opened. Stop after this Design A.
