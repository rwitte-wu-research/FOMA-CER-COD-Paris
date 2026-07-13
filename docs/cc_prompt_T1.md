# Claude Code prompt — T1 canonical run (Block A), FOMA CER–COD

You are executing the **canonical T1 run** of this project. Working directory = repo root (contains `renv.lock`, `R/`, `output/`, `DECISION_LOG.md`). The scripts `R/01_core.R` and `R/01_verify_outputs.R` are already in place and Gate-2-approved. Your job: **run, minimally fix (fix zone only), verify, report.** You do not interpret results.

## Task sequence
1. `Rscript -e "renv::status()"` — report drift. Do **not** `renv::restore()` unless a package fails to load in step 3/4; if it does, `renv::restore()` once, then retry.
2. If `output/dat_prep.rds` is missing: run `Rscript R/00_prep.R`, then `Rscript R/00_verify_prep.R`. The prep verifier must exit 0 with 28/28 PASS; otherwise STOP (condition S1). If the file exists, do not touch prep.
3. `Rscript R/01_core.R`
4. `Rscript R/01_verify_outputs.R` — success criterion: **exit code 0, 21/21 PASS**.
5. Write the report (format below). Then stop.

## Fix zone (the ONLY changes you may make)
- Syntax errors and package-API **signature** mismatches in `R/01_core.R` / `R/01_verify_outputs.R`. Anticipated examples: `clubSandwich::coef_test` df column naming (`df` vs `df_Satt`), `conf_int` column names, `aggregate.escalc` argument names, a ggplot2 deprecation shim, `here` namespace loading.
- Every fix: the smallest possible behavior-preserving edit; document each changed line in the report (file / before / after / reason).

## Frozen zone (NEVER change)
- All statistical logic: model formulas, `random = ~ 1 | cluster/study/esid`, V imputation on **cluster_id** (F56), rho values {0.6, 0.4, 0.8}, estimator definitions (one-per-cluster + KnHa; UWLS+3 per Stanley et al. 2024; HS; WAAP threshold |UWLS+3|/2.8), the PI formula (all three variance components; F55), the bp-translation formula.
- All constants: `K_ES = 2713`, `K_STUDY = 115`, `K_CLUSTER = 114`, `K_STUDY_POST = 31`, `K_PERIOD_NA = 8` (period NAs in `pp_mid_lag0` are a design fact per DEC-042b, not an error), `SEED = 20260710`, `SD_COD_BP_GRID = {100, 150, 200}` (PENDING DEC-012a — placeholders are intentional), `SMALL_BENCH_R = 0.07`.
- CSV schema (35 columns), spec labels, the 15-row expected-spec inventory, figure filenames/dimensions.
- Verifier check logic: check numbering, tolerances, expected values, flag strings (`"PENDING DEC-012a"`, `"reduces to UWLS"`). API-signature fixes are permitted in the verifier under the same fix-zone rule; nothing else.
- dat_prep handling: the schema is **binding** (author ruling 2026-07-12; R/00_prep.R list contract `pr$dat` / `pr$n` / `pr$seed`). A schema mismatch is a STOP condition, not a patch target.

## STOP conditions (halt, report, fix nothing)
- **S1** `output/dat_prep.rds` missing and prep cannot be regenerated with its verifier at 28/28 PASS.
- **S2** Contract violation: `pr$n != 2713`, `pr$seed != 20260710`, missing required columns, or any estimation-set assert failure (2713 / 115 / 114).
- **S3** Any verifier FAIL whose cause is not a pure syntax/API-signature issue in the two scripts.
- **S4** Any fix that would require touching the frozen zone.
- **S5** renv/package conflicts not resolved by a single `renv::restore()`.

## Prohibitions
- No `git commit`, no `git push`, no branch operations, no file deletions.
- No edits to `DECISION_LOG.md`, `analysis_plan.md`, anything under `data/`, or `R/00_*`.
- No interpretation, framing, or evaluation of the estimates — transport numbers only.

## Report format (verbatim sections, in this order)
1. **Commands run** — in order, with exit codes.
2. **Edits** — file / line / before / after / reason; write "none" if none.
3. **Verifier log** — full stdout of `R/01_verify_outputs.R`.
4. **Outputs** — directory listing of `output/` and `output/figures/` with file sizes; the first 10 lines of `output/T1_results.csv`.
5. **Session notes** — runtime, warnings, renv status.
