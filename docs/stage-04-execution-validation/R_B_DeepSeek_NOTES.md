# FulfillIQ 2.0 Stage 4 R(B) notes

- Drafted an independent tidyverse rebuild from B_orders, B_items, and B_sellers; no SQL A inputs or logic are used.
- Supports CSV and SQLite input through an explicit CONFIG block and performs raw-key, duplicate, orphan, chronology, and schema QA.
- Reconstructs seller-order grain, DATE lateness plus timestamp twin, disagreement fields, exact late_n and eligible_n, LFR fractions, leave-one-out comparators, membership gates, handoff evidence, N4 counterfactuals, and independent N5 DATE/timestamp runs.
- Applies post-selection rank/capacity actions, freeze/refill rules, locked action taxonomy, and C=20/S=20 full-capacity simulation with occupancy O=0 and no padding.
- The script publishes the judged seller table and QA/audit outputs. It is a draft only and was not executed; no MySQL was run.
