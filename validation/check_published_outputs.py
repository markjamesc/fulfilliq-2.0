#!/usr/bin/env python3
"""Compare published FulfillIQ outputs; does not rerun or certify SQL/R logic."""
import argparse
import csv
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
FIELDS = ("late_n", "eligible_n", "action", "membership", "selected")
EXPECTED = {
    "ENROLL_RECOMMENDED": 7,
    "INCONCLUSIVE": 2,
    "STANDARD_NOT_QUALIFIED": 3086,
    "WATCH": 0,
}
SNAPSHOT = "fulfilliq-olist-frozen-2026-09-08"
SPEC = "fulfilliq-2.0-stage3-candidate-v0.2.1"


def boolean(value):
    if value in ("1", "TRUE", "true"):
        return True
    if value in ("0", "FALSE", "false"):
        return False
    raise ValueError("Invalid selected flag: " + repr(value))


def read_table(path, delimiter, check_identity=False):
    rows = {}
    with path.open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream, delimiter=delimiter)
        required = {"seller_id", *FIELDS}
        if check_identity:
            required |= {"snapshot_id", "specification_id"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(str(path) + ": missing columns " + repr(sorted(missing)))
        for line, row in enumerate(reader, 2):
            seller = row["seller_id"]
            if not seller or seller in rows:
                raise ValueError(str(path) + ": blank/duplicate seller at line " + str(line))
            late, eligible = int(row["late_n"]), int(row["eligible_n"])
            if not 0 <= late <= eligible:
                raise ValueError(str(path) + ": invalid counts for " + seller)
            action, membership = row["action"], row["membership"]
            selected = boolean(row["selected"])
            if action not in EXPECTED:
                raise ValueError(str(path) + ": unrecognized action for " + seller)
            expected_membership = (
                "INCONCLUSIVE" if action == "INCONCLUSIVE"
                else "YES" if action in ("ENROLL_RECOMMENDED", "WATCH")
                else "NO"
            )
            if membership != expected_membership or selected != (action == "ENROLL_RECOMMENDED"):
                raise ValueError(str(path) + ": inconsistent judgment fields for " + seller)
            if check_identity and (
                row["snapshot_id"] != SNAPSHOT or row["specification_id"] != SPEC
            ):
                raise ValueError(str(path) + ": unexpected snapshot/specification for " + seller)
            rows[seller] = dict(
                late_n=late, eligible_n=eligible, action=action,
                membership=membership, selected=selected,
            )
    if not rows:
        raise ValueError(str(path) + ": no data rows")
    return rows


def compare(a, b):
    common = set(a) & set(b)
    mismatches = {
        field: sum(a[seller][field] != b[seller][field] for seller in common)
        for field in FIELDS
    }
    counts_a = {key: sum(row["action"] == key for row in a.values()) for key in EXPECTED}
    counts_b = {key: sum(row["action"] == key for row in b.values()) for key in EXPECTED}
    selected_a = {key for key, row in a.items() if row["selected"]}
    selected_b = {key for key, row in b.items() if row["selected"]}
    inconclusive_a = {key for key, row in a.items() if row["action"] == "INCONCLUSIVE"}
    inconclusive_b = {key for key, row in b.items() if row["action"] == "INCONCLUSIVE"}
    passed = (
        len(a) == len(b) == len(common) == 3095
        and not any(mismatches.values())
        and counts_a == counts_b == EXPECTED
        and selected_a == selected_b
        and inconclusive_a == inconclusive_b
    )
    return {
        "status": "PASS" if passed else "FAIL",
        "scope": "published-output comparison; no raw-data rebuild or causal validation",
        "seller_rows": {"SQL_A": len(a), "R_B": len(b), "overlap": len(common)},
        "seller_ids_only_in_A": len(set(a) - set(b)),
        "seller_ids_only_in_R_B": len(set(b) - set(a)),
        "field_mismatch_counts": mismatches,
        "action_counts_SQL_A": counts_a,
        "action_counts_R_B": counts_b,
        "selected_set_matches": selected_a == selected_b,
        "inconclusive_set_matches": inconclusive_a == inconclusive_b,
        "rate_comparison": "integer numerators and denominators; displayed LFR excluded",
        "snapshot_note": "R(B) identity fields checked; A export has no snapshot column",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--a", type=Path, default=ROOT / "results/A_judged_seller_freeze.tsv")
    parser.add_argument("--b", type=Path, default=ROOT / "results/R_B_judged_seller.csv")
    args = parser.parse_args()
    try:
        result = compare(read_table(args.a, "\t"), read_table(args.b, ",", True))
    except (OSError, ValueError, KeyError, TypeError, csv.Error) as error:
        print(json.dumps({"status": "FAIL", "error": str(error)}, indent=2))
        return 1
    print(json.dumps(result, indent=2))
    return 0 if result["status"] == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
