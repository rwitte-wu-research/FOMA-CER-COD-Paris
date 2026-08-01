# M-Phase Positioning Map — FOMA CER–COD–Paris (P1 output)

Authored in the M session (P1), 2026-08-01. Governing entry: **DEC-052** (same commit). This file is the **single source** for the TB→chapter mapping, the frozen RQ/H anchors, the vocabulary zones, the single-home register, and the M1–M7 sequencing. Chapter sessions work against this map; changes to frozen items require a corrigendum DEC with ripple check.

Authority chain: claim architecture per [DEC-044] (Framing A) and [DEC-047] (equivalence register); moderator design per [DEC-043]/[DEC-048]; this map adds the manuscript-side architecture only. Result-blind discipline has served its purpose; reporting is licensed within the DEC-047 register.

---

## 1. Claim architecture (binding recap)

- **Tier 1 (Paris moderation):** equivalence register — "no detectable Paris-Agreement moderation; the post-minus-pre contrast is statistically equivalent to zero within the secondary SESOI band (±0.05 on Fisher-z)." Carried by the equivalence test (diff_z = +0.010, p = .582; p_TOST = .022; 90% CI [−0.022; +0.042]); coherent with the model-averaged contrast (+0.003, 95% CI [−0.031; +0.045]). Bayes factors descriptive only: BF01 = 1.03 / 1.17 (pre-specified priors); 8.49 only as a sensitivity bracket with disclosed convergence caveats.
- **Tier 2 (pooled effect):** statistically detectable, economically negligible, explicitly **not null**. Headline: r = −0.059 (95% CI [−0.086; −0.031], df = 111.7, p < .001; 2,713 ES / 115 studies) [TB-04]; 0.84× the 0.07 small-PCC benchmark [TB-05]; heterogeneity dominates — 95% PI [−0.390; 0.287]; 62.3% between-cluster / 37.5% within-study / <1% sampling variance [TB-06].
- **Moderation (both tiers of the moderator design):** no interaction HTZ significant (p = .077–.799; Holm-adjusted minimum .616) [TB-58]; no levels omnibus significant (C1 .428 · C2 .113 · C3 .446 · C4 .867 · C5 .541 · C6 .085 · C7 .880 · C8 .929); single nominal level contrast loan vs. bond (Δz = 0.053, p = .009, within a 15-pair family — descriptive only) [TB-59].

### Locked vocabulary (DEC-047)
- **Banned everywhere:** "evidence of absence"; "the data provide (moderate/strong) evidence for the null"; any headline sourcing of BF01 = 8.49; any Bayesian-affirmative null phrasing.
- **Licensed (Tier 1):** the register sentence family above; BF cited descriptively (1.03 / 1.17); 8.49 only as sensitivity bracket with caveats.
- **Vocabulary zones (register-governed text):** Title · Abstract · Ch. 1 promise · Ch. 2 §2.2 (H2 wording) · Ch. 4 §4.2 result sentence (+ the single cross-reference) · Ch. 5 (TB-55).

---

## 2. Chapter skeleton (frozen, P1-Q1)

1 Introduction · 2 Theory & hypotheses (**2.1** CER→COD / H1 · **2.2** Paris / H2 · **2.3** Moderating contexts, consolidated) · 3 Methods · 4 Results (**4.1** pooled & heterogeneity · **4.2** Paris contrast & equivalence · **4.3** identification · **4.4** moderator analysis · **4.5** publication bias, D6 table at end · **4.6** robustness & outlier register) · 5 Discussion & conclusion · Online appendix. Abstract written last.

---

## 3. RQ / hypothesis anchors (frozen wordings, R2 = O-A')

| Anchor | Wording (EN) |
|---|---|
| RQ1 | Is CER negatively associated with firms' cost of debt? |
| RQ2 | Has the Paris Agreement moderated the CER–COD relationship? |
| RQ3 | How does the CER–COD association vary across measurement, instrument, industry, regulatory, and country contexts — and does the Paris-period contrast itself vary across these dimensions? |
| H1 | CER is negatively associated with firms' cost of debt. |
| H2 | The negative association between CER and COD is stronger in the post-Paris period than in the pre-Paris period. |

Rules: formal hypotheses = H1 + H2 only; **no H3+**; no H2a/H2b split (the equivalence test, the identification battery, and the Bayesian sensitivity are pre-registered probe strands of H2, not separate hypotheses; also avoids collision with the battery-internal H2a/H2b RoBMA labels). H2 is retained directionally and rejected in favour of the equivalence conclusion (R1). RQ3 is answered by the pre-registered two-tier heterogeneity analysis (levels inventory + Holm interaction family), declared as such in Methods. Cutoff/coding definitions live in Methods (TB-16), not in the H wording. Word-level polish permitted in chapter sessions; structure and content of these anchors are frozen.

---

## 4. Section 2.3 build plan (R2 = O-A')

One consolidated section, four paragraph blocks in featured depth, then one collective paragraph:

1. **COD instrument** — fullest block; draft-§2.3 substance; expectation: association strongest in relationship (bank) lending.
2. **CER measurement** — new, short; performance- vs. disclosure-based operationalization as an information-channel argument.
3. **Carbon regulation** — draft-§2.4 condensed.
4. **Country / institutional context** — short; compositionally motivated (links to the identification narrative).
5. **Collective paragraph** — remaining pre-registered dimensions: industry sensitivity (draft-§2.5 core argument in two sentences), economic development, cultural cluster, legal origin.

Directional expectations may stand as prose ("we expect …"), **no H numbers**. Closing sentence of 2.3: "These expectations structure RQ3; the pre-registered analysis examines both whether the association varies across these dimensions and whether the Paris-period contrast does."

Featured reporting set (unchanged, per C-session prominence ruling): {CER_measure, COD_instrument, regulation3, country_region} in the main text; all eight panels retained (others in the appendix).

---

## 5. TB → chapter map v1.0 (frozen at range + item level)

71 slots · 66 active · gap TB-29 (documented, never assigned, no renumbering) · TB-68 superseded (do not use). Source rule: **TB-65 and the TB-68 disposition are taken from the TF workbook; TB-66/67 from TG.** READY blocks are used verbatim (workbooks are the source of record); DRAFT blocks are finalized in their scheduled session.

| Chapter | TB blocks | Notes |
|---|---|---|
| 1 Introduction | 45 · gap builder #35 (no TB: 73/115 studies span the break, 72 pool across it, 1 splits) | promise rebuild per audit |
| 2 Theory | — (no result TBs) | anchors §3; build plan §4 |
| 3 Methods | 01, 02, 03 · 16, 17, 18 · 20 · 30 · 38 · 52 · 57, 63 · 47 (dual with App) · #36 overlap prose (from docs/overlap_disclosure_v12.md, no TB) | 13 READY blocks; gaps only [PENDING #16], [PENDING #23 note], [PENDING R5] |
| 4.1 Pooled | 04, 05, 06 · 07 (bridge to 4.2) | **08 BLOCKED until #37** (economic translation; Tier-2-bearing; feeds Ch. 1/5) |
| 4.2 Paris | 13 · 36, 37 · 39 · 40 · 43 (carries the single overlap cross-ref) · 44 · 46 (DRAFT → here, R6) · 48–51 · 53, 54 · 14, 15, 19 (main/appendix split at writing time) | core vocabulary zone |
| 4.3 Identification | 21–26 · 28 (after flip; closing synthesis paragraph, P1-Q4) | |
| 4.4 Moderators | 58, 59, 60, 61 · 62 | featured four in text; loan-vs-bond descriptive |
| 4.5 Publication bias | 31, 32, 34 · D6 table at end | 33 → App |
| 4.6 Robustness | 65(TF), 66, 67 · 69, 70 · 09 | register overview |
| 5 Discussion | **55 (register voice, single home)** · 35 · 27 · 56 (DRAFT) · 64 (DRAFT; composition/boundary paragraph, R3) · 11 (power/null-security, P1-Q5) · TH.md verdict sentence (M authorship) | |
| Appendix | 10 · 33 · 47 · 71 · non-featured panels · LOO/influence tables · any-with line · PRISMA flow | |
| Abstract | 12 (DRAFT, last) | R4 title family |

---

## 6. Single-home register

- TB-55 = the register decision, voiced once in Ch. 5; **exactly one** Results cross-reference (from §4.2).
- TB-28 = identification/moves synthesis, **not** a second register voice (register-conformity edit at flip).
- Overlap tiers (7/120 · 6/115 · 5/113 · 60/2,713 ≈ 2.2% · 0 shared ES): home = Methods self-overlap paragraph; §4.2 carries one cross-reference via TB-43 (H9).
- composition_adj / trend_composition: canonical home T8/B5; T7 references only.
- Prediction intervals: home A.8/T1 (TB-02/06); no PIs elsewhere.
- LOSO-post cell: home T2/B6; TF register cross-references.
- D6 triangulation table: one location (end of §4.5); TB-35 prose in Ch. 5 references it.
- BF01 = 8.49: sensitivity bracket only, never a headline anywhere.
- Δ-vs-headline comparisons: robustness register only.

---

## 7. Session plan M1–M7 (frozen, author sequence 3→4→1→2→5→Abstract)

| Session | Chapter / task | DRAFT & housekeeping | Gates |
|---|---|---|---|
| **M1** | Ch. 3 Methods assembly (13 TBs + battery pins + #36 paragraph + O-A' declaration paragraph); PRISMA section at block end | Data-availability slot [PENDING R5]; #23 PRISMA note slot | **#16** ([PENDING #16] slots if absent at start); Fig. 2 PRISMA flow gated |
| **M2** | Ch. 4 Results (§4.1–4.6 per map); figures: forest/funnel rebuilt, TB-41/42 figures | Finalize TB-41/42, TB-46; **T8 workbook: TB-28 flip BLOCKED→READY + register-conformity edit** (placement end of §4.3); TH.md verdict sentence | **#37** → TB-08 ([PENDING #37] if absent; rest of §4.1 proceeds) |
| **M3** | Ch. 1 Introduction (RQ block, promise/contributions, #35 gap + TB-45, novelty scan & COE/Zarea positioning) | — | — |
| **M4** | Ch. 2 (2.1/2.2 rebuild with the two-sided tension architecture per R1; 2.3 per §4 build plan; Fig. 1 framework update) | — | — |
| **M5** | Ch. 5 (build around TB-55/35/27/11; boundary paragraph TB-61+64) | Finalize TB-56, TB-64; TH_b workbook touch → micro-fix inherited 4_Formula_Reference B6/B8/B9 | — |
| **M6** | Abstract + title (R4 family); finalize TB-12 | — | — |
| **M7** | Pre-submission gate: **R5 ruling** · vocabulary-zone scan (whole manuscript) · single-home check · numbers consistency pass · #33 waiver decision · Ch.-2 pass-2 B-level quality check · references/format (author's closing pass) | — | R5 |

Manuscript file layout (DEC-052.i): `manuscript/` directory, one Markdown file per chapter (`ch1_introduction.md` … `ch5_discussion.md`, `abstract_title.md`); docx assembly at M7.

---

## 8. Ruling register (P1)

| ID | Ruling | Status |
|---|---|---|
| P1-Q1 | Chapter skeleton incl. "5 = Discussion + Conclusion" and online-appendix zone | FROZEN |
| P1-Q2' | D6 **table** at end of §4.5; TB-35 **prose** in Ch. 5 | FROZEN |
| P1-Q4 | TB-28: flip + register-conformity edit as M2 housekeeping; placement = closing paragraph of §4.3 | FROZEN |
| P1-Q5 | TB-11 → Discussion (null-security support) | FROZEN |
| R1 | H2 directional, retained and rejected; two-sided tension architecture in §2.2 | FROZEN (a) |
| R2 | O-A': RQ1–3 · H1+H2 only · no a/b split · 2.3 consolidated section without H3+ · anchors §3 · featured set unchanged | FROZEN |
| R3 | TB-64 adopted into the composition/boundary paragraph (Ch. 5) | FROZEN (a) |
| R4 | Title family = question form ("Did the Paris Agreement Reprice Environmental Responsibility in Credit Markets? …"); final wording M6 | FROZEN (a) |
| R5 | Repro/OSF package scope | **DEFERRED → M7** |
| R6 | TB-46 → Results §4.2 | FROZEN (a) |
| R7 | overlap note → `docs/` | FROZEN (a) |

---

## 9. Draft-20260612 audit summary (P1 §3b)

**Three fault lines** (each submission-blocking): **I Framing** — directional H2/RQ2, one-sided §2.2, contingent-moderation discussion vs. DEC-044/047. **II Data & methods** — 66 studies / 1,306 ES; HO-1985 RE on ES level without a dependence model; winsorized primary spec (contra DEC-013(a): unwinsorized = headline); SAMD outliers (excluded per DEC-031a.4); QB subgroups; "Model 10"; end-anchored Paris coding as baseline. **III Core claims** — r = −0.020 and I² = 0.000 ("near-complete homogeneity") vs. final r = −0.059 with dominant heterogeneity; draft's significant subgroup stories (bank-Paris, bond inversion QB = 11.3, 2.5× industry, regulation paradox) all non-replicating under the final HTZ family → every passage built on them collapses.

**Per-chapter verdicts:** Ch. 1 re-anchor (~50% rebuild; RQ/promise/contributions; first-claim to be evidenced; #35 gap builder). Ch. 2 substance holds, architecture does not (2.2 one-way street; counter-mechanisms already in the draft but misplaced as ad-hoc discussion explanations — pull forward into 2.2). Ch. 3 rebuild with reusable core (inclusion criteria + fn. 1–3; database list; Appendix-1 search strings; coding footnotes as Table-1 basis); **zero PRISMA substance** (A-risk; #16). Ch. 4 rebuild via TB assembly. Ch. 5 rebuild with two reusable germ paragraphs ("significance ≠ materiality" → Tier-2; "may not have operated as structural repricing" → replaced by TB-55, note banned-family proximity); draft limitation 2 inverted into a strength (T2/TH_c); limitation 5 obsolete.

**Anticipated referee lines + preemptive fixes:** (1) "null = absence of evidence" → pre-registered SESOI/TOST (TB-38), power (TB-47/11), permutation/multiverse (TB-48–51), RoBMA sensitivity (TB-53/54), register vocabulary. (2) "no theoretical contribution if nothing moderates" → §2.2 adjudication architecture; #35 gap; boundary narrative (TB-59/61/64). (3) "−0.059 is tiny" → TB-05 benchmark + TB-08 bp translation (#37) + TB-06 PI span as the substantive message.

---

## 10. External inputs & gates

| Item | Content | Gate | Status |
|---|---|---|---|
| #16 | PRISMA basics (search date, databases, hit/screening counts, inter-coder) | M1 | requested 2026-07-31 (C1 package to Volker) |
| #23 | Capelle-Blancard PRISMA note + drop-one sensitivity note | M1 (note slot) | requested 2026-07-31 |
| #37 | SD(COD) benchmarks per instrument → TB-08 | M2 | requested 2026-07-31 |
| #33 | 2021 search metadata; else waiver | M7 (waiver decision) | archive search requested 2026-07-31 |
| #17 | lookup upkeep | non-blocking | open |
| R5 | repro/OSF scope | M7 | deferred |

---

## 11. Housekeeping & known defects

- Status `Update_Scoping` I23 stored-formula defect: **fixed in this commit** (text cell).
- T8 workbook TB-28 stale "BLOCKED — Pending-C": flip + register-conformity edit scheduled **M2**.
- TH_b `4_Formula_Reference` B6/B8/B9 stored-formula defects: micro-fix at the **M5** workbook touch.
- Workbook run-banner rows (2–3) remain at run-time provenance wording (historical record); per-block Note fields carry the DEC-047 state.
- TB-29 gap and TB-68 supersession: documented here; no action.
