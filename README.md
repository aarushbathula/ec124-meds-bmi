# EC124: Mental Health Medication and BMI

This repository is organised as a small replication package for an instrumental-variables project studying the relationship between mental health medication use and body mass index (BMI) in the 2019 Health Survey for England (HSE).

## Research Question

How is mental health medication use associated with BMI, and what is the implied causal effect when treatment is instrumented using geographic variation in prescribing intensity?

## Empirical Design

- Outcome: continuous BMI
- Main treatment: indicator for taking any mental health medication
- Identification strategy: leave-one-out regional prescribing rates
- Main instrument: Government Office Region (GOR) leave-one-out prescribing rate
- Alternative instrument: Strategic Health Authority (SHA) leave-one-out prescribing rate
- Estimation: weighted OLS, first stage, reduced form, and 2SLS using `fixest`
- Inference: standard errors clustered at the geography level used in the specification

## Repository Structure

- `code/`: data construction, instrument building, estimation, and table/figure scripts
- `data/`: local-only raw and intermediate datasets
- `output/`: generated tables and figures
- `paper/`: manuscript source and compiled paper

## Replication Workflow

Run the full pipeline from the project root with:

```r
source("code/master.R")
```

Or execute the scripts in sequence:

1. `code/01_data_cleaning.R`
2. `code/02_construct_instrument.R`
3. `code/03_iv_analysis.R`
4. `code/04_robustness_checks.R`
5. `code/05_figures_tables.R`

## Data Availability

The underlying HSE data are not distributed through this repository.

- Place the raw input file at `data/hse_2019.dta`
- The project expects the HSE 2019 documentation PDF to sit alongside the raw data for reference
- Intermediate `.rds` files are generated locally by the scripts and are intentionally excluded from Git

See [data/README.md](data/README.md) for the expected local file layout.

## Main Outputs

Running the pipeline produces:

- `output/tables/table_main_effects.tex`
- `output/tables/table_firststage_reducedform.tex`
- `output/tables/table_iv_robustness_instruments.tex`
- `output/tables/table_iv_heterogeneity.tex`
- `output/tables/table_placebo.tex`
- `output/figures/fig_region_prescribing_hist.pdf`
- `output/figures/fig_firststage_binned.pdf`
- `output/logs/` for any local run logs you choose to create

## Software

The scripts use R and the following packages:

- `tidyverse`
- `dplyr`
- `ggplot2`
- `haven`
- `fixest`

The project now uses repo-relative paths, so it should run after cloning without editing machine-specific directories.

## Notes For Readers

- This repository is structured for reproducibility of workflow, not public redistribution of restricted microdata
- The identification logic is implemented in the code, but any serious reuse should still be accompanied by a written discussion of exclusion restrictions, sampling restrictions, and variable construction choices in the paper
