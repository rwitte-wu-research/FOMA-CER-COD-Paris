# Cowork Prompt — Chapter-2 Theory Harvest over the v12 Corpus — v2.3

<!-- FOMA CER-COD-Paris · docs/cowork_prompt_theory_harvest.md · M4 session, 2026-08-03 · authorized by ruling M4-Q11 (logged in the M4 DEC) -->
<!-- v2 (2026-08-03; §0 configured with author paths): supersedes v1 in-session (v1 never committed). Deltas: full-folder sweep incl. non-worklist PDFs (EXTRA rule), recursive library scan, mandatory preflight echo with author GO, FULL mode regenerates outputs from scratch, self-checks V4 amended + V7 added, extras sanity stop. -->
<!-- v2.1 (2026-08-03): key_citation quote made mandatory — resolution (a) of the executor's preflight stop-and-ask (spec contradiction §2/§4/§7, see ERROR_LOG M4 entry); §4 amended, §2 rule 1 and V2 unchanged. -->
<!-- v2.2 (2026-08-03; pilot-calibrated): key_citation outside the per-paper cap (max 3); text-layer quality gate + image-transcription route codified (rules 10-11, note flag, fidelity checks V8); hard rule 2 recast as function-over-label; two-gate FULL preflight with author-confirmed matching table; duplicate-file handling explicit; checks V8-V9 added; RUN_MODE pre-set to FULL. Pilot outputs are superseded by the FULL fresh write. -->
<!-- v2.3 (2026-08-03; Gate-1 conventions): rule 10 note format = "image_transcribed; <context>" (flag first, classification context preserved); §4 status-note enum lists duplicate_file:<processed filename> alongside duplicate_version:<label> (byte-identical library copy vs. working-paper/published twin); §3 final line clarified (Gate-2 first-page identification is not extraction reading). -->
<!-- Executor: Claude Cowork (author-run). Role: pure extractor. No synthesis, no drafting, no evaluation across papers. -->

## 0. Run configuration (AUTHOR SETS BEFORE LAUNCH)

```
RUN_MODE         = FULL             # PILOT = the 5 pilot papers only · FULL = all 120 worklist papers + every remaining PDF in the library
PDF_LIBRARY_PATH = C:\Cowork\FOMA-Extraktion-Theory\papers        # folder containing the corpus PDFs (author-verified path; ~135 files expected; subfolders allowed)
REPO_ROOT        = C:\R_Projects\FOMA-CER-COD-Paris        # local repo working copy (author-verified; outputs go to REPO_ROOT\docs\)
```

Do not start if either path is unset or does not exist (see §8).

## 1. Mission

One systematic pass over the theory content of the corpus's primary studies (worklist §6), plus — in FULL mode — a sweep of every additional PDF in the library beyond the worklist. For each paper, extract quote-anchored raw material relevant to manuscript Chapter 2 (theory & hypotheses): which theory frames the paper invokes, which mechanism arguments it makes for the CER–cost-of-debt link, which counter-/attenuation arguments it offers, and which Paris-/climate-policy-specific theoretical claims it states. Output = two files (§4, §5). Extraction only — consolidation happens elsewhere.

## 2. Hard rules

1. **Evidence only.** Every content record carries a verbatim quote (max 50 words) plus a page number. If you cannot supply quote + page, do not create the record — use a status row instead. Never paraphrase inside the quote field.
2. **Section scope — classify by function, not by heading.** Any passage that develops theory, mechanisms, or hypotheses is in scope wherever it sits — including theory-bearing passages inside methods sections (e.g., construct-measurement discussions carrying greenwashing or information arguments) and discussion sections whose substance is mechanism development. Out of scope: results reporting and results interpretation — except result-rationalization passages that qualify as counter/attenuation arguments or policy claims — plus tables and purely procedural methods text.
3. **Per-paper cap:** max 8 content records of the types {frame_use, mechanism_extra, counter, paris_policy} (choose the strongest and most distinct). `key_citation` records sit **outside** this cap, max 3 per paper. Status rows count against no cap.
4. **Repo discipline.** Write exactly two files: `REPO_ROOT\docs\theory_harvest_ch2.csv` and `REPO_ROOT\docs\theory_harvest_ch2.md`. Modify nothing else in the repo. Do not commit — the author commits with the session package.
5. **No web access.** PDFs only. If a paper cannot be resolved from the library, record the status and move on.
6. **Library scan & PDF matching.** Scan `PDF_LIBRARY_PATH` **recursively** for PDFs. Match each worklist label to a file via author surname + year in the filename or on the first page. Multiple plausible candidates → status `pdf_ambiguous` (do not guess). No candidate → status `pdf_missing`. If the library holds a working-paper twin of a published corpus paper, process the published version and note it. Byte-identical duplicate files: process one, record the other with a status row (`note = duplicate_file:<processed filename>`) — it is then not an extra.
7. **EXTRA-PDF rule (FULL mode only).** After all worklist papers are resolved, process every remaining PDF in the library under the same schema, with `study_label = "EXTRA: <filename stem>"` plus one mandatory status row per file (`note = non_corpus_pdf; <author/year/title from the first page>`). The per-paper cap applies. If an extra turns out to be a worklist paper under a different filename, use the worklist label instead — it is then not an extra. In PILOT mode, extras are not processed.
8. **Language.** Extract in the paper's original language; non-English papers get a status flag in addition to any content records.
9. **No cross-paper judgments.** Do not rank, synthesize, or comment on the literature as a whole; the free-observations section of the run log (§5) is capped at 15 lines.
10. **Text-layer quality gate.** Before extracting from any PDF, probe its text layer (column order, glyph integrity). If degraded (scan/OCR artifacts, column bleed), transcribe quotes from rendered page images and set `note = image_transcribed; <context>` on every affected record — flag first, then the record's classification context (the flag stays greppable, the context stays usable). Never quote from a degraded text layer — such quotes are silently non-verbatim.
11. **Quote-fidelity verification.** Before finishing, verify every quote against its claimed page: text-layer quotes must exact-match after normalisation (ligatures, curly quotes, dash variants, column-spanning reading order); image-transcribed quotes must token-match the page at >=0.75 coverage. Report the result in the run log.

## 3. Preflight echo (MANDATORY, before any paper is read)

**Gate 1 — echo.** Report back and **wait for the author's explicit GO**:
1. Resolved `PDF_LIBRARY_PATH` and `REPO_ROOT` (existence confirmed).
2. Number of PDFs found (recursive scan).
3. `RUN_MODE` as read from §0, and the resulting worklist size (PILOT = 5 · FULL = 120 + extras).

**Gate 2 — matching table (FULL mode only).** After the Gate-1 GO, resolve all 120 worklist labels to files (first-page checks wherever a filename disagrees on year or carries no year) and append the full matching table to the run log (§5), each row flagged {clean, year_mismatch, unknown_year, suffix_ambiguous, duplicate, missing}. Working-paper/published twins resolve per §2.6 (process the library version under the worklist label; note the version). Then STOP and present all flagged rows for author confirmation; extraction starts only after the author's second GO. In PILOT mode, Gate 2 is skipped.

No paper is read — beyond Gate-2 first-page identification — before the final GO of the active mode.

## 4. Output file 1 — CSV (item-level records)

Path: `REPO_ROOT\docs\theory_harvest_ch2.csv` · UTF-8 · comma-separated · RFC-4180 quoting · header exactly:

```
study_label,item_type,frame_tag,verbatim_quote,page,cited_work,note
```

**item_type** ∈ {frame_use, mechanism_extra, counter, paris_policy, key_citation, status}

- `frame_use` — the paper invokes one of the tagged theory frames. One record per distinct frame; quote = the paper's crispest statement of that frame.
- `mechanism_extra` — a mechanism argument for the CER→COD link **outside** the tagged frames (e.g., covenant channel, collateral/stranded-asset logic, relationship-lending information, refinancing/rollover risk).
- `counter` — an attenuation or counter-argument: why the association may be weak, null, positive, or conditional (e.g., cost burden, greenwashing noise, substitution by explicit carbon prices, anticipation/pre-pricing, diffusion lag).
- `paris_policy` — a Paris-Agreement- or climate-policy-specific theoretical claim, amplification OR attenuation.
- `key_citation` — one of the paper's top-3 theory anchor citations; `cited_work` = the full in-text citation string; `verbatim_quote` = the sentence (max 50 words) in which the anchor is invoked, `page` accordingly — mandatory like every content record. Top-3 anchors are selected by in-text theoretical load; a work citable only from the reference list does not qualify.
- `status` — paper-level status row; `note` ∈ {no_theory_content, pdf_missing, pdf_ambiguous, non_english:<lang>, duplicate_version:<label>, duplicate_file:<processed filename>, non_corpus_pdf} plus free text. (`duplicate_version` = working-paper/published twin of a corpus study; `duplicate_file` = byte-identical library copy, §2.6.)

**frame_tag** (only for `frame_use`, else empty) ∈
- `SIG` — signaling / information asymmetry / disclosure
- `RISK` — risk mitigation / default, downside, regulatory & transition risk
- `STAKE` — stakeholder / legitimacy / reputation / social license
- `AGENCY` — agency, overinvestment, cost-burden, entrenchment views (predicting weaker or positive associations)
- `OTHER:<name>` — any further explicitly named theory (e.g., `OTHER:institutional`, `OTHER:RBV`)

**page** = printed page number as shown on the page; fallback `pdf-N` (PDF page count) if pages are unnumbered.
**study_label** = byte-identical worklist string (§6) — or, for extras in FULL mode, `EXTRA: <filename stem>` (§2.7).

## 5. Output file 2 — run log

Path: `REPO_ROOT\docs\theory_harvest_ch2.md` · structure:

1. Header: run date/time · RUN_MODE · agent/model · PDF_LIBRARY_PATH as set · PDFs found · worklist size · papers processed.
2. Coverage table (worklist): `study_label | status (done / partial / <status-code>) | n_records`.
3. Matching table (FULL only; Gate-2 output, §3): `worklist label | file | flag | resolution`.
4. Extras table (FULL only): `filename | EXTRA label or matched worklist label | n_records`.
5. **PILOT mode only:** per-paper wall-clock minutes (basis for the FULL-run projection — no projection without this sample).
6. Anomalies & free observations (max 15 lines).
7. Self-check block (§7), each check reported PASS/FAIL.

**FULL mode regenerates both output files from scratch** (fresh, complete write; pilot-stage files are overwritten by design — no appending, no merging).

## 6. Worklist

**PILOT set (5):** Chava (2014) · Oikonomou et al (2014) · Erragragui (2018) · Ofogbe et al (2021) · Owolabi et al (2024)
*(2 canonical · 2 null/mixed-findings · 1 Paris-design; no extras sweep in PILOT)*

**FULL set (120 studies; labels are the CSV key, byte-identical):**

1. Al-Fakir Al Rabab'a et al (2023)
2. Ali et al (2023)
3. Ali et al (2026)
4. Almutairi (2026)
5. Altavilla et al (2024)
6. Apergis et al (2022)
7. Atif, Ali (2021)
8. Attig et al (2025)
9. Azmi et al (2021)
10. Bannier et al (2022)
11. Bauer, Hann (2010)
12. Ben Slimane et al (2019)
13. Bhattacharya & Sharma (2019)
14. Boermans et al (2023)
15. Borsuk & Shrimali (2026)
16. Boubaker et al (2026)
17. Brinette et al (2026)
18. Caragnano et al (2020)
19. Chava (2010)
20. Chava (2014)
21. Chen et al (2020)
22. Chen, Gao (2011)
23. Chodnicka-Jaworska (2022)
24. Christ et al (2022)
25. Cicchini et al (2026)
26. Cubas, Martinez (2018)
27. D'Arcangelo et al (2025)
28. Delis et al (2021)
29. Devalle et al (2017)
30. Ding et al (2022)
31. Drago et al (2018)
32. Drago, Carnevale (2020)
33. Du et al (2015)
34. Du et al (2022)
35. Dumrose & Höck (2023)
36. Duong et al (2025)
37. Ehlers et al (2021)
38. Eichholtz et al (2019)
39. Eliwa et al (2021)
40. Erragragui (2018)
41. Ferriani (2022)
42. Fonseka et al (2019a)
43. Fonseka et al (2019b)
44. Ge, Liu (2015)
45. Gonzales Sanches et al (2026)
46. Hamrouni et al (2019a)
47. Hansen & Marcet (2025)
48. Ho & Wong (2023)
49. Hoepner et al (2016)
50. Hu et al (2024)
51. Hui et al (2024)
52. Höck et al (2020)
53. Jang et al (2020)
54. Jiraporn et al (2014)
55. Johnson (2020)
56. Jung et al (2016)
57. Kim & Pouget (2026)
58. Kim, Kim (2022)
59. Kleimeier, Viehs (2021)
60. Kordschia (2020)
61. Kozak (2021)
62. Kumar & Firoz (2018)
63. Kölbel et al (2020)
64. Lee (2022)
65. Lemma et al (2017)
66. Li & Qiu (2026)
67. Li et al (2014)
68. Li et al (2022)
69. Lin et al (2025)
70. Liu et al (2023)
71. Luo et al (2019)
72. Ma et al (2022)
73. Maaloul, Wegener (2021)
74. Mahmoudian et al (2023)
75. Nandy, Lodh (2012)
76. Nasih et al (2024)
77. Ng & Rezaee (2012)
78. Ofogbe et al (2021)
79. Oikonomou et al (2014)
80. Okimoto & Takaoka (2024)
81. Okimoto, Takaoka (2022)
82. Ould Daoud Ellili (2020)
83. Owolabi et al (2024)
84. Palea, Drogo (2020)
85. Panjwani et al (2023)
86. Piechocka-Kałużna et al (2021)
87. Pizzutilo et al (2020)
88. Polbennikov et al (2016)
89. Ratajczak & Mikolajewicz (2021)
90. Ririmasse et al (2026)
91. Safiullah et al (2021)
92. Safiullah et al (2025)
93. Salvi et al (2021)
94. Sandra et al (2021)
95. Schneider (2010)
96. Seltzer et al (2022)
97. Shad et al (2022)
98. Shi et al (2025)
99. Srivisal et al (2021)
100. Sze et al (2021)
101. Tan et al (2021)
102. Tan et al (2026)
103. Tang et al (2023)
104. Temiz (2022)
105. Trinh et al (2024)
106. Truong, Kim (2019)
107. Wang & Wijethilake (2026)
108. Wang et al (2020)
109. Wang et al (2022a)
110. Wang et al (2025a)
111. Wang et al (2025b)
112. Wu et al (2020)
113. Xiang & Gong (2026)
114. Yang et al (2024)
115. Yilmaz (2022)
116. Zhang et al (2023)
117. Zheng (2021)
118. Zhou et al (2018)
119. Zhou et al (2024)
120. Zhu, Zhao (2022)

## 7. Self-checks before finishing (report PASS/FAIL in the run log)

- **V1 Coverage:** every worklist entry of the active RUN_MODE has ≥1 CSV row (content or status).
- **V2 Completeness:** every non-status row has non-empty `verbatim_quote` and `page`.
- **V3 Quote cap:** every quote ≤50 words.
- **V4 Key integrity:** every `study_label` is byte-identical to a worklist string OR carries the `EXTRA: ` prefix.
- **V5 Count consistency:** totals reported in the run log equal the CSV row counts.
- **V6 Footprint:** no file outside the two outputs was created or modified.
- **V7 Extras accounted (FULL only):** every non-worklist PDF in the library appears in the extras table with either records or a skip reason.
- **V8 Quote fidelity:** the rule-11 verification ran on every quote with zero failures, or every failure is listed with its resolution.
- **V9 Cap legality:** per paper max 8 substantive-type records and max 3 `key_citation` records.

## 8. Stop conditions

- `PDF_LIBRARY_PATH` or `REPO_ROOT` unset/invalid → STOP before any processing; report.
- Preflight (§3) not yet confirmed by the author → do not process.
- FULL mode: >15 worklist papers unmatched after the matching step → write the status rows, then STOP and report (library likely incomplete).
- FULL mode: >25 PDFs left unmatched as extras after the matching step → STOP and report before processing extras (matching has likely failed; ~15 extras are expected).
- FULL mode: Gate-2 flagged rows not yet author-confirmed → do not extract.
- Any instruction conflict or ambiguity → STOP and ask the author; do not improvise.

## 9. After the run (author)

- **PILOT:** hand both output files to the project chat for schema validation and the runtime anchor. FULL run only after an explicit chat GO.
- **FULL:** keep both files in `docs\`; they ship in the M4 package commit (log-first via the M4 DEC; ruling M4-Q11).
