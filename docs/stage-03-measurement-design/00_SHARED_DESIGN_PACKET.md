# Stage 3 Shared Design Packet — FulfillIQ 2.0

**Status:** Input package locked for independent Design A / Design B / Data-Risk Dossier  
**Date:** 2026-09-08 (America/Chicago)  
**Modes:** AI1 ChatGPT Work GPT-6 Astra High = Primary Design A; AI2 Grok Expert = Design B; AI3 DeepSeek DeepThink = Data & Risk Dossier  
**Sources:** Stages 1–2 handoff `10_STAGE_3_MEASUREMENT_DESIGN_HANDOFF.md`; V1 data docs are **read-only empirical context**, not inherited measurement design.

## 1. Approved decision (do not rewrite)

Maya Chen must decide which marketplace sellers, if any, to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms, in order to reduce late customer deliveries under a hard concurrent capacity of about 20 (no padding; enroll fewer if fewer clearly meet the bar), by the mid-month VP ops meeting; tiny-volume sellers stay on standard terms; featured placement is out; enrollment is ops capacity allocation, not an RCT; exact numeric cutoffs are deferred to Stage 3 measurement only where they serve this enrollment.

## 2. Locked analytical question (do not rewrite)

Under the locked concurrent capacity of about 20, with tiny-volume sellers remaining on standard terms, which sellers, if any, have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer operational check-ins and a seller corrective path rather than ordinary marketplace monitoring?

**Membership rule:** Yes/no eligibility first; if more than ~20 qualify, rank qualifiers within the cap; if fewer, enroll fewer with no padding; non-qualifiers stay ordinary monitoring.

## 3. Hard constraints

- Cap ~20 concurrent; no padding
- Tiny-volume → standard terms
- Featured placement / catalog not in DB and out of scope
- Not RCT; not permanent offboarding
- Plan ~30 days = business intervention definition, not a DB field
- Numeric cutoffs MUST be designed here (Stage 3) to serve enrollment — with rationale; provisional thresholds must be labeled provisional, not SLA

## 4. Database context (verified V1 build; same `fulfilliq` MySQL for 2.0)

- MySQL 8, schema `fulfilliq`, Olist CSVs
- Tables: `raw_orders`, `raw_order_items`, `raw_sellers`, `raw_customers`, `raw_products`, `raw_payments`, `raw_reviews`, `raw_category_translation`, `raw_geolocation`
- Primary lateness path uses orders + order_items (+ sellers). Do not invent featured/plan columns.
- Lateness concept available via `order_delivered_customer_date` vs `order_estimated_delivery_date` on delivered orders
- Seller-order grain via items; multi-seller orders possible
- Full schemas: `FulfillIQ_Database_Context_V1_READONLY.md`

## 5. Data profile highlights (empirical; not a locked design)

- ~99k orders; ~96k delivered; seller volumes heavily skewed (median ~6 delivered orders; ~80% of sellers <30 delivered)
- Provisional illustrative lateness (date actual > date estimated) ~8% overall on delivered — **not** a locked KPI
- Geolocation joins dangerous without ZIP collapse
- Profile: `FulfillIQ_Data_Profile_V1_READONLY.md`

## 6. Stage 4 recon requirement (design contracts must support)

- **SQL A:** judged seller KPI / decision table
- **SQL B:** lower-grain dump (seller-order or equivalent) — not A with columns dropped
- **R(B):** rebuild metrics from B only; must not read A
- Exact recon on late_n / eligible_n / LFR (or design-named equivalents) / action

## 7. Independence rule

Do not copy V1 Stage 3/4 thresholds or enroll lists as proof. Redesign from this packet. Do not write executable SQL/R in Stage 3.
