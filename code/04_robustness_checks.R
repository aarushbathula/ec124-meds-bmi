# -------------------------------
# 04_robustness_checks.R
# Robustness: alt instruments, multiple IVs, heterogeneity, placebo
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

iv_path  <- file.path(root_dir, "data", "hse_2019_iv.rds")
tab_dir  <- file.path(root_dir, "output", "tables")

dat <- readRDS(iv_path)

# Ensure instruments exist --------------------------------------------
dat <- dat %>%
  filter(!is.na(instr_gor_c))

# Controls ------------------------------------------------------------
ctrls <- ~ age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug

# 1. Alternative IV: SHA-level ---------------------------------------
dat_sha <- dat %>%
  filter(!is.na(instr_sha_c))

f_iv_sha <- bmi ~ 1 + age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug |
  med_any ~ instr_sha_c

m_iv_sha <- feols(
  f_iv_sha,
  data    = dat_sha,
  weights = ~weight,
  cluster = ~sha
)

# 2. Multiple IVs: GOR + SHA -----------------------------------------
dat_both <- dat_sha  # already has both instr_gor_c and instr_sha_c non-missing

f_iv_multi <- bmi ~ 1 + age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug |
  med_any ~ instr_gor_c + instr_sha_c

m_iv_multi <- feols(
  f_iv_multi,
  data    = dat_both,
  weights = ~weight,
  cluster = ~gor
)

# 3. Heterogeneity by med type ---------------------------------------

f_iv_ad <- bmi ~ 1 + age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug |
  med_ad ~ instr_gor_c

m_iv_ad <- feols(
  f_iv_ad,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

f_iv_ap <- bmi ~ 1 + age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug |
  med_ap ~ instr_gor_c

m_iv_ap <- feols(
  f_iv_ap,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

f_iv_hy <- bmi ~ 1 + age_band + sex + ethnicity + nssec + inc_quint +
  educ + smoker + alcohol_uw +
  imd_quint + urban +
  lipid_drug + diur_drug + beta_drug |
  med_hypno ~ instr_gor_c

m_iv_hy <- feols(
  f_iv_hy,
  data    = dat,
  weights = ~weight,
  cluster = ~gor
)

# 4. Placebo: non-medicated sample -----------------------------------

dat_placebo <- dat %>%
  filter(med_any == 0)

m_placebo <- feols(
  bmi ~ instr_gor_c + age_band + sex + ethnicity + nssec + inc_quint +
    educ + smoker + alcohol_uw +
    imd_quint + urban +
    lipid_drug + diur_drug + beta_drug,
  data    = dat_placebo,
  weights = ~weight,
  cluster = ~gor
)

# Export tables -------------------------------------------------------

etable(
  list("IV: SHA instrument" = m_iv_sha,
       "IV: GOR + SHA instruments" = m_iv_multi),
  tex  = TRUE,
  file = file.path(tab_dir, "table_iv_robustness_instruments.tex")
)

etable(
  list("IV: Antidepressants" = m_iv_ad,
       "IV: Antipsychotics"  = m_iv_ap,
       "IV: Hypnotics"       = m_iv_hy),
  tex  = TRUE,
  file = file.path(tab_dir, "table_iv_heterogeneity.tex")
)

etable(
  list("Placebo: non-medicated sample" = m_placebo),
  tex  = TRUE,
  file = file.path(tab_dir, "table_placebo.tex")
)

message("Robustness checks complete. Tables written to ", tab_dir)
