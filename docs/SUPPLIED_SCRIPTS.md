# Supplied Stage 4 scripts

Owner-supplied files reviewed and indexed on September 10, 2026. Four uploads exactly matched the existing GitHub blobs. The other two are preserved below as historical or diagnostic artifacts.

## File map

| Uploaded filename | Repository location | Role and status |
|---|---|---|
| `Stage_04_SQL_A_plain.sql` | [Plain SQL A](../sql/Stage_04_SQL_A_plain.sql) | Main ordinary-session SQL A implementation; uploaded bytes match the existing file. |
| `Stage_04_R_B_rebuild.R` | [R(B) rebuild](../r/Stage_04_R_B_rebuild.R) | R rebuild from the three B exports; uploaded bytes match the existing file. |
| `Stage_04_SQL_A(1).sql` | [Procedure-based SQL A](../sql/Stage_04_SQL_A.sql) | Original stored-procedure variant; uploaded bytes match this existing canonical filename. |
| `Stage_04_align_B_snapshot.sql` | [Snapshot-label alignment](../sql/Stage_04_align_B_snapshot.sql) | Updates metadata labels on existing B tables; uploaded bytes match the existing file. |
| `Stage_04_SQL_B.sql` | [Historical SQL B with pending labels](../sql/historical/Stage_04_SQL_B_pending.sql) | Earlier upload with `PENDING_STAGE4_SNAPSHOT_ID` and `PENDING_STAGE4_SOURCE_VERSION`; preserved as supplied. |
| `_halt_repro.sql` | [Halt-condition diagnostic](../sql/diagnostics/_halt_repro.sql) | Minimal debugging example for the SQL A assertion/stop behavior; preserved as supplied. |

## Recovered export command

The owner subsequently supplied the [B-table export command](../scripts/historical/export_B_tables_to_tsv.ps1). See [export-history notes](EXPORT_HISTORY.md) for its provenance, the public-copy destination parameter, and the observed file-size difference.

## How to use these records

For the documented reproduction path, start with [plain SQL A](../sql/Stage_04_SQL_A_plain.sql), [current SQL B](../sql/Stage_04_SQL_B.sql), and [R(B)](../r/Stage_04_R_B_rebuild.R).

The historical SQL B copy retains the uploaded placeholder labels and trailing control characters. It is an archival record; the current SQL B has the recorded snapshot labels and the documented control-character cleanup.

The halt diagnostic includes a deliberately unresolved column reference within a conditional expression. It documents investigation of the assertion behavior and may raise an SQL error. It is not a required analysis or validation step.

The snapshot-alignment script changes metadata labels. Running it does not establish that the underlying data match the frozen source package.

## Reproduction status

These files document the analysis implementation and part of its debugging history. The owner has now supplied the B-table MySQL-to-TSV export command. The original Olist CSV-to-MySQL import script remains missing; the compact A export command is also not included in the recovered B export.

The supplied scripts were inspected and compared with GitHub, not executed during this addition. The earlier output comparison remains distinct from a fresh raw-input rebuild.

See [REPRODUCING.md](REPRODUCING.md) for input requirements and execution steps, and [R_ENVIRONMENT.md](R_ENVIRONMENT.md) for the reported R installation.
