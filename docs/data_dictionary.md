# Data Dictionary — `cer_cod_prepared` (T0.4)

Provisional analysis-ready dataset produced by [`R/01_prep.R`](../R/01_prep.R)
from `data/CER-COD_data_v1.xlsx` (sheet `Tabelle1`). The processed files
(`data/processed/cer_cod_prepared.{rds,csv}`) are gitignored; this dictionary
is committed. Decision basis: DEC-002, DEC-005, DEC-013, DEC-015;
analysis_plan.md §1–§3, §6, §9.

**Shape:** 1306 effect sizes × 34 columns, 66 studies. No rows dropped.

## Columns

| column | type | derivation / meaning |
|---|---|---|
| `study` | chr | Study label incl. `(YYYY)` publication tag (cluster id). |
| `outcome_id` | num | Within-source outcome index (raw `outcome`). |
| `r` | num | Reported correlation (raw `corr`); **unaltered**. |
| `n` | num | Sample size as coded (raw `sample`); **unaltered** — see F2. |
| `z` | num | Fisher's z = `atanh(r)` [plan §2]. |
| `vz` | num | Sampling variance = `1/(n-3)` on n as coded. |
| `sez` | num | `sqrt(vz)` (used by FAT-PET-PEESE, plan §8). |
| `esid` | int | Global effect id for `~ 1 | study/esid` [DEC-002]. |
| `paris_end_lag0..3` | chr | Raw end-window Paris labels (`1_Post`/`0_Pre`). |
| `paris_median`,`paris_mean` | chr | Raw window-midpoint labels (`Post`/`Pre`). |
| `post_paris` | int | **HEADLINE** 0/1 from `paris_end_lag0` [DEC-005]. |
| `post_lag1..3` | int | 0/1 lag variants (coding-sensitivity panel). |
| `post_median`,`post_mean` | int | 0/1 window-midpoint variants. |
| `pub_year` | int | Publication year parsed from `study`; raw uncentred (E8 interim axis). |
| `pub_year_c` | num | **Provisional** centring: `pub_year` − 2018.538 (effect-level mean). Centring is **not locked** — definitive centring deferred to T8, which may recentre; the raw `pub_year` is retained so T8 can recentre without a re-prep. |
| `es_type` | fct | `bivariate`/`partial` (raw `ES_measure` B/P) [DEC-004]. |
| `cer_type` | fct | `Performance`/`Disclosure` (raw `CER_measure`). |
| `cod_instrument` | fct | `interest`/`rating`/`yields`/`derivativ`. |
| `sensitive_industry` | int | 1 = sensitive, 0 = not (raw `industry`). |
| `journal_high` | int | 1 = HIGH, 0 = LOW (raw `journal_q`). |
| `regulation_start` | fct | Raw `0/1/9/NA` — semantics deferred (F4, E9). |
| `regulation_end` | fct | Raw `0/1/9` — semantics deferred (F4, E9). |

## n-distribution [DEC-015]

- Median n = **289.05**; IQR ≈ [115.02, 599.33]; min = 5.5625, max = 11112.
- Share n < 200 = **37.4%**; count n < 100 = 311.

## Data-integrity flags (for the Volker extraction check)

### F1 — near-perfect extremes [DEC-013]
Implausible CER–COD correlations → source-verify (do **not** drop):

| esid | study | r | n |
|---|---|---|---|
| 409 | Devalle et al (2017) | 0.9998 | 56.0000 |
| 414 | Drago et al (2018) | -0.9977 | 184.0000 |

### F2 — non-integer n (n-derivation rule unknown)
**699/1306 (53.5%)** effects carry a fractional `n` (ratio-like → likely a
study total split across effects). **Volker: what is the n-derivation rule?**
Until resolved, T1 inverse-variance weights are provisional.

### F3 — n < 10 (fragile variance)
**9** effects have n < 10 → `vz = 1/(n-3)` is fragile. Smallest first:

| esid | study | r | n |
|---|---|---|---|
|  269 | Chodnicka-Jaworska (2022) | 0.0199 | 5.5625 |
| 1020 | Schneider (2010) | -0.5219 | 6.0000 |
|  518 | Fard et al (2020) | -0.1529 | 6.1600 |
|  519 | Fard et al (2020) | -0.0523 | 6.1600 |
|  520 | Fard et al (2020) | 0.0603 | 6.1600 |
|  521 | Fard et al (2020) | -0.0843 | 6.1600 |
| 1022 | Schneider (2010) | 0.1960 | 7.4545 |
| 1021 | Schneider (2010) | -0.4574 | 8.7273 |
|  275 | Chodnicka-Jaworska (2022) | 0.0694 | 9.0000 |

### F4 — regulation semantics unknown [E9]
`regulation_start`/`regulation_end` carry raw `0/1/9/NA`; the direction/
meaning is undefined, so **no regulation moderator is constructed** (plan §7).
Resolution gated on Volker (E9).

## Carved out — gated, NOT in this dataset
- **Sample-year `year_c`** (identification time axis, plan §4 / T8 Moves 1–2)
  — gated until Volker's sample years arrive; `pub_year` is the interim axis.
- **Regulation moderator** (plan §7) — gated until E9 (F4).
- **T1 weight trust** — provisional until F2 (n-rule) is resolved.

