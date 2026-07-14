# Results workbook template — FOMA CER–COD (per-run, binding)

Per Setup §5/§7. One workbook per RUN (`output/Tx_results_workbook.xlsx`), never per block and never a growing consolidated file. Built by the project chat post-run from `output/Tx_results.csv`; the verifier never reads the workbook. Instantiations: T1 (commit ce5d80b), T2 (commit 20a4e90).

## Tab structure (fixed order; `N_Label` names — digit prefix means: QUOTE the sheet name in cross-references)

1. **1_README** — 3-line title block (project/run · template pointer · run stamp + verifier result); `Item | Value` table (version, method one-liner, scope, repo, computational stack, scripts, decision basis); TAB-INDEX listing every tab.
2. **2_Methodology** — `Quantity | Formula / Construction | Reference` (source pointers in project notation: [DEC-nnn], [F-nn], [plan §x], paper cites).
3. **3_Interpretation_Guide** — `Quantity | Meaning | Decision rule` (how to read each reported quantity; thresholds with citations, e.g. Tipton df ≥ 4, Doucouliagos 0.07).
4. **4_Formula_Reference** — `Quantity | R call | Reference / script section` (exact calls as implemented).
5. **5_Data_Provenance** — `Item | Value | Source` (estimation set + domain, dat_prep md5, pr$n/pr$seed, spec revision, run timestamp + runtime, verifier line incl. notable check details, semantics pins, design cross-checks, known warnings).
6. **…N — one numbered result tab per analysis theme**, each with the fixed pattern: 3-line title block → estimate table (**both scales z and r** where applicable; difference-of-z rows are z-only by convention, est_r = NA) → **Interpretation** block (short prose lines) → **Reviewer Q&A** block (`Question | Answer`, navy header row) → **Verdict** sentence (bold, one line).
7. **Results_Long** — verbatim transport of the run CSV (full precision, all columns/rows; navy header, freeze `A2`, autofilter). **This tab is the single formula source for every derived cell in the workbook.**
8. **Manuscript_Inputs** — ms_input = TRUE rows only; **every cell formula-derived** from Results_Long (paste-ready strings via `TEXT()`; p-values via `IF(p<0.0001,"< 0.0001",TEXT(...))`; k-strings concatenated).
9. **Manuscript_Text_Blocks** — copy-paste-ready English prose: `ID | Target section | Status | Text (EN) | Source pointers | Note`. IDs **TB-nn continue across runs** (T1 = TB-01..12, T2 = TB-13..19, next run continues). Status traffic light: READY (green) / BLOCKED — DEC-xxx (red) / DRAFT (amber). Prose framing-neutral until Ablauf 3b. Numbers here are hardcoded WITH a provenance line in the tab header ("regenerate on any re-run"); the formula-live layer is Manuscript_Inputs.

## Style constants

Arial 10 throughout; header rows white bold on navy `#1F3864`; thin bottom borders `#D9D9D9`; wrap on prose cells; number formats: estimates/CIs `0.0000`, variances `0.00E+00`, df `0.0`, shares `0.0%`, signed contrasts `+0.0000;-0.0000`.

## Formula rules

Derived quantities (Δ, %Δ, CI-overlap, formatted strings) by FORMULA from `'Results_Long'`, never hardcoded — EXCEPT tab Manuscript_Text_Blocks (see above). No `XLOOKUP/FILTER/SORT/UNIQUE` (LibreOffice recalc); `INDEX/MATCH` where lookups are needed. Mandatory recalc pass (`scripts/recalc.py`) with 0 errors, plus a 2–3-cell spot verification against the CSV. Pairwise Δ-vs-headline columns ONLY where methodologically licensed — never for nested-subset coding models [DEC-031a.6].

## Sensitivity-sheet layout (where a spec panel exists)

`Spec | k | est_z | CI_z | est_r | CI_r | df | p` (+ Δ/%Δ/overlap only if licensed), reference row first, Verdict line below the panel.
