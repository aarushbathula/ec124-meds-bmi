# -------------------------------
# 05_figures_tables.R
# Figures: instrument variation, first-stage plot, model tables
# -------------------------------

setup_file <- if (file.exists(file.path("code", "00_project_setup.R"))) {
  file.path("code", "00_project_setup.R")
} else if (file.exists("00_project_setup.R")) {
  "00_project_setup.R"
} else {
  stop("Could not find code/00_project_setup.R", call. = FALSE)
}
source(setup_file)

root_dir <- project_root()
ensure_project_dirs(root_dir)
load_required_packages(c("dplyr", "ggplot2", "fixest"))

iv_path  <- file.path(root_dir, "data", "hse_2019_iv.rds")
mod_path <- file.path(root_dir, "data", "models_main.rds")

fig_dir  <- file.path(root_dir, "output", "figures")
tab_dir  <- file.path(root_dir, "output", "tables")

dat <- readRDS(iv_path)
models_main <- readRDS(mod_path)

# Keep non-missing instrument
dat_plot <- dat %>% filter(!is.na(instr_gor))

# ------------------------------------------------------------
# 1. Histogram of regional prescribing variation
# ------------------------------------------------------------

region_rates <- dat_plot %>%
  group_by(gor) %>%
  summarise(
    rate = mean(med_any, na.rm = TRUE),
    n    = n(),
    .groups = "drop"
  )

p1 <- ggplot(region_rates, aes(x = rate)) +
  geom_histogram(bins = 15, colour = "black", fill = "grey80") +
  labs(
    x = "Regional mental health prescribing rate",
    y = "Count",
    title = "Variation in mental health prescribing across GORs"
  )

ggsave(file.path(fig_dir, "fig_region_prescribing_hist.pdf"), p1)


# ------------------------------------------------------------
# 2. Binned first-stage relationship (manual implementation)
# ------------------------------------------------------------

# Get first-stage model
fs <- models_main$first_stage

# Predict using underlying data
dat_plot <- dat_plot %>%
  mutate(
    fs_fitted = predict(fs, newdata = dat_plot),
    bin       = ntile(instr_gor_c, 20)
  )

binned <- dat_plot %>%
  group_by(bin) %>%
  summarise(
    instr_bin = mean(instr_gor_c, na.rm = TRUE),
    med_hat   = mean(fs_fitted, na.rm = TRUE),
    .groups   = "drop"
  )

p2 <- ggplot(binned, aes(x = instr_bin, y = med_hat)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, colour = "black") +
  labs(
    x = "GOR prescribing instrument (centered, binned)",
    y = "Predicted probability of medication",
    title = "First stage: instrument → mental health medication"
  )

ggsave(file.path(fig_dir, "fig_firststage_binned.pdf"), p2)


# ------------------------------------------------------------
# 3. Combined model table for the paper
# ------------------------------------------------------------

etable(
  setNames(models_main, c("OLS", "First stage", "Reduced form", "2SLS")),
  tex  = TRUE,
  file = file.path(tab_dir, "table_all_models.tex")
)

message("Figures saved to: ", fig_dir)
message("Tables saved to: ", tab_dir)
