# Analysis Plan — CER → Cost of Debt (Paris moderator)

Meta-analysis of Corporate Environmental Responsibility (CER) on the Cost of Debt
(COD), with the Paris Agreement (2015) as a temporal moderator. Target journal:
*Business Strategy and the Environment*. This is a living stub — fill in as decisions
are made (and log them in [DECISION_LOG.md](DECISION_LOG.md)).

## Architecture
<How the pipeline is organised: data flow from raw `data/*.xlsx` → tidy effect-size
table in `data/processed/` → models → `output/` results → `manuscript/` write-ups.
Numbered `R/NN_*.R` scripts, each paired with an `NN_*_verify.R`. One driver per task
running all K specs into a long-format CSV with a `spec` column. Note the estimator
strategy (e.g. multilevel `metafor` + cluster-robust `clubSandwich` RVE).>

## Headline vs robustness
<Define THE headline specification — the single pre-registered model whose estimate is
the paper's main claim (estimator, effect-size metric, clustering, moderator coding).
Then enumerate the robustness specifications that surround it: alternative effect-size
measures, inclusion/exclusion rules, influence/leave-one-out, publication-bias
diagnostics, alternative Paris cut-points. State what would count as the result being
robust vs fragile.>

## Task sequence
<Ordered list of Claude-Code tasks, each = one `R/NN_*.R` + verifier, mirroring
`run_all.R`. For each: short goal, inputs, outputs. Roughly:>
1. `00_prepare_data` — raw `.xlsx` → tidy effect-size table.
2. `01_main_model` — headline RVE meta-analysis.
3. `02_paris_moderator` — Paris Agreement temporal moderation.
4. `03_robustness` — all robustness specs (long format, `spec` column).
5. `04_tables_figures` — manuscript tables and plots.
