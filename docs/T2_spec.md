# T2 spec — Block B coding layer (B1, B3, B6, B7): Paris headline binary, coding sensitivities, post-cell LOSO, disclosures

Status: FROZEN handoff spec (standard loop per Setup §2/§3: CC writes `R/02_paris.R` + `R/02_verify_outputs.R` from this spec, runs both, reports). T8 (B2/B4/B5/B8 — dose, trend-vs-break, composition, bounding) is a SEPARATE Gate-2 script and NOT part of T2.

Decision basis: [DEC-024] headline cut + ties→Post · [DEC-031 Annex B] · [DEC-031a.5 upgrades fired; .6 inference conventions; .7 no T2 figures; .9 pp_share_lag0 = continuous dose ≡ share_2016] · [DEC-042a] estimation set · [DEC-042b] period-NA rule · [F55–F57 conventions carry over] · [plan §6 + Addendum A.3] · design facts: df(pp_mid) = 31.9 (transfer rule NOT triggered → binary carries full inference), clean-window df = 12.3 ≥ 5 (upgrade fired → full inference), post cell = 31 studies.

## 1. Input contract (binding — schema mismatches are STOP conditions, not patch targets)

`pr <- readRDS(here::here("output","dat_prep.rds"))`; list contract `pr$dat` / `pr$n == 2713` / `pr$seed == 20260710`. Columns used (all confirmed present 2026-07-13):
`zi, vi, cluster_id, study, esid, n_eff, pp_mid_lag0, pp_median_lag0, pp_end_lag0, pp_end_lag1, pp_end_lag2, pp_end_lag3, share_2016, share_2017, share_2018, share_2019, pp_share_lag0, pp_window_class`.

Asserted constants: `K_ES = 2713L; K_STUDY = 115L; K_CLUSTER = 114L; K_PERIOD_NA = 8L; K_PERIOD_NA_STUDY = 2L; K_STUDY_POST = 31L; RHO = 0.6; SEED = 20260710` (deterministic run; seed set defensively).

**DEC-042b generalization (assert, per coding column actually used):** every window-derived coding (`pp_mid_lag0, pp_median_lag0, pp_end_lag0..3, share_2016..2019, pp_window_class`) has EXACTLY 8 NA rows over EXACTLY the same 2 studies. Estimation domain for every coding-based analysis = complete cases on that coding (k = 2,705); the full set (2,713) is never re-filtered otherwise.

**Semantics pins:**
- P1: `pp_share_lag0` is CONTINUOUS and identical to `share_2016` [DEC-031a.9; Addendum A.3] — verifier asserts `identical()` (tol 1e-12) and > 2 distinct values.
- P2: Coding-lag recuts for B3 are computed IN-SCRIPT as `share_201x >= 0.5` (ties→Post, the DEC-024 rule); the prep columns `pp_share_lag1..3` are NOT used as regressors — their semantics are reported as an INFO line in run_meta only.
- P3: Canonical identity: `(share_2016 >= 0.5)` (ties→Post) must reproduce `pp_mid_lag0` exactly on the 2,705 defined rows (verifier assert).
- P4: `pp_median_lag0` = tie-break variant (ties→Pre) [plan §6]; disagreement with `pp_mid_lag0` occurs only on exact-0.5 rows (verifier: all disagreements have share_2016 == 0.5; count reported, cross-checked against design_quantities_v12.csv if a matching key exists, else INFO).
- P5: `clean_window` cells = `pp_window_class` levels identifying pure-pre and pure-post windows. Exact level STRINGS are the only permitted in-run adaptation (string-literal fix zone); resolve from the data/`output/design_quantities_v12.csv` and report the mapping in run_meta.

## 2. Model machinery (identical to T1; frozen)

Fisher-z scale throughout; `V = clubSandwich::impute_covariance_matrix(vi, cluster = cluster_id, r = 0.6)` [F56]; `metafor::rma.mv(zi, V, mods = ~ <coding>, random = ~1|cluster_id/study/esid, sparse = TRUE, method = "REML")`; CR2 + Satterthwaite clustered on `cluster_id` (`coef_test` / `conf_int` / `linear_contrast` as needed). NO prediction intervals in T2 (A3 owns them). NO pairwise spec-vs-headline tests [DEC-031a.6]; each coding model carries its OWN formal between-group inference (the moderator coefficient).

Per coding model, emit three rows (`term` column): `cell_pre` (mean at coding = 0), `cell_post` (mean at coding = 1), `diff` (post − pre coefficient with CR2 t/df/p). Implementation: single fit `~ 0 + factor(coding)` for cell means + CR2 linear contrast for the difference (or the equivalent `~ coding` parameterization — estimates must satisfy the O-identity `cell_post − cell_pre == diff` to 1e-10). Cell rows carry both scales (est_r = tanh(est_z)); **diff rows are z-scale only** (est_r = NA; note: "difference of Fisher-z means; no tanh transform of differences").

## 3. Analyses, spec labels, and row inventory (93 rows total)

| Battery | spec | Coding / domain | Rows | Notes |
|---|---|---|---|---|
| B1 | `paris_mid` | `pp_mid_lag0`; k = 2,705 | 3 | headline moderation; full inference (df 31.9 design); ms_input = TRUE on all 3 |
| B3 | `tie_break_median` | `pp_median_lag0` (ties→Pre) | 3 | sensitivity, ONE variant [plan §6] |
| B3 | `end_any_exposure` | `pp_end_lag0` | 3 | upper-recall bound |
| B3 | `share_recut_2017` / `_2018` / `_2019` | in-script `share_201x >= 0.5` (P2) | 3×3 | main-text coding sensitivity; collapse = finding |
| B3 | `end_lag1` / `end_lag2` / `end_lag3` | `pp_end_lag1..3` | 3×3 | appendix (note flag "appendix") |
| B3 | `clean_window` | subset `pp_window_class ∈ {clean pre, clean post}`; binary clean-post | 3 | FULL inference [DEC-031a.5 fired, df 12.3]; k = clean-cell total (report; assert df ≥ 5) |
| B6 | `loso_post` | drop each of the 31 post-cell studies (whole study) and refit `paris_mid` | 31 | one row per dropped study (`subset` = study key; `term` = diff); ms_input = FALSE |
| B6 | `loso_post_summary` | — | 1 | `term` = range; `value` = max−min of the 31 diffs; note names min/max/full-sample diff |
| B6 | `post_dominance` | post cell (pp_mid_lag0 == 1) | 31 | one row per post study: `value` = normalized weight share with w = 1/(vi + Σσ̂²_B1) within the post cell (documented marginal approximation — RVE weights are matrix-valued); `k_es` = the study's post-cell ES count; note carries the ES-count share. Memo check: Panjwani expected ≈ 23.9% ES share, top-3 ≈ 44% |
| B7 | `disclosure_attenuation_end` | pp_end_lag0 == 1 rows | 1 | `value` = share of end-coded "post" ES with share_2016 < 0.5 (majority-pre contamination, recomputed on v12); note adds the study-level count |
| B7 | `disclosure_knife_edge` | full defined set | 1 | `value` = ES share with share_2016 ∈ [0.45, 0.55]; note adds study count |
| B7 | `disclosure_panel_drift` | full defined set | 1 | `value` = mean(share_2016) at ES level − mean of study-level means (post years contribute more observations than their calendar share); note carries both components |

ms_input = TRUE: `paris_mid` (3 rows), `clean_window` (3), `loso_post_summary`, all three `disclosure_*` rows. Everything else FALSE. All coding variants register in the catalogue-G long table later — keep spec labels exactly as above.

## 4. Output contract

- `output/T2_results.csv` — long format, **T1 schema + `term` column inserted after `subset`** (36 columns; all other names/order identical to T1). PI columns stay in the schema and remain NA (schema stability across runs).
- `output/T2_run_meta.txt` — dat_prep md5, pr$n/pr$seed echo, per-coding NA counts, clean-window level mapping (P5), pp_share_lag1..3 semantics INFO (P2), sessionInfo.
- **No figures** [DEC-031a.7: T2 owes none; the time figure is N10/Block H].
- `manuscript/T2.md` and the T2 results workbook are post-run chat deliverables (not the script's).

## 5. Verifier `R/02_verify_outputs.R` (oracle-independent; numbered checks, exit 1 on FAIL)

O1 files exist (CSV, run_meta) and NO T2 figure files were created · O2 schema exact (36 names + order) · O3 inventory exact: 93 (spec, subset, term) rows, no duplicates · O4 domain identities: every coding-based spec has k_es = 2,705 except `clean_window` (k = clean total; df ≥ 5) and LOSO rows (k_es = 2,713 − dropped study's ES count − 8-NA overlap handled by recomputation) · O5 `paris_mid` cell_post: k_study = 31 [design] and cell_pre + cell_post k_es = 2,705 · O6 P1 identity (pp_share_lag0 ≡ share_2016, continuous) · O7 P3 identity (recut_2016 ≡ pp_mid_lag0 on defined rows) · O8 P4 tie-break: disagreements only at share_2016 == 0.5; count reported · O9 diff identity per coding model: cell_post − cell_pre == diff (1e-10) · O10 est strictly inside CI (both scales where present); tanh identity on cell rows; diff rows have est_r = NA by convention · O11 per-coding NA count == 8 / 2 studies [DEC-042b generalized] · O12 LOSO: 31 rows; per row k_study == 114; recompute each dropped-study ES count from dat_prep and match k_es · O13 dominance: 31 rows; weight shares sum to 1 (1e-8); note contains ES-count share; flag row with max share in detail output · O14 disclosures: recompute all three values independently from dat_prep (1e-10) · O15 df floors two-tier [F57 logic]: hard df ≥ 4 on `paris_mid` and `clean_window` diff rows; all other coding-variant diffs: df finite > 1 (values echoed in the check detail) · O16 run_meta contents (md5, contract echo, P5 mapping, P2 INFO, sessionInfo, package stamp) · O17 no NA in est_z/se_z/CI on any `diff` row; no NA in est_r on cell rows.

## 6. STOP conditions (halt, report, fix nothing beyond CC's own implementation bugs)

S1 dat_prep missing and not regenerable with prep verifier 28/28 · S2 contract violation (pr$n/pr$seed/columns/constants incl. the 8-NA-per-coding assert) · S3 any verifier FAIL not attributable to CC's own implementation error · S4 anything requiring a deviation from THIS SPEC (models, labels, constants, inventory, check targets — spec is frozen; the only permitted adaptation is the P5 level-string mapping) · S5 renv conflicts beyond one `renv::restore()`.
