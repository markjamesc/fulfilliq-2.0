# FulfillIQ 2.0

An AI-augmented e-commerce analytics case study using **MySQL, SQL, R, and Tidyverse** to turn a seller-performance request into a documented investigation decision.

**Completed simulation case study.** Validation, Finish, and Recommendation gates are recorded as **Pass on September 9, 2026**. [Gate log](docs/orchestration/gate-log.md) · [Finish Gate](docs/stage-05-interpretation/05_FINISH_GATE.md).

The project uses historical Brazilian Olist data and a fictional stakeholder, Maya Chen. Its seven selected sellers are **simulation investigation signals**, not live enrollment instructions or findings of seller fault.

## Executive result

The locked rules assess membership before applying a capacity limit of 20. Seven sellers qualify for investigation; unused capacity is left open.

| Outcome | Sellers |
|---|---:|
| Investigation candidates (`ENROLL_RECOMMENDED` in the simulation output) | 7 |
| Unresolved date/timestamp classifications (`INCONCLUSIVE`) | 2 |
| Standard / not qualified under the rules | 3,086 |
| Watch | 0 |
| Total seller universe | 3,095 |

SQL A and the independent R rebuild of SQL B's raw exports agree across all 3,095 sellers on **late counts, eligible counts, action, membership, and selection** in the recorded freeze. Matching integer counts establish the same late-rate fractions; rounded display rates are not the reconciliation authority.

**Read the outcome:** [decision evaluation and candidate inventory](docs/stage-05-interpretation/04_STAGE5_DECISION_EVALUATION.md).  
**Inspect the evidence:** [reconciliation freeze](docs/stage-04-execution-validation/02_EXACT_RECON_FREEZE.md) · [SQL A output](results/A_judged_seller_freeze.tsv) · [R(B) output](results/R_B_judged_seller.csv).

## What validation caught

The first R(B) run omitted **765 zero-eligible sellers** and disagreed with SQL A on **five actions**. The reconciliation record attributes these differences to incomplete half-window rules, an incomplete date/timestamp sensitivity implementation, and an incomplete seller universe.

The coordinator repaired R(B) against the locked measurement design and reran the comparison. The final freeze records full agreement, the same seven selected sellers, and the same two inconclusive sellers.

This demonstrates how independently built paths can expose implementation differences. Agreement verifies consistency on the frozen pack; it does not establish that the measurement design is causally valid or that an improvement plan will work.

## My contribution and AI roles

I own the portfolio project and the human approvals recorded at the decision, framing, design, and finish gates. My analyst responsibility is to approve the question and measurement rules, assess the evidence, and accept a recommendation within its limits.

The [approval record](docs/stage-01-02-start-framing/08_STAKEHOLDER_REVISIONS_AND_APPROVAL.md) distinguishes my approvals from the simulated stakeholder dialogue. The [builder record](docs/stage-04-execution-validation/02_EXACT_RECON_FREEZE.md) attributes SQL A to ChatGPT, SQL B to Grok, and R(B) to DeepSeek with coordinator repairs. AI-generated code and coordinator fixes are identified explicitly.

The approved approach preserves membership-first selection, no padding, and unresolved classifications. The final handoff supports investigation rather than claims of fault, current operational performance, or proven plan effectiveness.

## Five-stage workflow

| Stage | Work | Start here |
|---|---|---|
| 1. Start | Identify the decision behind the metric request | [Approved decision](docs/stage-01-02-start-framing/05_APPROVED_DECISION_STATEMENT.md) |
| 2. Framing | Lock the analytical question and membership-first rule | [Final question](docs/stage-01-02-start-framing/09_FINAL_ANALYTICAL_QUESTION.md) |
| 3. Design | Define population, grain, KPI, comparison rules, and safeguards | [Measurement design](docs/stage-03-measurement-design/Stage_03_Measurement_Design.md) |
| 4. Execution | Build SQL A and SQL B independently; rebuild B in R; reconcile and review | [Freeze](docs/stage-04-execution-validation/02_EXACT_RECON_FREEZE.md) · [Structural review](docs/stage-04-execution-validation/03_STRUCTURAL_CROSS_REVIEW.md) |
| 5. Finish | Interpret the validated simulation and approve its bounded handoff | [Decision evaluation](docs/stage-05-interpretation/04_STAGE5_DECISION_EVALUATION.md) · [Finish Gate](docs/stage-05-interpretation/05_FINISH_GATE.md) |

This completed run is descriptive. It does not include a predictive model or an estimate of the plan's causal effect.

## Code and reproducibility

| Artifact | Purpose |
|---|---|
| [Plain SQL A](sql/Stage_04_SQL_A_plain.sql) | Judged seller table using ordinary MySQL session SQL |
| [SQL B](sql/Stage_04_SQL_B.sql) | Raw orders, items, and sellers projections for independent rebuilding |
| [R(B) script](r/Stage_04_R_B_rebuild.R) | Rebuild seller judgments from the B exports |
| [Published-output checker](validation/check_published_outputs.py) | Compare the committed SQL A and R(B) outputs without a database |
| [Reproduction guide](docs/REPRODUCING.md) | Commands, dependencies, data requirements, and remaining gaps |
| [Framework manifest](docs/orchestration/controlling-framework-manifest.md) | Controlling workflow sources |
| [Version change ledger](docs/version-change-ledger.md) | V1/V2 process history |

With Python 3, run this from the repository root:

```bash
python validation/check_published_outputs.py
```

The checker reads already-published outputs. **A fresh raw-data rebuild still requires the three frozen B TSV inputs**, which are not committed. The reproduction guide distinguishes this output comparison from independently rerunning SQL and R.

## Scope and limitations

- Historical delivered orders purchased January 1–August 31, 2018; this does not describe current seller performance.
- Capacity is a simulation: C=20, occupancy=0, reservations=0, available slots=20.
- The two inconclusive sellers remain unresolved for enrollment.
- Selection reflects the locked rules, not proof of seller fault or plan effectiveness.
- A real operational release would need current data, actual capacity, case investigation, and an accountable decision owner.
- First builds were isolated; after comparison, documented coordinator repairs were made against the specification.

## Related work

[Version 1 historical baseline](https://github.com/markjamesc/fulfilliq) · [Five-stage workflow](https://github.com/markjamesc/ai-augmented-analyst-workflow) · [Bitcoin proxy analysis](https://github.com/markjamesc/ai-augmented-bitcoin-proxy-analysis)

## License

Copyright 2026 Mark Ciganovic. Portfolio use only unless a LICENSE file is added later.
