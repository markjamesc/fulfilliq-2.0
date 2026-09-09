# SQL_B_NOTES — FulfillIQ 2.0 AI 2 SQL B

**Spec:** `fulfilliq-2.0-stage3-candidate-v0.2.1`  
**Date:** 2026-09-08 (America/Chicago)  
**Role:** Notes for the raw three-relation package only. Not SQL A. Not R(B).  
**Sources used:** `00_STAGE4_SHARED_PACKET.md` §4, §8.3; `Stage_03_Measurement_Design.md` §7.1, §9, §11.2, §21.

---

## 1. Assumptions

1. **Schema name.** Stage 3 refers to the live `fulfilliq` schema. All three source tables are qualified as `fulfilliq.<table>`.
2. **Source table names.**
   - `raw_sellers` — named in both packets.
   - `raw_order_items` — named in Stage 3 §7.2 / §9.
   - `raw_orders` — **not named**. Assumed by parallel `raw_*` naming so that “all order records in the frozen snapshot” have a source. If DESCRIBE shows `orders`, `raw_order`, or another name, map that table here; do not guess further columns.
3. **Carrier-handoff column.** Packets require “carrier-handoff timestamp” / “carrier receipt” on orders and never name the physical column. Assumed source name: `order_delivered_carrier_date`, projected under that same name. PENDING-DB: verify presence and semantics (carrier receipt between purchase and customer delivery). If the live column name differs, rename the source reference only; do not invent a substitute metric.
4. **Status column.** Packets require order status / delivered status and never name the physical column. Assumed source name: `order_status`, projected as-is.
5. **No timezone conversion.** Packets lock “source recorded convention; no speculative conversion.” Session `time_zone = +00:00` is only for the extract-audit clock (`extraction_timestamp`), not for rewriting business timestamps.
6. **No joins.** The three projections are independent full-table reads. R(B) performs association later. This avoids dropping orphans and avoids manufacturing a seller–order dump (explicitly rejected as the SQL B contract).
7. **No row filter.** Full snapshot, including non-delivered, out-of-window, duplicate, and invalid rows. Window, delivered status, chronology, and coverage are R(B)/A work, not B.
8. **No quantity column.** Packets name no item quantity field. Item grain is `(order_id, order_item_id)` — one source row per item line. Price/freight/product columns are not named in the Stage 3/4 B contract and are omitted so the script does not invent schema. If Stage 4 DESCRIBE confirms such columns and R diagnostics need them, add them as raw pass-throughs in a new extract version; they must not carry late/eligible flags.
9. **Seller attributes.** B_sellers minimum is `seller_id` + source-version audit. City/state/zip, featured, and catalog fields are not projected. Featured/catalog remain out of business scope and PENDING-DB; do not invent them.
10. **Audit fields.** Packets require source-version audit on B_sellers and snapshot identity on the package manifest. Physical source audit columns are not named. The script injects extract-time literals: `specification_id`, `snapshot_id`, `source_version`, `extraction_timestamp`. Replace `PENDING_STAGE4_*` before a real freeze. These are package lineage, not business judgments.
11. **Collation.** Connection collation `utf8mb4_0900_bin` preserves bytewise identity for later seller_id ranking in R(B). It does not sort or rank inside B.
12. **CREATE TABLE AS.** Copies source types for business columns. Does not cast business timestamps. Does not COALESCE nulls to empty text.

---

## 2. Source-to-projection mapping

| Projection | Source (assumed/named) | Source column | B column | Origin |
| --- | --- | --- | --- | --- |
| B_orders | `fulfilliq.raw_orders` (assumed) | `order_id` | `order_id` | Named (identity) |
| B_orders | same | `order_status` | `order_status` | Required “status”; name assumed |
| B_orders | same | `order_purchase_timestamp` | `order_purchase_timestamp` | Named (purchase / cohort clock) |
| B_orders | same | `order_delivered_carrier_date` | `order_delivered_carrier_date` | Required carrier-handoff; name assumed |
| B_orders | same | `order_delivered_customer_date` | `order_delivered_customer_date` | Named (actual customer delivery) |
| B_orders | same | `order_estimated_delivery_date` | `order_estimated_delivery_date` | Named (estimated / promised delivery) |
| B_orders | extract literals | — | `specification_id`, `snapshot_id`, `source_version`, `extraction_timestamp` | Package audit |
| B_items | `fulfilliq.raw_order_items` (named) | `order_id` | `order_id` | Named (item/order key) |
| B_items | same | `order_item_id` | `order_item_id` | Named (raw item grain) |
| B_items | same | `seller_id` | `seller_id` | Named (seller key) |
| B_items | same | `shipping_limit_date` | `shipping_limit_date` | Named (item shipping deadline) |
| B_items | extract literals | — | `specification_id`, `snapshot_id`, `source_version`, `extraction_timestamp` | Package audit |
| B_sellers | `fulfilliq.raw_sellers` (named) | `seller_id` | `seller_id` | Named (minimum identity) |
| B_sellers | extract literals | — | `specification_id`, `snapshot_id`, `source_version`, `extraction_timestamp` | Required source-version audit |

R(B) can independently compute DATE-rule lateness, timestamp-rule lateness, window, delivered status, chronology, single- vs multi-seller association, and handoff support from these columns plus the frozen spec. B itself computes none of that.

---

## 3. Join assumptions

- **None inside SQL B.** No INNER/LEFT join across orders, items, and sellers.
- Unavoidable later (R(B), not this script): items to orders on `order_id`; items to sellers on `seller_id`. Those joins must be loss-auditing (retain unmatched keys) because packets forbid silent drop of orphans and forbid silent dedupe of business-key collisions.
- Multi-seller and multi-item cardinality is visible only after R(B) reconstructs `(seller_id, order_id)` from B_items + B_orders. B does not emit `multi_seller_order_flag`.

---

## 4. Validation checklist (package freeze)

Run after the three `CREATE TABLE` statements, against the same session snapshot identity. Record results in the SQL B manifest. Do not “fix” rows to pass.

**Identity / snapshot**

- [ ] `@snapshot_id` and `@source_version` are no longer `PENDING_*`
- [ ] `specification_id`, `snapshot_id`, `source_version` are identical on every row of all three tables
- [ ] `extraction_timestamp` is recorded and matches the manifest extract time
- [ ] Source schema is `fulfilliq` (or mapped name is written in the manifest)

**Schema verification (PENDING-DB — halt if required fields missing)**

- [ ] `raw_orders` (or mapped name) exists and has: `order_id`, `order_status`, `order_purchase_timestamp`, `order_delivered_customer_date`, `order_estimated_delivery_date`, carrier-handoff column
- [ ] Carrier-handoff physical name confirmed; semantics = carrier receipt, not a invented proxy
- [ ] `raw_order_items` has: `order_id`, `order_item_id`, `seller_id`, `shipping_limit_date`
- [ ] `raw_sellers` has non-null `seller_id` column
- [ ] No featured/catalog columns invented
- [ ] No payments, reviews, products, or raw geolocation tables joined

**Row fidelity**

- [ ] `B_orders` row count = `raw_orders` row count
- [ ] `B_items` row count = `raw_order_items` row count
- [ ] `B_sellers` row count = `raw_sellers` row count
- [ ] Duplicate `(order_id)` / `(order_id, order_item_id)` / `seller_id` values, if any, are preserved (no DISTINCT)
- [ ] Null business timestamps remain null (not empty string, not sentinels)
- [ ] No in-window or `order_status = 'delivered'` filter applied

**Contract hygiene**

- [ ] No column named late, eligible, coverage, membership, rank, action, LFR, handoff_support, or comparator
- [ ] No aggregates, GROUP BY, HAVING, window functions
- [ ] Not a pre-joined seller–order dump
- [ ] Column order documented; encoding utf8mb4; binary connection collation noted
- [ ] File/table hashes taken after freeze for recon with R(B)

**Seller-key verification (Stage 4 must do this before R(B) proceeds)**

- [ ] `seller_id` present on B_sellers
- [ ] Uniqueness of `seller_id` on B_sellers verified (duplicates, if found, are a run-blocking DQ finding — do not silently dedupe in B)

---

## 5. What this package deliberately does not do

- Does not apply the 2018-01-01 / 2018-09-01 purchase window or halves
- Does not classify delivered vs nondelivered
- Does not compare actual vs estimated (DATE or timestamp)
- Does not build seller–order grain or leave-one-out comparators
- Does not evaluate volume, coverage, materiality, persistence, handoff, N4, or N5
- Does not assign membership, rank, selected, or action
- Does not treat simulation S = 20 or live occupancy

Those belong to SQL A and R(B) after this freeze.