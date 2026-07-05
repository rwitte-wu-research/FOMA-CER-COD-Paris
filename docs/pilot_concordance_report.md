# Blind-Pilot Concordance Report — Extraction Procedure v1 [DEC-032 §9]
Date: 2026-07-05 · Pilot papers: Atif et al (2021) · Capelle-Blancard et al (2019) · Yilmaz (2022) · Devalle et al (2017) — extracted blind in the dedicated extraction project; diffed here against CER-COD_data_v10.

## 1. Verdict: **PASS**
- **Extractor error count on statistical core fields (b/SE/t/p/n_obs, row identification): 0.**
- All 5 v10-matchable effect rows identified and reproduced (Atif 1/1 exact incl. t=−2.61/n=2036; Yilmaz r=−0.215/n=1375 exact; Devalle 3/3 with raw magnitudes consistent to source).
- The one v10 row not extracted (Capelle-Blancard) is a **correct rule application** (R2.1 firm-level gate), with the exact v10 source cell independently located as a near-miss (ENVI −0.030/0.040, t=−0.75 → r=−0.0395 = v10 value).
- FLAG discipline exemplary: no guessed field; every FLAG logged; the Devalle outcome-direction block is the two-step sign design working as intended.
- Beyond concordance, the pilot surfaced 3 v10 errata, 6 additional qualifying rows (rule-breadth finding), and 8 codebook clarification needs — see §3–§5.

## 2. Per-study diff

### Atif et al (2021) — v10: 1 row · extracted: 2 rows
| Item | v10 | Extraction | Classification |
|---|---|---|---|
| Bloomberg E→CDS | r=−0.057747 (t impl. −2.610, n=2036) | t=−2.61, n=2036, Tab.11 Col5 | ✓ exact |
| CER_measure | performance | disclosure (paper's explicit §6.4 framing; internal inconsistency logged) | v10 coding divergence → Volker (F35c) |
| Asset4 E→CDS (Tab.12 Col7, t=−2.63, n=4725) | — absent — | extracted | **v10 under-extraction vs all-models rule** (F35f) |
| regulation start/end | with / without ETS/CT | without / without (+ sub-national note) | **v10 erratum candidate** — US has no national ETS/CT 2006 or 2017; v10 pattern looks inverted (F35b) |
| no_firms | 170 calculated (2036/12) | derive downstream | ✓ same convention |

### Capelle-Blancard et al (2019) — v10: 1 row · extracted: 0 rows (gate)
| Item | v10 | Extraction | Classification |
|---|---|---|---|
| ENVI(lag)→10Y sovereign spread | r=−0.039498 = b/SE −0.030/0.040 (t=−0.75) | identified as near-miss with exact provenance; excluded per R2.1 (country-level construct, sovereign issuer) | **Scope finding: original corpus includes one sovereign-level study; codebook v1 is firm-level** (F35e) |
| no_firms | 21 coded | 20 countries (verbatim list) | v10 erratum candidate 21 vs 20 (F35d) |
| sample_end | 2012 | FLAG (paper internally inconsistent 2012 vs 2014; N counts 340/360/380) | legitimate FLAG; v10 chose 2012 |

### Yilmaz (2022) — v10: 1 row · extracted: 4 rows
| Item | v10 | Extraction | Classification |
|---|---|---|---|
| r(COD, ES) | −0.215, n=1375 | −0.215, n=1375, Tab.5 | ✓ exact |
| Pooled/RE/GMM ES→COD (t=−2.62 / +0.62 / +14.78) | — absent — | extracted (GMM n=FLAG, correctly not derived) | **v10 under-extraction vs all-models rule** (F35f) |
| regulation fields | empty | FLAG (mixed 24-country sample, no rule) | consistent treatment; rule gap → F36 |
| country_econ/legal etc. | 99_NCE | 99_NCE | ✓ |

### Devalle et al (2017) — v10: 3 rows · extracted: 3 rows
| Item | v10 | Extraction | Classification |
|---|---|---|---|
| Route | (OR−1)/SE treated as b/SE, then harmonized | z from table (|z| + sign from OR≷1), b/SE deliberately empty | Extractor route statistically superior; delta-approx only valid near OR≈1 |
| Resource_Use | r=−0.088 (t=−0.662) | z=+0.67, outcome_direction=FLAG | raw magnitudes consistent (0.664 vs 0.67); sign difference = harmonization step, correctly deferred (paper's rating scale 1=AAA…7=CCC contradicts its own interpretation) |
| Emission | r=−0.146 (t=−1.101) | z=+1.11, FLAG | dito (1.106 vs 1.11) |
| Env_Innov | **r=+0.999831 (t impl. +406.9)** | z=−2.32, p=0.021; misprinted OR .0966 flagged | **HIGH-severity v10 erratum: pathological effect (r≈+1.0) from propagating a misprinted odds ratio through the (OR−1)/SE route** (F35a). Fisher-z ≈ 4.3 → real leverage despite 1/1306 |

## 3. Erratum / verification list → Volker (F35)
- **a. Devalle row 409 (HIGH):** r=+0.999831 from misprinted OR .0966009; replace via z-route (z=−2.32 per table; direction per F35-resolution of the rating-scale conflict). Must be fixed before any analysis run.
- b. Atif regulation_sample_start/end: with/without pattern vs US regulatory facts — verify and correct.
- c. Atif CER_measure: performance vs disclosure (Bloomberg E) — ruling with paper's §6.4 framing on record.
- d. Capelle no_firms 21 vs 20 countries.
- e. Sovereign-scope note: Capelle-Blancard is country-level; decide legacy-exception documentation (recommended) vs corpus action; add drop-one robustness note.
- f. **Extraction-breadth finding:** 2 of 4 pilot studies carry fewer rows than the all-models rule yields (Atif +1, Yilmaz +3). Recommendation: (i) document; (ii) corpus-segment dummy (original vs update) as robustness in v11 design — anticipates the reviewer question "do extraction densities differ across corpus segments?"; (iii) Volker decides whether a spot-audit of high-risk original-corpus studies is warranted.
- Resolution route: corrections land in v11 via prep with a dedicated DEC; v10 remains untouched (append-only history).

## 4. Codebook v1.1 clarification set (F36 — proposed rulings for confirmation)
- a. **N/A convention:** add `n/a (structural)` as distinct from FLAG for §1 fields that cannot exist for a design (no improvised use; Capelle case). *Proposed: yes.*
- b. **Mixed multi-country regulation fields:** rule = code by dominant coverage share of firm-years; if no clear dominance, `mixed` label (new closed-list value) instead of empty/FLAG. *Proposed: adopt `mixed`.*
- c. **country_region/econ/culture/legal for mixed samples:** confirm 99_NCE as the standing convention (v10-consistent, Yilmaz precedent); no dominance coding. *Proposed: confirm.*
- d. **Two-author studies:** study label "X & Y (Year)" where the corpus uses it (v10 precedent: Kim & Kim), else "X et al (Year)"; new extractions: "X & Y (Year)". *Proposed: adopt.*
- e. **Dynamic-panel GMM:** qualifies under R2.4 (robustness variant; CER not instrumented); n_obs=FLAG when not printed. *Proposed: confirm extractor's treatment.*
- f. **|z|-only tables:** ratify sign attribution from OR≷1 (deterministic, no computation); record z in t field; **prohibit the (OR−1)/SE-as-b/SE route** (Devalle lesson). *Proposed: adopt.*
- g. **Sub-national ETS (RGGI, California):** does not flip country-level `without ETS/CT`. *Proposed: confirm.*
- h. **Sovereign/unit-of-analysis:** R2.1 explicitly states firm-level unit; sovereign designs are out of scope for the update. *Proposed: confirm.*

## 5. Production go-conditions
1. F36 a–h confirmed (5 minutes; all have proposed rulings) → codebook v1.1 issued (clarifications only, no rule changes).
2. F35 list handed to Volker (non-blocking for production; blocking for the first analysis run: F35a).
3. Then: Cowork batch over the 51-candidate folder per the batch kickoff line; Volker verification per DEC-032.
