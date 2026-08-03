# M-Phase Positioning Map — FOMA CER–COD–Paris (P1 output) — v1.1

Authored in the M session (P1), 2026-08-01; **v1.1 revision authored in the M2 session, 2026-08-02.** Governing entries: **DEC-052** (v1.0) · **DEC-053** (RQ4 corrigendum; vocabulary conventions) · **the M2 chapter DEC DEC-054** (skeleton-v2 corrigendum, authorized by the M-hub ack of 2026-08-02, cited verbatim there). This file is the **single source** for the TB→chapter mapping, the frozen RQ/H anchors, the vocabulary zones, the single-home register, and the M1–M7 sequencing. Chapter sessions work against this map; changes to frozen items require a corrigendum DEC with ripple check.

Authority chain: claim architecture per [DEC-044] (Framing A) and [DEC-047] (equivalence register); moderator design per [DEC-043]/[DEC-048]; this map adds the manuscript-side architecture only. Result-blind discipline has served its purpose; reporting is licensed within the DEC-047 register.

**v1.1 changelog (2026-08-02):**
1. *DEC-053 sync:* RQ4 added to §3 (DRAFT wording; freeze at M4 per the DEC-053 ripple inventory); "pre-registered" → "pre-specified" at all five map sites (§3 rules ×2, §4 ×2, §9 ×1); terminology conventions per DEC-053 recorded (CHE–RVE model term; NEC = "not elsewhere classified" in prose/tables — no further textual sites in this map); DEC-053 TB-supersession-register note added under §5.
2. *Skeleton-v2 corrigendum (M-hub ack 2026-08-02):* Ch. 4 restructured to four RQ-symmetric sections (§2); amends P1-Q1 (skeleton), P1-Q4 (TB-28 → closing paragraph of §4.2.3; non-register-voice protection per §6 unchanged), P1-Q2' (renumber only: D6 table → end of §4.4). Renumber sites executed: §6 D6 line, §7 M2 row, §8 P1-Q2'/P1-Q4 rows. The §4.2 references (§1 vocabulary zone; §6 TB-55 and overlap lines; §8 R6) remain verbatim valid.
3. *TB-44 realign (hub pin h, adopted):* Results home §4.2 → §4.4 — ch3 §3.3.3 declares the conditional p-curve as the fourth publication-bias method; the results home follows the methods declaration.
4. *Binding drafting pins* (hub ack a–h) recorded at the end of §8; gate (e) executed 2026-08-02 with zero hard-section-number hits across all ten workbooks (TB-07 [B1] placeholder resolves to §4.2).

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

## 2. Chapter skeleton (v2 — frozen per the M2 corrigendum; supersedes the P1-Q1 v1 skeleton)

1 Introduction · 2 Theory & hypotheses (**2.1** CER→COD / H1 · **2.2** Paris / H2 · **2.3** Moderating contexts, consolidated) · 3 Methods · 4 Results, four RQ-symmetric sections (**4.1** The pooled CER–COD association, RQ1 — **4.1.1** headline & heterogeneity · **4.1.2** robustness & outlier register — **4.2** The Paris contrast, RQ2 — **4.2.1** contrast & equivalence · **4.2.2** Bayesian model averaging · **4.2.3** identification · **4.2.4** permutation & multiverse — **4.3** Moderator analysis, RQ3 · **4.4** Publication-bias analyses, RQ4, D6 table at end) · 5 Discussion & conclusion · Online appendix. Abstract written last. Subsection headings are written out (pin b); heading wording is finalized at the unit drafts (word-level polish).

---

## 3. RQ / hypothesis anchors (frozen wordings, R2 = O-A'; RQ4 added per DEC-053)

| Anchor | Wording (EN) |
|---|---|
| RQ1 | Is CER negatively associated with firms' cost of debt? |
| RQ2 | Has the Paris Agreement moderated the CER–COD relationship? |
| RQ3 | How does the CER–COD association vary across measurement, instrument, industry, regulatory, and country contexts — and does the Paris-period contrast itself vary across these dimensions? |
| RQ4 | Is the pooled CER–COD association robust to publication selection? *(DRAFT wording per the DEC-053 ripple inventory; freeze at M4)* |
| H1 | CER is negatively associated with firms' cost of debt. |
| H2 | The negative association between CER and COD is stronger in the post-Paris period than in the pre-Paris period. |

Rules: formal hypotheses = H1 + H2 only; **no H3+**; no H2a/H2b split (the equivalence test, the identification battery, and the Bayesian sensitivity are pre-specified probe strands of H2, not separate hypotheses; also avoids collision with the battery-internal H2a/H2b RoBMA labels). H2 is retained directionally and rejected in favour of the equivalence conclusion (R1). RQ3 is answered by the pre-specified two-tier heterogeneity analysis (levels inventory + Holm interaction family), declared as such in Methods. RQ4 is answered by the publication-bias battery (declared in Section 3.3.3; results home §4.4). Ch.-4 spine (skeleton v2): §4.1↔RQ1 · §4.2↔RQ2 · §4.3↔RQ3 · §4.4↔RQ4. Cutoff/coding definitions live in Methods (TB-16), not in the H wording. Word-level polish permitted in chapter sessions; structure and content of these anchors are frozen.

---

## 4. Section 2.3 build plan (R2 = O-A')

One consolidated section, four paragraph blocks in featured depth, then one collective paragraph:

1. **COD instrument** — fullest block; draft-§2.3 substance; expectation: association strongest in relationship (bank) lending.
2. **CER measurement** — new, short; performance- vs. disclosure-based operationalization as an information-channel argument.
3. **Carbon regulation** — draft-§2.4 condensed.
4. **Country / institutional context** — short; compositionally motivated (links to the identification narrative).
5. **Collective paragraph** — remaining pre-specified dimensions: industry sensitivity (draft-§2.5 core argument in two sentences), economic development, cultural cluster, legal origin.

Directional expectations may stand as prose ("we expect …"), **no H numbers**. Closing sentence of 2.3: "These expectations structure RQ3; the pre-specified analysis examines both whether the association varies across these dimensions and whether the Paris-period contrast does."

Featured reporting set (prose prominence, per DEC-048 [R1] as amended by DEC-054): {CER_measure, COD_instrument, regulation3, country_region} featured in the main-text prose; **main-text Table 3 reports all eight panels (both tiers, level-granular incl. per-level Paris shifts + Holm note; M-T3 variant L)**; the separate appendix panel table is dropped; the 15 pairwise contrasts move to Appendix Table A.1.

---

## 5. TB → chapter map v1.1 (frozen at range + item level; Ch.-4 rows per skeleton v2)

71 slots · 66 active · gap TB-29 (documented, never assigned, no renumbering) · TB-68 superseded (do not use). Source rule: **TB-65 and the TB-68 disposition are taken from the TF workbook; TB-66/67 from TG.** READY blocks are used verbatim (workbooks are the source of record); DRAFT blocks are finalized in their scheduled session. DEC-053 supersession family: "pre-registered" → "pre-specified" is applied at chapter use; swapped Methods TBs are listed in DEC-053, swapped Results TBs in the M2 DEC.

| Chapter | TB blocks | Notes |
|---|---|---|
| 1 Introduction | 45 · gap builder #35 (no TB: 73/115 studies span the break, 72 pool across it, 1 splits) | promise rebuild per audit |
| 2 Theory | — (no result TBs) | anchors §3; build plan §4 |
| 3 Methods | 01, 02, 03 · 16, 17, 18 · 20 · 30 · 38 · 52 · 57, 63 · 47 (dual with App) · #36 overlap prose (from docs/overlap_disclosure_v12.md, no TB) | 13 READY blocks; gaps only [PENDING #16], [PENDING #23 note], [PENDING R5] |
| 4.1 Pooled (RQ1) | **4.1.1:** 04, 05, 06 · **08 BLOCKED until #37** (economic translation; Tier-2-bearing; feeds Ch. 1/5) — **4.1.2:** 65(TF), 66, 67 · 69, 70 · 09 (register overview; Δ-vs-headline home) | 4.1.2 compact: overview prose + register table; LOO/influence detail stays Appendix [pin a] |
| 4.2 Paris (RQ2) | **4.2.1:** 07 (opener; relocated from §4.1 per DEC-054, closing pointer sentence superseded [E-9], resolves the [B1] note) · 13 · 14, 15 · 40 · 36, 37 · 46 (R6) — **4.2.2:** 53, 54 · 43 (carries the single overlap cross-ref) — **4.2.3:** 21–26 · 39 · 28 (after flip; closing paragraph [pin c]) — **4.2.4:** 48–51 · 41, 42 (finalized M2; figure-coupled resolved, Figures 4/5) — 19 → Appendix (multiverse panel line) | core vocabulary zone; TB-55 cross-reference finalized at §4.2 close (last sentence of the 4.2 conclusion) [pin d] |
| 4.3 Moderators (RQ3) | 58, 59, 60, 61 · 62 | main-text Table 3 = all eight panels, both tiers (M-T3 variant L); prose prominence featured four; loan-vs-bond descriptive; pairwise inventory → Appendix Table A.1 |
| 4.4 Publication bias (RQ4) | 31, 32, 34 · 44 (realigned per pin h) · D6 table (Table 4) directly after the section opener [author ruling at the unit draft, DEC-054; supersedes the 'end of section' placement] | 33 → App (period FAT-PET-PEESE panel) |
| 5 Discussion | **55 (register voice, single home)** · 35 · 27 · 56 (DRAFT) · 64 (DRAFT; composition/boundary paragraph, R3) · 11 (power/null-security, P1-Q5) · TH.md verdict sentence (M authorship) | |
| Appendix | 10 · 33 · 47 · 71 · 19 (multiverse panel line) · pairwise inventory (Table A.1) · LOO/influence tables · any-with line · Figures A1 (forest) / A2 (funnel) · PRISMA flow | |
| Abstract | 12 (DRAFT, last) | R4 title family |

---

## 6. Single-home register

- TB-55 = the register decision, voiced once in Ch. 5; **exactly one** Results cross-reference (from §4.2).
- TB-28 = identification/moves synthesis, **not** a second register voice (register-conformity edit at flip).
- Overlap tiers (7/120 · 6/115 · 5/113 · 60/2,713 ≈ 2.2% · 0 shared ES): home = Methods self-overlap paragraph; §4.2 carries one cross-reference via TB-43 (H9).
- composition_adj / trend_composition: canonical home T8/B5; T7 references only.
- Prediction intervals: home A.8/T1 (TB-02/06); no PIs elsewhere.
- LOSO-post cell: home T2/B6; TF register cross-references.
- D6 triangulation table (Table 4): one location (§4.4, directly after the opener); TB-35 prose in Ch. 5 references it.
- BF01 = 8.49: sensitivity bracket only, never a headline anywhere.
- Δ-vs-headline comparisons: robustness register only.

---

## 7. Session plan M1–M7 (frozen, author sequence 3→4→1→2→5→Abstract)

| Session | Chapter / task | DRAFT & housekeeping | Gates |
|---|---|---|---|
| **M1** | Ch. 3 Methods assembly (13 TBs + battery pins + #36 paragraph + O-A' declaration paragraph); PRISMA section at block end | Data-availability slot [PENDING R5]; #23 PRISMA note slot | **#16** ([PENDING #16] slots if absent at start); Fig. 2 PRISMA flow gated |
| **M2** | Ch. 4 Results (§4.1–§4.4 per skeleton v2); figures: forest/funnel rebuilt, TB-41/42 figures | Finalize TB-41/42, TB-46; **T8 workbook: TB-28 flip BLOCKED→READY + register-conformity edit** (placement = closing paragraph of §4.2.3); TH.md verdict sentence | **#37** → TB-08 ([PENDING #37] if absent; rest of §4.1 proceeds) |
| **M3** | Ch. 1 Introduction (RQ block, promise/contributions, #35 gap + TB-45, novelty scan & COE/Zarea positioning) | — | — |
| **M4** | Ch. 2 (2.1/2.2 rebuild with the two-sided tension architecture per R1; 2.3 per §4 build plan; Fig. 1 framework update) | — | — |
| **M5** | Ch. 5 (build around TB-55/35/27/11; boundary paragraph TB-61+64) | Finalize TB-56, TB-64; TH_b workbook touch → micro-fix inherited 4_Formula_Reference B6/B8/B9 | — |
| **M6** | Abstract + title (R4 family); finalize TB-12 | — | — |
| **M7** | Pre-submission gate: **R5 ruling** · vocabulary-zone scan (whole manuscript) · single-home check · numbers consistency pass · #33 waiver decision · Ch.-2 pass-2 B-level quality check · references/format (author's closing pass) | — | R5 |

Manuscript file layout (DEC-052.i): `manuscript/` directory, one Markdown file per chapter (`ch1_introduction.md` … `ch5_discussion.md`, `abstract_title.md`); docx assembly at M7.

**Manuscript pipeline (concretizes DEC-052.i; hub ruling 2026-08-03, cited in DEC-054):** `manuscript/*.md` is the single source of truth through M6. Word files before M7 are disposable review exports only (generated container-side from the committed .md, provenance line "generated from <file> @ <commit>; comments only"); co-author comments are worked back into the .md. At M7, a one-time container-side assembly (pandoc + reference template; footnotes and heading styles mapped; reference ledger rendered as formatted bibliography) produces the submission .docx; from then on the .docx is the source of truth and the .md tree is frozen with a repo tag. The 20260612 draft is reference material only — no direct editing into it. Manuscript tables are build artifacts: generated from the committed results CSVs by session scripts (analysis_id::spec::term keys; rounding/both-scales conventions; provenance comments), placed as Markdown tables in the chapter files, converted to journal-style Word tables at assembly. No hand-transcription, no Excel intermediate. Figures follow the same rule (R/14: build artifacts from committed CSVs/prep; no re-estimation).

---

## 8. Ruling register (P1; skeleton-v2 amendments per the M2 corrigendum)

| ID | Ruling | Status |
|---|---|---|
| P1-Q1 | Chapter skeleton incl. "5 = Discussion + Conclusion" and online-appendix zone; **skeleton v2 per §2 (four RQ-symmetric Results sections)** | FROZEN (amended M2) |
| P1-Q2' | D6 **table** at end of §4.4; TB-35 **prose** in Ch. 5 | FROZEN (renumbered M2) |
| P1-Q4 | TB-28: flip + register-conformity edit as M2 housekeeping; placement = closing paragraph of §4.2.3 | FROZEN (amended M2) |
| P1-Q5 | TB-11 → Discussion (null-security support) | FROZEN |
| R1 | H2 directional, retained and rejected; two-sided tension architecture in §2.2 | FROZEN (a) |
| R2 | O-A': RQ1–3 · H1+H2 only · no a/b split · 2.3 consolidated section without H3+ · anchors §3 · featured set unchanged | FROZEN |
| R3 | TB-64 adopted into the composition/boundary paragraph (Ch. 5) | FROZEN (a) |
| R4 | Title family = question form ("Did the Paris Agreement Reprice Environmental Responsibility in Credit Markets? …"); final wording M6 | FROZEN (a) |
| R5 | Repro/OSF package scope | **DEFERRED → M7** |
| R6 | TB-46 → Results §4.2 | FROZEN (a) |
| R7 | overlap note → `docs/` | FROZEN (a) |

**M2 skeleton-v2 drafting pins (hub ack 2026-08-02, binding):**
(a) §4.1.2 compact — overview prose + register table; LOO/influence detail stays Appendix. (b) Subsection headings written out. (c) TB-28 closes §4.2.3, not §4.2. (d) The single licensed TB-55 cross-reference: default home = close of §4.2 (after 4.2.4); final micro-ruling at the 4.2 draft; exactly one occurrence chapter-wide. (e) Pre-draft gate: MTB full-text grep for hard section numbers + TB-07 bridge check — executed 2026-08-02, zero hard-reference hits in the chapter-text column across all ten workbooks (three "Results 4.1" metadata labels in T1 remain valid under v2); TB-07 [B1] placeholder resolves to §4.2. (f) BOOTSTRAP_M2_SESSION.md lifted to v2.1 (skeleton-v2 numbering) before the package commit. (g) ch3 line-35 micro-edit "(Section 4.6 …)" → "(Section 4.1.2 …)" ships in the M2 package (F3-class, logged in the M2 DEC). (h) TB-44 realigned to §4.4 (adopted; changelog no. 3).

---

## 9. Draft-20260612 audit summary (P1 §3b)

**Three fault lines** (each submission-blocking): **I Framing** — directional H2/RQ2, one-sided §2.2, contingent-moderation discussion vs. DEC-044/047. **II Data & methods** — 66 studies / 1,306 ES; HO-1985 RE on ES level without a dependence model; winsorized primary spec (contra DEC-013(a): unwinsorized = headline); SAMD outliers (excluded per DEC-031a.4); QB subgroups; "Model 10"; end-anchored Paris coding as baseline. **III Core claims** — r = −0.020 and I² = 0.000 ("near-complete homogeneity") vs. final r = −0.059 with dominant heterogeneity; draft's significant subgroup stories (bank-Paris, bond inversion QB = 11.3, 2.5× industry, regulation paradox) all non-replicating under the final HTZ family → every passage built on them collapses.

**Per-chapter verdicts:** Ch. 1 re-anchor (~50% rebuild; RQ/promise/contributions; first-claim to be evidenced; #35 gap builder). Ch. 2 substance holds, architecture does not (2.2 one-way street; counter-mechanisms already in the draft but misplaced as ad-hoc discussion explanations — pull forward into 2.2). Ch. 3 rebuild with reusable core (inclusion criteria + fn. 1–3; database list; Appendix-1 search strings; coding footnotes as Table-1 basis); **zero PRISMA substance** (A-risk; #16). Ch. 4 rebuild via TB assembly. Ch. 5 rebuild with two reusable germ paragraphs ("significance ≠ materiality" → Tier-2; "may not have operated as structural repricing" → replaced by TB-55, note banned-family proximity); draft limitation 2 inverted into a strength (T2/TH_c); limitation 5 obsolete.

**Anticipated referee lines + preemptive fixes:** (1) "null = absence of evidence" → pre-specified SESOI/TOST (TB-38), power (TB-47/11), permutation/multiverse (TB-48–51), RoBMA sensitivity (TB-53/54), register vocabulary. (2) "no theoretical contribution if nothing moderates" → §2.2 adjudication architecture; #35 gap; boundary narrative (TB-59/61/64). (3) "−0.059 is tiny" → TB-05 benchmark + TB-08 bp translation (#37) + TB-06 PI span as the substantive message.

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
