# CC Prompt — TH canonical runs (Blocks E + H, null/Bayes battery)

**Repo:** `C:\R_Projects\FOMA-CER-COD-Paris` (branch `main`). **Authority:** DEC-045 (E/H execution pins; supersession register S1–S9), DEC-044 (language gate — all output framing-neutral), DEC-031f (convergence protocol), analysis_plan A.13. Scripts were author-reviewed before this run (GO given in chat, per run).

## Run structure (three runs, EACH gated by its own author GO in chat)

| Run | Scripts | Status |
|---|---|---|
| **TH-a** | `R/06_null_battery_a.R` + `R/06_verify_outputs.R` | **canonical NOW (this prompt)** |
| TH-b | `R/07_robma.R` + `R/07_verify_outputs.R` | activates only after the F66 lockfile closure + R↔JAGS handshake; separate GO |
| TH-c | `R/09_null_battery_c.R` + `R/09_verify_outputs.R` | **canonical (this prompt); overnight run; separate GO required** |

Do NOT run TH-b before its scripts exist in the repo AND an explicit author GO for that run has been given in chat.

## Task (TH-c canonical run — only after its own author GO; overnight, ~13–15 h)

```
Rscript R/09_null_battery_c.R
Rscript R/09_verify_outputs.R
```

**Success criterion:** the verifier prints `O1`–`O19` with **19/19 PASS** and exits 0, and `output/TH_c_results.csv` (1,347 rows) + `output/TH_c_run_meta.txt` + `output/TH_c_perms.rds` exist. Start in the evening; the permutation pass (500 × 23 ladder fits, W = 11 PSOCK workers) dominates the wall time. The fix zone and stop conditions below apply identically; additionally off-limits: the parallel setup (worker count, cluster type, export list) and the `Matrix`/`parallel` calls — any failure there is a stop, not a fix.

## Task (TH-a canonical run — exactly this, in order)

```
Rscript R/06_null_battery_a.R
Rscript R/06_verify_outputs.R
```

**Success criterion:** the verifier prints `O1`–`O17` with **17/17 PASS** and exits with status 0, and `output/TH_a_results.csv` (177 rows) + `output/TH_a_run_meta.txt` exist. Nothing else counts as success. Expected wall time ≈ 45–70 min (113 cumulative H7 refits dominate; sequential by design).

## Fix zone (the ONLY changes you may make autonomously)

1. **R syntax errors** (typos, unbalanced parentheses/braces, missing commas) — minimal edit, semantics untouched.
2. **Package-API mismatches** — accessor field names only (relevant here: `clubSandwich::coef_test` / `conf_int` / `linear_contrast` result fields, e.g. `df_Satt` vs `df`, `p_Satt` vs `p`). Fix the **accessor only**; never change model calls, pinned constants, formulas, bands, tolerances, or row structure.
3. **`renv::restore()`** if the library is out of sync with `renv.lock`.

Log every fix-zone edit (file, line, before → after, one-line reason).

## Stop conditions (severity classes S1–S5 per project convention)

Anything outside the fix zone is a **stop, not a fix**. That includes, without limitation: any `stopifnot`/assert failure (input contract, domain counts, tie/POST16 pins, `SCHEMA HARD STOP`, `ANCHOR HARD STOP` — the F65 gates against committed `output/T1_results.csv` / `output/T2_results.csv` at 1e-9 and the refit identities at 1e-6 —, row-budget mismatch, key duplication), any rma.mv non-convergence, any verifier FAIL, and any condition you did not expect. On a stop:

- **Halt immediately.** Do not retry with altered settings, do not "work around", do not touch pins.
- Report the **complete verbatim message** plus surrounding console context to the chat.
- Do not classify definitively — tentative severity is fine; S1–S5 semantics are governed by the project convention.

## Hard prohibitions

- **No commits, no staging** (`git add`/`commit`/`push` off-limits; the commit ritual runs in chat).
- **No result framing or interpretation.** Do not characterize estimates as supporting/undermining anything; do not compare against SESOI; do not use verdict or evidence-of-absence language (the DEC-044 gate resolves post-run in chat). The mechanical TOST pass flags in `value` are computed by the script; do not restate them in prose beyond verbatim quotation inside the required report.
- No edits to `docs/`, `data/`, `renv.lock`, or any pinned constant.
- No re-runs after a successful canonical run.

## Report (end of session, exactly three parts)

1. **Transcript:** full console output of both Rscript calls (verbatim).
2. **Fix log:** every fix-zone edit as specified above ("none" if none).
3. **One closing line:** `TH-a canonical run: <PASS 17/17 | STOPPED at <point>> — outputs written: <yes/no>`.
