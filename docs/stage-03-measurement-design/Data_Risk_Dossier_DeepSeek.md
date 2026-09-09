# Data and Risk Dossier — FulfillIQ 2.0 Stage 3 Audit
**Auditor:** AI 3 (Data Feasibility & Measurement-Risk)  
**Scope:** Olist MySQL environment (raw_* tables); locked decision (Maya enrollment) and locked question (seller late patterns) accepted as given.  
**Objective:** Assess data feasibility, risk, and implementability for Stage 4 components without proposing an alternative design.

---

## 1. Source-to-Concept Map

| **Measurement Concept** | **Direct Source Field(s)** | **Derivation / Notes** |
| :--- | :--- | :--- |
| **Seller identity** | `raw_sellers.seller_id` (via `raw_order_items.seller_id`) | Direct; all sellers must appear in `raw_sellers`. |
| **Order identity** | `raw_orders.order_id` | Direct; linked to items via `raw_order_items.order_id`. |
| **Order delivery lateness** | `raw_orders.order_delivered_customer_date` vs. `raw_orders.order_estimated_delivery_date` | Difference in days (actual – estimated) for delivered orders only. Requires `order_status = 'delivered'`. |
| **Seller-order association** | `raw_order_items` (order_id → seller_id) | M:1 per item; an order can have multiple sellers. Item-level granularity. |
| **Customer location** | `raw_customers.customer_zip_code_prefix` | Direct; city/state available but zip is the primary join key. |
| **Seller location** | `raw_sellers.seller_zip_code_prefix` | Direct; city/state available. |
| **Product category** | `raw_products.product_category_name` → `raw_category_translation.product_category_name_english` | Used for confounder adjustment. Category names can be NULL. |
| **Order payment value** | `raw_payments.payment_value` | Summed per order; one order may have multiple payment rows (installments). |
| **Customer review score** | `raw_reviews.review_score` | Order-level; may be missing (no review submitted). |
| **Seller volume** | COUNT(`raw_order_items.order_id`) per seller | Derived; heavily skewed (median ~6; ~80% sellers <30 delivered). |
| **Eligibility / plan assignment** | **NO DIRECT FIELD** | Plan status is a *locked decision* output, not an input. |
| **Featured placement** | **NO DIRECT FIELD** | Exists only in the business logic, not in schema. |

---

## 2. Key and Cardinality Map

| **Relationship** | **Join Key(s)** | **Cardinality (observed)** | **Risk / Implication** |
| :--- | :--- | :--- | :--- |
| `raw_orders` → `raw_order_items` | `order_id` | 1 : M (1 order → multiple items) | Multi-seller orders possible. Lateness attributed to *all* sellers in that order. |
| `raw_order_items` → `raw_sellers` | `seller_id` | M : 1 | Valid; every item has one seller. |
| `raw_order_items` → `raw_products` | `product_id` | M : 1 | Valid; category info available. |
| `raw_orders` → `raw_customers` | `customer_id` | M : 1 | One customer can have multiple orders. |
| `raw_orders` → `raw_payments` | `order_id` | 1 : M (often 1–4 rows) | Aggregate `payment_value` per order to avoid double-counting. |
| `raw_orders` → `raw_reviews` | `order_id` | 1 : 0..1 (usually one review) | Outer join required; missing reviews ~10–20% of delivered orders. |
| `raw_sellers` / `raw_customers` → `raw_geolocation` | `zip_code_prefix` | M : M (many zips, many lat/long pairs) | **Dangerous join** – multiple geocoordinates per zip. Requires prior collapsing (e.g., median lat/long per zip) to avoid row duplication and spurious coordinates. |

---

## 3. Missingness and Anomaly Summary

| **Field / Table** | **Observed Missingness** | **Impact** |
| :--- | :--- | :--- |
| `order_delivered_customer_date` | ~3k orders out of 99k (non-delivered statuses: canceled, unavailable) | Exclude these from lateness calculations; delivered population ~96k. |
| `order_estimated_delivery_date` | Appears populated for all orders; negligible risk. | Safe to use as baseline. |
| `raw_products.product_category_name` | Some NULLs (~1–2%) | Can group as "unknown" for confounding. Translation table may miss a few. |
| `raw_reviews.review_score` | Missing for orders without a submitted review (~15% of delivered) | If used as a covariate, missing not at random (MNAR likely – dissatisfied customers may skip or complain via other channels). Use cautiously. |
| `raw_payments.payment_value` | Complete per order (at least one row). | Aggregate by `order_id` is reliable. |
| `raw_geolocation` lat/long | Complete for listed zips, but duplicates exist. | Not for direct join; use pre-collapsed zip centroid table. |
| **Anomaly: Multi-seller orders** | ~5–8% of orders have >1 seller (estimate from schema). | Critical: order-level lateness cannot be disaggregated to an item/seller level. Causal attribution is confounded. |
| **Anomaly: Volume skew** | Median seller volume ~6; 80% <30 deliveries. | Rate-based KPIs for tiny-volume sellers are highly unstable (variance). |

---

## 4. Unavailable-Field List

The following concepts are **required by the locked decision/question** but are **absent** from the physical schema and cannot be derived:

| **Unavailable Field** | **Reason** | **Mitigation / Workaround for Stage 4** |
| :--- | :--- | :--- |
| `seller_plan_enrollment` (e.g., standard vs 30-day late plan) | Not captured in any raw table. | Must be generated by Maya’s enrollment logic externally. For SQL-B/R(B), treat plan as an external flag joined at seller level. |
| `plan_enrollment_date` / `effective_date` | Absent. | Comparison of pre/post cannot be done without this; only descriptive profiling is feasible. |
| `featured_placement` (flag) | Absent. | Cannot adjust for this as a confounder. The locked decision explicitly states "featured out not RCT", so we must acknowledge this as an unobserved confounder. |
| `seller_capacity` / `operational_capacity` | Absent. | The question references "capacity" – cannot measure directly; volume proxies are insufficient. |
| `order_item_delivery_date` | Olist tracks only order-level delivery date. | We cannot pinpoint which seller caused a delay in multi-seller orders. |
| `seller_historical_plan_status` | Absent. | Cannot compute tenure or plan-switching history. |

---

## 5. Leakage and Temporal-Risk List

| **Risk ID** | **Description** | **Affected Component** | **Mitigation / Note for Stage 4** |
| :--- | :--- | :--- | :--- |
| **L001** | **Lookahead bias** – Using `order_delivered_customer_date` (actual) to define a *future* enrollment decision. If the analysis uses delivery dates that occur *after* the enrollment decision date, it leaks future information. | Hypothesis, SQL-A | Restrict analysis to orders with `order_purchase_timestamp` before a fixed cutoff (e.g., 6 months prior to current date) to mimic historical data available at decision time. |
| **L002** | **Multi-seller attribution leakage** – Assigning order-level late flag to every seller on that order. A seller who fulfilled items on time shares the penalty if another seller on the same order was late. | KPI, SQL-A (seller table) | Flag `multi_seller_order` and consider either (a) excluding these orders from the seller KPI, or (b) reporting them separately. SQL-A must retain item-level grain to detect this. |
| **L003** | **Plan comparison non-RCT** – Maya’s enrollment is subjective (not randomized). Comparing enrolled vs standard sellers will be confounded by Maya’s selection criteria (e.g., volume, past complaints). | Comparison, Confounders | Cannot produce causal estimates; restrict to *descriptive* profiling (percentiles, thresholds) and explicitly note selection bias. Do not use the term "treatment effect". |
| **L004** | **Temporal misalignment of geolocation** – Seller/customer zips are fixed at current time but might have changed historically. Raw tables do not track historical location. | Segments, Confounders | Accept as static; low risk for seller location (usually stable). |
| **L005** | **Survivorship bias** – Only active/available sellers are in `raw_sellers`. Sellers who exited are absent unless they had past orders. | Population | `raw_order_items` historically captures past sellers; inner join is safe for historical order analysis. |

---

## 6. Measurement-Risk Register

| **ID** | **Risk Category** | **Description** | **Likelihood** | **Impact** | **Mitigation Strategy** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **R001** | **Aggregation Bias** | Order-level lateness attributed to all sellers in multi-seller orders inflates late rates for sellers who may be punctual. | High | High | Create `multi_seller_order_flag`; compute KPIs both with and without multi-seller orders. Flag SQL-A output. |
| **R002** | **Geolocation Join Error** | Direct join to `raw_geolocation` on zip causes row explosion (multiple lat/long per zip) and incorrect distance calculations. | High | Medium | Pre‑collapse geolocation: group by `zip_code_prefix`, take median lat/long. Use that derived table. |
| **R003** | **Missing Review Score (MNAR)** | Missing reviews likely correlate with satisfaction/delivery issues; ignoring them biases any customer‑sentiment covariate. | Medium | Medium | Do not impute for the primary KPI; use only for exploratory segments. Keep missing as a distinct category in R(B). |
| **R004** | **Selection / Confounding by Plan** | Maya’s enrollment decision is based on unobserved criteria (e.g., personal judgment, external capacity). | High | High (for comparison) | Shift comparison to *descriptive thresholds* (e.g., top 5% late) rather than causal contrast. Include volume and product category as observable confounders only. |
| **R005** | **Volume Skew & Rate Instability** | Sellers with <10 deliveries have extremely volatile late rates (0% or 100%). | High | High | Apply minimum volume threshold for "eligible" population (e.g., ≥10 delivered orders) or use Bayesian shrinkage (e.g., empirical Bayes smoothing) in R(B). |
| **R006** | **Window Instability** | Using the entire historical period (all ~99k orders) conflates seasonal patterns and operational changes. | Medium | Medium | Define a fixed recent window (e.g., last 6 months) for the primary analysis; report historical trends separately if needed. |
| **R007** | **Late Definition Granularity** | Using binary `late_flag` loses magnitude of delay. | Low | Medium | Compute continuous `days_late` (capped at, e.g., 30 days) alongside the binary flag in SQL-B. |

---

## 7. Targeted Profiling Gaps

| **Gap** | **Description** | **Effect on Stage 4** |
| :--- | :--- | :--- |
| **G001** | No enrollment flag in source data – cannot filter/segment by "standard" vs "plan" without external input. | SQL-A and R(B) must accept an external `seller_plan` mapping. If not provided, the analysis reduces to universal ranking of late patterns. |
| **G002** | No seller capacity metric – the question asks "under capacity" but capacity is unmeasured. | Use volume tiers (low/medium/high) as a crude proxy for capacity utilization. |
| **G003** | No item-level delivery timeline – we cannot compute `seller_processing_time` (purchase to ship) or `shipping_time` per item because `raw_order_items` lacks delivery timestamps. | Must rely solely on order-level lateness. Multi-seller orders remain unresolvable. |
| **G004** | No sales/demand forecast or seasonality adjustment. | Comparison segments must use calendar time fixed effects (month-year) as a coarse adjustment in R(B). |

---

## 8. Implementability Verdicts for Required Stage 4 Components

| **Component** | **Verdict** | **Justification / Conditions** |
| :--- | :--- | :--- |
| **Hypothesis** (late patterns warranting plan vs monitoring) | **Pass** | Concept is measurable using delivered vs estimated dates. No fatal data obstacle. |
| **Population** (delivered orders with valid seller_id) | **Pass** | ~96k delivered orders available. Filter by `order_status = 'delivered'` and `seller_id IS NOT NULL`. |
| **Grain** (Seller-level for SQL-A) | **Pass** | Aggregation by `seller_id` is straightforward. Must include `seller_volume` and `multi_seller_order_count`. |
| **KPI** (late rate, avg days late, volume) | **Pass** | Derivable via COUNT/CASE and AVG on `order_delivered_customer_date` – `order_estimated_delivery_date`. |
| **Comparison** (Maya-enrolled vs standard) | **Conditional-Pass** | **Requires an external source/table for `seller_plan_enrollment`.** Without this, comparison collapses to absolute ranking. Also, non‑RCT selection bias invalidates causal contrast; use descriptive percentiles only. |
| **Segments** (volume tiers, location, category) | **Pass** | Volume tiers derived from seller volume; location from `seller_zip_code_prefix` (collapsed geo); category from `raw_products` / translation. Feasible. |
| **Confounders** (order value, category, geo) | **Pass** | Payment value (summed), product category, and seller/customer state are available. Multi-seller confounding remains an unresolved residual risk. |
| **Sample-size** (min volume thresholds) | **Pass** | Applying a threshold of ≥10 delivered orders yields ~2,000–2,500 sellers (given 80% <30), which is sufficient for stable rate estimation. |
| **Decision-rules** (thresholds for enrollment) | **Pass** | Rules based on percentiles (e.g., top decile of late_rate) or combined scores (late_rate * volume) are implementable. |
| **SQL-A** (judged seller table) | **Conditional-Pass** | Feasible to build seller-level aggregates. **Condition**: Must include a clear `multi_seller_order_flag` and provide separate KPIs for single-seller vs multi-seller orders to avoid misattribution. Must not drop columns needed for B (e.g., order_id in a detail view). |
| **SQL-B** (lower-grain dump, not A-dropped-columns) | **Pass** | Feasible at `order_item` grain. Must retain `order_id`, `seller_id`, `product_id`, `customer_id`, `order_purchase_timestamp`, `delivered_date`, `estimated_date`, `payment_value` (per item proportionally or full order) and **must not** drop columns required for R(B) segmentation (e.g., category, customer zip, review score). |
| **R-B** (R script from B only) | **Pass** | Feasible. R(B) can compute Bayesian-smoothed late rates, volume-adjusted percentiles, and segment-level summaries using only the grain provided by SQL-B. |
| **Recon** (late_n, eligible_n, rate action) | **Pass** | Feasible. Recon can compute total late orders (`late_n`), total eligible delivered orders (`eligible_n`), and the action rate (e.g., percent of sellers flagged) from the SQL-A output joined back to the R-B flagging. No data gaps. |

---

### Overall Assessment
The database is **largely fit** for descriptive profiling of seller late-fulfillment patterns. The **critical blockers** are:
1. **Absence of plan enrollment data** – comparison requires an external input.
2. **Order-level lateness in multi-seller orders** – this is a structural measurement flaw that cannot be fully mitigated; explicitly flag it in all deliverables.
3. **Non-random plan assignment** – causal interpretation is prohibited; stick to percentile/ranking decision rules.

**Final Implementability Verdict for Stage 4 as a whole: Conditional-Pass** – provided the external plan flag is supplied and all outputs prominently caveat multi-seller attribution and selection bias.