# ----------------------------------------
# run_all.R
# Master script: runs the full IV pipeline
# ----------------------------------------

# 0. Set project root (YOUR PATH)
root_dir <- "/Users/aarushbathula/Developer/mental-health-meds-bmi-iv"

setwd(root_dir)
cat("Working directory set to:", getwd(), "\n")

# 1. Package check / install ------------------------------------------

needed <- c("tidyverse", "haven", "fixest", "modelsummary")

to_install <- needed[!(needed %in% installed.packages()[, "Package"])]

if (length(to_install) > 0) {
  cat("Installing missing packages:", paste(to_install, collapse = ", "), "\n")
  install.packages(to_install)
}

invisible(lapply(needed, library, character.only = TRUE))

# 2. Run each step in order -------------------------------------------

run_step <- function(file) {
  cat("\n==============================\n")
  cat("Running:", file, "\n")
  cat("==============================\n")
  source(file)
  cat("Finished:", file, "\n")
}

run_step("code/01_data_cleaning.R")
run_step("code/02_construct_instrument.R")
run_step("code/03_iv_analysis.R")
run_step("code/04_robustness_checks.R")
run_step("code/05_figures_tables.R")

cat("\nALL DONE. Outputs are in:\n")
cat("  - data/hse_2019_clean.rds\n")
cat("  - data/hse_2019_iv.rds\n")
cat("  - data/models_main.rds\n")
cat("  - output/tables/*.tex\n")
cat("  - output/figures/*.pdf\n")