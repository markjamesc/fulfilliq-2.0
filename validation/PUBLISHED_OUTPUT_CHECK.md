# Published-output verification — September 10, 2026

The [published-output checker](check_published_outputs.py) was executed against the committed SQL A and R(B) seller exports during the portfolio documentation update.

## Observed result

| Check | Result |
|---|---|
| SQL A / R(B) seller rows | 3,095 / 3,095 |
| Seller-ID overlap | 3,095; zero IDs exclusive to either file |
| Mismatches: late_n, eligible_n, action, membership, selected | 0 for every compared field |
| Selected seller sets | Identical; 7 sellers |
| Inconclusive seller sets | Identical; 2 sellers |
| Action counts in both files | 7 ENROLL_RECOMMENDED; 2 INCONCLUSIVE; 3,086 STANDARD_NOT_QUALIFIED; 0 WATCH |
| R(B) snapshot and specification labels | Match the recorded freeze |
| Exit status | 0 / PASS |

Negative checks also confirmed that a changed late count, an omitted seller, and a duplicate seller cause failure.

## Scope

This check reads published outputs. It does not rerun SQL or R, reconstruct raw inputs, validate the original input hashes, prove builder independence, or establish causal validity. The compact A export has no snapshot fields; its provenance remains linked through the original freeze record.

The original Stage 4 freeze and Stage 5 gate records remain the authority for the historical run. This verification is supplementary evidence, not a replacement gate or a claim of full raw-data reproduction.

## Maintenance changes

The SQL A plain-script notes were corrected to describe the ordinary scratch tables actually used by the committed implementation.

Three trailing non-SQL control characters (form feed, escape, and device control 4) were removed from SQL B. Its SQL statements and business logic are unchanged. SQL B was not executed in this documentation update; the frozen results were not regenerated.

## Repeat the check

From the repository root with Python 3:

```bash
python validation/check_published_outputs.py
```

See [the reproduction guide](../docs/REPRODUCING.md) for the raw-data requirements.
