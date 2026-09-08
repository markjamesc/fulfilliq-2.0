# 10 — Stage 3 Measurement Design Handoff

**Project:** FulfillIQ 2.0  
**Handoff date:** 2026-09-08 (America/Chicago)  
**From:** Stages 1–2 Start & Framing (framework: `docs/orchestration/frameworks/three-ai-start-and-framing-dialogue-framework.md`)  
**To:** Stage 3 Measurement Design  
**Gate status:** Start Gate **Pass**; Framing Gate **Pass** (Mark APPROVED both; Maya T8/T14 synthetic)

---

## 1. Approved decision statement

Maya Chen must decide which marketplace sellers, if any, to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms, in order to reduce late customer deliveries under a hard concurrent capacity of about 20 (no padding; enroll fewer if fewer clearly meet the bar), by the mid-month VP ops meeting; tiny-volume sellers stay on standard terms; featured placement is out; enrollment is ops capacity allocation, not an RCT; exact numeric cutoffs are deferred to Stage 3 measurement only where they serve this enrollment.

---

## 2. Locked analytical question

> Under the locked concurrent capacity of about 20, with tiny-volume sellers remaining on standard terms, which sellers, if any, have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer operational check-ins and a seller corrective path rather than ordinary marketplace monitoring?

**Membership rule:** Yes/no eligibility first; if more than ~20 qualify, rank qualifiers within the cap; if fewer, enroll fewer with no padding; non-qualifiers stay ordinary monitoring (T12).

---

## 3. Locked constraints (do not reopen without new stakeholder/owner authority)

| Constraint | Detail | Evidence |
|---|---|---|
| Capacity | Hard concurrent cap ~20; no padding | T4, T8 |
| Tiny-volume | Remain on standard terms | T6, T8 |
| Featured placement | Out of scope for this review | T2 |
| Decision type | Ops enrollment — not RCT / causal experiment | T6, T8 |
| Plan horizon | About 30 days | T6, T10 |
| Intervention | Documented plan; closer ops check-ins; seller corrective path | T10 |
| Non-enrollment | Ordinary marketplace monitoring only | T10 |
| Not this decision | Permanent offboarding; catalog/featured changes | T10 |
| Outcome | Fewer late customer deliveries under ops capacity | T8 |
| Deadline context | Mid-month VP ops meeting | T0–T2 |

---

## 4. Deferred to Stage 3 (and later) — design here, do not invent at Framing

- Exact numeric cutoffs for “meaningfully worse than pack” late rates on delivered orders
- Volume / “not noise” floor (tiny-volume operationalization)
- Measurement window / lookback for late-delivery rates
- SQL grain, KPI formulas, data-quality rules
- Ranking method among qualifiers if >~20 meet eligibility
- Tie-break rules under the cap
- Any Stage 4–5 evaluation / success criteria / causal detection (raised by AI3 Framing R1) — do not rewrite the locked enrollment question into an experiment

---

## 5. What Stage 3 must NOT rewrite

- The approved decision statement
- The locked analytical question wording
- Capacity ~20 / no-padding / enroll-fewer rule
- Tiny-volume stay standard
- Featured placement exclusion
- Non-RCT / ops-enrollment character of the decision
- Membership-first rule (yes/no then rank-if-over-cap)
- Maya synthetic vs Mark real-approval distinction in the audit trail

---

## 6. Chat URL summary (AI separate chats)

| Role | Round | URL |
|---|---|---|
| AI 1 Dialogue Lead | T1 | https://chatgpt.com/c/6aa08656-bde4-83ea-aa21-5c3357dffa29 |
| AI 1 Dialogue Lead | T3 | https://chatgpt.com/c/6aa08da3-e8e8-83e9-9dc2-63b798201378 |
| AI 1 Dialogue Lead | T5 | https://chatgpt.com/c/6aa09183-10b4-83e8-87a7-f63a32cc378b |
| AI 1 Dialogue Lead | T7 / Framing T9–T13 | https://chatgpt.com/c/6aa095b0-230c-83e8-8eea-be716c28c255 |
| AI 2 Start R1 | T0–T2 | https://grok.com/c/ae6c69b1-d1fd-4179-ae4b-dbc92c646260?rid=3ab2fdbf-4e02-407c-b14d-9601f5ad0a59 |
| AI 2 Start R2 | T0–T4 | https://grok.com/c/760baf78-5a89-4310-831c-411ef5455380?rid=049c264c-c149-4c1d-80e4-4d0b57532e80 |
| AI 2 Start R3 | T0–T6 | https://grok.com/c/6c8f6f62-58ea-47bd-a2f0-c517e4faa43c?id=a8feec255-0ae6-407d-b428-66ba7af93dd |
| AI 2 Framing R1 | Start locked + T9–T10 | https://grok.com/c/e8e8aef6-c82a-4592-b28f-36956c622a76?rid=6f96ac53-ee6d-4eb7-b985-ae009a48f743 |
| AI 3 Start R1 | T0–T2 | https://chat.deepseek.com/a/chat/s/403d2b8b-3e29-4805-8cfe-27286fc45257 |
| AI 3 Start R2 | T0–T4 | https://chat.deepseek.com/a/chat/s/8c035efb-e462-41ba-af04-28c45f78bce5 |
| AI 3 Start R3 | T0–T6 | https://chat.deepseek.com/a/chat/s/2eb5933b-2d9a-4216-bae9-2a88746e3d8f |
| AI 3 Framing R1 | Framing | https://chat.deepseek.com/a/chat/s/4fe97600-b42a-4489-b9dc-ca6310d75c7f |

Full verbatim dialogue: `01_ORIGINAL_REQUEST_AND_VERBATIM_DIALOGUE.md`.

---

## 7. Gate status

| Gate | Result | Approvers | Date |
|---|---|---|---|
| Start Gate | Pass | Mark (human); Maya T8 (**synthetic**) | 2026-09-08 America/Chicago |
| Framing Gate | Pass | Mark (human); Maya T14 (**synthetic**) | 2026-09-08 America/Chicago |

Log: `docs/orchestration/gate-log.md`. Framing gate file: `07_FRAMING_GATE.md`.

---

## 8. Key artifact index

| Framework deliverable | Path |
|---|---|
| 01 Original request + dialogue | `01_ORIGINAL_REQUEST_AND_VERBATIM_DIALOGUE.md` |
| 02 Start decision options | `02_START_DECISION_OPTIONS.md` |
| 03 Decision + ambiguity ledgers | `03_DECISION_AND_AMBIGUITY_LEDGERS.md` |
| 04 Independent Start reviews | `04_INDEPENDENT_START_REVIEWS.md` |
| 05 Approved decision statement | `05_APPROVED_DECISION_STATEMENT.md` |
| 06 Candidate analytical questions | `06_CANDIDATE_ANALYTICAL_QUESTIONS.md` |
| 07 Independent Framing reviews | `07_INDEPENDENT_FRAMING_REVIEWS.md` |
| 08 Stakeholder revisions + approval | `08_STAKEHOLDER_REVISIONS_AND_APPROVAL.md` |
| 09 Final analytical question | `09_FINAL_ANALYTICAL_QUESTION.md` |
| 10 This handoff | `10_STAGE_3_MEASUREMENT_DESIGN_HANDOFF.md` |

**Extras retained (not framework §20 names):** `00_INTAKE_AND_CONFIGURATION.md`, `02_DECISION_LEDGER.md`, `03_CONSOLIDATED_START_ISSUE_LIST.md`, `04_START_GATE.md`, `05_FRAMING_INTAKE.md`, `06_FRAMING_NOTES.md`, `07_FRAMING_GATE.md`, `reviews/`.
