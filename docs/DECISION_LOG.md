# CER–COD FOMA — Decision Log

**Purpose.** Append-only record of *reviewer-defensible methodological decisions* for the CER–COD meta-analysis (Corporate Environmental Responsibility → Cost of Debt; Paris Agreement as a temporal moderator). Companion to the Status workbook (`CER-COD_Status.xlsx` — current state) and the repo scripts (implementation).

**Convention.**
- Append-only. **Never renumber DEC-IDs.**
- Each entry uses the canonical **8-field schema**: Block · Question · Options considered · Chosen · Rationale · Reviewer-Risk · Consequences · Files.
- **Reviewer-Risk is split into two camps:** *Finance/Econometrics* (Stanley–Doucouliagos / meta-regression tradition) vs. *Management/BSE* (CSR–CFP / strategy tradition). Every decision is pre-defended from both.
- Setup/process conventions (tooling, repo, hand-off, verifier) live in the Status workbook **Setup** tab, **not** here.
- Source-pointer notation for cross-references: `[DEC-NNN]; [R/NN]; [<xlsx> Tab N]; [<md>]; [<ms> §X.Y]; [commit <hash>]`.

**Cross-references.** Status workbook (Roadmap themes #1–#16; Tasks T0.1–T8); repo `/R`, `/output`, `/manuscript`.

**Status.** DEC-001…009 promoted from provisional; DEC-010…013 added 2026-06-29 (Roadmap themes #6–#9); DEC-014…016 added 2026-06-30 (methodology re-review against the newly added PK methods papers; Roadmap themes #14–#16); DEC-017 added 2026-06-30 (within-study working correlation rho; operationalizes DEC-002, analysis plan §3); DEC-018 added 2026-06-30 (interim publication-year time axis, E8; superseded by sample year, Datenagenda #10); DEC-019…023 added 2026-07-03 (data finalization: n-definition, Pre/Post operationalization + headline-cut, DEC-018 superseded, country moderators, quality moderators). IDs now active. Language: English (feeds the English response-letter / methods); switchable to German on request.

---

## DEC-001: Retain the FOMA design with the Paris Agreement as a temporal moderator
**Block:** Phase 0 (architecture) · 2026-06-29
**Question:** Keep the existing first-order meta-analysis design (CER–COD with Paris pre/post moderation applied across all moderators), or restructure?
**Options considered:** (a) keep the design, reframe the language; (b) restructure around a continuous climate-policy-stringency moderator only; (c) abandon the Paris focus entirely.
**Chosen:** (a) — keep the FOMA design; Paris as a temporal *moderator* applied consistently across all moderator analyses.
**Rationale:** The design is published and viable. Zarea et al. (2026, *J. Econ. Asymmetries*) demonstrates the same CSR–finance relationship with the same Paris moderator in a finance journal. The weakness is implementation rigor, not the design concept.
**Reviewer-Risk:** *Finance/Econometrics* — will scrutinize identification (→ DEC-007/008) and dependence (→ DEC-002). *Management/BSE* — will scrutinize contribution/novelty (→ DEC-011).
**Consequences:** Anchors all subsequent tasks; commits to the moderator-across-the-board structure, which forces the architecture choice in DEC-009. Strategic framing (path A null/debunking vs. path C contingency) deferred — see Pending-C.
**Files:** `[<xlsx> Roadmap]`; all tasks.

---

## DEC-002: Dependence handling — 3LMA-RVE + unified meta-regression (one pipeline)
**Block:** Phase 0 · 2026-06-29
**Question:** How to handle the non-independence of 1,306 effect sizes nested in 66 studies (≈20/study; range 1–138)?
**Options considered:** (a) pool as independent + robustness only (status quo); (b) aggregate to one effect/study; (c) multilevel/correlated-effects working model + RVE-CR2; (d) (c) **plus** a unified meta-regression with interactions.
**Chosen:** (d) — 3LMA-RVE (multilevel/CE working model with cluster-robust CR2 + Satterthwaite df, clustered on `study`) as the headline, **and** a unified meta-regression with Paris×moderator interactions. Two views of one underlying framework.
**Rationale:** Pooling dependent effects as independent inflates precision — the draft's z = −19.5 and CI [−0.023, −0.018] are spurious. Every comparable paper models dependence: Zarea (3-level REML), Huang (cluster-robust + HLM), Malovaná (cluster-robust + BMA), Steel & House (MLLMA). **No recent comparable paper pools as independent**, so a literature defense of the status quo is unavailable; the reanalysis is load-bearing. The 1–138 effects/study imbalance makes the issue acute.
**Reviewer-Risk:** *Finance/Econometrics* — RVE/multilevel is the expected standard (Hedges–Tipton–Johnson 2010; Pustejovsky–Tipton). *Management/BSE* — Zarea is the in-domain benchmark that did exactly this.
**Consequences:** Resolves the I²=0 anomaly (#2) downstream via the variance decomposition (τ²_within/τ²_between); replaces the draft's Tables 2–8. Pre-execution diff-review applies (foundational script).
**Files:** `[R/NN_t1_main]; [R/NN_t7_unified]`; T1, T7.

---

## DEC-003: Headline role split — magnitude vs. identification
**Block:** Phase 0 · 2026-06-29
**Question:** Which model carries the headline result?
**Options considered:** (a) 3LMA-RVE pooled mean as headline; (b) meta-regression intercept as headline.
**Chosen:** 3LMA-RVE carries the headline **magnitude** (MA convention + direct Zarea comparability); the unified meta-regression carries the **identification** (break vs. secular trend), which a pooled mean cannot address. Both are reported.
**Rationale:** The two answer different questions. Magnitude needs the convention estimator (comparable to Zarea's r). The Paris "break vs. trend" question is only answerable in a regression frame (continuous time + dummy + interaction; → DEC-007). Therefore the meta-regression is not "mere robustness."
**Reviewer-Risk:** *Finance/Econometrics* — will want the identification frame foregrounded. *Management/BSE* — will want a single comparable headline number.
**Consequences:** Defines the reporting structure and the Key_Results digest.
**Files:** T1, T7, T8.

---

## DEC-004: Effect-size estimand — retain the bivariate+partial mix, disclose, robustness
**Block:** Phase 0/1 · 2026-06-29
**Question:** The dataset mixes bivariate (zero-order) and partial correlations as the effect size. Keep mixing?
**Options considered:** (a) keep mixing, disclose + cite supporting literature + robustness; (b) standardize on one estimand (all PCC, as Huang/Malovaná); (c) separate bivariate/partial throughout.
**Chosen:** (a) — keep, disclose in-text, cite supporting literature, run robustness.
**Rationale:** Data finding: only **36 of 1,306 (2.8%)** effects are partial; 97% are bivariate. The mix cannot drive the headline. Partial-only robustness is infeasible (too few effects/clusters); bivariate-only robustness (drop the 36) is trivial and expected to leave the headline essentially unchanged. Mixing is tolerated in this tradition (Zarea mixes via Peterson–Brown; Stanley–Doucouliagos normalize partial-correlation MA).
**Reviewer-Risk:** *Finance/Econometrics* — Huang/Malovaná use single-estimand PCC; the mix is the less-clean choice, mitigated by disclosure + bivariate-only sensitivity. **Note:** 97% zero-order correlations are largely *unconditional* (no control for size/leverage) → reinforces cautious causal language (→ DEC-006). *Management/BSE* — CSR–CFP MAs routinely use bivariate r.
**Consequences:** The r-from-regression conversion must be documented in-text (currently only "in the coding file" → feeds #11 / Pending-B); report per-type counts.
**Files:** T4; coding sheet.

---

## DEC-005: Event-coding — compute-then-select, headline designated a priori
**Block:** Phase 0 · 2026-06-29
**Question:** How to operationalize the Paris pre/post split?
**Options considered:** end-year (status quo); sample-midpoint (median / mean) at the 2015/16 threshold; continuous time; climate-policy-stringency moderator; each with/without lag variants.
**Chosen:** Compute all variants in **one driver** (long-format CSV with a `spec` column); **designate the headline specification a priori**, before inspecting which yields the most favourable result. The specific headline choice becomes its own DEC after T2 (→ Pending-A).
**Rationale:** End-year (status quo) is precisely the approach Zarea **explicitly rejects** as "temporal misclassification," adopting sample-midpoint instead and citing Feld et al. (2013), Geyer-Klingeberg et al. (2021), Tang & Buckley (2020). The dataset already contains midpoint codings (`median_lag0`, `mean_lag0`). A-priori headline designation forecloses the specification-search appearance that the current lag1–3 approach invites.
**Reviewer-Risk:** *Finance/Econometrics* — midpoint-at-threshold is the defensible primary; end-year is contestable. *Management/BSE* — the Zarea precedent legitimizes the moderator approach.
**Consequences:** Requires a continuous year variable for the trend-vs-break race (→ DEC-008 / T0.4). Headline choice deferred (Pending-A).
**Files:** `[R/NN_t2_eventcode]`; T2; coding sheet (year variables).

---

## DEC-006: Causal language — "temporal policy moderator"; redirect forcefulness to the debunking/contingency claim
**Block:** Phase 0 · 2026-06-29
**Question:** How to frame the Paris effect linguistically?
**Options considered:** (a) retain "structural break / exogenous policy-salience shock"; (b) soften to "temporal policy moderator."
**Chosen:** (b) — drop "structural break / exogenous shock"; frame Paris as a temporal policy moderator. Redirect rhetorical forcefulness onto the **defensible** claim (the prevailing narrative is overstated / the effect is contingent), not onto a discontinuity the design cannot support.
**Rationale:** A between-study split on observational, ~97%-zero-order correlations cannot support causal "structural break" language. No comparator (Zarea, Malovaná, Steel & House, the COVID cluster) claims a causal break from such a design; all use "regime shift / temporal moderation / changing over time." Even Zarea — which finds a *significant* Paris effect — stays at "temporal moderation."
**Reviewer-Risk:** *Finance/Econometrics* — over-claiming on identification is a classic rejection trigger; tempering pre-empts it. *Management/BSE* — a clear debunking/contingency contribution reads as a contribution, not a thin null.
**Consequences:** Title likely changes; intro/contribution reframed. Final framing (A vs. C) depends on the DEC-007 result (Pending-C).
**Files:** manuscript (title, intro, discussion).

---

## DEC-007: Identification — 7-move break-vs-trend toolkit
**Block:** Phase 0 · 2026-06-29
**Question:** How to defend the Paris claim against the secular-trend confound — a pre/post dummy cannot distinguish a discrete break from smooth drift?
**Options considered:** (a) rely on the dummy alone (status quo); (b) add explicit trend modeling + a battery of identification checks.
**Chosen:** (b) — a 7-move toolkit across 4 strength tiers: (1) trend-vs-break race; (2) segmented meta-regression / ITS; (3) placebo break-dates; (4) composition control; (5) differential-exposure (DiD-like); (6) within-study (gold standard); (7) Oster / E-value bounding.
**Rationale:** The data already exhibit the drift (pre-median r = −0.025 vs. post-median r = −0.019; baseline pre > post), and the comparator literature documents "time-lag bias" (Malovaná 2024; Astakhov et al. 2019). The only defensible strategy is to model the trend and require Paris to deliver *beyond* it. This battery **is** the A-vs-C decision mechanism.
**Reviewer-Risk:** *Finance/Econometrics* — the trend-vs-break race + placebo dates are exactly what a referee will demand; doing them pre-emptively is a strength. *Management/BSE* — frames the analysis as rigorous rather than as specification-search.
**Consequences:** Reframes lag1–3 from confirmatory diffusion (specification-search-flavored) to **falsification** (move 3 — is the break uniquely localized at 2015/16?). Moves 1–2 require continuous time (DEC-008); move 6 is infeasible (DEC-008).
**Files:** `[R/NN_t8_identif]`; T8.

---

## DEC-008: Within-study identification infeasible; identification rests on moves 1–5; continuous time required
**Block:** Phase 1 (data) · 2026-06-29
**Question:** Can the strongest identification anchor (within-study pre/post) be used, and what does the dataset support?
**Options considered:** n/a — data-determined finding plus the consequent restriction.
**Chosen:** Within-study identification (move 6) is **dropped** — only 1–3 of 66 studies span the Paris break (end-year: 1; midpoint: 3). Identification rests on moves 1–5 + bounding (move 7). Moves 1–2 require a **continuous year variable** that is **not** in the analysis file (only pre-binarized codings) → recover in T0.4.
**Rationale:** The Paris variable is almost entirely *between-study* (each study's effects share one sample period → one pre/post label), making the between-study confounding concern unavoidable and the within-study anchor unavailable. The continuous year exists upstream (the binaries were derived from it).
**Reviewer-Risk:** *Finance/Econometrics* — between-study identification is the core vulnerability; honest acknowledgment + moves 1–5 + bounding is the credible response. *Management/BSE* — n/a (technical).
**Consequences:** T0.4 is a **blocker** for T8 moves 1–2; pre-execution diff-review applies to T0.4.
**Files:** T0.4, T8; `[data/processed]`.

---

## DEC-009: Moderator×Paris — unified interaction, not nested subgroups
**Block:** Phase 0/1 · 2026-06-29
**Question:** How to test each moderator's Paris pre/post split given thin cells?
**Options considered:** (a) nested subgroup meta-analyses per moderator level × Paris (status-quo style); (b) a unified meta-regression with Paris×moderator interaction terms.
**Chosen:** (b) — interaction terms in the unified meta-regression; nested subgroups only where cluster counts permit.
**Rationale:** Data finding: most moderator×Paris cells fall below the RVE small-sample threshold (~≥10 clusters; Tipton 2015) — e.g., derivative pre-Paris = 1 study; bond yields = 8/8; sensitive industry = 6/6; carbon-pricing pre = 6. Nested subgroup RVE is unreliable there; the interaction model pools information jointly. It also fixes the old Model-10 multicollinearity (RVE + a parsimonious spec instead of all-lags-plus-three-time-controls, which produced SE = 0.568).
**Reviewer-Risk:** *Finance/Econometrics* — the joint interaction model is the rigorous route; thin-cell subgroup tables would be criticized. *Management/BSE* — interaction terms are standard in meta-regression.
**Consequences:** T6 subgroups quarantined to adequately-powered cells; T7 carries the moderator×Paris inference.
**Files:** T6, T7.

---

## DEC-010: Publication bias — apply the conditional PET-PEESE protocol consistently across all subgroups
**Block:** Phase 2 · 2026-06-29 · *(Roadmap #6)*
**Question:** How to report publication-bias correction, given the draft selectively reports PEESE and omits non-significant PET intercepts?
**Options considered:** (a) keep selective PEESE reporting (status quo); (b) apply the conditional PET-PEESE decision rule consistently across all subgroups and align claims to PET.
**Chosen:** (b) — where the PET intercept is non-significant, conclude *no effect beyond small-study/publication bias* and temper the corresponding subgroup claim; report PET and PEESE side by side for every subgroup.
**Rationale:** Under PET, several touted subgroups vanish — sensitive industry (PET = 0.001 n.s.) and no-carbon-pricing (PET = 0.004 n.s.); the draft celebrates these via PEESE and omits the null PETs. The overall PET (−0.009) is less than half the headline (−0.020). Stanley–Doucouliagos's conditional protocol governs this.
**Reviewer-Risk:** *Finance/Econometrics* — a Stanley-literate referee catches selective reporting immediately; this is a credibility issue. *Management/BSE* — less salient, but supports honest reporting.
**Consequences:** Tempers the industry / no-pricing claims; feeds the A-vs-C framing (fewer surviving subgroup effects → leans toward A).
**Files:** `[R/NN_t5_pubbias]`; T5.

---

## DEC-011: Novelty — cite and differentiate Zarea + Witte; reposition on the debt channel + decomposition
**Block:** Phase 0 · 2026-06-29 · *(Roadmap #7)*
**Question:** How to position novelty, given Zarea (2026) tests Paris in a CSR–finance MA and the companion Witte cost-of-equity paper overlaps?
**Options considered:** (a) claim "first to test Paris in a CSR–finance MA"; (b) reposition novelty on the debt channel specifically + channel decomposition (bank/bond/CDS/rating), citing and differentiating both.
**Chosen:** (b). The "first to test Paris" claim is **dead** (Zarea H5 tests pre/post-Paris and finds strengthening). Surviving novelty: the first meta-analytic synthesis of CER–cost-of-*debt* specifically, and the first to map channel heterogeneity (bank/bond/CDS/rating) — neither covered by Zarea (equity-performance, banking-only) nor by the companion COE paper.
**Rationale:** Zarea is published 2026 in a finance journal and tests Paris; not citing it — given the Witte-COE sibling and topic proximity — would be a serious gap and a self-overlap/desk-reject risk. Differentiation is on outcome (debt vs. equity-performance), scope (all sectors vs. banking), and the channel decomposition.
**Reviewer-Risk:** *Finance/Econometrics* **and** *Management/BSE* — an informed referee in this space knows Zarea/Witte; the differentiation must be explicit and defensible. Self-overlap with the accepted COE companion is a desk-reject risk if not handled.
**Consequences:** Intro/contribution rewritten; an explicit comparison table vs. Zarea may be warranted.
**Files:** manuscript (intro, contribution, discussion).

---

## DEC-012: Economic significance — translate r into basis points
**Block:** Phase 2 · 2026-06-29 · *(Roadmap #8)*
**Question:** How to treat economic significance, given the draft asserts "economically modest" without quantification?
**Options considered:** (a) keep the qualitative assertion; (b) translate r into bp of credit spread / cost-of-debt terms with an honest magnitude statement.
**Chosen:** (b) — provide an explicit economic-magnitude calculation (or a clear statement of why r is the wrong scale), acknowledging that r = −0.020 sits **below the paper's own "small" benchmark** (0.07; Doucouliagos 2011).
**Rationale:** BSE expects economic-magnitude treatment; "economically modest" repeated without numbers is a soft spot. The effect is ~5× smaller than Zarea's (0.11), so the magnitude question is acute. (Zarea also does not quantify in bp — a tradition-wide weakness — so doing it is a differentiator.)
**Reviewer-Risk:** *Management/BSE* — practical-implications referees want magnitude in decision terms. *Finance/Econometrics* — wants the estimand-to-economics mapping to be rigorous.
**Consequences:** Feeds the contingency/debunking framing (small magnitude is part of the story).
**Files:** manuscript (results/discussion); T1 output as input.

---

## DEC-013: Outliers — verify/correct the 2 extreme codings rather than winsorize all 1,306
**Block:** Phase 1/2 · 2026-06-29 · *(Roadmap #9)*
**Question:** How to handle extreme effect sizes, given winsorizing moves the headline ~45% and is driven by 2 near-perfect correlations?
**Options considered:** (a) winsorize at the 1/99 percentile (status quo); (b) verify/correct the 2 extreme codings at source + use a multilevel-native outlier diagnostic (studentized deleted residuals) + prominent sensitivity.
**Chosen:** (b). Drago et al. (r = −0.998, n = 184) and Devalle et al. (r = +0.9998, n = 56) are near-perfect correlations — almost certainly extraction/sign errors; verify at source. Replace blanket winsorizing with rstudent-based identification + drop-and-refit sensitivity, reported **prominently** (not buried). Also flag n < 10 / non-integer-n cases surfaced in T0.3.
**Rationale:** The winsorizing-driven headline shift is caused by literally 2 values; the clean fix is to verify them, not to trim 1,306 effects. (SOMA precedent: `rstudent.rma.mv` as the multilevel-native equivalent of ±3 SD / SAMD.)
**Reviewer-Risk:** *Finance/Econometrics* — a referee will ask why coding errors were not investigated; blanket winsorizing looks like hiding them. *Management/BSE* — n/a.
**Consequences:** Requires source verification in T0.4; sensitivity reported in T4.
**Files:** T0.4 (verification), T4 (sensitivity); coding sheet.

---

## DEC-014: Cluster-robust (CR2) inference for the FAT-PET-PEESE and all meta-regressions
**Block:** Phase 2 · 2026-06-30 · *(Roadmap #14; refines #6)*
**Question:** The publication-bias step (FAT-PET-PEESE) and any subgroup bias regressions are estimated by WLS on 1,306 effect sizes treated as independent. Are their standard errors valid, given the dependence already established in DEC-002?
**Options considered:** (a) keep conventional WLS standard errors for the bias regressions (status quo, as in the draft's Table 7); (b) estimate **every** weighted regression — including FAT-PET-PEESE — with cluster-robust variance (CR2 + Satterthwaite df), clustering on `study`.
**Chosen:** (b). Cluster-robust (CR2) inference is mandatory for every weighted regression in the pipeline, not only the headline mean (T1) and the unified meta-regression (T7, already RVE under DEC-002). This explicitly extends to T5 (FAT-PET-PEESE) and to any subgroup-level PET-PEESE.
**Rationale:** The dependence that invalidates the draft's pooled z (DEC-002) equally invalidates the SEs, t-statistics, and significance stars of the FAT-PET-PEESE table (draft Table 7): the WLS regression of z on SE(z) ignores the clustering of effects in 66 studies, so its uncertainty is understated and the PET/PEESE significance verdicts are not trustworthy as reported. The Stanley–Doucouliagos tradition that motivates PET-PEESE estimates it within a WLS frame, and in the economics-MA literature FAT-PET-PEESE is routinely study-clustered (Pustejovsky & Tipton, 2022; Stanley, Doucouliagos & Havranek, 2025). DEC-010 governs *what* is concluded from PET-PEESE (consistency, PET-alignment); DEC-014 governs *whether the SEs are valid at all*.
**Reviewer-Risk:** *Finance/Econometrics* — a Stanley-literate referee will immediately see that 1,306 dependent estimates are pooled as independent in the bias regression; uncorrected SEs are a hard methodological error here, not a nuance. *Management/BSE* — less salient, but consistent dependence handling reads as rigor.
**Consequences:** Tables 7 and 8 re-estimated with CR2; some PET/PEESE significance verdicts may shift (likely toward weaker), feeding the A-vs-C framing and DEC-010. The bias regression joins the same RVE pipeline as T1/T7.
**Files:** `[R/NN_t5_pubbias]; [R/NN_t7_unified]`; T5, T7; `clubSandwich`.

---

## DEC-015: Correlation small-sample bias — retain Fisher's z, add UWLS+3/HS robustness, report the n-distribution, adjust PCC degrees of freedom
**Block:** Phase 1/2 · 2026-06-30 · *(Roadmap #15; refines #1, #5)*
**Question:** Recent work shows inverse-variance-weighted meta-analysis of correlations is biased because the SE of r is a mechanical function of r, and that Fisher's z reduces but does not eliminate the residual small-sample bias. Given that **37.4% of the 1,306 effects have n < 200** (median n = 289; 9 effects with non-integer n < 10), is the draft's Fisher-z random-effects-IVW headline adequate, and how are the 36 partial correlations to be treated?
**Options considered:** (a) keep Fisher-z RE-IVW as the headline with no small-sample treatment (status quo); (b) retain Fisher's z, justify the WLS/RVE headline (DEC-002) explicitly on the correlation-bias literature, add a less-biased estimator (UWLS+3 and/or Hunter–Schmidt) as a robustness `spec`, report the n-distribution, and treat the 36 PCCs with covariate-adjusted Fisher-z df plus a bivariate-only sensitivity.
**Chosen:** (b).
**Rationale:** Stanley, Doucouliagos, Maier & Bartoš (2024, *Psychological Methods*) and Stanley, Doucouliagos & Havranek (2025, *Research Synthesis Methods*) demonstrate that fixed- and random-effects IVW of correlations and of Fisher's z carry small-sample bias (n < 200) from the r↔SE relationship, and that UWLS+3 and HS are less biased whether or not selection is present. The draft already uses Fisher's z (the correct first mitigation), so the headline critique does **not** bite — but with 37% of effects under n < 200 and a headline of only r = −0.020, the residual bias is non-negligible in proportional terms. The move to 3LMA-RVE (DEC-002) is itself a WLS/RVE estimator and thus already the right direction; the correlation-bias literature supplies a **second, independent** justification for it beyond dependence. For the 36 PCCs (2.8%), van Aert (2023) and Stanley, Doucouliagos & Havranek (2024, *RSM*, PCC) show Fisher-z transformation lowers bias/RMSE but the variance must use df = n − k − 3 (k = number of controls); given 2.8% of effects and median n = 289 the PCCs cannot move the headline, and a bivariate-only sensitivity (drop the 36) is the clean demonstration.
**Reviewer-Risk:** *Finance/Econometrics* — Stanley/Havranek-camp referees know the correlation-bias result; an unjustified RE-IVW headline and an undisclosed n-distribution are soft spots; UWLS+3/HS robustness pre-empts the demand. *Management/BSE* — low; the bivariate/partial disclosure is reassurance.
**Consequences:** n-distribution (median, IQR, share n < 200) reported in Methods; UWLS+3 and/or HS added as a robustness `spec` in T4; PCC df documented; bivariate-only `spec` in T4. Ties into DEC-002 and DEC-004.
**Files:** `[R/NN_t4_robust]`; T0.4 (n verification), T4; coding sheet.

---

## DEC-016: Add a selection-model secondary publication-bias check (3PSM / p-uniform*)
**Block:** Phase 2 · 2026-06-30 · *(Roadmap #16; refines #6; resolves the T5 "selection model" placeholder)*
**Question:** The draft's publication-bias evidence rests on a single method family (FAT-PET-PEESE). Is a triangulating selection-model check warranted, and is it feasible here?
**Options considered:** (a) PET-PEESE only (status quo); (b) PET-PEESE as primary **plus** a selection-model secondary (three-parameter selection model and/or p-uniform*); (c) add robust Bayesian MA (RoBMA) as a third.
**Chosen:** (b), with (c) optional. PET-PEESE remains primary (strongly supported by Stanley et al., 2025); a 3PSM and/or p-uniform* check is added at the study level.
**Rationale:** van Aert & van Assen (2026) show p-uniform* and 3PSM perform comparably and generally outperform p-uniform and the random-effects model under publication bias, and estimate the mean and between-study variance well with ≥ 10 studies (here k = 66). The project knowledge now holds three bias philosophies — PET-PEESE (Stanley), selection models (van Aert), and RoBMA (Bartoš et al., 2022) — so a referee preferring any one is likely; triangulation is the defensible posture. Stanley et al. (2025) simultaneously validate PET-PEESE as primary (it nearly eradicates selection bias and keeps type-I error nominal), so this is an addition, not a replacement. **Caveat:** selection models assume independence, so they are applied at the study level (one effect per study) or per adequately-powered subgroup — not on the 1,306 dependent effects.
**Reviewer-Risk:** *Finance/Econometrics* — comfortable with PET-PEESE primary; a selection-model robustness is expected best practice. *Management/BSE* — selection models are familiar from the CSR–CFP MA tradition; triangulation reads as thoroughness.
**Consequences:** T5 gains a secondary selection-model panel (study-level); convergence/divergence between PET-PEESE and the selection model feeds the overall bias narrative and the A-vs-C framing.
**Files:** `[R/NN_t5_pubbias]`; T5.

---

## DEC-017: Within-study working correlation for the CE/CHE covariance â rho = 0.6 (sensitivity 0.4/0.6/0.8)
**Block:** Phase 0 Â· 2026-06-30 Â· *(operationalizes DEC-002; analysis plan §3.1/§3.3)*
**Question:** The CE/CHE working model (DEC-002) needs an assumed within-study sampling correlation rho to build the block-diagonal covariance V; DEC-002 fixed the estimator but not rho.
**Options considered:** (a) leave rho implicit / accept package defaults; (b) fix rho = 0.6 with a sensitivity grid 0.4/0.6/0.8; (c) estimate rho (not feasible â within-study sampling correlations are essentially never reported in the primaries).
**Chosen:** (b). rho = 0.6 default; sensitivity at 0.4 / 0.6 / 0.8.
**Rationale:** Within-study sampling correlations are essentially never reported, so an assumed working value is unavoidable â this is standard for the CHE model (Pustejovsky & Tipton, 2022). Cluster-robust CR2 inference makes the point estimates robust to rho-misspecification, so the choice affects efficiency, not validity; 0.6 is the conventional default, and the 0.4/0.6/0.8 grid demonstrates the headline is insensitive. V is built with `clubSandwich::impute_covariance_matrix(vi, cluster = study, r = 0.6)`.
**Reviewer-Risk:** *Finance/Econometrics* â an assumed rho plus a sensitivity grid is expected and accepted; CR2 is the defence. *Management/BSE* â minor; the sensitivity table is reassurance.
**Consequences:** V at rho = 0.6 for all 3LMA-RVE and meta-regression estimates; a rho-sensitivity row (`spec = "rho_0.4" | "rho_0.8"`) in T4.
**Files:** `[R/NN_t1_main]; [R/NN_t4_robust]`; T1, T4; `docs/analysis_plan.md §3`.

---

## DEC-018: Continuous time axis — interim publication year (pub_year), superseded by sample year
**Block:** Phase 0 · 2026-06-30 · *(implements E8; analysis_plan.md §4/§9; T0.4; Datenagenda #10)*
**Question:** The continuous-time identification (break vs. trend, DEC-007) needs a continuous time variable. The dataset has no year column — the `event_sample` columns are already dichotomised Pre/Post labels, so the sample year is not recoverable from the data. What continuous time axis is used?
**Options considered:** (a) wait for sample-period years from Volker's extraction sheet (identification-grade, but blocks §4/T8 until delivery); (b) parse publication year from the `study` strings as an interim axis (derivable now — all 66 studies resolve, 2010–2024 — but a proxy); (c) defer continuous-time identification entirely.
**Chosen:** (b), explicitly **provisional**. `pub_year` is parsed from `study`; the identification-grade sample year replaces it when Volker delivers.
**Rationale:** `pub_year` is derivable now for all 66 studies and is the conventional time axis in economics meta-regression trend tests. It is a proxy — publication lags the sample period — so it is retained as an *interim* axis, not the final one: the sample year (Datenagenda #10) supersedes it if/when Volker's sheet arrives. The raw uncentred `pub_year` is stored so T8 can recentre (likely on 2015 = Paris) without a re-prep; the effect-level centring produced in the prep (`pub_year_c`, mean 2018.54) is **not** locked. The binary headline split `post_paris` remains sample-based (end_lag0), so only the secular-trend control uses the publication clock.
**Reviewer-Risk:** *Finance/Econometrics* — publication year as the trend axis is standard in economics MA, but a referee may note it proxies the sample period; the sample-year refinement and the sample-based binary headline mitigate. *Management/BSE* — low.
**Consequences:** `pub_year` + provisional `pub_year_c` in the prepared dataset; continuous-time identification (§4, T8 Moves 1–2) runs on `pub_year` interim, flagged provisional; T8 recentres from raw `pub_year`; sample year tracked as Datenagenda #10.
**Files:** `[R/01_prep.R]`; T0.4, T8; `analysis_plan.md §4/§9`; Datenagenda #10.

---

## DEC-019: Sample-size base for inverse-variance weights — no_firms (headline)
**Block:** Data finalization · 2026-07-03 · *(E14; analysis_plan §2)*
**Question:** v4 provides two sample-size columns (`no_firms`, `no_firm-years`); which is the base for `vz = 1/(n − 3)`?
**Options considered:** (a) `no_firms`; (b) `no_firm-years`; (c) design-effect-adjusted between the two.
**Chosen:** (a) `no_firms` as headline; `no_firm-years` and study-level aggregation as robustness specs.
**Rationale:** Firm count is the conservative choice — firm-years overstates precision under within-firm clustering; it also matches the original plan's implicit n. The firm-years and study-level robustness bracket the sensitivity. Material choice (scales every variance); to be re-validated in methodology finalization.
**Reviewer-Risk:** *Finance/Econometrics* — the firms-vs-firm-years choice is consequential; the firm-years robustness + RVE clustering is the defence. *BSE* — low.
**Consequences:** `vz = 1/(no_firms − 3)`; firm-years + study-level as robustness (E14).
**Files:** `[R prep]`; `analysis_plan §2`; T1, T4.

---

## DEC-020: Pre/Post-Paris operationalization + headline-cut shift (supersedes DEC-005 end-headline)
**Block:** Data finalization · 2026-07-03 · *(headline-cut; clean-window S1; supersedes the end-based headline of DEC-005)*
**Question:** The sample-end headline (DEC-005) classifies 81 % of "Post" effects as *majority-pre-Paris* data (median post-Paris coverage 0.10) — a contamination artifact. How is the pre/post treatment operationalized?
**Options considered:** (a) `sample_end` binary (generous — over-assigns Post); (b) `sample_mid` binary (majority-of-window); (c) continuous `post_share` (treatment dose); (d) clean-window (drop the 685 straddlers).
**Chosen:** A full suite is built in v4 — continuous `post_share` (4 lag thresholds), binary mid/mean/end/start, median-split, tertile-split, `window_class`. **Headline recommendation: `pp_mid` (= post_share ≥ 0.5) or continuous `post_share`; `end` demoted to robustness.** The formal headline-cut decision is **deferred to methodology finalization (Fable-5)**.
**Rationale:** 52 % of windows straddle Paris; the end-cut's "Post" group is 81 % majority-pre data → the pre/post contrast is a cut artifact. Midpoint (majority-of-window) or the continuous dose is defensible; the clean-window test (578 clean_pre vs 43 clean_post) is the uncontaminated robustness. Note: with only start/end, **mean = median = midpoint** — report one, not three (illusory distinct cuts).
**Reviewer-Risk:** *Finance/BSE* — the straddling/contamination critique is the central design vulnerability; the operationalization suite + clean-window is the pre-emptive defence.
**Consequences:** headline = mid/continuous (pending Fable-5); `end` = robustness bound; `window_class` clean-window test; DEC-005 end-headline superseded.
**Files:** v4 `pp_*`, `post_share`, `window_class`; `analysis_plan §6`; T1, T4, T8.

---

## DEC-021: Continuous time axis — sample_mid (supersedes DEC-018 / pub_year)
**Block:** Data finalization · 2026-07-03 · *(supersedes DEC-018)*
**Question:** DEC-018 used publication year as the interim time axis pending sample years; v4 delivers `sample_start`/`sample_end`.
**Chosen:** `sample_mid` (window midpoint) = the continuous time axis for identification (T8); `pub_year` retired.
**Rationale:** Sample years are now available per effect → the identification-grade time axis exists; the `pub_year` publication-lag proxy is no longer needed. T8 Moves 1–2 unblocked. Datenagenda #10 resolved.
**Reviewer-Risk:** low — the sample-based time axis is the correct choice; `pub_year` was explicitly interim (DEC-018).
**Consequences:** T8 identification uses `sample_mid`; DEC-018/`pub_year` retired.
**Files:** v4 `sample_mid`; `analysis_plan §4`; T8; Datenagenda #10.

---

## DEC-022: Geographic / context moderators — region · development · culture · legal origin
**Block:** Data finalization · 2026-07-03 · *(E16–E21 + legal origin)*
**Question:** How are country-level moderators operationalized from the free-text `country` field (35 distinct strings, 88 constituent countries, ~25 % multi-country)?
**Options considered:** crude "any multi-country → mixed" vs. parse-homogeneous vs. dominant-country assignment.
**Chosen:** Four schemes via a documented lookup — **region** (US / Europe-geographic / Asia-Pacific incl. Oceania / NCE), **development** (IMF Advanced Economies), **culture** (DST Statistics-Denmark Western/Non-Western), **legal origin** (La Porta common/civil). **Parse-homogeneous rule:** a multi-country list → the shared category if homogeneous on that dimension, else **NCE (Not Classified Elsewhere)**. Dominant-country sensitivity **dropped** (no per-country sample composition in the data).
**Rationale:** Objective external standards (IMF / DST / La Porta) minimize arbitrariness and are reviewer-defensible; NCE is a clean residual (19–25 %); parse-homogeneous preserves signal (all-EU list → Europe, not mixed). Documented contested calls: SA/Israel → common; Poland/Hungary/Bulgaria/Romania → developing (IMF); developed-but-non-western Japan/Korea/Singapore (IMF×DST divergence, by design). Caveats: Asia-Pacific is China-dominated (315/421); Europe-region is thin (77).
**Reviewer-Risk:** *BSE* — geographic moderators are expected; the documented standards + auditable lookup are the defence; the `culture` (west) scheme is flagged exploratory.
**Consequences:** `country_region/_dev/_west/_legal` columns via `country_lookup` sheet; `country_lookup.csv` is the 88-country reference.
**Files:** v4 `country_*` + `country_lookup` sheet; `country_lookup.csv`; `analysis_plan §7`.

---

## DEC-023: Study-quality / context moderators — status · VHB · JIF · field (CIT dropped)
**Block:** Data finalization · 2026-07-03 · *(E15; CIT dropped)*
**Question:** How are study-quality tiers operationalized (v1's `journal_q` was dropped)?
**Chosen:** Publication status (published / working-paper), **VHB-JOURQUAL** ranking (high/low), **JIF** (high/low), **field** (fin·acc·econ / sustainability / management), via a study-level `source_lookup`. **CIT (citations/year) dropped.** VHB/JIF at current-year reference.
**Rationale:** `journal_q` replaced by richer, source-level tiers; the study-level lookup is the correct architecture. CIT dropped (collection burden outweighs marginal value). **Open item:** VHB/JIF are currently populated for the 536 working-paper rows — the assignment basis must be documented or those set to N/A (flagged, not yet resolved).
**Reviewer-Risk:** *BSE* — quality moderators and grey-literature inclusion are standard; the working-paper-VHB/JIF assignment needs an explicit, defensible basis.
**Consequences:** `q_status/VHB/JIF`, `field` columns via `source_lookup`; the three CIT analyses dropped from the plan.
**Files:** v4 `q_*`, `field` + `source_lookup` sheet; `analysis_plan §9`.

---

## Conditional / Pending DECs

These are reserved placeholders, promoted to full entries when resolved (per the SOMA convention).

- **Pending-A — Headline event-coding specification.** Designate the headline Paris coding (end / midpoint / continuous) after the T2 variant comparison. *Trigger:* T2 long-format results complete. *Parent:* DEC-005.
- **Pending-B — r-from-regression transform documentation.** Confirm the exact transform used (e.g., Peterson–Brown 2005) once the coding sheet is reviewed; becomes a full DEC if the transform is contestable. *Trigger:* coding-sheet review (T0.3/T0.4). *Feeds:* Roadmap #11.
- **Pending-C — Strategic framing: A (null/debunking) vs. C (contingency).** Resolve after the Tier-1 reanalysis (T1–T3) **and** the T8 identification battery. *Trigger:* T8 verdict (do industry / bank-Paris effects survive 3LMA-RVE **and** PET **and** the trend-vs-break race?). *Parents:* DEC-001, DEC-006, DEC-007.

---

## Non-DEC items (Status workbook tasks, not reviewer-defensible choices)

- **Roadmap #11 (PRISMA / reporting).** Document the conversion in-text, add PRISMA flow counts, inter-coder reliability, search date. Execution/compliance task; may spawn Pending-B if the transform is contestable.
- **Roadmap #12 (internal consistency / polish).** Fix the duplicate "H3" label, the degenerate PI = [0.000, 0.000], comma decimal separators in Model 10, the "tbd" abstract. Cleanup task.
