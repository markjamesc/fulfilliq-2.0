# FulfillIQ 2.0 — Stage 3 Measurement Design B

**Role:** AI 2 Independent Counter-Designer and Methodological Critic  
**Artifact:** Design B (complete independent measurement design + five counter-design extras)  
**Engine / schema:** MySQL 8.0, schema `fulfilliq` (Olist Brazil raw tables)  
**Stage 4 status:** not begun. No live queries. No executable SQL or R in this file.  
**Threshold rule used throughout:** every numeric cutoff that is not a locked capacity figure is labeled **provisional**.  
**Locked texts:** copied exactly. Not rewritten.

---

## A. Document control

| Item | Value |
| ---- | ----- |
| Product | FulfillIQ 2.0 |
| Stage | 3 — measurement design (numeric cutoffs exist only to serve enrollment) |
| Design ID | Design B |
| Author role | Independent counter-designer / methodological critic |
| Decision owner | Maya Chen, Director of Marketplace Seller Operations (fictional) |
| Decision timing | mid-month VP ops cycle; ~30-day plan length |
| Concurrent capacity | about 20; no padding; enroll fewer if fewer meet the bar |
| Experiment status | ops process, **not** an RCT |
| Featured placement | out of this design; not a database field |
| Plan-administration fields | out of this design; do not invent them |
| Offboarding | later VP recommendation; not an output of Stage 3 or Stage 4 |

**What Design B is allowed to do:** choose grain, KPI, comparison, confounder handling, anomaly policy, and decision rules that convert the locked question into a yes/no membership call plus a cap-aware rank.

**What Design B is not allowed to do:** rewrite the approved decision or locked question; invent featured-placement or plan-status columns; use 95% or the Data Profile descriptive 8.11% late share as a cut; claim the 30-day plan will causally reduce lateness; pad the roster to fill 20 seats.

---

## B. Approved decision (exact text; not rewritten)

Maya Chen decides which sellers if any to enroll on ~30-day late-fulfillment improvement plan vs standard terms to reduce late customer deliveries under ~20 concurrent cap no padding enroll fewer if fewer meet bar by mid-month VP ops; tiny-volume stay standard; featured out; ops not RCT; Stage 3 sets numeric cutoffs only to serve enrollment.

---

## C. Locked question (exact text; not rewritten)

Under locked concurrent capacity about 20 with tiny-volume on standard which sellers if any have late-fulfillment patterns that warrant documented 30-day improvement plan with closer ops check-ins and seller corrective path rather than ordinary marketplace monitoring?

---

## D. Membership rule (exact intent; operationalized below, not rewritten)

yes/no first; if more than ~20 qualify rank within cap; else enroll fewer.

**Design B reading of that rule (interpretation, not a rewrite):**

1. First produce a Boolean *qualify* flag per seller. Qualify is not “top 20.”
2. If `n_qualify = 0`, enroll nobody. Continue ordinary monitoring.
3. If `1 ≤ n_qualify ≤ ~20`, enroll exactly those sellers.
4. If `n_qualify > ~20`, rank the qualifiers and enroll only the top ~20. The remainder stay off the plan (watch / standard, per rules). Do not raise capacity.
5. Tiny-volume sellers never qualify. They stay on standard terms.

---

## E. Business constraints and decision authority

**Maya can:** leave a seller on standard terms / ordinary monitoring; enroll a seller on the documented 30-day improvement plan (closer ops check-ins + seller corrective path, administered outside the database); ask account management to call; recommend offboarding later to the VP.

**Maya cannot:** terminate contracts; change fees; add concurrent-plan capacity; invent a US or 2026 extract; run an RCT; treat featured placement as a table field.

**Confirmed constraints used by Design B:**

- Data universe is the nine `fulfilliq` raw tables. Do not add tables that were not built.
- Lateness clock source is delivered `order_delivered_customer_date` versus `order_estimated_delivery_date`.
- Seller identity comes from `raw_order_items.seller_id`, validated against `raw_sellers`.
- Seller volumes are badly skewed: median delivered volume is about 6; about 80 percent of sellers sit under 30 delivered orders. Tiny-volume stay standard.
- Reviews, payments, products, category translation, customers, and raw geolocation are **not** on the primary enrollment path.
- Always show the denominator next to every rate.
- Stage 3 numeric cutoffs exist only to serve enrollment, not to declare an SLA.

**Working time window (Stage 3 design choice, not a rewrite of the locked question):** purchases with `order_purchase_timestamp >= '2018-01-01 00:00:00'` and `< '2018-09-01 00:00:00'`. Reason: in this extract, September–October 2018 are not a usable “last month,” and 2016 is a different marketplace year. Purchase time, not delivery time, defines window membership. A 31 August purchase delivered in September remains in if delivered. **Provisional as a 2.0 window default** if a later handoff locks a different complete window.

---

## F. Population, eligibility, and out-of-scope

### F.1 Eligible order (parent)

An order is eligible when all of the following hold:

- `order_status = 'delivered'`
- purchase timestamp in the working window
- at least one `raw_order_items` row
- `order_delivered_customer_date` is not null
- `order_estimated_delivery_date` is not null

Non-delivered statuses are structurally missing delivery dates. They are out of population. They are not scored late.

### F.2 Eligible seller-order

Parent order eligible; `seller_id` present; `seller_id` exists in `raw_sellers`.

### F.3 Enrollment-eligible seller (volume gate)

Seller has usable denominator `eligible_n >= 30` **after** the required exclusions in Section L. **Provisional.** Tiny-volume (`eligible_n < 30`) stay standard and are not ranked.

Applying 30 to the post-exclusion denominator is a Design B tightening: the 30 that supports a rate should be the 30 that actually enter the rate. If Maya meant 30 raw delivered rows before exclusions, Stage 4 must print both counts and stop if membership flips.

### F.4 Out of population

- any status other than delivered
- purchases outside the working window
- 775 item-less orders (full-extract count; live DB may differ)
- sellers who only appear on ineligible orders
- featured-placement status, plan-administration status (not columns)

---

## G. Analytical grain (Design B working choice)

| Layer | One record | Use in Design B |
| ----- | ---------- | --------------- |
| Item | `(order_id, order_item_id)` | Source of `seller_id`, `price`, `freight_value`, `shipping_limit_date`. Collapse immediately. Never count items as deliveries. |
| Seller-order | `(seller_id, order_id)` | **Working measurement grain.** Late flag, duration, anomaly flags, multi-seller flag. This is SQL B. |
| Seller-window | `seller_id` over the working window | **Working decision grain.** Rates, denominators, qualify yes/no, rank, action. This is SQL A. |

**Why seller-order, not item and not order-only:** customer delivery exists once per order. Items fan out. Counting items would clone the same late/on-time flag and inflate both numerator and denominator for multi-item sellers. Counting the order once and dropping extra sellers would hide shared-clock contamination. Seller-order keeps one clock per seller participation.

**Attribution limit (not optional):** when two sellers share an order, both inherit the same customer-delivery and estimate timestamps. The database cannot say which seller made the order late. Design B therefore computes an all-order LFR and a single-seller-only LFR, and treats a flip as inconclusive rather than as enrollment.

---

## H. Hypothesis

**Business hypothesis.** Among sellers who clear the delivered-only rule, the working window, and the provisional volume floor, some sellers show a *pattern* of late customer delivery versus the printed estimate that is (i) worse than same-window peers who also clear the floor, (ii) large enough in late count that it is not a two-event fluke, (iii) not confined to one half of the window, and (iv) not an artifact of shared multi-seller clocks or timestamp-precision choice. Those sellers, and only those sellers, warrant the documented 30-day improvement plan rather than ordinary monitoring.

**Operational null (not a p-value).** After grain control, exclusions, and guardrails, the qualify set is empty inside the ~20 cap. Maya enrolls nobody.

**Expected relationship.** Higher LFR is more support for *qualification*. Among qualifiers, higher *excess late count* (defined in I.2) is more support for *rank within the cap*. The unit compared is the seller, built from seller-orders.

**This hypothesis does not claim** the seller is the sole cause of delay. Carrier time after handoff, customer distance, and estimate-setting are not seller columns.

---

## I. KPI framework and metric contracts

### I.1 Role table

| Role | Name | Direction | Threshold status |
| ---- | ---- | --------- | ---------------- |
| Primary | Seller Late-Fulfillment Rate (LFR) | higher is worse | no signed percent; peer bar is data-derived in Stage 4; **provisional** construction in J |
| Ranking companion | Excess late count (ELC) | higher is worse for customers | no signed cut; used only after qualify = yes |
| Supporting | `eligible_n`; `late_n`; on-time count; Wilson lower bound of LFR; median days vs estimate; median days late among lates; split-window LFR; single-seller LFR; multi-seller order share; item revenue (`price`); seller state | context, guardrails, narrative | no approved numeric cuts except the provisional volume floor and the provisional late-count hygiene |
| Guardrail | volume floor; late-count hygiene; staffing cap; always print `late_n / eligible_n`; anomaly concentration; split-window stability; attribution flip; date-vs-timestamp action flip; live-DB reconciliation; no 95% back-door | permit / block / downgrade | floor and hygiene = **provisional**; cap = locked |

Ship-limit miss rate (`order_delivered_carrier_date` vs `shipping_limit_date`) is a **diagnostic only**. It cannot enroll. Reviews, payments, categories, customers, and raw geolocation stay off the primary path.

### I.2 Primary KPI — Seller Late-Fulfillment Rate

| Field | Definition |
| ----- | ---------- |
| Metric name | Seller Late-Fulfillment Rate (LFR) |
| Metric type | Primary |
| Business purpose | Answers which in-scope sellers have a late-fulfillment *pattern* that can support plan membership versus ordinary monitoring |
| Analytical grain | seller-order for the flag; seller-window for the rate |
| Eligible population | enrollment-screening sellers’ usable seller-orders (delivered, window, both delivery timestamps, parent has items, seller in `raw_sellers`) |
| Numerator | `late_n` = count of those seller-orders classified late under the working lateness rule |
| Denominator | `eligible_n` = count of those seller-orders |
| Formula | `LFR = late_n / eligible_n`. Report as a proportion and as the fraction `late_n / eligible_n`. Also report percent to one decimal for the brief. |
| Source tables | `raw_orders`, `raw_order_items`, `raw_sellers` |
| Source columns | `order_id`, `order_status`, `order_purchase_timestamp`, `order_delivered_customer_date`, `order_estimated_delivery_date`, `order_item_id`, `seller_id`, `seller_state`, `seller_city` |
| Time window | working window in E |
| Exclusions | Section L |
| Duplicate handling | collapse items to one `(seller_id, order_id)` before counting. An order with two sellers yields two seller-orders, same late flag |
| Missing-value handling | null actual or estimate → not in LFR; counted in QA |
| Directionality | higher is worse |
| Threshold status | **unresolved as a business percent.** Peer bar is data-derived. 95% and 8.11% are not used. |
| Decision use | *qualify* screen, together with hygiene and guardrails. Does not enroll by itself. |
| Known limitation | shared clock on multi-seller orders; estimate-setting is not a seller column; LFR ignores severity |

**Working lateness rule (Design B default, not a Maya lock):** late if and only if `DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)`.

Reason: in the Data Profile, `order_estimated_delivery_date` min/max sit at `00:00:00`. A raw timestamp comparison treats a same-calendar-day afternoon delivery as late against a midnight promise. The printed promise in this extract behaves like a calendar day.

**Required twin (not optional):** Stage 4 must also compute timestamp lateness `order_delivered_customer_date > order_estimated_delivery_date`. If the *action* (not merely the rate) flips, the seller is inconclusive until Maya picks precision.

This is **not** adoption of the profile’s 8.11% full-extract figure.

### I.3 Ranking companion — Excess late count (ELC)

| Field | Definition |
| ----- | ---------- |
| Metric name | Excess late count |
| Metric type | Ranking companion (not a second primary for *qualify*) |
| Business purpose | The locked purpose is to reduce late *customer deliveries*. Among sellers who already qualify on rate-pattern grounds, rank by how many extra late seller-orders they produced versus the marketplace expectation. This stops a 40% of 30 seller from outranking a 16% of 400 seller when both cleared the peer screen. |
| Formula | `ELC = late_n − (eligible_n × LFR_mkt_weighted)` where `LFR_mkt_weighted` is the seller-order-weighted LFR among sellers with `eligible_n >= 30` |
| Grain | seller-window |
| Threshold status | no cut. Rank key only. **Provisional** as a ranking device. |
| Decision use | after qualify = yes, when `n_qualify > ~20` |
| Known limitation | still uses the same late flag, so it inherits estimate-setting and carrier confounders |

### I.4 Wilson lower bound of LFR (guardrail input)

| Field | Definition |
| ----- | ---------- |
| Metric name | Wilson lower bound of seller LFR, 80% interval |
| Metric type | Guardrail input |
| Business purpose | At `n = 30`, a raw 20% rate is compatible with ordinary marketplace performance. A lower bound that still exceeds the marketplace weighted LFR is stronger evidence of a pattern. |
| Formula | Wilson score interval lower bound on `late_n / eligible_n` at **provisional** `z = 1.2816` (80% two-sided). Design B does not treat this as a significance test and does not publish p-values. |
| Threshold status | **provisional.** Used as a qualify conjunct: `Wilson_LB > LFR_mkt_weighted`. |
| Decision use | blocks qualify when the point LFR is high only because n is small |
| Known limitation | interval level is a design choice, not a Maya lock |

### I.5 Eligible volume

Count of usable seller-orders at seller-window grain. Same exclusions as LFR. Direction: higher is more stable evidence, not better fulfillment. Threshold: `eligible_n >= 30` **provisional** on the post-exclusion denominator. Below 30 → standard terms, not ranked.

### I.6 Late count and late-count hygiene

`late_n` as in I.2. **Provisional hygiene:** a seller cannot auto-qualify with `late_n < 4`. Reason: three late events at n = 30 is a 10% point rate that can appear by chance under an ~8% marketplace base. Hygiene is not an SLA. It is a Design B working default. **Still unresolved** as a Maya number.

### I.7 Median calendar days versus estimate

Median of `DATE(actual) − DATE(estimate)` in days on duration-clean seller-orders; also the median on the late subset only. Narrative and tie-break after ELC. Cannot enroll by itself. Duration screens park the 166 carrier-before-purchase and 23 delivery-before-carrier rows (full-extract counts; live DB may differ) **out of duration metrics**. Those rows stay in LFR if they remain scorable. **Provisional** treatment.

### I.8 Split-window LFR

Same LFR formula on purchases in Jan–Apr 2018 versus May–Aug 2018. Purpose: the locked question asks for a *pattern*, not a one-half spike. **Provisional working default:** auto-qualify requires that the seller is not a one-half spike as defined in N. Thin halves do not get a free pass; they get watch / inconclusive.

### I.9 Single-seller LFR

LFR restricted to orders with exactly one distinct `seller_id`. If all-order LFR would qualify and single-seller LFR would not, action = inconclusive. No 50% contamination cut is confirmed.

### I.10 Seller item revenue

Sum of `raw_order_items.price` on that seller’s items on eligible orders. Optional second column `price + freight_value`. Do not join `raw_payments`. Eyes-open exposure only. No kill-rule. High GMV does not block enrollment and does not force it.

---

## J. Comparison groups and segments

**Primary comparison group.** Sellers with usable `eligible_n >= 30` after exclusions, same window, same lateness rule. Call this the *peer set*.

Stage 4 must compute, as **data-derived benchmarks, not SLAs**:

- seller-order-weighted marketplace LFR on the peer set (`LFR_mkt_weighted`)
- equal-weighted mean seller LFR on the peer set
- min, P25, median, P75, P90, P95, max of seller LFR on the peer set
- the same percentiles inside each volume band below

**Design B working peer screen (ranking device, not an SLA; provisional construction):**

A seller *rate-clears* when all of the following hold:

1. `eligible_n >= 30` (provisional floor)
2. `late_n >= 4` (provisional hygiene)
3. `LFR >= P75` of the seller’s **own volume band** (see bands)
4. `LFR > LFR_mkt_weighted` of the pooled peer set
5. `Wilson_LB > LFR_mkt_weighted` (provisional interval)

**Volume bands (descriptive peers, provisional cuts):** 30–49 / 50–99 / 100+. Band P75 is used because a pooled P75 is dominated by noisy n ≈ 30 sellers and will both (a) over-qualify small noisy rates and (b) under-qualify large sellers whose 12% on 400 orders is more damaging than 18% on 32 orders.

**Capacity rule after the screen.** The rate-clear set is not yet the enroll set. Apply guardrails in N. The survivors are the *qualify* set. Then:

- if qualify set > ~20, rank by `ELC` desc, then `LFR` desc, then `late_n` desc, then `eligible_n` desc, then `seller_id` asc
- take the top ~20 as enroll; remainder of the qualify set = watch
- if qualify set ≤ ~20, enroll the qualify set; do not pad

**Not used as comparison baselines:** 2016; Sep–Oct 2018; SP-only; review-score strata; payment-type strata; product category; ZIP coordinates; the profile 8.11%; a 95% on-time target.

**Descriptive segments only:** `seller_state`; volume band; multi-seller vs single-seller; purchase half-window; late-severity bands (on-time / 1–3 / 4–7 / 8–30 / >30 days vs estimate).

---

## K. Confounders and interpretation risks

1. **Promise-date tightness (most important — see Q.4).** The estimate is not a seller column. A seller with a tight printed promise can look “late” while a seller with a slack promise looks “on time” at the same physical speed. LFR confounds operations with SLA printing.
2. **Shared delivery clock** on multi-seller orders.
3. **Carrier time after handoff.** `order_delivered_carrier_date` is diagnostic. Customer lateness can be last-mile.
4. **Customer geography versus seller geography.** Distance is not measured. Raw geolocation is forbidden on the primary path. Customer state may be noted only as a confounder, never as a join that changes LFR.
5. **Small-n rates** even at 30. This is why Design B adds Wilson_LB and late-count hygiene.
6. **One extreme delay** (profile max purchase→customer on the full extract is on the order of 200 days). Medians, not means, for severity.
7. **Calendar versus timestamp precision** flipping action.
8. **SP concentration** dominating an unsegmented list. State is descriptive, not a filter.
9. **Item-revenue versus payment-value** if someone later joins payments after items (fan-out). Forbidden on this path.
10. **Live MySQL ≠ source-file profile.** Critical QA failure kills the list.
11. **Window composition.** Eight months is not interchangeable with a 30-day ops plan. Historical 2018 pattern ≠ 2026 performance.
12. **Selection into delivery.** Scoring only delivered orders conditions on completion. Cancelled / unavailable orders are out by lock, which can hide sellers who fail by never finishing.

Design B does not “control” these with a regression. It flags them, splits where the schema allows (single-seller LFR, split-window, state slices), and refuses to enroll when the flag is the whole story.

---

## L. Data-quality and anomaly rules

Do not hide counts. Stage 4 QA must print each exclusion’s row count. Full-extract counts below are anchors, not live guarantees.

| Issue | Treatment |
| ----- | --------- |
| Item / payment / review fan-out | Pre-aggregate items to seller-order **before** seller roll-up. Do not join payments or reviews on the primary path. If a later sensitivity uses them, aggregate those tables to `order_id` first. |
| Small seller samples (median ~6; ~80% under 30) | Volume floor; always print n; tiny-volume stay standard. |
| 8 delivered orders missing customer-delivery date | **Exclude from LFR**; QA count. They cannot be scored. **Provisional** if Maya wants a delivered-unknown bucket. |
| 166 carrier-before-purchase (full extract) | **Keep in LFR** if actual and estimate exist; **exclude from duration**; **flag**. **Provisional.** |
| 23 delivery-before-carrier (full extract) | Same as 166. |
| 4 item rows with 2020 `shipping_limit_date` | Exclude those **item rows** from the ship-limit diagnostic only. Do not drop the parent order from LFR on this alone. |
| Partial 2016 and Sep–Oct 2018 | Out of the working window. |
| Duplicate / multiple reviews | Unused. If ever used: one row per `order_id` first. |
| Multiple payments | Unused. If ever used: aggregate to `order_id` before joining. Never sum `payment_value` after an item join. |
| Multiple items | Collapse to seller-order. |
| Missing / untranslated categories | Unused. |
| Geolocation many-rows-per-ZIP and outliers | Unused. |
| Zero freight / zero weight / zero payment | Do not drop from LFR. |
| Context-package grand total 1,450,922 | Use **1,550,922** as the nine-table source sum. Individual table counts in the context package stand. |
| Live vs source | Stage 4 MySQL proceeds only after differences are explained. Critical gate fail → no enrollment list. |

---

## M. Sample-size and stability rules

- Ranking and qualify require usable `eligible_n >= 30`. **Provisional.**
- Sellers below 30 appear in a volume-suppressed appendix (counts only). Action = standard terms.
- Always publish `late_n / eligible_n`.
- Do not treat full-extract coverage figures (“627 sellers at 30 orders” on the whole history) as the expected size of the Jan–Aug 2018 n≥30 set.
- **Provisional** late-count hygiene: `late_n >= 4` to auto-qualify.
- **Provisional** Wilson lower-bound conjunct as in I.4.
- Split-window: one-half-only heat blocks auto-enroll (Section N).
- Date vs timestamp action flip → inconclusive.
- Live MySQL critical QA fail → whole list inconclusive.
- No confidence interval is an SLA. No p-value enrolls or blocks by itself.

---

## N. Decision rules and actions

Apply in order. Stop at the first decisive row.

**N0. Global gate.** Live MySQL fails critical reconciliation → no list. Action for every seller: wait. Guardrail: live-DB.

**N1. Volume gate.** `eligible_n < 30` → `action = standard_terms`. Not ranked. Tiny-volume stay standard.

**N2. Hygiene gate.** `eligible_n >= 30` and `late_n < 4` → `action = standard_terms` (ordinary monitoring). **Provisional hygiene.** These sellers are not “cleared as good”; they simply do not present a VP-defensible pattern count.

**N3. Peer / Wilson screen.** Among sellers who pass N1–N2:

- rate-clear if LFR ≥ band P75 **and** LFR > pooled `LFR_mkt_weighted` **and** Wilson_LB > `LFR_mkt_weighted`
- else `action = standard_terms`

Peer percentiles are **data-derived in Stage 4**. They are not 95% and not 8.11%.

**N4. Attribution guardrail.** If all-order view would qualify and single-seller LFR would not rate-clear under the same numeric bars (or single-seller n is too thin to compute a rate and multi-seller share is the majority of the seller’s eligible_n) → `action = inconclusive`.

**N5. Precision guardrail.** If date-rule action and timestamp-rule action disagree on enroll-versus-not → `action = inconclusive`.

**N6. Stability guardrail.** Define a half as “hot” when that half’s LFR ≥ that seller’s band P75 **and** that half’s `eligible_n_half >= 10` (**provisional** half-floor). Define a half as “cold” when that half’s LFR ≤ peer-set median LFR and `eligible_n_half >= 10`. If one half is hot and the other is cold → `action = watch` (not enroll). If either half has `eligible_n_half < 10`, do not treat the split as exonerating; leave the seller in the qualify pool but flag `split_window_thin = 1` for the brief.

**N7. Qualify set.** Sellers who pass N1–N6 with a residual enroll-ward direction form the qualify set (`qualify = yes`).

**N8. Capacity.**

- If `n_qualify = 0` → enroll nobody. Publish the LFR distribution. Do not lower the bar to manufacture 20 names.
- If `1 ≤ n_qualify ≤ ~20` → `action = enroll` for the qualify set.
- If `n_qualify > ~20` → rank by ELC desc, LFR desc, late_n desc, eligible_n desc, seller_id asc. Top ~20: `action = enroll`. Other qualifiers: `action = watch`. Do not pad. Do not expand the cap.

**N9. Supporting metrics** (duration, ship-limit diagnostic, state, revenue) may change the *conversation* (AM call, watch intensity). They must not enroll by themselves.

**Actions by result**

| Result | Meaning | Sufficient for the decision? | Action |
| ------ | ------- | ---------------------------- | ------ |
| Qualify = yes, inside cap | Pattern Maya can document | Yes, as working design | enroll (plan lives in ops, not in a DB field) |
| Qualify = yes, outside cap after rank | Same pattern, no seat | Partial | watch |
| Attribution flip | Shared clock may be the story | No | inconclusive |
| Date vs timestamp flip | Precision is the story | No | inconclusive |
| One-half spike | Not a pattern | No | watch |
| Rate-clear fails, n≥30 | Ordinary versus peers | Yes | standard_terms |
| n<30 | Too little evidence | Yes for *not ranking* | standard_terms |
| Empty qualify set | No separable pattern | Yes | standard_terms for all; show distribution |
| Live-DB critical fail | Measurement not trustworthy | Yes for *not listing* | wait |

Featured placement and offboarding are **not** outputs of these rules.

---

## O. Stage 4 contracts

No executable SQL. No executable R.

### O.1 Engine and tables

- Engine: MySQL 8.0, schema `fulfilliq`. Record `VERSION()`, `sql_mode`, session and global time zone.
- Primary-path tables: `raw_orders`, `raw_order_items`, `raw_sellers`.
- Primary-path columns:
  - `raw_orders`: `order_id`, `order_status`, `order_purchase_timestamp`, `order_delivered_carrier_date`, `order_delivered_customer_date`, `order_estimated_delivery_date`
  - `raw_order_items`: `order_id`, `order_item_id`, `seller_id`, `shipping_limit_date`, `price`, `freight_value`
  - `raw_sellers`: `seller_id`, `seller_city`, `seller_state`
- Not on the primary path: `raw_payments`, `raw_reviews`, `raw_products`, `raw_category_translation`, `raw_geolocation`, `raw_customers`.

### O.2 Mandatory pre-aggregations (blueprint only)

1. Collapse `raw_order_items` to one row per `(order_id, seller_id)`: item count, sum `price`, sum `freight_value`, min/max `shipping_limit_date`.
2. Count distinct `seller_id` per `order_id` (multi-seller flag).
3. Filter orders first (`delivered` + working window + both timestamps). Join the item collapse after that filter, never before.
4. Attach `raw_sellers`.
5. Flag late under **both** date and timestamp rules. Flag anomalies.
6. Roll up to seller-window last.

Safe join order: filter orders → aggregate items to seller-order → join → attach sellers → flags → seller roll-up.

### O.3 Contract SQL A — judged seller table

SQL A emits one row per `seller_id` in the working decision grain. It is the judged table. It may contain peer benchmarks (repeated as columns or as a one-row companion), qualify flags, rank, and `action`.

**Minimum SQL A columns:**

- `seller_id`, `seller_state`, `seller_city`
- `eligible_n`, `late_n`, `on_time_n`
- `lfr` (date-rule primary), `lfr_timestamp`
- `late_n_ts` (timestamp numerator; same `eligible_n` unless a twin-specific exclusion is documented)
- `wilson_lb` (date-rule)
- `elc`
- `median_days_vs_estimate`, `median_days_late`
- `eligible_n_jan_apr`, `late_n_jan_apr`, `lfr_jan_apr`
- `eligible_n_may_aug`, `late_n_may_aug`, `lfr_may_aug`
- `eligible_n_single`, `late_n_single`, `lfr_single_seller`
- `multi_seller_order_n`, `multi_seller_order_share`
- `item_revenue`
- `anomaly_n`
- `volume_band`
- `lfr_mkt_weighted`, `band_p75_lfr`, `peer_p75_lfr`, `peer_p90_lfr`, `peer_median_lfr` (benchmarks may be attached)
- `qualify` (0/1)
- `rank_if_qualify`
- `action` (`enroll` / `watch` / `standard_terms` / `inconclusive` / `wait`)
- `action_reason`

SQL A is **not** the object R is required to rebuild from.

### O.4 Contract SQL B — lower-grain dump, not A, with judged columns dropped

SQL B is a seller-order dump. It is **not** SQL A. It must not carry judged columns that would let R copy the decision instead of rebuilding it.

**SQL B grain:** one row per `(seller_id, order_id)` that is a usable seller-order under Section F, plus a documented thin set of excluded-but-flagged rows needed for QA (those rows must carry `in_lfr_denom = 0`).

**SQL B required columns:**

- `seller_id`, `order_id`
- `seller_state`, `seller_city`
- `order_purchase_timestamp`
- `order_delivered_customer_date`, `order_estimated_delivery_date`
- `order_delivered_carrier_date` (diagnostic; nullable)
- `late_date` (0/1, only where `in_lfr_denom = 1`)
- `late_ts` (0/1, only where `in_lfr_denom = 1`)
- `days_vs_estimate` (nullable if parked from duration)
- `n_sellers_on_order`
- `single_seller_flag` (1 if `n_sellers_on_order = 1`)
- `item_n`, `item_revenue`, `freight_sum`
- `anomaly_carrier_before_purchase`, `anomaly_delivery_before_carrier`, `anomaly_other`
- `in_lfr_denom` (0/1)
- `in_duration` (0/1)
- `half_window` (`jan_apr` / `may_aug`)

**SQL B must drop (do not emit):** `action`, `action_reason`, `qualify`, `rank_if_qualify`, `elc`, `wilson_lb`, `lfr`, `lfr_timestamp`, `volume_band`, all peer-percentile columns, all seller-window rates.

Those dropped columns are exactly what R(B) has to rebuild.

### O.5 Contract R(B) — rebuild from B only

R reads SQL B and **only** SQL B (plus this design). It does not read SQL A. It does not reconnect to MySQL. It does not invent rows.

R must:

1. Restrict to `in_lfr_denom = 1` for rate construction.
2. Aggregate to seller-window.
3. Rebuild `late_n`, `eligible_n`, date-rule LFR, timestamp-rule LFR.
4. Rebuild volume band, peer percentiles on the n≥30 set, `LFR_mkt_weighted`, Wilson_LB, ELC.
5. Rebuild split-window and single-seller metrics from B columns.
6. Re-apply Sections J and N exactly, producing `qualify`, `rank_if_qualify`, `action`, `action_reason`.

No forecast. No RCT estimator. No p-value decision rule. No ML.

### O.6 Exact reconciliation contract

R(B) must reconcile to SQL A on every seller that appears in both, for at least:

| Key | Rule |
| --- | ---- |
| `late_n` | exact integer match |
| `eligible_n` | exact integer match |
| `LFR-or-equivalent` | date-rule `late_n / eligible_n` matches SQL A `lfr` within a documented rounding tolerance of 1e-12 relative, or both null |
| `action` | exact string match |

Any mismatch is a **critical** Stage 4 failure. Do not enroll from a broken recon. If SQL A and R(B) disagree, neither list ships.

Also recon the obvious roll-up identities on B itself: `sum(late_date) = late_n`, `sum(in_lfr_denom) = eligible_n` at seller grain.

### O.7 QA gates (halt on critical)

- uniqueness of `raw_orders.order_id` and `(order_id, order_item_id)`
- seller-order uniqueness on `(seller_id, order_id)` in B
- join-expansion: B row count on `in_lfr_denom = 1` equals distinct `(order_id, seller_id)` in items for eligible orders
- null actual/estimate in the LFR denom = 0
- non-delivered rows in the LFR denom = 0
- nine table row counts versus profile (corrected total 1,550,922)
- n printed for every rate
- no output labeled 95% SLA
- date vs timestamp action-flip count printed
- tiny-volume sellers have `action = standard_terms` and `qualify = 0`
- enroll count ≤ ~20
- enroll count < 20 if `n_qualify < 20` (no padding)
- SQL A vs R(B) recon on `late_n`, `eligible_n`, LFR-or-equivalent, `action`

### O.8 Stage 4 must not

- write executable analysis back into this Stage 3 file
- join payments, reviews, products, categories, customers, or raw geolocation on the primary path
- use 2016 or Sep–Oct 2018 as a baseline
- treat 8.11% or 95% as cuts
- rank sellers with `eligible_n < 30`
- invent featured-placement or plan-status fields
- ship SQL A as the only artifact; B and R(B) are required

---

## P. Assumptions, open questions, and what Design B refuses to lock

**Copied locks / confirmed constraints:** concurrent capacity about 20; no padding; tiny-volume on standard; featured out; ops not RCT; delivered customer date vs estimate as the lateness source; seller via items; Stage 3 cutoffs exist only to serve enrollment.

**Accepted provisional (Design B):** `eligible_n >= 30` after exclusions; late-count hygiene `late_n >= 4`; Wilson 80% lower bound conjunct; half-window floor `eligible_n_half >= 10`; volume bands 30–49 / 50–99 / 100+; band-P75 as the seller’s peer bar.

**Stage 3 working defaults that are not Maya locks:** seller-order measurement grain; seller-window decision grain; DATE lateness as primary with timestamp twin; 8 missing customer dates out of LFR; 166/23 out of duration and in LFR if scorable; ELC as the within-cap rank key; attribution flip → inconclusive; one-half spike → watch; Jan–Aug 2018 working window.

**Data-derived in Stage 4:** marketplace weighted LFR; band and pooled percentiles; actual n≥30 headcount; date-vs-timestamp action-flip count; qualify-set size; enroll-set size.

**Still unresolved / Maya must choose if list membership is sensitive:** official percent target; date vs timestamp as the business lock; whether 30 is before or after exclusions; whether 166/23 may stay in LFR; whether hygiene 4 is acceptable; whether Wilson 80% is acceptable; whether band-P75 plus ELC rank is acceptable versus a single pooled P90; live MySQL versus source-file profile.

---

## Q. Five counter-design extras

These are the critic layer. They are not silent replacements of Sections G–N. They are the alternatives Design B judges strongest. Stage 4 implements Sections G–N unless Maya explicitly swaps in one of these.

### Q.1 Strongest alternative KPI

**Excess-late-count as the *primary* qualify metric, not only the rank key.**

Formula: `ELC = late_n − eligible_n × LFR_mkt_weighted`.

Qualify if `ELC >= ELC_P75` of the n≥30 peer set (provisional) and `late_n >= 4` (provisional), then cap-rank by ELC.

**Why this is the strongest alternative.** The approved purpose is to reduce late customer deliveries, not to equalize seller percentages. LFR treats 6/30 and 80/400 as the same 20% pattern. They are not the same customer problem. ELC-as-primary puts the 80-late seller on the plan first.

**What it costs.** A high-rate tiny-but-above-floor seller (12 late of 32) can miss the plan even though the locked question is also about a *pattern* Maya would document. ELC-primary is impact-first; LFR-primary is pattern-first. Design B kept LFR as primary *because the locked question says “patterns”* and used ELC only after yes/no membership. Swapping Q.1 in would change that philosophy.

**Stage 4 sensitivity (not a second official list):** print the ELC-primary enroll set beside the official Design B enroll set and count Jaccard overlap. Do not average the two lists.

### Q.2 Strongest alternative grain

**Seller-month panel, then a persistence rule up to seller-window.**

One record = `(seller_id, purchase_calendar_month)` for months with at least one eligible seller-order. Monthly LFR = monthly late_n / monthly eligible_n. Decision grain remains the seller, but membership requires the late pattern in **at least two distinct months** with monthly `eligible_n >= 5` (**provisional**) and the window LFR still above the peer bar.

**Why this is the strongest alternative.** The locked question wants a pattern that warrants a 30-day corrective path. Two calendar halves can still hide a single brutal month. Month grain is the finest persistence grain the eight-month window can support without turning into an order-level case review.

**What it costs.** Many n=30 sellers will have months of 3–6 orders. Monthly rates become noisier than the window rate. SQL B would need a month key (already recoverable from `order_purchase_timestamp`). R(B) would rebuild a panel, which the current complete-skip seller-window engine does not assume.

**Rejected weaker grains:** item grain (clones the order clock); order grain with a single “primary seller” (hides shared-clock sellers instead of flagging them); seller-day (sparsity; overfit).

### Q.3 Strongest alternative comparison

**Volume-band P75 is already Design B’s working comparison. The strongest *further* alternative is a shrink-to-marketplace comparison: qualify only if Wilson_LB > LFR_mkt_weighted, and drop percentile ranks entirely.**

No P75, no P90, no “top 20 of a flat cluster.” The marketplace weighted LFR is the only peer. Wilson_LB supplies the small-n brake. Capacity still caps at ~20 via ELC rank.

**Why this is the strongest alternative comparison.** Percentiles on a skewed LFR distribution are an artifact of how many noisy n=30 sellers exist, not of a fulfillment standard Maya would write down. A P75 of 10% and a P90 of 14% are sample-order statistics. They move when the floor moves. A marketplace-rate hurdle plus shrinkage does not.

**What it costs.** If the whole peer set is mediocre, Wilson_LB > marketplace mean will still qualify the noisy right tail — unless hygiene and the cap do the rest. If the whole peer set is excellent, almost nobody qualifies, which the “do not pad” rule already accepts.

**Rejected weaker comparisons:** forced top-20 by raw LFR (pads); “above portfolio average” with no shrinkage (admits a long noisy tail); SP-only peers (violates all-states constraint); 95% on-time (unsigned); 8.11% profile share (descriptive, wrong window mix).

### Q.4 Most important confounder

**Estimate-setting / printed-promise tightness.**

The lateness flag is `actual` versus `estimated`. The seller does not own `order_estimated_delivery_date` as a column they set in `raw_sellers`. Two sellers with identical handoff speed receive different LFR if the platform printed different promises. Carrier-after-handoff is real but second: it explains some late flags, it does not systematically re-rank every seller the way a tight versus slack promise does.

**What Design B can do about it without new columns:** (i) keep ship-limit vs carrier as a diagnostic of seller-controlled handoff; (ii) print median days-versus-estimate including negatives, so a seller who is usually three days early and occasionally late looks different from a seller who is usually one day late; (iii) refuse to call LFR “seller fault.” What Design B cannot do: back out the counterfactual estimate. That would be a new model, not this enrollment design.

### Q.5 Design choice most likely to change the enrollment decision

**How the peer bar is built after the volume floor — specifically pooled P75 with a raise-to-P90 if over cap, versus Design B’s band-P75 + Wilson_LB + ELC rank.**

Evidence from the prior FulfillIQ 1.0 execution (historical, not 2.0 results): a clean pooled P75 set exploded past 20 and forced a P90 raise; guardrails then cut the operable enroll set again. Changing only the percentile, or changing only whether percentiles are pooled versus banded, moved more names than changing DATE versus timestamp for most sellers.

For 2.0, the same lever remains the largest. The volume floor is the second-largest lever (~80% of sellers are already excluded by “tiny-volume stay standard”). Date-versus-timestamp precision is third: it will flip a minority of borderline sellers and is already an inconclusive guardrail.

**Practical implication for Maya.** Before Stage 4 writes names, she should pick one sentence:

- “Qualify on band-P75 + Wilson vs marketplace, rank leftover seats by excess lates” (Design B working), or
- “Qualify on pooled P75, raise to P90 if the clean set exceeds ~20, do not pad” (1.0-style), or
- “Qualify on Wilson_LB > marketplace LFR only, rank by ELC” (Q.3).

Those three sentences will not produce the same 20 names. Everything else in this file moves fewer seats.

---

## R. Stage 4 handoff checklist (Design B)

1. Reconcile live MySQL to profile anchors (nine counts, corrected 1,550,922, keys, orphans, status mix, 8 missing customer dates, 166, 23, four 2020 ship-limits).
2. Build SQL B at `(seller_id, order_id)` with the columns in O.4 and **without** judged columns.
3. Build SQL A at seller-window with the columns in O.3.
4. Compute LFR under both date and timestamp rules. Print action-flip count.
5. Apply n≥30 on the usable denominator. Print every rate as `late_n / eligible_n`.
6. Compute pooled and band peer distributions. Apply Design B screens. Rank by ELC inside the cap. Do not pad.
7. Attach split-window, single-seller, revenue, state, anomaly flags.
8. Output `enroll` / `watch` / `standard_terms` / `inconclusive` / `wait`. No 95% label. No featured field. No plan-status field.
9. Run R(B) from SQL B only. Exact recon on `late_n`, `eligible_n`, LFR-or-equivalent, `action`.
10. Halt on critical QA failure.

No Stage 4 analysis was performed in this document. No executable SQL or R is included.

---

## S. Independent-critic close

Design B accepts the locked decision, the locked question, the cap, the tiny-volume rule, and the “ops not RCT” clause without negotiation. It refuses three habits that make enrollment lists look more precise than they are:

1. Treating a pooled percentile as if it were a fulfillment standard.
2. Treating a percentage as if it were customer impact.
3. Treating a single eight-month rate as if it were already a documented *pattern*.

The working design therefore uses LFR to answer yes/no (pattern), ELC to answer who occupies a scarce seat (impact), Wilson and late-count hygiene to stop n=30 lotteries, split-window and single-seller views to stop spike-and-contamination enrollments, and an explicit SQL A / SQL B / R(B) recon so the judged table cannot drift from the grain that produced it.

If Maya wants a different philosophy, she should swap Q.1, Q.2, or Q.3 in as a named variant — not quietly edit N8 after seeing the names.

**End of Design B.**
