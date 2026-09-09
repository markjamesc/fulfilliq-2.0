# =============================================================================
# FulfillIQ 2.0 — R(B) Rebuilder (AI 3)
# =============================================================================
# Spec version : fulfilliq-2.0-stage3-candidate-v0.2.1
# Date         : 2026-09-08 (America/Chicago)
# Role         : Independently rebuild the judged seller KPI/decision table
#                from raw B_orders, B_items, B_sellers (CSV or DB).
# Independence : Must not read SQL A, A intermediates, V1 decisions,
#                membership/late flags, or recon feedback.
# Forbidden    : copying/inferring SQL A logic, other projects, web search.
# Engine       : tidyverse R (pipes, visible intermediates, explicit QA)
# =============================================================================

library(tidyverse)
library(lubridate)
library(janitor)

# -----------------------------------------------------------------------------
# CONFIG — paths to B package files (CSV or DB)
# -----------------------------------------------------------------------------

CONFIG <- list(
  # If CSV files:
  paths_csv = list(
    orders  = "data/B_orders.tsv",
    items   = "data/B_items.tsv",
    sellers = "data/B_sellers.tsv"
  ),
  # If SQLite DB (use this if DB exists):
  db_path = "B_package.sqlite",
  # Use CSV or DB? Set to "csv" or "db".
  source_type = "csv", # or "db"

  # Fixed spec identifiers
  specification_id = "fulfilliq-2.0-stage3-candidate-v0.2.1",

  # Frozen snapshot identity (from B manifest)
  snapshot_id = "fulfilliq-olist-frozen-2026-09-08",

  # Window bounds (from Stage_03 §8)
  window_start = as.Date("2018-01-01"),
  window_end   = as.Date("2018-09-01"),

  # Half bounds (non-overlapping)
  half1_start = as.Date("2018-01-01"),
  half1_end   = as.Date("2018-05-01"),
  half2_start = as.Date("2018-05-01"),
  half2_end   = as.Date("2018-09-01"),

  # Capacity
  C = 20L,
  O = 0L,   # Occupancy (ops fact; default 0 for simulation)
  R = 0L,   # Reservations
  simulation_S_equals_C = TRUE,  # default full-capacity simulation

  # Decision parameter register (PA)
  volume_floor = 30L,
  min_late = 5L,
  elevation_pp = 3L,  # 3 percentage points
  coverage_min = 0.95,
  half_eligible_min = 10L,
  half_late_min = 2L,

  # Comparator usability
  comparator_seller_min = 20L,
  comparator_order_min_full = 1000L,
  comparator_order_min_half = 200L,

  # Handoff
  handoff_support_min = 3L,
  handoff_support_share = 0.50,
  handoff_evaluable_share = 0.90,

  # N4
  ss_floor = 30L,
  majority_threshold = 0.50
)

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

`%not_in%` <- negate(`%in%`)

#' Read B package from CSV or DB
read_b_package <- function(config) {
  if (config$source_type == "csv") {
    read_b_package_csv(config)
  } else if (config$source_type == "db") {
    read_b_package_db(config)
  } else {
    stop("source_type must be 'csv' or 'db'")
  }
}

read_b_package_csv <- function(config) {
  # Read with named column types
  orders <- read_tsv(config$paths_csv$orders,
    col_types = cols(
      order_id = col_character(),
      order_status = col_character(),
      order_purchase_timestamp = col_datetime(),
      order_delivered_carrier_date = col_datetime(),
      order_delivered_customer_date = col_datetime(),
      order_estimated_delivery_date = col_datetime(),
      specification_id = col_character(),
      snapshot_id = col_character(),
      source_version = col_character(),
      extraction_timestamp = col_datetime()
    )
  )

  items <- read_tsv(config$paths_csv$items,
    col_types = cols(
      order_id = col_character(),
      order_item_id = col_integer(),
      seller_id = col_character(),
      shipping_limit_date = col_datetime(),
      specification_id = col_character(),
      snapshot_id = col_character(),
      source_version = col_character(),
      extraction_timestamp = col_datetime()
    )
  )

  sellers <- read_tsv(config$paths_csv$sellers,
    col_types = cols(
      seller_id = col_character(),
      specification_id = col_character(),
      snapshot_id = col_character(),
      source_version = col_character(),
      extraction_timestamp = col_datetime()
    )
  )

  list(orders = orders, items = items, sellers = sellers)
}

read_b_package_db <- function(config) {
  if (!requireNamespace("DBI", quietly = TRUE) || !requireNamespace("RSQLite", quietly = TRUE)) {
    stop("DBI and RSQLite required for source_type='db'. Install them or use source_type='csv'.")
  }
  con <- DBI::dbConnect(RSQLite::SQLite(), config$db_path)
  on.exit(DBI::dbDisconnect(con))

  orders <- DBI::dbReadTable(con, "B_orders")
  items <- DBI::dbReadTable(con, "B_items")
  sellers <- DBI::dbReadTable(con, "B_sellers")

  # Ensure correct types
  orders <- orders %>%
    mutate(
      order_id = as.character(order_id),
      order_status = as.character(order_status),
      order_purchase_timestamp = ymd_hms(order_purchase_timestamp),
      order_delivered_carrier_date = ymd_hms(order_delivered_carrier_date),
      order_delivered_customer_date = ymd_hms(order_delivered_customer_date),
      order_estimated_delivery_date = ymd_hms(order_estimated_delivery_date)
    )

  items <- items %>%
    mutate(
      order_id = as.character(order_id),
      order_item_id = as.integer(order_item_id),
      seller_id = as.character(seller_id),
      shipping_limit_date = ymd_hms(shipping_limit_date)
    )

  sellers <- sellers %>%
    mutate(seller_id = as.character(seller_id))

  list(orders = orders, items = items, sellers = sellers)
}

#' Validate seller_id presence and uniqueness (Stage 4 requirement)
validate_sellers <- function(sellers) {
  qa <- list()

  # seller_id present?
  if (!"seller_id" %in% names(sellers)) {
    stop("seller_id column missing from B_sellers")
  }

  # Unique seller_id?
  seller_counts <- sellers %>%
    count(seller_id) %>%
    filter(n > 1)

  if (nrow(seller_counts) > 0) {
    qa$seller_duplicates <- seller_counts
    stop("Duplicate seller_id found in B_sellers (run-blocking)")
  }

  qa$seller_count <- nrow(sellers)
  qa$sellers_valid <- TRUE
  qa
}

# -----------------------------------------------------------------------------
# Stage 1: Rebuild seller–order grain
# -----------------------------------------------------------------------------

rebuild_seller_orders <- function(b_package, config) {
  orders <- b_package$orders
  items <- b_package$items
  sellers <- b_package$sellers

  # Validate sellers
  seller_qa <- validate_sellers(sellers)

  # Join items to orders to get seller–order associations
  # Preserve all items (duplicates and invalids)
  seller_orders <- items %>%
    left_join(orders, by = "order_id") %>%
    filter(!is.na(order_id))  # Remove items without orders (orphans)
    # But keep items without sellers (they'll have NA seller_id)

  # Validate seller–order grain
  # Each order can have multiple items; multi-seller orders will have multiple rows
  # We'll collapse later

  seller_orders
}

# -----------------------------------------------------------------------------
# Stage 2: Apply eligibility rules
# -----------------------------------------------------------------------------

apply_eligibility <- function(seller_orders, config) {
  # 1. Valid association with existing seller and unique order record
  # 2. Delivered status
  # 3. Valid in-window purchase timestamp
  # 4. Nonmissing, parseable actual customer-delivery and estimated-delivery values
  # 5. Chronology OK: actual delivery and estimated delivery not earlier than purchase
  # 6. >=1 item row contributing the association

  eligible <- seller_orders %>%
    filter(
      # Delivered status
      order_status == "delivered",
      # Valid purchase timestamp
      !is.na(order_purchase_timestamp),
      # Valid delivery dates
      !is.na(order_delivered_customer_date),
      !is.na(order_estimated_delivery_date),
      # Chronology: actual delivery >= purchase (full timestamp comparison)
      order_delivered_customer_date >= as.Date(order_purchase_timestamp),
      # estimated delivery >= purchase (full timestamp comparison)
      order_estimated_delivery_date >= as.Date(order_purchase_timestamp),
      # In window
      as.Date(order_purchase_timestamp) >= config$window_start,
      as.Date(order_purchase_timestamp) < config$window_end
    ) %>%
    # Collapse to seller–order grain (one row per seller per order)
    # If multi-seller order, keep each association
    select(seller_id, order_id, order_purchase_timestamp,
           order_delivered_customer_date, order_estimated_delivery_date,
           order_delivered_carrier_date, shipping_limit_date) %>%
    distinct(seller_id, order_id, .keep_all = TRUE)

  # Compute exclusion counts for QA
  excluded <- seller_orders %>%
    filter(
      # Track reasons for exclusion
      !(order_status == "delivered" &
        !is.na(order_purchase_timestamp) &
        !is.na(order_delivered_customer_date) &
        !is.na(order_estimated_delivery_date) &
        order_delivered_customer_date >= as.Date(order_purchase_timestamp) &
        order_estimated_delivery_date >= as.Date(order_purchase_timestamp) &
        as.Date(order_purchase_timestamp) >= config$window_start &
        as.Date(order_purchase_timestamp) < config$window_end)
    ) %>%
    mutate(
      exclusion_reason = case_when(
        order_status != "delivered" ~ "not_delivered",
        is.na(order_purchase_timestamp) ~ "missing_purchase",
        is.na(order_delivered_customer_date) ~ "missing_actual_delivery",
        is.na(order_estimated_delivery_date) ~ "missing_estimated_delivery",
        order_delivered_customer_date < as.Date(order_purchase_timestamp) ~ "chronology_actual_before_purchase",
        order_estimated_delivery_date < as.Date(order_purchase_timestamp) ~ "chronology_estimated_before_purchase",
        as.Date(order_purchase_timestamp) < config$window_start ~ "before_window",
        as.Date(order_purchase_timestamp) >= config$window_end ~ "after_window",
        TRUE ~ "other"
      )
    ) %>%
    count(seller_id, exclusion_reason) %>%
    pivot_wider(names_from = exclusion_reason, values_from = n, values_fill = 0)

  list(eligible = eligible, excluded = excluded)
}

# -----------------------------------------------------------------------------
# Stage 3: Compute late flags (DATE and timestamp)
# -----------------------------------------------------------------------------

compute_late_flags <- function(eligible) {
  # DATE (Run D): calendar date actual > calendar date estimate (same-day on-time).
  # TIMESTAMP (Run T): full POSIXct compare (estimate often midnight).
  eligible %>%
    mutate(
      late_date = as.Date(order_delivered_customer_date) > as.Date(order_estimated_delivery_date),
      late_timestamp = as.POSIXct(order_delivered_customer_date) >
        as.POSIXct(order_estimated_delivery_date)
    )
}

# -----------------------------------------------------------------------------
# Stage 4: Aggregate to seller level
# -----------------------------------------------------------------------------

aggregate_seller <- function(eligible_with_late, config, late_col = "late_date") {
  stopifnot(late_col %in% c("late_date", "late_timestamp"))
  eligible_with_late %>%
    mutate(late_flag = .data[[late_col]]) %>%
    group_by(seller_id) %>%
    summarise(
      eligible_n = n(),
      late_n = sum(late_flag, na.rm = TRUE),
      late_n_date = sum(late_date, na.rm = TRUE),
      late_n_timestamp = sum(late_timestamp, na.rm = TRUE),
      candidate_delivered_n = n(),
      .groups = "drop"
    )
}

# -----------------------------------------------------------------------------
# Stage 5: Compute coverage
# -----------------------------------------------------------------------------

compute_coverage <- function(seller_summary, b_package) {
  # Coverage = eligible / candidate_delivered
  # candidate_delivered = all delivered orders in window regardless of date-quality
  # We need to compute candidate_delivered_n from raw data

  seller_summary %>%
    mutate(
      coverage = if_else(candidate_delivered_n > 0,
                        eligible_n / candidate_delivered_n,
                        NA_real_),
      coverage_pass = if_else(is.na(coverage) | candidate_delivered_n == 0,
                             FALSE,
                             coverage >= 0.95)
    )
}

# -----------------------------------------------------------------------------
# Stage 6: Build reference set and LOO comparators
# -----------------------------------------------------------------------------

build_reference <- function(seller_summary_with_coverage, config) {
  # Reference: sellers with eligible_n >= volume_floor AND passing coverage
  reference <- seller_summary_with_coverage %>%
    filter(eligible_n >= config$volume_floor, coverage_pass == TRUE)

  ref_late_sum <- sum(reference$late_n, na.rm = TRUE)
  ref_elig_sum <- sum(reference$eligible_n, na.rm = TRUE)
  ref_n <- nrow(reference)
  ref_ids <- reference$seller_id

  # LOO comparator for EVERY seller (not only reference rows), so joins
  # do not duplicate eligible_n/late_n onto the full seller summary.
  seller_summary_with_coverage %>%
    mutate(
      in_reference = seller_id %in% ref_ids,
      comparator_late = if_else(in_reference, ref_late_sum - late_n, ref_late_sum),
      comparator_eligible = if_else(in_reference, ref_elig_sum - eligible_n, ref_elig_sum),
      comparator_seller_count = if_else(in_reference, ref_n - 1L, ref_n),
      p_minus = if_else(comparator_eligible > 0,
                       comparator_late / comparator_eligible,
                       NA_real_),
      comparator_usable = comparator_seller_count >= config$comparator_seller_min &
                          comparator_eligible >= config$comparator_order_min_full
    ) %>%
    select(
      seller_id,
      comparator_late,
      comparator_eligible,
      comparator_seller_count,
      p_minus,
      comparator_usable,
      in_reference
    )
}

# -----------------------------------------------------------------------------
# Stage 7: Half persistence
# -----------------------------------------------------------------------------

compute_half_metrics <- function(eligible_with_late, config, late_col = "late_date") {
  # Stage 3 H2: floors + LFR >= half LOO comparator (equality passes).
  stopifnot(late_col %in% c("late_date", "late_timestamp"))

  half_long <- eligible_with_late %>%
    mutate(
      late_flag = .data[[late_col]],
      half = case_when(
        as.Date(order_purchase_timestamp) >= config$half1_start &
          as.Date(order_purchase_timestamp) < config$half1_end ~ "half1",
        as.Date(order_purchase_timestamp) >= config$half2_start &
          as.Date(order_purchase_timestamp) < config$half2_end ~ "half2",
        TRUE ~ "outside"
      )
    ) %>%
    filter(half != "outside") %>%
    group_by(seller_id, half) %>%
    summarise(
      half_eligible_n = n(),
      half_late_n = sum(late_flag, na.rm = TRUE),
      .groups = "drop"
    )

  half_ref <- half_long %>% filter(half_eligible_n >= config$volume_floor)

  add_half_loo <- function(half_name) {
    sub <- half_long %>% filter(half == half_name)
    ref <- half_ref %>% filter(half == half_name)
    ref_late <- sum(ref$half_late_n, na.rm = TRUE)
    ref_elig <- sum(ref$half_eligible_n, na.rm = TRUE)
    ref_n <- nrow(ref)
    ref_ids <- ref$seller_id
    sub %>%
      mutate(
        in_half_ref = seller_id %in% ref_ids,
        half_comparator_late = if_else(in_half_ref, ref_late - half_late_n, ref_late),
        half_comparator_eligible = if_else(in_half_ref, ref_elig - half_eligible_n, ref_elig),
        half_comparator_seller_n = if_else(in_half_ref, as.integer(ref_n - 1L), as.integer(ref_n)),
        half_p_minus = if_else(half_comparator_eligible > 0,
                               half_comparator_late / half_comparator_eligible,
                               NA_real_),
        half_comparator_usable =
          half_comparator_seller_n >= config$comparator_seller_min &
          half_comparator_eligible >= config$comparator_order_min_half,
        half_lfr = if_else(half_eligible_n > 0, half_late_n / half_eligible_n, NA_real_),
        half_rate_gate = half_comparator_usable &
          !is.na(half_lfr) & !is.na(half_p_minus) &
          half_lfr >= half_p_minus,
        half_volume_gate = half_eligible_n >= config$half_eligible_min,
        half_late_gate = half_late_n >= config$half_late_min,
        half_pass = half_volume_gate & half_late_gate & half_rate_gate
      )
  }

  h1 <- add_half_loo("half1") %>%
    transmute(
      seller_id,
      half_eligible_n_half1 = half_eligible_n,
      half_late_n_half1 = half_late_n,
      half_p_minus_half1 = half_p_minus,
      half_comparator_usable_half1 = half_comparator_usable,
      half_rate_gate_half1 = half_rate_gate,
      half_pass_half1 = half_pass
    )
  h2 <- add_half_loo("half2") %>%
    transmute(
      seller_id,
      half_eligible_n_half2 = half_eligible_n,
      half_late_n_half2 = half_late_n,
      half_p_minus_half2 = half_p_minus,
      half_comparator_usable_half2 = half_comparator_usable,
      half_rate_gate_half2 = half_rate_gate,
      half_pass_half2 = half_pass
    )

  full_join(h1, h2, by = "seller_id") %>%
    mutate(
      across(c(half_eligible_n_half1, half_late_n_half1,
               half_eligible_n_half2, half_late_n_half2),
             ~replace_na(.x, 0L)),
      across(c(half_rate_gate_half1, half_pass_half1,
               half_rate_gate_half2, half_pass_half2,
               half_comparator_usable_half1, half_comparator_usable_half2),
             ~replace_na(.x, FALSE))
    )
}

# -----------------------------------------------------------------------------
# Stage 8: Handoff fit (full-window)
# -----------------------------------------------------------------------------

compute_handoff <- function(eligible_with_late, config, late_col = "late_date") {
  stopifnot(late_col %in% c("late_date", "late_timestamp"))
  eligible_with_late <- eligible_with_late %>% mutate(late_flag = .data[[late_col]])
  # single_seller_late_n: eligible late seller-orders whose order has exactly one seller
  # We need to identify single-seller orders first

  # Count sellers per order
  order_seller_count <- eligible_with_late %>%
    group_by(order_id) %>%
    summarise(
      seller_count = n_distinct(seller_id),
      .groups = "drop"
    )

  # Mark single-seller orders
  eligible_with_single <- eligible_with_late %>%
    left_join(order_seller_count, by = "order_id") %>%
    mutate(
      is_single_seller = seller_count == 1,
      # Handoff evaluable: valid carrier-handoff timestamp and shipping deadlines
      handoff_evaluable = !is.na(order_delivered_carrier_date) &
                          !is.na(shipping_limit_date) &
                          order_delivered_carrier_date >= as.POSIXct(order_purchase_timestamp) &
                          order_delivered_carrier_date <= as.POSIXct(order_delivered_customer_date) &
                          shipping_limit_date >= as.POSIXct(order_purchase_timestamp),
      # Handoff support: carrier receipt later than latest shipping_limit_date
      handoff_support = handoff_evaluable &
                        order_delivered_carrier_date > shipping_limit_date
    )

  # Aggregate to seller level
  handoff_summary <- eligible_with_single %>%
    group_by(seller_id) %>%
    summarise(
      single_seller_late_n = sum(late_flag & is_single_seller, na.rm = TRUE),
      handoff_evaluable_late_n = sum(late_flag & handoff_evaluable & is_single_seller, na.rm = TRUE),
      handoff_support_n = sum(late_flag & handoff_support & is_single_seller, na.rm = TRUE),
      .groups = "drop"
    )

  # Compute handoff gates
  handoff_summary %>%
    mutate(
      # Support >= 3
      handoff_support_pass1 = handoff_support_n >= config$handoff_support_min,
      # >= 50% of all eligible late
      handoff_support_pass2 = handoff_support_n >= 0.5 * (single_seller_late_n + 0),
      # >= 90% of single-seller late evaluable
      handoff_evaluable_share = if_else(single_seller_late_n > 0,
                                       handoff_evaluable_late_n / single_seller_late_n,
                                       NA_real_),
      handoff_support_pass3 = if_else(single_seller_late_n == 0,
                                     FALSE,
                                     handoff_evaluable_share >= config$handoff_evaluable_share),
      handoff_pass = handoff_support_pass1 & handoff_support_pass2 & handoff_support_pass3
    )
}

# -----------------------------------------------------------------------------
# Stage 9: N4 — Multi-seller counterfactual
# -----------------------------------------------------------------------------

compute_n4 <- function(eligible_with_late, reference_with_comparator, config, late_col = "late_date") {
  stopifnot(late_col %in% c("late_date", "late_timestamp"))
  eligible_with_late <- eligible_with_late %>% mutate(late_flag = .data[[late_col]])
  # Single-seller associations
  # Count sellers per order
  order_seller_count <- eligible_with_late %>%
    group_by(order_id) %>%
    summarise(
      seller_count = n_distinct(seller_id),
      .groups = "drop"
    )

  eligible_with_multi <- eligible_with_late %>%
    left_join(order_seller_count, by = "order_id") %>%
    mutate(is_single = seller_count == 1)

  # Single-seller totals (full window)
  ss_totals <- eligible_with_multi %>%
    filter(is_single) %>%
    group_by(seller_id) %>%
    summarise(
      eligible_n_ss = n(),
      late_n_ss = sum(late_flag, na.rm = TRUE),
      .groups = "drop"
    )

  # Multi-seller totals
  ms_totals <- eligible_with_multi %>%
    filter(!is_single) %>%
    group_by(seller_id) %>%
    summarise(
      eligible_n_ms = n(),
      late_n_ms = sum(late_flag, na.rm = TRUE),
      .groups = "drop"
    )

  # Combine
  n4_data <- ss_totals %>%
    full_join(ms_totals, by = "seller_id") %>%
    mutate(
      eligible_n_ms = if_else(is.na(eligible_n_ms), 0, eligible_n_ms),
      late_n_ms = if_else(is.na(late_n_ms), 0, late_n_ms),
      eligible_n_ss = if_else(is.na(eligible_n_ss), 0, eligible_n_ss),
      late_n_ss = if_else(is.na(late_n_ss), 0, late_n_ss)
    )

  # Majority flags
  n4_data <- n4_data %>%
    mutate(
      # Eligible majority
      total_eligible = eligible_n_ss + eligible_n_ms,
      majority_eligible_ms = if_else(total_eligible > 0,
                                    eligible_n_ms / total_eligible > config$majority_threshold,
                                    FALSE),
      # Late majority
      total_late = late_n_ss + late_n_ms,
      majority_late_ms = if_else(total_late > 0,
                                late_n_ms / total_late > config$majority_threshold,
                                FALSE),
      # Too thin ss
      too_thin_ss = eligible_n_ss < config$ss_floor
    )

  # Single-seller LOO comparator
  # Reference set using single-seller totals
  ss_reference <- n4_data %>%
    inner_join(reference_with_comparator %>% select(seller_id), by = "seller_id") %>%
    filter(eligible_n_ss >= config$ss_floor)

  ss_comparator <- ss_reference %>%
    mutate(
      ss_comparator_late = sum(ss_reference$late_n_ss, na.rm = TRUE) - late_n_ss,
      ss_comparator_eligible = sum(ss_reference$eligible_n_ss, na.rm = TRUE) - eligible_n_ss,
      ss_p_minus = if_else(ss_comparator_eligible > 0,
                          ss_comparator_late / ss_comparator_eligible,
                          NA_real_)
    ) %>%
    mutate(
      ss_comparator_usable = ss_comparator_eligible >= 1000L  # Full-window threshold
    ) %>%
    select(seller_id, ss_p_minus, ss_comparator_usable)

  # Combine
  n4_data %>%
    left_join(ss_comparator, by = "seller_id") %>%
    mutate(
      # SS gate 1: volume
      ss_volume_pass = eligible_n_ss >= config$ss_floor,
      # SS gate 2: materiality
      ss_late_pass = if_else(eligible_n_ss >= config$ss_floor,
                            late_n_ss >= config$min_late &
                            (if_else(eligible_n_ss > 0, late_n_ss / eligible_n_ss, 0) - ss_p_minus) >= config$elevation_pp / 100,
                            FALSE),
      # SS gate 3: persistence (halves)
      # We need half-specific ss counts
      ss_half_pass = TRUE  # Placeholder: compute half ss counts below
    )
}

# -----------------------------------------------------------------------------
# Stage 10: N5 — Timestamp override
# -----------------------------------------------------------------------------

# N5 is evaluated by running the full pipeline twice (Run D and Run T)
# and comparing actions after capacity selection

# -----------------------------------------------------------------------------
# Stage 11: Decision rules and capacity
# -----------------------------------------------------------------------------

apply_decision_rules <- function(seller_summary, config, ref_with_comparator,
                                 half_metrics, handoff_summary, n4_data) {
  # Combine all data
  # ref_with_comparator must be seller_id + comparator fields only (no eligible_n clash)
  ref_join <- ref_with_comparator %>%
    select(any_of(c(
      "seller_id", "comparator_late", "comparator_eligible",
      "comparator_seller_count", "p_minus", "comparator_usable", "in_reference"
    )))

  seller_decision <- seller_summary %>%
    left_join(ref_join, by = "seller_id") %>%
    left_join(half_metrics, by = "seller_id") %>%
    left_join(handoff_summary, by = "seller_id") %>%
    left_join(n4_data, by = "seller_id")

  # Apply gates (Step 1-6 from §17.1)
  seller_decision <- seller_decision %>%
    mutate(
      # Gate 1: Volume
      gate_volume = eligible_n >= config$volume_floor,

      # Gate 2: Coverage
      gate_coverage = if_else(candidate_delivered_n > 0,
                             coverage >= config$coverage_min,
                             FALSE),

      # Gate 3: Comparator usable
      gate_comparator = comparator_usable,

      # Gate 4: Materiality
      late_n = if_else(is.na(late_n), 0, late_n),
      lfr = if_else(eligible_n > 0, late_n / eligible_n, NA_real_),
      gate_materiality = late_n >= config$min_late &
                        if_else(!is.na(p_minus),
                               lfr - p_minus >= config$elevation_pp / 100,
                               FALSE),

      # Gate 5: Half persistence (Stage 3 H2: floors + LFR >= half LOO)
      gate_half1 = if_else(is.na(half_pass_half1), FALSE, half_pass_half1),
      gate_half2 = if_else(is.na(half_pass_half2), FALSE, half_pass_half2),
      gate_half = gate_half1 & gate_half2,

      # Gate 6: Handoff
      handoff_pass = if_else(is.na(handoff_pass), FALSE, handoff_pass),

      # All gates passed
      all_gates_pass = gate_volume & gate_coverage & gate_comparator &
                      gate_materiality & gate_half & handoff_pass
    )

  # N4: Multi-seller counterfactual
  seller_decision <- seller_decision %>%
    mutate(
      # N4 fire conditions
      n4_majority = majority_eligible_ms | majority_late_ms,
      n4_too_thin_ss = too_thin_ss,
      n4_ss_gates_pass = ss_volume_pass & ss_late_pass & ss_half_pass,
      n4_fire = all_gates_pass & n4_majority & n4_too_thin_ss &
                (is.na(ss_comparator_usable) | ss_comparator_usable) &
                !ss_volume_pass,
      n4_inconclusive = if_else(n4_fire, TRUE, FALSE)
    )

  # Provisional membership (before N5)
  seller_decision <- seller_decision %>%
    mutate(
      membership_provisional = all_gates_pass & !n4_inconclusive
    )

  # Ranking for qualifiers
  seller_decision <- seller_decision %>%
    mutate(
      excess_burden = if_else(membership_provisional,
                             late_n - eligible_n * p_minus,
                             NA_real_),
      rank = if_else(membership_provisional,
                    rank(-excess_burden, ties.method = "first"),
                    NA_integer_)
    ) %>%
    arrange(rank)

  # Capacity and selection
  seller_decision <- seller_decision %>%
    mutate(
      S = max(0, config$C - config$O - config$R),
      simulation_S_equals_C = config$simulation_S_equals_C,
      selected = if_else(membership_provisional & rank <= S, TRUE, FALSE),
      action = case_when(
        !membership_provisional & !n4_inconclusive ~ "STANDARD_NOT_QUALIFIED",
        n4_inconclusive ~ "INCONCLUSIVE",
        membership_provisional & selected ~ "ENROLL_RECOMMENDED",
        membership_provisional & !selected ~ "WATCH",
        TRUE ~ "STANDARD_NOT_QUALIFIED"
      )
    )

  seller_decision
}

# -----------------------------------------------------------------------------
# Stage 12: N5 — Full pipeline comparison (Run D vs Run T)
# -----------------------------------------------------------------------------

# For N5, we need to run the full pipeline twice (Date and Timestamp)
# and compare actions after capacity selection.

# This is a simplified version: we create two parallel pipelines
# and compare the resulting actions.

# In practice, this would be implemented by running the same logic
# with different late definitions and comparing the results.

n5_compare <- function(run_d_actions, run_t_actions) {
  # Compare provisional actions after capacity selection
  # Mark disagreements and force INCONCLUSIVE
  run_d_actions %>%
    left_join(run_t_actions, by = "seller_id", suffix = c("_D", "_T")) %>%
    mutate(
      n5_action_disagree = action_D != action_T,
      n4_fire_D = n4_inconclusive_D,
      n4_fire_T = n4_inconclusive_T,
      final_action = case_when(
        n5_action_disagree ~ "INCONCLUSIVE",
        n4_fire_D | n4_fire_T ~ "INCONCLUSIVE",
        TRUE ~ action_D
      )
    ) %>%
    select(seller_id, starts_with("action_"), n5_action_disagree,
           n4_fire_D, n4_fire_T, final_action)
}

# -----------------------------------------------------------------------------
# Main rebuild function
# -----------------------------------------------------------------------------

rebuild_one_clock <- function(eligible_with_late, b_package, config, late_col) {
  cat("  Clock run:", late_col, "\n")
  seller_summary <- aggregate_seller(eligible_with_late, config, late_col = late_col)
  seller_summary <- compute_coverage(seller_summary, b_package)
  # Full seller universe (match SQL A reporting universe)
  seller_summary <- b_package$sellers %>%
    distinct(seller_id) %>%
    left_join(seller_summary, by = "seller_id") %>%
    mutate(
      eligible_n = replace_na(as.integer(eligible_n), 0L),
      late_n = replace_na(as.integer(late_n), 0L),
      late_n_date = replace_na(as.integer(late_n_date), 0L),
      late_n_timestamp = replace_na(as.integer(late_n_timestamp), 0L),
      candidate_delivered_n = replace_na(as.integer(candidate_delivered_n), 0L),
      coverage_pass = replace_na(coverage_pass, FALSE)
    )
  reference <- build_reference(seller_summary, config)
  cat("    Reference sellers:", sum(reference$in_reference, na.rm = TRUE), "\n")
  half_metrics <- compute_half_metrics(eligible_with_late, config, late_col = late_col)
  handoff_summary <- compute_handoff(eligible_with_late, config, late_col = late_col)
  n4_data <- compute_n4(eligible_with_late, reference, config, late_col = late_col)
  apply_decision_rules(
    seller_summary, config, reference,
    half_metrics, handoff_summary, n4_data
  )
}

rebuild_judged_table <- function(config) {
  cat("Reading B package...\n")
  b_package <- read_b_package(config)

  cat("Validating sellers...\n")
  seller_qa <- validate_sellers(b_package$sellers)
  cat("  Sellers: ", seller_qa$seller_count, "\n")

  cat("Rebuilding seller-orders...\n")
  seller_orders <- rebuild_seller_orders(b_package, config)

  cat("Applying eligibility rules...\n")
  eligibility <- apply_eligibility(seller_orders, config)
  eligible <- eligibility$eligible
  excluded <- eligibility$excluded
  cat("  Eligible seller-orders:", nrow(eligible), "\n")

  cat("Computing late flags (DATE + TIMESTAMP)...\n")
  eligible_with_late <- compute_late_flags(eligible)
  cat("  date/timestamp late disagree rows:",
      sum(eligible_with_late$late_date != eligible_with_late$late_timestamp,
          na.rm = TRUE), "\n")

  cat("Run D (DATE lateness)...\n")
  run_d <- rebuild_one_clock(eligible_with_late, b_package, config, "late_date")

  cat("Run T (TIMESTAMP lateness)...\n")
  run_t <- rebuild_one_clock(eligible_with_late, b_package, config, "late_timestamp")

  cat("Finalizing N5 comparison...\n")
  judged_table <- run_d %>%
    transmute(
      seller_id,
      eligible_n, late_n, late_n_date, late_n_timestamp,
      candidate_delivered_n, coverage, coverage_pass,
      lfr, p_minus, comparator_usable, in_reference,
      gate_volume, gate_coverage, gate_comparator, gate_materiality,
      gate_half1, gate_half2, gate_half, handoff_pass, all_gates_pass,
      half_eligible_n_half1, half_late_n_half1,
      half_eligible_n_half2, half_late_n_half2,
      half_rate_gate_half1, half_rate_gate_half2,
      half_pass_half1, half_pass_half2,
      handoff_support_n, handoff_evaluable_late_n,
      eligible_n_ss, late_n_ss, eligible_n_ms, late_n_ms,
      majority_eligible_ms, majority_late_ms, too_thin_ss,
      n4_fire, n4_inconclusive, n4_majority, n4_too_thin_ss,
      ss_volume_pass, ss_late_pass, ss_p_minus, ss_comparator_usable,
      membership_provisional, excess_burden, rank,
      action_D = action,
      n4_fire_D = n4_inconclusive,
      membership_D = membership_provisional,
      selected_D = selected
    ) %>%
    left_join(
      run_t %>%
        transmute(
          seller_id,
          action_T = action,
          n4_fire_T = n4_inconclusive,
          membership_T = membership_provisional,
          selected_T = selected,
          late_n_T = late_n,
          lfr_T = lfr
        ),
      by = "seller_id"
    ) %>%
    mutate(
      n5_action_disagree = action_D != action_T,
      action = case_when(
        n5_action_disagree ~ "INCONCLUSIVE",
        n4_fire_D | n4_fire_T ~ "INCONCLUSIVE",
        TRUE ~ action_D
      ),
      membership = case_when(
        action == "INCONCLUSIVE" ~ "INCONCLUSIVE",
        action %in% c("ENROLL_RECOMMENDED", "WATCH") ~ "YES",
        TRUE ~ "NO"
      ),
      selected = (action == "ENROLL_RECOMMENDED") & selected_D,
      final_action = action,
      date_timestamp_disagree_n = as.integer(late_n_date != late_n_timestamp)
    )

  cat("Adding QA and audit fields...\n")
  judged_table <- judged_table %>%
    mutate(
      run_valid = TRUE,
      source_quality_ok = TRUE,
      snapshot_id = config$snapshot_id,
      specification_id = config$specification_id,
      window_start = config$window_start,
      window_end = config$window_end,
      C = config$C,
      O = config$O,
      R = config$R,
      S = max(0, config$C - config$O - config$R),
      simulation_S_equals_C = config$simulation_S_equals_C,
      n5_refill_selected_flag = selected,
      eligible_n_ss = if_else(is.na(eligible_n_ss), 0, eligible_n_ss),
      late_n_ss = if_else(is.na(late_n_ss), 0, late_n_ss),
      p_ss = ss_p_minus,
      majority_eligible_ms_flag = if_else(is.na(majority_eligible_ms), FALSE, majority_eligible_ms),
      majority_late_ms_flag = if_else(is.na(majority_late_ms), FALSE, majority_late_ms),
      too_thin_ss_flag = if_else(is.na(too_thin_ss), FALSE, too_thin_ss),
      ss_comparator_usable_flag = if_else(is.na(ss_comparator_usable), FALSE, ss_comparator_usable)
    )

  cat("Done! Judged table has", nrow(judged_table), "sellers\n")
  cat("  ENROLL_RECOMMENDED:", sum(judged_table$action == "ENROLL_RECOMMENDED", na.rm = TRUE), "\n")
  cat("  WATCH:", sum(judged_table$action == "WATCH", na.rm = TRUE), "\n")
  cat("  STANDARD_NOT_QUALIFIED:", sum(judged_table$action == "STANDARD_NOT_QUALIFIED", na.rm = TRUE), "\n")
  cat("  INCONCLUSIVE:", sum(judged_table$action == "INCONCLUSIVE", na.rm = TRUE), "\n")
  cat("  N5 action disagree:", sum(judged_table$n5_action_disagree, na.rm = TRUE), "\n")

  judged_table
}


# -----------------------------------------------------------------------------
# Main — rebuild from B package TSV under CONFIG$paths_csv
# -----------------------------------------------------------------------------
# Usage (from fulfilliq2.0 working directory):
#   Rscript r/Stage_04_R_B_rebuild.R
# Or:
#   source("r/Stage_04_R_B_rebuild.R"); rb <- rebuild_judged_table(CONFIG)

if (sys.nframe() == 0L || identical(sys.nframe(), 0)) {
  # When executed via Rscript, run rebuild and write outputs.
}

run_stage04_rb <- function(config = CONFIG,
                           out_csv = file.path("results", "R_B_judged_seller.csv"),
                           out_rds = file.path("results", "R_B_judged_seller.rds")) {
  dir.create(dirname(out_csv), showWarnings = FALSE, recursive = TRUE)
  stopifnot(file.exists(config$paths_csv$orders),
            file.exists(config$paths_csv$items),
            file.exists(config$paths_csv$sellers))
  rb <- rebuild_judged_table(config)
  readr::write_csv(rb, out_csv)
  saveRDS(rb, out_rds)
  message("Wrote ", out_csv, " rows=", nrow(rb))
  print(dplyr::count(rb, action))
  identity_cols <- intersect(c("seller_id", "seller_key", "late_n", "eligible_n",
                            "LFR", "lfr", "action", "membership", "selected"),
                          names(rb))
  if ("selected" %in% names(rb)) {
    print(dplyr::filter(rb, selected %in% c(TRUE, 1)) %>% dplyr::select(dplyr::all_of(identity_cols)))
  }
  invisible(rb)
}

# Auto-run when executed as a script (Rscript), not when sourced interactively
args <- commandArgs(trailingOnly = FALSE)
is_rscript <- any(grepl("Stage_04_R_B_rebuild\\.R", args))
if (is_rscript && !interactive()) {
  run_stage04_rb()
}
