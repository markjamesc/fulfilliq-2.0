# CHANGELOG — Phase 7 AI3 Clarifications

**Document revised:** `CANDIDATE_MEASUREMENT_DESIGN.md` (copied to `Stage_03_Measurement_Design.md`)  
**From:** `fulfilliq-2.0-stage3-candidate-v0.2` (Phase 7 AI1 revise)  
**To:** `fulfilliq-2.0-stage3-candidate-v0.2.1` (Phase 7 AI3 clarifications)  
**Audit:** `AI3_PHASE7_AUDIT_DeepSeek.md` (verdict **PASS — with clarifications**)  
**Date:** 2026-09-08 (America/Chicago)  
**Constraint honored:** Approved decision (§2) and locked analytical question (§3) **not rewritten**. No executable SQL/R. No new numeric cutoffs beyond Designs A/B integers; all PA levels remain provisional.

---

## Clarifications applied (AI3 §2 contract gaps)

### 1) Gap 1 — `B_sellers` minimum fields (§7.1, §21)
- Specified minimum: `seller_id` (valid, non-null, unique key) + source-version audit fields.
- Additional approved attributes optional for diagnostic context only.
- Stage 4 must verify `seller_id` presence and uniqueness before proceeding.

### 2) Gap 2 — Chronology “earlier than” temporal precision (§7.3)
- Full timestamp comparison when both fields are timestamps.
- Mixed date-only / timestamp: source recorded precision governs; convert per source docs.
- Purchase / actual / estimated must be parseable to the same temporal precision for equality boundaries.

### 3) Gap 3 — N4 half comparator usability (§17.4)
- Per-half usability for ss half comparators = ≥200 ss comparator eligible seller–orders **in that half**.
- Full-window ≥1,000 does **not** gate half comparator availability.
- Half usability follows §12 half-specific logic applied to ss associations.

### 4) Gap 4 — Half comparator other-seller count (§12, §17.4)
- Chose audit **Alternative** (no new threshold): ≥20 other comparator sellers applies **only** to full-window usability and does **not** extend to half comparators.
- Did **not** invent a ≥10 half seller-count (would be a new cutoff beyond A/B integers).

### 5) Gap 5 — Coverage denominator `candidate_delivered` (§11.1)
- `candidate_delivered_n` = §7.2 definition **before** §7.3 delivery-date-quality exclusions.
- `eligible_n` = §7.3 definition.
- Coverage measures data-quality fallout from invalid/missing delivery dates, not volume filtering.

### 6) Gap 6 — N4 Thin+Majority late-majority branch (§17.4)
- Late-majority (`late_n_ms / late_n > 0.5`) triggers **regardless** of eligible-majority.
- Both flags always computed and emitted.
- N4 fires if either majority is true AND `eligible_n_ss < 30` AND all-order would otherwise pass.

### 7) Gap 7 — Frozen snapshot consistency A vs R(B) (§19, §23)
- SQL A and R(B) must use the same frozen snapshot extraction; snapshot identity in both manifests.
- Separate extractions must use identical time-locked views.
- Extraction-timing mismatches = recon failures.

### 8) Gap 8 — `multi_seller_order_flag` aggregation (§20)
- Per seller: `multi_seller_association_n` = count of distinct eligible seller–orders with `multi_seller_order_flag` = TRUE; `single_seller_association_n` = `eligible_n - multi_seller_association_n`; `late_n_ms` / `late_n_ss` per §17.4.

### Also annotated from §2 Gap 9 — Recon mismatch as halt (§14.1(d), §23)
- Reworded trigger (d): recon critical mismatch → release prohibited by §23; automatic until resolved; **recon halt**, not a separate hold process.

---

## Sections touched

| Area | Sections |
| --- | --- |
| Header / version / provenance | Header, §24, end marker |
| Population / chronology / B_sellers | §7.1, §7.3, §21 |
| Coverage | §11.1 |
| Comparator usability | §12, §16, parameter register |
| Operational-release / recon | §14.1, §19, §23 |
| N4 | §17.4 |
| SQL A multi-seller fields | §20 |

---

## Not changed

- Verbatim approved decision and locked analytical question.
- Structural locks: 8-month window, non-overlapping halves, C=20, A-style membership spine, raw three-table SQL B, exact recon, reject P75-alone / fill-to-cap / severity-only / causal claims.
- No new numeric cutoffs; Gap 4 Alternative used specifically to avoid inventing a half seller-count.
- N4/N5 logic, capacity selection, and action taxonomy unchanged in substance (clarified only).

---

*End of CHANGELOG_PHASE7_AI3_CLARIFY.md*
