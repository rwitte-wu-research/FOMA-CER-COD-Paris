# cc_prompt_TF.md -- CC contract for the TF canonical run [DEC-051 / route per DEC-051a]

## Task
Execute, in the repo root, in this order:
1. `Rscript R/12_outliers.R`
2. `Rscript R/12_verify_outputs.R`
Paste the FULL console output of both back to chat. Do not commit anything.

## Contract (unchanged house rules)
- CC is a pure executor. No design decisions, no parameter changes, no commits.
- **Fixzone** = the marked FIXZONE block in R/12_outliers.R (incl. RS_NCPUS) plus pure
  syntax/API-accessor corrections anywhere (e.g. metafor rstudent/hatvalues return-object
  accessors, clubSandwich accessors, jsonlite availability, PSOCK/snow cluster setup).
  Column rebinds happen ONLY inside FIXZONE. Everything else is frozen [DEC-051/DEC-051a].
- Milestones auto-continue on PASS; report each milestone line to chat as it appears:
  M0 (bind/inventory + Gate A + smoke incl. rstudent serial/parallel identity probe) ->
  **"F1 rstudent pass started/done" lines (parallel snow; report both immediately)** ->
  identification print (rstudent/MAD flag counts) -> **M1 (first LOO fit timed + x114
  projection -- report immediately)** -> M2 (LOO complete + ne count) -> M3 (variant refits)
  -> M4 (influence) -> M5 (outputs written).
- Designed stops: S-A (bind/columns/md5), S5 (unlisted model signature, P-T5-4),
  S-SCHEMA (36-col FIELDMAP / row-count contracts), S-BUDGET (> 130 model fits or > 40 result
  rows), S-F1 (rstudent/MAD/hatvalues API toy-probe, parallel/serial identity, or accessor
  mismatch), S-F4 (not_estimable LOO fits > 5). On any stop: paste the message and STOP --
  no outputs are written on a stop; do not improvise definitions or fixes outside the fixzone.
- "positive definite" errors route to not_estimable rows [DEC-049]; do not chase them.
- Expected footprint: <= 130 model fits (planned 121 incl. Gate A + smoke; rstudent
  FE-deletions do not count), seed 20260710. On this machine (known ~2.5-3x per-fit factor;
  serial rstudent pass empirically > 8 h on 2026-07-30): rstudent pass parallel snow with
  RS_NCPUS workers ~1-2.5 h, LOO (PSOCK W = 8) ~15-25 min, remainder ~15 min; total ~2-3.5 h.
  The "F1 rstudent pass done" line and the M1 projection line are authoritative.
- Sanctioned deviations (bootstrap): persistent console tee OUTSIDE the repo; read-only log
  watcher; milestone reports.
- Success criteria: "TF run complete" + "TF VERIFIER: 12/12 PASS".
