# FulfillIQ 2.0

AI-augmented e-commerce analytics case study using MySQL, SQL, R, and a five-stage decision workflow with three-AI review.

This repository is the authoritative home for **FulfillIQ Version 2**. Version 1 remains at [markjamesc/fulfilliq](https://github.com/markjamesc/fulfilliq) as a read-only historical baseline.

## Status

**Shell only.** Repository structure and the master orchestration prompt are in place. Stages 1–5 have not started. No execution, reconciliation, or gate has passed.

## Methodology (summary)

1. **Start and Framing** — stakeholder dialogue (Maya Chen, fictional) to lock the decision and analytical question  
2. **Measurement Design** — hypothesis, grain, KPI, peer rules, validation criteria  
3. **Execution and Validation** — SQL A (KPI), SQL B (lower-grain dump), R(B) rebuild, exact reconciliation  
4. **Deeper Analysis** — only after reconciliation passes  
5. **Interpretation and Recommendation** — evidence-bounded decision support  

Three separate AI instances review independently where the frameworks require it. Merge is not a vote. Human-owner approvals remain required at framework gates.

## Version 1 vs Version 2

| | Version 1 | Version 2 |
|---|---|---|
| Repo | [fulfilliq](https://github.com/markjamesc/fulfilliq) | this repo |
| SQL | Judged seller export (Clerk A) | SQL A + SQL B + R(B) recon |
| Process record | Partial | Full stage records, gates, ledgers |

See `docs/version-change-ledger.md` (stub until the run begins).

## Artifact map

| Path | Role |
|---|---|
| `docs/orchestration/` | Master prompt, framework manifest, conversation record |
| `docs/stage-01-02-start-framing/` | Dialogue and handoff |
| `docs/stage-03-measurement-design/` | Locked measurement design |
| `docs/stage-04-execution-validation/` | Execution and validation records |
| `docs/stage-05-interpretation/` | Recommendation pack |
| `sql/sql-a/` | Final KPI SQL |
| `sql/sql-b/` | Independent lower-grain SQL |
| `R/` | R workflow (ENGINE.md style) |
| `outputs/` | Exports and workbooks |
| `validation/` | Reconciliation evidence |
| `data-documentation/` | Database context and profiles |

## Controlling frameworks

Links and retrieval dates will be recorded in `docs/orchestration/controlling-framework-manifest.md` when the authorized run starts.

## Reproduce

Not yet. Wait until Stage 4 execution evidence is present and labeled.

## License

Copyright 2026 Mark Ciganovic. Portfolio use only unless a LICENSE file is added later.
