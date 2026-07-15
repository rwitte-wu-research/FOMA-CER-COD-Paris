# Claude Code execution prompt — T8: Paris identification battery (Block B: B2/B4/B5/B8)

**Repo:** `C:\R_Projects\FOMA-CER-COD-Paris` (branch `main`).
**Precondition:** the T8 Gate-2 commit is present (R/08_identification.R v4, R/08_verify_outputs.R v4, this prompt). `output/dat_prep.rds` exists (canonical prep, pr$n = 2713, pr$seed = 20260710).
**Authority:** DEC-024/024a · DEC-031 family (031c/031d) · DEC-042a/b · analysis_plan Addendum A (incl. A.9/A.10). Gate 2 (pre-execution diff review) is closed with the author GO of 2026-07-15.

## Task (canonical run — exactly this, in this order)

```
Rscript R/08_identification.R
Rscript R/08_verify_outputs.R
```

**Success criterion:** run 1 passes all input-contract asserts and writes `output/T8_results.csv` (83 rows × 36 columns), `output/T8_run_meta.txt`, `output/T8_sessionInfo.txt`; run 2 prints **27/27 PASS** and exits **0**.

## Frozen zone — do not modify under any circumstances

- All constants and pins: `RHO`, `KNOT`, `PLACEBO_YEARS`, `PRED_SHARES`, `CONTRAST_MAIN`, `SESOI_*`, `OSTER_*`, `B5_COVARS` / `B5_REFS` / `B5_LEVELS`, domain counts (`N_SET*`, `N_SUB*`, `K_PERIOD_NA_*`, `POST16`, `SHARE_DISTINCT`), `SEED`, the derived `N_ROWS_EXPECTED` (69 + 2·Σ(B5_LEVELS − 1) = 83), the 36-column `SCHEMA`.
- All model formulas, the row plan, the share_Y recode and its identity gates [DEC-024a], the F60 placebo-cell pins, the T2/B1 full-precision anchors, all note strings / labels / `ms_input` flags.
- The verifier's checks O1–O27, tolerances, and pinned tables.

A change needed in any of the above = **stop S4** (see below). The verifier is the oracle; the scripts are never adjusted to make a check pass.

## Fix zone — the only permitted changes

1. R **syntax** errors (typos, missing commas/brackets).
2. **Package-API** signature or column-name variants (e.g., clubSandwich `coef_test` / `conf_int` / `linear_contrast` column names across versions).
3. **Library loading / environment restoration:** `renv::restore()` from the committed lockfile is allowed; package upgrades beyond the lockfile are not.

Every fix: minimal diff, documented in the final report as (file · line · before → after · reason). Nothing else is touched — not constants, not formulas, not notes, not the verifier.

## Stop conditions — halt immediately, output the full console log + a one-paragraph diagnosis, change nothing further

- **S1 — input contract:** `dat_prep.rds` missing, or pr$n ≠ 2713, pr$seed ≠ 20260710, or required columns absent.
- **S2 — frozen-logic assert fires:** domain counts, identity gates (share_2016 / mid-rule), level pins, `N_ROWS`, key duplicates.
- **S3 — verifier FAIL:** any O-check fails (nonzero exit).
- **S4 — a needed fix lies outside the fix zone.**
- **S5 — anything unexpected:** non-convergence, NA/NaN estimates, a package unavailable after restore, ambiguous state.

## Prohibitions

- No `git commit`, `git push`, or staging.
- No file renames, moves, or deletions; no edits outside the fix zone.
- **No interpretation, framing, or evaluation of any estimate.** Report structural facts only: rows written, checks passed, fixes applied. Verdict language is produced downstream by the author-facing session.

## Report format

1. Full console transcript of both `Rscript` runs.
2. Fix log (file · line · before → after · reason) or the line `no fixes required`.
3. Exactly one closing line: `27/27 PASS, exit 0` **or** `STOP <S1–S5>: <one-line reason>`.
