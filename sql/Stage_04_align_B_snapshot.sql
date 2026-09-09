-- =============================================================================
-- Stage_04_align_B_snapshot.sql — align existing B_* snapshot identity
-- =============================================================================
-- Spec version : fulfilliq-2.0-stage3-candidate-v0.2.1
-- Purpose      : UPDATE B_orders / B_items / B_sellers so snapshot_id,
--                source_version, and specification_id match the shared Stage 4
--                freeze identity — without a full B rebuild (e.g. prior run
--                that still has PENDING_* literals).
-- Shared freeze:
--   snapshot_id      : fulfilliq-olist-frozen-2026-09-08
--   source_version   : olist-csv-raw_tables
--   specification_id : fulfilliq-2.0-stage3-candidate-v0.2.1
-- Does not alter business projection columns or row grain.
-- =============================================================================

USE fulfilliq;

SET @a4_align_snapshot_id      = 'fulfilliq-olist-frozen-2026-09-08';
SET @a4_align_source_version   = 'olist-csv-raw_tables';
SET @a4_align_specification_id = 'fulfilliq-2.0-stage3-candidate-v0.2.1';

UPDATE B_orders
SET snapshot_id = @a4_align_snapshot_id,
    source_version = @a4_align_source_version,
    specification_id = @a4_align_specification_id;

UPDATE B_items
SET snapshot_id = @a4_align_snapshot_id,
    source_version = @a4_align_source_version,
    specification_id = @a4_align_specification_id;

UPDATE B_sellers
SET snapshot_id = @a4_align_snapshot_id,
    source_version = @a4_align_source_version,
    specification_id = @a4_align_specification_id;
