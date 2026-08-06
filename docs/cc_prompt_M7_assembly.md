# CC Contract — M7 docx Assembly (P6; authority: DEC-060 §8 · DEC-061 §5) — v1.2

v1.1 (post run 1): step 3 gains footnote-label namespacing (operation 7 —
run 1 produced a cross-file `[^1]` collision: ch1's footnote text was lost,
ch3's duplicated); §6 gains the no-duplicate-note-warning check and the
distinct-footnote check; the `PENDING #37` expectation is pinned to 3
(run-1 root cause accepted: the raw-source count of 6 includes three
comment-embedded header occurrences that pandoc strips by design).
v1.2: the reference's `Compact` cell style is now single-spaced 10 pt
(REFERENCE_MD5 updated below — re-verify 1c against the new value); step 3
gains operation 8 (strip the ch3 `## Table 1` navigation heading, which
rendered as a duplicate visible heading in run 1); §6 gains the
Compact-propagation check. Column-width fine-tuning and the landscape flip
for wide appendix panels remain Word-side polish per the cut-over design.

Single-use, deterministic build. Repo: `C:\R_Projects\FOMA-CER-COD-Paris`.
**Hard rules:** no git writes (no add/commit/tag/push), no edits to any tracked
file, no re-estimation, no R runs. All work in a temp tree outside the repo;
the only repo write is the output docx into `manuscript\build\`. On any STOP:
report the failing step with verbatim output and take no further steps.
Report language: English, verbatim tool output where specified.

```
EXPECTED_HEAD  = 2f3b0347deac77f753d24b2da6f89715c579c843
REFERENCE_MD5  = d22e0c9c9073c7cfa5e31b479c8c8579
OUTPUT_DOCX    = manuscript\build\FOMA-CER-COD-Paris_manuscript_v1.0.docx
```

## 0. Environment probe (report)
`git --version` · `pandoc --version` (>= 2.11 required) · `python --version`
plus `python -c "import docx; print(docx.__version__)"` (install `python-docx`
via pip if missing). If pandoc is unavailable in the VM, run it Windows-side
via CMD redirect (project convention); report which side executed.

## 1. Preflight (any FAIL => STOP)
a. `git rev-parse HEAD` == EXPECTED_HEAD.
b. `git status --porcelain -- manuscript docs R` empty except the known
   untracked set (R/13_*, bench_13_out.txt, data/benchmarks/,
   output/appendix_tables_A2_A4.md, manuscript/build/). Any *modified*
   tracked file => STOP.
c. MD5 of `manuscript\build\reference.docx` == REFERENCE_MD5 (certutil).
d. `dir output\figures` — verbatim listing into the report. Required PNGs:
   fig1_framework.png · T1_A7_caterpillar_cluster.png ·
   TH_a_H7_cumulative.png · TH_a_H8_rolling.png · D1_funnel_contour.png.
   Forest: T1_A8_forest_study.pdf (a png is expected to be ABSENT).
e. Forest raster: build a temp png from page 1 of T1_A8_forest_study.pdf at
   300 dpi (pdftoppm or magick, whichever exists). If neither tool exists:
   note it — step 3(5) then takes the placeholder branch, FLAG in the report.
f. Forest legend duty [DEC-061 §3]: view the rasterized forest page, transcribe
   its embedded caption/legend text VERBATIM into the report, and explicitly
   FLAG whether the string "3LMA-RVE" occurs (register: 0 occurrences in the
   manuscript text).
g. Attribution sweep [DEC-061 §5]: view TH_a_H7_cumulative.png,
   TH_a_H8_rolling.png, D1_funnel_contour.png and confirm for each:
   dashed line = pooled reference; no estimator-label text embedded.
   Report PASS/FAIL per figure.

## 2. Temp tree (outside the repo, e.g. %TEMP%\m7_assembly)
Copy — never move, never touch repo originals:
- `manuscript\abstract_title.md`, `ch1_introduction.md`, `ch2_theory.md`,
  `ch3_methods.md`, `ch4_results.md`, `ch5_discussion.md`,
  `references_consolidated.md`, `appendix.md`  ->  `TMP\manuscript\`
- `output\figures\*.png` (+ the forest raster from 1e, named
  `T1_A8_forest_study.png`)  ->  `TMP\output\figures\`

## 3. Deterministic transform (python, on the TMP copies only)
Six replacements; assert each incumbent occurs EXACTLY once in its file and
abort on any count != 1. Report the six assert results.

1. `ch2_theory.md`:
   `[Figure 1 about here]`
   -> `![](output/figures/fig1_framework.png)`
2. `ch4_results.md`:
   `<!-- FIGURE 3 artifact: output/figures/T1_A7_caterpillar_cluster.(pdf|png) [committed T1 plot; P4 visual check] -->`
   -> `![](output/figures/T1_A7_caterpillar_cluster.png)`
3. `ch4_results.md`:
   `<!-- FIGURE 4 artifact: output/figures/TH_a_H7_cumulative.(pdf|png) -->`
   -> `![](output/figures/TH_a_H7_cumulative.png)`
4. `ch4_results.md`:
   `<!-- FIGURE 5 artifact: output/figures/TH_a_H8_rolling.(pdf|png) -->`
   -> `![](output/figures/TH_a_H8_rolling.png)`
5. `appendix.md`:
   `[artifact: output/figures/T1_A8_forest_study.pdf]`
   -> `![](output/figures/T1_A8_forest_study.png)`
   — placeholder branch (only if 1e flagged no raster tool):
   -> `*[Figure A1 artifact: output/figures/T1_A8_forest_study.pdf — embedded at the polish pass]*`
6. `appendix.md`:
   `[artifact: output/figures/D1_funnel_contour.(pdf|png)]`
   -> `![](output/figures/D1_funnel_contour.png)`

7. Footnote-label namespacing (collision guard — ch1 and ch3 both define
   `[^1]`): in `ch1_introduction.md` replace every digit label `[^N]` with
   `[^iN]`; in `ch3_methods.md` replace every `[^N]` with `[^mN]` — global
   regex on references AND definitions alike. Asserts: (a) per file, the
   pre-count of digit labels equals the post-count of namespaced labels and
   ZERO digit-only labels remain; (b) across all eight TMP files, the
   definition labels (lines starting `[^label]:`) are pairwise distinct.
   Report both.

8. Navigation-heading strip: in `ch3_methods.md` remove the line
   `## Table 1` (assert it occurs exactly once; delete the whole line).
   The bold caption line below it stays.

## 4. Pandoc run (one call, exit code must be 0)
```
pandoc TMP\manuscript\abstract_title.md TMP\manuscript\ch1_introduction.md ^
  TMP\manuscript\ch2_theory.md TMP\manuscript\ch3_methods.md ^
  TMP\manuscript\ch4_results.md TMP\manuscript\ch5_discussion.md ^
  TMP\manuscript\references_consolidated.md TMP\manuscript\appendix.md ^
  -f markdown+smart -t docx ^
  --reference-doc=manuscript\build\reference.docx ^
  --resource-path=TMP ^
  -o OUTPUT_DOCX
```
Capture ALL warnings verbatim (especially missing-image warnings). The
warning stream must contain NO `Duplicate note reference` line — one
appearing => STOP and report (the namespacing failed).
Ordering note (disclosed deviations, recorded here): `abstract_title.md`
leads (front matter; the double-blind title-page split happens at submission
packaging), and the references precede the appendix (journal convention; the
bootstrap §4 file list was an inventory, not an ordering).

## 5. Post-step (python-docx, deterministic)
On OUTPUT_DOCX:
- `sections[0]`: page size A4 (21.0 x 29.7 cm), all margins 2.54 cm,
  `different_first_page_header_footer = False`.
- Footer, single paragraph, right-aligned, Times New Roman 9 pt:
  `assembled from manuscript-v1.0-assembly @ <short> — FOMA CER–COD–Paris · p. `
  followed by a PAGE field (`w:fldSimple` with `w:instr=" PAGE "`, inner run
  also TNR 9 pt).
- `<short>` = `git rev-parse --short HEAD` at runtime; assert it is a prefix
  of EXPECTED_HEAD before writing.
- Save in place.

## 6. Verification (report a table)
- OUTPUT_DOCX exists; size > 300 KB with six images (> 150 KB on the
  placeholder branch) — report exact size.
- Image count: entries under `word/media/` == 6 (5 on the placeholder branch).
- Marker preservation: `pandoc OUTPUT_DOCX -t plain` and compare counts
  against the SAME counts computed from the TMP sources BEFORE step 3, for:
  `PENDING #16` · `PENDING #23` · `PENDING-external` ·
  `[Fig. 2: gated on #16]`. These four must be equal (`PENDING #37` has its
  own pinned expectation below).
- `PENDING #37` pinned expectation: docx count == 3 (see v1.1 head note).
- Footnotes: extract `word/footnotes.xml`; notes with id >= 1 must number 9,
  and their nine text contents must be pairwise DISTINCT (run-1 defect had
  9 notes with one text duplicated and one source text missing). Report the
  count and the first ~60 chars of each note.
- Style propagation: unzip OUTPUT_DOCX; the `Compact` style block in
  `word/styles.xml` must contain `w:line="240"` and `<w:sz w:val="20" />`
  (the reference's single-spaced 10 pt cell style carried through).
- Word count of the plain roundtrip — report.
- Clean up TMP. Do NOT commit, tag, or push anything.

## 7. Report format (single message back)
HEAD + tool versions · preflight a–g (with the figures listing verbatim) ·
six transform asserts · pandoc exit + verbatim warnings · post-step confirms
(geometry, footer text incl. resolved short hash) · verification table ·
forest legend VERBATIM + the 3LMA-RVE flag · attribution-sweep results.
