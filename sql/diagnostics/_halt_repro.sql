SET @a4_snapshot_id = 'fulfilliq-olist-frozen-2026-09-08';
SET @a4_source_version = 'olist-csv-raw_tables';
SET @a4_outcome_observation_boundary = 'snapshot_extraction_time';
SET @a4_temporal_convention = 'source_as_stored';
SET @a4_source_verified = 1;
SET @a4_halt_cond = (COALESCE(@a4_source_verified,0) <> 1 OR NULLIF(TRIM(@a4_snapshot_id),'') IS NULL OR NULLIF(TRIM(@a4_source_version),'') IS NULL OR NULLIF(TRIM(@a4_outcome_observation_boundary),'') IS NULL OR NULLIF(TRIM(@a4_temporal_convention),'') IS NULL);
SELECT @a4_source_verified AS v, @a4_halt_cond AS halt, CASE WHEN @a4_halt_cond THEN 'WOULD_HALT' ELSE 'ok' END AS branch;
SET @a4_assert = (SELECT CASE WHEN 0 THEN (SELECT `SQL_A_halted:_verified_snapshot_source_boundary_required` FROM (SELECT 1) AS _a4_halt) ELSE 0 END);
SELECT @a4_assert AS assert_when_false;
