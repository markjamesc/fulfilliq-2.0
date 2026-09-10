-- =============================================================================
-- FulfillIQ 2.0 — SQL B (AI 2 only)
-- =============================================================================
-- Spec version : fulfilliq-2.0-stage3-candidate-v0.2.1
-- Date         : 2026-09-08 (America/Chicago)
-- Engine       : MySQL 8
-- Role         : Independently produced raw three-relation package
--                B_orders + B_items + B_sellers
-- Independence : Must not read SQL A, A intermediates, R(B), V1 decisions,
--                membership/late flags, or recon feedback.
-- Forbidden    : lateness flags, eligibility labels, thresholds, membership,
--                rank, action, COUNT/SUM/AVG/MIN/MAX, GROUP BY, HAVING,
--                DISTINCT, window functions, silent dedupe, window/status
--                membership filters, featured/catalog columns, payments,
--                reviews, products, raw geolocation joins.
-- Grain        : One raw source row in, one projected row out (duplicates
--                and invalids preserved).
-- Snapshot     : Full frozen source snapshot — not in-window / delivered only.
-- =============================================================================

SET NAMES utf8mb4;
SET SESSION collation_connection = 'utf8mb4_0900_bin';
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET SESSION time_zone = '+00:00';

-- Extract-time audit literals (not source business columns; not judgments).
-- Replace PENDING_* values from the frozen-snapshot manifest before run.
SET @specification_id       = 'fulfilliq-2.0-stage3-candidate-v0.2.1';
SET @snapshot_id            = 'PENDING_STAGE4_SNAPSHOT_ID';
SET @source_version         = 'PENDING_STAGE4_SOURCE_VERSION';
SET @extraction_timestamp   = UTC_TIMESTAMP(6);

-- -----------------------------------------------------------------------------
-- Source-table assumptions (see SQL_B_NOTES)
--   Schema          : fulfilliq
--   Orders          : fulfilliq.raw_orders          (ASSUMED name)
--   Order items     : fulfilliq.raw_order_items     (named in Stage 3/4)
--   Sellers         : fulfilliq.raw_sellers         (named in Stage 3/4)
-- Carrier-handoff source column assumed as order_delivered_carrier_date.
-- No timezone conversion. Source recorded convention is preserved as stored.
-- No joins among the three projections.
-- -----------------------------------------------------------------------------


-- =============================================================================
-- B_orders
-- Raw projection of all order records in the frozen snapshot.
-- Required by contract: identity, status, purchase, actual-delivery,
-- estimated-delivery, carrier-handoff fields as present.
-- =============================================================================

DROP TABLE IF EXISTS B_orders;

CREATE TABLE B_orders AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CAST(@specification_id AS CHAR(64) CHARSET utf8mb4)     AS specification_id,
    CAST(@snapshot_id AS CHAR(64) CHARSET utf8mb4)          AS snapshot_id,
    CAST(@source_version AS CHAR(64) CHARSET utf8mb4)       AS source_version,
    @extraction_timestamp                                   AS extraction_timestamp
FROM fulfilliq.raw_orders AS o;

ALTER TABLE B_orders
    COMMENT = 'SQL B raw order snapshot — no eligibility, late, or membership columns';


-- =============================================================================
-- B_items
-- Raw projection of all item records in the frozen snapshot.
-- Required by contract: order/item/seller keys, shipping_limit_date.
-- Quantity: contract names no quantity column; item grain is one source row
-- per (order_id, order_item_id). No invented qty column.
-- =============================================================================

DROP TABLE IF EXISTS B_items;

CREATE TABLE B_items AS
SELECT
    i.order_id,
    i.order_item_id,
    i.seller_id,
    i.shipping_limit_date,
    CAST(@specification_id AS CHAR(64) CHARSET utf8mb4)     AS specification_id,
    CAST(@snapshot_id AS CHAR(64) CHARSET utf8mb4)          AS snapshot_id,
    CAST(@source_version AS CHAR(64) CHARSET utf8mb4)       AS source_version,
    @extraction_timestamp                                   AS extraction_timestamp
FROM fulfilliq.raw_order_items AS i;

ALTER TABLE B_items
    COMMENT = 'SQL B raw item snapshot — no eligibility, late, or membership columns';


-- =============================================================================
-- B_sellers
-- Raw projection of all seller records in the frozen snapshot.
-- Minimum required: seller_id + source-version audit fields.
-- Additional approved attributes omitted pending Stage 4 schema verification
-- (do not invent featured/catalog or geolocation columns).
-- =============================================================================

DROP TABLE IF EXISTS B_sellers;

CREATE TABLE B_sellers AS
SELECT
    s.seller_id,
    CAST(@specification_id AS CHAR(64) CHARSET utf8mb4)     AS specification_id,
    CAST(@snapshot_id AS CHAR(64) CHARSET utf8mb4)          AS snapshot_id,
    CAST(@source_version AS CHAR(64) CHARSET utf8mb4)       AS source_version,
    @extraction_timestamp                                   AS extraction_timestamp
FROM fulfilliq.raw_sellers AS s;

ALTER TABLE B_sellers
    COMMENT = 'SQL B raw seller snapshot — no eligibility, late, or membership columns';


-- =============================================================================
-- End SQL B
-- Next (out of scope for this script): write manifest (row counts, column
-- order, encoding, null encoding, temporal precision, timezone convention,
-- file hashes). Do not compute hashes inside this projection script.
-- =============================================================================