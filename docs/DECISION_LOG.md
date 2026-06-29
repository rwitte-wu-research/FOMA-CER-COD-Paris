# CER–COD FOMA — Decision Log

**Purpose.** Append-only record of *reviewer-defensible methodological decisions* for the CER–COD meta-analysis (Corporate Environmental Responsibility → Cost of Debt; Paris Agreement as a temporal moderator). Companion to the Status workbook (`CER-COD_Status.xlsx` — current state) and the repo scripts (implementation).

**Convention.**
- Append-only. **Never renumber DEC-IDs.**
- Each entry uses the canonical **8-field schema**: Block · Question · Options considered · Chosen · Rationale · Reviewer-Risk · Consequences · Files.
- **Reviewer-Risk is split into two camps:** *Finance/Econometrics* (Stanley–Doucouliagos / meta-regression tradition) vs. *Management/BSE* (CSR–CFP / strategy tradition). Every decision is pre-defended from both.
- Setup/process conventions (tooling, repo, hand-off, verifier) live in the Status workbook **Setup** tab, **not** here.
- Source-pointer notation for cross-references: `[DEC-NNN]; [R/NN]; [<xlsx> Tab N]; [<md>]; [<ms> §X.Y]; [commit <hash>]`.

**Cross-references.** Status workbook (Roadmap themes #1–#13; Tasks T0.1–T8); repo `/R`, `/output`, `/manuscript`.

**Status.** DEC-001…009 promoted from provisional; DEC-010…013 added 2026-06-29 (Roadmap themes #6–#9). IDs now active. Language: English (feeds the English response-letter / methods); switchable to German on request.

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

## Conditional / Pending DECs

These are reserved placeholders, promoted to full entries when resolved (per the SOMA convention).

- **Pending-A — Headline event-coding specification.** Designate the headline Paris coding (end / midpoint / continuous) after the T2 variant comparison. *Trigger:* T2 long-format results complete. *Parent:* DEC-005.
- **Pending-B — r-from-regression transform documentation.** Confirm the exact transform used (e.g., Peterson–Brown 2005) once the coding sheet is reviewed; becomes a full DEC if the transform is contestable. *Trigger:* coding-sheet review (T0.3/T0.4). *Feeds:* Roadmap #11.
- **Pending-C — Strategic framing: A (null/debunking) vs. C (contingency).** Resolve after the Tier-1 reanalysis (T1–T3) **and** the T8 identification battery. *Trigger:* T8 verdict (do industry / bank-Paris effects survive 3LMA-RVE **and** PET **and** the trend-vs-break race?). *Parents:* DEC-001, DEC-006, DEC-007.

---

## Non-DEC items (Status workbook tasks, not reviewer-defensible choices)

- **Roadmap #11 (PRISMA / reporting).** Document the conversion in-text, add PRISMA flow counts, inter-coder reliability, search date. Execution/compliance task; may spawn Pending-B if the transform is contestable.
- **Roadmap #12 (internal consistency / polish).** Fix the duplicate "H3" label, the degenerate PI = [0.000, 0.000], comma decimal separators in Model 10, the "tbd" abstract. Cleanup task.
