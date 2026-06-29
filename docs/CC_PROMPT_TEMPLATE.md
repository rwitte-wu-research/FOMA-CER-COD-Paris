# Claude-Code Task Template

Copy this file for each new analysis task, fill in the `<placeholders>`, and hand it
to Claude Code. Keep one task ≈ one `R/NN_*.R` script plus its paired verifier.

---

## TASK
<One-sentence statement of what this script must produce and why it matters for the
CER → Cost-of-Debt meta-analysis (e.g. "Estimate the headline RVE model and the Paris
moderator across K robustness specifications").>

## INPUTS
- **Data:** `<data/...xlsx or data/processed/....csv>`
- **Upstream outputs depended on:** `<output/... or data/processed/... from prior steps>`
- **Key columns / variables:** `<effect size, variance, study id, cluster id, moderators ...>`
- **Parameters / constants:** `<estimator, rho, alpha, small-sample correction ...>`

## LOGIC
- `<Step-by-step modelling logic.>`
- **Run all K specifications in ONE driver.** Do not write a script per spec. Loop /
  map over the spec grid inside a single driver and bind results into ONE long-format
  data frame with a `spec` column identifying each specification (plus any spec
  parameters as additional columns). Headline result = one labelled row among the K.

## OUTPUT
1. **Results CSV** → `<output/NN_<name>.csv>` in **long format**, one row per spec
   (`spec` column present), tidy and machine-readable.
2. **Write-up** → `<manuscript/NN_<name>.md>` with exactly these H2 headings:
   - `## Purpose` — what question this step answers.
   - `## Methods` — model, estimator, specs, decisions.
   - `## Results` — numbers with CIs; reference the long-format CSV / `spec` labels.
   - `## Verdict` — does the evidence support the hypothesis? how strong / robust?
   - `## Implications` — what it means for the paper's argument and next steps.
3. **Console summary** → end the script with a `cat()` summary report (headline
   estimate, CI, k studies/effects, and pass/fail of the key robustness checks) so a
   reader sees the bottom line without opening files.

## CODING STANDARDS
- 80-char header banner (`===` separators); section headers `# SECTION X — name`.
- tidyverse **native pipe `|>`** only; `here::here()` for ALL paths; no magic numbers
  (name constants at the top).
- Comments explain **WHY**, not WHAT.
- `source(here::here("setup.R"))` at the top; do not re-`library()` ad hoc.

## REPRODUCIBILITY
- Print an abbreviated `sessionInfo()` (R version + key package versions) and a
  run **timestamp** (`Sys.time()`) at the end of the script.
- Rely only on lockfile-pinned packages (`renv.lock`); add nothing outside renv.

## DO NOT
- **No git** — do not init/add/commit/push; the user commits manually.
- **Stay in `data/processed/` and `manuscript/`** for writes (plus declared
  `output/` results); do not write elsewhere.
- **No probe / scratch / `_probe_*.R` files** left behind — clean up temporaries.
- Do not run other pipeline steps or modify upstream scripts.
