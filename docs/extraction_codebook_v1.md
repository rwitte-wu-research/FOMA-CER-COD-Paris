# Extraction Codebook v1 — CER→COD Meta-Analysis (Search Update) [FROZEN per DEC-032]
Status: v1 (2026-07-05). Calibrated on Shad 2022 · Oikonomou 2014 · Lemma 2017 · Eliwa 2021 (13/13 effects reproduced cell-exactly). F34a–f ruled by authors. Production use gated on blind-pilot PASS (§9).

## §1 Study-level fields (once per paper)
| Field | Rule |
|---|---|
| study | "Surname et al (Year)" as in citation |
| sample_start / sample_end | first/last data year of estimation sample (not publication year) |
| country | verbatim sample countries |
| no_firms / no_firm-years | record what the paper states; the other is DERIVED downstream (rounded division by T). Source flags mark the route used: `coded` (from paper) vs `calculated` (derived) — even if both are stated (Shad precedent) |
| industry | `sensitive` / `non-sensitive` (sample dominated by env.-sensitive sectors) |
| regulation_sample_start/end | `with ETS/CT` / `without ETS/CT` |
| country_region | `1_US` `2_Europe` `3_AsiaPac` `99_NCE` |
| country_econ | `1_developed` `2_developing` `99_NCE` |
| country_culture | `1_western` `2_non_western` `99_NCE` |
| country_legal | `1_common law` `2_civil law` `99_NCE` |
| field | `1_fin/acc/econ` `2_sust` `3_mgmt` |
| NOT extracted (lookup side) | q_status, q_VHB, verified reference — Volker/records |

## §2 Effect qualification & selection
- R2.1 **Construct gate [F32v2 + F34a]:** X = firm's own environmental conduct as **stand-alone environmental construct only**: env. performance scores incl. stand-alone E-pillar of ESG ratings, carbon/GHG emissions/intensity (incl. author-inverted variants), carbon-management/CDP scores, env. disclosure (CDP/TCFD/GRI, EnvSR-type components), env. violations/penalties, env. management practices. **Composite ESG/CSR/sustainability indices NEVER qualify — no fallback** [F34a]. Consequence for composite-ESG papers: they enter only via separately reported E-pillar estimates. EXCLUDED constructs: climate-risk exposure/perception, physical risk, policy/event exposure, fossil-industry status, market-implied factors; Eco-/Soc-/Gov-components; aggregate strengths/concerns.
- R2.2 **Outcome set:** cost of debt (interest-based), loan spreads, bond yields/spreads, credit ratings, CDS spreads. EXCLUDED: default probability/distance-to-default, leverage/volume, CoE, WACC; binary rating-class indicators (e.g., speculative-grade dummies) are not in the outcome set (as executed: Oikonomou probit models on the speculative dummy were not extracted).
- R2.3 **E-specificity (5× validated):** extract every qualifying environmental estimate the paper reports (E-pillar of performance AND of disclosure count as two constructs — Eliwa; strengths AND concerns count as two — Oikonomou).
- R2.4 **All-models rule [F34b]:** EVERY regression model containing a qualifying CER main effect on a COD outcome contributes one row — main specs, robustness variants, FE alternatives, alternative COD instruments, system equations (Lemma reduced AND full). **Do not de-duplicate**; within-study dependence is handled downstream by the 3LMA-RVE design.
- R2.5 **Subsamples [F34e]:** distinct estimation samples (different N; split samples pre/post, regions, industries) = distinct rows, with subsample_note.
- R2.6 **Bivariate rule [F34f]:** from the correlation matrix, r(COD, each qualifying CER variable); **Pearson only** — if Pearson/Spearman triangles are mixed, identify and state the triangle used.
- R2.7 **Excluded as effect rows:** interaction terms (moderation estimand, not the link), quadratic terms, instrumented second stages → log as near-miss with reason. Legacy note: v10 row 836 (Lemma DSCR×HCR) under author review [parked with F34d]; forward rule is exclusion.

## §3 Statistical fields (RAW ONLY — no computation at extraction)
- R3.1 One source tier per effect, priority r > t > b+SE > p. ES_source labels VERBATIM (incl. historical typo/double space): `Correlation coefficient available` · `T-Statistic available` · `Regression Cofficient and Standard Error  available` · `p-Value available`.
- R3.2 Record: b (as printed), SE, t, p (exact printed value), r (bivariate only), n_obs OF THAT MODEL, construct & outcome labels verbatim.
- R3.3 z-statistics from ordered probit/logit models are recorded in the t field (treated as t downstream — as executed, Oikonomou rating models).
- R3.4 Downstream (prep script T0.4, NOT extractor): partial r = t/√(t²+df), df = n_obs [DEC-028]; b/SE→t; p→|t| two-tailed inverse-t, df = n_obs. Validated cell-exactly on all four calibration papers.
- R3.5 ES_measure: `bivariate` vs `partial`.

## §4 Sign handling — TWO-STEP [F34c]
- **Step 1 (extraction):** record values AS REPORTED. No flips. Additionally record direction metadata per row: `x_direction` ∈ {good-CER, bad-CER, author-inverted-to-good} (bad-CER = higher value means worse env. conduct: concerns, emissions, intensity, violations); `outcome_direction` ∈ {cost, creditworthiness} (creditworthiness = higher value means lower cost: ratings, rating scores).
- **Step 2 (harmonization, downstream/prep):** flip sign iff exactly one of {x_direction = bad-CER, outcome_direction = creditworthiness} holds (double flip cancels). Target convention: **positive r = higher CER associated with higher COD**. Validated: Oikonomou concerns×spread (one flip → −0.0168), concerns×rating (double flip → +0.0215), strengths×rating (one flip → −0.0500) — all cell-exact.
- Author-inverted X (Lemma CR = inverse intensity per formula): record as `author-inverted-to-good`, no flip; direction conflict formula-vs-text → FLAG + log [F34d parked].

## §5 Categorical labels (closed lists — verbatim; new value ⇒ FLAG)
COD_instrument: `loand (interest rate)` [sic] · `bond (yield)` · `rating` · `derivativ (CDS spread)` [sic]. CER_measure: `performance` · `disclosure`.

## §6 Do-not-extract (derived downstream)
ES (corr_coeff), df, sample_mid/median, pp_* family, post-share fields, median/tertial splits, harmonized signs.

## §7 Output contract (per paper, one chat/run)
A) Study block (§1). B) One CSV row per effect, schema: `study; construct_label_verbatim; CER_measure; COD_instrument; outcome_label_verbatim; ES_source; b; SE; t; p; r_bivariate; n_obs; subsample_note; x_direction; outcome_direction; table_no; panel_model; page; cell_quote`. C) Extraction log: ambiguities, FLAGs, near-misses with reasons, scan-quality issues, count reconciliation. FLAG rule: unclear rule ⇒ field=FLAG + log entry; never guess, never compute, never judge quality.

## §8 Resolved / parked register
a ✓ E-standalone only, no composite fallback (F34a) · b ✓ all models (F34b; interaction exclusion codified in R2.7) · c ✓ two-step sign procedure (F34c) · d ◐ parked: Lemma CR tag + direction (author background check, non-blocking) · e ✓ subsample = own row · f ✓ Pearson only.

## §9 Production gate [DEC-032]
Blind pilot on ≥2 corpus papers not used in calibration; concordance target ≥95% on statistical core fields (b/SE/t/p/n_obs/row identification) vs. v10; below target → codebook/prompt iteration and re-pilot. Volker verifies 100% of statistical core fields of all production extractions against the PDFs (role inversion).

## Annex A — Calibration provenance (gold examples)
| v10 row | Value | Source cell |
|---|---|---|
| Shad 1094 | −0.35 | Tab.4, corr(EnvSR, Cd) |
| Shad 1095 | −0.115179 | Tab.5 Panel A, EnvSR β=−0.432, SE=0.184 |
| Oik 917 | +0.015764 | Tab.4, Env strengths → ln(spread), p=0.164 |
| Oik 918 | −0.016801 | Tab.4, Env concerns → ln(spread), p=0.138 [bad-CER] |
| Oik 919 | −0.050004 | Tab.5, Env strengths → bond rating, p=0.000 [creditworthiness] |
| Oik 920 | +0.021471 | Tab.5, Env concerns → bond rating, p=0.058 [bad-CER × creditworthiness] |
| Lemma 832/833 | −0.108 / −0.053 | Tab.2 corr matrix, KD×DSCR / KD×CR |
| Lemma 834/835 | t=0.36 / 0.63 | Tab.7, DSCR→KD, reduced / full system |
| Lemma 836 | t=−0.98 | Tab.7, DSCR×HCR interaction [legacy; R2.7] |
| Eliwa 481 | t=−3.41, N=6018 | Tab.5 Panel A col 1, Environmental-perform |
| Eliwa 482 | t=−2.41, N=3166 | Tab.5 Panel B col 1, Environmental-disclose |
