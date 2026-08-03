# CC prompt — M2 figure package (R/14)

Role: pure executor. Run the steps below in order. Do not modify any file, do
not fix any error, do not commit. On any failure: stop and paste the complete
console output (including the failing assert message) back to the author.

## Precondition — R environment

The runner must have the project R available (`Rscript` on PATH; renv
activates via the repo `.Rprofile`). A sandbox shell without R (e.g. a
folder-mount VM) cannot execute this package: STOP at Step 1 and hand the
two `Rscript` commands to the author to run on the Windows host.

## Step 0 — Evidence (read-only; shell-agnostic)

```
git status --short
git ls-files data/CER-COD_data_v12.xlsx
```

Expected: the second command prints exactly `data/CER-COD_data_v12.xlsx`
(literal path check — no substring filters). Empty output = the source
contract is void: STOP and report. `git status` output is evidence for the
author, not a stop condition by itself.

## Step 1 — Figures

```
Rscript R/14_figures.R
```

The script sources `R/00_prep.R` (canonical estimation-set construction), so
the console first shows the prep's own `ok(...)` assert lines and it may
refresh the gitignored `data/processed/` mirrors — both expected, not stop
conditions. Expected final line: `14_figures.R: all three figure pairs
written to output/figures/.` Any `Error:`/`stopifnot` failure -> STOP, paste
output.

## Step 2 — Verifier (mandatory, immediately after)

```
Rscript R/14_verify_outputs.R
```

Expected: five `PASS` lines (V1-V5) and the closing banner
`================ R/14 VERIFIER: ALL PASS ================`.
Any `fail`/`Error` -> STOP, paste output. Do not re-run with modifications.

## Step 3 — Deliverables back to the author (no commit)

1. Full console output of Steps 0-2 (verbatim).
2. The three PNGs: `output/figures/D1_funnel_contour.png`,
   `output/figures/TH_a_H7_cumulative.png`,
   `output/figures/TH_a_H8_rolling.png`.
3. `output/fig_run_meta.txt`.

The commit happens later inside the M2 package (author ritual); the new files
remain uncommitted in the working tree until then.
