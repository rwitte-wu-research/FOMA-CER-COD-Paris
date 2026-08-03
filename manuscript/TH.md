# TH — Null/equivalence battery (Blocks E/H · run family TH-a/TH-c) · manuscript feed

Framing-neutral until the documented gate-resolution step [DEC-044] (post TH-b). Sources of record:
`output/TH_a_results.csv` (177 rows) + `output/TH_c_results.csv` (1,347 rows) @ commit 6203522
(family run base dafd95e; runs 2026-07-24 / 2026-07-26; verifiers **17/17** and **19/19 PASS**; chat
artefact checks 18/18; dat_prep md5 `6702ef3dc45fe0b693b13f50ebd1576b`; perms md5
`077d689b2dee2931467650585089888a`, kept out of git). Text blocks **TB-36…TB-51** live in
`output/TH_a_results_workbook.xlsx` / `output/TH_c_results_workbook.xlsx` › Manuscript_Text_Blocks;
formula-live numbers in each Manuscript_Inputs tab. **TH-b (H2a/H2b RoBMA):** source of record
`output/TH_b_results.csv` (30 rows) + `output/TH_b_run_meta.txt` @ the Block-2 commit (run 2026-07-27,
canonical run 3; verifier **O0–O14 PASS**, exit 0; scripts @ 4cf8fe6; dat_prep md5 unchanged). Text blocks
**TB-52…TB-56** live in `output/TH_b_results_workbook.xlsx` › Manuscript_Text_Blocks. F66 CLOSED
[DEC-046]; the DEC-044 language gate is now resolvable (resolution step = own DEC).

## Battery summary (period domain 2,705 ES / 113 studies / 112 clusters; E1 on the estimation set 2,713 / 115 / 114)

| Move | Design | Key result | Read-out |
|---|---|---|---|
| E1 · TOST pooled | bands \|r\| = 0.070 (primary) / 0.050 | p_TOST = .205 / .732; 90% CI [−.082; −.036]; flags 0/0 (primary fail ex-ante expected) | pooled effect small but **not** equivalence-small |
| E2 · TOST Paris contrast | ±0.050 on diff (headline coding) | diff_z = +0.010 (p = .582); p_TOST = .022; 90% CI [−.022; +.042]; flag 1 | contrast inside the secondary band — mechanical flag only |
| E3 · Gate config | E2-pass requirement + BF01 ladder (≥3 full; 1–3 equivalence register) | status: resolution deferred | wording tier decided post TH-b [DEC-044] |
| H1 · MDE/power | 6 VC scenarios × 9-point δ-grid + 200-REML calibration | MDE80: own×0.5 = 0.063; own×1.0/×2.0 **NA** (> 0.08 ceiling; power@0.08 = .730/.448); COE lower bound 0.010–0.018; calibration rejection .765 (optimism +.035) | observed heterogeneity, not k, is the binding constraint |
| H3 · Spec curve | 1,260 cells; 10-coding core; joint time-translation permutation | core **0/10** significant; full curve **1/1,260** (end_lag2\|winsor\|full\|dfE, ρ .4: +0.018, p = .049; ~63 expected under a global null); p_perm(share) = 1.000, p_perm(median \|t\|) = .854 (B_eff 500) | coding- and model-invariant null |
| H4 · Sup-break | 12 admissible years (df ≥ 5) + joint permutation | sup \|t\| = 2.12 @ 2009; p_perm = .341 (B_eff 500) | strongest candidate year unremarkable |
| H5 · Race permutation | cluster time translation, full-REML refits | p_perm = .401 (B_eff 500); observed \|t_race\| = 1.052 (point estimate single-home T8) | permutation confirms the T8 double null |
| H6 · Zarea transplant | midpoint rule + tie exclusion on own 3L-RVE spine | diff_z = +0.011 (t(11.6) = 0.58, p = .574); 79 tied ES / 5 studies excluded, post 31 → 26 | competing operationalization, same answer |
| H7 · Cumulative MA | 113 chronological steps; 10-cluster CI floor | post-floor range [−.095; −.015]; final −0.059 [−.087; −.031]; step 1 not estimable (rule) | sign-stable from early on; ends at the pooled value |
| H8 · Rolling windows | 6-y width, 21 windows (20 estimable; 2002-07 < 5 clusters) | window means [−.087; −.015]; tiers per DEC-045 S6 | negative in every estimable window |
| H9 · External size | vs COE companion study-level (descriptive, no test) | −0.059 (debt) vs −0.039 [−.046; −.032] (equity); overlap 6/115 studies, 0 shared ES | debt-side larger; SE provenance blocks a formal contrast |
| H10 · Conditional p-curve | first-reported ES per significant post study (28/31) | right-skew binomial p = 1.5e-06, Stouffer p = 2.1e-119; flatness pp = 1.000 | post-cell literature carries evidential value, not selection |
| H11 · Within-study display | inventory + single splitter | Li et al (2022) only: 12 pre / 5 post, +0.036 descriptive; 73 straddlers, 72 pool across | motivates the pooled-across-the-break module |
| H2a · RoBMA level | 36-model averaging, k = 114 aggregates; priors: PSMA defaults (primary) / COE-informed N(−0.041, 0.021) / wide 2σ | BF01(effect) = 7.03 / 2.38 / 1.69; μ̄ −0.009 … +0.008 (spike-bounded 95% CIs); heterogeneity saturated (BF01 = 0); bias block BF10 = 94.7 / 11.1 / 16.8 | limited effect-component support, mechanically prior-dependent — gate input |
| H2b · RoBMA moderation | RoBMA.reg, 113 cluster×period rows (82+31); contrast priors N(0, 0.025) primary / N(0, 0.050) / package default mNormal(0, 0.25) | BF01(period) = 1.03 / 1.17 / 8.49 (default with disclosed convergence caveats); contrast +0.003 z [−.031; +.045] | primary in the 1–3 band ⇒ equivalence-register input [E3]; gate input delivered |

## Disclosures carried into the text

- **Gate discipline [DEC-044]:** no evidence-of-absence language anywhere before the documented resolution
  step; all E-flags and p_perm values are reported mechanically; TB-36/37/39/48–51 BLOCKED, TB-41/42/46 DRAFT.
- **H1:** fixed variance components are design inputs here (semantically licensed, H-Q4) and prohibited in
  H3/H5 inference; the COE mapping is a one-level **lower bound** (variance factor ~65, MDE factor ~8 vs COD).
- **H3:** the single sub-.05 cell is named in text (winsorized end_lag2 arm, ρ .4) as a descriptive
  observation against ~63 expected; UWLS3 rows (df ≈ 2,703) are an estimator-structure axis, a different
  estimand family — not a spine alternative.
- **Single-home:** H4 observed grid in TH-a / p_perm in TH-c; H5 point estimate and p_CR2 in T8 only;
  Paris×exposure interactions keep their one designated location.
- **Mechanics:** H7 step 001 not_estimable by rule (#12 guard); H8 tier scheme S6; H10 NCP sign fix (#11)
  verifier-anchored; H6 wording pin ("Zarea's operationalization … within our 3L-RVE framework", never
  "Zarea's method"); k20 basis excludes Chodnicka-Jaworska (2022, n = 18), disclosed.
- **TH-b stack & policies [DEC-046]:** RoBMA 3.6.1 + BayesTools 0.2.23 pinned per upstream reproduction
  guidance (4.0.0 = breaking release); y/se route — priors act verbatim on Fisher-z; effect_direction
  "negative"; saturated BF pairs Inf/0 are legitimate raw values (#18 policy); FITMETA prior echoes are
  2-dp print renderings, full-precision constants verifier-anchored (O8b); h2b_factor_default carries 23
  convergence warnings (adaptation/R-hat 1.174/ESS 98) — disclosed at the non-primary set, primary clean.
- **TH-b run record:** canonical run 3 (runs 1–2 = designed halts, ERROR_LOG #17/#18); wall clock 4 h 39 min
  vs 5.15 h projection (88%); κ_emp = 1.71/2.18/2.34 vs pin 2.5; result-blind ledger: single non-gate leak
  (run-2 halt value), gate quantities first read at workbook build.
- **Runtime/provenance:** TH-c 44.3 h vs 13–15 h projected (§6(v) decomposition in `TH_c_run_meta.txt`);
  ladder balance 148/0 (TH-a) and 11,500/92/0 · 540/3/0 · 200/2/0 (TH-c); eff_B 500/500/500.

## Verdict line (gate input — no framing)

Across the equivalence and stress battery the Paris moderation is a consistent, mechanically bounded null —
the contrast sits inside the secondary SESOI band (E2 flag 1), 0/10 core codings are significant, sup-break
and race permutations are unremarkable, and the competing operationalization concurs — while the pooled
association stays small, negative and sign-stable across time slices (H7/H8) and is not statistically
equivalent to zero (E1 flags 0). The wording tier (evidence-of-absence vs equivalence register) is decided
at the documented gate-resolution step [DEC-044] after the TH-b Bayes factors. That input is now on
file: BF01(moderation) = 1.03 and 1.17 under the pre-specified contrast priors (band 1–3) and 8.49 under the
package default (disclosed caveats); BF01(level) = 7.03 / 2.38 / 1.69 with saturated heterogeneity and a
strongly included selection block — the resolution step [DEC-044 → own DEC] is unblocked.

RESOLVED [DEC-047, 2026-08-01]: the gate adopts the equivalence register — Paris
BF01 in band 1–3 per the pre-specified E3 ladder; the package-default BF01 = 8.49
is sourced as a sensitivity bracket only, never as headline. All TH-derived
manuscript wording follows that tier (applied throughout Chapter 4 at M2).
