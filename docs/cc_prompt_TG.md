# cc_prompt_TG.md -- CC contract for the TG canonical run [DEC-050]

## Task
Execute, in the repo root, in this order:
1. `Rscript R/11_robustness.R`
2. `Rscript R/11_verify_outputs.R`
Paste the FULL console output of both back to chat. Do not commit anything.

## Contract (unchanged house rules)
- CC is a pure executor. No design decisions, no parameter changes, no commits.
- **Fixzone** = the marked FIXZONE block in R/11_robustness.R plus pure syntax/API-accessor
  corrections anywhere (e.g. clubSandwich return-object accessors, jsonlite availability).
  Column rebinds happen ONLY inside FIXZONE. Everything else is frozen [DEC-050].
- M0 prints the dat_prep inventory and auto-continues on PASS. Designed stops:
  S-A (bind/columns), S-G1/S-G2/S-G3 (definition-count asserts 99 / 297 / adj-integer >= .99),
  S5 (unlisted model signature, P-T5-4), S-SCHEMA (36-col FIELDMAP), S-BUDGET (> 60 rows).
  On any stop: paste the message and STOP -- do not improvise definitions.
- "positive definite" errors route to not_estimable rows [DEC-049]; do not chase them.
- Expected footprint: <= 14 model fits, < 5 min, no parallelization, seed 20260710.
- Success criteria: "TG run complete" + "TG VERIFIER: 12/12 PASS".
