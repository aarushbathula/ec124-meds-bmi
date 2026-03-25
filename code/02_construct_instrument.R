# -------------------------------
# 02_construct_instrument.R
# Build regional prescribing instruments (leave-one-out rates)
# -------------------------------

library(tidyverse)

root_dir   <- "/Users/aarushbathula/Developer/mental-health-meds-bmi-iv"
clean_path <- file.path(root_dir, "data", "hse_2019_clean.rds")
iv_path    <- file.path(root_dir, "data", "hse_2019_iv.rds")

dat <- readRDS(clean_path)

# Leave-one-out prescribing rate by GOR -------------------------------
dat_iv <- dat %>%
  group_by(gor) %>%
  mutate(
    n_gor       = n(),
    med_sum_gor = sum(med_any, na.rm = TRUE),
    instr_gor   = ifelse(
      n_gor > 1,
      (med_sum_gor - med_any) / (n_gor - 1),
      NA_real_
    )
  ) %>%
  ungroup() %>%
  # Optional: SHA-level instrument
  group_by(sha) %>%
  mutate(
    n_sha       = n(),
    med_sum_sha = sum(med_any, na.rm = TRUE),
    instr_sha   = ifelse(
      n_sha > 1,
      (med_sum_sha - med_any) / (n_sha - 1),
      NA_real_
    )
  ) %>%
  ungroup() %>%
  # Center instruments (helps numerics)
  mutate(
    instr_gor_c = instr_gor - mean(instr_gor, na.rm = TRUE),
    instr_sha_c = instr_sha - mean(instr_sha, na.rm = TRUE)
  )

summary(dat_iv$instr_gor)
summary(dat_iv$instr_sha)

saveRDS(dat_iv, iv_path)
message("Saved IV dataset to: ", iv_path)