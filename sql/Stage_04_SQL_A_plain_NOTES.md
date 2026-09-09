# Stage_04_SQL_A_plain — NOTES

**Artifact:** `sql/Stage_04_SQL_A_plain.sql`  
**Spec:** `fulfilliq-2.0-stage3-candidate-v0.2.1`  
**Date:** 2026-09-08 (America/Chicago)  
**Engine:** MySQL 8 ordinary session SQL (no stored routines)

## Why this file exists

`Stage_04_SQL_A.sql` wraps Stage 3 judged-seller logic in `CREATE PROCEDURE` / `DELIMITER` / `CALL` / `DROP PROCEDURE`. The `fulfilliq_user` account lacks `CREATE ROUTINE`, so procedure creation fails with CREATE PROCEDURE denied.

This plain script implements the **same** Stage 3 v0.2.1 judged-seller logic by unwrapping the procedure body into session SQL + `TEMPORARY` tables. Final output is lasting table `fulfilliq.a4_judged_seller`.

## Privileges required

- `SELECT` on frozen `raw_orders`, `raw_order_items`, `raw_sellers`
- `CREATE` / `DROP` `TEMPORARY` TABLES
- `CREATE` / `DROP` TABLE on `fulfilliq` (for `a4_judged_seller`)
- **Not required:** `CREATE ROUTINE`, `EXECUTE`, `ALTER ROUTINE`, `CREATE TEMPORARY TABLES`

## Documented session vars (this run)

| Variable | Value |
| --- | --- |
| `@a4_snapshot_id` | `fulfilliq-olist-frozen-2026-09-08` |
| `@a4_source_version` | `olist-csv-raw_tables` |
| `@a4_outcome_observation_boundary` | `snapshot_extraction_time` |
| `@a4_temporal_convention` | `source_as_stored` |
| `@a4_source_verified` | `1` |
| `@a4_documented_hold_reason` | `NULL` |

Capacity: **C=20**, simulated **O=0 / R=0**, **S=20** (full-capacity simulation).

## Independence

- Must **not** read SQL B (`B_orders` / `B_items` / `B_sellers`), B intermediates, B judgments, R(B), V1 decisions, or recon feedback.
- Inputs: frozen `fulfilliq.raw_*` + locked Stage 3 / Stage 4 packet only.
- Do **not** invent featured / catalog / plan-enrollment columns.
- No padding; membership-first, then rank qualifiers under S.

Note: B tables may already exist in the same schema; this script does not query them.

## Conversion notes

- Procedure `DECLARE` locals → session vars (`@a4_v_bad`, `@a4_v_columns`, `@a4_extracted_at`).
- Procedure params → the documented `@a4_*` session vars above.
- `SIGNAL` / EXIT handlers → plain-SQL halt asserts (`@a4_halt_cond` + PREPARE/EXECUTE unknown-column only when cond=1). Client must stop on first error (no `mysql --force`).
- Intermediate tables are ordinary `a4_*` scratch tables (same names as the procedure temps; dropped at start). Adapted because `fulfilliq_user` lacked `CREATE TEMPORARY TABLES`.
- After invariants pass and `COMMIT`, results are copied to lasting **`a4_judged_seller`** (ordered: qualifiers first by `rank`, then `seller_key`).
- Result sets: (1) `a4_judged_seller`, (2) audit row, (3) `information_schema` column metadata for the three raw tables.

## Output

Permanent table: **`fulfilliq.a4_judged_seller`**

Includes (non-exhaustive): `seller_id` / `seller_key`, `late_n`, `eligible_n`, `LFR` / LFR fraction pairs, twin timestamp fields, N4/N5 flags, multi-seller / single-seller counts, gates, `membership`, `rank`, `selected`, `action`, capacity C/O/R/S + `simulation_S_equals_C_flag`, snapshot/audit columns. No featured columns.

## How to run

```bash
mysql --skip-force -u fulfilliq_user -p fulfilliq < sql/Stage_04_SQL_A_plain.sql
```

Use one dedicated connection (TEMPORARY tables are session-scoped). Inspect `a4_judged_seller` after success.
