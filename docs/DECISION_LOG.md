# CER–COD FOMA — Decision Log

**Purpose.** Append-only record of *reviewer-defensible methodological decisions* for the CER–COD meta-analysis (Corporate Environmental Responsibility → Cost of Debt; Paris Agreement as a temporal moderator). Companion to the Status workbook (`CER-COD_Status.xlsx` — current state) and the repo scripts (implementation).

**Convention.**
- Append-only. **Never renumber DEC-IDs.**
- Each entry uses the canonical **8-field schema**: Block · Question · Options considered · Chosen · Rationale · Reviewer-Risk · Consequences · Files.
- **Reviewer-Risk is split into two camps:** *Finance/Econometrics* (Stanley–Doucouliagos / meta-regression tradition) vs. *Management/BSE* (CSR–CFP / strategy tradition). Every decision is pre-defended from both.
- Setup/process conventions (tooling, repo, hand-off, verifier) live in the Status workbook **Setup** tab, **not** here.
- Source-pointer notation for cross-references: `[DEC-NNN]; [R/NN]; [<xlsx> Tab N]; [<md>]; [<ms> §X.Y]; [commit <hash>]`.

**Cross-references.** Status workbook (Roadmap themes #1–#16; Tasks T0.1–T8); repo `/R`, `/output`, `/manuscript`.

**Status.** DEC-001…009 promoted from provisional; DEC-010…013 added 2026-06-29 (Roadmap themes #6–#9); DEC-014…016 added 2026-06-30 (methodology re-review against the newly added PK methods papers; Roadmap themes #14–#16); DEC-017 added 2026-06-30 (within-study working correlation rho; operationalizes DEC-002, analysis plan §3); DEC-018 added 2026-06-30 (interim publication-year time axis, E8; superseded by sample year, Datenagenda #10); DEC-019…023 added 2026-07-03 (data finalization: n-definition, Pre/Post operationalization + headline-cut, DEC-018 superseded, country moderators, quality moderators). IDs now active. DEC-024…027 added 2026-07-03 (methodology finalization, Step 1): headline Paris cut + inference-transfer rule (DEC-024, resolves Pending-A); quality moderators consolidated, q_JIF retired (DEC-025); publication-status correction + version policy (DEC-026); n-definition validated + E14 relabel (DEC-027). Same date: DEC-013 verification arm closed — Devalle (+0.9998) and Drago (−0.9977) confirmed at source; retained; influence carried by rstudent/LOSO/winsor sensitivity. DEC-020 corrigendum recorded in DEC-024. Datenagenda #11 closed: COE-companion corpus overlap = 5/66 studies (Chava 2014; Chen & Gao 2011; Li et al. 2014; Shad; Lemma), 42/1,306 effects (3.2%), zero shared effect sizes (both papers' extraction rules enforce disjoint estimands). Data basis: CER-COD_data_v8.xlsx. DEC-028/029 added 2026-07-04: data documentation closure (v10 canonical; Pending-B resolved; ES-type correction — 36 bivariate direct-r / 1,270 converted PCCs; df ≈ n_obs convention with pcc_df_k sensitivity) and the a-priori null-robustness battery (all N1–N15 adopted; DEC-008 partially reopened for the descriptive within-study display). Language: English (feeds the English response-letter / methods); switchable to German on request.

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

## DEC-024: Headline Paris cut = pp_share_lag0 (binary, ties→Post); dose promoted to identification; pre-registered inference-transfer rule (resolves Pending-A; finalizes DEC-020; corrigendum to DEC-020)
**Block:** Methodology finalization (Step 1) · 2026-07-03
**Question:** DEC-020 built the Pre/Post operationalization suite but deferred the headline cut (mid/continuous vs. end). Which specification carries the headline, what are the roles of the remaining variants, and what guards the choice if the post cell proves inferentially thin?
**Options considered:** (a) pp_end binary; (b) binary majority-of-window; (c) continuous post_share as headline; (d) hard flip rule; (e) (b) + pre-registered inference-transfer.
**Chosen:** (e). Headline = **pp_share_lag0** (post_share ≥ 0.5, ties→Post; v8: 138 effects / 11 studies). Suite roles fixed a priori:
- Tie-break sensitivity: pp_mid_lag0 ≡ pp_median_lag0 (ties→Pre; 136 / 9) — one row. Precedent note: Zarea et al. (2026) use the midpoint rule but *exclude* windows that defy strict assignment; our convention differs (ties→Post), affects exactly 2 single-effect studies (Hachenberg & Schiereck 2015–16; Kordschia 2014–17; share = 0.5), both variants reported — divergence disclosed.
- Continuous post_share → **identification** (T8, DEC-007 Move 5): model `zi ~ sample_mid_c + post_share`; report model-implied z̄(0)/z̄(0.6)/z̄(1), the 0→0.6 in-support contrast (p95 of share = 0.6), quadratic-in-share check; z̄(1) flagged extrapolative.
- pp_end_lag0 re-labelled **"any post-Paris exposure" bound** (end ≥ 2016 ⇔ share > 0; 728 / 40). Corrigendum to DEC-020: "median post-coverage 0.10" is the full-sample median; within the end-Post cell it is 0.333 (mean 0.36); the 81.0% (590/728) majority-pre figure stands (straddle share 52.4%).
- Lag panels, placement a priori: share-axis lag1–3 (55/5 · 26/2; lag2 ≡ lag3) = main-text coding sensitivity — the cell collapse is itself the finding (post-Paris evidence is young); end-axis lag1–3 (562/31 · 506/24 · 252/14) = appendix.
- Clean-window (clean_pre 578/27 vs clean_post 43/4) = descriptive bound; estimate + CI + df, no p-values (Satterthwaite df < 4–5; Tipton & Pustejovsky 2015).
- Localization = placebo break-years on sample_mid; support lies pre-2015 (study-level median sample_mid = 2012; 8 studies ≥ 2016).
**Inference-transfer rule (pre-registered):** The T2 verifier computes CR2/Satterthwaite df of the Paris coefficient in the headline moderation model from design quantities only (X, W, V from n and ρ; no outcomes). df ≥ 5 → the binary carries full inference. df < 4–5 → the binary remains the descriptive headline display (estimate + CI + df; no p-value, per T&P's validity floor) and the inferential Paris claim — abstract language and the A-vs-C input — transfers to the post_share model (T8). Divergence between the two is reported, not adjudicated post hoc. Expected df ≈ 8–12; the rule is insurance.
**Rationale:** (1) End-cut disqualified under both target framings: its mislabeling attenuates mechanically — a null is "manufactured by dilution" (framing A) and biased against contingency (framing C). (2) Binary vs. continuous adjudicated on three criteria: communicable precedent-comparable Pre/Post magnitude (Zarea midpoint; COE companion), DEC-003 role separation (the dose is interpretable only next to the trend, corr(sample_mid, post_share) = 0.70 → belongs in T8), result-blind designation. On observed support the dose's honest 0→0.6 contrast ≈ 0.6·slope ≈ the binary contrast; the estimand advantage of (c) is extrapolative. (3) Attenuation disclosed as a design constant: group-mean shares 0.728 vs 0.138 → the binary recovers ≈ 0.59 of the full 0→1 regime contrast (implied full contrast ≈ binary/0.59; direction conservative). (4) Tie-break: v5+ stores exact midpoints (v4 rounded up), so share-rule and mid-rule diverge only at share = 0.5; ties→Post keeps 11 post clusters, ties→Pre yields 9 — below the ~10-cluster RVE threshold (Tipton 2015, per DEC-009). Cluster counts are design, not outcomes. (5) Designated now on design columns only, superseding Pending-A's "after T2" (which would carry specification-search appearance, contra DEC-005); T2 becomes a sensitivity panel. Not admitted into this rationale: observed effect-size contrasts; any "0% contamination" framing for the mid cell (its median within-cell share is 0.60).
**Reviewer-Risk:** *Finance/Econometrics* — 11 post clusters at the small-sample boundary: per-coefficient df reported; transfer rule pre-registered; knife-edge mass disclosed (96 effects, share ∈ [0.40, 0.60)); trend confound met in T8 (race + placebo). Composition conceded: post cell is Asia-Pacific-heavy (84/138 effects from 4 Chinese studies), bond-yield 58%, CER-performance 98.6%, shorter windows (median 5 vs 10 yrs), larger n (median 799 vs 225 firms) — Paris inference reads from T7 (composition controls) + T8, never the raw subgroup table; LOSO on the post cell mandatory (Tan = 36%; top-3 = 72%). *Management/BSE* — one communicable r_pre vs r_post headline; the four-role suite pre-empts the arbitrary-cut critique.
**Consequences:** Data source = CER-COD_data_v8.xlsx. analysis_plan §§1/4/6/9 replaced. Prep re-derives all pp_* from raw years: pp_start rule = start ≥ 2016 (v8 cache is stale at ≥ 2017); verifier asserts pp_start ≡ clean_post ≡ (share = 1), pp_mid ≡ pp_median, lag2 ≡ lag3 (share axis), end ⇔ share > 0, sample_median ≡ sample_mid (drop one). Naming hazard: pp_share_lag0..3 are binary; the continuous dose lives in `sample_post share_2016..2019`. pp_median/pp_tertial splits (boundaries 2012 / 2014, pre-Paris) → T8 trend toolkit, not Paris codings. Methods carries one panel-drift caveat (post years contribute more observations than their calendar share).
**Files:** v8 `pp_*`, `sample_post share_*`, `sample_mid`; `analysis_plan §§1/4/6/9`; T1, T2, T7, T8; `R/01_prep.R` + verifier.

---

## DEC-025: Source-quality moderators = q_status + q_VHB (published-only tiers); q_JIF retired (finalizes the DEC-023 open item)
**Block:** Methodology finalization (Step 1) · 2026-07-03 · *(supersedes DEC-023 in part)*
**Question:** DEC-023 left open how VHB/JIF are treated for working-paper rows. Audit reframed the item: nothing was assigned — raw lookup values are "-"/NaN; the moderator coding folded WPs asymmetrically (VHB → 0_low; JIF → 99_NA), contaminating univariate quality panels and creating collinearity in the planned §7 double entry (corr(q_status, JIF_NA) = 0.918, pre-correction basis).
**Options considered:** (a) keep the asymmetric fold; (b) symmetric NA + JIF as an E15 robustness swap; (c) q_status + q_VHB only; q_JIF removed from the analysis.
**Chosen:** (c).
- **q_status** — published vs. not published; post-DEC-026 state: published 999 effects / 60 studies; WP 307 / 6 (23.5% of effects). Sole grey-literature moderator; bridges the T5 publication-bias narrative.
- **q_VHB** — defined for published sources only: high {A+, A, B} = 813 effects / 41 studies vs. low/unranked = 186 / 19. Model entry via reference-cell coding of {pub-high, pub-low (ref), WP}: q_status + q_VHB_high; WP rows retained (NOT dropped); univariate/subgroup VHB panels run on the published subsample only.
- **q_JIF** — retired analytically; raw JIF retained in source_lookup (audit trail).
**Rationale:** (1) Asymmetry defect; (2) univariate contamination; (3) §7 collinearity, as quantified. (4) JIF is not redundant with VHB — study-level concordance 68.2% — but the discordance is one-sided (12 of 14 cases VHB-high ↔ JIF-low) and exposes the dichotomization's fragility: Management Science (A+; Chava, 22 effects), Eichholtz (36), Fonseka (39), Hoepner (19) land "JIF low" — classifications a referee would attack; the ranking tier needs no numeric threshold. (5) Nine published studies lack a JIF (second NA level). Residual condition resolved: the accepted COE companion uses no JIF moderator (verified in the uploaded companion) → no appendix swap; deletion final.
**Reviewer-Risk:** *Finance/Econometrics* — status moderator = expected best practice; "why not impact factor?" answered by threshold-fragility evidence + raw JIFs on file. *Management/BSE* — VHB tiers familiar; measure choice disclosed.
**Consequences:** Prep: q_VHB display for WP rows = 99_NA; codebook documents the reference-cell mapping; verifier: no WP row carries a tier; m_uni retains all 1,306 rows; VHB panels published-only. Disclosure: WP = 23.5% of effects; Bauer & Hann alone = 45% of WP effects (138; then Seltzer 72, Chava 50); LOSO covers concentration. Changelog note: Hamrouni et al. (2019a) tier resolved ("prüfen" placeholder → Management Decision = B = high; 2 effects) — data correction, no DEC.
**Files:** v8 `q_status`, `q_VHB` (`q_JIF` retired; raw in `source_lookup`); `analysis_plan §7, §9`; T7; `R/01_prep.R` + verifier.

---

## DEC-026: Publication-status correction (7 studies) + version-of-record policy + full source audit
**Block:** Data finalization · 2026-07-03
**Question:** A verification pass found 7 of 13 "not published" sources published — one (Schneider → Contemporary Accounting Research 2011) already at initial coding. How are status, tiers, extraction versions, and the lookup corrected?
**Options considered:** (a) leave as-extracted status; (b) flip status + full re-extraction from versions of record; (c) flip status + triage; keep as-coded effect sizes; documented field semantics; full lookup audit.
**Chosen:** (c).
- Status corrected **as of 2026-07-03**: Kölbel (96 effects), Delis (73), Ferriani (21), Bannier (16), Schneider (10), Okimoto & Takaoka (10), Chen & Gao (3) → 0_published (229 effects / 7 studies). Remaining WP: Bauer & Hann, Chava 2010, Christ, Nemoto & Liu, Seltzer, Sze (307 / 6).
- **Version policy:** effect sizes remain from the versions retrieved at search; Methods states: "effect sizes were extracted from the versions retrieved at search; publication status reflects 2026-07-03." Triage executed: no material deviations in sample period, outcome specification, or N between coded and journal versions → no re-extraction; effect base final. Robustness spec `status_as_extracted` (the 7 coded back to WP) demonstrates moderator insensitivity to the correction.
- VHB/field re-coded for the 7 under the documented rule (Kölbel A; Schneider A; Bannier/Delis/Ferriani/Okimoto B → high; Chen & Gao unlisted → low).
- **Full 66-row lookup audit** executed (Schneider proves initial-coding errors exist; sampling insufficient at desk-reject stakes): no further analytic errors; audit remarks in `note`.
- **Field semantics fixed:** `journal` + `publication year` = version **as coded** (Schneider therefore keeps SSRN/2010 there); verified version-of-record citation in `reference_verified` (headerless column to be named; 59/66 filled — clarify the 7 blanks); Kölbel title change ("Ask BERT …") documented for future matching. Study-key strings unchanged (join/LOSO stability).
**Reviewer-Risk:** *Finance/Econometrics + BSE* — a referee spotting a CAR paper coded "unpublished" reads it as sloppiness; correction + dated status + as-coded policy + sensitivity spec is the defensible package. Grey-literature share drops 41.0% → 23.5%, strengthening the corpus-quality profile without touching a single effect size.
**Consequences:** DEC-025 counts reflect this decision. `status_as_extracted` added to §9. Pending lookup care (non-blocking, Volker batch): Shad as-coded year (key 2022 vs ESPR 2020), Lemma year convention (2017 online-first vs BSE 28(1) 2019 → reference_verified), duplicate Li lookup rows (2021 WP + 2022 VoR) → consolidate; verifier gains a bidirectional data.source ⟷ lookup.source anti-join check. PRISMA one-liner (F16): document the exclusion rationale for Sharfman & Fernando (2008), which sits in the COE corpus and reports COD results.
**Files:** v7 (status/VHB), v8 (audit); `source_lookup` (`note`, `reference_verified`); codebook; `analysis_plan §9`; Methods.

---

## DEC-027: n-definition documentation + E14 robustness relabel (validates DEC-019)
**Block:** Methodology finalization (Step 1) · 2026-07-03
**Question:** DEC-019 (headline n = no_firms; marked material) required re-validation.
**Options considered:** n/a — validation with two documentation-level findings.
**Chosen:** DEC-019 **confirmed**. no_firms is the only unit-consistent n in the dataset and the conservative bound; under CR2, weights are working weights (misspecification costs efficiency, not validity; Hedges et al. 2010) — the same defence structure as ρ (DEC-017). Additions:
- **Derivation rule documented:** no_firms = round(n_obs / window years) where not directly reported — arithmetically consistent for 85.1% of rows, including all nine n < 10 rows (Chodnicka 2; Fard 4: 154/25 → 6; Schneider 3: 66/11 → 6). Conceptually the average annual cross-section (sensible under unbalanced panels); reported-vs-derived flag per row = Volker item (deferred, non-blocking).
- **E14 spec relabelled `n_obs`** (reported estimation-sample observations; upper-precision bound): the former "firm-years" column mixes units — 81 effects in 3 studies exceed firms × window (Delis 73, loan-level, ratio ≈ 88 at ≤ 10 yrs; Hui 7; Schneider 1). Ratio distribution: median 9.0, IQR [5.4, 12.0], p95 48, max 154.
- Consistency verified: firms = n_obs in 27 rows / 4 studies — all window length 1 (pure cross-sections); firms > n_obs: none.
- Plan §1 corrigendum: "9 non-integer n < 10" → "9 integer rows with n < 10" (rounding lives in `calc_rounded`).
- Bracket is real: naive inverse-variance top-study share 36.9% (Seltzer, n to 11,112) under firms vs 13.0% under n_obs; corr(log weights) = 0.82 → E14 is a genuine sensitivity. Study-weight shares are reported from the RVE model, never naive.
**Reviewer-Risk:** *Finance/Econometrics* — "why firms, not the reported N?": within-firm dependence overstates precision; conservative headline + n_obs bracket + CR2. "Your n is imputed for small studies": documented rule, per-row flag, nine visible rows with ≈ 0 weight, n-distribution disclosed (DEC-015). *BSE* — low.
**Consequences:** `analysis_plan §§1/2/9` edits; vz = 1/(no_firms − 3) unchanged; `n_obs` + study-level aggregation remain the E14 specs.
**Files:** v8 n columns; `analysis_plan §§1/2/9`; T1, T2, T4; codebook.

---

## DEC-028: Data documentation closure (v9/v10) — conversion formulas, source flags, ES-type correction; Pending-B resolved
**Block:** Data finalization · 2026-07-04
**Question:** Volker's batch (v9: lookup care a–e incl. Sharfman rationale [F16]; V4 n-source flags; V5 conversion-formula sheet) plus author fixes (v10) — what closes, which conventions are set, and what does the new `ES_source` column change?
**Options considered:** (a) accept as delivered; (b) accept + correct the ES-type label inversion + fix conventions; (c) additionally re-code k for converted PCCs.
**Chosen:** (b); (c) rejected [F21].
- Canonical source → **CER-COD_data_v10.xlsx** (data 45 cols; new sheets `notes`, `formula`; lookup 65 rows — Li orphan removed; bidirectional source anti-join 0/0). Value-preserving renames verified (max |Δ| = 0 vs v8): `corr` → `ES (corr_coeff)`; `…calc_rounded` → `…_rounded`.
- **V5 / Pending-B resolved:** `formula` sheet documents four routes (direct r; t/√(t²+df); (b/SE)→t; TINV(p, df)); `ES_source` counts: 36 direct r · 634 t · 570 b+SE · 66 p.
- **ES-type correction [F20]:** v9's `ES_measure` labels were inverted; v10 fixes them — **bivariate = 36 direct-r effects (23 studies, 2.8%)**, **partial = 1,270 converted PCCs (97.2%)**. E5 reinterpreted as `direct_r_only` (36/23 — a viable cluster count, not merely descriptive).
- **df convention [F21]:** conversions use df ≈ `n_obs` (not n − k − 1); k is not coded and will not be collected. Disclosed approximation (relative attenuation ≈ k/(2·n_obs); negligible at median n_obs ≈ 2,910; anchor van Aert 2023) + sensitivity `pcc_df_k10`/`pcc_df_k20`: invert t from (r, n_obs), recompute r with df = n_obs − {10, 20}. Sampling variance remains 1/(no_firms − 3) [DEC-019/027] regardless.
- **method_artefacts operationalized:** §7 uses the single 4-level factor `ES_source` (reference = t-route), replacing the `es_type` + `method_artefacts` placeholders; **Datenagenda #3 closed**. The `r_type` spec is superseded by `direct_r_only`.
- **V4 flags authoritative:** `no_firms_source` coded 593 / calculated 713 (54.6%); `no_firm-years_source` 408/898. Supersedes DEC-027's 85.1% arithmetic bound (440 coded rows coincide with the rule; 42 calculated rows follow other routes). Closes the DEC-027 per-row-flag item.
- **Li key rename** `Li et al (2021)` → `Li et al (2022)` (4 effects; same paper, version-of-record identity): conscious, pre-analysis deviation from DEC-026 key stability; joins re-verified in v10.
- **Shad cross-note [F22]:** our verified year 2022 (reference column) vs. the COE companion's 2020 citation of the same ESPR article — disclosed in the overlap/cover-letter table, not adjudicated.
- Cosmetics: the verified-reference column header remains `source_verfified` (sic); codebook maps it to DEC-026's `reference_verified`. `notes`/`formula` sheets stay header-less (documentation sheets; folded into the codebook).
**Reviewer-Risk:** *Finance/Econometrics* — the transparent conversion table is a strength; the df approximation is bounded by an explicit sensitivity; the 4-level artefact factor pre-empts "conversions drive results". *Management/BSE* — low.
**Consequences:** analysis_plan §§1/2/7/9 updated; prep maps legacy column names; verifier adds: ES_measure × ES_source diagonality, source-flag presence, anti-join 0/0, and a formula spot-check (recompute 20 random conversions from the documented routes).
**Files:** v10 (`data`, `source_lookup`, `notes`, `formula`); `analysis_plan §§1/2/7/9`; codebook; Datenagenda #3/#14/#15/#17.

---

## DEC-029: Null-robustness battery designated a priori — all N1–N15 adopted (partially reopens DEC-008 Move 6 as a descriptive display)
**Block:** Methodology extension (pre-T1) · 2026-07-04
**Question:** The paper's core claim is an informative null on the Paris moderator. Which pre-designated analyses guard it against the four attack lines — (A) chance/power, (B) specification choice, (C) time-form, (D) wrong benchmark?
**Options considered:** (a) main-text core subset; (b) full battery N1–N15 with a-priori placements and conditional rules.
**Chosen:** (b) — all fifteen (Status tab `Null_Battery`, decision column GO 2026-07-04). Placements: main text — N1 TOST, N2 design-only MDE simulation, N3 BF/RoBMA (compact), N4 prediction intervals, N5 multiverse/specification curve (anchor figure), N6 sup-break + N7 permutation inference (shared machinery; p_perm next to p_CR2), N8 Zarea transplantation, N10 cumulative MA (time graphic), N12 external-difference test (one sentence); appendix — N9 HS (+WAAP), N11 rolling window, N14 pre/post publication-bias split; conditional — N13 p-curve with the pre-set rule: run only if ≥ 5 significant study-level p-values exist in the post cell, otherwise reported as infeasible (the rule itself is the a-priori commitment). **N15 within-study display: DEC-008 Move 6 consciously reopened for a descriptive-only purpose** (3 mixed studies; point + spread; no inference) — justified by the new strategic objective; the original "dead for identification" verdict stands.
**A-priori inputs to fix before T1 (battery-prep step):** SESOI dual anchor [F18: Zarea-extracted post effect + |Δr| = 0.05 convention — extraction pending]; RoBMA priors (default + Zarea-informed); multiverse factor space; sup-break year grid + permutation scheme and B; rolling-window width/step; p-curve per-study selection rule; τ²/ω² grid for the MDE simulation (COE-companion values + conservative grid). N2 is design-only and joins the T2 verifier.
**Paper acquisitions (PK):** Lakens 2017/2018 (TOST); Simonsohn, Simmons & Nelson 2020 (specification curve); Stanley, Doucouliagos & Ioannidis 2017 (WAAP); optional Steegen et al. 2016 (multiverse).
**Rationale:** Coverage of the attack lines, not analysis count, is the currency; designation now — before T1, result-blind — preserves DEC-005 discipline and immunizes against the sought-null optic (Ioannidis 2016). Claim discipline: N1/N3 adjudicate between "evidence of absence" and "absence of evidence" language and feed Pending-C (A-vs-C).
**Reviewer-Risk:** *Finance/Econometrics* — battery framed as a pre-registered program; each piece carries its small-cell disclosure (post cell = 11 studies throughout). *Management/BSE* — specification-curve and cumulative-MA figures are the communicable core.
**Consequences:** analysis_plan §13 (new) + §9 additions; Status `Null_Battery` decision column filled; **T1 gate extended: battery inputs fixed first**; response-letter skeleton gains the A–D structure.
**Files:** Status `Null_Battery`; `analysis_plan §§9/13`; DEC-008 (partial reopen note); Pending-C linkage.

---

## DEC-030: Formal PRISMA search update decided (rule-based, pre-T1); CER-construct gate codified; AI-assisted scoping documented (renumbering note: battery-input fixation moves to DEC-031)
**Block:** Corpus governance · 2026-07-04
**Question:** The original search ran effectively 2021/22; submission targets 2026. Is a search update required, and under which rules is it defensible given that the post-Paris cell is the paper's binding constraint?
**Options considered:** (a) no update (justify staleness); (b) targeted post-Paris supplementation; (c) full rule-based PRISMA update, identical criteria, all-that-qualifies.
**Chosen:** (c). (a) fails recency expectations for a 2026 submission in a fast-growing field — precisely where the central claim sits; (b) is selection on the moderator and would manufacture bias (red line, documented).
- **Process (Volker):** identical search strings and inclusion/exclusion criteria; same 10 databases (WoS Core, Scopus, EconLit, BSC/EBSCO, ABI/INFORM, ScienceDirect, Wiley, SpringerLink, SSRN, NBER) + Google Scholar snowballing; end date = execution date; two-stage PRISMA flow (original + update reported separately); ALL qualifying studies included regardless of period; extraction into the existing sheet → **CER-COD_data_v11**; verification per the established V2 pattern.
- **Gate codification [F32/F32v2]:** Environmental performance includes carbon/GHG-based measures (emissions, intensity, carbon-risk and carbon-management scores, environmental violations/penalties, environmental disclosure incl. CDP/TCFD), consistent with the original coding (e.g., Palea & Drogo 2020; Maaloul & Wegener 2021; Zhu & Zhao 2022; Jung et al. 2016). **Excluded** are climate-risk exposure or perception measures (textual/earnings-call exposure, physical-risk exposure, policy- or event-exposure, industry fossil status, market-implied risk factors) that do not measure the firm's own environmental conduct.
- **AI-assisted supplementary scoping (documented, not a substitute for the DB re-run):** four independent deep-search engines (Claude DR, ChatGPT DR, Perplexity base + agent) under an identical prompt with anti-hallucination rules and recall benchmarks (Owolabi 2024; Al-Fakir 2023; Ehlers 2022 — 3/3 in all four runs). Consolidated union: **~41 published + ~10 WP in-window narrow-E candidates**, 11 construct-check cases, ~15 excluded per gate, 3 pre-window completeness flags (Maaloul 2018; Kleimeier & Viehs 2016/18; Caragnano et al. 2020), ~11 Round-2 (ESG-composite) previews. Engine-error protocol retained: one venue hallucination corrected at source (Seltzer remains WP per SSRN/NBER/FRBNY, July 2026), one fragment mis-mapped onto a corpus study (Sze), metadata garbles resolved by cross-engine majority + record priority.
- **Round-2 (composite ESG/CSR constructs)** follows with the identical prompt frame; the update is criteria-complete only after both rounds (the corpus contains composite-ESG studies).
**Rationale:** (1) recency compliance is unavoidable for 2026; (2) doing it now — before T1, result-blind — is the last moment at which the update cannot be read as outcome-driven; (3) all design RULES (DEC-024 coding, DEC-029 battery, SESOI per F27v2) are data-independent and unchanged; only design quantities (cell sizes, df, grids) are re-derived mechanically after v11; (4) the post-cell relief (plausibly 11 → 15+ clusters) is a by-product of the rule, not a selection criterion.
**Reviewer-Risk:** *Finance/Econometrics* — "search 2021/22, submitted 2026" is pre-empted; the two-stage PRISMA plus the documented AI-supplementary layer exceeds current reporting practice. *Management/BSE* — three BSE in-window candidates (Ali 2023; Cicchini 2026; Wang & Wijethilake 2026) double as journal-fit evidence.
**Consequences:** Numbering: **battery-input fixation becomes DEC-031** (after v11), keeping the log chronological; prior chat references to "DEC-030 = battery inputs" are superseded. Status tab `Update_Scoping` rebuilt as the consolidated screening list (verdict classes P1/P1-WP/B/D/E/F28/R2); Datenagenda #18/#19 opened (Volker DB re-run; author downloads). analysis_plan source remains v10 until v11 lands; §1/§9 untouched. T1 gate: v11 → DEC-031 → prep.
**Files:** `Update_Scoping` (Status); DECISION_LOG; analysis_plan (open items + changelog); Volker package; v11 (pending).

---

## DEC-032: AI-assisted extraction with role inversion adopted for the search-update corpus; extraction codebook v1 frozen (F34a–f); blind-pilot gate before production
**Block:** Corpus governance / extraction · 2026-07-05
**Question:** Who extracts the ~51-candidate search-update corpus, and under which codified rules, given capacity constraints and the established dual-control principle (extraction vs. verification)?
**Options:** (a) Volker manual extraction as before; (b) AI-assisted extraction (Claude) with inverted roles — Claude extracts, Volker verifies; (c) uncontrolled AI extraction.
**Chosen:** (b). (a) is a capacity bottleneck at ~51 candidates plus DB-run yield; (c) breaks dual control.
- **Codebook v1 (frozen, committed as docs/extraction_codebook_v1.md):** reverse-engineered from four calibration papers (Shad 2022; Oikonomou 2014; Lemma 2017; Eliwa 2021) whose 13 v10 effects were reproduced **cell-exactly**, incl. the transformation chain (df = n_obs, per DEC-028) and the two-sided sign logic. Author rulings F34a–f codified: (a) stand-alone environmental constructs only, composites never qualify; (b) all-models rule — every qualifying CER main effect from every regression model contributes a row (dependency handled by 3LMA-RVE); (c) two-step sign procedure — extraction as-reported + direction metadata, harmonization downstream (target: positive r = higher CER ↔ higher COD); (d) Lemma CR rows parked as possible erratum (author background check, non-blocking); (e) distinct subsamples = distinct rows; (f) Pearson-only bivariates. Interaction terms excluded forward (R2.7); legacy row 836 under review.
- **Process:** one paper per chat (or Cowork batch run) under the frozen production prompt (docs/extraction_prompt.md); RAW values + provenance (table/model/page/cell quote) + extraction log; staging CSV (docs/extraction_staging_template.csv) — never direct writes into the data file; merge into v11 via prep with verifier.
- **Gate:** blind pilot on ≥2 corpus papers not used in calibration; concordance target ≥95% on statistical core fields vs. v10; production starts only after PASS. **Verification:** Volker checks 100% of statistical core fields of all production extractions against the PDFs (role inversion preserves dual control).
- **Methods disclosure (EN, for the manuscript):** "Effect sizes from studies identified in the search update were extracted with AI assistance (Claude, Anthropic) under a pre-specified extraction codebook; a blind pilot against double-coded studies from the original corpus yielded [X]% field-level agreement, and all statistical fields were independently verified against the source documents by one author."
**Reviewer-Risk:** *Finance/Econometrics* — extraction reliability: answered by the concordance statistic, cell-level provenance, and 100% human verification. *Management/BSE* — transparency of AI use: answered by the disclosure sentence and the committed, versioned codebook (exceeds typical reporting practice).
**Consequences:** codebook/prompt/template committed and mirrored into the dedicated extraction project's knowledge; production extraction feeds staging → v11; DEC-031 (battery-input fixation) remains scheduled post-v11; Datenagenda #20 (pilot) and #21 (production + verification) opened.
**Files:** docs/extraction_codebook_v1.md · docs/extraction_prompt.md · docs/extraction_staging_template.csv · DECISION_LOG · Status (index, Datenagenda).

---

## DEC-033: Full-corpus harmonization re-extraction under codebook v1.1 (Option C); Capelle-Blancard excluded at harmonization stage (unit of analysis); triage-based verification protocol
**Block:** Corpus governance / extraction · 2026-07-05
**Question:** After the blind pilot (PASS, 0 extractor errors; 3 v10 errata incl. one pathological effect r=+0.9998; extraction-density gap in 2 of 4 studies), should the legacy corpus be (A) kept as-is with a segment dummy, (B) audit-re-extracted with v10 remaining canonical on exact matches, or (C) fully re-extracted so that one procedure produces the entire dataset?
**Chosen:** **(C)** — full-corpus re-extraction via Cowork under codebook v1.1; the new extraction is the canonical basis for v11.
- **Verification protocol (the condition that makes C affordable):** the legacy v10 human coding serves as an independent double-coding on the overlap. Field-level machine diff of new vs v10: **exact agreement = mutually verified** (no further human check); disagreements and rows without a v10 counterpart → **Volker adjudicates against the source PDF**. The F35 erratum list (a–f, incl. Devalle row 409, Atif regulation/CER_measure, Capelle firm count) is folded into this adjudication. Without this triage rule, C would cost weeks; with it, C ≈ B in workload with a cleaner lineage and a textbook double-coding design for the Methods section.
- **Capelle-Blancard et al (2019): excluded** at harmonization stage — unit of analysis is the sovereign, not the firm (country-level ESG indices → sovereign bond spreads); fails the firm-level construct gate (R2.1/F36h). Rule-based, result-blind, pre-T1. Corpus: 66 → 65 studies; 1,306 → 1,305 legacy effects before re-extraction. PRISMA documentation as harmonization-stage exclusion; drop-one sensitivity note retained for transparency.
- **Scope:** all 65 legacy papers + all screened-in update candidates in one Cowork batch (one paper per run; staging_<study>.csv + log_<study>.md; run manifest). The four pilot extractions are reusable (Yilmaz regulation fields re-coded per F36b at staging); the four calibration papers are re-extracted uniformly in the batch.
- **Design invariants:** result-blind (pre-T1, no analysis has run); inclusion/membership untouched except the documented Capelle rule-exclusion; segment flag (original vs update screening vintage) retained as robustness moderator; all design quantities (DEC-024 cells, grids, df) re-derived mechanically on v11; DEC-031 (battery-input fixation) follows v11.
- **Methods disclosure (EN, updated):** "All effect sizes were extracted under a pre-specified, versioned codebook with AI assistance (Claude, Anthropic). For the original corpus this constitutes an independent re-extraction; field-level agreement with the original human coding was [X]%, disagreements were adjudicated against the source documents, and all statistical fields of newly added studies were verified by one author."
**Reviewer-Risk:** *Finance/Econometrics* — extraction reliability and comparability across corpus segments: answered by one uniform procedure, the double-coding agreement statistic, and cell-level provenance for every row. *Management/BSE* — transparency of AI use and of the sovereign exclusion: answered by the disclosure sentence, the committed codebook, and the PRISMA harmonization note.
**Consequences:** production batch covers the full corpus; v11 is a single-procedure dataset; Datenagenda #21 rewritten, #22 folded into adjudication, #23 (Capelle documentation) opened; DEC-031 remains scheduled post-v11.
**Files:** docs/extraction_codebook_v1_1.md · extraction_project_instructions.md (pin v1.1) · docs/pilot_concordance_report.md · DECISION_LOG · Status.

---

## DEC-034: Six supplementary extraction fields adopted (codebook v1.2) — copy-level, purpose-tagged, result-blind; pilot stagings invalidated for batch uniformity
**Block:** Corpus governance / extraction · 2026-07-05
**Question:** Before the full-corpus Cowork batch starts, should additional fields be collected while the marginal cost is ~zero (every table is read anyway), and which candidates survive the filter (objective copy-level; named pre-specified purpose; architecture untouched)?
**Chosen:** Six fields adopted; the temptation list beyond them rejected (mechanism/theory coding — judgement field; DV transformation — irrelevant for PCC; primary-study winsorizing — log note suffices; journal/author traits — lookup side; anything implying a new analysis strand). Construct-/outcome-granularity needs NO new fields — post-codable ex post from the verbatim labels + provenance already collected.
- **Per effect:** `x_lag` (reviewer-predictable robustness cut; pilot: Oikonomou t−1 lived only in the log) · `estimation_method` (MAER-NET reporting; identification cut — the most predictable Finance-referee request) · `se_clustering` (SE-quality heterogeneity of t-values; known PCC-meta flank) · `subsample_dimension` + `subsample_value` (structures the existing free-text note → mechanical composition disclosures) · `subsample_start`/`subsample_end` (effect-level windows; feeds N15 within-study contrasts and the dose axis).
- **Per study:** `n_obs_by_year` (verbatim, only if an observations-per-year table exists) → enables WEIGHTED post-share/dose variants instead of the uniform-within-window assumption.
- **Architecture guard:** headline definitions remain exactly as logged (DEC-024: study-window pp_share, ties→Post). Effect-window and weighted-share variants are **pre-registered secondary specifications**; x_lag/method/clustering are **documented reserves** (analyzed only per plan or in referee response). Purpose tags per field are recorded here as the defense against any field-fishing reading.
- **Clarification memorialized (author exchange):** fields #1/#4/#6 were assumed to be already collected per row; factually #4 existed only as free-text trace (subsample_note), #1 and #6 not at all — v1.2 makes all three machine-readable.
- **Uniformity rule:** the four pilot staging files (Atif, Capelle-Blancard, Devalle, Yilmaz) are deleted from staging\ before the full batch, so the resume rule re-runs them and every paper is extracted under v1.2.
**Reviewer-Risk:** *Finance/Econometrics* — identification/SE heterogeneity questions get data-backed answers instead of prose. *Management/BSE* — no scope creep: six copy-level fields, each with a named purpose, none altering the locked design.
**Consequences:** codebook v1.2 + template v1.2 + instructions pin committed and swapped into the extraction project's knowledge; DEC-031 (battery inputs) unchanged, post-v11.
**Files:** docs/extraction_codebook_v1_2.md · docs/extraction_staging_template.csv · docs/extraction_project_instructions.md · DECISION_LOG · Status.

---

## DEC-035: Mid-batch construct-gate rulings codified (F38, F39a–f); codebook v1.3→v1.4 under pin discipline; mandated re-extractions; two further harmonization-stage exclusions
**Block:** Corpus governance / extraction · 2026-07-06
**Question:** The full-corpus batch surfaced construct-gate collisions between codebook v1.2 and the as-executed corpus, plus five log-flagged rule questions. How are they ruled, and how is mid-batch rule evolution kept defensible?
**Rulings (author, 2026-07-06):**
- **F38 — Delis stays; gate amended (v1.3):** firm-level fossil-fuel reserves qualify as embedded/potential-emissions CONDUCT. Boundary formula codified: *quantified firm-level carbon stocks and flows (emissions, intensity, reserves) = conduct; classifications, sector-membership dummies, and perceptions = exposure; country-level quantities mechanically allocated to firms remain excluded.* Delis re-extracted under v1.3: 0 → 32 main-effect rows (interactions logged as near-misses per R2.7); price-valued vs. proved reserve variants (4 rows) → adjudication [F39c].
- **F39a — Fard et al (2020) exits** at harmonization stage: X = country-level environmental-policy stringency — exposure side of the F38 boundary, no conduct reading. Legacy impact: −46 effects; corpus 64 → **63** studies (after Capelle). Documented as rule-based, result-blind, pre-T1; PRISMA harmonization note + drop-one sensitivity note.
- **F39b — KLD/MSCI-type rating subdimensions of strengths/concerns type, incl. climate-change concern indicators, are performance-assessment CONDUCT** (Oikonomou precedent: concerns = bad-CER conduct) → codified in v1.4. Consequence asymmetry: **missing rows ⇒ re-run** (Bauer & Hann re-extraction mandated; staging invalidated), **flagged rows ⇒ adjudication** (Chava 2010/2014 rows already captured with FLAGs).
- **F39d** — duplicate keys / version drift (Fonseka 2019a/b; Du "2017"↔2015; Chen 2021↔2020; Christ n.d.↔2022; Chen & Gao n.d.↔2011) → crosswalk/alias table (Claude), author/Volker confirm at adjudication. **F39e** — Eichholtz building/loan-level unit → adjudication. **F39f** — v1.3 status-line inconsistency (header v1.3 / status v1.2): fixed in v1.4.
**Version-evolution defense (reviewer-facing):** tranche 1 ran v1.2, tranche 2 v1.3, tranche 3+ v1.4 — all deltas are ADDITIVE construct-gate clarifications affecting named constructs only; every affected legacy paper is either re-extracted under the current version (Delis, Bauer & Hann) or FLAG-resolved at adjudication (Chava). Papers untouched by the deltas extract identically under all three versions; per-paper logs record the governing codebook version; the version pin in the project instructions enforces the active edition. The final dataset is therefore single-rule-set equivalent.
**Reviewer-Risk:** *Finance/Econometrics* — "rules changed mid-extraction": answered by the pin discipline, delta-targeted re-runs, and log-level version traceability. *Management/BSE* — two further study exclusions (Fard; after Capelle): answered by the rule-based, result-blind timing and the boundary formula that also disciplines the UPDATE side (Trinh, Demetriades, Ginglinger remain out on identical grounds).
**Consequences:** governing rule text committed to the repo WHILE governing (this package: v1.3, v1.4, instructions pin, .gitignore); Update_Scoping: Cumming reclassified D (outcome = leverage; no COD DV); Datenagenda #24 (Fard exclusion documentation) opened; DEC-036 reserved for adjudication outcomes + v11 assembly.
**Files:** docs/extraction_codebook_v1_3.md · docs/extraction_codebook_v1_4.md · docs/extraction_project_instructions.md · DECISION_LOG · Status.

---

## DEC-036: Five construct micro-rulings codified (F40 a–e; codebook v1.5) — all additive, adjudication-resolved for completed papers, no re-extractions required
**Block:** Corpus governance / extraction · 2026-07-06
**Rulings (author):** (a) dichotomized/median-split dummies of the firm's OWN quantified measures = conduct transformation, not external classification (Ho & Wong case); (b) carbon-risk-awareness operationalized via the firm's own CDP response behavior = disclosure conduct (Jung); (c) Heckman-type selection-corrected outcome equations with non-instrumented CER qualify (Kleimeier & Viehs; extends the Al-Fakir precedent); (d) generalized-ordered-logit threshold equations: full-scale rating outcome qualifies, all threshold-specific coefficients extracted and tagged `rating-class` (Kim & Kim); (e) energy-/resource-consumption-based measures = quantified firm-level flows → conduct regardless of author labels (Kim & Kim).
**Handling:** all four case papers were extracted with included+FLAGged rows → rulings resolve at adjudication; no re-runs. Codified in v1.5 because the a/e constructs recur in the remaining ~56 papers — prevents the next Bauer&Hann/Chava-type divergence. Version-evolution defense of DEC-035 extends unchanged (additive deltas; pin discipline; log-level version traceability).
**Consequences:** v1.5 + instructions pin swapped (PK, project settings, rules\) and committed while governing; DEC-037 reserved for adjudication outcomes + v11 assembly.
**Files:** docs/extraction_codebook_v1_5.md · docs/extraction_project_instructions.md · DECISION_LOG · Status.

---

## DEC-037: F41 rulings codified (v1.6) — Kölbel stays via disclosure-channel boundary (re-extraction mandated); system-estimator line corrects the reviewer's own narrower proposal; Maaloul source identity resolved (lookup erratum)
**Block:** Corpus governance / extraction · 2026-07-06
**Rulings (author):**
- **F41a — Kölbel stays (96 legacy effects):** climate-related disclosure CONTENT measures from the firm's OWN reporting instruments (10-K/annual, CDP, TCFD, sustainability reports) — incl. risk-disclosure content scores — are disclosure CONDUCT. Boundary: textual measures from conversational/indirect sources (earnings-call transcripts, media) remain EXPOSURE → the update-side exclusions (Trinh, Lu, Cang & Li, Hrazdil) are untouched. Kölbel re-extraction mandated (0 → rows under v1.6). Residual softness acknowledged: the channel line is formal; the reviewer's alternative (adoption/quality vs. disclosed-risk magnitude) would have excluded Kölbel — both positions logged, author ruling governs.
- **F41d — system estimators:** the author's ruling ("rein") is the CONSISTENT one — the calibration precedent (Lemma 3SLS, cell-exact reproduced) already includes system-instrumented CER coefficients; the reviewer's narrower fitted-out proposal would have contradicted as-executed practice. Codified line: external-instrument IV/2SLS CER = excluded (Al-Fakir/Ali-2023 exclusions unaffected); 3SLS/simultaneous systems incl. fitted CER regressors = qualify. Lemma: NO re-run (rows present). Mahmoudian: re-run mandated (capture any dropped fitted-regressor rows; 8-row paper, deterministic).
- **F41b** government-initiated ratings of firm conduct (CECE) = conduct (rater identity irrelevant). **F41c** decomposed spread components qualify, outcome_label-tagged. **F41e** new ES_source label `b with significance stars only`; downstream star-bound rule documented in the v11 prep spec, not decided by the extractor.
- **Maaloul source identity (data-logistics erratum):** the 27 v10 rows (US, 2010–2016, credit ratings, disclosure, mandatory/voluntary-type subsample-N pattern) match **Maaloul & Wegener, "Mandatory vs voluntary GHG emissions disclosure and credit risk"** (coded from the 2021 version; VoR 2022) — NOT the CRR ESG paper cited in lookup column L → **lookup erratum → F35 list**. The wrong-PDF 0-row staging is retained as documentation; the correct M&W-2022 PDF (new filename) extracts fresh in the next tranche. **Maaloul (2018) remains OUT** — pre-window; stays the F28 exclusion-documentation case; its PDF is removed from papers\ (an extraction would constitute an undocumented corpus addition outside the rule-based search).
**Consequences:** v1.6 swapped and committed while governing; staging deletions before next tranche: Kölbel pair, Mahmoudian pair; papers\ surgery: Maaloul-2018 PDF out. DEC-038 reserved for adjudication outcomes + v11.
**Files:** docs/extraction_codebook_v1_6.md · docs/extraction_project_instructions.md · DECISION_LOG · Status.

---

## DEC-038: Post-batch ruling bundle (F42/F44/F45/F46), corrected corpus ledger (66→61 legacy), coverage-gap closure, evidence-based crosswalk, and the exclusion-list re-screen mandate
**Block:** Corpus governance / harmonization · 2026-07-07
**Context:** Full-corpus extraction complete (113/113 PDFs incl. Zhou gap closure; 2,579 effect rows; 954 FLAG cells; four gold papers cell-exact across eight tranches and five codebook versions). Pass 2 produced the tiered concordance and a 727-item adjudication draft.
**Rulings (author):**
- **F42:** (a) Nemoto & Liu exits (sovereign design; 18 legacy rows). (b) CDS term-structure SLOPE and curvature outcomes QUALIFY (overruling the reviewer's levels-only recommendation; both positions logged; heterogeneity remains visible via outcome_label). (c) Sandra↔Ofogbe identical r/p → Volker independence check; if same sample: joint cluster or drop-one at v11.
- **F44:** (a) Trinh eco-innovation = conduct; CER_measure resolved to `performance` (104 rows). (b) Shi internal-instrument systems qualify (file carried zero FLAGs — confirmation). (c) Kölbel x_direction = good-CER (construct ruling governs over the paper's risk framing). (d) Slope FLAG resolution mechanical: 48 rows → `derivativ (CDS spread)`. (e) Wang-2020: COD_instrument = `loand (interest rate)` per author (matches file state); the 28 estimation_method FLAGs resolve descriptively to `other: not stated` (closed-list integrity; the paper names no estimator).
- **F45:** (a) Zhu & Zhao STAYS (28 rows; overruling the reviewer). Boundary refinement codified for adjudication: allocation with FIRM-SPECIFIC weights (cost shares) = firm-varying emissions proxy = conduct; uniform/mechanical allocation without firm weights remains excluded (Delis-CRFL variants unchanged). (b) Zhang prod_inno rows (12) exit — only explicitly environmental innovation measures qualify.
- **F46:** Weber et al (2010) exits (default-prediction design, outside R2.2; 1 row).
**Corrected corpus ledger:** v10 comprises 66 study keys (incl. Hui 2024 and Weber 2010, absent from earlier informal counts). Study-level exits: Capelle-Blancard, Fard, Nemoto & Liu, Hachenberg & Schiereck, Weber → **61 legacy studies; 1,239 legacy rows (1,306 − 67) before adjudication**. Hui et al (2024) is retagged corpus_segment=update at v11 (in-window of the update search; documents that v10 was not strictly 2021-frozen). Zhou et al (2018) coverage gap closed (22 rows; page-renderer unavailable on that run → Volker image-spot-check flagged). Working hypothesis for the Zhou 62→22 delta (Pass-2b test): v10 bivariates drawn from a Spearman-only matrix, which R2.6/F34f now excludes — same hypothesis queued for the Cubas puzzle.
**Crosswalk (evidence-based):** Fonseka 2019a=energy / 2019b=realestate (permutation test: 30 vs 0 exact matches); Jung (2016)↔staging 2018 (9/12); Wang et al (2020) identity confirmed (2/2) — its exclusion-list entry was stale; Du 2015↔2017; Chen 2020↔2021; Christ, Chen & Gao, Kordschia→Kordsachia, Li_Qui, Maaloul→M&W-2022, Höck/Kölbel oe-transliterations.
**Re-screen mandate:** Volker's 42-entry exclusion list (docs-archived) is partially stale and 13 entries are undocumented ("0"); one entry is result-based ("ridicolous findings") and MUST be superseded by a rule-based verdict. Mandated: full-class re-screen of 20 papers + 1 identity check (Kleimeier & Viehs 2021 vs the already-extracted 2018 WP) under codebook v1.6, identical workflow, corpus_segment=rescreen at v11; Wang-2020 and K&V-2018 are formalized under this segment retroactively. Not-retrievable papers are documented, not skipped. Zero-row runs constitute the retroactive PRISMA exclusion documentation.
**Adjudication approach:** B&H 62-row cluster diagnosed as row-level N-assignment difference (v10 internally consistent given its own N; 100% of analyzable pairs differ in N) → block adjudication per model family, not row-by-row. Resolution pre-fills: 48 slope rows, Trinh 104, Zhu&Zhao 28, Zhang prod_inno 12, Wang-2020 28, Truong n_obs (F37d).
**Reviewer-Risk:** *Finance/Econometrics* — "two rulings overrule the methodological reviewer" (F42b, F45a): both positions and criteria are logged; heterogeneity remains identifiable and testable. *Management/BSE* — re-screen optics: rule-based classes, result-blind, pre-v11; converts an undocumented exclusion layer into a PRISMA asset.
**Consequences:** DEC-039 reserved for adjudication outcomes + v11 assembly; rescreen tranche runs under this mandate; Pass-2b (cause labels, Spearman hypothesis, Cubas, calib-delta) precedes the Volker package.
**Files:** DECISION_LOG · Status (index; Datenagenda #25 rescreen, #26 adjudication package).

---

## DEC-039: Adjudication ruling layer closed (R1–R8, K1–K4) — unit boundary "firm and below", two study clusters, sign regime Devalle, industry operationalization; DEC-040 reserved for adjudication outcomes + v11
**Block:** Corpus governance / adjudication · 2026-07-07
**Rulings (author):** R1 Devalle: printed-scale reading governs (outcome_direction=cost; three v10 signs invert; row 409 corrected via z-route, |z|=2.32/p=.021). R2 price-valued Delis reserve variants stay, tagged `construct_variant=price-valued`. R3 Eichholtz stays — **unit boundary codified (author's formulation, adopted as superior to the reviewer's two-condition variant): the firm and everything below it (its own assets/decisions) qualifies; units above the firm (sovereign/country) do not.** R4 industry-sensitive operationalized: sector list {Oil&Gas, Energy, Utilities, Basic Materials/Chemicals, Mining/Metals, Paper/Forestry, Cement/Construction Materials}, threshold >50% firm-years, borderline → new closed-list value `mixed`. R5 Sandra/Ofogbe: both papers stay, ONE cluster_id; the literally duplicated correlation cell (r=0.001/p=.9818) counts once (Sandra set, N=1,440 per F37d), Ofogbe copy tagged `duplicate` — evidence: identical windows 2005–2019, same first author, identical cell across nominally different samples (96 vs 32 firms). R6 K&V: ONE cluster per F47a; 9 numerically duplicated rows count once; the EL-unique estimate (Scope-1 → ln spread, t=7.47, N=2,267) is ADDED to the canonical set tagged `source=EL2021` (canonical cluster = 29 rows); EL 2021 remains the citable VoR. R7 Atif errata confirmed (regulation without/without; Bloomberg=disclosure, Asset4=performance per paper framing). R8 exclusion-list semantics closed without answer; PRISMA prose will be label-free. K1 split-slope rows in (`subsample_dimension=other: slope-group`). K2 PSM/ATT rows in (`estimation_method=other: PSM-ATT`). K3 Wald-χ² mechanics ratified (z=√χ², df=1, sign from b; unresolvable cells stay FLAG). **K4 withdrawn by the reviewer:** file-level evidence shows full statistics for all 20 Piechocka rows (15 bivariate r + 5 b/SE/t/p) — the author's objection was correct.
**Mechanics for v11:** new assembly-level field `cluster_id` (default = study key; Sandra/Ofogbe joint; K&V joint); duplicate rows carried with `duplicate` tag but excluded from estimation.
**Consequences:** adjudication package updated (sheet Rulings_Verdikte; Sonderfälle patched); ruling dossier carries the verdict block; Volker meeting scope reduces to block confirmations, the 343 line checks, his info items (DB-run, intro status, Zhou/Cubas source checks, spot checks); **DEC-040 reserved** for adjudication outcomes + v11 assembly spec.
**Files:** docs/ruling_dossier_volker.md · docs/adjudication_package_v1.xlsx · DECISION_LOG · Status.

---

## DEC-040: Adjudication outcomes booked as study-level dispositions; lookup layer verified; v11 assembly spec issued (v11-preliminary mandated; freeze gated on DB re-run)
**Block:** Corpus governance / v11 assembly · 2026-07-07
**Adjudication outcomes (I2 = adjudication_package_v1_rw.xlsx):** verdicts were entered at study/block level and propagated to member rows — booked accordingly as STUDY-LEVEL DISPOSITIONS, not cell-level verifications. Blocks: 1a B&H Staging-N ("v10-N nicht nachvollziehbar") closes 62 diffs; 1b Lesart (i) — structural diagnoses CONFIRMED, 208 v10-only rows of Delis/Seltzer (R2.7) and Tan/Wang-2022a (ambient) stay out (comment "Haupteffekt" = confirmation shorthand); 1c "beibehalten" — 51 version-drift v10-only rows adopt (source=v10_version) with numeric dedup, a documented, deliberate exception to DEC-026; 1d/1e closed by existing DECs. Einzelprüfungen (308): 213 Staging / 95 v10; the 95 adoptions enter WITHOUT cause attribution (author: "kein Grund; ohne übernehmen").
**Honesty notes (reviewer-facing):** (N1) for the 95 adoptions no cell-cause clarification is claimed; the plausible main driver is the F37c supplement-scope asymmetry (v10 could code online appendices; the 2026 extraction by design could not) — stated as conjecture, framed as the dual-coding design working as intended (the human layer caught what the scope-restricted AI layer excluded). (N2) Zhou-2018/Cubas source question WAIVED (author: "keine konkrete Tabellenquelle verfügbar") → the fully provenance-documented 2026 extraction governs; −40/−23 v10-only rows exit, 12 Cubas diffs → staging values.
**Lookup layer (Task 5):** executed via Cowork with mandated web access (role-inversion pattern extended to bibliographic work); survived a double spend-limit interruption via resume; 61/61 records, verifier-passed (DOI format, key collisions, VHB plausibility), Volker 10% spot-check + both identity FLAGs author-resolved (Zheng confirmed; Ng & Rezaee = 2012 SSRN WP); B/C→B fixed; M&W column-L erratum resolved; Wang 2025a/b keys assigned. Task 4 spot-checks (Zhou-2018 renderer; Hamrouni scan) returned OK — verification protocol complete.
**Quality-moderator ruling (resolves DEC-023):** q = VHB-JOURQUAL only; WPs and VHB-unrated journals = missing within that moderator. JIF completed for ALL journals (b1 top-up in the DB-re-run slot) as a DORMANT reserve field.
**v11:** assembly spec issued (docs/v11_assembly_spec.md) — column architecture (29-col v10 core byte-identical + extension block), 12-step deterministic pipeline, 16-check verifier, cluster_id mechanic, dedup rules, ES computation incl. star-bound handling. Balance: 2,716 −1 (stray) −12 (prod_inno) −9 (K&V dupes) + 160 (adoptions) ≈ **2,853 ± version-dedup**; estimation set excludes duplicate-tagged rows. Build order: **v11-preliminary now** (unlocks prep/T1 development) → **v11-freeze = DEC-041** after DB re-run (end of week; incl. any straggler mini-tranche), JIF top-up, residual moderator list.
**Reviewer-Risk:** *Finance/Econometrics* — study-level (not cell-level) adjudication: answered by the exact-match layer (437 mutually verified cells), the gold anchors, and full per-row provenance; *Management/BSE* — DEC-026 exception for version-drift rows: answered by numeric dedup + source tags + drop-one sensitivity availability.
**Files:** docs/v11_assembly_spec.md · docs/adjudication_package_v1_rw.xlsx · docs/lookup_neuzugaenge_v1.xlsx · DECISION_LOG · Status.

---

## Conditional / Pending DECs

These are reserved placeholders, promoted to full entries when resolved (per the SOMA convention).

- **Pending-A — Headline event-coding specification.** **Resolved 2026-07-03 → DEC-024** (designated a priori on design columns only; the original 'after T2' trigger is superseded — deciding after variant inspection would carry specification-search appearance, contra DEC-005; T2 is now a sensitivity panel). *Parent:* DEC-005.
- **Pending-B — r-from-regression transform documentation.** **Resolved 2026-07-04 → DEC-028** (v9 `formula` sheet documents four conversion routes; df ≈ n_obs convention per F21 with `pcc_df_k` sensitivity; k not collected). *Feeds:* Roadmap #11 — the conversion is now documentable in-text.
- **Pending-C — Strategic framing: A (null/debunking) vs. C (contingency).** Resolve after the Tier-1 reanalysis (T1–T3) **and** the T8 identification battery. *Trigger:* T8 verdict (do industry / bank-Paris effects survive 3LMA-RVE **and** PET **and** the trend-vs-break race?). *Parents:* DEC-001, DEC-006, DEC-007.

---

## Non-DEC items (Status workbook tasks, not reviewer-defensible choices)

- **Roadmap #11 (PRISMA / reporting).** Document the conversion in-text, add PRISMA flow counts, inter-coder reliability, search date. Execution/compliance task; may spawn Pending-B if the transform is contestable.
- **Roadmap #12 (internal consistency / polish).** Fix the duplicate "H3" label, the degenerate PI = [0.000, 0.000], comma decimal separators in Model 10, the "tbd" abstract. Cleanup task.
