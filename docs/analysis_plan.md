# Analysis Plan — CER–COD FOMA (Paris moderator)

**Status:** T0.1 deliverable. Canonical executable specification. Every per-block Claude-Code spec (T1, T4, T5, T7, T8) inherits from this document; deviations require a DEC.
**Language:** English (consistent with `DECISION_LOG.md`).
**Environment (confirmed):** R 4.6.1 · renv 1.2.3 · metafor 5.0.1 · clubSandwich 0.7.0 · `selmodel` present · `puniform` 0.2.8 installed. Deferred (E4): `RoBMA` + JAGS/Stan.
**Decision basis:** DEC-002, DEC-003, DEC-004, DEC-005, DEC-006, DEC-007, DEC-008, DEC-009, DEC-010, DEC-011, DEC-012, DEC-013, DEC-014, DEC-015, DEC-016, DEC-017, DEC-018, DEC-019, DEC-020, DEC-021, DEC-022, DEC-023, DEC-024, DEC-025, DEC-026, DEC-027, DEC-028, DEC-029; E1–E6, E8, E14–E23.

---

## 1. Data

- Source: **`CER-COD_data_v10.xlsx`** (final; sheets `data` [45 cols] + `country_lookup` + `source_lookup` [65 rows; `note` audit trail; verified-reference column `source_verfified` — sic, codebook alias: reference_verified] + `notes` [Volker batch answers a–e incl. Sharfman exclusion rationale] + `formula` [conversion routes, V5]). Lineage: v5 exact midpoints + end-axis lags; v6 quality recode [DEC-025]; v7 status correction [DEC-026]; v8 66-row source audit; v9 Volker batch (V4 flags, V5 formulas, lookup care) [DEC-028]; v10 ES-type label fix + lookup consolidation [DEC-028]. Effect-size core byte-identical v4→v10 under renames (verified: max |Δ| = 0).
- Column renames (v9): `corr` → **`ES (corr_coeff)`**; `sample_size …calc_rounded` → `…_rounded`. New columns: `no_firms_source` / `no_firm-years_source` (coded 593/408 · calculated 713/898) [V4]; **`ES_source`** (direct r 36 · t-statistic 634 · coef+SE 570 · p-value 66) [V5]. Prep maps legacy names.
- Cached-column caveat unchanged: prep re-derives all `pp_*` from raw years (rules in §6); `pp_start_lag0` cache stale (≥ 2017).
- Unit: **1,306 effect sizes / 66 studies** (effects/study: min 1, median 10, max 138 = Bauer & Hann, 10.6%). Study-key note: `Li et al (2021)` → `Li et al (2022)` in v9 (same paper, version-of-record identity) [DEC-028].
- **ES composition [F20/DEC-028]:** 36 bivariate direct-r effects (23 studies, 2.8%) · 1,270 converted PCCs (97.2%) via the `formula` routes; df convention in §2.
- n-distribution & derivation [DEC-015/027/028]: median 289; 9 integer rows with n < 10; source flags authoritative (calculated 54.6%); round(n_obs/T) is the primary derivation route.
- Extremes [DEC-013, closed]: Devalle +0.9998 (n = 56) and Drago −0.9977 (n = 184) verified at source; retained; rstudent/LOSO/winsor carry influence (§9).

## 2. Effect-size metric [DEC-004, DEC-015, DEC-028; E5]

- **Sample size [DEC-019, DEC-027]:** headline `n = no_firms`; `vz = 1/(no_firms − 3)`. Robustness: **`n_obs`** (upper-precision bound; unit-heterogeneous: 81 effects in 3 studies are sub-annual/loan-level) and study-level aggregation [E14].
- Metric: **Fisher's z** throughout; back-transform the meta-analytic estimate to r for reporting only. `zi = atanh(ri)`.
- **Estimand composition [F20/DEC-028]:** 1,270 effects (97.2%) are **converted partial correlations** (routes: t 634 · b/SE 570 · p 66; documented in the `formula` sheet, V5); 36 effects (2.8%; 23 studies) are direct bivariate r. The PCC literature (van Aert 2023; Stanley et al. 2024) is therefore the reporting anchor; IZRT back-transformation applies to the direct-r minority only.
- **PCC df convention [F21/DEC-028]:** the conversions use df ≈ `n_obs` (not n − k − 1); k is not coded and is not collected. Disclosed approximation — relative attenuation ≈ k/(2·n_obs), negligible at median n_obs ≈ 2,910 — plus sensitivity `pcc_df_k10`/`pcc_df_k20` (invert t from (r, n_obs); recompute r with df = n_obs − {10, 20}). The sampling variance remains 1/(no_firms − 3) regardless [DEC-019].
- **`direct_r_only`** (`spec`, E5): the 36/23 direct-r subsample as the conversion-free check (replaces the former `bivariate_only`/`r_type` framing).

## 3. Core model family — 3LMA-RVE [DEC-002, DEC-003, DEC-017]

Three-level structure (effects within studies) with a correlated-effects working covariance, cluster-robust CR2 inference (Satterthwaite df), clustered on `study`.

### 3.1 Working covariance V [DEC-017, E1]
Within-study sampling correlation **ρ = 0.6** (default); sensitivity grid **0.4 / 0.6 / 0.8**.

```r
library(metafor); library(clubSandwich)
dat$esid <- seq_len(nrow(dat))                      # effect id within study
V <- impute_covariance_matrix(vi = dat$vz, cluster = dat$study, r = 0.6)
```

### 3.2 Headline magnitude (pooled) [DEC-003]
```r
m <- rma.mv(yi = zi, V = V,
            random = ~ 1 | study/esid,             # 3-level: effect in study
            data = dat, sparse = TRUE, method = "REML")
coef_test(m, vcov = "CR2", cluster = dat$study)     # CR2 + Satterthwaite df
conf_int(m, vcov = "CR2", cluster = dat$study)      # robust CI
# report: back-transform tanh(estimate) and tanh(CI) to r
```
- Headline = the pooled 3LMA-RVE mean (MA convention + direct Zarea comparability).
- Variance decomposition (`m$sigma2`) reports τ²_within / τ²_between → resolves the I²=0 anomaly (#2) and replaces the draft's degenerate PI = [0.000, 0.000].

### 3.3 ρ-sensitivity
Re-run 3.1–3.2 at r = 0.4 and 0.8; report point/CI as a sensitivity row (`spec = "rho_0.4" | "rho_0.8"`). CR2 makes the **point estimate robust to ρ-misspecification**; ρ affects efficiency, not validity (DEC-017 rationale).

## 4. Identification — break vs. trend vs. dose [DEC-003, DEC-007, DEC-008, DEC-021, DEC-024]

Headline magnitude (§3) and identification are distinct results. T8 runs on the single DEC-021 time axis `sample_mid` (half-year resolution; centred ~2015/16).

```r
# (i) Trend-vs-break race
m_race <- rma.mv(zi, V, mods = ~ sample_mid_c + post_paris,      # post_paris = pp_share_lag0
                 random = ~ 1 | study/esid, data = dat, sparse = TRUE)
# (ii) Dose (differential exposure, Move 5)
m_dose <- rma.mv(zi, V, mods = ~ sample_mid_c + post_share,
                 random = ~ 1 | study/esid, data = dat, sparse = TRUE)
coef_test(m_race, vcov="CR2", cluster=dat$study); coef_test(m_dose, vcov="CR2", cluster=dat$study)
```

- Dose reporting: model-implied z̄(0) / z̄(0.6) / z̄(1) with CR2 CIs; 0→0.6 = in-support contrast (p95 of share = 0.6; z̄(1) flagged extrapolative); quadratic-in-share check.
- Deliberate collinearity disclosure: corr(sample_mid, post_share) = 0.70 — the dose is interpretable only alongside the trend, which is why it lives here, not in §3/§6.
- Placebo break-years on `sample_mid` (Move 3 replacement for the collapsed lag ladder); support is pre-2015 (study-level median sample_mid = 2012; 8 studies ≥ 2016). `pp_median split` / `pp_tertial split` (boundaries 2012 / 2014) are generic time splits and belong to this toolkit, not the Paris suite.
- Toolkit remainder per Identifikation tab: segmented MR · composition control (Move 4, elevated to core — see §6 disclosure) · bounding. Move 6 dead (DEC-008).

## 5. Cluster-robust inference everywhere [DEC-014]

**All** weighted regressions — pooled, subgroup, FAT-PET-PEESE, and the unified meta-regression — use CR2 clustered on `study`, never naive WLS. This is the single correction that makes the draft's Table 7/8 inference valid.

## 6. Pre/Post-Paris coding [DEC-005, DEC-020, DEC-024]

**Headline: `pp_share_lag0`** — binary, post_share ≥ 0.5, ties→Post (138 effects / 11 studies). Precedent: sample-midpoint per Zarea et al. (2026), who reject start/end-year classification as temporal misclassification (citing Feld et al. 2013; Geyer-Klingeberg et al. 2021; Tang & Buckley 2020) but *exclude* tie windows; our ties→Post convention diverges for exactly 2 single-effect studies (disclosed; tie-break row brackets it).

Attenuation disclosure (design constant): group-mean shares 0.728 (Post) vs 0.138 (Pre) → the binary contrast recovers ≈ 0.59 of the full 0→1 regime contrast; implied full contrast ≈ binary/0.59 (conservative direction). Knife-edge mass: 96 effects with share ∈ [0.40, 0.60). One Methods sentence on panel drift (post years contribute more observations than their calendar share).

**Inference-transfer rule [DEC-024, pre-registered]:** T2 verifier computes the CR2/Satterthwaite df of the Paris coefficient design-only. df ≥ 5 → full inference on the binary. df < 4–5 → binary stays as descriptive display (estimate + CI + df, no p-value); the inferential Paris claim transfers to the §4 dose model. Divergence reported, not adjudicated post hoc.

Suite roles (a priori):

| Spec | Definition | Cells (Post: k/studies) | Role |
|---|---|---|---|
| headline | share ≥ 0.5, ties→Post | 138 / 11 | full inference (subject to rule) |
| tie_break | pp_mid ≡ pp_median (ties→Pre) | 136 / 9 | sensitivity, ONE row |
| end_any_exposure | end ≥ 2016 ⇔ share > 0 | 728 / 40 | upper-recall bound (81.0% of the cell is majority-pre; within-cell median share 0.333) |
| share_lags 1–3 | share_2017/18/19 ≥ 0.5 | 55/5 · 26/2 (lag2 ≡ lag3) | main-text coding sensitivity; the collapse is the finding |
| end_lags 1–3 | end ≥ 2017/18/19 | 562/31 · 506/24 · 252/14 | appendix |
| clean_window | clean_pre 578/27 vs clean_post 43/4 | — | descriptive; no p-values (df < 4–5) |

Composition disclosure (post cell): Asia-Pacific 84/138 effects (4 Chinese studies), bond-yield 58%, CER-performance 98.6%, median window 5 vs 10 yrs, median n 799 vs 225. Paris inference reads from T7 (composition controls) + §4; the raw subgroup table is descriptive. LOSO on the post cell mandatory (Tan = 36%; top-3 = 72%).

Prep derivation rules + verifier identities: pp_start = 1{start ≥ 2016} (cache stale); assert pp_start ≡ clean_post ≡ (share = 1); pp_mid ≡ pp_median; lag2 ≡ lag3 (share axis); end ⇔ share > 0; sample_median ≡ sample_mid (drop one). Naming: pp_share_* are binary; the continuous dose = `sample_post share_*`.

## 7. Unified meta-regression [DEC-002, DEC-009, DEC-014]

One model with Paris × moderator interactions instead of many nested subgroup splits (resolves the old Model-10 multicollinearity, SE(Zr)-SE = 0.568).

```r
m_uni <- rma.mv(zi, V,
                mods = ~ post_paris * (cod_instrument + industry + regulation
                                       + country_region + country_dev + country_west + country_legal
                                       + q_status + q_VHB + field)
                        + ES_source,
                random = ~ 1 | study/esid, data = dat, sparse = TRUE)
coef_test(m_uni, vcov = "CR2", cluster = dat$study)
```
- **Moderator inventory [DEC-022, DEC-025]:** CER type · COD instrument · industry · regulation (ETS/CT) · country {region, development (IMF), culture (DST), legal (La Porta)}, parse-homogeneous → NCE residual · quality [DEC-025, DEC-026]: `q_status` (published 999/60 vs WP 307/6; sole grey-literature moderator) + `q_VHB` via reference-cell coding of {pub-high 813/41, pub-low 186/19 (ref), WP} — WP rows retained; univariate VHB panels on the published subsample; `q_JIF` retired (raw in `source_lookup`). `country_*` via `country_lookup`; `q_*`/`field` via `source_lookup`. Dominant-country sensitivity dropped (E21); CIT dropped (DEC-023). `ES_source` (4-level conversion-route factor; reference = t-route) operationalizes the former es_type/method_artefacts placeholders [DEC-028]; Datenagenda #3 closed.
- Long-format results CSV carries a `spec` column for variant handling.

## 8. Publication bias [DEC-010, DEC-014, DEC-016, E3]

### 8.1 Primary — FAT-PET-PEESE, CR2-clustered, consistent across ALL subgroups [DEC-010, DEC-014]
```r
# FAT/PET: z ~ SE(z)   (slope = FAT test; intercept = PET estimate of true effect)
m_pet  <- rma.mv(zi, V, mods = ~ sez, random = ~1|study/esid, data=dat, sparse=TRUE)
coef_test(m_pet, vcov="CR2", cluster=dat$study)
# PEESE: z ~ SE(z)^2   (use if PET intercept is significant)
m_peese <- rma.mv(zi, V, mods = ~ I(sez^2), random = ~1|study/esid, data=dat, sparse=TRUE)
coef_test(m_peese, vcov="CR2", cluster=dat$study)
```
- **Decision rule (fixed a priori):** PET first; PEESE only if the PET intercept is significant. Apply the **same** rule to every subgroup — no selective PEESE. This forces the discussion to align with PET, where Sensitive-industry (PET = +0.001 n.s.) and No-pricing (PET = +0.004 n.s.) vanish.

### 8.2 Secondary — selection models, study level [DEC-016, E3]
Selection models assume independence → fit on **one-effect-per-study** aggregates (k = 66).
```r
agg <- aggregate_to_study(dat)                       # one z per study (precision-weighted)
m_fe  <- rma(yi = z, vi = vz, data = agg, method = "FE")
sm_3psm <- selmodel(m_fe, type = "stepfun", steps = 0.025)   # 3PSM (native metafor)
library(puniform)
pu <- puni_star(yi = agg$z, vi = agg$vz, side = "left")      # p-uniform* (CER↓COD ⇒ left)
```
- Triangulation target: convergence/divergence of PET-PEESE vs. 3PSM vs. p-uniform\* feeds the overall bias narrative and the A-vs-C framing. PET-PEESE remains primary (Stanley et al. 2025).
- RoBMA deferred (E4).

## 9. Robustness `spec` catalogue [DEC-004, DEC-013, DEC-015, DEC-024–027; E1, E2, E5]

Single long-format CSV, `spec` column. Required specs:
`leave_one_out` (incl. explicit post-cell LOSO) · `outlier_rstudent` · `winsor` / `unwinsor` · `one_effect_per_study` · `cer_type` · `journal_q` (VHB, published subsample) · `status_as_extracted` [DEC-026] · `n_obs` [E14/DEC-027] · `event_coding` = {tie_break, end_any_exposure, share_lags_main, end_lags_appendix, clean_window, share_quadratic} [DEC-024] · **`uwls3`** [E2] · **`direct_r_only`** [E5; 36 effects / 23 studies] · **`pcc_df_k10` / `pcc_df_k20`** [DEC-028] · **`rho_0.4` / `rho_0.8`** [E1].

- **UWLS+3 [E2, DEC-015]:** unrestricted WLS (FE estimator with multiplicative dispersion) with the +3 Fisher-z df adjustment of Stanley et al. (2025). Implementation per that paper's appendix (confirm the exact df constant against the source). Robustness only; HS deferred (E2).
- **Outliers [DEC-013, closed]:** Devalle/Drago verified at source and retained; rstudent identification + drop-and-refit reported prominently; winsor remains a sensitivity, never the primary treatment.

## 10. Headline-vs-robustness, fixed a priori [DEC-003, T0.2]

To pre-empt specification search: headline magnitude = 3LMA-RVE pooled mean (§3.2); identification = meta-regression (§4); everything in §6, §8.1-variants, §9 is robustness. Event coding and r-type fixed a priori (§2, §6). This ordering is locked before any model runs.

## 11. Output contract

- Per-run results workbook: frontmatter + analysis tabs + **"Manuscript Inputs"** tab (copy-paste-ready prose). Plots: DejaVu Serif, navy #1F3864, 95% CI.
- Long-format `output/Tx_results.csv` with `spec` column.
- `manuscript/Tx.md` with mandatory H2s (Purpose / Methods / Results / Verdict / Implications).
- Each analysis script `R/NN_name.R` has a paired `R/NN_verify_outputs.R` (numbered checks O1..On, PASS/FAIL).
- Source-pointer notation throughout: `[DEC-NNN]; [R/NN]; [<xlsx> Tab N]; [<md>]; [<ms> §X.Y]; [commit <hash>]`.

## 12. Toolchain manifest

| Need | Package | Status |
|---|---|---|
| 3LMA-RVE, meta-regression, FAT-PET-PEESE | metafor 5.0.1 | ✓ |
| CR2 + Satterthwaite, V construction | clubSandwich 0.7.0 | ✓ |
| 3PSM | metafor::selmodel | ✓ (native) |
| p-uniform\* | puniform 0.2.8 | ✓ (E3) |
| UWLS+3 | metafor/WLS (manual df) | ✓ (no new pkg, E2) |
| RoBMA (Bayesian) | RoBMA + JAGS/Stan | deferred (E4); README, not renv |

---

## 13. Null-robustness battery [DEC-029]

Fifteen pre-designated analyses (Status tab `Null_Battery`, GO 2026-07-04) guard the informative-null claim along four attack lines. **(A) chance/power:** N1 TOST equivalence (SESOI dual anchor, F18) · N2 design-only MDE simulation (joins the T2 verifier) · N3 BF/RoBMA · N4 prediction intervals. **(B) specification:** N5 multiverse/specification curve (anchor figure) · N6 sup-break + N7 permutation inference (shared machinery; p_perm next to p_CR2) · N8 Zarea transplantation · N9 HS (+WAAP; appendix). **(C) time-form:** N10 cumulative MA (main graphic) · N11 rolling window (appendix). **(D) benchmark:** N12 external-difference test · N13 p-curve (conditional: ≥ 5 significant study-level post-cell p, else reported infeasible) · N14 pre/post publication-bias split (appendix). N15 within-study display is descriptive only (DEC-008 partially reopened). Required a-priori inputs and paper acquisitions per DEC-029; **inputs are fixed in the battery-prep step before T1**.

---

## Open items (non-blocking)

**Pending-B resolved** (v9 `formula` sheet → DEC-028). Remaining: **V6 PRISMA basics** (Volker; Datenagenda #16) · **battery a-priori inputs + paper acquisitions** [DEC-029] (battery-prep step, pre-T1; incl. F18 SESOI) · codebook folding of `notes`/`formula` + `source_verfified` alias note · F22 Shad cross-note carried into the overlap/cover-letter table.

---

## Change log
- 2026-06-30 — created; operationalizes `[DEC-002..017]` (E1–E6). ρ = 0.6 working correlation fixed in DEC-017.
- 2026-06-30 (b) — `[DEC-018]` (E8): interim publication-year time axis, §4/§9; data-path fix in §1 (`data/CER-COD_data_v1.xlsx`).
- 2026-07-03 — data finalization `[DEC-019..023]` (E14–E23): source → `CER-COD_data_v4.xlsx`; n = `no_firms` (§2); Pre/Post suite + headline shift end→mid/continuous (§6); `sample_mid` time axis, DEC-018 retired (§4); country {region/dev/culture/legal} + quality {status/VHB/JIF/field} moderators (§7); CIT dropped. Headline-cut + VHB/JIF-WP basis open for methodology finalization.
- 2026-07-03 (b) — Step-1 finalization `[DEC-024..027]`: source → `CER-COD_data_v8.xlsx`; §§1/2/4/6/7/9 replaced; Pending-A resolved; `q_JIF` retired; E14 → `n_obs`; DEC-013 closed (extremes verified); Datenagenda #11 closed (COE overlap 5/66, 42 effects, disjoint estimands).
- 2026-07-04 — Data closure + null battery `[DEC-028, DEC-029]`: source → `CER-COD_data_v10.xlsx`; §§1/2 rewritten (ES composition corrected: 36 direct-r / 1,270 PCC; df ≈ n_obs convention + `pcc_df_k` sensitivity); §7 `ES_source` factor; §9 updates (`direct_r_only`, `pcc_df_k10/20`; `r_type` retired); §13 null battery added; Pending-B resolved.

### Update 2026-07-04 [DEC-030]
- Formal PRISMA search update decided (rule-based, identical criteria, end date = execution date; two-stage flow). Data source remains **v10** for all specs until **v11** lands; all design quantities (cell sizes, df, grids, N2 design matrix) are re-derived mechanically on v11.
- Numbering: **DEC-030 = search update** (this entry); **DEC-031 = battery-input fixation** (SESOI values per F27v2, multiverse factor space, p-curve rule, permutation B) — logged after v11. Prior references to "DEC-030 = battery inputs" are superseded.
- CER-construct gate codified (carbon-based measures IN as executed; climate-risk exposure/perception OUT) [F32v2].
- Consolidated screening list (4-engine union): see Status `Update_Scoping`; pre-window completeness flags (Maaloul 2018; Kleimeier & Viehs 2016/18; Caragnano 2020) → PRISMA documentation, not corpus reopening.

---

## Addendum A — v12 / DEC-031-family supersessions (2026-07-12, ships with the T0.4 commit)

This addendum supersedes the affected statements above. Where a section conflicts with this addendum, **the addendum governs**; full authority remains with the DECISION_LOG entries cited.

**A.1 Data (supersedes §1).** Canonical input: `data/CER-COD_data_v12.xlsx` [DEC-042]. Corpus 2,852 rows · 120 studies · 119 cluster_ids. Usable ES 2,730; **effective estimation set 2,713** (− 1 duplicate tag − 16 no-n rows) over **115 studies / 114 clusters**; five studies drop fully at the estimation filter (Johnson 2020; Kumar & Firoz 2018; Ould Daoud Ellili 2020; Piechocka-Kałużna et al. 2021; Polbennikov et al. 2016) [DEC-042a]. Sample-size basis = column E (n_obs if numeric, else n_firms × window-years; 297 proxy rows incl. 134 FLAG-based) [R-16b/R-19, DEC-042a]. All quantities re-derived mechanically in `output/design_quantities_v12.csv` (T0.4, verifier v2 28/28).

**A.2 Inference unit (supersedes `cluster = study` snippets in §§3–8).** All nesting and CR2 clustering on **cluster_id** (`~1 | cluster_id/study/esid`) [DEC-031 D31.1]. `cluster_study` spec removed [DEC-031a.3].

**A.3 Paris coding (clarifies §6).** Headline binary = `pp_mid_lag0` (mid ≥ 2015.5 ⟺ post-share ≥ 0.5, ties→Post); `pp_share_lag0` is the **continuous** dose regressor (≡ share_2016) [DEC-031a.9]. Transfer rule NOT triggered: design df(pp_mid) = 31.9 [T0.4]. Pre-registered conditional upgrades both **fired** [DEC-031a.5; T0.4]: clean-window comparison carries full inference (df = 12.3 ≥ 5); 3PSM + p-uniform* run in the pre/post bias split (post cell 31 ≥ 20 studies). Eight ES from two studies (Bhattacharya & Sharma 2019; Ng & Rezaee 2012) have unrecoverable sample windows — all window-derived Paris codings are NA; they remain in the estimation set and drop listwise from period/dose cells (T1/A3: pre + post = 2,705 ES; rule binds Block B ex ante) [DEC-042b].

**A.4 Moderators (supersedes §7 architecture).** Two-stage per DEC-031 D31.5 / DEC-031a.1: Stage 1 univariate panels for the narrative set (CER_measure, COD_instrument, industry, regulation3, 4 country schemes); technical checks (q_VHB, field, ES_measure, es_method) live in the robustness catalogue; q_status = grey-literature panel in the bias block; corpus_segment removed (on-demand) [DEC-031a.2]. Stage 2 unified composition = Pending-D → DEC-043 (session after T0.4, before T7 stage 2).

**A.5 Robustness catalogue (supersedes §9 list).** Current spec set per DEC-031 Annex G + DEC-031a.4: adds `no_starbound`, `no_nobs_proxyfill`, `n_firms_variance`, `one_per_cluster_median`, `outlier_mad`, `trim_1_99`; removes `cluster_study`, `segment_original_only`, provenance specs (on-demand). Trim-and-fill, ±SD, SAMD excluded with citations.

**A.6 Null battery inputs (supersedes §13 placeholders).** All N-inputs fixed [DEC-031 Annex H]; N3 priors per **DEC-031b**: PSMA defaults (primary) + COE-companion-informed Normal(μ = −0.041 Fisher-z, σ = 0.021) + wide (σ = 0.042); Zarea-informed prior dropped. N15 within-study set on v12 = {Li et al. 2022} (73 studies span the break; 72 pool across it) [T0.4].

**A.7 Execution.** Canonical runs = Claude Code via Rscript **with paired verifier** (exit code; outputs committed); RStudio = interactive inspection (process decision, Setup tab, 2026-07-12). Prep = `R/00_prep.R` + `R/00_verify_prep.R` (v2, 28 checks) replacing the `R/01_prep.R` naming in §1.

**A.8 Prediction-interval convention (T1; F55 author ruling 2026-07-12).** All prediction intervals — overall and per period — are CR2-consistent: PI = b ± t(df_Satt) · sqrt(SE_CR2² + σ̂²_cluster + σ̂²_study + ω̂²_esid), i.e. the robust coefficient variance plus **all three** estimated variance components including the effect-level ω². Rationale (pinned): effect-level heterogeneity is real, and the PI is meant to show the plausible range of a single new effect, so omitting ω² would understate it; including all components is the conservative choice. Pre- and post-period PIs are constructed identically on their subset fits; no between-group test lives in A3 (that is B1's job) [DEC-031a.6]. Implementation: `R/01_core.R` (`pi_bounds`); verifier identity O7 (PI ⊇ CI) and O20 (A3 overall ≡ A1).

**A.9 T8 design-constant re-derivations (supersedes the §4 support/collinearity pins; 2026-07-15, ships with the T8 Gate-2 commit).** Per the DEC-031 a-priori-quantities clause (roles fixed, counts re-derive), three §4 quantities are superseded on v12 (mechanical, design columns only, result-blind): **(D1) dose support** — p95(share, ES level) = 1.0, not 0.6; share = 1 is populated by 318 ES / 13 clusters and share = 0 by 611 ES / 27 studies, so z̄(1) is relabeled from "extrapolative" to "marginal support with a joint (mid, share) caveat" (share = 1 implies mid ≥ 2016 while predictions evaluate at calendar 2015.5); the 0→0.6 contrast point is retained by role [DEC-024]. **(D2) collinearity** — corr(sample_mid, pp_share_lag0) = 0.8146, not 0.70; the disclosure sharpens, the architecture is unchanged. **(D3) placebo support** — study-level median sample_mid = 2013 (not 2012); 25 studies with study-level mid ≥ 2016 (not 8); smallest placebo cell = pre side at Y = 2008 with 13 clusters. Placebo recode rule and pinned cells: DEC-024a.

**A.10 Paris composition-control inference home + C3/C4 pre-trend guard (supersedes the §6 "reads from T7" sentence; extends A.4; 2026-07-15).** Composition-control inference for the Paris contrast reads from **B5/T8** (`composition_adj` and `trend_composition` per DEC-031d), not from T7; the T7 Stage-2 unified model remains governed by Pending-D → DEC-043. The C3/C4 univariate panels (Stage 1) gain **M-pre** as the sole pre-registered addition — the Move-5 pre-trend guard on the majority-pre domain (`zi ~ ts_knot × exposure` per exposure dimension; DEC-031c); the D31.5 interaction form itself is unchanged; fully interacted and stratum-segmented variants live in the on-demand register.

