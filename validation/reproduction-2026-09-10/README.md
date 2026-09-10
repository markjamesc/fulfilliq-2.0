# Fresh R(B) reproduction — September 10, 2026

**PASS within the reproduction scope.** The unchanged committed R(B) script was executed against the three owner-supplied frozen B TSVs in a separate Linux R environment. The resulting CSV is **byte-for-byte identical** to the previously published R(B) CSV.

## Verified results

| Check | Result |
|---|---|
| Input identities | All three TSV hashes match the original Stage 4 freeze |
| Builder | Committed R script unchanged; matches the uploaded script |
| Fresh execution | Exit code 0 |
| Comparison with frozen SQL A | 3,095 sellers; zero differences in late_n, eligible_n, action, membership, selected |
| Selected / inconclusive sets | Identical to A: 7 selected and 2 inconclusive |
| Other actions | 3,086 standard; 0 watch |
| Comparison with published R(B) | All 82 columns and all 3,095 rows reproduced; entire CSV byte-identical |

Both the fresh CSV and the [published CSV](../../results/R_B_judged_seller.csv) have SHA-256 `58482f6d84a2b60f6e6ae7742302b091693c96650d9ff02487af32545d564cc0`.

## Evidence

- [Execution and comparison manifest](manifest.json)
- [Checker output](reconciliation.json)
- [Loaded R session](sessionInfo.txt)
- [Installed package versions](installed_packages.csv)
- [Reusable execution wrapper](../../scripts/reproduce_rb.R)
- [Original input freeze record](../../docs/stage-04-execution-validation/02_EXACT_RECON_FREEZE.md)

The checker JSON describes the comparison component as a published-output comparison. In this run its B argument was the newly generated CSV; the separate R execution is recorded in the manifest. The builder itself does not read the A export, and comparison occurs afterward.

## Parsing warning investigated

The unchanged reader reports 4,748 timestamp parsing issues in the orders input. Inspection of every reported issue showed the literal `NULL`: 1,783 carrier-delivery timestamps and 2,965 customer-delivery timestamps. The reader converts those tokens to missing values. No other problematic token was reported; the items and sellers inputs had zero parsing issues.

This warning remains visible in the unchanged implementation. No data or business rules were changed to suppress it. The reproduced output matches the frozen output exactly.

## Environment and limits

Execution used R 4.3.3 on 64-bit Ubuntu, with tidyverse 2.0.0, dplyr 1.1.4, readr 2.1.5, tidyr 1.3.1, purrr 1.0.2, lubridate 1.9.3, and janitor 2.2.1. R and its packages were installed in an isolated runtime; the session and package records above describe the actual loaded environment. This differs from the owner's reported Windows R 4.0.3 installation.

This demonstrates reproducibility of the committed R transformation on the frozen inputs. It does not rerun MySQL, recover the original CSV import, establish causal validity, or prove the plan will improve delivery performance. Existing historical gates are unchanged.

The three raw B TSVs remain outside the public repository pending explicit approval to publish them. They have been supplied and verified locally; no additional upload from the owner is needed for this completed reproduction.

## Repeat when the inputs are available

From the repository root, after installing the documented packages and placing the original TSVs in `data/`:

```bash
Rscript scripts/reproduce_rb.R results/reproduced/my-run
python validation/check_published_outputs.py --b results/reproduced/my-run/R_B_judged_seller.csv
```

Choose a new output directory for each run. The wrapper preserves existing nonempty run directories and records the execution environment. It invokes the original builder without changing its configuration or analytical logic.
