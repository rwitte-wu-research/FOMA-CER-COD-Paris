# CC Contract — M7 docx Assembly (P6; authority: DEC-060 §8 · DEC-061 §5) — v1.3

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
v1.3 (S1-P7, post-erratum rebuild): HEAD rule replaces the fixed hash (the
contract's own commit is the run base — subject-prefix rule below); output
bumps to v1.1; Figure 2 (PRISMA) joins the embed set (new marker in ch3);
the A8 forest PNG is now a committed artifact — the raster branch and the
placeholder branch are removed; the `PENDING #37` pin drops to 0 (markers
redeemed S1-P4; remaining notes are comments that pandoc strips); the
marker set gains `PENDING Item 20`; §6 gains the S1 RENDER GATE (bp ladder,
bp trio, band, drop-set, count census incl. the 114 Class-B parity, and the
3LMA-RVE zero check). Assembly runs only after this gate list is green.

Single-use, deterministic build. Repo: `C:\R_Projects\FOMA-CER-COD-Paris`.
**Hard rules:** no git writes (no add/commit/tag/push), no edits to any tracked
file, no re-estimation, no R runs. All work in a temp tree outside the repo;
the only repo write is the output docx into `manuscript\build\`. On any STOP:
report the failing step with verbatim output and take no further steps.
Report language: English, verbatim tool output where specified.

```
HEAD_RULE      = git log -1 --format=%s starts with "P7b contract v1.3"
                 AND git merge-base --is-ancestor 6de998a HEAD succeeds
REFERENCE_MD5  = d22e0c9c9073c7cfa5e31b479c8c8579
OUTPUT_DOCX    = manuscript\build\FOMA-CER-COD-Paris_manuscript_v1.1.docx
```

## 0. Environment probe (report)
`git --version` · `pandoc --version` (>= 2.11 required) · `python --version`
plus `python -c "import docx; print(docx.__version__)"` (install `python-docx`
via pip if missing). If pandoc is unavailable in the VM, run it Windows-side
via CMD redirect (project convention); report which side executed.

## 1. Preflight (any FAIL => STOP)
a. HEAD_RULE holds (report the subject line and the ancestor-check result).
b. `git status --porcelain -- manuscript docs R scripts` empty except the
   known untracked set (R/13_*, bench_13_out.txt, data/benchmarks/,
   output/appendix_tables_A2_A4.md, manuscript/build/). Any *modified*
   tracked file => STOP.
c. MD5 of `manuscript\build\reference.docx` == REFERENCE_MD5 (certutil).
d. `dir output\figures` — verbatim listing into the report. Required PNGs
   (all seven must exist): fig1_framework.png · fig2_prisma.png ·
   T1_A7_caterpillar_cluster.png · T1_A8_forest_study.png ·
   TH_a_H7_cumulative.png · TH_a_H8_rolling.png · D1_funnel_contour.png.
e. Forest legend duty [DEC-061 §3]: view T1_A8_forest_study.png, transcribe
   any embedded caption/legend text VERBATIM into the report (expected:
   NONE — the S1-P6 rebuild is F-CAP), and explicitly FLAG whether the
   string "3LMA-RVE" occurs anywhere in the figure (expected: no).
f. Attribution sweep [DEC-061 §5]: view fig2_prisma.png,
   T1_A7_caterpillar_cluster.png, TH_a_H7_cumulative.png,
   TH_a_H8_rolling.png, D1_funnel_contour.png and confirm for each:
   no estimator-label text embedded; for the three curve figures the dashed
   line = pooled reference. Report PASS/FAIL per figure.

## 2. Temp tree (outside the repo, e.g. %TEMP%\m7_assembly)
Copy — never move, never touch repo originals:
- `manuscript\abstract_title.md`, `ch1_introduction.md`, `ch2_theory.md`,
  `ch3_methods.md`, `ch4_results.md`, `ch5_discussion.md`,
  `references_consolidated.md`, `appendix.md`  ->  `TMP\manuscript\`
- the seven PNGs from 1d  ->  `TMP\output\figures\`

## 3. Deterministic transform (python, on the TMP copies only)
Seven embed replacements; assert each incumbent occurs EXACTLY once in its
file and abort on any count != 1. Report the seven assert results.

1. `ch2_theory.md`:
   `[Figure 1 about here]`
   -> `![](output/figures/fig1_framework.png)`
2. `ch3_methods.md`:
   `<!-- FIGURE 2 artifact: output/figures/fig2_prisma.(pdf|png) -->`
   -> `![](output/figures/fig2_prisma.png)`
3. `ch4_results.md`:
   `<!-- FIGURE 3 artifact: output/figures/T1_A7_caterpillar_cluster.(pdf|png) [committed T1 plot; P4 visual check] -->`
   -> `![](output/figures/T1_A7_caterpillar_cluster.png)`
4. `ch4_results.md`:
   `<!-- FIGURE 4 artifact: output/figures/TH_a_H7_cumulative.(pdf|png) -->`
   -> `![](output/figures/TH_a_H7_cumulative.png)`
5. `ch4_results.md`:
   `<!-- FIGURE 5 artifact: output/figures/TH_a_H8_rolling.(pdf|png) -->`
   -> `![](output/figures/TH_a_H8_rolling.png)`
6. `appendix.md`:
   `[artifact: output/figures/T1_A8_forest_study.pdf]`
   -> `![](output/figures/T1_A8_forest_study.png)`
7. `appendix.md`:
   `[artifact: output/figures/D1_funnel_contour.(pdf|png)]`
   -> `![](output/figures/D1_funnel_contour.png)`

8. Footnote-label namespacing (collision guard — ch1 and ch3 both define
   `[^1]`): in `ch1_introduction.md` replace every digit label `[^N]` with
   `[^iN]`; in `ch3_methods.md` replace every `[^N]` with `[^mN]` — global
   regex on references AND definitions alike. Asserts: (a) per file, the
   pre-count of digit labels equals the post-count of namespaced labels and
   ZERO digit-only labels remain; (b) across all eight TMP files, the
   definition labels (lines starting `[^label]:`) are pairwise distinct.
   Report both.

9. Navigation-heading strip: in `ch3_methods.md` remove the line
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
packaging), and the references precede the appendix (journal convention).

## 5. Post-step (python-docx, deterministic)
On OUTPUT_DOCX:
- `sections[0]`: page size A4 (21.0 x 29.7 cm), all margins 2.54 cm,
  `different_first_page_header_footer = False`.
- Footer, single paragraph, right-aligned, Times New Roman 9 pt:
  `assembled from manuscript-v1.1-assembly @ <short> — FOMA CER–COD–Paris · p. `
  followed by a PAGE field (`w:fldSimple` with `w:instr=" PAGE "`, inner run
  also TNR 9 pt).
- `<short>` = `git rev-parse --short HEAD` at runtime (the P7b commit).
- Save in place.

## 6. Verification (report a table)
- OUTPUT_DOCX exists; size > 350 KB — report exact size.
- Image count: entries under `word/media/` == 7.
- Marker preservation: `pandoc OUTPUT_DOCX -t plain` and compare counts
  against the SAME counts computed from the TMP sources BEFORE step 3, for:
  `PENDING #16` · `PENDING #23` · `PENDING Item 20` ·
  `[Fig. 2: gated on #16]`. These four must be equal (expected source
  counts: 0 · 1 · 1 · 0 — report both sides).
- `PENDING #37`: docx count == 0 (markers redeemed S1-P4; the surviving
  `[#37 REDEEMED S1-P4]` notes are comment-embedded and stripped by pandoc).
- Footnotes: extract `word/footnotes.xml`; notes with id >= 1 must number 9,
  and their nine text contents must be pairwise DISTINCT. Report the count
  and the first ~60 chars of each note.
- Style propagation: unzip OUTPUT_DOCX; the `Compact` style block in
  `word/styles.xml` must contain `w:line="240"` and `<w:sz w:val="20" />`.
- **S1 RENDER GATE** (all on the `pandoc OUTPUT_DOCX -t plain` roundtrip;
  each row PASS/FAIL with the observed count):
  g1. bp ladder tokens, each >= 1: `200.0` · `150.0` · `168.6` · `111.7` ·
      `310.0` · `157.0` · `153.7` · `159.7` · `186.5` · `163.0`.
  g2. band string `110–200` (en dash) >= 1.
  g3. bp trio: `−11.8` · `−8.8` · `−9.9` · `−6.6` (U+2212), each >= 1.
  g4. drop-set: `−0.062` >= 1 · `2,636` >= 1 · `107 clusters` >= 1.
  g5. structure counts: `2,713` >= 1 · `120 studies` >= 1 · `118` >= 1 ·
      `113` >= 3 · `111` >= 1.
  g6. 114 Class-B parity: the count of the standalone token `114`
      (regex `\b114\b`) in the docx plain text EQUALS the same count over
      the eight TMP sources BEFORE step 3 — report both numbers.
  g7. `3LMA-RVE` count == 0.
  g8. Table-2 spots: `Extended combined drop-set (erratum constellation)`
      == 1 · `Headline model, v12.1 anchor` == 1.
- Word count of the plain roundtrip — report.
- Clean up TMP. Do NOT commit, tag, or push anything.

## 7. Report format (single message back)
HEAD subject + ancestor check + tool versions · preflight a–f (with the
figures listing verbatim) · seven transform asserts + namespacing + heading
strip · pandoc exit + verbatim warnings · post-step confirms (geometry,
footer text incl. resolved short hash) · verification table incl. the full
S1 RENDER GATE rows · forest legend finding + the 3LMA-RVE flag ·
attribution-sweep results.
