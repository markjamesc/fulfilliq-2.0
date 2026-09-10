# Reproducing FulfillIQ 2.0

There are two distinct checks: comparing the published seller outputs, and rebuilding the analysis from raw inputs. The first works with this repository alone. The second still needs the original frozen B export package or a documented regeneration of it.

The historical analytical authority remains the [Stage 3 design](stage-03-measurement-design/Stage_03_Measurement_Design.md), [Stage 4 freeze](stage-04-execution-validation/02_EXACT_RECON_FREEZE.md), and [Finish Gate](stage-05-interpretation/05_FINISH_GATE.md). This guide does not amend their rules.

The [supplied-script index](SUPPLIED_SCRIPTS.md) maps the owner's six Stage 4 uploads to their current, historical, and diagnostic locations. The [B-table export command has been recovered from the owner's history](EXPORT_HISTORY.md). The owner-supplied conversation screenshot reports that the CSV-to-MySQL import was run interactively and no standalone import script was saved.

## 1. Compare the published outputs

Requirements: Git and Python 3. No third-party Python packages, API keys, R installation, or database are needed for this check.

```bash
git clone https://github.com/markjamesc/fulfilliq-2.0.git
cd fulfilliq-2.0
python validation/check_published_outputs.py
```

On Windows, `py -3` can be used instead of `python`.

Expected result: exit code 0 and JSON with `"status": "PASS"`, 3,095 sellers in both files, zero mismatches on the five compared fields, seven selected sellers, and two inconclusive sellers.

The checker:
- Rejects missing columns, blank or duplicate seller IDs, invalid counts, and inconsistent action/membership/selection fields.
- Requires complete seller-universe agreement and the frozen outcome counts.
- Compares `late_n`, `eligible_n`, `action`, `membership`, and `selected` by seller ID.
- Checks snapshot and specification labels in R(B); the compact SQL A export has no such columns.
- Compares integer counts rather than rounded LFR text.
- Reads files and prints a result; it does not modify outputs.

It verifies agreement between committed outputs. It does not establish that the source data, SQL, R implementation, or measurement design are independently correct. See the [September 10 verification note](../validation/PUBLISHED_OUTPUT_CHECK.md).

## 2. Restore the frozen B package for an R rebuild

The R script requires three files under the repository's `data/` directory: `B_orders.tsv`, `B_items.tsv`, and `B_sellers.tsv`. They are not currently committed.

The owner supplied all three originals during the September 10 follow-up; their hashes matched the recorded freeze. They have not yet been added to the repository, and a fresh R rebuild has not yet been performed.

Restore the original frozen export package and verify it against the existing [Stage 4 freeze record](stage-04-execution-validation/02_EXACT_RECON_FREEZE.md). This guide does not republish local filesystem details or file hashes.

Preserve the original files if making a new extraction. A snapshot label alone cannot establish that a newly exported package contains the same records.

## 3. Rebuild R(B) without overwriting the published result

Requirements: R and the `tidyverse`, `lubridate`, and `janitor` packages. The [reported R environment](R_ENVIRONMENT.md) records the owner's current R version and seven installed package versions from console screenshots. It is not a complete dependency lock or confirmation of the original execution environment.

From R with the repository root as the working directory:

```r
install.packages(c("tidyverse", "lubridate", "janitor"))

source("r/Stage_04_R_B_rebuild.R")
run_stage04_rb(
  config = CONFIG,
  out_csv = "results/reproduced/R_B_judged_seller.csv",
  out_rds = "results/reproduced/R_B_judged_seller.rds"
)
writeLines(
  capture.output(sessionInfo()),
  "results/reproduced/sessionInfo.txt"
)
```

Then compare the rebuilt output with the frozen A export:

```bash
python validation/check_published_outputs.py --b results/reproduced/R_B_judged_seller.csv
```

This is a fresh R(B) check only if the input package was actually restored and the R code executed successfully. The documented September 10 public-output check did not perform this rebuild.

## 4. Rebuild SQL from the source database

The implementation targets **MySQL 8.0**. The historical [database context](stage-03-measurement-design/FulfillIQ_Database_Context_V1_READONLY.md) documents the source-table schemas and original import behavior. It is reference material, not a new verification of the V2 database.

Required source relations:

| Relation | Key | Historical reference row count |
|---|---|---:|
| `fulfilliq.raw_orders` | `order_id` | 99,441 |
| `fulfilliq.raw_order_items` | `order_id, order_item_id` | 112,650 |
| `fulfilliq.raw_sellers` | `seller_id` | 3,095 |

The original source archive/checksums and an executable raw-data import recipe are not committed. A conversation screenshot supplied by the owner on September 10, 2026 reports that the import used interactive `LOAD DATA LOCAL INFILE` queries, with MySQL Shell used for reviews cleanup, and was not saved as an import script. This records the reported method; the exact query text and execution log were not supplied. Reviews cleanup is separate from the three-table analytical path used here.

There is no saved import file to keep requesting on the basis of that report. Any future import script must be labeled as a new reconstruction and validated against the documented schema and data. Row counts alone cannot prove source identity or exact historical reproduction.

Once a matching source database is verified:

1. Use a dedicated development schema matching the scripts' `fulfilliq` mapping. SQL A recreates ordinary `a4_*` tables; SQL B recreates `B_*` tables. Keep the source `raw_*` tables frozen.
2. Run [plain SQL A](../sql/Stage_04_SQL_A_plain.sql) with a client that stops on the first error. It requires source reads and creation/deletion of its output tables; it does not require stored-routine privileges.
3. Run [SQL B](../sql/Stage_04_SQL_B.sql) independently against those same source tables. It projects raw relations without using A's judgments. Supply the database as the client default because SQL B does not issue `USE fulfilliq`.
4. Export A's `seller_id, late_n, eligible_n, LFR, action, membership, selected` from `fulfilliq.a4_judged_seller` to a headered TSV. Export `B_orders`, `B_items`, and `B_sellers` to separate headered TSVs.
5. Record encoding, null representation, temporal convention, row counts, export order, extraction time, and file hashes. Ensure missing timestamps are read as missing values by R. The [recovered B export command](EXPORT_HISTORY.md) documents its flags and pipeline; the precise PowerShell environment and the compact A export command remain undocumented.
6. Run R(B) from those exports, freeze both results, then invoke the checker with `--a` and `--b` pointing to the new files. Keep comparison outside both independent builders.

Documented SQL A command:

```bash
mysql --skip-force -u fulfilliq_user -p fulfilliq < sql/Stage_04_SQL_A_plain.sql
```

Do not assume that hard-coded `source_verified=1` or snapshot labels verify the database. Those are recorded assertions; source verification must precede execution. The historical identity-alignment script also changes labels, not data provenance.

## Reproducibility status and remaining work

- Received: the three original frozen B TSV files; their hashes matched the existing freeze record. Public distribution of the input package remains pending.
- Recorded: [owner-reported R and installed package versions](R_ENVIRONMENT.md). A complete dependency record from a successful execution remains pending.
- Recovered: [the owner-reported B-table export command](EXPORT_HISTORY.md), with transcription changes and a three-byte file-size discrepancy documented.
- Import history clarified: the supplied conversation reports interactive `LOAD DATA LOCAL INFILE` execution; no standalone import script was saved. Exact query text remains unavailable.
- Optional historical evidence, if already available: the original source dataset archive/version, SQL query history, compact A export command, and PowerShell version. These are not prerequisites for rebuilding R(B) from the verified TSVs.
- Next execution step: rerun R(B) from the verified files, preserve the fresh results separately, capture the loaded environment, and compare with the published A output.

The portfolio's recorded simulation completion remains distinct from these outstanding public reproducibility tasks.
