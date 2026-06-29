# FOMA-CER-COD-Paris

First-order meta-analysis of **Corporate Environmental Responsibility (CER) → Cost of
Debt (COD)**, with the **Paris Agreement** as a temporal moderator. Target journal:
*Business Strategy and the Environment*.

## Repository structure

```
.
├── R/                  # analysis scripts + paired verifiers (00_… onward)
├── data/               # raw data — the .xlsx effect-size database (tracked)
│   └── processed/      # intermediate CSVs (gitignored)
├── output/             # results CSVs, xlsx workbooks, plots (tracked)
├── docs/               # DECISION_LOG.md, analysis plan, boilerplate templates
├── manuscript/         # per-analysis .md write-ups
├── setup.R             # loads core packages, prints session info
├── run_all.R           # orchestrator: ordered list of analysis scripts
├── renv.lock           # pinned package versions
└── .gitignore
```

## How to reproduce

1. Clone the repository.
2. Restore the package environment:
   ```r
   renv::restore()
   ```
3. Run the analysis scripts in `R/` in numbered order (or via `run_all.R` once the
   scripts exist). Each `R/NN_*.R` analysis script is paired with a verifier that
   checks its outputs.

## Environment

- **R version:** 4.6.1
- **Key packages:** `metafor` (meta-analytic models), `clubSandwich` (cluster-robust
  variance / RVE), `tidyverse` (data wrangling), `here` (project-relative paths),
  `readxl` / `readr` (data I/O).
- Exact versions are pinned in `renv.lock`.

## Decisions

All substantive modelling and coding decisions are logged in
[docs/DECISION_LOG.md](docs/DECISION_LOG.md).
