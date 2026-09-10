# Rebuild the committed R(B) implementation from the frozen B TSV files.
# Run from the repository root: Rscript scripts/reproduce_rb.R
# Optional output directory: Rscript scripts/reproduce_rb.R results/reproduced/my-run
# The builder does not read SQL A or its output. Compare separately afterward.

options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args)) args[[1]] else "results/reproduced/local-run"
if (dir.exists(out_dir) && length(list.files(out_dir, all.files = TRUE, no.. = TRUE))) {
  stop("Output directory is not empty. Choose a new directory to preserve prior runs.")
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

source("r/Stage_04_R_B_rebuild.R")
on.exit_capture <- function() {
  writeLines(capture.output(sessionInfo()), file.path(out_dir, "sessionInfo.txt"))
  versions <- installed.packages()
  write.csv(
    versions[, c("Package", "Version", "Built"), drop = FALSE],
    file.path(out_dir, "installed_packages.csv"), row.names = FALSE
  )
}

tryCatch({
  run_stage04_rb(
    config = CONFIG,
    out_csv = file.path(out_dir, "R_B_judged_seller.csv"),
    out_rds = file.path(out_dir, "R_B_judged_seller.rds")
  )
}, finally = on.exit_capture())
