# -------------------------------
# 03_iv_analysis.R
# Baseline OLS, first stage, reduced form, and 2SLS
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
load_required_packages(c("dplyr", "fixest"))

iv_path   <- file.path(root_dir, "data", "hse_2019_iv.rds")
out_table <- file.path(root_dir, "output", "tables")

dat <- readRDS(iv_path)

# Keep only obs with non-missing instrument ---------------------------
dat <- dat %>%
  filter(!is.na(instr_gor_c))

# 1. OLS: BMI on med_any + controls ----------------------------------

m_ols <- feols(
  bmi ~ med_any +
    age_band + sex + ethnicity + nssec + inc_quint +
    educ + smoker + alcohol_uw +
    imd_quint + urban +
    lipid_drug + diur_drug + beta_drug,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

# 2. First stage: med_any on instrument + controls --------------------

m_fs <- feols(
  med_any ~ instr_gor_c +
    age_band + sex + ethnicity + nssec + inc_quint +
    educ + smoker + alcohol_uw +
    imd_quint + urban +
    lipid_drug + diur_drug + beta_drug,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

# 3. Reduced form: BMI on instrument + controls -----------------------

m_rf <- feols(
  bmi ~ instr_gor_c +
    age_band + sex + ethnicity + nssec + inc_quint +
    educ + smoker + alcohol_uw +
    imd_quint + urban +
    lipid_drug + diur_drug + beta_drug,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

# 4. 2SLS: BMI on instrumented med_any + controls ---------------------
# Syntax: y ~ controls | endogenous ~ instruments

m_iv <- feols(
  bmi ~
    age_band + sex + ethnicity + nssec + inc_quint +
    educ + smoker + alcohol_uw +
    imd_quint + urban +
    lipid_drug + diur_drug + beta_drug |
    med_any ~ instr_gor_c,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

# Weak instrument F-stat ----------------------------------------------

iv_fstat <- fitstat(m_iv, type = "ivf")
print(iv_fstat)

# Save models for later scripts ---------------------------------------

saveRDS(
  list(ols = m_ols, first_stage = m_fs, reduced_form = m_rf, iv = m_iv),
  file.path(root_dir, "data", "models_main.rds")
)

# Export LaTeX tables -------------------------------------------------

etable(
  list("OLS" = m_ols, "2SLS" = m_iv),
  tex  = TRUE,
  file = file.path(out_table, "table_main_effects.tex")
)

etable(
  list("First stage" = m_fs, "Reduced form" = m_rf),
  tex  = TRUE,
  file = file.path(out_table, "table_firststage_reducedform.tex")
)

message("Main IV analysis complete. Tables written to ", out_table)
