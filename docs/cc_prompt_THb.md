# CC execution contract — canonical TH-b run (R/07, RoBMA battery)

FOMA CER–COD–Paris · authority: DEC-045 (TH-b spec) · DEC-046 (version +
scale-path pins, t_RoBMA) · B-Q1 (foundational pair, pre-execution diff
review completed before this run) · P-T5-4 analog (STOP semantics).

## Mission

Execute the committed canonical TH-b scripts exactly once, in order, and
return the full evidence. You are the EXECUTOR only: do not write, patch,
or re-run R code; the fix zone for any failure lives in the project chat.

## Preconditions (verify, then proceed; on any failure: STOP + report)

1. Working directory = repo root `C:\R_Projects\FOMA-CER-COD-Paris`.
2. `git log -1 --oneline` shows the Block-1 commit (message contains
   `DEC-046`); `git status --porcelain` is clean (no modified tracked
   files, no untracked files under `R/` or `docs/`).
3. `R/07_robma.R` and `R/07_verify_outputs.R` are tracked at HEAD
   (`git ls-files R/07_robma.R R/07_verify_outputs.R` lists both).
4. No R/RStudio process is attached to the project library.
5. Rscript 4.6.1 at
   `C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe` (full path; not
   necessarily on PATH).

## Execution

Step 1 — canonical run (long):

    "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" R\07_robma.R

- No `--vanilla` (renv activation required), no timeout, no kill/poll.
- Projected duration ≈ 5–7 h (T = 3·t + 3·κ·t, t = 1,764.8 s, κ = 2.5;
  autofit variance makes this a point projection [DEC-046]) — the run
  passed its binding GO check before launch. Long silences during MCMC
  sampling are NORMAL; do not intervene.
- Sanctioned deviation (established practice [DEC-046]): tee the full
  console (stdout+stderr) to `C:\Users\witte\thb_console.log` so the
  unabridged log survives.
- The script prints an `R7-PRE` smoke-test verdict within the first
  minutes, then one progress line per canonical fit (6 fits).

Step 2 — paired verifier (runs only if Step 1 exited 0):

    "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" R\07_verify_outputs.R

- Exit 0 is REQUIRED for acceptance; the verifier prints numbered
  O0–O14 PASS/FAIL lines.

## STOP protocol (binding)

Halt immediately — complete the current step's output capture, write
nothing further, change nothing — when any of the following appears:

- `VERSION-PIN ANOMALY` (installed stack deviates from DEC-046 pins)
- `INPUT CONTRACT HARD STOP` / `SCHEMA HARD STOP` (dat_prep contract)
- `PACKAGE-API MISMATCH (fix zone: Paket-API)` incl. an `R7-PRE`
  smoke-test failure (accessor repair is chat-side only)
- `S5 HARD STOP` (unlisted condition; the listed non-convergence
  signatures do NOT stop the run — they surface as not_estimable rows)
- `ROW BUDGET MISMATCH`, or any verifier FAIL / non-zero exit.

On STOP: no fixes, no partial re-runs, no output deletion. Return the
full console log(s) and the exact failing lines.

## Permissions

- WRITE: only `output/TH_b_results.csv` and `output/TH_b_run_meta.txt`
  (created by the script) plus the sanctioned console tee outside the
  repo. Nothing else.
- FORBIDDEN: package installs, `renv::*` calls, edits to any tracked
  file, git writes of any kind (git is read-only for status/log checks).

## Return (single report)

1. Full console log of Step 1 (unabridged; the tee file is the backstop).
2. Full console log of Step 2 (all O-check lines + verdict).
3. `git status --porcelain` — expected EXACTLY:

       ?? output/TH_b_results.csv
       ?? output/TH_b_run_meta.txt

   Anything else (modified tracked files, additional untracked files) is
   an anomaly: report it, stage nothing, commit nothing.
4. The `TFIT|...` lines (per-fit timings) verbatim, for the projection
   vs. actual comparison in the chat.
