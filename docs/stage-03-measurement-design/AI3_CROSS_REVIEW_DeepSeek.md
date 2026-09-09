1) Implementation impossibilities or missing fields in A or B

Missing seller_plan_enrollment flag (Both A and B): The Dossier’s Overall Assessment states "Absence of plan enrollment data — comparison requires an external input." Both designs propose an "enrollment" action, but neither design’s SQL A or SQL B schema includes a field for a plan enrollment identifier or timestamp. This makes the "ENROLL_RECOMMENDED" and "enroll" actions non-implementable in isolation and violates the Stage 3 instruction that "ops enrollment not RCT".

Missing multi_seller_order_flag (Design A): Design A requires this field to compute multi_seller_order_flag and separate single- vs multi-seller KPIs as per the Dossier’s §8 Conditional-Pass for SQL-A. The SQL A contract does not list this field, making the handoff gate ≥ 90% of single-seller late have evaluable handoff and the multi_seller_order_flag derivation unimplementable.

Missing seller_id table for membership ranking (Design A): SQL A is defined as a "Judged seller table: 1 row per seller in full universe". There is no schema field to store the final rank, selected, or action (ENROLL_RECOMMENDED | STANDARD_CAPACITY | STANDARD_NOT_QUALIFIED) for a given seller-window, making the enrollment selection process untraceable in a raw-table contract.

Missing live-DB status field (Design B): Design B’s N0 rule ("live-DB critical fail → wait") requires a live-DB status for each seller. No such field is defined in the B_orders + B_items + B_sellers projection contract. This renders the "wait" action impossible to derive from the provided data sources.

2) Join/cardinality/grain bugs that would break SQL A or SQL B or R(B)

Item-level JOIN causing cardinality explosion (Both A and B): The grain is defined as (seller_id, order_id) for both designs, but the data sources are raw_sellers, raw_orders, and raw_items. If a seller_id has multiple order_item_id rows for a single order_id, a direct JOIN without a preliminary DISTINCT order_id collapse will duplicate the order_id in the denominator and numerator, causing eligible_n to count items, not orders. This breaks the Grain contract.

Multi-seller order grain violation (Both A and B): The packet states that a single order with multiple sellers creates a "shared outcome" where one late delivery is attributed to all sellers. The grain (seller_id, order_id) produces one row per seller per order. An ORDER BY or aggregation process that does not explicitly handle this will double-count the same order_id for different sellers, breaking the cardinality assumption that order_id is unique to a seller-window.

Design A block split temporal overlap: Design A uses "Block1 Jan–Apr 2018; Block2 Apr–Jul 2018 (end exclusive)". The month of April is included in both blocks. This creates an overlapping window in the "repetition splits". A SQL JOIN using BETWEEN for both blocks will count the same April orders in both Block1 and Block2, violating the "strictly above" block comparator rule due to dependent samples.

Design B in_lfr_denom=0 QA row requirement: The SQL B contract requires B to carry "thin QA rows with in_lfr_denom=0". If these rows are joined with the eligible_n < 30 exclusion rule, a LEFT JOIN on the eligible_n table will produce NULL for these rows, which could be misinterpreted as zero instead of excluded. The contract must specify a COALESCE or explicit handling for these QA rows to prevent cardinality mismatches in the recon step.

R(B) "B raw only" vs. frozen spec: R(B) must rebuild "associations, window, gates" using "B raw + frozen spec only". However, the comparator for Design B is defined as "Peer set = all eligible_n≥30; band P75 + pooled weighted LFR". The B raw projections do not include the peer set aggregates (e.g., LFR_mkt_weighted, band P75). R(B) cannot compute these percentiles without performing a self-join on the full seller set, which is not a "rebuild" of a pre-computed value but a new aggregation, posing a cardinality risk if the window filtering (2018-01-01 vs 2018-09-01) is not consistently applied.

3) Untestable decision rules or recon gaps

Design A "strictly above" vs "at least" conflict: The decision rule states: "Each block: ≥10 eligible, ≥2 late, LFR strictly above that block’s comparator (equality fails 'strictly above'; equality passes 'at least')". The SQL A contract does not specify if the comparator condition is > or >=. The recon contract requires "Exact... membership... selected". A seller with an LFR equal to the comparator would fail the "strictly above" rule, but the text says "equality passes 'at least'". This is a logical contradiction that makes the membership gate untestable.

Design B "hot/cold" (N6) test undefined: The rule states: "half 'hot' (half LFR ≥ band P75 & half n≥10) and other 'cold' (≤ peer-set median & half n≥10) → watch; thin half → flag, leave in qualify pool." The SQL B contract only includes "split halves", not the result of the hot/cold comparison. There is no recon field to validate the boolean outcome of this test, and the rule does not specify how to combine "hot" and "cold" if both conditions are met, making the "watch" action untestable.

Design B "action" vs "rate" flip (N5): The rule states "date-rule vs timestamp-rule action disagree → inconclusive". The packet says "timestamp twin: Mandatory; late_n_timestamp + disagreement count". However, the SQL B contract only carries late_date/late_ts flags. It does not specify the business logic for what constitutes an "action" disagreement. If the two methods yield a different late count (e.g., 5 vs 6), does that flip the action from enroll to inconclusive? The threshold for "action disagree" is missing from the contracts.

Recon contract mismatch: The recon contract requires "Exact late_n, eligible_n... exact action string; mismatch = critical fail". However, Design A has three action strings (ENROLL_RECOMMENDED, etc.) and Design B has five (enroll, watch, standard_terms, inconclusive, wait). The packet does not define a cross-walk or common taxonomy. A recon comparison between A and B will always result in a "critical fail" because the action strings are not identical, even if the underlying seller set is the same.

Design A handoff gate denominator: The rule requires "≥ 90% of single-seller late have evaluable handoff". It does not specify the denominator for this percentage. Is it 90% of the late_n count or 90% of the handoff_support_n? The recon contract calls for "handoff counts", but the mathematical definition of the percentage is absent.

4) Which design components are Pass Conditional-Pass or Fail for Stage 4 readiness and what must change before lock

Population / KPI / Grain:

Pass. Both designs correctly define the grain as (seller_id, order_id) and the KPI as late_n / eligible_n with no grace period. The ≥30 volume floor is clearly implemented in both.

Sample-size / Uncertainty:

Pass (Conditional). The Wilson intervals are correctly specified (95% descriptive vs 80% LB). However, the comparator requirements (block-level n≥10 for A, half n≥10 for B) rely on the overlapping block logic in Design A, which must be fixed to avoid temporal leakage before it can be deemed fully implementable.

SQL-A / R(B) / Recon:

Conditional-Pass. The contracts are defined, but they are missing required fields. For Design A, multi_seller_order_flag and a handoff_support_n table are mandatory to implement the membership gates. For Design B, the live-DB field is mandatory to implement N0. For Recon, the action strings must be harmonized to a common taxonomy (e.g., Enroll, Watch, Standard, Inconclusive) or the comparison must be explicitly scoped to "qualify" vs "not-qualify" only.

Decision Rules:

Fail (Design A): The "strictly above" vs "at least" rule is a logical contradiction, making the membership determination impossible to validate. Change: The packet must lock one definition (e.g., "strictly above" for all block tests) and codify the operator in the SQL contract.

Fail (Design B): The "hot/cold" (N6) test lacks a defined SQL output field and a clear boolean combination rule for "watch" vs "qualify pool" when a seller has one hot and one cold half. Change: Define a single hot_cold_status field (e.g., HOT, COLD, MIXED, THIN) in the SQL B contract and explicitly state that MIXED qualifies for the enroll pool.

Cap Logic & Actions:

Fail (Both). The cap logic (enroll first min(S,Q)) is untestable in a static SQL table because it requires a row number ordering across the entire result set. Neither SQL A nor SQL B includes a rank field in its core projection. Change: Both SQL A and R(B) must output a final rank column and a selected_flag (1/0) for the top ~20 sellers to make the "no padding" rule enforceable.

Overall Stage 4 Readiness:

Fail. While individual components are Pass or Conditional-Pass, the unresolved critical blocker from the Dossier—"Absence of plan enrollment data"—makes the "enrollment" action infeasible. The designs propose to select sellers but provide no mechanism to document or compare their enrollment status, violating the Stage 3 instruction to "serve enrollment". Before Stage 4 is locked, the project must decide if the output is a ranked list (watchlist) or an actionable enrollment table. If enrollment, the external seller_plan_enrollment table must be added to the scope.

