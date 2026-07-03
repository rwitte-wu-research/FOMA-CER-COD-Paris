# Analysis Plan — CER–COD FOMA (Paris moderator)

**Status:** T0.1 deliverable. Canonical executable specification. Every per-block Claude-Code spec (T1, T4, T5, T7, T8) inherits from this document; deviations require a DEC.
**Language:** English (consistent with `DECISION_LOG.md`).
**Environment (confirmed):** R 4.6.1 · renv 1.2.3 · metafor 5.0.1 · clubSandwich 0.7.0 · `selmodel` present · `puniform` 0.2.8 installed. Deferred (E4): `RoBMA` + JAGS/Stan.
**Decision basis:** DEC-002, DEC-003, DEC-004, DEC-005, DEC-006, DEC-007, DEC-008, DEC-009, DEC-010, DEC-011, DEC-012, DEC-013, DEC-014, DEC-015, DEC-016, DEC-017, DEC-018, DEC-019, DEC-020, DEC-021, DEC-022, DEC-023, DEC-024, DEC-025, DEC-026, DEC-027; E1–E6, E8, E14–E23.

---

## 1. Data

- Source: **`CERCOD_data_v8.xlsx`** (final; sheets `data` + `country_lookup` + `source_lookup` incl. `note` audit trail and `reference_verified`). Lineage: v5 exact window midpoints (half-year resolution) + end-axis lags; v6 quality recode [DEC-025]; v7 publication-status correction [DEC-026]; v8 full 66-row source audit. The effect-size core (`corr`, both n columns, `ES_measure`, window years) is byte-identical v4→v8 (verified).
- Cached-column caveat: `pp_start_lag0` encodes start ≥ 2017 (stale). The R prep re-derives **all** `pp_*` columns from raw years (rules in §6); cached formulas are never trusted.
- Unit: **1,306 effect sizes** in **66 studies** (effects/study: min 1, median 10, mean 19.8, max 138; Bauer & Hann 2010 alone = 138 = 10.6%).
- Key columns: `study`, `corr` (r), `no_firms` / `n_obs` (see §2), `ES_measure` (B = 1,270 / P = 36), `sample_start/end/mid`, continuous dose `sample_post share_2016..2019`, binary `pp_share_lag0..3` (NB: binary despite the name), `pp_mid_lag0` ≡ `pp_median_lag0`, `pp_end_lag0..3`, `pp_window_class`, `COD_instrument`, `CER_measure`, `industry`, `regulation_*`, `country_*`, `q_status`, `q_VHB`, `field`.
- n-distribution (report in Methods, DEC-015): median 289, IQR ≈ [115, 599], 37.4% with n < 200, **9 integer rows with n < 10** (corrigendum of the earlier "non-integer" descriptor; rounding lives in `calc_rounded`; derivation rule no_firms = round(n_obs/T) — DEC-027).
- Extremes [DEC-013, closed 2026-07-03]: Devalle 2017 r = +0.9998 (n = 56) and Drago 2018 r = −0.9977 (n = 184) **verified at source and confirmed**; retained; influence carried by rstudent identification, LOSO, and the winsor sensitivity (§9).

## 2. Effect-size metric [DEC-004, DEC-015, E5]

- **Sample size [DEC-019, DEC-027]:** headline `n = no_firms`; `vz = 1/(no_firms − 3)`. Robustness: **`n_obs`** (reported estimation-sample observations; upper-precision bound — unit-heterogeneous: 81 effects in 3 studies are sub-annual/loan-level) and study-level aggregation [E14].
- Metric: **Fisher's z** throughout; back-transform the meta-analytic estimate to r for reporting only.
  `zi = atanh(ri)`; bivariate variance `vz = 1/(n − 3)`.
- Mixed estimand: retain bivariate + partial (2.8% partial); disclose. Bivariate-only sensitivity (`spec = "bivariate_only"`, drop the 36 P) is the clean demonstration [E5].
- **PCC degrees of freedom [E5]:** the number of controls `k` is **not** coded in the dataset. Use the **n − 3 approximation** for the 36 PCCs (instead of n − k − 3), with a footnote that bias is negligible at 2.8% (median n = 289); the bivariate-only `spec` carries the robustness. Re-coding `k` from Volker's extraction sheet only if trivial (as-executed layer).

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
                        + es_type + method_artefacts,
                random = ~ 1 | study/esid, data = dat, sparse = TRUE)
coef_test(m_uni, vcov = "CR2", cluster = dat$study)
```
- **Moderator inventory [DEC-022, DEC-025]:** CER type · COD instrument · industry · regulation (ETS/CT) · country {region, development (IMF), culture (DST), legal (La Porta)}, parse-homogeneous → NCE residual · quality [DEC-025, DEC-026]: `q_status` (published 999/60 vs WP 307/6; sole grey-literature moderator) + `q_VHB` via reference-cell coding of {pub-high 813/41, pub-low 186/19 (ref), WP} — WP rows retained; univariate VHB panels on the published subsample; `q_JIF` retired (raw in `source_lookup`). `country_*` via `country_lookup`; `q_*`/`field` via `source_lookup`. Dominant-country sensitivity dropped (E21); CIT dropped (DEC-023). `method_artefacts` operationalization pending (Datenagenda #3; couples to Pending-B/V5).
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
`leave_one_out` (incl. explicit post-cell LOSO) · `outlier_rstudent` · `winsor` / `unwinsor` · `one_effect_per_study` · `r_type` · `cer_type` · `journal_q` (VHB, published subsample) · `status_as_extracted` [DEC-026] · `n_obs` [E14/DEC-027] · `event_coding` = {tie_break, end_any_exposure, share_lags_main, end_lags_appendix, clean_window, share_quadratic} [DEC-024] · **`uwls3`** [E2] · **`bivariate_only`** [E5] · **`rho_0.4` / `rho_0.8`** [E1].

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

## Open items (non-blocking)

**All Step-1 items resolved (DEC-024–027; Pending-A closed).** Remaining, non-blocking: Volker batch — reported-vs-derived n flag (V4/DEC-027); r-transform documentation + PCC k (V5 → Pending-B; also operationalizes `method_artefacts`, Datenagenda #3); PRISMA basics (V6); lookup care per DEC-026 (Shad/Lemma years, Li duplicate row, `reference_verified` header + 7 blanks); F16 Sharfman & Fernando (2008) exclusion rationale.

---

## Change log
- 2026-06-30 — created; operationalizes `[DEC-002..017]` (E1–E6). ρ = 0.6 working correlation fixed in DEC-017.
- 2026-06-30 (b) — `[DEC-018]` (E8): interim publication-year time axis, §4/§9; data-path fix in §1 (`data/CER-COD_data_v1.xlsx`).
- 2026-07-03 — data finalization `[DEC-019..023]` (E14–E23): source → `CER-COD_data_v4.xlsx`; n = `no_firms` (§2); Pre/Post suite + headline shift end→mid/continuous (§6); `sample_mid` time axis, DEC-018 retired (§4); country {region/dev/culture/legal} + quality {status/VHB/JIF/field} moderators (§7); CIT dropped. Headline-cut + VHB/JIF-WP basis open for methodology finalization.
- 2026-07-03 (b) — Step-1 finalization `[DEC-024..027]`: source → `CERCOD_data_v8.xlsx`; §§1/2/4/6/7/9 replaced; Pending-A resolved; `q_JIF` retired; E14 → `n_obs`; DEC-013 closed (extremes verified); Datenagenda #11 closed (COE overlap 5/66, 42 effects, disjoint estimands).
