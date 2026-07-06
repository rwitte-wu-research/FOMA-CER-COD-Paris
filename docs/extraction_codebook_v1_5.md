# Extraction Codebook v1.5 — CER→COD Meta-Analysis [SELF-CONTAINED EDITION — supersedes v1.4; F40 a–e construct micro-rulings]
Status: v1.5. Complete rule set (no external references needed). Calibrated on Shad 2022 · Oikonomou 2014 · Lemma 2017 · Eliwa 2021 (13/13 effects cell-exact). Blind pilot PASSED (0 extractor errors). F34 a–f, F36 a–h, DEC-034 fields integrated. Production-live under DEC-032/033/034 (+F38 amendment, author ruling 2026-07-06).

## §1 Study-level fields (once per paper)
| Field | Rule |
|---|---|
| study | "Surname et al (Year)"; two-author papers: "X & Y (Year)". Existing corpus keys are never renamed. |
| sample_start / sample_end | first/last data year of the estimation sample (not publication year) |
| country | verbatim sample countries |
| no_firms / no_firm-years | record what the paper states; the other is DERIVED downstream (rounded division by T). Source flags mark the route used (`coded` = from paper; `calculated` = derived) even if both are stated |
| industry | `sensitive` / `non-sensitive` (sample dominated by environmentally sensitive sectors) |
| regulation_sample_start/end | `with ETS/CT` / `without ETS/CT`; multi-country samples: code by dominant firm-year coverage share; no clear dominance → `mixed`. Sub-national schemes (e.g., RGGI, California) do not flip a country-level `without ETS/CT` |
| country_region | `1_US` `2_Europe` `3_AsiaPac` `99_NCE` — mixed samples → `99_NCE` |
| country_econ | `1_developed` `2_developing` `99_NCE` |
| country_culture | `1_western` `2_non_western` `99_NCE` |
| country_legal | `1_common law` `2_civil law` `99_NCE` |
| field | `1_fin/acc/econ` `2_sust` `3_mgmt` |
| n_obs_by_year | ONLY if the paper prints an observations-per-year table: copy verbatim `year:count; year:count; …`; otherwise `not reported`. Never reconstruct. |
| structurally inapplicable fields | `n/a (structural)` — distinct from FLAG (FLAG = clarifiable; n/a = cannot exist for the design) |
| NOT extracted (lookup side) | q_status, q_VHB, verified reference |

## §2 Effect qualification & selection
- R2.1 **Construct gate:** unit of analysis = the firm. X = the firm's own environmental conduct as **stand-alone environmental construct only**: env. performance scores incl. stand-alone E-pillar of ESG ratings, carbon/GHG emissions/intensity (incl. author-inverted variants), **firm-level fossil-fuel reserves as embedded/potential-emissions measures (firm-specific quantified carbon stocks, e.g., reserves scaled by assets) [F38]**, carbon-management/CDP scores, **environmental rating subdimensions of strengths/concerns type — incl. climate-change concern indicators (KLD/MSCI et al.) — are performance-assessment conduct measures, NOT exposure classifications [F39b; Oikonomou precedent: concerns = bad-CER conduct]**, env. disclosure (CDP/TCFD/GRI, EnvSR-type components), env. violations/penalties, env. management practices, **dichotomized/median-split dummies of the firm's OWN quantified measures (intensity, emissions — transformation of conduct, not an external classification) [F40a]**, **carbon-risk-awareness constructs operationalized via the firm's own disclosure behavior (e.g., CDP response) [F40b]**, **energy-/resource-consumption-based measures (quantified firm-level flows; author labels such as "environmental risk" are irrelevant — the measurement decides) [F40e]**. **Composite ESG/CSR/sustainability indices NEVER qualify — no fallback.** Country-/sovereign-level designs are out of scope. EXCLUDED constructs: climate-risk exposure/perception, physical risk, policy/event exposure, fossil-industry MEMBERSHIP dummies/status, market-implied factors — boundary [F38]: quantified firm-level carbon stocks and flows (emissions, intensity, reserves) = conduct; classifications, sector dummies, and perceptions = exposure. Country-level quantities mechanically allocated to firms remain excluded; Eco-/Soc-/Gov-components; aggregate strengths/concerns.
- R2.2 **Outcome set:** cost of debt (interest-based), loan spreads, bond yields/spreads, credit ratings, CDS spreads. EXCLUDED: default probability/distance-to-default, leverage/volume, CoE, WACC; binary rating-class indicators (e.g., speculative-grade dummies). **Clarification [F40d]: modeling the FULL rating scale qualifies; generalized-ordered-logit threshold equations contribute ALL threshold-specific CER coefficients, tagged subsample_dimension=`rating-class` + threshold value (collapsing, if any, happens at adjudication).**
- R2.3 **E-specificity:** extract every qualifying environmental estimate; E-pillar of performance AND of disclosure = two constructs; strengths AND concerns = two constructs. Composite only if the paper reports no separate environmental estimate — which under R2.1 means: not at all.
- R2.4 **All-models rule:** EVERY regression model containing a qualifying CER main effect on a COD outcome contributes one row — main specs, robustness variants, FE alternatives, alternative COD instruments, system equations, dynamic-panel GMM (CER not instrumented; n_obs = FLAG when the model N is not printed). No de-duplication; within-study dependence is handled downstream (3LMA-RVE).
- R2.5 **Subsamples:** distinct estimation samples (different N; splits by period/region/industry) = distinct rows, with subsample fields (§3.7).
- R2.6 **Bivariate rule:** from the correlation matrix, r(COD, each qualifying CER variable); **Pearson only** — if Pearson/Spearman triangles are mixed, identify and state the triangle used.
- R2.7 **Excluded as effect rows:** interaction terms, quadratic terms, instrumented-CER second stages → log as near-miss with reason. **Heckman-type selection-corrected outcome equations with NON-instrumented CER (IMR as control) qualify under R2.4 [F40c; Al-Fakir precedent].**

## §3 Statistical fields (RAW ONLY — no computation at extraction)
- R3.1 One source tier per effect, priority r > t > b+SE > p. ES_source labels VERBATIM (incl. historical typo/double space): `Correlation coefficient available` · `T-Statistic available` · `Regression Cofficient and Standard Error  available` · `p-Value available`.
- R3.2 Record: b (as printed), SE, t, p (exact printed value), r (bivariate only), n_obs OF THAT model, construct & outcome labels verbatim.
- R3.3 z-statistics from probit/logit/ordered models: record in the t field.
- R3.4 Downstream only (prep script): r = t/√(t²+df) with df = n_obs; b/SE→t; p→|t| two-tailed inverse-t. Never at extraction.
- R3.5 ES_measure: `bivariate` vs `partial`.
- R3.6 **|z|-only tables:** attribute sign deterministically from the odds ratio (OR>1 → +, OR<1 → −); record |z| with attributed sign in t. **PROHIBITED: treating (OR−1)/SE as b/SE.** Implausible/misprinted ORs → note in log; the printed z remains the extracted value.
- R3.7 **Supplementary per-effect fields (copy-level only; judgement needed → FLAG + log):**
| Field | Closed list / format | Source |
|---|---|---|
| x_lag | `0` · `1` · `2+` · `as-stated:<verbatim>` | model spec / table header |
| estimation_method | `OLS` · `FE` · `RE` · `IV-2SLS` · `GMM` · `3SLS` · `ordered probit` · `ordered logit` · `other:<verbatim>` | table header / methods text for THAT model |
| se_clustering | `firm` · `industry` · `country` · `year` · `two-way:<verbatim>` · `robust (unclustered)` · `not stated` · `other:<verbatim>` | table footnotes / methods |
| subsample_dimension | `none` · `period` · `region` · `industry` · `rating-class` · `other:<verbatim>` | model/table caption |
| subsample_value | verbatim (e.g., `post-2016`, `EU only`) | dito |
| subsample_start / subsample_end | years; ONLY when the model runs on a sub-window of the study sample; else empty | model/table caption |
`subsample_note` remains as free-text overflow.

## §4 Sign handling — TWO-STEP
- **Step 1 (extraction):** record values AS REPORTED. No flips. Record direction metadata per row: `x_direction` ∈ {good-CER, bad-CER, author-inverted-to-good} (bad-CER = higher value means worse env. conduct: concerns, emissions, intensity, violations); `outcome_direction` ∈ {cost, creditworthiness} (creditworthiness = higher value means lower cost: ratings, rating scores).
- **Step 2 (harmonization, downstream only):** flip iff exactly one of {bad-CER, creditworthiness}. Target: positive r = higher CER ↔ higher COD.
- Author-inverted X kept as `author-inverted-to-good`, no flip. Unresolvable direction conflicts (e.g., rating scale coded 1=best contradicting the paper's own interpretation) → outcome_direction = FLAG + log.

## §5 Categorical labels (closed lists — verbatim; new value ⇒ FLAG)
COD_instrument: `loand (interest rate)` [sic] · `bond (yield)` · `rating` · `derivativ (CDS spread)` [sic]. CER_measure: `performance` · `disclosure`. regulation: `with ETS/CT` · `without ETS/CT` · `mixed`. Structural: `n/a (structural)`.

## §6 Do-not-extract (derived downstream)
ES (corr_coeff), df, sample_mid/median, pp_* family, post-share fields, median/tertial splits, harmonized signs.

## §7 Output contract (per paper, one chat/run)
A) Study block (§1 fields incl. n_obs_by_year). B) One CSV row per effect — schema, order binding (26 columns):
`study;construct_label_verbatim;CER_measure;COD_instrument;outcome_label_verbatim;ES_source;b;SE;t;p;r_bivariate;n_obs;subsample_note;x_direction;outcome_direction;x_lag;estimation_method;se_clustering;subsample_dimension;subsample_value;subsample_start;subsample_end;table_no;panel_model;page;cell_quote`
C) Extraction log: ambiguities, FLAGs, near-misses with reasons, scan-quality issues, count reconciliation. FLAG rule: unclear rule ⇒ field=FLAG + log entry; never guess, never compute, never judge quality. Self-checks: announced count = row count; every row has provenance; every FLAG has a log entry; no computed fields. Gold-row note: the template's supplementary-field values are schema illustrations.

## §8 Register
F40 a–e codified (own-measure dummies; awareness-as-disclosure; Heckman-outcome equations; gologit thresholds; consumption-based measures — author rulings 2026-07-06). F39b: KLD-type climate-concern subdimensions qualify as conduct (author ruling 2026-07-06; Bauer & Hann re-extraction mandated). F38: fossil reserves qualify as embedded-emissions conduct (author ruling; Delis re-extraction mandated). F34 a–f codified (construct level; all-models; two-step signs; subsamples; Pearson) · F36 a–h codified (n/a-structural; mixed-regulation; 99_NCE; two-author label; GMM; |z|/OR rule; sub-national; firm-level unit) · DEC-034: six supplementary fields, purpose-tagged, result-blind. Parked: legacy interaction row (Lemma 836); Lemma CR tag/direction — both under adjudication.

## §9 Production gate
Blind pilot PASSED (2026-07-05; 0 extractor errors on statistical core fields). Full-corpus harmonization per DEC-033: new extraction = canonical for v11; legacy v10 = independent double-coding on the overlap; exact agreement = mutually verified; disagreements + new rows → adjudication against source. Uniformity: pilot stagings invalidated; every paper runs under this codebook.

## Annex A — Calibration provenance (gold examples)
| Corpus row | Value | Source cell |
|---|---|---|
| Shad 1094 | −0.35 | Tab.4, corr(EnvSR, Cd) |
| Shad 1095 | −0.115179 | Tab.5 Panel A, EnvSR β=−0.432, SE=0.184 |
| Oik 917 | +0.015764 | Tab.4, Env strengths → ln(spread), p=0.164 |
| Oik 918 | −0.016801 | Tab.4, Env concerns → ln(spread), p=0.138 [bad-CER] |
| Oik 919 | −0.050004 | Tab.5, Env strengths → bond rating, p=0.000 [creditworthiness] |
| Oik 920 | +0.021471 | Tab.5, Env concerns → bond rating, p=0.058 [bad-CER × creditworthiness] |
| Lemma 832/833 | −0.108 / −0.053 | Tab.2 corr matrix, KD×DSCR / KD×CR |
| Lemma 834/835 | t=0.36 / 0.63 | Tab.7, DSCR→KD, reduced / full system |
| Eliwa 481 | t=−3.41, N=6018 | Tab.5 Panel A col 1, Environmental-perform |
| Eliwa 482 | t=−2.41, N=3166 | Tab.5 Panel B col 1, Environmental-disclose |
