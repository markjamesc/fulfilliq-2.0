# Stage 4 Structural Cross-Review — FulfillIQ 2.0

**Status:** Pass (post exact recon)  
**Date:** 2026-09-09 (America/Chicago)  
**Depends on:** `02_EXACT_RECON_FREEZE.md` Pass

## Scope

Lightweight structural review after exact A↔R(B) recon Pass — hidden weaknesses, not a second design debate.

## Findings

1. **Independence architecture held** for counts: separate A (`raw_*`) and R(B) (B package) paths; KPI exact match before decision repair.
2. **Stage 3→4 translation risk (material for V3):** first R(B) omitted half-rate persistence and real N5. Caught by recon. V3 should add executable gate checklists / known-case fixtures so builders cannot skip H2 rate or dual-clock N5.
3. **SQL A privilege adaptation:** plain SQL + ordinary `a4_*` tables (no `CREATE TEMPORARY TABLES`). Documented; does not change judged logic.
4. **Halt assert bug (MySQL):** `CASE WHEN` still evaluated unknown-column THEN branch when false — fixed via PREPARE/EXECUTE. Stage 4 plumbing lesson.
5. **B lineage:** initial PENDING_* snapshot IDs aligned to shared freeze via `Stage_04_align_B_snapshot.sql` before final recon.
6. **Simulation:** S=C=20 full-capacity simulation only; not live enrollment.
7. **Optional deeper R / parsnip:** deferred until after this Pass; must not replace membership rules.

## Residual open items (non-blocking for Validation Gate)

- Parse warnings on B TSV read (investigate in deeper analysis if needed).
- Rank column exact pairwise export for A not frozen in the slim TSV (selected set + action already exact; R ranks 1–7 for the seven ENROLL).
- GitHub archive of large B TSVs may stay local-PC-only; hashes recorded in recon freeze.

## Decision

**Structural cross-review Pass.** Deeper R analysis and Stage 5 may open on the validated pack. Live operational release remains held pending Mark/ops.
