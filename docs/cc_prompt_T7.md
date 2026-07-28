# CC contract — T7 / Block C canonical run (R/10 pair) [DEC-043 · DEC-048]

## 0 Role

You are the EXECUTOR ONLY. You run the commands below exactly as written, report milestones, and stop on the conditions in §4. You do not interpret results, do not frame findings, do not edit any file outside the fix zone, and you NEVER commit, stage, stash, or push. All result framing happens outside this contract [DEC-047 language regime].

## 1 Preconditions (verify, paste, then proceed)

Run and paste the output of each; ALL must hold, else STOP (§4):

1. `git log -1 --oneline` — HEAD message contains `[DEC-048]`.
2. `git status` — working tree clean (no modified tracked files; no `~$` Excel lock files under `docs/`).
3. `dir output\dat_prep.rds output\T1_results.csv` — both present.
4. `Rscript -e "cat(R.version.string)"` — R 4.6.1.

No `renv::install`/`renv::snapshot` in this contract (T7 adds no packages). `renv::restore()` is permitted only if R/10 aborts with a missing-package error, and must be reported.

## 2 Canonical run

```
powershell -Command "New-Item -ItemType Directory -Force $env:USERPROFILE\FOMA_logs | Out-Null; Rscript R/10_moderators.R 2>&1 | Tee-Object -FilePath $env:USERPROFILE\FOMA_logs\T7_console_20260728.log"
```

Sanctioned deviations (pre-approved; nothing else): the persistent console tee OUTSIDE the repo shown above · a passive read-only log watcher in a second terminal (`powershell Get-Content -Wait` on the tee file) · milestone reports per §3. Single run, foreground, no parallel jobs.

## 3 Milestones (report each as one short message; do not pause unless STOP fires)

- **M0** — pre-flight complete: paste the `[GATES]` block (md5 gate, 7 design gates, regulation3 gate 14/6/11, F65 A5 identity, design-df echo table). All must read PASS.
- **M1** — Kostprobe: paste the `[COSTPROBE]` line (t of the first M_A fit + printed projection `~22 × t`). Continue immediately.
- **M2** — after the eight panels: paste the `[PANELS DONE]` line (row counter).
- **M3** — after C9 (V1 + V2): paste the `[C9 DONE]` line (convergence certificates summary).
- **M4** — script end: paste the final `[WRITE]` block (files written + row count 200) and the exit code.
- **M5** — verifier: run `Rscript R/10_verify_outputs.R`, paste the numbered PASS/FAIL table tail and the exit code. Exit 0 = run accepted.

## 4 STOP protocol

Formal STOP (report the full console tail, touch nothing, await instructions) on ANY of: precondition failure (§1) · any `[GATES]` FAIL · an `[S5]` stop line (unlisted non-convergence condition) · verifier exit ≠ 0 · any error outside the fix zone.

**Fix zone (the ONLY permitted repairs, each reported with a before/after line):** syntax errors introduced by transport · package-API accessor mismatches (column/field names of `coef_test` / `Wald_test` / `linear_contrast` results — accessor-only, no logic changes) · `renv::restore()` per §1. Everything else — including anything touching model calls, domains, gates, the FROZEN ZONE block, row budget, or output paths — is out of zone: STOP.

## 5 Expected outputs (on success)

`output/T7_results.csv` (exactly 200 rows + header) · `output/T7_background_C0.csv` · `output/T7_run_meta.txt` · `output/T7_sessionInfo.txt` · verifier exit 0. The canonical bytes are those on this machine; nothing is regenerated elsewhere.
