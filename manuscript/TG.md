# TG — Block G: robustness battery (G1–G11) · manuscript feed

Language per the resolved gate [DEC-044 → DEC-047]: Tier-1 wording = equivalence register; all
robustness findings are reported mechanically/descriptively. Source of record:
`output/TG_results.csv` (36 rows) @ the TG canonical-run commit (scripts `R/11_robustness.R` +
`R/11_verify_outputs.R` @ `c935b28`; canonical run 2026-07-29 17:28:47; verifier **V01–V12 all
PASS**, exit 0; dat_prep md5 `6702ef3dc45fe0b693b13f50ebd1576b`; seed 20260710). Text blocks
**TB-65…TB-68** live in `output/TG_results_workbook.xlsx` › Manuscript_Text_Blocks (TB-65 = DRAFT
until the F append); no `ms_input` rows are flagged in the TG CSV — formula-live citables sit in the
workbook tabs. The machine-readable register `output/robustness_register.csv` is **partial** by
design (A + G rows populated and source-verified; 7 F placeholders pending the outlier session).

**Gates.** Gate A (script pre-flight): CS-aggregate reproduced by value at −0.0616608 (df 113),
1e-9 point / 1e-6 CI tiers — PASS. Gate B (verifier): independent 3L headline refit matched to the
committed `output/T1_results.csv` A1 row (−0.058647; three variance components ≤ 1e-6; row located
by label key, the A1 ≡ A3 identity untouched) — PASS [DEC-050b; DEC-050c].

## Battery summary (spine verbatim: 3L random effects cluster/study/esid, CS ρ = 0.6, CR2/Satterthwaite on cluster_id; G6 off-spine by design)

| Move | Design | Key result | Read-out |
|---|---|---|---|
| G1 · star-bound excl. | drop 99 star-bound ES / 11 studies | r = −.058, CI [−.087, −.029] | headline intact |
| G2 · proxy-n drop | drop 296 flagged rows (297 on the usable basis incl. 134 FLAG-based; one tagged duplicate exits at the estimation filter) [DEC-050a] | r = −.038, CI [−.048, −.029] | largest attenuation; sign + SESOI retained; narrowest CI of the panel |
| G3 · n_firms variance | vi rebuilt on firm counts (adjustment-integer share 1.00; 0 rows dropped) [r02f2] | r = −.051, CI [−.071, −.032] | headline intact |
| G4 · direct r only | 104 bivariate ES / 52 studies | r = −.038, CI [−.086, +.011] | zero-covering CI; near-identical to the G9 bivariate cell (Δ = 2 ES / 1 study) — cross-referenced, not independent |
| G5 · PCC df k = 10 / 20 | vi = 1/(n − k − 3) on PCC rows; k20 excludes the single n = 18 row | r = −.058 / −.058 | invariant (< .001 movement) [van Aert 2023] |
| G6 · cluster median | off-spine one-per-cluster median, rma.uni(REML, knha); 114 aggregates, df 113 | r = −.062, CI [−.094, −.030] | brackets the rho-based headline from below; companion to T1-A5 |
| G7 · journal quality | 3 cells incl. 99_NCE (D31.4) | r = −.056…−.060; HTZ p = .988; all pairwise \|Δz\| ≤ .004 | no quality gradient; publication-status inference single-homed in D5 |
| G8 · research field | fin/acc/econ · sust · mgmt | r = −.046 / −.090 / −.052; HTZ p = .617 | no field split; sust cell widest CI (p = .065), contrast p = .356 |
| G9 · ES measure (FEATURED) | partial vs bivariate [van Aert 2023] | partial r = −.062 (2,607 ES / 113 cl) vs bivariate r = −.026 (106 / 53); Δz = −.036, p = .218 | the > 95% PCC basis carries the headline; small remainder points the same way |
| G10 · conversion route | computed · bivariate · star-bound · v10-adopted; main-effect-only per Annex C | r = −.022…−.095, dominant computed route −.058; HTZ p = .565; one contrast df = 3.1 (display-flagged) | no route artifact |
| G11 · register | 23 rows: 5 A + 11 G + 7 F placeholders; assembly by value, 1e-9 source verification, mandatory reported-in column [DEC-050 §10] | partial — closes at the F append | machine-readable appendix table |

## Disclosures carried into the text

- **Language regime:** resolved-gate wording throughout [DEC-047]; workbook verdict lines use the
  pinned formula ("Mechanical outcome: …; wording per the resolved gate").
- **Descriptive regime [DEC-050 §3–4]:** panels are level panels — cells + HTZ omnibus + pairwise
  CR2/Satterthwaite, all descriptive; no Holm by design (no inferential family is claimed); the
  df < 5 display convention [DEC-048] bites once (G10 computed vs star-bound, df = 3.1).
- **Δ and flags are presentation-layer** [DEC-050 §3]: no spec-vs-headline tests exist anywhere in
  the block (nested-subset differences have no valid SE [DEC-031a.6]); joint specification
  inference is single-homed in the N5 multiverse arm.
- **S-G2 episode [DEC-050a]:** the designed stop fired at 296 vs the pinned 297; reconciled
  result-blind (estimation-set vs usable-basis counting; the one tagged duplicate is a proxy row)
  and re-pinned to 296. The G2 register row carries the counting convention verbatim.
- **G4/G9 near-identity [DEC-050 §6]:** the direct-correlation spec and the bivariate panel cell
  coincide on v12 up to 2 ES / 1 study; the rows are cross-referenced to avoid double counting.
- **Single-home:** prediction intervals live in A3/T1; TOST/equivalence in E1/TH-a; publication-
  status inference in D5; Paris moderation in T7; composition-adjusted contrasts in T8.
- **Pinned limits:** TG contains no outlier or influence analysis (Block F, pending), no multiverse
  (N5), no spec-vs-headline testing, no prediction intervals, and no multiplicity family.
- **Run record:** one designed stop (S-G2, reconciled result-blind before any estimate was read),
  verifier corrigenda family DEC-050b/c (Gate-B canary wording; row location by label key with the
  A1 ≡ A3 identity untouched), final verifier 12/12; delivery-side ERROR #32–#34 logged; nothing
  invalid entered committed bytes. Budget respected (< 5 min, ≤ 14 fits, ≤ 60 rows [DEC-050 §9];
  36 rows delivered).

## Verdict line (per the resolved gate [DEC-044/DEC-047])

Across the eleven pre-registered robustness rows of Block G the pooled CER–COD association keeps
its negative sign and stays inside the pre-registered SESOI band (|r| ≤ .070): the seven spine and
aggregation variants range from r = −.038 to −.062 around the headline r = −.059, and the four
technical level panels show HTZ p-values from .218 to .988 with no journal-quality, field,
measurement-basis, or conversion-route pattern. The two attenuated rows — the proxy-filled-n drop
(r = −.038, the narrowest CI of the panel) and the 52-study direct-correlation subset (r = −.038,
CI covering zero) — are disclosed individually, the latter cross-referenced to the featured
bivariate cell rather than read as an independent check. Consistent with the headline reading:
statistically detectable but economically negligible, never null. The register closes at the
F append.
