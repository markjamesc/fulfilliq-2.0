-- Stage_04_SQL_A.sql -- MySQL 8.0; run in one dedicated connection.
-- Sources: supplied Stage 3 v0.2.1 and Stage 4 shared packet ONLY.
-- Populate the five manifest/verification settings below before execution.
-- NULL settings intentionally halt: snapshot facts must not be fabricated.
-- Requires SELECT, CREATE TEMPORARY TABLES, CREATE ROUTINE, EXECUTE,
-- ALTER ROUTINE. Stop on the first error; do not use mysql --force.
-- No source-table writes. The temporary evidence/audit/judged tables remain
-- available in this connection. This script creates/drops its own procedure;
-- a pre-existing procedure of the same name is NOT overwritten.

USE fulfilliq;
SET @a4_snapshot_id = NULL;             -- verified frozen snapshot identifier
SET @a4_source_version = NULL;          -- verified source/import version
SET @a4_outcome_observation_boundary = NULL; -- documented snapshot boundary
SET @a4_temporal_convention = NULL;     -- documented source clock convention
SET @a4_source_verified = 0;            -- 1 only after mappings, native DATETIME
-- semantics, handoff interpretation, and immutable snapshot are verified.
SET @a4_documented_hold_reason = NULL;  -- optional documented release hold
-- Capacity is fixed below: C=20, simulated O=0/R=0, S=20.
SET @a4_saved_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = 'STRICT_ALL_TABLES,ONLY_FULL_GROUP_BY,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DELIMITER $$
CREATE PROCEDURE fulfilliq.stage04_build_sql_a(
    IN p_snapshot_id TEXT, IN p_source_version TEXT,
    IN p_outcome_boundary TEXT, IN p_temporal_convention TEXT,
    IN p_source_verified INT, IN p_hold_reason TEXT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_bad BIGINT DEFAULT 0;
    DECLARE v_columns INT DEFAULT 0;
    DECLARE v_extracted_at DATETIME(6);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS a4_judged;
        RESIGNAL;
    END;
    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS a4_judged;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: SQL warning; inspect source types, values and arithmetic.';
    END;

    DROP TEMPORARY TABLE IF EXISTS a4_evidence, a4_audit, a4_base,
        a4_gates, a4_q, a4_q_peer, a4_provisional_ranks, a4_provisional,
        a4_twin, a4_compare, a4_final_q, a4_final_q_peer,
        a4_final_ranks, a4_judged;

    IF COALESCE(p_source_verified,0) <> 1
       OR NULLIF(TRIM(p_snapshot_id),'') IS NULL
       OR NULLIF(TRIM(p_source_version),'') IS NULL
       OR NULLIF(TRIM(p_outcome_boundary),'') IS NULL
       OR NULLIF(TRIM(p_temporal_convention),'') IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: supply verified snapshot, source, observation boundary and temporal semantics.';
    END IF;
    IF VERSION() NOT LIKE '8.0.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A requires MySQL 8.0.';
    END IF;

    -- Required physical mappings. This implementation accepts native DATETIME
    -- at one recorded precision; it never guesses a text/date-only parser.
    SELECT COUNT(*) INTO v_columns FROM information_schema.columns
    WHERE table_schema='fulfilliq' AND (
      (table_name='raw_orders' AND column_name IN ('order_id','order_status',
       'order_purchase_timestamp','order_delivered_customer_date',
       'order_estimated_delivery_date','order_delivered_carrier_date')) OR
      (table_name='raw_order_items' AND column_name IN
       ('order_id','order_item_id','seller_id','shipping_limit_date')) OR
      (table_name='raw_sellers' AND column_name='seller_id'));
    IF v_columns <> 11 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: missing required source mapping.';
    END IF;
    SELECT COUNT(*), COUNT(DISTINCT datetime_precision)
      INTO v_columns, v_bad FROM information_schema.columns
    WHERE table_schema='fulfilliq' AND data_type='datetime' AND (
      (table_name='raw_orders' AND column_name IN
       ('order_purchase_timestamp','order_delivered_customer_date',
        'order_estimated_delivery_date','order_delivered_carrier_date')) OR
      (table_name='raw_order_items' AND column_name='shipping_limit_date'));
    IF v_columns <> 5 OR v_bad <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: temporal type/precision requires a verified mapping; no implicit parsing.';
    END IF;
    SELECT COUNT(*) INTO v_columns FROM information_schema.columns
    WHERE table_schema='fulfilliq' AND data_type IN ('char','varchar') AND (
      (table_name='raw_orders' AND column_name IN ('order_id','order_status')) OR
      (table_name='raw_order_items' AND column_name IN ('order_id','seller_id')) OR
      (table_name='raw_sellers' AND column_name='seller_id'));
    IF v_columns <> 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: verify textual identity/status mappings.';
    END IF;
    SELECT COUNT(*) INTO v_columns FROM information_schema.tables
    WHERE table_schema='fulfilliq' AND engine='InnoDB'
      AND table_name IN ('raw_orders','raw_order_items','raw_sellers');
    IF v_columns <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: all three frozen source tables must be InnoDB.';
    END IF;

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION WITH CONSISTENT SNAPSHOT;
    SET v_extracted_at = UTC_TIMESTAMP(6);

    -- No silent deduplication of business-key collisions, including invalids.
    SELECT COUNT(*) INTO v_bad FROM (
      SELECT CAST(order_id AS BINARY) AS k FROM raw_orders
      GROUP BY CAST(order_id AS BINARY) HAVING COUNT(*)>1
    ) x;
    IF v_bad > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: duplicate raw_orders order_id.';
    END IF;
    SELECT COUNT(*) INTO v_bad FROM (
      SELECT CAST(seller_id AS BINARY) AS k FROM raw_sellers
      GROUP BY CAST(seller_id AS BINARY) HAVING COUNT(*)>1
    ) x;
    IF v_bad > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: duplicate raw_sellers seller_id.';
    END IF;
    SELECT COUNT(*) INTO v_bad FROM (
      SELECT CAST(order_id AS BINARY) AS k, CAST(order_item_id AS BINARY) AS i
      FROM raw_order_items
      GROUP BY CAST(order_id AS BINARY), CAST(order_item_id AS BINARY)
      HAVING COUNT(*)>1
    ) x;
    IF v_bad > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: duplicate raw_order_items business key.';
    END IF;

    -- Raw native values are retained in evidence; *_valid flags are their
    -- parsed-value validation. NULL/zero/impossible dates are not on-time.
    CREATE TEMPORARY TABLE a4_evidence AS
    WITH orders_checked AS (
      SELECT o.*,

        COALESCE(YEAR(order_purchase_timestamp)>=1000 AND MONTH(order_purchase_timestamp) BETWEEN 1 AND 12
          AND DAYOFMONTH(order_purchase_timestamp) BETWEEN 1 AND DAYOFMONTH(LAST_DAY(order_purchase_timestamp)),0)
          AS purchase_valid,

        COALESCE(YEAR(order_delivered_customer_date)>=1000 AND MONTH(order_delivered_customer_date) BETWEEN 1 AND 12
          AND DAYOFMONTH(order_delivered_customer_date) BETWEEN 1 AND DAYOFMONTH(LAST_DAY(order_delivered_customer_date)),0)
          AS actual_valid,

        COALESCE(YEAR(order_estimated_delivery_date)>=1000 AND MONTH(order_estimated_delivery_date) BETWEEN 1 AND 12
          AND DAYOFMONTH(order_estimated_delivery_date) BETWEEN 1 AND DAYOFMONTH(LAST_DAY(order_estimated_delivery_date)),0)
          AS estimated_valid,

        COALESCE(YEAR(order_delivered_carrier_date)>=1000 AND MONTH(order_delivered_carrier_date) BETWEEN 1 AND 12
          AND DAYOFMONTH(order_delivered_carrier_date) BETWEEN 1 AND DAYOFMONTH(LAST_DAY(order_delivered_carrier_date)),0)
          AS carrier_valid

      FROM raw_orders o
      WHERE NULLIF(TRIM(order_id),'') IS NOT NULL
    ), item_orders AS (
      SELECT CAST(i.order_id AS BINARY) AS order_key,
        COUNT(*) AS order_item_row_n,
        COUNT(DISTINCT CASE WHEN NULLIF(TRIM(i.seller_id),'') IS NOT NULL
          THEN CAST(i.seller_id AS BINARY) END) AS distinct_seller_association_n,
        COUNT(DISTINCT CAST(s.seller_id AS BINARY)) AS valid_seller_n,
        SUM(s.seller_id IS NULL) AS unresolved_seller_item_n,
        SUM(NULLIF(TRIM(CAST(i.order_item_id AS CHAR)),'') IS NULL)
          AS invalid_item_key_n,
        MIN(COALESCE(YEAR(i.shipping_limit_date)>=1000
          AND MONTH(i.shipping_limit_date) BETWEEN 1 AND 12
          AND DAYOFMONTH(i.shipping_limit_date)
              BETWEEN 1 AND DAYOFMONTH(LAST_DAY(i.shipping_limit_date))
          AND i.shipping_limit_date>=o.order_purchase_timestamp,0))
          AS all_item_deadlines_valid,
        MAX(i.shipping_limit_date) AS latest_shipping_limit_date
      FROM raw_order_items i
      JOIN orders_checked o ON CAST(o.order_id AS BINARY)=CAST(i.order_id AS BINARY)
      LEFT JOIN raw_sellers s ON CAST(s.seller_id AS BINARY)=CAST(i.seller_id AS BINARY)
        AND NULLIF(TRIM(s.seller_id),'') IS NOT NULL
      GROUP BY CAST(i.order_id AS BINARY)
    ), associations AS (
      SELECT CAST(i.seller_id AS BINARY) AS seller_key,
        CAST(i.order_id AS BINARY) AS order_key,
        COUNT(*) AS association_item_row_n
      FROM raw_order_items i
      JOIN raw_sellers s ON CAST(s.seller_id AS BINARY)=CAST(i.seller_id AS BINARY)
        AND NULLIF(TRIM(s.seller_id),'') IS NOT NULL
      WHERE NULLIF(TRIM(i.order_id),'') IS NOT NULL
      GROUP BY CAST(i.seller_id AS BINARY), CAST(i.order_id AS BINARY)
    ), classified AS (
      SELECT a.*, o.order_status, o.order_purchase_timestamp,
        o.order_delivered_customer_date, o.order_estimated_delivery_date,
        o.order_delivered_carrier_date,
        o.purchase_valid, o.actual_valid, o.estimated_valid, o.carrier_valid,
        io.order_item_row_n, io.distinct_seller_association_n,
        io.valid_seller_n, io.unresolved_seller_item_n, io.invalid_item_key_n,
        io.all_item_deadlines_valid, io.latest_shipping_limit_date,
        (io.distinct_seller_association_n>1) AS multi_seller_order_flag,
        (io.valid_seller_n=1 AND io.unresolved_seller_item_n=0)
          AS strict_single_seller_flag,
        (o.order_purchase_timestamp<'2018-05-01 00:00:00') AS half1_flag,
        CASE
          WHEN o.order_delivered_customer_date IS NULL
            OR o.order_estimated_delivery_date IS NULL THEN 'MISSING_DELIVERY_DATE'
          WHEN o.actual_valid=0 OR o.estimated_valid=0 THEN 'INVALID_DELIVERY_DATE'
          WHEN o.order_delivered_customer_date<o.order_purchase_timestamp
            THEN 'ACTUAL_BEFORE_PURCHASE'
          WHEN o.order_estimated_delivery_date<o.order_purchase_timestamp
            THEN 'ESTIMATED_BEFORE_PURCHASE'
          ELSE 'ELIGIBLE'
        END AS eligibility_reason
      FROM associations a
      JOIN orders_checked o ON CAST(o.order_id AS BINARY)=a.order_key
      JOIN item_orders io ON io.order_key=a.order_key
      WHERE CAST(o.order_status AS BINARY)=CAST('delivered' AS BINARY)
        AND o.purchase_valid=1
        AND o.order_purchase_timestamp>='2018-01-01 00:00:00'
        AND o.order_purchase_timestamp<'2018-09-01 00:00:00'
    )
    SELECT c.*, (eligibility_reason='ELIGIBLE') AS eligible_flag,
      COALESCE(eligibility_reason='ELIGIBLE'
        AND DATE(order_delivered_customer_date)>DATE(order_estimated_delivery_date),0)
        AS late_D,
      COALESCE(eligibility_reason='ELIGIBLE'
        AND order_delivered_customer_date>order_estimated_delivery_date,0) AS late_T,
      COALESCE(strict_single_seller_flag=1 AND carrier_valid=1
        AND order_delivered_carrier_date>=order_purchase_timestamp
        AND order_delivered_carrier_date<=order_delivered_customer_date
        AND all_item_deadlines_valid=1,0) AS handoff_evaluable_flag,
      COALESCE(order_delivered_carrier_date>latest_shipping_limit_date,0)
        AS carrier_after_latest_deadline_flag
    FROM classified c;

    CREATE TEMPORARY TABLE a4_audit AS
    WITH item_audit AS (
      SELECT COUNT(*) AS source_item_row_n,
        COALESCE(SUM(NULLIF(TRIM(i.order_id),'') IS NULL
          OR NULLIF(TRIM(i.seller_id),'') IS NULL
          OR NULLIF(TRIM(CAST(i.order_item_id AS CHAR)),'') IS NULL),0)
          AS invalid_item_key_row_n,
        COALESCE(SUM(NULLIF(TRIM(i.order_id),'') IS NOT NULL AND o.order_id IS NULL),0)
          AS orphan_order_item_row_n,
        COALESCE(SUM(NULLIF(TRIM(i.seller_id),'') IS NOT NULL AND s.seller_id IS NULL),0)
          AS orphan_seller_item_row_n
      FROM raw_order_items i
      LEFT JOIN raw_orders o ON CAST(o.order_id AS BINARY)=CAST(i.order_id AS BINARY)
        AND NULLIF(TRIM(o.order_id),'') IS NOT NULL
      LEFT JOIN raw_sellers s ON CAST(s.seller_id AS BINARY)=CAST(i.seller_id AS BINARY)
        AND NULLIF(TRIM(s.seller_id),'') IS NOT NULL
    ), order_audit AS (
      SELECT COUNT(*) AS source_order_row_n,
        COALESCE(SUM(NULLIF(TRIM(order_id),'') IS NULL),0) AS invalid_order_key_row_n,
        COALESCE(SUM(NOT COALESCE(YEAR(order_purchase_timestamp)>=1000
          AND MONTH(order_purchase_timestamp) BETWEEN 1 AND 12
          AND DAYOFMONTH(order_purchase_timestamp)
            BETWEEN 1 AND DAYOFMONTH(LAST_DAY(order_purchase_timestamp)),0)),0)
          AS invalid_purchase_order_n
      FROM raw_orders
    ), seller_audit AS (
      SELECT COUNT(*) AS source_seller_row_n,
        COALESCE(SUM(NULLIF(TRIM(seller_id),'') IS NULL),0) AS invalid_seller_key_row_n,
        COALESCE(SUM(NULLIF(TRIM(seller_id),'') IS NOT NULL),0) AS valid_seller_n
      FROM raw_sellers
    ), cohort_audit AS (
      SELECT COUNT(*) AS candidate_seller_order_n,
        COUNT(DISTINCT order_key) AS candidate_unique_order_n,
        COALESCE(SUM(eligible_flag),0) AS eligible_seller_order_n,
        COUNT(DISTINCT CASE WHEN eligible_flag=1 THEN order_key END)
          AS eligible_unique_order_n,
        COALESCE(SUM(late_D),0) AS late_seller_order_n,
        COUNT(DISTINCT CASE WHEN late_D=1 THEN order_key END) AS late_unique_order_n,
        COUNT(DISTINCT CASE WHEN late_T=1 THEN order_key END)
          AS late_timestamp_unique_order_n,
        COALESCE(SUM(eligible_flag=1 AND unresolved_seller_item_n>0),0)
          AS eligible_unresolved_seller_association_n
      FROM a4_evidence
    )
    SELECT i.*, o.*, s.*, c.*,
      (invalid_item_key_row_n+orphan_order_item_row_n+orphan_seller_item_row_n
       +invalid_order_key_row_n+invalid_seller_key_row_n+invalid_purchase_order_n>0)
        AS source_quality_flag,
      0 AS duplicate_order_key_group_n, 0 AS duplicate_item_key_group_n,
      0 AS duplicate_seller_key_group_n,
      'VALID' AS run_validity,
      (invalid_item_key_row_n+orphan_order_item_row_n+orphan_seller_item_row_n
       +invalid_order_key_row_n+invalid_seller_key_row_n+invalid_purchase_order_n>0
       OR NULLIF(TRIM(p_hold_reason),'') IS NOT NULL) AS operational_release_hold_flag,
      CONCAT_WS('|',
        IF(invalid_item_key_row_n+orphan_order_item_row_n+orphan_seller_item_row_n
          +invalid_order_key_row_n+invalid_seller_key_row_n+invalid_purchase_order_n>0,
          'SOURCE_ANOMALY_EFFECT_NOT_BOUNDED',NULL),NULLIF(TRIM(p_hold_reason),''))
        AS operational_release_hold_reason
    FROM item_audit i CROSS JOIN order_audit o CROSS JOIN seller_audit s
      CROSS JOIN cohort_audit c;

    -- Two clock runs; counts are DECIMAL(20,0) before products. All gates
    -- compare integer products. Quotients below are display fields only.
    CREATE TEMPORARY TABLE a4_base AS
    WITH clocks AS (SELECT 'D' AS clock UNION ALL SELECT 'T'),
    events AS (
      SELECT e.*, c.clock, IF(c.clock='D',late_D,late_T) AS late_flag
      FROM a4_evidence e CROSS JOIN clocks c
    ), aggregates AS (
      SELECT seller_key, clock,

        CAST(COUNT(*) AS DECIMAL(20,0)) AS candidate_delivered_n,
        CAST(SUM(eligible_flag) AS DECIMAL(20,0)) AS eligible_n,
        CAST(SUM(eligible_flag=0) AS DECIMAL(20,0)) AS excluded_n,
        CAST(SUM(eligibility_reason='MISSING_DELIVERY_DATE') AS DECIMAL(20,0)) AS excluded_missing_delivery_date_n,
        CAST(SUM(eligibility_reason='INVALID_DELIVERY_DATE') AS DECIMAL(20,0)) AS excluded_invalid_delivery_date_n,
        CAST(SUM(eligibility_reason='ACTUAL_BEFORE_PURCHASE') AS DECIMAL(20,0)) AS excluded_actual_before_purchase_n,
        CAST(SUM(eligibility_reason='ESTIMATED_BEFORE_PURCHASE') AS DECIMAL(20,0)) AS excluded_estimated_before_purchase_n,
        CAST(SUM(late_flag) AS DECIMAL(20,0)) AS late_n,
        CAST(SUM(late_D<>late_T) AS DECIMAL(20,0)) AS date_timestamp_disagree_n,
        CAST(SUM(eligible_flag*strict_single_seller_flag) AS DECIMAL(20,0)) AS eligible_n_ss,
        CAST(SUM(late_flag*strict_single_seller_flag) AS DECIMAL(20,0)) AS late_n_ss,
        CAST(SUM(eligible_flag*multi_seller_order_flag) AS DECIMAL(20,0)) AS eligible_n_ms,
        CAST(SUM(late_flag*multi_seller_order_flag) AS DECIMAL(20,0)) AS late_n_ms,
        CAST(SUM(eligible_flag=1 AND unresolved_seller_item_n>0) AS DECIMAL(20,0)) AS unresolved_association_n,
        CAST(SUM(eligible_flag=1 AND strict_single_seller_flag=0 AND multi_seller_order_flag=0) AS DECIMAL(20,0)) AS unclassified_association_n,
        CAST(SUM(late_flag*handoff_evaluable_flag) AS DECIMAL(20,0)) AS handoff_evaluable_late_n,
        CAST(SUM(late_flag*handoff_evaluable_flag*carrier_after_latest_deadline_flag) AS DECIMAL(20,0)) AS handoff_support_n,
        CAST(SUM(eligible_flag*half1_flag) AS DECIMAL(20,0)) AS eligible_n_half1,
        CAST(SUM(late_flag*half1_flag) AS DECIMAL(20,0)) AS late_n_half1,
        CAST(SUM(eligible_flag*strict_single_seller_flag*half1_flag) AS DECIMAL(20,0)) AS eligible_n_ss_half1,
        CAST(SUM(late_flag*strict_single_seller_flag*half1_flag) AS DECIMAL(20,0)) AS late_n_ss_half1,
        CAST(SUM(eligible_flag*(1-half1_flag)) AS DECIMAL(20,0)) AS eligible_n_half2,
        CAST(SUM(late_flag*(1-half1_flag)) AS DECIMAL(20,0)) AS late_n_half2,
        CAST(SUM(eligible_flag*strict_single_seller_flag*(1-half1_flag)) AS DECIMAL(20,0)) AS eligible_n_ss_half2,
        CAST(SUM(late_flag*strict_single_seller_flag*(1-half1_flag)) AS DECIMAL(20,0)) AS late_n_ss_half2

      FROM events GROUP BY seller_key, clock
    ), populated AS (
      SELECT s.seller_id, CAST(s.seller_id AS BINARY) AS seller_key, c.clock,

        CAST(COALESCE(a.candidate_delivered_n,0) AS DECIMAL(20,0)) AS candidate_delivered_n,
        CAST(COALESCE(a.eligible_n,0) AS DECIMAL(20,0)) AS eligible_n,
        CAST(COALESCE(a.excluded_n,0) AS DECIMAL(20,0)) AS excluded_n,
        CAST(COALESCE(a.excluded_missing_delivery_date_n,0) AS DECIMAL(20,0)) AS excluded_missing_delivery_date_n,
        CAST(COALESCE(a.excluded_invalid_delivery_date_n,0) AS DECIMAL(20,0)) AS excluded_invalid_delivery_date_n,
        CAST(COALESCE(a.excluded_actual_before_purchase_n,0) AS DECIMAL(20,0)) AS excluded_actual_before_purchase_n,
        CAST(COALESCE(a.excluded_estimated_before_purchase_n,0) AS DECIMAL(20,0)) AS excluded_estimated_before_purchase_n,
        CAST(COALESCE(a.late_n,0) AS DECIMAL(20,0)) AS late_n,
        CAST(COALESCE(a.date_timestamp_disagree_n,0) AS DECIMAL(20,0)) AS date_timestamp_disagree_n,
        CAST(COALESCE(a.eligible_n_ss,0) AS DECIMAL(20,0)) AS eligible_n_ss,
        CAST(COALESCE(a.late_n_ss,0) AS DECIMAL(20,0)) AS late_n_ss,
        CAST(COALESCE(a.eligible_n_ms,0) AS DECIMAL(20,0)) AS eligible_n_ms,
        CAST(COALESCE(a.late_n_ms,0) AS DECIMAL(20,0)) AS late_n_ms,
        CAST(COALESCE(a.unresolved_association_n,0) AS DECIMAL(20,0)) AS unresolved_association_n,
        CAST(COALESCE(a.unclassified_association_n,0) AS DECIMAL(20,0)) AS unclassified_association_n,
        CAST(COALESCE(a.handoff_evaluable_late_n,0) AS DECIMAL(20,0)) AS handoff_evaluable_late_n,
        CAST(COALESCE(a.handoff_support_n,0) AS DECIMAL(20,0)) AS handoff_support_n,
        CAST(COALESCE(a.eligible_n_half1,0) AS DECIMAL(20,0)) AS eligible_n_half1,
        CAST(COALESCE(a.late_n_half1,0) AS DECIMAL(20,0)) AS late_n_half1,
        CAST(COALESCE(a.eligible_n_ss_half1,0) AS DECIMAL(20,0)) AS eligible_n_ss_half1,
        CAST(COALESCE(a.late_n_ss_half1,0) AS DECIMAL(20,0)) AS late_n_ss_half1,
        CAST(COALESCE(a.eligible_n_half2,0) AS DECIMAL(20,0)) AS eligible_n_half2,
        CAST(COALESCE(a.late_n_half2,0) AS DECIMAL(20,0)) AS late_n_half2,
        CAST(COALESCE(a.eligible_n_ss_half2,0) AS DECIMAL(20,0)) AS eligible_n_ss_half2,
        CAST(COALESCE(a.late_n_ss_half2,0) AS DECIMAL(20,0)) AS late_n_ss_half2

      FROM raw_sellers s CROSS JOIN clocks c
      LEFT JOIN aggregates a ON a.seller_key=CAST(s.seller_id AS BINARY)
        AND a.clock=c.clock
      WHERE NULLIF(TRIM(s.seller_id),'') IS NOT NULL
    )
    SELECT p.*,
      (eligible_n>=30) AS volume_gate,
      (candidate_delivered_n>0 AND 100*eligible_n>=95*candidate_delivered_n)
        AS coverage_gate,
      (eligible_n>=30 AND candidate_delivered_n>0
        AND 100*eligible_n>=95*candidate_delivered_n) AS reference_flag
    FROM populated p;

    CREATE TEMPORARY TABLE a4_gates AS
    WITH reference_components AS (
      SELECT b.*,
        CAST(SUM(reference_flag) OVER (PARTITION BY clock)-reference_flag
          AS DECIMAL(20,0)) AS comparator_seller_n,
        CAST(SUM(reference_flag*(eligible_n_ss>0)) OVER (PARTITION BY clock)
          -reference_flag*(eligible_n_ss>0) AS DECIMAL(20,0)) AS ss_comparator_seller_n,

        CAST(SUM(IF(reference_flag=1,eligible_n,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n,0) AS DECIMAL(20,0)) AS comparator_eligible_n,

        CAST(SUM(IF(reference_flag=1,late_n,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n,0) AS DECIMAL(20,0)) AS comparator_late_n,

        CAST(SUM(IF(reference_flag=1,eligible_n_half1,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n_half1,0) AS DECIMAL(20,0)) AS comparator_eligible_n_half1,

        CAST(SUM(IF(reference_flag=1,late_n_half1,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n_half1,0) AS DECIMAL(20,0)) AS comparator_late_n_half1,

        CAST(SUM(IF(reference_flag=1,eligible_n_half2,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n_half2,0) AS DECIMAL(20,0)) AS comparator_eligible_n_half2,

        CAST(SUM(IF(reference_flag=1,late_n_half2,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n_half2,0) AS DECIMAL(20,0)) AS comparator_late_n_half2,

        CAST(SUM(IF(reference_flag=1,eligible_n_ss,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n_ss,0) AS DECIMAL(20,0)) AS comparator_eligible_n_ss,

        CAST(SUM(IF(reference_flag=1,late_n_ss,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n_ss,0) AS DECIMAL(20,0)) AS comparator_late_n_ss,

        CAST(SUM(IF(reference_flag=1,eligible_n_ss_half1,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n_ss_half1,0) AS DECIMAL(20,0)) AS comparator_eligible_n_ss_half1,

        CAST(SUM(IF(reference_flag=1,late_n_ss_half1,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n_ss_half1,0) AS DECIMAL(20,0)) AS comparator_late_n_ss_half1,

        CAST(SUM(IF(reference_flag=1,eligible_n_ss_half2,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,eligible_n_ss_half2,0) AS DECIMAL(20,0)) AS comparator_eligible_n_ss_half2,

        CAST(SUM(IF(reference_flag=1,late_n_ss_half2,0)) OVER (PARTITION BY clock)
          -IF(reference_flag=1,late_n_ss_half2,0) AS DECIMAL(20,0)) AS comparator_late_n_ss_half2

      FROM a4_base b
    ), atomic_gates AS (
      SELECT r.*,

        (comparator_seller_n>=20 AND comparator_eligible_n>=1000) AS full_comparator_usable_flag,
        (comparator_eligible_n_half1>=200) AS half1_comparator_usable_flag,
        (comparator_eligible_n_half2>=200) AS half2_comparator_usable_flag,
        (ss_comparator_seller_n>=20 AND comparator_eligible_n_ss>=1000) AS ss_full_comparator_usable_flag,
        (comparator_eligible_n_ss_half1>=200) AS ss_half1_comparator_usable_flag,
        (comparator_eligible_n_ss_half2>=200) AS ss_half2_comparator_usable_flag,
        (late_n>=5) AS minimum_late_gate,
        (eligible_n>0 AND comparator_eligible_n>0 AND 100*late_n*comparator_eligible_n>=100*eligible_n*comparator_late_n+3*eligible_n*comparator_eligible_n) AS elevation_gate,
        (eligible_n_ss>=30) AS ss_volume_gate,
        (late_n_ss>=5) AS ss_minimum_late_gate,
        (eligible_n_ss>0 AND comparator_eligible_n_ss>0 AND 100*late_n_ss*comparator_eligible_n_ss>=100*eligible_n_ss*comparator_late_n_ss+3*eligible_n_ss*comparator_eligible_n_ss) AS ss_elevation_gate,
        (late_n_ss>0 AND 100*handoff_evaluable_late_n>=90*late_n_ss) AS handoff_evaluability_gate,
        (handoff_support_n>=3) AS handoff_support_count_gate,
        (late_n>0 AND 2*handoff_support_n>=late_n) AS handoff_support_share_gate,
        (eligible_n>0 AND 2*eligible_n_ms>eligible_n) AS majority_eligible_ms_flag,
        (late_n>0 AND 2*late_n_ms>late_n) AS majority_late_ms_flag,
        (eligible_n_ss<30) AS too_thin_ss_flag,
        (eligible_n_half1>=10) AS half1_volume_gate,
        (late_n_half1>=2) AS half1_late_gate,
        (eligible_n_half1>0 AND comparator_eligible_n_half1>0 AND late_n_half1*comparator_eligible_n_half1>=eligible_n_half1*comparator_late_n_half1) AS half1_rate_gate,
        (eligible_n_half2>=10) AS half2_volume_gate,
        (late_n_half2>=2) AS half2_late_gate,
        (eligible_n_half2>0 AND comparator_eligible_n_half2>0 AND late_n_half2*comparator_eligible_n_half2>=eligible_n_half2*comparator_late_n_half2) AS half2_rate_gate,
        (eligible_n_ss_half1>=10) AS ss_half1_volume_gate,
        (late_n_ss_half1>=2) AS ss_half1_late_gate,
        (eligible_n_ss_half1>0 AND comparator_eligible_n_ss_half1>0 AND late_n_ss_half1*comparator_eligible_n_ss_half1>=eligible_n_ss_half1*comparator_late_n_ss_half1) AS ss_half1_rate_gate,
        (eligible_n_ss_half2>=10) AS ss_half2_volume_gate,
        (late_n_ss_half2>=2) AS ss_half2_late_gate,
        (eligible_n_ss_half2>0 AND comparator_eligible_n_ss_half2>0 AND late_n_ss_half2*comparator_eligible_n_ss_half2>=eligible_n_ss_half2*comparator_late_n_ss_half2) AS ss_half2_rate_gate

      FROM reference_components r
    ), composite_gates AS (
      SELECT a.*,
        (full_comparator_usable_flag AND half1_comparator_usable_flag
          AND half2_comparator_usable_flag) AS comparator_usable_flag,
        (ss_full_comparator_usable_flag AND ss_half1_comparator_usable_flag
          AND ss_half2_comparator_usable_flag) AS ss_comparator_usable_flag,
        (minimum_late_gate AND elevation_gate AND full_comparator_usable_flag)
          AS materiality_gate,
        (half1_volume_gate AND half1_late_gate AND half1_rate_gate
          AND half1_comparator_usable_flag AND half2_volume_gate
          AND half2_late_gate AND half2_rate_gate AND half2_comparator_usable_flag)
          AS persistence_gate,
        (handoff_support_count_gate AND handoff_support_share_gate)
          AS handoff_support_gate,
        (ss_volume_gate AND ss_minimum_late_gate AND ss_elevation_gate
          AND ss_full_comparator_usable_flag AND ss_half1_comparator_usable_flag
          AND ss_half2_comparator_usable_flag AND ss_half1_volume_gate
          AND ss_half1_late_gate AND ss_half1_rate_gate AND ss_half2_volume_gate
          AND ss_half2_late_gate AND ss_half2_rate_gate) AS ss_rate_clear_flag,
        CAST(late_n*comparator_eligible_n-eligible_n*comparator_late_n
          AS DECIMAL(44,0)) AS excess_burden_num,
        comparator_eligible_n AS excess_burden_den
      FROM atomic_gates a
    ), pre_n4 AS (
      SELECT c.*,
        (volume_gate AND coverage_gate AND comparator_usable_flag
          AND materiality_gate AND persistence_gate AND handoff_evaluability_gate
          AND handoff_support_gate) AS all_order_pass,
        CONCAT_WS('|',IF(eligible_n=0,'NO_ELIGIBLE_VOLUME',NULL),
          IF(volume_gate=0,'BELOW_VOLUME_FLOOR',NULL),
          IF(coverage_gate=0,'COVERAGE_FAILURE',NULL),
          IF(comparator_usable_flag=0,'INSUFFICIENT_COMPARATOR',NULL),
          IF(materiality_gate=0,'MATERIALITY_FAILURE',NULL),
          IF(persistence_gate=0,'REPETITION_FAILURE',NULL),
          IF(handoff_evaluability_gate=0,'HANDOFF_EVALUABILITY_FAILURE',NULL),
          IF(handoff_support_gate=0,'HANDOFF_SUPPORT_FAILURE',NULL))
          AS failed_all_order_gate_codes,
        CASE WHEN eligible_n=0 THEN 'NO_ELIGIBLE_VOLUME'
          WHEN volume_gate=0 THEN 'BELOW_VOLUME_FLOOR'
          WHEN coverage_gate=0 THEN 'COVERAGE_FAILURE'
          WHEN comparator_usable_flag=0 THEN 'INSUFFICIENT_COMPARATOR'
          WHEN materiality_gate=0 THEN 'MATERIALITY_FAILURE'
          WHEN persistence_gate=0 THEN 'REPETITION_FAILURE'
          WHEN handoff_evaluability_gate=0 THEN 'HANDOFF_EVALUABILITY_FAILURE'
          WHEN handoff_support_gate=0 THEN 'HANDOFF_SUPPORT_FAILURE'
          ELSE 'QUALIFIED' END AS all_order_primary_reason
      FROM composite_gates c
    ), n4 AS (
      SELECT p.*,
        (all_order_pass AND NOT ss_rate_clear_flag) AS n4_flip_flag,
        (all_order_pass AND too_thin_ss_flag
          AND (majority_eligible_ms_flag OR majority_late_ms_flag))
          AS n4_thin_majority_flag
      FROM pre_n4 p
    )
    SELECT n.*,
      (n4_flip_flag OR n4_thin_majority_flag) AS n4_fire,
      CASE WHEN n4_thin_majority_flag THEN 'thin_majority'
        WHEN n4_flip_flag THEN 'flip' ELSE 'none' END AS n4_branch,
      CASE WHEN n4_flip_flag OR n4_thin_majority_flag THEN 'INCONCLUSIVE'
        WHEN all_order_pass THEN 'YES' ELSE 'NO' END AS membership_pre
    FROM n4 n;

    -- Materialized copies avoid MySQL's temporary-table reopen restriction.
    CREATE TEMPORARY TABLE a4_q AS
      SELECT * FROM a4_gates WHERE membership_pre='YES';
    CREATE TEMPORARY TABLE a4_q_peer AS SELECT * FROM a4_q;

    -- Exact pairwise rank: 1 + number strictly ahead; no rounded score sort.
    CREATE TEMPORARY TABLE a4_provisional_ranks AS
    SELECT a.clock, a.seller_key, 1+COUNT(b.seller_key) AS seller_rank
    FROM a4_q a LEFT JOIN a4_q_peer b ON a.clock=b.clock AND (
      b.excess_burden_num*a.excess_burden_den
        > a.excess_burden_num*b.excess_burden_den
      OR (b.excess_burden_num*a.excess_burden_den
        = a.excess_burden_num*b.excess_burden_den AND (
          (b.handoff_support_n,b.late_n,b.eligible_n)
            > (a.handoff_support_n,a.late_n,a.eligible_n)
          OR ((b.handoff_support_n,b.late_n,b.eligible_n)
            = (a.handoff_support_n,a.late_n,a.eligible_n)
            AND b.seller_key<a.seller_key))))
    GROUP BY a.clock, a.seller_key;

    CREATE TEMPORARY TABLE a4_provisional AS
    SELECT g.*, r.seller_rank AS rank_provisional,
      COALESCE(r.seller_rank<=20,0) AS selected_provisional,
      CASE WHEN g.membership_pre='INCONCLUSIVE' THEN 'INCONCLUSIVE'
        WHEN g.membership_pre='NO' THEN 'STANDARD_NOT_QUALIFIED'
        WHEN r.seller_rank<=20 THEN 'ENROLL_RECOMMENDED'
        ELSE 'WATCH' END AS action_provisional
    FROM a4_gates g LEFT JOIN a4_provisional_ranks r
      ON r.seller_key=g.seller_key AND r.clock=g.clock;

    CREATE TEMPORARY TABLE a4_twin AS
      SELECT * FROM a4_provisional WHERE clock='T';
    CREATE TEMPORARY TABLE a4_compare AS
    SELECT d.*,
      d.membership_pre AS membership_D, t.membership_pre AS membership_T,
      d.action_provisional AS action_D_provisional,
      t.action_provisional AS action_T_provisional,
      d.selected_provisional AS selected_D_provisional,
      t.selected_provisional AS selected_T_provisional,
      d.rank_provisional AS rank_D_provisional, t.rank_provisional AS rank_T_provisional,
      d.n4_fire AS n4_fire_D, t.n4_fire AS n4_fire_T,
      d.n4_branch AS n4_branch_D, t.n4_branch AS n4_branch_T,
      t.n4_flip_flag AS n4_flip_T_flag,
      t.n4_thin_majority_flag AS n4_thin_majority_T_flag,
      t.failed_all_order_gate_codes AS failed_all_order_gate_codes_T,
      t.all_order_primary_reason AS all_order_primary_reason_T,
      (d.action_provisional<>t.action_provisional) AS n5_action_disagree_flag,

      t.late_n AS late_n_timestamp,
      t.late_n_ss AS late_n_ss_timestamp,
      t.late_n_ms AS late_n_ms_timestamp,
      t.handoff_evaluable_late_n AS handoff_evaluable_late_n_timestamp,
      t.handoff_support_n AS handoff_support_n_timestamp,
      t.late_n_half1 AS late_n_half1_timestamp,
      t.late_n_ss_half1 AS late_n_ss_half1_timestamp,
      t.late_n_half2 AS late_n_half2_timestamp,
      t.late_n_ss_half2 AS late_n_ss_half2_timestamp,
      t.comparator_eligible_n AS comparator_eligible_n_timestamp,
      t.comparator_late_n AS comparator_late_n_timestamp,
      t.comparator_eligible_n_half1 AS comparator_eligible_n_half1_timestamp,
      t.comparator_late_n_half1 AS comparator_late_n_half1_timestamp,
      t.comparator_eligible_n_half2 AS comparator_eligible_n_half2_timestamp,
      t.comparator_late_n_half2 AS comparator_late_n_half2_timestamp,
      t.comparator_eligible_n_ss AS comparator_eligible_n_ss_timestamp,
      t.comparator_late_n_ss AS comparator_late_n_ss_timestamp,
      t.comparator_eligible_n_ss_half1 AS comparator_eligible_n_ss_half1_timestamp,
      t.comparator_late_n_ss_half1 AS comparator_late_n_ss_half1_timestamp,
      t.comparator_eligible_n_ss_half2 AS comparator_eligible_n_ss_half2_timestamp,
      t.comparator_late_n_ss_half2 AS comparator_late_n_ss_half2_timestamp,
      t.full_comparator_usable_flag AS full_comparator_usable_flag_timestamp,
      t.half1_comparator_usable_flag AS half1_comparator_usable_flag_timestamp,
      t.half2_comparator_usable_flag AS half2_comparator_usable_flag_timestamp,
      t.ss_full_comparator_usable_flag AS ss_full_comparator_usable_flag_timestamp,
      t.ss_half1_comparator_usable_flag AS ss_half1_comparator_usable_flag_timestamp,
      t.ss_half2_comparator_usable_flag AS ss_half2_comparator_usable_flag_timestamp,
      t.minimum_late_gate AS minimum_late_gate_timestamp,
      t.elevation_gate AS elevation_gate_timestamp,
      t.ss_volume_gate AS ss_volume_gate_timestamp,
      t.ss_minimum_late_gate AS ss_minimum_late_gate_timestamp,
      t.ss_elevation_gate AS ss_elevation_gate_timestamp,
      t.handoff_evaluability_gate AS handoff_evaluability_gate_timestamp,
      t.handoff_support_count_gate AS handoff_support_count_gate_timestamp,
      t.handoff_support_share_gate AS handoff_support_share_gate_timestamp,
      t.majority_eligible_ms_flag AS majority_eligible_ms_flag_timestamp,
      t.majority_late_ms_flag AS majority_late_ms_flag_timestamp,
      t.too_thin_ss_flag AS too_thin_ss_flag_timestamp,
      t.half1_volume_gate AS half1_volume_gate_timestamp,
      t.half1_late_gate AS half1_late_gate_timestamp,
      t.half1_rate_gate AS half1_rate_gate_timestamp,
      t.half2_volume_gate AS half2_volume_gate_timestamp,
      t.half2_late_gate AS half2_late_gate_timestamp,
      t.half2_rate_gate AS half2_rate_gate_timestamp,
      t.ss_half1_volume_gate AS ss_half1_volume_gate_timestamp,
      t.ss_half1_late_gate AS ss_half1_late_gate_timestamp,
      t.ss_half1_rate_gate AS ss_half1_rate_gate_timestamp,
      t.ss_half2_volume_gate AS ss_half2_volume_gate_timestamp,
      t.ss_half2_late_gate AS ss_half2_late_gate_timestamp,
      t.ss_half2_rate_gate AS ss_half2_rate_gate_timestamp,
      t.comparator_usable_flag AS comparator_usable_flag_timestamp,
      t.ss_comparator_usable_flag AS ss_comparator_usable_flag_timestamp,
      t.materiality_gate AS materiality_gate_timestamp,
      t.persistence_gate AS persistence_gate_timestamp,
      t.handoff_support_gate AS handoff_support_gate_timestamp,
      t.ss_rate_clear_flag AS ss_rate_clear_flag_timestamp,
      t.all_order_pass AS all_order_pass_timestamp,
      t.excess_burden_num AS excess_burden_num_timestamp,
      t.excess_burden_den AS excess_burden_den_timestamp

    FROM a4_provisional d JOIN a4_twin t ON t.seller_key=d.seller_key
    WHERE d.clock='D';

    -- Freeze N5 now. Refill ONCE under D; never run a second twin comparison.
    CREATE TEMPORARY TABLE a4_final_q AS
      SELECT * FROM a4_compare WHERE membership_D='YES'
        AND n4_fire_D=0 AND n5_action_disagree_flag=0;
    CREATE TEMPORARY TABLE a4_final_q_peer AS SELECT * FROM a4_final_q;

    -- Exact pairwise rank: 1 + number strictly ahead; no rounded score sort.
    CREATE TEMPORARY TABLE a4_final_ranks AS
    SELECT a.seller_key, 1+COUNT(b.seller_key) AS seller_rank
    FROM a4_final_q a LEFT JOIN a4_final_q_peer b ON (
      b.excess_burden_num*a.excess_burden_den
        > a.excess_burden_num*b.excess_burden_den
      OR (b.excess_burden_num*a.excess_burden_den
        = a.excess_burden_num*b.excess_burden_den AND (
          (b.handoff_support_n,b.late_n,b.eligible_n)
            > (a.handoff_support_n,a.late_n,a.eligible_n)
          OR ((b.handoff_support_n,b.late_n,b.eligible_n)
            = (a.handoff_support_n,a.late_n,a.eligible_n)
            AND b.seller_key<a.seller_key))))
    GROUP BY a.seller_key;

    CREATE TEMPORARY TABLE a4_judged AS
    WITH final_decision AS (
      SELECT c.*, r.seller_rank AS `rank`,
        CASE WHEN n5_action_disagree_flag THEN 'INCONCLUSIVE'
          ELSE membership_D END AS membership,
        COALESCE(r.seller_rank<=20,0) AS selected,
        CASE WHEN n5_action_disagree_flag OR n4_fire_D THEN 'INCONCLUSIVE'
          WHEN membership_D='NO' THEN 'STANDARD_NOT_QUALIFIED'
          WHEN r.seller_rank<=20 THEN 'ENROLL_RECOMMENDED'
          ELSE 'WATCH' END AS action,
        (COALESCE(r.seller_rank<=20,0)=1 AND selected_D_provisional=0)
          AS n5_refill_selected_flag,
        -- The specific N5 interaction rule takes precedence over the general
        -- reason list: action disagreement is the primary inconclusive reason.
        CASE WHEN n5_action_disagree_flag THEN 'CLOCK_ACTION_INCONCLUSIVE'
          WHEN all_order_pass=0 THEN all_order_primary_reason
          WHEN n4_fire_D THEN 'MULTI_SELLER_INCONCLUSIVE'
          ELSE 'QUALIFIED' END AS primary_reason,
        CONCAT_WS('|',NULLIF(failed_all_order_gate_codes,''),
          IF(n4_fire_D,'N4_DATE',NULL),IF(n4_fire_T,'N4_TIMESTAMP',NULL),
          IF(n5_action_disagree_flag,'N5_CLOCK_ACTION_DISAGREEMENT',NULL))
          AS reason_codes
      FROM a4_compare c LEFT JOIN a4_final_ranks r ON r.seller_key=c.seller_key
    )
    SELECT f.*,
      'fulfilliq-2.0-stage3-candidate-v0.2.1' AS specification_id,
      CAST('2018-01-01 00:00:00' AS DATETIME) AS window_start_inclusive,
      CAST('2018-05-01 00:00:00' AS DATETIME) AS half_boundary,
      CAST('2018-09-01 00:00:00' AS DATETIME) AS window_end_exclusive,
      p_snapshot_id AS snapshot_id, p_source_version AS source_version,
      p_outcome_boundary AS outcome_observation_boundary,
      p_temporal_convention AS source_temporal_convention,
      v_extracted_at AS extraction_timestamp_utc,
      'BINARY_BYTES' AS identity_and_tie_collation,
      @@SESSION.time_zone AS session_time_zone,
      1 AS source_mapping_verified_flag, 1 AS immutable_snapshot_verified_flag,
      (excluded_n>0) AS delivery_date_quality_flag,
      (unresolved_association_n>0) AS unresolved_seller_association_flag,
      (late_n_ss>handoff_evaluable_late_n) AS incomplete_handoff_evidence_flag,
      eligible_n AS coverage_num, candidate_delivered_n AS coverage_den,
      eligible_n/NULLIF(candidate_delivered_n,0) AS coverage,
      late_n AS LFR_num, eligible_n AS LFR_den,
      late_n/NULLIF(eligible_n,0) AS LFR,
      CONCAT(late_n,'/',eligible_n) AS LFR_fraction,
      eligible_n-late_n AS on_time_n,
      late_n_timestamp AS LFR_timestamp_num, eligible_n AS LFR_timestamp_den,
      late_n_timestamp/NULLIF(eligible_n,0) AS LFR_timestamp,
      CONCAT(late_n_timestamp,'/',eligible_n) AS LFR_timestamp_fraction,
      eligible_n-late_n_timestamp AS on_time_n_timestamp,
      eligible_n_ms AS multi_seller_association_n,
      eligible_n-eligible_n_ms AS single_seller_association_n,
      (eligible_n_ms>0) AS multi_seller_order_flag,
      late_n_ss AS single_seller_late_n,
      late_n_ss_timestamp AS single_seller_late_n_timestamp,
      comparator_late_n AS p_num, comparator_eligible_n AS p_den,
      comparator_late_n/NULLIF(comparator_eligible_n,0) AS p_loo,
      comparator_late_n_ss AS p_ss_num, comparator_eligible_n_ss AS p_ss_den,
      comparator_late_n_ss/NULLIF(comparator_eligible_n_ss,0) AS p_ss,
      excess_burden_num/NULLIF(excess_burden_den,0) AS excess_burden,
      20 AS C, 0 AS O, 0 AS R, 20 AS S, 1 AS simulation_S_equals_C_flag,
      'full-capacity simulation (occupancy treated as 0; not authoritative for live enrollment)'
        AS capacity_scenario,
      0 AS operational_release_authorized_flag,
      CASE WHEN membership<>'YES' THEN 'NOT_A_QUALIFIER'
        WHEN selected=1 THEN 'WITHIN_AVAILABLE_SLOTS'
        ELSE 'QUALIFIED_NO_AVAILABLE_SLOT' END AS capacity_reason,
      CASE WHEN eligible_n=0 THEN '0' WHEN eligible_n<10 THEN '1-9'
        WHEN eligible_n<30 THEN '10-29' WHEN eligible_n<100 THEN '30-99'
        ELSE '100+' END AS eligible_volume_band,
      a.*
    FROM final_decision f CROSS JOIN a4_audit a;

    -- Publish nothing unless the whole judged-table invariants pass.
    SELECT COUNT(*) INTO v_bad FROM a4_judged
    WHERE late_n>eligible_n OR late_n_timestamp>eligible_n
      OR candidate_delivered_n<>eligible_n+excluded_n
      OR excluded_n<>excluded_missing_delivery_date_n+excluded_invalid_delivery_date_n
         +excluded_actual_before_purchase_n+excluded_estimated_before_purchase_n
      OR eligible_n<>eligible_n_half1+eligible_n_half2
      OR late_n<>late_n_half1+late_n_half2
      OR late_n_timestamp<>late_n_half1_timestamp+late_n_half2_timestamp
      OR eligible_n_ss<>eligible_n_ss_half1+eligible_n_ss_half2
      OR late_n_ss<>late_n_ss_half1+late_n_ss_half2
      OR late_n_ss_timestamp<>late_n_ss_half1_timestamp+late_n_ss_half2_timestamp
      OR eligible_n<>eligible_n_ss+eligible_n_ms+unclassified_association_n
      OR handoff_support_n>handoff_evaluable_late_n
      OR handoff_evaluable_late_n>late_n_ss OR late_n_ss>late_n
      OR handoff_support_n_timestamp>handoff_evaluable_late_n_timestamp
      OR handoff_evaluable_late_n_timestamp>late_n_ss_timestamp
      OR late_n_ss_timestamp>late_n_timestamp
      OR selected<>(action='ENROLL_RECOMMENDED')
      OR (selected=1 AND membership<>'YES')
      OR (membership='YES' AND `rank` IS NULL)
      OR (membership<>'YES' AND `rank` IS NOT NULL)
      OR (n5_action_disagree_flag=1 AND action<>'INCONCLUSIVE');
    IF v_bad>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: judged-table invariant failure.';
    END IF;
    SELECT (COUNT(*)<>COALESCE(MAX(valid_seller_n),0))
      OR (COALESCE(SUM(selected),0)<>LEAST(20,COALESCE(SUM(membership='YES'),0)))
      OR (COUNT(DISTINCT seller_key)<>COUNT(*)) INTO v_bad FROM a4_judged;
    IF v_bad>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SQL A halted: seller universe/capacity invariant failure.';
    END IF;

    COMMIT;
    -- Result 1: final judged seller table. All sellers; qualifiers first.
    SELECT * FROM a4_judged ORDER BY (`rank` IS NULL), `rank`, seller_key;
    -- Result 2: source/cohort audit, including unique customer-order totals.
    SELECT p_snapshot_id AS snapshot_id, p_source_version AS source_version,
      v_extracted_at AS extraction_timestamp_utc, a.* FROM a4_audit a;
    -- Result 3: actual schema metadata, for mapping and scope verification.
    SELECT table_name, ordinal_position, column_name, column_type,
      is_nullable, datetime_precision, character_set_name, collation_name
    FROM information_schema.columns WHERE table_schema='fulfilliq'
      AND table_name IN ('raw_orders','raw_order_items','raw_sellers')
    ORDER BY table_name, ordinal_position;
END$$
DELIMITER ;

CALL fulfilliq.stage04_build_sql_a(
  @a4_snapshot_id,@a4_source_version,@a4_outcome_observation_boundary,
  @a4_temporal_convention,@a4_source_verified,@a4_documented_hold_reason
);
DROP PROCEDURE fulfilliq.stage04_build_sql_a;
SET SESSION sql_mode = @a4_saved_sql_mode;
