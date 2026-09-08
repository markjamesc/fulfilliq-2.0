# Version Change Ledger

Status: **initialized stub**. Rows are filled as FulfillIQ 2.0 stages run.

| Topic | Version 1 approach | Version 2 approach | Retained | Changed | Why | Framework | Practical improvement |
|---|---|---|---|---|---|---|---|
| Repository | `markjamesc/fulfilliq` | `markjamesc/fulfilliq-2.0` | V1 as historical baseline | New authoritative repo | Prompt requires separation | Master orchestration | Clear V1 vs V2 provenance |
| Stage 4 recon | R rechecked SQL A CSV (one clerk, two pens) | SQL A + SQL B + R(B) | Same DB / Olist context expected | Independent grain dump + rebuild | Reduce shared implementation error | Validation framework | Two implementations, one spec |
| Process records | Partial docs on V1 | Full stage records, gates, ledgers | Continuity of Maya scenario as context only | New dialogue and gates required | Demonstrate methodology | All stage frameworks | Auditable 2.0 run |

Do not treat a blank cell as a passed gate.
