# ----------------------------------------
# master.R
# Runs the full IV pipeline from a repo-relative path
# ----------------------------------------

setup_file <- if (file.exists(file.path("code", "00_project_setup.R"))) {
  file.path("code", "00_project_setup.R")
} else if (file.exists("00_project_setup.R")) {
  "00_project_setup.R"
} else {
  stop("Could not find code/00_project_setup.R", call. = FALSE)
}
source(setup_file)

root_dir <- project_root()
setwd(root_dir)
ensure_project_dirs(root_dir)

cat("Working directory set to:", getwd(), "\n")

# 1. Package check -----------------------------------------------------

needed <- c("dplyr", "ggplot2", "haven", "fixest")
load_required_packages(needed)

# 2. Run each step in order -------------------------------------------

run_step <- function(file) {
  cat("\n==============================\n")
  cat("Running:", file, "\n")
  cat("==============================\n")
  source(file.path(root_dir, file))
  cat("Finished:", file, "\n")
}

run_step(file.path("code", "01_data_cleaning.R"))
run_step(file.path("code", "02_construct_instrument.R"))
run_step(file.path("code", "03_iv_analysis.R"))
run_step(file.path("code", "04_robustness_checks.R"))
run_step(file.path("code", "05_figures_tables.R"))

cat("\nALL DONE. Outputs are in:\n")
cat("  - data/hse_2019_clean.rds\n")
cat("  - data/hse_2019_iv.rds\n")
cat("  - data/models_main.rds\n")
cat("  - output/tables/*.tex\n")
cat("  - output/figures/*.pdf\n")
