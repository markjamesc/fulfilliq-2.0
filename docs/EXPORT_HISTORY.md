# Recovered B-table export history

## Source and status

On September 10, 2026, the owner supplied the PowerShell command reported as the Stage 4 export used on September 9, 2026. The command reads the three B tables from MySQL with `--login-path=fulfilliq --batch --raw` and writes each result through `Set-Content -Encoding utf8`.

The [readable script copy](../scripts/historical/export_B_tables_to_tsv.ps1) restores line breaks and removes Markdown escaping from the pasted text. Its output directory is a required parameter instead of the owner's local absolute path. This is a documented transcription with that portability change, not a byte-for-byte recovered original PS1 file.

The command has not been rerun or independently verified as the producer of the frozen files. The login-path name is a credential-profile reference; no password is included.

## File-size comparison

The pasted history gave approximate sizes. Inspection of the uploaded files found:

| File | Owner-reported historical bytes | Uploaded bytes | Difference |
|---|---:|---:|---:|
| B_orders.tsv | ~24,190,943 | 24,190,940 | 3 |
| B_items.tsv | ~23,544,063 | 23,544,060 | 3 |
| B_sellers.tsv | ~476,709 | 476,706 | 3 |

All three uploaded files lack a UTF-8 byte-order mark and use CRLF line endings. A UTF-8 byte-order mark is three bytes, making it a possible explanation for the size difference; the original export bytes are unavailable, so that explanation is unconfirmed.

The uploaded files match the existing Stage 4 freeze hashes. Preserve those verified bytes as the input authority. The approximate size report does not supersede the hashes.

## Re-execution scope

The recovered command selects all columns without an explicit row ordering. It preserves the historical pipeline rather than adding exit-status checks. The precise PowerShell version and original text-encoding pipeline have not been captured, and the destination files are overwritten when the command runs.

For any new export, use a separate destination directory, record the PowerShell/MySQL environment and resulting hashes, and validate the exported contents before using them. Recreating B tables also changes extraction metadata; a newly generated package must not automatically be described as byte-identical to the frozen one.

## Remaining history

The original Olist CSV-to-MySQL import script has not been found. That history gap does not block rebuilding R(B) from the three verified B TSVs already supplied.

The recovered command covers the B tables. It does not document export of the compact SQL A judged-seller file.

See [REPRODUCING.md](REPRODUCING.md) for the current verification status.
