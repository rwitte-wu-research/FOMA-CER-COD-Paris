# CC Prompt — T5 canonical run (Block D bias battery)

**Repo:** `C:\R_Projects\FOMA-CER-COD-Paris` (branch `main`). **Authority:** DEC-031g (T5 execution pins), DEC-031f (convergence protocol), analysis_plan §8 + A.11/A.12. Scripts were author-reviewed before this run (GO given in chat).

## Task (canonical run — exactly this, in order)

```
Rscript R/05_bias.R
Rscript R/05_verify_outputs.R
```

**Success criterion:** the verifier prints `O1`–`O27` with **27/27 PASS** and exits with status 0, and `output/T5_results.csv` + `output/T5_run_meta.txt` exist. Nothing else counts as success.

## Fix zone (the ONLY changes you may make autonomously)

1. **R syntax errors** (typos, unbalanced parentheses/braces, missing commas) — minimal edit, semantics untouched.
2. **Package-API mismatches** — the scripts raise labelled stops (`PACKAGE-API MISMATCH (fix zone: Paket-API)`) when an accessor field name does not match the installed package version (relevant: `metafor::selmodel` and `puniform::puni_star` object fields). Fix the **accessor only**; never change model calls, pinned constants, formulas, steps, sides/alternatives, tolerances, or row structure.
3. **`renv::restore()`** if the library is out of sync with `renv.lock` (puniform 0.2.8 must be present per F64/DEC-031g).

Log every fix-zone edit (file, line, before → after, one-line reason).

## Stop conditions (severity classes S1–S5 per project convention)

Anything outside the fix zone is a **stop, not a fix**. That includes, without limitation: any `stopifnot`/assert failure (input contract, md5, domain counts, q_status pins, level-order guards, row budget, key duplication), any `DEC-031f R5/R6 STOP`, any `S5 HARD STOP [P-T5-4]`, any verifier FAIL, and any condition you did not expect. On a stop:

- **Halt immediately.** Do not retry with altered settings, do not "work around", do not touch pins.
- Report the **complete verbatim message** plus the surrounding console context to the chat.
- Do not classify definitively — tentative severity is fine; the S1–S5 semantics are governed by the project convention, not redefined here.

## Hard prohibitions

- **No commits, no staging** (`git add`/`commit`/`push` are off-limits; the commit ritual runs in chat).
- **No result framing or interpretation.** Do not characterize estimates as supporting/undermining anything; do not compare against SESOI; do not use verdict language. Numbers may only be quoted verbatim inside the required report.
- No edits to `docs/`, `data/`, `renv.lock`, or any pinned constant.
- No re-runs after a successful canonical run.

## Report (end of session, exactly three parts)

1. **Transcript:** full console output of both Rscript calls (verbatim).
2. **Fix log:** every fix-zone edit as specified above ("none" if none).
3. **One closing line:** `T5 canonical run: <PASS 27/27 | STOPPED at <point>> — outputs written: <yes/no>`.
