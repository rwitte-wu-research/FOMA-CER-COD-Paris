# T0.4 — Data Preparation Spec (`R/00_prep.R` + `R/00_verify_prep.R`)
Gate: pre-execution diff review (foundational script #1). Result-blind by construction: the script computes NO pooled estimates; the only model fits use a seeded DUMMY outcome to obtain design-only Satterthwaite df (df depend on X, V, clustering — not on effect values).

## Inputs (pinned)
- `data/CER-COD_data_v12.xlsx` (canonical, commit 63356a7) — sheets `data`, `lookup`, `country_map`, `subsample_country_map`
- Governing decisions: DEC-028 (Fisher-z PCC, df ≈ n_obs + k-sensitivities), DEC-024 (Paris suite + transfer rule), DEC-031/031a/031b/042a (battery, q-rule, estimation set), DEC-017 (ρ = 0.6)

## Outputs
1. `output/dat_prep.rds` — analysis-ready object: estimation set (asserted n = 2,713), zi/vi (+ vi_k10/vi_k20), all factors, id columns (esid, study, cluster_id), Paris codings, flags (starbound, proxy_n) as columns
2. `output/design_quantities_v12.csv` — the citable design facts (replaces every [v8] placeholder):
   - cells per Paris coding (headline `pp_mid`, tie-break `pp_median`, `end_lag0–3`, share-lags binary 1–3, clean-window): k effects / studies / clusters, pre & post
   - design-only Satterthwaite df of the Paris coefficient per binary coding (dummy-outcome device, seed 20260710)
   - **upgrade adjudications (DEC-031a.5):** `clean_window_upgrade` = (df_clean ≥ 5); `split_selmodels_upgrade` = (post-cell studies ≥ 20)
   - post-cell dominance: study shares of post-cell k (LOSO inputs)
   - post-cell composition shares: country_region, CER_measure
   - counts: star-bound (99), proxy-n rows in estimation set, N15 within-study set (studies with both pre- and post-cell effects under the headline coding)
3. `output/verify_prep_log.txt` — verifier PASS/FAIL table (written by `00_verify_prep.R`)

## Pipeline (00_prep.R)
S1 Load + name normalization (newline column names mapped to syntactic names via a fixed lookup table; mapping printed).
S2 **Cross-language recomputation (hard gate):** recompute in R, from raw fields only, and assert cell-exact equality (numeric tol 1e-9) against the sheet values for: grid L–AE (rules incl. frozen constants: median split > 2013; tertiles > 2011 / > 2014; pp_mid ≥ 2015.5; pp_median ≥ 2016; window-class rule), q_status/q_VHB/field classes (P-09 rule via lookup), country_region/econ/culture/legal (subsample-override-else-paper via the two map sheets; Bannier/Srivisal hardcode exception), column E (n_obs-if-numeric-else-proxy), Fisher-z vs `d_fisher_z` (pre-verified: max|Δ| ≈ 4e-16).
S3 Structural assertions: closed lists (all coded moderators), key integrity (data studies ⊆ lookup; 120 studies; 119 cluster_ids), grid identities (sample_median ≡ sample_mid; pp_share_lag0 ≡ share_2016; end_lag0 ⇔ share_2016 > 0; clean_post ⇔ pp_start ⇔ share = 1).
S4 Estimation set: `d_es_usable == 1 & duplicate == 0 & is.finite(E)` → **assert n = 2,713** (plus 2,852 / 2,730 / 122 / 1 / 16 component asserts per DEC-042a).
S5 Effect sizes: zi = atanh(r); vi = 1/(E − 3) (df ≈ n_obs headline, DEC-028); vi_k10 = 1/(E − 10 − 3), vi_k20 = 1/(E − 20 − 3) as sensitivity columns (rows with E ≤ 13/23 → NA in that column, count logged).
S6 Factors: moderators per DEC-031a inventory; reference level = largest cell (pure convention, logged; irrelevant for F-tests/dose model); Paris codings as named columns; `sample_mid_c` centered on the corpus mean.
S7 Design quantities + upgrade adjudication (dummy-outcome df; NO real-outcome fit anywhere).
S8 Save RDS; print run manifest (counts, session info, seed) — no effect statistics.

## Verifier (00_verify_prep.R) — independent code paths
V1 reload xlsx fresh; recount S4 constants · V2 re-derive grid via an independent implementation (vectorized formulas, not shared functions) and compare to RDS · V3 closed lists + key integrity re-run · V4 RDS internals: zi/vi finiteness, no NA in id/factor columns of the estimation set · V5 design_quantities re-derivation of cell counts (df values taken from prep output; counts recomputed) · V6 identity checks S3 re-run · writes PASS/FAIL log; any FAIL → nonzero exit.

## Reviewer checklist (for the diff review)
1. S2/S3 assertions match the DEC-031a.9 rules and frozen constants verbatim
2. No `rma.mv`/model call with the real `zi` anywhere (grep `zi` usage — only the dummy-df block may fit models, and only with `y_dummy`)
3. Estimation-set filter matches DEC-042a exactly (incl. duplicate exclusion — source of the 2,713 vs 2,714 correction)
4. vi conventions match DEC-028; k-sensitivity NA-handling explicit
5. design_quantities columns cover every [v8] placeholder in DEC-031 Annex B + both upgrade conditions
6. Seed 20260710 set once, used only in the dummy-df block
