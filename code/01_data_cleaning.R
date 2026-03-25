# -------------------------------
# 01_data_cleaning.R
# Clean HSE 2019 and build main analysis dataset
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
load_required_packages(c("dplyr", "haven"))

# 0. Paths ------------------------------------------------------------

raw_path   <- file.path(root_dir, "data", "hse_2019.dta")
clean_path <- file.path(root_dir, "data", "hse_2019_clean.rds")

# 1. Helper functions -------------------------------------------------

# Treat negative numeric codes as missing (HSE convention)
na_if_neg <- function(x) {
  if (!is.numeric(x)) return(x)
  ifelse(x < 0, NA, x)
}

# Flexible variable finder:
#   - tries a sequence of regex patterns
#   - returns the *first* match
#   - throws a clear error if nothing is found
find_var <- function(df, patterns, label) {
  for (p in patterns) {
    hits <- grep(p, names(df), ignore.case = TRUE, value = TRUE)
    if (length(hits) > 0) {
      message("Matched ", label, " to variable: ", hits[1], " (pattern: ", p, ")")
      return(hits[1])
    }
  }
  stop("Couldn't find variable for '", label, "'. ",
       "Check names(hse_raw) and the HSE 2019 docs.", call. = FALSE)
}

# 2. Load raw data ----------------------------------------------------

hse_raw <- read_dta(raw_path)

# 3. Resolve actual variable names (robust to small naming differences) ----------

id_var       <- grep("serial", names(hse_raw), ignore.case = TRUE, value = TRUE)
id_var       <- ifelse(length(id_var) > 0, id_var[1], NA_character_)

bmi_var      <- find_var(hse_raw,
                         c("^BMIVAL2$", "^BMIVAL$", "bmi$"),
                         "BMI (continuous)")

bmi_cat_var  <- find_var(hse_raw,
                         c("^BMIVG52$", "bmivg5"),
                         "BMI 5-group")

med_any_var  <- find_var(hse_raw,
                         c("^MENHTAKg2$", "menhtak"),
                         "any mental health med")

med_ad_var   <- find_var(hse_raw,
                         c("^AntiDepTakg2$", "antidep"),
                         "antidepressants")

med_ap_var   <- find_var(hse_raw,
                         c("^ANTIPSYTAKg2$", "antipsytak"),
                         "antipsychotics")

med_hyp_var  <- find_var(hse_raw,
                         c("^HYPNOTAKg2$", "hypnotak"),
                         "hypnotics")

age_band_var <- find_var(hse_raw,
                         c("^Age16g5$", "age16"),
                         "age 16+ 5-year bands")

sex_var      <- find_var(hse_raw,
                         c("^SEX$"),
                         "sex")

eth_var      <- find_var(hse_raw,
                         c("^ORIGIN2$", "origin"),
                         "ethnicity")

nssec_var    <- find_var(hse_raw,
                         c("^NSSEC5$", "nssec"),
                         "NSSEC")

incq_var     <- find_var(hse_raw,
                         c("^EQV5$", "eqv5", "income"),
                         "income quintiles")

educ_var     <- find_var(hse_raw,
                         c("^TOPQUAL3$", "topqual"),
                         "education")

smoke_var    <- find_var(hse_raw,
                         c("^CIGST1_19$", "cigst1"),
                         "smoking status")

alcohol_var  <- find_var(hse_raw,
                         c("^totalwug_19$", "totalwug"),
                         "weekly alcohol units")

lipid_var    <- find_var(hse_raw,
                         c("^LIPID2$", "lipid"),
                         "lipid-lowering drug")

diur_var     <- find_var(hse_raw,
                         c("^DIUR2$", "diur"),
                         "diuretic")

beta_var     <- find_var(hse_raw,
                         c("^BETA2$", "beta"),
                         "beta-blocker")

gor_var      <- find_var(hse_raw,
                         c("^GOR1$", "gor"),
                         "Government Office Region")

sha_var      <- find_var(hse_raw,
                         c("^SHA$", "sha"),
                         "SHA")

imd_var      <- find_var(hse_raw,
                         c("^QIMD19$", "imd"),
                         "IMD quintile")

urban_var    <- find_var(hse_raw,
                         c("^URBAN14b$", "urban"),
                         "urban/rural")

wt_var       <- find_var(hse_raw,
                         c("^WT_INT$", "wt_int", "weight"),
                         "interview weight")

# 4. Clean and construct variables -----------------------------------

hse_tmp <- hse_raw %>%
  mutate(
    # Outcome
    bmi      = na_if_neg(.data[[bmi_var]]),
    bmi_cat5 = na_if_neg(.data[[bmi_cat_var]]),
    
    # Treatment + med types
    med_any   = na_if_neg(.data[[med_any_var]]),
    med_ad    = na_if_neg(.data[[med_ad_var]]),
    med_ap    = na_if_neg(.data[[med_ap_var]]),
    med_hypno = na_if_neg(.data[[med_hyp_var]]),
    
    # Demographics / SES
    age_band  = na_if_neg(.data[[age_band_var]]),
    sex_raw   = na_if_neg(.data[[sex_var]]),
    ethnicity = na_if_neg(.data[[eth_var]]),
    nssec     = na_if_neg(.data[[nssec_var]]),
    inc_quint = na_if_neg(.data[[incq_var]]),
    educ      = na_if_neg(.data[[educ_var]]),
    
    # Behaviours
    smoker    = na_if_neg(.data[[smoke_var]]),
    alcohol_uw= na_if_neg(.data[[alcohol_var]]),
    
    # Other meds
    lipid_drug_raw = na_if_neg(.data[[lipid_var]]),
    diur_drug_raw  = na_if_neg(.data[[diur_var]]),
    beta_drug_raw  = na_if_neg(.data[[beta_var]]),
    
    # Geography + weights
    gor       = na_if_neg(.data[[gor_var]]),
    sha       = na_if_neg(.data[[sha_var]]),
    imd_quint = na_if_neg(.data[[imd_var]]),
    urban     = na_if_neg(.data[[urban_var]]),
    weight    = na_if_neg(.data[[wt_var]]),
    
    # ID if available
    id_raw    = if (!is.na(id_var)) .data[[id_var]] else NA
  )

# 5. Define analysis sample -------------------------------------------

hse <- hse_tmp %>%
  filter(
    !is.na(bmi),
    !is.na(med_any),
    !is.na(gor),
    !is.na(weight)
  ) %>%
  mutate(
    # If SERIALA2 missing, create a simple ID
    id = if (!all(is.na(id_raw))) as.integer(id_raw) else row_number()
  ) %>%
  transmute(
    id,
    bmi,
    bmi_cat5  = factor(bmi_cat5),
    
    # Binary treatment dummies
    med_any   = as.integer(med_any   == 1),
    med_ad    = as.integer(med_ad    == 1),
    med_ap    = as.integer(med_ap    == 1),
    med_hypno = as.integer(med_hypno == 1),
    
    # Controls
    age_band  = factor(age_band),
    sex       = factor(sex_raw, labels = c("Male", "Female")),
    ethnicity = factor(ethnicity),
    nssec     = factor(nssec),
    inc_quint = factor(inc_quint),
    educ      = factor(educ),
    smoker    = factor(smoker),
    alcohol_uw,
    
    lipid_drug = as.integer(lipid_drug_raw == 1),
    diur_drug  = as.integer(diur_drug_raw  == 1),
    beta_drug  = as.integer(beta_drug_raw  == 1),
    
    gor        = factor(gor),
    sha        = factor(sha),
    imd_quint  = factor(imd_quint),
    urban      = factor(urban),
    
    weight
  )

# 6. Quick sanity checks ----------------------------------------------

cat("N (analysis sample): ", nrow(hse), "\n")
print(summary(hse$med_any))
print(summary(hse$bmi))
print(table(hse$gor))

# 7. Save cleaned dataset ---------------------------------------------

saveRDS(hse, clean_path)

message("Saved cleaned dataset to: ", clean_path)
