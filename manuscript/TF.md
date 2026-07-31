# TF — Block F: outliers & influence (F1–F7) · manuscript feed

Language per the resolved gate [DEC-044 → DEC-047]: all outlier and influence findings are
reported mechanically/descriptively. Source of record: `output/TF_results.csv` (4 rows),
`output/TF_loo.csv` (114 rows), `output/TF_influence.csv` (2,713 rows) @ the TF canonical-run
script commit `06d1eeb` (run start 2026-07-30 21:58:15; F1 rstudent pass 249.4 min, parallel snow,
ncpus = 8; 121 model fits); meta re-emission + fresh verifier @ `c1e8b6c`: **V01–V12 all PASS**
[DEC-051b]; dat_prep md5 `6702ef3dc45fe0b693b13f50ebd1576b`; seed 20260710. Text blocks
**TB-69…TB-71** live in `output/TF_results_workbook.xlsx` › Manuscript_Text_Blocks; **TB-65 is
finalized there (READY)** and **TB-68 is superseded** (recorded per the TB-35 precedent; the
TG-workbook cells remain build-historical). No `ms_input` rows are flagged in the TF CSV (TG
style per F-Q9) — formula-live citables sit in the workbook tabs. The machine-readable register
`output/robustness_register.csv` is **complete**: 23 × 18 (5 A + 11 G + 7 F rows), assembly by
value with 1e-9 source verification and the mandatory reported-in column [DEC-051 no.9].

**Gates.** Gate A (script + verifier): CS-aggregate reproduced by value at −0.0616608 (df 113),
1e-9 — PASS. Gate B (verifier): independent 3L headline refit matched to the committed
`output/T1_results.csv` A1 row (−0.058647; three variance components located ≤ 1e-6; row by label
key) — PASS [DEC-050b/c; DEC-051 no.11]. Verifier history: first pass 11/12 — V10 caught a
serialization-only defect (jsonlite default digits = 4 truncated the stored winsor percentiles;
statistics proven intact by the exact inside-count identity) — resolved by the DEC-051b
deterministic meta re-emission; fresh verifier 12/12 [ERROR #36].

## Battery summary (all refits on the verbatim spine: 3L random effects cluster/study/esid, CS ρ = 0.6, CR2/Satterthwaite on cluster_id)

| Move | Design | Key result | Read-out |
|---|---|---|---|
| F1 · rstudent identification | ES-wise studentized deleted residuals on the full-set fit, reestimate = FALSE (convention disclosed), \|t\| > 3; computed parallel snow [DEC-051a] | 13 / 2,713 flagged (0 non-finite); top \|t\| = 18.6 = Drago et al (2018), z = −3.39 | full per-ES set in TF_influence.csv; 9 of 13 flags negative |
| F2 · drop-and-refit (prominent) | two pre-stated sets, no union: rstudent set (k = 2,700) and MAD set (k = 2,438); overlap 13 (rstudent ⊆ MAD) | r = −.038, CI [−.047, −.029] · r = −.032, CI [−.038, −.026] | both attenuate toward zero; sign, CI ≠ 0, SESOI retained |
| F3 · winsor / unwinsor | zi at empirical P1/P99 (−0.3808 / 0.1847, type-7, computed once; 56 clipped); unwinsor ≡ headline [DEC-013(a) status-quo semantics] | r = −.041, CI [−.050, −.031] | headline direction intact; pair semantics disclosed, no second fit |
| F4 · cluster leave-one-out | 114 deletion refits + CR2; PSOCK W = 8; ne = 0 | est_z −.060…−.041 (range .019); 114/114 signs retained, 114/114 CIs exclude 0 | max shift = the Drago drop; full table TF_loo.csv |
| F5 · influence diagnostics | cluster Cook’s D derived from the LOO fits; ES hat values from the full-set fit; descriptive, no thresholds | max D = 1.64 (Drago), runner-up 0.024; hat max .0061 (mean .0004) | one dominant, disclosed influence point |
| F6 · MAD second identification | median ± 3·MAD on zi (b = 1.4826), full estimation set | 275 flagged (10.1%); rstudent set fully contained | broad by construction on the heavy-tailed zi distribution; identification, not adjudication |
| F7 · trim 1/99 | drop the 56 ES outside [P1, P99] (same percentiles as winsor) | r = −.041, CI [−.050, −.032] | mirrors the winsor read |
| G11 · register close | 7 F rows appended: 4 populated refits + leave_one_out summary + influence diagnostic + loso_post_cell cross-reference | 23 × 18, status complete; every populated row negative and inside the band (\|r\| .031–.062); 14/16 CIs exclude zero | machine-readable appendix table |

## Disclosures carried into the text

- **Language regime:** resolved-gate wording throughout [DEC-047]; workbook verdict lines use the
  pinned formula ("Mechanical outcome: …; wording per the resolved gate").
- **Excluded treatments [A.5; DEC-031a.4]:** trim-and-fill excluded (Carter et al. 2019 —
  unreliable under heterogeneity); ±k·SD rules and SAMD excluded (mean/SD themselves
  outlier-distorted; superseded by model-based studentized residuals — Leys et al. 2013;
  Viechtbauer). All treatments pre-stated; no result-contingent trimming [Annex F].
- **F1 computation convention:** deleted residuals under fixed variance components
  (reestimate = FALSE) — full re-estimation at k = 2,713 is computationally prohibitive (the
  FE-only serial route alone implied ≈ 32 h on the run machine); threshold and route pinned a
  priori [DEC-051; DEC-051a]. Relation to the N5/H3 mask: the multiverse arm uses the
  once-computed standardized-residual mask, F1 the deleted residuals — a descriptive relation
  only, no test.
- **DEC-013 anchors:** Drago et al (2018), −0.9977 (z = −3.39), is present, is the top flag, and
  is carried by the drop-and-refit variants — the primary specification remains untouched
  [DEC-005]. The Devalle et al (2017) extreme (+0.9998) was superseded before analysis by the
  documented v12 Devalle regime (ruling R1; v12 buildlog "P7 adoptions … Devalle per R1
  ausgeschlossen"; v12 verifier V7 PASS, signs 0.089 / 0.147 / −0.296); its three recomputed ES
  are in the estimation set and unflagged.
- **MAD breadth:** k = 3 was pinned for symmetry with the rstudent threshold; on the heavy-tailed
  zi distribution it flags 10.1% of ES. Both identifications are reported in full
  (TF_influence.csv); no union spec exists in the catalogue, and here the union refit would equal
  the MAD refit (rstudent ⊆ MAD).
- **Δ and flags are presentation-layer:** no spec-vs-headline tests exist anywhere in the block
  [DEC-031a.6]; joint specification inference is single-homed in the N5 multiverse arm.
- **loso_post_cell:** carried in the register as a cross-reference row only — post-cell LOSO was
  executed in Block B (T2/B6, 31 whole-study drops); values are single-homed there [A.8].
- **Single-home:** prediction intervals live in A3/T1; TOST/equivalence in E1/TH-a;
  publication-status inference in D5; Paris moderation in T7; composition-adjusted contrasts in
  T8; specification multiverse in N5.
- **Pinned limits:** TF contains no multiverse, no prediction intervals, no Paris analyses, no
  multiplicity family, and no new framing surface.
- **Run record:** the first canonical attempt was aborted > 10 h inside the serial F1 pass per a
  pre-stated break-even rule — no outputs existed (terminal-write design), the tree stayed clean,
  and no estimate was produced or seen [ERROR #35; DEC-051a]; the re-routed run completed with
  exactly 121 model fits (≤ 130 budget), zero not_estimable LOO fits, and one
  serialization-only verifier corrigendum [ERROR #36; DEC-051b]. Delivery-side worker pins 8/8
  follow the measured RAM (15.7 GB total / ~5.8 GB available).

## Verdict line (per the resolved gate [DEC-044/DEC-047])

Across the seven pre-registered outlier and influence rows of Block F the pooled CER–COD
association keeps its negative sign, its significance, and its place inside the pre-registered
SESOI band (|r| ≤ .070) in every specification: the four handling variants range from r = −.032
to −.041 around the headline r = −.059, and 114/114 leave-one-out refits retain sign and
significance (est_z −.060 to −.041). Outlier handling attenuates magnitude — the flagged tail is
predominantly negative, led by a single dominant, fully disclosed observation (Drago et al. 2018;
Cook’s D 1.64) whose removal never changes the reading. With the seven F rows appended, the
machine-readable robustness register is complete: 23 specifications, every populated row negative
and inside the band (|r| .031–.062), 14 of 16 value rows excluding zero (the UWLS+3 and
direct-r-only CIs, both disclosed in their blocks, cover it). Consistent with the headline
reading: statistically detectable but economically negligible, never null.
