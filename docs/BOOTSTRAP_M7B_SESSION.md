# BOOTSTRAP — M7b Session (Pre-Submission Gate, Part 2 — final M-phase session) — M-hub authorized

Authored by the M-hub, 2026-08-05, against the verified post-M7a state (HEAD 3d81219). Ships in the M7b package commit. Conversation language: German; artifacts/log entries: English (ERROR_LOG: German). **Governance:** bootstrap authorship = M-hub only; M7b closes with the M-phase close sync; map/DEC-touching forks escalate before commit. The M7 master plan (BOOTSTRAP_M7 §2, committed @ 3d81219) remains binding for the phases executed here — this file supersedes its P3/P5/P6/P7 with the post-M7a state.

**v1.1 (M7b session, 2026-08-06; governing entry: DEC-060):** §1.6 corrected to "120 entries" (ERROR #52); §2e superseded — pass-2 executed and PASS at M7a, the duty collapses to record verification (author ruling (ii), ERROR #53); §3.3 dropped per the same ruling. No other content changed; where v1.0 and this delta diverge, the delta governs.

**Phase goal:** P3 scan battery · P5 deferred rulings · P6 docx assembly + cut-over · P7 submission-readiness checklist. Output closes the M phase.

---

## §1 Canary (MANDATORY; deviation = STOP + file request, except where marked)

1. `docs/DECISION_LOG.md` — last entry **DEC-059** (2026-08-05, M7a, FROZEN). bp DEC (+#41) preceding = conform.
2. `docs/ERROR_LOG.md` — last entry **#51**. #41 reserved.
3. `analysis_plan.md` — **A.16**.
4. `docs/CER-COD_Status.xlsx` — DLI A2 = "76 DECs", A80 = DEC-059; Ablauf carries the M7 row split note per sheet labels (M7a executed).
5. `docs/M_PHASE_MAP.md` = **v1.4** (TB-19 annotation corrected; M7 row split).
6. PK complete: ch1–ch5 · abstract_title.md · appendix.md · five finalized ledgers (five PENDING-external flags = conform: Ibrahim authors+issue · Singhania issue · van Aert & van Assen issue · two DOI-anchored page flags) · references_consolidated.md (120 entries, 36 corpus asterisks).
7. bp working set untracked = conform.

Git anchor: 3d81219.

## §2 P3 — Whole-manuscript scan battery (fix-as-found; every fix in the M7b DEC)

Per the M7 master plan P3 a–e, unchanged, with these post-M7a precisions: (a) vocabulary greps now include `abstract_title.md` and `appendix.md`; (b) single-home unchanged; (c) numbers pass includes appendix tables vs. their build provenance (spot 10 already PASS at M7a — sample 5 fresh ones); (d) cross-reference pass includes the **ch1 ¶2 title-echo line** (M6 carry) and appendix A-numbering from ch4/ch5 back-references; TB-19 site corrections are done (Map v1.4) — verify, don't redo; (e) **Ch.-2 pass-2 record verification** [v1.1]: pass-2 executed and PASS at M7a (DEC-059 §4 · Map v1.4 §7; author ruling (ii), ERROR #53) — this session verifies the record; no re-execution.

## §3 P5 — Deferred rulings (author, logged in the M7b DEC)

1. **R5 (repro/OSF):** reactivated P1 proposal — public-repo snapshot + DOI (OSF/Zenodo) at submission; data-availability text into the ch3 slot; scope ruling (i) full ES dataset (MAER-Net standard, recommended) vs. (ii) code+register.
2. **#33 waiver:** waive with a one-sentence Methods note, or hold — author call.
3. **Ch.-2 pass-2 verdict** — dropped [v1.1]: acknowledgment of the M7a-logged PASS per author ruling (ii) (ERROR #53); no fresh verdict.
4. **bp disposition statement:** if unlanded, TB-08/ch1-a7/ch4 slots stay `[PENDING #37]` — explicit line in the readiness list.

## §4 P6 — docx assembly & cut-over

Reference template (heading styles, footnotes, three-line tables, landscape section for wide panels) → one deterministic pandoc run from the committed tree (ch1→ch5 + appendix + references_consolidated; figures from output/figures; Fig.-2 placeholder page `[PENDING #16]`; PENDING-external reference flags render as-is and are listed in P7); footer provenance "assembled from <tag> @ <commit>". **Cut-over:** repo tag `manuscript-v1.0-assembly`; .docx = source of truth for text polish thereafter (Volker's medium; author citation-style pass happens there); md edits post-tag only via logged exception; build artifact location (`manuscript/build/` committed vs. delivered-only) = author call at P6.

## §5 P7 — Submission-readiness checklist + close

`docs/SUBMISSION_READINESS.md`: every item PASS / PENDING-external with owner + unblock condition. Register (post-M7a): #16+#23 → PRISMA numbers, note, Fig. 2 (Volker; A-risk) · #37/bp → TB-08 + ch1-a7 + ch4 slots + #41 call (author-local) · Volker: ch2-delta quarry · Bauer-T2 triage outcome · **K&V EL-twin data question** (if it changes a coding → own data DEC + sensitivity note; until then reference-side only) · ledger-hygiene remnants · five PENDING-external reference flags · **RQ-7a–g codebook register** (author/Volker; classify each as submission-relevant vs. documentation) · author citation-style pass (post-cut-over, in the .docx) · R5 execution steps per §3.1 ruling. Then: package, ritual, **M-phase close sync to the hub**.

## §6 Package, ritual, standing rules

Expected files (final from git evidence): P3-fix touches · `docs/SUBMISSION_READINESS.md` · assembly template + build artifact per §4 call · `docs/M_PHASE_MAP.md` (v1.5 closing note: M phase closed, slot-package protocol for #16/bp refreshes) · `docs/DECISION_LOG.md` (M7b DEC) · `docs/CER-COD_Status.xlsx` (M-phase close per sheet labels) · `docs/BOOTSTRAP_M7B_SESSION.md` (in the placement table) · ERROR_LOG on event · tag `manuscript-v1.0-assembly`. Standing rules unchanged: label-addressed status cells (exact cells in the sync) · index.lock check · placement paths from git evidence · certutil B-stage line-wise · push as fourth step · PK swap (xlsx from repo working copies) · no bp touch.

## §7 After M7b (hub program)

M-phase close sync → hub verifies → final Companion milestone sync → **postmortem at the Companion hub** (protocol §4). Submission waits on the PENDING-external list; #16/bp land as micro-packages with own DECs against the tagged tree, followed by an assembly refresh run.
