# COE-Companion Overlap Disclosure — v12 Verification Note (C2)

Authored in the Companion chat, 2026-07-31. Task: Datenagenda #36 (COE-overlap refresh on the final 120-study corpus). Language: English (artifact convention). Status: verification PASS · Methods prose = DRAFT input for the M session (no TB number minted here; TB numbering is workbook-based).

---

## 1. Central finding — #36 is superseded, not open

The re-derivation that #36 requests **already exists canonically**: DEC-045 (Overlap disclosure, H-Q10 v2 / H-Q19, 2026-07-22, "supersedes Datenagenda #11") derived the v12 overlap with author adjudication (Lemma identity incl. veto window; Shad year identity per the F22 cross-note) and pinned the three-tier disclosure. Producing a second independent derivation as a *competing* number set would violate the single-home rule. This document therefore delivers what #36 still legitimately needs: (a) an **independent verification** of the DEC-045 numbers against the COE full text and the v12 workbook, and (b) the **Methods-ready prose block**. The numbers' single home remains DEC-045; the manuscript home is the Methods self-overlap paragraph (DEC-011 guardrail), with the H9/N12 Results sentence cross-referencing, not duplicating, the tiers.

## 2. Canonical numbers under verification (DEC-045, verbatim basis)

Seven overlap studies on v12: **Chava (2014) · Chen, Gao (2011)** [= Chen & Silva-Gao 2011] **· Li et al (2014) · Shad et al (2022)** [COE: Shad et al. 2020; identical per F22] **· Lemma et al (2017)** [COE: Lemma et al. 2019; identity per v8 adjudication] **· Ng & Rezaee (2012) · Ould Daoud Ellili (2020)**.
Tiers: **7/120 corpus · 6/115 estimation set** (Ould Daoud: 0 estimation rows) **· 5/113 period domain** (additionally without Ng & Rezaee; its 6 estimation ES are all pp-NA [DEC-042b]).
ES level: **60/2,713 estimation ES ≈ 2.2 %** (Chava 22 · Li 18 · Lemma 8 · Ng & Rezaee 6 · Chen–Gao 4 · Shad 2) · **0 shared effect sizes** (disjoint estimands). Predecessor baseline (log-verified): 5/66 studies, 42/1,306 ES (3.2 %), v8 basis, Datenagenda #11.

## 3. Verification protocol and results

Sources: COE companion full text (PK container, 29 pages, text layer) · `CERCOD_data_v12.xlsx` (data 2,852 rows; lookup 120 studies) · `DECISION_LOG.md`.

| # | Check | Result |
|---|---|---|
| V1 | COE included-study list reconstruction: asterisk-marked references (endnote 19 convention), junk-line cleaning, entry rebuild incl. multi-word surnames | **66 asterisked publications** extracted; count audit 66/66 (0 p-value footnotes inside the References section) — PASS |
| V2 | All seven DEC-045 studies present on the COE side | 7/7 found, incl. `*Ould Daoud Ellili, N. 2020` and `*Chen, L. H., and L. Silva-Gao. 2011`; Trinks 2017b correctly **un**starred — PASS |
| V3 | All seven study keys present in the v12 corpus (lookup, 120 studies) | 7/7 → corpus tier **7/120** — PASS |
| V4 | Per-study usable rows (`d_es_usable`) equal the DEC-045 estimation-ES split | Chava (2014) 22 · Li 18 · Lemma 8 · Ng & Rezaee 6 (of 7 corpus rows) · Chen–Gao 4 · Shad 2 → **Σ = 60** — PASS |
| V5 | Period-domain arithmetic: studies whose usable rows are entirely pp-NA | Exactly two — Bhattacharya & Sharma (2019), 2 ES · Ng & Rezaee (2012), 6 ES → 2,713−8 = **2,705** ES · 115−2 = **113** studies · 114−2 = **112** clusters, matching the DEC-045 E2 domain; overlap tier 7 − Ould(0 est.) − Ng(pp-NA) = **5/113** — PASS |
| V6 | Chava footnote | Chava (2010) and Chava (2014) are separate studies **and** separate cluster_ids in v12; COE lists only 2014 — PASS |
| V7 | Predecessor baseline | Datenagenda-#11 closure text in the log: 5/66 · 42/1,306 · 3.2 % · named seeds — PASS |
| V8 | Global estimation-set membership (2,713/115/114) | **Delegated, disclosed:** the membership rule is a dat_prep derivation (T0.4, verifier 28/28, md5 `6702ef3d…`), not stored in the xlsx (lookup `n_rows` = corpus rows, Σ 2,852; `d_es_usable` = 2,730/117 is the pre-final usability layer). Every workbook-derivable consequence of the membership (V4, V5) reproduces exactly; the rule itself is warranted by the verified pipeline, not re-implemented here. |

**Verdict: DEC-045 disclosure verified — no discrepancy in any independently derivable quantity.**

## 4. COE-side observation (no COD action)

The COE paper reports **75 studies / 1,139 effect sizes** and states (endnote 19) that included studies are asterisk-marked in the reference list; the published text layer carries **66** asterisked publications. The delta is a COE-internal counting layer (samples/units vs. publications; cf. Trinks 2017a starred, 2017b unstarred) and does not affect the COD-side disclosure, which matches on publications and cites the COE corpus as reported (75 units, k = 1,139, per the H9 pin). Flagged for author awareness only, as the author of both papers.

## 5. Methods-ready disclosure prose (DRAFT — for M-session placement)

> Five of the authors are also authors of a companion meta-analysis of the CER–cost-of-equity relationship (Witte et al. 2026); we disclose the corpus overlap in full. Seven of the 120 corpus studies also appear in the companion's included-study list (Chava 2014; Chen and Silva-Gao 2011; Li et al. 2014; Shad et al. 2022, published 2020 in the companion's citation; Lemma et al. 2017, cited there as 2019; Ng and Rezaee 2012; Ould Daoud Ellili 2020). Six of these enter the estimation set (6/115; Ould Daoud Ellili contributes no estimable effect sizes), and five the Paris-period domain (5/113; Ng and Rezaee report no sample-window information). At the effect-size level the overlapping studies contribute 60 of 2,713 estimates (2.2 %). No effect size is shared between the two papers: the companion analyzes cost-of-equity estimands, this study cost-of-debt estimands, and both extraction protocols enforce disjoint outcome sets.

Placement notes: (i) author-count phrase ("Five of the authors…") is a placeholder — set to the actual author overlap at drafting; (ii) the year cross-notes may move to a footnote; (iii) the Chava 2010/2014 distinction is available as an optional footnote: *"The corpus additionally contains Chava (2010), an earlier unpublished sample (1990–2008) coded as a separate cluster; the companion includes only the published 2014 study."*; (iv) the H9/N12 Results sentence references these tiers — do not restate them there (single home).

## 6. Disposition recommendations

1. **Datenagenda #36 → close** with the string: `superseded by DEC-045 (H-Q10 v2/H-Q19) — v12 re-derivation canonical there; independent verification note on file (2026-07-31); Methods prose = M-session input`. Status touch rides along with the next commit package (no standalone commit).
2. **DEC-031b's historical "5/66" citation stays untouched** (append-only log; the entry was correct on its v8 basis and DEC-045 records the supersession).
3. **This file** → propose `docs/overlap_disclosure_v12.md` (or `manuscript\` per the W-session feed-home ruling — author's call), ride-along in the next commit package.
