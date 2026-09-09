(1) Improvements to adopt
Apply the volume floor after all exclusions. Adopt B’s explicit
"eligible_n < 30" after exclusions → standard terms. Recompute seller
counts within the frozen window; the full-extract “627 at 30” is not the
decision population. This clarifies A’s volume gate without changing tiny-
volume treatment. [Packet §2, Population / Sample-size]
Make sensitivity checks affect recommendations. Adopt B N4’s
attribution check and N5’s rule that date-versus-timestamp “action”
disagreement → inconclusive. Freeze what “single-seller would not,” “too
thin,” and “multi-seller majority” mean before implementation; the packet
does not fully specify those tests. Keep analytical qualification separate
from cap selection so a rank-driven action change is distinguishable from a
membership change. [Design B N4–N5]
Retain positive evidence of repetition and operational fit. A requires
each block to have "≥10 eligible, ≥2 late" and LFR “strictly above” its
comparator. Its handoff requirements are "≥3" supporting orders, "≥50%"
of all eligible late, and "≥90%" evaluable coverage among single-seller
late. These directly address persistence and a plausible seller corrective
path. Retain those gate types, but do not lock their implementation until
“supporting” and “evaluable” have reproducible definitions. Their numeric
values remain provisional design proposals. [Design A, Decision rules,
gates 5–6]
Preserve A’s independent reconstruction contract. Lock SQL B as
B_orders + B_items + B_sellers, retaining duplicates and invalid records
without derived eligibility, lateness, or judgments. R(B) must reconstruct
associations, exclusions, metrics, and decisions independently. B’s already-
filtered seller-order dump could make SQL A and R(B) agree while sharing
the same upstream error. [Design A/B, SQL B and R(B) contracts]
Reconcile decisions and their ingredients. Retain A’s exact checks for
counts, comparator totals, handoff counts, gates, membership, rank,
selection, and action. B’s LFR tolerance of "1e-12" relative may support
numerical checking, but cannot replace those checks or decide a boundary
outcome. Retain B’s mismatch rule: “neither list ships.” [Design A/B,
Recon contracts]

(2) Alternatives that answer the wrong question
Observed plan-versus-standard comparison is outside this
enrollment question. The Dossier’s requirement for external
seller_plan_enrollment concerns comparing existing groups. It does not
establish which sellers currently warrant enrollment. Remove that
requirement as a blocker for this design; do not invent the field or turn the
task into an intervention evaluation. [Dossier §8, Comparison / Overall
Assessment / G001]
Excess burden is a capacity tie-breaker, not proof that the plan
fits. A’s e_s = k_s − n_s p_{-s} and B’s ELC can prioritize already-
qualified sellers when capacity binds. Using either to establish membership
would substitute estimated burden for the required pattern-and-corrective-
path judgment. Both designs explicitly place their burden ranking after
qualification; preserve that order. [Design A, Rank YES only; Design B,
Cap]
B’s relative-rate screen is insufficient as the complete membership
rule. "own volume-band P75" in bands "30–49 / 50–99 / 100+" , LFR above
the pooled marketplace rate, and "Wilson 80% LB" with "z = 1.2816"
identify relative elevation and statistical evidence. They do not
independently establish recurring seller-remediable patterns. These
measures can inform the decision; substituting them for repetition and
operational-fit requirements answers which sellers have elevated
measured rates. [Design B N3; Packet §2, Operational fit]
Reject fill-to-cap, severity-only, and causal reinterpretations.
Neither design authorizes automatic top-N enrollment; both prohibit
padding. A’s ">7 calendar days" severity measure “does not change
membership,” and B’s ship-limit diagnostic “cannot enroll.” Neither
should become an enrollment override. The Dossier’s non-random-
assignment warning prohibits causal claims; it does not justify replacing
membership rules with percentile ranking alone. [Design A/B, Severity /
Cap; Dossier R004 / L003]

(3) Data risks requiring design change
Multi-seller attribution requires an enforceable gate. Shared order-
level delivery outcomes cannot identify which seller caused lateness, and
the Dossier confirms no item-level delivery timeline. Carry
multi_seller_order_flag , produce separate single- and multi-seller
evidence, and reconcile the attribution-sensitive membership result. A
footnote is insufficient when that result determines enrollment. A’s handoff
proxy also needs a precise definition and must not be described as proof of
seller causation. [Dossier R001 / L002 / G003 / SQL-A verdict; Design
A gate 6; Design B N4]
Lookahead requires a frozen evidence cutoff. A qualifying purchase
window does not itself establish what was observable when the decision
was made. Specify the evidence snapshot and handling of deliveries
recorded after the simulated decision cutoff; apply the same rule in SQL A
and independently in R(B). Post-window delivery can remain eligible under
the purchase clock only when consistent with that cutoff. [Dossier L001;
Design A/B, Cohort clock]
Coverage and chronology must become executable contracts
before Stage 4. Retain A’s coverage gate "≥95%" , with zero candidate
orders failing, and its exclusion of actual/estimated delivery before
purchase. Define the candidate denominator, exclusion precedence, and
how malformed associations affect coverage. Preserve excluded evidence
so R(B) can reproduce those counts; B’s usable-row extraction and
unspecified “thin QA rows” do not demonstrate that capability. [Design A,
Eligible order / Coverage guardrail / SQL B; Design B, SQL B]
Volume instability requires more than a full-window floor.
Recompute usable denominators after exclusions, retain block-level
evidence requirements, and prevent B N6’s “thin half → flag, leave in
qualify pool” from silently satisfying persistence. The Dossier’s volume-
skew risk makes thin-period handling a membership rule, not merely a
reporting note. [Dossier R005; Design A gate 5; Design B N6]
Prevent geolocation multiplication before aggregation. Keep
geolocation joins out of the primary measurement path. If later
segmentation needs geolocation, require a documented unique lookup and
verify unchanged seller-order keys and counts before and after enrichment.
[Dossier R002; Design A/B, Grain]
Replace the Dossier’s broad pass with specific prerequisites. Its
SQL-B/R-B/recon “Pass” verdicts do not resolve the competing extraction
contracts, undefined sensitivity tests, or evidence cutoff. Stage 4 needs
one frozen window, explicit non-overlapping repetition intervals, threshold
definitions, and a complete reconciliation schema. [Dossier §8; Packet
§2, Window length / SQL contracts]

(4) Business requirements lost in B
The corrective-path requirement is not enforced. The missing bar is
“warrant a documented 30-day improvement plan with closer ops
check-ins and seller corrective path rather than ordinary
marketplace monitoring.” B makes carrier/ship-limit evidence
“diagnostic only” and provides no replacement operational-fit gate. A
attempts to enforce this through its handoff requirements; those particular
thresholds are provisional, not business locks. [Locked question; Design
A gate 6; Design B, Operational fit]
Repeated evidence is weakened. B’s hot/cold exclusion does not
require affirmative evidence in both periods, and its thin-half exception
allows qualification without it. The missing A design bar is each block:
"≥10 eligible, ≥2 late" and LFR “strictly above” the block comparator.
This is a proposed implementation of the locked “patterns” requirement,
not a verbatim stakeholder cutoff. [Design A gate 5; Design B N6]
Complete seller disposition is weakened. A reports “Every distinct
valid seller_id in raw_sellers (incl. zero eligible).” B starts from
sellers represented through items, so its volume-suppressed appendix
cannot by itself establish a disposition for every seller. Preserve the full
universe and explicitly enforce “tiny-volume stay standard.” [Locked
decision; Design A/B, Reporting universe]
Extra statuses need a business-action mapping. B’s watch ,
inconclusive , and wait require explicit meanings under “enroll …
versus leave on standard terms.” Distinguish qualified sellers held out
by capacity from non-qualifiers and unresolved cases; analytical
uncertainty must not imply unauthorized enrollment. A whole-list wait also
needs an escalation path compatible with “by mid-month VP ops
meeting.” [Locked decision; Design A/B, Actions; Design B N0]
Capacity intent is retained, but execution remains underspecified.
B preserves membership-first and “Do not pad / do not expand cap.”
Its “top ~20” still requires an exact available-slot rule before
implementation. A supplies "C=20 integer" , but that is a design
operationalization requiring confirmation against actual concurrent
availability. [Design A, Selection; Design B, Cap]

Unresolved Maya choices — separate from adoption/rejection
recommendations:
Confirm the provisional purchase window: A’s “2018-01-01 00:00:00 incl
→ 2018-07-01 00:00:00 excl” or B’s “ >= '2018-01-01 00:00:00' and <
'2018-09-01 00:00:00' ”; confirm the simulated evidence cutoff.
Resolve the material membership tradeoff: A’s "≥5" late and “at least 3
percentage points” elevation versus B’s "late_n >= 4" and relative-
rate/uncertainty screen. Confirm acceptable evidence for a seller corrective
path; statistical elevation alone leaves that requirement unresolved.
Confirm exact available concurrent slots within the existing cap, and the
operational treatment of unresolved cases by the meeting deadline.

