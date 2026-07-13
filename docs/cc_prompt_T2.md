# Claude Code prompt — T2 build + canonical run (Block B coding layer), FOMA CER–COD

You are executing **T2** in the standard loop (Setup §2/§3): you **write** `R/02_paris.R` and its paired verifier `R/02_verify_outputs.R` strictly from the frozen spec, then **run** both, then **report**. Working directory = repo root. You do not interpret results.

## Task sequence
1. Read `docs/T2_spec.md` in full. It is the complete, frozen specification — models, spec labels, row inventory (96), constants, verifier checks O1–O17, semantics pins P1–P5. Treat every element as binding.
2. `Rscript -e "renv::status()"` — report drift; `renv::restore()` only on load failure, once.
3. If `output/dat_prep.rds` is missing: `Rscript R/00_prep.R` then `Rscript R/00_verify_prep.R` (must exit 0, 28/28 PASS; otherwise STOP S1). If present, do not touch prep.
4. Write `R/02_paris.R` implementing spec §§1–4 (header: decision basis + spec pointer; frozen constants block; input contract with fail-fast asserts; NO result-dependent branching).
5. Write `R/02_verify_outputs.R` implementing spec §5 — oracle-independent (do NOT source 02_paris; duplicate constants deliberately; recompute O12/O14 identities from dat_prep).
6. `Rscript R/02_paris.R`, then `Rscript R/02_verify_outputs.R` — success: exit 0, **17/17 PASS**.
7. Report (format below). Then stop.

## What you may do
- You own the implementation: fix your own bugs freely and iterate until the verifier passes — but every iteration must implement the SPEC, never adapt it.
- The single permitted data-driven adaptation: the `pp_window_class` level-string mapping (spec P5) — resolve from the data / `output/design_quantities_v12.csv`, document the mapping in `output/T2_run_meta.txt`.

## Frozen (NEVER change; deviations = STOP S4)
- Model machinery (3LMA-RVE, V on cluster_id with rho = 0.6, CR2/Satterthwaite on cluster_id, REML), the three-row term pattern (cell_pre / cell_post / diff; diff z-scale only), the in-script recut rule `share_201x >= 0.5` ties→Post.
- Spec labels, the 96-row inventory, the 36-column schema (T1 schema + `term` after `subset`), ms_input assignments.
- Constants: `K_ES = 2713`, `K_STUDY = 115`, `K_CLUSTER = 114`, `K_PERIOD_NA = 8` (per coding column — design fact per DEC-042b, not an error), `K_STUDY_POST = 31`, `RHO = 0.6`, `SEED = 20260710`.
- Verifier check targets, tolerances, and the two-tier df floor (O15).
- No figures. No prediction intervals. No edits to `DECISION_LOG.md`, `analysis_plan.md`, `data/`, `R/00_*`, `R/01_*`.

## STOP conditions
S1 prep unavailable/unverifiable · S2 input-contract violation (pr$n, pr$seed, columns, 8-NA-per-coding, 2713/115/114) · S3 verifier FAIL not caused by your own implementation bug · S4 anything requiring a spec deviation · S5 renv conflicts beyond one restore.

## Prohibitions
No git operations. No file deletions outside your own scratch. No interpretation of estimates — transport only.

## Report format
1. **Commands run** (order + exit codes)
2. **Spec-conformance notes** — the P5 mapping you resolved; confirmation that P1–P4 asserts passed; any ambiguity you hit (there should be none — if there is, that is STOP S4, report it)
3. **Verifier log** (full stdout)
4. **Outputs** — listing of `output/` with sizes; first 12 lines of `output/T2_results.csv`
5. **Session notes** (runtime, warnings, renv)
