# Analysis Plan — CER–COD FOMA (Paris moderator)

**Status:** T0.1 deliverable. Canonical executable specification. Every per-block Claude-Code spec (T1, T4, T5, T7, T8) inherits from this document; deviations require a DEC.
**Language:** English (consistent with `DECISION_LOG.md`).
**Environment (confirmed):** R 4.6.1 · renv 1.2.3 · metafor 5.0.1 · clubSandwich 0.7.0 · `selmodel` present · `puniform` 0.2.8 installed. Deferred (E4): `RoBMA` + JAGS/Stan.
**Decision basis:** DEC-002, DEC-003, DEC-004, DEC-005, DEC-006, DEC-007, DEC-008, DEC-009, DEC-010, DEC-011, DEC-012, DEC-013, DEC-014, DEC-015, DEC-016, DEC-017; E1–E6.

---

## 1. Data

- Source: `FOMA_CERCOE_Data_v1.xlsx`, sheet `Tabelle1` (filename retains the COE-era label; content is COD).
- Unit: **1,306 effect sizes** in **66 studies** (effects/study: min 1, median 10, mean 19.8, max 138; Bauer & Hann 2010 alone = 138 = 10.6%).
- Key columns: `study`, `corr` (r), `sample` (n), `outcome`, event-coding columns (`event_sample end_lag0..3`, `median_lag0`, `mean_lag0`), `COD_measure`, `CER_measure`, `ES_measure` (B=1270 bivariate / P=36 partial), `industry`, `regulation_start`, `regulation_end`, `journal_q`.
- n-distribution (report in Methods, DEC-015): median 289, IQR ≈ [115, 599], **37.4% with n < 200**, 311 with n < 100, **9 with non-integer n < 10** (verify in T0.4).
- Extremes (verify at source, DEC-013): Devalle 2017 r = +0.9998 (n = 56); Drago 2018 r = −0.9977 (n = 184). Near-perfect CER–COD correlations are implausible → likely coding/extraction errors.

## 2. Effect-size metric [DEC-004, DEC-015, E5]

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

## 4. Identification — break vs. secular trend [DEC-003, DEC-007, DEC-008]

The pooled mean cannot separate a Paris *break* from a pre-existing *trend*; this lives in the meta-regression and the Identifikation toolkit (T8). Headline magnitude (§3) and identification (here) are reported as distinct results.

```r
m_id <- rma.mv(zi, V, mods = ~ year_c * post_paris,  # continuous time × dummy
               random = ~ 1 | study/esid, data = dat, sparse = TRUE)
Wald_test(m_id, constraints = constrain_zero("post_paris"),
          vcov = "CR2", cluster = dat$study)
```
- `year_c` = centred continuous study year (from T0.4 — **blocker**, not yet in data).
- Toolkit (Identifikation tab): trend-race · segmented MR · placebo · component checks. Move 6 is dead (1–3/66 studies overlap), DEC-008.

## 5. Cluster-robust inference everywhere [DEC-014]

**All** weighted regressions — pooled, subgroup, FAT-PET-PEESE, and the unified meta-regression — use CR2 clustered on `study`, never naive WLS. This is the single correction that makes the draft's Table 7/8 inference valid.

## 6. Pre/Post-Paris coding [DEC-005]

- Headline coding fixed **a priori**: end-of-window year split (`event_sample end_lag0`).
- Variants computed but not headline: median/mean window, lag1–3. Reported as a coding-sensitivity panel.

## 7. Unified meta-regression [DEC-002, DEC-009, DEC-014]

One model with Paris × moderator interactions instead of many nested subgroup splits (resolves the old Model-10 multicollinearity, SE(Zr)-SE = 0.568).

```r
m_uni <- rma.mv(zi, V,
                mods = ~ post_paris * (cod_instrument + industry + regulation)
                        + es_type + method_artefacts,
                random = ~ 1 | study/esid, data = dat, sparse = TRUE)
coef_test(m_uni, vcov = "CR2", cluster = dat$study)
```
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

## 9. Robustness `spec` catalogue [DEC-004, DEC-013, DEC-015; E1, E2, E5]

Single long-format CSV, `spec` column. Required specs:
`leave_one_out` · `outlier_rstudent` (drop |rstudent|>cutoff) · `winsor` / `unwinsor` · `one_effect_per_study` · `r_type` · `cer_type` · `journal_q` · `event_coding` · `paris_lag1..3` · **`uwls3`** [E2] · **`bivariate_only`** [E5] · **`rho_0.4` / `rho_0.8`** [E1].

- **UWLS+3 [E2, DEC-015]:** unrestricted WLS (FE estimator with multiplicative dispersion) with the +3 Fisher-z df adjustment of Stanley et al. (2025). Implementation per that paper's appendix (confirm the exact df constant against the source). Robustness only; HS deferred (E2).
- **Outliers [DEC-013]:** identify via `rstudent.rma.mv`; **verify Drago/Devalle at source**; no blanket winsorizing as the primary treatment.

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

## Open prerequisite (blocker, T0.4)

`year_c` (continuous study year, centred) is **not** in the data and blocks §4 / T8 Moves 1–2. Plus: regulation direction coding (0/1/9) unclear; non-integer n verification. T0.4 resolves these before T1 runs.

---

## Change log
- 2026-06-30 — created; operationalizes `[DEC-002..017]` (E1–E6). ρ = 0.6 working correlation fixed in DEC-017.
