# AI-2 Cross-Review of Design A (with Dossier)

Sources used: packet extracts of Design A, Design B, and the Data Risk Dossier only. Locked decision and locked question are not rewritten. Numeric cutoffs are quoted exactly. No SQL.

---

## (1) Invalid or weak hypotheses in Design A

Design A’s working hypothesis is that a seller who clears **all** of the following has a late-fulfillment *pattern that warrants a documented 30-day improvement plan* (closer ops check-ins and a seller corrective path), rather than ordinary monitoring:

- **≥ 30** eligible seller–orders  
- **≥ 95%** measurement coverage  
- usable full-window and block comparators  
- **≥ 5** late **and** full-window LFR **at least 3 percentage points** above the seller-excluded comparator  
- each block: **≥ 10** eligible, **≥ 2** late, LFR **strictly above** that block’s comparator  
- handoff: **≥ 3** supporting orders; supporting **≥ 50%** of all eligible late; **≥ 90%** of single-seller late have evaluable handoff; zero single-seller late fails  

The dossier marks Hypothesis **Pass**. The *question* is therefore well-posed. What is weak is the chain from “statistically elevated LFR under these gates” to “pattern that warrants a 30-day ops plan.”

**Elevation ≠ warrant.** A fixed **3 percentage points** gap versus the leave-one-out comparator is treated as sufficient evidence of a *correctable seller pattern*. That is an operational claim, not a measurement claim. Under dossier **R005** (Volume Skew & Rate Instability, High / High) and the packet context that median delivered volume is ~6 and **~80% of sellers are below 30**, a 3 pp gap at the floor of **n = 30** (5 late vs ~4 late at a 13% comparator, for example) is a few orders. That can be mix, one bad week, or one multi-seller order—not a 30-day corrective object.

**Both-blocks “strictly above” ≠ persistence.** A’s repetition split is Block1 Jan–Apr 2018 and Block2 Apr–Jul 2018 (end exclusive) inside a purchase window **2018-01-01 00:00:00 incl → 2018-07-01 00:00:00 excl**. April is named in both blocks; Block2 also names July, which sits *outside* the locked six-month purchase window. The hypothesis that two blocks demonstrate a repeated pattern is therefore weaker than it appears: the blocks are not a clean partition of the eligible window, and they are not independent.

**Handoff gates ≠ seller-correctable cause.** A requires handoff as *membership*, not diagnostics: **≥ 3** supporting; supporting **≥ 50%** of all eligible late; **≥ 90%** of single-seller late evaluable; zero single-seller late fails. That is the right *kind* of hypothesis for “seller corrective path.” It is still weak against dossier **R001** / **L002** (multi-seller late attribution, High / High) and **G003** (no item-level delivery timeline). If handoff cannot be reconstructed at item grain, the gate either silently fails almost everyone or is computed on an order-level proxy that does not isolate the seller.

**Enrollment reduces late deliveries.** The locked brief already says ops enrollment is **not RCT**. The dossier Comparison verdict is **Conditional-Pass** and forbids causal language. Any implicit “enroll these 20 and late deliveries fall” is an invalid use of A’s membership hypothesis.

**Coverage completeness ≠ pattern quality.** **≥ 95%** Eligible/candidate as a *membership* gate assumes that missing timestamps are non-informative. Sellers who systematically omit estimated or actual dates (the ones most worth a plan) can be excluded by the coverage rule rather than enrolled.

None of these make the locked question invalid. They make A’s *identification* of “warrant” thinner than the decision Maya has to take under a hard concurrent capacity of about **20**.

---

## (2) Construct-validity denominator baseline risks in A

A’s LFR construct is:

- Denominator `eligible_n` = distinct eligible **seller–orders**  
- Eligible = delivered; in-window purchase; nonmissing actual & estimated; chronology OK (actual/estimate not before purchase)  
- Numerator `late_n` = actual **calendar date** later than estimated **calendar date**  
- Same-day on time; **no grace period**  
- Grain **(seller_id, order_id)** — multi-item same seller once; multi-seller → one association each, **shared outcome**  
- Tiny-volume **`< 30`** eligible seller–orders → standard (provisional)  
- Post-window delivery still counts if purchase qualifies  

**Delivered-only denominator.** Conditioning the baseline on *delivered* orders with both timestamps drops cancellations, lost packages, and never-delivered orders. “Late fulfillment” as a customer-delivery problem is then only “late among completed deliveries.” Sellers who fail by non-delivery look better on LFR than sellers who deliver late. That is a construct miss relative to “reduce late customer deliveries.”

**Shared-outcome multi-seller rows in the denominator.** A discloses multi-seller dependence and routes handoff through single-seller late, but the *primary* LFR still puts a shared late/on-time label on every associated seller. Dossier **R001** / **L002** and SQL-A **Conditional-Pass** (“must include `multi_seller_order_flag`; separate single- vs multi-seller KPIs”) mean A’s baseline mixes seller-controlled and co-attributed orders. The leave-one-out comparator \(p_{-s}\) inherits the same contamination, so the **3 percentage points** test is not a clean seller-vs-market contrast.

**Volume floor as construct, not just precision.** **`< 30` → standard** and membership **≥ 30** permanently remove the mass of the catalog (~80% of sellers). That matches the lock (“tiny-volume stay standard”). The risk is treating **n ≥ 30** as if it were also a *stable rate baseline*. At n = 30, **≥ 5** late is a 16.7% LFR; Wilson **95%** is explicitly **descriptive only** and **not** an enrollment gate, so A has no interval check that the rate is distinguishable from the comparator before the 3 pp rule fires.

**Leave-one-out as the only baseline.** A’s comparator needs usable **≥ 20** other sellers and **1,000** eligible orders, each block **≥ 200**. Those are coverage-of-the-baseline rules, not peer-fairness rules. A high-volume seller is compared to a market that still includes other high-late sellers; a barely-qualified n = 30 seller is compared to a pooled rate dominated by larger shops. B’s volume bands **30–49 / 50–99 / 100+** exist because this baseline is not exchangeable across volume. A has no band-specific denominator.

**Calendar-date late vs timestamp twin.** A mandates a timestamp twin and a disagreement count, but disagreement does **not** change membership (unlike B, where an **action** flip → inconclusive). If estimates sit at `00:00:00` (packet note on B, same DATE rule), same-day vs next-calendar-day is a clock artifact. The denominator of “late pattern” then depends on which clock is authoritative, while A still enrolls.

**Lookahead in the cohort clock.** Purchase-time eligibility plus “post-window delivery still counts” is correct for a historical extract. Dossier **L001** still applies if the same spec is reused operationally: deliveries that occur after the enrollment decision must not enter the rate that justified the plan. A does not state a freeze of actual-delivery timestamps relative to decision time.

**Coverage gate changes the baseline mid-stream.** **≥ 95%** Eligible/candidate (zero candidate → fail) can drop a seller from the judged set because of missing fields rather than because the rate is ordinary. The marketplace comparator is then computed on a different surviving population than the seller under test.

---

## (3) Unhandled confounding or unjustified thresholds in A

### Unhandled confounding

- **Multi-seller attribution (R001 High/High, L002, Confounders “multi-seller residual risk unresolved”).** A’s handoff rules constrain *single-seller late* but do not stop all-order LFR from qualifying a seller whose late mass is co-shipped. B’s N4 (all-order would qualify but single-seller would not, or single-seller too thin and multi-seller majority → inconclusive) is the explicit control A lacks.  
- **Non-random assignment / selection (R004 High/High, L003).** Irrelevant to *membership* if Stage 3 only serves enrollment, which the lock already says. It becomes confounding the moment anyone reads A’s YES list as “these sellers are the late problem, those on standard terms are not.”  
- **Volume and promised-SLA mix.** **≥ 5** late at **≥ 30** eligible selects on raw late *counts* as well as rates. Tight estimated dates (ship-limit) inflate LFR without a seller process failure. A treats ship-limit/severity (**> 7 calendar days** late; median days late) as diagnostic only and **does not change membership**—correct for “do not enroll on severity alone,” but then SLA tightness remains an unadjusted confounder of the 3 pp test.  
- **Geolocation / zip explosion (R002 High/Medium).** Not a membership input in the A extract. It becomes confounding if later “corrective path” work joins geo to explain lateness without fixing row grain.  
- **Missing plan flag (G001, Comparison Conditional-Pass).** Not a membership confounder; it is a later-analysis confounder. A should not grow a comparison claim to compensate.

### Unjustified or internally inconsistent thresholds

All of the following are *named* as provisional in A, but they function as hard YES gates. None is derived from the locked capacity of about **20**; they are identification bars.

| Gate in A | Exact cutoff | Problem |
| --- | --- | --- |
| Volume floor | **≥ 30** eligible; **`< 30`** → standard | Matches lock on tiny-volume. Unjustified as a *rate-stability* threshold given ~80% below 30 and median ~6. |
| Min late | **≥ 5** late seller–orders | Integer knife-edge. B’s hygiene is **`late_n >= 4`**. A gives no reason 5 is the smallest count that “warrants a plan.” |
| Elevation | full-window LFR **at least 3 percentage points** above seller-excluded comparator | Fixed additive bar, volume-blind. Ranking then uses excess burden **`e_s = k_s − n_s p_{-s}`**, which *is* volume-weighted. Membership and rank optimize different objects. |
| Block size | each block **≥ 10** eligible, **≥ 2** late | **≥ 2** late in a block of 10 is a 20% block LFR before “strictly above” even applies. Very small cells. |
| Block test | LFR **strictly above** block comparator (equality fails “strictly above”; equality passes “at least”) | Full window allows equality on the 3 pp test (“at least”); blocks forbid equality. Same seller can fail on a rounding/tie that the full-window rule would accept. |
| Coverage | Eligible/candidate **≥ 95%**; zero candidate → fail | Completeness rule promoted to membership. No link to “warrant a plan.” B has no equivalent gate. |
| Comparator usability | **≥ 20** other sellers & **1,000** eligible orders; each block **≥ 200** | If the extract is thin after exclusions, *every* seller fails gate 3 even when individual patterns are ugly. That is a study-feasibility rule sitting inside a seller-enrollment rule. |
| Handoff | **≥ 3** supporting; supporting **≥ 50%** of all eligible late; **≥ 90%** of single-seller late evaluable; zero single-seller late fails | Right construct for “seller corrective path,” but the triple (3 / 50% / 90%) is not justified against **G003**. If item-level timeline is absent, the 90% evaluable rule either cannot be computed or becomes a hidden population filter. |
| Wilson | **95%** Wilson — descriptive only; **not** enrollment gate | Then it does not protect the 3 pp test at n = 30. B’s **80%** LB (`z = 1.2816`) as a qualify *conjunct* is the opposite design choice. |
| Cap | first min(S,Q) with **C = 20** integer; no padding; no automatic top-twenty | Cap itself is locked. Unjustified piece is using **e_s** only *after* YES, so a seller with huge excess burden who fails handoff **90%** never enters the cap ranking. |

Block calendar confounding is also a threshold issue: overlapping April plus a Block2 end that overruns the purchase window **2018-07-01 00:00:00 excl** makes “each block strictly above” an ill-defined test, not merely a harsh one.

---

## (4) Claims stronger than design can support or dossier risks forcing design change

### Claims A cannot support

- **YES = “patterns that warrant a documented 30-day plan.”** A supports “cleared these provisional gates.” The lock’s verb is *warrant*. Gate-clearance is a proxy.  
- **Any treatment-effect or “improvement plan works” language.** Dossier: non-random plan assignment; **L003** — do not use “treatment effect”; Comparison **Conditional-Pass** only with external `seller_plan_enrollment` and descriptive percentiles.  
- **Seller-level lateness as if single-agent.** Dossier critical blocker: “Order-level lateness in multi-seller orders — structural measurement flaw; explicitly flag in all deliverables.” SQL-A is **Conditional-Pass** until `multi_seller_order_flag` and separate single- vs multi-seller KPIs exist. A’s current primary KPI does not yet meet that bar.  
- **Handoff-qualified ⇒ ops-actionable corrective path.** Not supportable until **G003** (no item-level delivery timeline) is closed or the handoff gates are declared non-computable.  
- **Coverage-pass ⇒ measurement is fit for enrollment.** **≥ 95%** is a completeness statistic, not a construct-validity statistic.  
- **Full-extract “627 at 30” as the Jan–Jun/Jan–Aug headcount.** Packet already warns both designs: do not treat that figure as window headcount. A must not imply the YES pool is pre-counted.

Overall dossier Stage 4: **Conditional-Pass** — external plan flag supplied *and* outputs caveat multi-seller attribution and selection bias. Stage 3 membership can proceed without the plan flag; it cannot proceed *as if* comparison were already valid.

### Dossier risks that force a design change (not a footnote)

These are the items that must alter membership, judged-table contents, or recon—not merely the slide caveats.

1. **R001 / L002 — multi-seller aggregation / attribution leakage (High).** Force a membership or action change: either compute membership on single-seller LFR, or adopt an inconclusive state when all-order and single-seller disagree (B N4). Flag-only is what the dossier already says is insufficient for the structural flaw.  
2. **SQL-A Conditional-Pass.** Judged seller table must carry `multi_seller_order_flag` and both KPIs. Recon must match both late_n/eligible_n pairs, not only the blended LFR.  
3. **G003 — no item-level delivery timeline.** If handoff **3 / 50% / 90%** cannot be built from available grain, those gates cannot remain *membership-required*. They must be dropped, relaxed to diagnostic (B’s ship-limit stance), or the extract must gain item-level timestamps before Stage 4. Leaving them as hard YES rules on a missing construct is a silent population filter.  
4. **R005 — volume skew and rate instability (High / High).** The combination **≥ 30**, **≥ 5** late, **3 percentage points**, Wilson **not** a gate, is not a sufficient uncertainty control. Either Wilson (or another LB) becomes a conjunct for the 3 pp test, or the 3 pp test is restricted to a volume band, or min late is raised. Footnoting instability while still emitting ENROLL_RECOMMENDED is a design miss.  
5. **L001 — lookahead.** Spec must freeze which deliveries may enter `late_n` relative to purchase window *and* decision time. “Post-window delivery still counts if purchase qualifies” stays for historical 2018 scoring only if the operational reuse path is explicitly out of spec.  
6. **R004 / G001 / L003 — plan flag and non-RCT.** Do not add enrolled-vs-standard contrast to Stage 3 outputs. That is a comparison-design change: keep it out of membership, rank, and action vocabulary (A’s three codes already do this; do not grow them into a lift claim).

**R002** (zip explosion) forces a join/grain rule *if* geo enters the pipeline; it does not by itself change A’s current membership gates.

Critical blockers restated as design constraints: no plan-enrollment field inside Stage 3; multi-seller lateness flagged *and* split in the KPI; no causal reading of the cap-20 list.

---

## (5) Keep A with named amendments OR replace with named B alternatives

**Keep Design A as the membership spine. Do not replace A with B.**

Reason: A is aimed at the locked question (which sellers, if any, have patterns that *warrant a documented 30-day plan* under concurrent capacity about **20**, tiny-volume on standard terms, no padding, featured placement out, not an RCT). B is stronger on precision, attribution hygiene, and peer-fairness, but several B devices answer a *different* question (beat volume-band **P75**, beat marketplace weighted LFR, fill or trim by **ELC**). Those are impact/ranking rules. They can starve or flood the plan list without asking whether a *seller corrective path* is even identifiable.

### Amendments to lock into A (adopt from B or from the dossier; quote cutoffs)

1. **Attribution (adopt B N4, required by R001/L002 and SQL-A Conditional-Pass).** If all-order LFR would pass A’s gates but single-seller LFR would not, **or** single-seller is too thin and multi-seller is the majority of eligible late → do **not** emit ENROLL_RECOMMENDED. Add an **inconclusive** action (B vocabulary) or map it to STANDARD_NOT_QUALIFIED with an explicit inconclusive reason code. Carry `multi_seller_order_flag` plus all-order LFR and single-seller LFR on every judged row.  
2. **Clock disagreement (adopt B N5).** If date-rule vs timestamp-rule would **change the action**, mark inconclusive. Disagreement *count* alone is not enough. Keep same-day on time and **no grace period**.  
3. **Uncertainty conjunct on the 3 pp test (adopt B’s Wilson *role*, not B’s peer bar).** Keep full-window LFR **at least 3 percentage points** above the seller-excluded comparator, and add a lower-bound conjunct so n = 30 / **≥ 5** late cannot enroll on noise. Prefer B’s already-specified **80%** Wilson LB (`z = 1.2816`) *versus the same leave-one-out comparator*, not versus `LFR_mkt_weighted` and not versus band **P75**. Do not replace the 3 pp LOO test with N3.  
4. **Repetition window (fix A; borrow B’s partition idea only).** Keep A’s purchase window **2018-01-01 00:00:00 incl → 2018-07-01 00:00:00 excl**. Replace overlapping Block1 Jan–Apr / Block2 Apr–Jul with two **non-overlapping** halves that partition that window (e.g. Jan–Mar vs Apr–Jun, end exclusive). Keep block floors **≥ 10** eligible and **≥ 2** late, but change “strictly above” to the same “at least” wording used on the full-window 3 pp test so equality is not a hidden veto.  
5. **Handoff stays membership-required only if G003 is closed.** If item-level delivery timeline exists: keep **≥ 3** supporting; supporting **≥ 50%** of all eligible late; **≥ 90%** of single-seller late evaluable; zero single-seller late fails. If G003 is still true at Stage 4 start: demote handoff to diagnostic (B’s ship-limit rule: **cannot enroll** on that signal alone) rather than inventing a proxy. Do not silently compute 90% evaluable on order grain.  
6. **Keep A’s tiny-volume, min-late, coverage, and cap rules.** **`< 30`** → standard; membership **≥ 30**; **≥ 5** late (do *not* adopt B **`late_n >= 4`**—A is the more conservative “warrant a plan” bar); Eligible/candidate **≥ 95%** remains a *data-quality fail for that seller*, not a market-wide kill switch if the only issue is one seller’s missing fields; rank only YES rows by **`e_s = k_s − n_s p_{-s}`** desc → handoff_support_n → late_n → eligible_n → seller_id asc; select first min(S, **C = 20**); **no padding**; **no automatic top-twenty**; no severity-only override (**> 7 calendar days** late stays diagnostic).  
7. **Action vocabulary.** Keep A’s three enrollment actions as the only *capacity* outputs: ENROLL_RECOMMENDED | STANDARD_CAPACITY | STANDARD_NOT_QUALIFIED. Add B’s **inconclusive** and **wait** (N0 live-DB critical fail → wait, whole list) as *non-enrolling* states so recon can fail closed (B: mismatch = critical fail; neither list ships). Do not add B **watch** as a way to park overflow inside the cap. Overflow after rank is STANDARD_CAPACITY / not selected—not a second plan.  
8. **Comparison stays out.** No enrolled-vs-standard contrast in Stage 3. Dossier Comparison remains **Conditional-Pass** pending external `seller_plan_enrollment`.

### B alternatives that must *not* replace A (wrong question)

- N3 as the qualify rule: LFR ≥ own volume-band **P75** (bands **30–49 / 50–99 / 100+**) **and** LFR > `LFR_mkt_weighted` **and** Wilson_LB > `LFR_mkt_weighted`. That is “unusual versus volume peers,” not “pattern that warrants a 30-day documented plan.”  
- Ranking by **ELC** desc as the primary selector, then filling **~20**. That is top-N impact under a cap. Lock is yes/no first, enroll fewer if fewer meet the bar, do not pad.  
- Eight-month window **`>= '2018-01-01 00:00:00'` and `< '2018-09-01 00:00:00'`** and May–Aug half. Different population; not a drop-in for A’s two-quarter window.  
- Ship-limit / carrier miss as a *substitute* for handoff when G003 is solvable. B correctly says that signal **cannot enroll**; it does not answer “seller corrective path.”  
- Featured placement, offboarding, RCT contrast, SLA-% optimization.

### Business requirements in A / the lock that B drops or softens (do not lose them)

- Handoff as **membership-required** (**3 / 50% / 90%**, zero single-seller late fails)—B makes carrier/ship-limit **diagnostic only**.  
- Coverage **≥ 95%** as a seller gate—B has no A-style 95% coverage membership gate.  
- Full-window **3 percentage points** vs seller-excluded comparator plus block repetition—B uses band **P75** + weighted market LFR + Wilson **80%** LB.  
- Min late **≥ 5**—B **`late_n >= 4`**.  
- Three capacity actions and “YES only then rank,” no watch list inside the cap.  
- Six-month purchase window ending **2018-07-01 00:00:00 excl**.

### Unresolved Maya choices (not adopt/reject)

- Whether G003 will be closed before Stage 4 (keeps or demotes handoff **3 / 50% / 90%**).  
- Whether inconclusive occupies a fourth action string or is folded into STANDARD_NOT_QUALIFIED.  
- Whether the Wilson conjunct is **80%** LB (`z = 1.2816`) or A’s existing **95%** interval promoted from “descriptive only.”  
- Exact non-overlapping half dates inside **2018-01-01 00:00:00 incl → 2018-07-01 00:00:00 excl**.  
- Whether **≥ 95%** coverage fail is seller-local or list-wide (A: zero candidate → fail).  

