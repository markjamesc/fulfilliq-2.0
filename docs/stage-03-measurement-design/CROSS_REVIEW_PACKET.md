# FulfillIQ 2.0 — Stage 3 Cross-Review Packet
Sources only: Design_A_ChatGPT.md | Design_B_Grok.md | Data_Risk_Dossier_DeepSeek.md  
Paste-ready. Do not invent content. Quote thresholds exactly.

---

## 1) Locked decision + question (short)

**Approved decision (A verbatim):** Maya Chen must decide which marketplace sellers if any to enroll on a ~30-day late-fulfillment improvement plan versus leave on standard terms to reduce late customer deliveries under hard concurrent capacity about 20 (no padding; enroll fewer if fewer meet bar) by mid-month VP ops meeting; tiny-volume stay standard; featured placement out; ops enrollment not RCT; numeric cutoffs designed in Stage 3 only to serve enrollment.

**Locked question (A verbatim):** Under locked concurrent capacity about 20 with tiny-volume on standard terms which sellers if any have late-fulfillment patterns that warrant a documented 30-day improvement plan with closer ops check-ins and seller corrective path rather than ordinary marketplace monitoring?

**B membership intent (not a rewrite):** yes/no first; if more than ~20 qualify rank within cap; else enroll fewer; tiny-volume never qualify; do not pad.

---

## 2) Side-by-side extract — Design A vs Design B

### Population / time window
| Topic | Design A | Design B |
| --- | --- | --- |
| Reporting universe | Every distinct valid seller_id in raw_sellers (incl. zero eligible) | Sellers via items validated against raw_sellers; n<30 in volume-suppressed appendix |
| Eligible order | delivered; in-window purchase; nonmissing actual & estimated; chronology OK (actual/estimate not before purchase) | delivered; in-window purchase; ≥1 item row; both delivery timestamps non-null |
| Purchase window | **2018-01-01 00:00:00 incl → 2018-07-01 00:00:00 excl** (provisional; two quarters) | **`>= '2018-01-01 00:00:00'` and `< '2018-09-01 00:00:00'`** (provisional; Jan–Aug) |
| Repetition splits | Block1 Jan–Apr 2018; Block2 Apr–Jul 2018 (end exclusive) | Halves Jan–Apr vs May–Aug 2018 |
| Cohort clock | Purchase time; post-window delivery still counts if purchase qualifies | Purchase time; 31 Aug purchase delivered in Sep remains in if delivered |
| Tiny-volume | `< 30` eligible seller–orders → standard (provisional) | `eligible_n < 30` **after exclusions** → standard (provisional; B tightening) |

### Grain
| Topic | Design A | Design B |
| --- | --- | --- |
| Item | (order_id, order_item_id); collapse | Same; never count items as deliveries |
| Measurement | **(seller_id, order_id)** — multi-item same seller once; multi-seller → one assoc each, shared outcome | **(seller_id, order_id)** — same; SQL B grain |
| Decision | One seller / window / spec version | seller-window; SQL A grain |
| Attribution | Disclose multi-seller dependence; handoff path uses single-seller late | All-order LFR + single-seller LFR; flip → inconclusive |

### Primary KPI (num / den / lateness rule)
| Topic | Design A | Design B |
| --- | --- | --- |
| Name | Seller Late-Fulfillment Rate (LFR) | Same |
| Denominator | `eligible_n` = distinct eligible seller–orders | `eligible_n` = usable seller-orders after Section L exclusions |
| Numerator | `late_n` = actual **calendar date** later than estimated **calendar date** | late iff `DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)` |
| Formula | LFR = k_s/n_s; null if n_s=0 (never zero) | LFR = late_n/eligible_n; always print fraction |
| Same-day / grace | Same-day on time; **no grace period**; exact counts, unrounded | Same DATE rule (profile estimates at 00:00:00) |
| Timestamp twin | Mandatory; late_n_timestamp + disagreement count | Mandatory; **action** (not merely rate) flip → inconclusive |
| Severity | Median days late; **>7 calendar days** late — diagnostic; **does not change membership** | Medians narrative/tie-break after ELC; ship-limit miss diagnostic only (**cannot enroll**) |

### Sample-size / uncertainty
| Topic | Design A | Design B |
| --- | --- | --- |
| Volume floor | **≥ 30** eligible (provisional) | **≥ 30** post-exclusion (provisional) |
| Min late volume | **≥ 5** late seller–orders | Hygiene **`late_n >= 4`** (provisional) |
| Interval | **95% Wilson** — descriptive only; **not** enrollment gate | Wilson **80%** LB (`z = 1.2816`) — qualify conjunct: `Wilson_LB > LFR_mkt_weighted` |
| Coverage guardrail | Eligible/candidate ≥ **95%** provisional; zero candidate → fail | No A-style 95% coverage membership gate |
| Comparator | Reference: ≥30 eligible + coverage pass; usable ≥ **20** other sellers & **1,000** eligible orders; each block ≥ **200** | Peer set = all eligible_n≥30; band P75 + pooled weighted LFR (Stage 4 data-derived) |
| Context (both) | Median ~6 delivered; ~80% sellers below 30 — recompute after exclusions | Same skew cited; do not treat full-extract “627 at 30” as Jan–Aug headcount |

### Decision rules under hard cap (~20, no padding)
**A — analytical membership YES only if all gates pass (numbers provisional):**
1. ≥30 eligible seller–orders  
2. ≥95% measurement coverage  
3. Usable full-window and block comparators  
4. ≥5 late **and** full-window LFR **at least 3 percentage points** above seller-excluded comparator  
5. Each block: ≥10 eligible, ≥2 late, LFR **strictly above** that block’s comparator (equality fails “strictly above”; equality passes “at least”)  
6. Handoff: ≥**3** supporting orders; supporting ≥**50%** of all eligible late; ≥**90%** of single-seller late have evaluable handoff; zero single-seller late fails  

Rank **YES only:** excess burden `e_s = k_s − n_s p_{-s}` desc → handoff_support_n → late_n → eligible_n → seller_id asc. Select first min(S,Q) with C=20 integer. Actions: ENROLL_RECOMMENDED | STANDARD_CAPACITY | STANDARD_NOT_QUALIFIED. No severity-only override; no automatic top-twenty; no padding.

**B — apply N0–N8 in order (provisional where marked):**
- N0 live-DB critical fail → wait (whole list)  
- N1 `eligible_n < 30` → standard_terms  
- N2 `late_n < 4` → standard_terms  
- N3 rate-clear if LFR ≥ **own volume-band P75** (bands **30–49 / 50–99 / 100+**) **and** LFR > `LFR_mkt_weighted` **and** Wilson_LB > `LFR_mkt_weighted`  
- N4 all-order would qualify but single-seller would not (or single-seller too thin & multi-seller majority) → inconclusive  
- N5 date-rule vs timestamp-rule **action** disagree → inconclusive  
- N6 half “hot” (half LFR ≥ band P75 & half n≥**10**) and other “cold” (≤ peer-set median & half n≥10) → watch; thin half → flag, leave in qualify pool  
- Cap: n_qualify=0 → nobody; 1…~20 → enroll all; >~20 → rank **ELC** desc, LFR, late_n, eligible_n, seller_id asc; top ~20 enroll, rest watch. **Do not pad / do not expand cap.**  
- Actions: enroll | watch | standard_terms | inconclusive | wait. Featured/offboarding not outputs.

### SQL A / SQL B / R(B) / recon contracts
| Contract | Design A | Design B |
| --- | --- | --- |
| **SQL A** | Judged seller table: 1 row per seller in full universe; population/outcome/repetition/reference/fit/gates/membership/rank/action; A must not read B or R(B) | Judged seller table: eligible_n, late_n, LFR twins, Wilson_LB, ELC, split halves, single-seller, peer benches, qualify, rank, action |
| **SQL B** | Package: **B_orders + B_items + B_sellers** raw full-snapshot projections; preserve duplicates/invalids; **no** seller aggregates, eligibility, late, membership, ranks | Seller-order dump of usable rows (+ thin QA rows with `in_lfr_denom=0`); may carry late_date/late_ts flags; **must drop** action, qualify, rank, ELC, Wilson, LFR, peer percentiles |
| **R(B)** | B raw + frozen spec only; rebuild associations, window, gates, exact integer/rational thresholds (3pp via scaled cross-products); same judged schema as A | B only (no MySQL, no A); rebuild peers, Wilson_LB, ELC, apply J/N; produce qualify/rank/action |
| **Recon** | Exact late_n, eligible_n, LFR pair, gates, comparator totals, handoff counts, membership, rank, selected, action; float display not authority | Exact late_n, eligible_n; LFR within **1e-12** relative; exact action string; mismatch = critical fail; neither list ships |

### Biggest differences (file-grounded)
1. **Window length:** A six months (ends 2018-07-01); B eight months (ends 2018-09-01); different repetition halves.  
2. **Elevation / peer bar:** A fixed **+3 pp** vs leave-one-out comparator + block strict-above; B **band-P75 + > marketplace weighted LFR + Wilson 80% LB**.  
3. **Min late count:** A **≥5**; B **≥4**.  
4. **Operational fit:** A **handoff gates are membership-required** (3 / 50% / 90%); B carrier/ship-limit is **diagnostic only** (cannot enroll); B substitutes attribution / precision / split-window guardrails.  
5. **Coverage:** A **95%** membership gate; B has no equivalent.  
6. **Wilson role:** A 95% descriptive; B 80% LB is a **qualify conjunct**.  
7. **SQL B philosophy:** A raw three-table package (R owns cohort filter); B pre-built seller-order evidence with late flags but no judgments.  
8. **Action vocabulary:** A three codes; B five (adds watch / inconclusive / wait).

---

## 3) Dossier implementability verdicts + top risks (verbatim short)

**§8 component verdicts:**
- Hypothesis: **Pass**
- Population: **Pass**
- Grain (seller-level SQL-A): **Pass**
- KPI: **Pass**
- Comparison (enrolled vs standard): **Conditional-Pass** — requires external `seller_plan_enrollment`; non-RCT → descriptive percentiles only
- Segments: **Pass**
- Confounders: **Pass** (multi-seller residual risk unresolved)
- Sample-size: **Pass**
- Decision-rules: **Pass**
- SQL-A: **Conditional-Pass** — must include `multi_seller_order_flag`; separate single- vs multi-seller KPIs
- SQL-B: **Pass**
- R-B: **Pass**
- Recon: **Pass**
- **Overall Stage 4: Conditional-Pass** — provided external plan flag supplied and outputs caveat multi-seller attribution and selection bias

**Critical blockers (Overall Assessment):**
1. Absence of plan enrollment data — comparison requires an external input.
2. Order-level lateness in multi-seller orders — structural measurement flaw; explicitly flag in all deliverables.
3. Non-random plan assignment — causal interpretation prohibited; stick to percentile/ranking rules.

**Top risks (short, from register / leakage):**
- **R001** Aggregation Bias — multi-seller late attribution (High / High)
- **R002** Geolocation Join Error — zip row explosion (High / Medium)
- **R004** Selection / Confounding by Plan (High / High for comparison)
- **R005** Volume Skew & Rate Instability (High / High)
- **L001** Lookahead bias if post-decision deliveries used for enrollment
- **L002** Multi-seller attribution leakage
- **L003** Plan comparison non-RCT — do not use “treatment effect”
- **G001/G003** No enrollment flag; no item-level delivery timeline

---

## 4) Instructions for reviewers — what to return

Return **four labeled sections only** (bullets; cite Design A / B / Dossier by section or exact threshold):

1. **Improvements to adopt** — concrete rule/threshold/contract changes from B (or A) worth locking; name the cutoff exactly.  
2. **Alternatives that answer the wrong question** — metrics or rules that optimize impact, SLA %, top-N fill, or causal contrast instead of “patterns warranting a documented 30-day plan under ~20 cap, no padding.”  
3. **Data risks requiring design change** — dossier risks that force a membership/SQL/recon rule change before Stage 4 (not merely a footnote).  
4. **Business requirements lost in B** — locked-decision elements present in A (or the brief) that B drops, softens, or cannot enforce; quote the missing bar.

Rules for reviewers: quote numeric cutoffs exactly; do not invent schema fields; do not rewrite the locked decision/question; list unresolved Maya choices separately from adopt/reject.

---
End of CROSS_REVIEW_PACKET.
