# EC124 - Mental Health Medication and BMI

This repository is a replication package for an applied economics project studying the relationship between mental health medication use and body mass index in the 2019 Health Survey for England.

## How to Replicate

- Software: R 4.x with `renv`
- Command: `source("code/master.R")`
- Input data: place `hse_2019.dta` in `data/`
- Outputs: figures and tables are written to `output/`, and generated datasets are written to `data/`

Before running the pipeline in a fresh clone:

```r
install.packages("renv")
renv::restore()
source("code/master.R")
```

## Project Overview

- Outcome: continuous BMI
- Main treatment: indicator for taking any mental health medication
- Identification strategy: leave-one-out regional prescribing rates
- Main instrument: Government Office Region leave-one-out prescribing rate
- Alternative instrument: Strategic Health Authority leave-one-out prescribing rate
- Estimation: weighted OLS, first stage, reduced form, and 2SLS using `fixest`
- Inference: standard errors clustered at the geography level used in the specification

## Data and Paper Assets

- `data/`: local-only raw and intermediate datasets
- `paper/`: manuscript source, compiled paper, and Overleaf assets
- The underlying HSE data are not distributed through this repository
- Place the raw input file at `data/hse_2019.dta`
- Keep the HSE 2019 documentation PDF alongside the raw data for reference

See [data/README.md](/Users/aarushbathula/Developer/modules/ec124-meds-bmi/data/README.md) for the expected local file layout.

## Software and Dependencies

- R 4.x
- `renv` for package-version locking
- R packages used by the pipeline: `dplyr`, `ggplot2`, `haven`, `fixest`
- The project uses repo-relative paths, so it should run after cloning without editing machine-specific directories

## Outputs

Running the pipeline produces:

- `output/tables/table_main_effects.tex`
- `output/tables/table_firststage_reducedform.tex`
- `output/tables/table_iv_robustness_instruments.tex`
- `output/tables/table_iv_heterogeneity.tex`
- `output/tables/table_placebo.tex`
- `output/figures/fig_region_prescribing_hist.pdf`
- `output/figures/fig_firststage_binned.pdf`

## PROJECT_STATUS

- Replication workflow: ready
- Data availability: restricted
- Paper assets: included
- Known gaps: reproducibility still depends on local access to the HSE microdata

## Limitations

- The raw HSE data are restricted and are not redistributed through this repository
- Full replication depends on placing the local raw input file in `data/`
- Package versions are locked with `renv`, but results are still constrained by data access and local licensing conditions
