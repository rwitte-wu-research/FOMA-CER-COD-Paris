# BOOTSTRAP — M6 Session (Title · Abstract · Keywords + Appendix Assembly) — M-hub authorized

Authored by the M-hub, 2026-08-04, against the verified post-M5 state (HEAD 447cea5). Ships in the M6 package commit. Conversation language: German; artifacts/log entries: English (ERROR_LOG: German). **Governance:** bootstrap authorship = M-hub only; M6's P5 = hub sync; no BOOTSTRAP_M7 authorship; map/DEC-touching forks escalate before commit.

**Phase goal (two parts):** (A) finalize title (R4 question-form family), abstract (TB-12 basis), and keywords → `manuscript/abstract_title.md`; close **[M6-SYNC-1]** (ch5 §5.8 opening ↔ final title). (B) **conditional on the author's docking confirm (§2):** assemble the online appendix from the staged ch4 block → `manuscript/appendix.md`.

---

## §1 Canary (MANDATORY; deviation = STOP + file request, except where marked)

1. `docs/DECISION_LOG.md` — last entry **DEC-057** (2026-08-04, M5, FROZEN). bp DEC (+#41) preceding = conform.
2. `docs/ERROR_LOG.md` — last entry **#47**. #41 reserved.
3. `analysis_plan.md` — **A.16**.
4. `docs/CER-COD_Status.xlsx` — A2 = "74 DECs", A78 = DEC-057; G14 = "erledigt (M2 … ; M5 Discussion per DEC-057 …)"; G16 = "in Arbeit — M5 Discussion/Conclusion erledigt …; M6 Abstract offen".
5. `docs/M_PHASE_MAP.md` = v1.2 (appendix-docking note: "docked to M6, author confirm at M6 start").
6. Manuscript set complete in PK: ch1–ch5 + five ledgers; ch4 carries the staged appendix block at file end.
7. Untracked bp working set in tree (R/13*, bench_13_out.txt, data/benchmarks/) = conform; untouched.

Git anchor: 447cea5. Self-locating rule applies after the M6 commit.

## §2 P1 confirm gate (before any drafting)

**Author confirm: appendix assembly in M6 — yes/no.** Yes → part (B) active per §5. No → appendix moves to M7; Map v1.3 note updated accordingly (logged); M6 = part (A) only.

## §3 Binding inputs

- **Vocabulary — title, abstract, and keywords are register zones:** Tier-1 sentence strictly from the DEC-047 family; Tier-2 = "statistically detectable, economically negligible — not null" family; **no Bayes factors anywhere in title/abstract** (8.49 banned globally; 1.03/1.17 not abstract material); no "evidence of absence" family; "pre-specified" wording.
- **Title:** R4 family frozen ("Did the Paris Agreement Reprice Environmental Responsibility in Credit Markets? …" as working anchor); finalize wording + subtitle here; **[M6-SYNC-1]:** compare ch5 §5.8 opening against the final title — delta → ch5 micro-edit ships in this package (logged in the M6 DEC).
- **Abstract:** TB-12 (T1 workbook, DRAFT) is the seed, superseded freely at use (list in the DEC per the DEC-053 pattern); target ≈ 150–200 words pending journal check (**[VERIFY] BSE author-guideline word cap → M7 list**); structure: motivation/gap → corpus & method one-breath (v12 quantities verbatim from ch3) → Tier-2 sentence → Tier-1 register sentence → moderation/selection one-liner → contribution close. Numbers minimal set per DEC-055 Q3 precedent (r, CI, benchmark ratio at most).
- **Keywords (5–7), session finalizes; hub proposal:** corporate environmental responsibility · cost of debt · Paris Agreement · meta-analysis · equivalence testing · publication bias (+ optional: credit markets).
- **Appendix content basis (if confirmed):** staged block at ch4 end + Map §5 appendix row (level/pair detail inventory per M-T3 disposition · TB-33 · TB-10 df footnote · TB-71 LOO/influence · TB-47 dual home · any-with line · PRISMA flow slot **[PENDING #16]**). Tables remain script-generated (extend `scripts/build_ch4_tables.py` or sibling; R/CC via Windows terminal per DEC-054 §4); **M6-F1 at P1:** inventory which appendix tables are script-built vs. already staged as markdown.

## §4 Delivery units

U1 title + subtitle (+ [M6-SYNC-1] check) → U2 abstract → U3 keywords → U4 (conditional) appendix assembly (A.1ff numbering; captions per F-CAP; provenance comments on every generated table) → U5 ch4 edit: staged block replaced by a one-line pointer to `manuscript/appendix.md` (logged micro-edit).

## §5 Duties (all ship in the M6 package)

1. **TB-12 finalize** (DRAFT → superseded-at-use or final wording) + **T1 workbook flip to READY** (pristine-copy discipline; recalc after edit; PK swap from repo working copy — M5 standing rule).
2. **[M6-SYNC-1] close** (documented in the DEC, including a "no delta" outcome).
3. **Status touch — rows by LABEL:** the "Ch 5 — Conclusion + Abstract" row → "erledigt (M5 Discussion per DEC-057; M6 Abstract/Titel per DEC-05x)"; if appendix assembled, note it there or on the fitting row per sheet evidence; DLI pointer + A2 count; three-cell minimum with re-read; report exact cells in the sync.
4. **Ledger:** abstract needs none; appendix references (if any) → increment convention (`ch4_results_references.md` or `appendix_references.md` — session's call, documented).
5. **No bp touch · no ch1–ch3 edits** beyond U5/[M6-SYNC-1] outcomes.

## §6 Package & ritual

Expected files (final from git evidence): `manuscript/abstract_title.md` · (conditional) `manuscript/appendix.md` + table script increment · `manuscript/ch4_results.md` (U5 pointer edit) · (conditional) `manuscript/ch5_discussion.md` ([M6-SYNC-1] delta) · `output/T1_results_workbook.xlsx` · `docs/DECISION_LOG.md` (M6 DEC) · `docs/CER-COD_Status.xlsx` · `docs/BOOTSTRAP_M6_SESSION.md` (**this file — list it in the placement table**; M5 deviation-3 lesson) · ERROR_LOG only on event. Ritual: close RStudio/agents + clear stale `.git/index.lock` → placement table (paths from git evidence) → certutil B-stage line-wise → C-block → `git log -1 --stat` paste → `git push origin main` → PK swap (xlsx from repo working copies) → **hub sync** (incl. §2 confirm outcome, [M6-SYNC-1] outcome, exact status cells).

## §7 Plan environment (not M6 scope)

After the M6 sync the hub authors **BOOTSTRAP_M7** (pre-submission gate: R5 ruling · #33 waiver · full-manuscript vocabulary/single-home/numbers scans · Ch.-2 pass-2 B-level check · [VERIFY] register resolution incl. BSE abstract cap · reference-string harvests · Word assembly via pandoc + reference template · figures/PRISMA pending #16). Volker strands unchanged (#16/#23 A-risk · Bauer-T2 · ch2 delta · ledger hygiene). bp/#41 at landing.
