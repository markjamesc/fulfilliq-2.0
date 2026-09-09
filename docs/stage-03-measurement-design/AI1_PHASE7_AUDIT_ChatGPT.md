**(1) Trace Pass items**

These pass on the candidate’s stated rationale; claims about upstream approvals or verified data remain subject to the provenance gap below.

* **Membership before capacity:** Eligibility first, ranking only among qualifiers, fewer enrollments when fewer qualify, and no padding directly trace to the approved decision and locked question.
* **Business scope:** Tiny-volume sellers remain on standard terms; featured placement is excluded; the plan is an operational recommendation, not an RCT or historical enrollment comparison.
* **Pattern-based membership:** Materiality, persistence, and a fulfillment-process signal reasonably operationalize whether a plan is warranted. They are disclosed methodological judgments, not stakeholder-specified tests or proof of seller fault.
* **Provisional thresholds:** The candidate explicitly treats numeric gates as policy proposals rather than validated optima or SLAs. A cutoff is not an unjustified invention merely because it requires methodological judgment.
* **Population and measurement:** Delivered-only eligibility, purchase-based cohorting, seller–order grain, full seller reporting, date-based lateness, and the historical observation window are disclosed measurement choices. Their limitations are acknowledged.
* **Data integrity:** Collapsing item associations before counting, preventing join multiplication, preserving missing outcomes, auditing exclusions, and stopping on unresolved key failures support trustworthy membership decisions.
* **Comparison and allocation:** The seller-excluded comparator supports relative materiality; excess-burden ranking and deterministic tie-breaks provide a disclosed allocation method when qualifiers exceed capacity.
* **Conclusion limits:** No causal effectiveness claim, no proof of fault, no severity-only override, and no invented enrollment field are consistent with the decision.
* **Independent reconstruction:** Raw B extraction, independent R(B) reconstruction, exact reconciliation, and withholding mismatched lists trace to reproducibility and implementation assurance.

**(2) Trace gaps / unjustified inventions**

1. **Upstream authority is asserted but cannot be independently checked from this attachment.**
   Sections 1, 24, and 25 rely on the reconciliation matrix, Designs A/B, dossier, and open-questions file. These were not supplied here. Consequently, the “Phase 4 lock” provenance and “No new thresholds beyond Designs A/B” claim remain unverified. The contextual “median ~6 delivered; ~80% sellers below 30” also lacks inspectable supporting evidence. “Not in DB” in §4 is a schema claim; exclusion from business scope does not establish database absence.
   **Required fix:** Provide source locations or embedded resolution/evidence excerpts for material AM/VF claims. Keep unsupported schema claims pending verification. This is a provenance gap, not evidence that those claims are false.

2. **The repetition hypothesis overstates what its gate establishes.**
   H2 says “Elevation appears in **both** non-overlapping halves,” but §17 permits “LFR **at least** above that half’s comparator (equality passes).” The register confirms “≥10 eligible; ≥2 late; LFR ≥ half comparator.” Equality establishes parity, not elevation. Moreover, aggregate half counts cannot exclude one episode spanning the April–May boundary.
   **Required fix:** Align the methodological hypothesis and explanation with the actual gate. If stronger persistence is intended, explicitly approve a revised test. Do not claim that the existing rule rules out one pooled episode.

3. **Repeated operational fit is not demonstrated by the specified handoff test.**
   H3 requires repeated late deliveries coinciding with a handoff signal, while the implemented cutoffs—“≥3 supporting,” “supporting ≥50% of all eligible late,” and “≥90% of single-seller late evaluable”—are full-window tests. All supporting handoff events could occur in one half. Separately, §§11.3 and 14 call ship-limit/carrier summaries diagnostic-only, although related evidence gates membership.
   **Required fix:** State whether repetition applies only to customer lateness or also to handoff support. Align H3 accordingly and distinguish the membership handoff test from diagnostic summaries. Any additional temporal handoff requirement needs explicit methodological approval.

4. **The multi-seller override delegates material choices to an undefined “N4-style” rule.**
   “All-order would qualify but single-seller would not” does not specify which gates and references are recomputed. “Single-seller too thin & multi-seller majority of eligible late” leaves “too thin” and “majority” undefined. It is unclear whether “eligible_n ≥ 30” and “≥10 eligible, ≥2 late” apply unchanged to the single-seller reconstruction, and what happens when its comparator is unusable.
   **Required fix:** Specify the complete single-seller counterfactual, reference population, thresholds, boundary handling, and precedence. Builders must not invent these decisions.

5. **The timestamp override lacks a deterministic evaluation order.**
   The rule says that if the twin would “change the derived action,” action becomes INCONCLUSIVE. Actions include capacity selection, so one seller’s changed rank can affect another seller’s action. Removing inconclusive sellers can then change selection again. Section 11.4 also says sensitivities “do not override primary action,” while explicitly including this action-changing test.
   **Required fix:** Define the two comparison runs, freeze point, treatment of capacity-only changes, removal/refill order, and interaction with N4. State the timestamp test’s exception to the diagnostic-only sensitivity rule. Include enough counterfactual evidence in A/R(B) outputs to reconcile the override.

6. **Available capacity is not fully tied to concurrent occupancy.**
   “C = 20” is a disclosed operationalization of the business cap. However, “0 ≤ S ≤ C” alone does not prevent existing plans plus new recommendations from exceeding it. “Ops supplies authoritative S if occupancy < C” leaves the full-occupancy case unclear, and “default simulation S = C” assumes all capacity is available.
   **Required fix:** Define S as available new-plan slots after existing occupancy and reservations. Require authoritative S for operational release; label full-capacity simulation explicitly. Make clear that WATCH and INCONCLUSIVE remain non-enrolling under standard terms.

7. **A discretionary release hold has no defined contract.**
   Section 14 requires resolution when diagnostics “materially undermine handoff interpretation,” but does not define the evidence trigger, owner, scope, or release status. This could become an undocumented override despite the instruction against analyst discretion replacing the deterministic rule.
   **Required fix:** Define a separate operational-release hold, its reason and resolution owner, while preserving calculated membership. State when resolution requires a new specification version.

8. **The parameter register does not capture all controlling choices.**
   It omits comparator usability—“≥20 other comparator sellers and ≥1,000 comparator eligible seller–orders full-window; ≥200 comparator eligible seller–orders in each half”—and does not consolidate N4/N5 semantics or authoritative S. Builders are nevertheless instructed to lock the parameter register.
   **Required fix:** Consolidate every controlling parameter and rule reference, including status, rationale, approval state, and exact boundary behavior. Distinguish decision parameters from reporting bands and diagnostic stress tests.

**(3) Verdict: REVISE**

The decision architecture is traceable, but the candidate is not yet sufficiently explicit for independent builders to produce the same defensible recommendation.

Resolve the eight gaps above, especially N4/N5 evaluation, the mismatch between hypotheses and gates, and available concurrent capacity. Supply the missing provenance or mark it unverified. **The approved decision and locked analytical question require no rewrite.**
