# Stage 4 Exact Reconciliation Freeze — FulfillIQ 2.0

**Gate:** Validation Gate (exact recon A vs R(B))  
**Result:** **Pass**  
**Date:** 2026-09-09 (America/Chicago)  
**Spec:** `fulfilliq-2.0-stage3-candidate-v0.2.1`  
**Snapshot:** `fulfilliq-olist-frozen-2026-09-08` / `olist-csv-raw_tables`  
**Capacity:** C=20, O=0, R=0, S=20 — *full-capacity simulation (not authoritative for live enrollment)*

## Builders (independent)

| Path | Builder | Artifact |
| --- | --- | --- |
| SQL A | ChatGPT (plain SQL A; lasting `a4_*` scratch + `a4_judged_seller`) | MySQL `fulfilliq.a4_judged_seller` |
| SQL B | Grok | `B_orders` / `B_items` / `B_sellers` (+ TSV export) |
| R(B) | DeepSeek script + Stage 4 coordinator fixes for Stage 3 H2 half-rate + real N5 twin + full seller universe | `results/R_B_judged_seller.csv` |

Independence held for first freeze attempt: A did not read B_*; R(B) did not read A. After KPI-exact / action-mismatch diagnosis, R(B) was repaired to implement locked Stage 3 rules (not copied from A’s seller list), then re-run and re-frozen.

## Package freeze hashes (SHA-256)

| Artifact | SHA-256 |
| --- | --- |
| `data/B_orders.tsv` | `B3B5E18AE4CC7947420AD155929AEB70C32C58FB5E7EE265CCEAFD8CBC60F7DB` |
| `data/B_items.tsv` | `3814FE44DD773199025F3F8E860CADC9D295A66C22FF93CBCC39AB0E51510BB1` |
| `data/B_sellers.tsv` | `A826359A6DEE4F3C049971E14BB7EAF32EAA38279594F03EF8DA66DAC645F076` |
| `results/A_judged_seller_freeze.tsv` (seller_id, late_n, eligible_n, LFR, action, membership, selected) | `C7D884C6FB94BAE6DB609B05AA369ABD46F4AD30DB3941C2CBCDE3BA0B4D37DF` |
| `results/R_B_judged_seller.csv` | `58482F6D84A2B60F6E6AE7742302B091693C96650D9FF02487AF32545D564CC0` |

Local PC paths under `C:\Users\Mark\Documents\R Working Directory\fulfilliq2.0\`.

## Exact recon results (final freeze)

Universe: **3,095 / 3,095** sellers (full overlap).

| Field | Match |
| --- | --- |
| `late_n` | 3095 / 3095 exact |
| `eligible_n` | 3095 / 3095 exact |
| `action` | 3095 / 3095 exact |
| `membership` | 3095 / 3095 exact |
| `selected` | 3095 / 3095 exact |
| Selected seller set | identical **7**; A-only 0; R-only 0 |
| INCONCLUSIVE set | identical **2**: `5058e8c1e82653974541e83690655b4a`, `e9bc59e7b60fc3063eb2290deda4cced` |

### Selected ENROLL_RECOMMENDED (simulation S=20; Q=7 ≤ S)

| seller_id | late_n | eligible_n | action |
| --- | ---: | ---: | --- |
| `06a2c3af7b3aee5d69171b0e14f0ee87` | 74 | 389 | ENROLL_RECOMMENDED |
| `cac4c8e7b1ca6252d8f20b2fc1a2e4af` | 11 | 46 | ENROLL_RECOMMENDED |
| `2eb70248d66e0e3ef83659f71b244378` | 21 | 187 | ENROLL_RECOMMENDED |
| `bbad7e518d7af88a0897397ffdca1979` | 9 | 38 | ENROLL_RECOMMENDED |
| `b561927807645834b59ef0d16ba55a24` | 12 | 85 | ENROLL_RECOMMENDED |
| `c60b801f2d52c7f7f91de00870882a75` | 6 | 39 | ENROLL_RECOMMENDED |
| `e9d99831abad74458942f21e16f33f92` | 5 | 32 | ENROLL_RECOMMENDED |

Float display LFR is not authority; integer late/eligible matched.

## Pre-fix mismatch (process note — not a fail of final freeze)

First R(B) run matched KPIs on overlap but disagreed on 5 actions (3 extra ENROLL; 2 INCONCLUSIVE→STANDARD) and omitted 765 zero-eligible sellers. Root cause: R under-implemented Stage 3 H2 half-rate vs LOO, faked N5, incomplete universe. Repaired toward locked Stage 3; re-ran; final freeze exact.

## Operational-release note

Validation Gate **Pass** unlocks Stage 5 interpretation on this validated simulation pack. It does **not** authorize live enrollment release. Simulation label required on any roster derived from S=C=20.

## Gate decision

**Pass** — exact recon contract satisfied on membership / selected / action / late_n / eligible_n / universe / snapshot identity for the frozen pack above.
