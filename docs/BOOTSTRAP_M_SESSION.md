# BOOTSTRAP — M Session (Manuscript phase · positioning + drafting)

Authored in the HK session, 2026-07-31. Conversation language: German; all artifacts, edits, and log entries: English. This file ships in the HK collective commit and is the opening prompt of the M session.

**Phase goal:** Convert the completed battery (A1–H11) and the resolved claim architecture [DEC-044/DEC-047] into the manuscript: positioning decision map first (Ablauf 4–6), then chapter work (Ablauf 7–11) per that map. Log discipline continues throughout.

---

## §1 Canary (mandatory — STOP on any mismatch, request current files)

Verify against the PK before any work:

1. `DECISION_LOG.md` — last entry **DEC-051b** (2026-07-31, FROZEN; DLI count 67 → 68). No HK DEC exists by design (HK edits implement documented DEC-045/047 obligations).
2. `ERROR_LOG.md` — last entry **#36** (2026-07-31, CLOSED with the DEC-051b fix commit). HK appended nothing: HK ruling 2026-07-31 = **no ERROR #37** — DEC-047 explicitly scheduled the TH workbook TB edits to the manuscript phase ("manuscript phase; workbook edits then"), so the 2026-07-29 sync omitting them was plan-conform and the HK execution is on schedule, not late.
3. `analysis_plan.md` — last addendum **A.16** (TF pins, 2026-07-29).
4. `CERCOD_Status.xlsx` — Ablauf Nr 3 = "erledigt (Batterie A–H komplett 2026-07-31; letzter Lauf TF 12/12)"; Nr 3b = "erledigt (Framing A per DEC-044; Wortlaut per DEC-047)"; Aufgaben T6 = "entfällt (in T7-Interaktionen aufgegangen, DEC-031)".
5. If TH workbooks are uploaded in-session: TH_b `Manuscript_Text_Blocks` TB-55 = READY (equivalence register per DEC-047).

**Git anchor (self-locating):** this file cannot contain its own commit hash — anchor = the commit introducing this file; verify via `git log --follow docs/BOOTSTRAP_M_SESSION.md`. Predecessor anchor: **5f4e38e** (TF P6 result package, "Commit 4" per DEC-051b). Known run/verifier commits: 06d1eeb (TF run) · c1e8b6c (TF verifier) · 76074a2 (T8 run source of record).

---

## §2 M-phase entry state

**Battery.** 100% complete: A1–H11 per Analyse_Batterie; robustness register complete 23×18; last run TF 12/12 PASS (2026-07-31). T6 formally entfällt (absorbed into T7 interactions, DEC-031).

**Claim architecture (binding).** Framing A [DEC-044]. Tier 1 (Paris moderation) = **equivalence register** [DEC-047]: "no detectable Paris-Agreement moderation; the post-minus-pre contrast is statistically equivalent to zero within the secondary SESOI band (±0.05 on Fisher-z)". Tier 2 (pooled effect) = statistically detectable, economically negligible, explicitly NOT null. LOCKED vocabulary (Tier 1): "evidence of absence"; "the data provide (moderate/strong) evidence for the null"; any headline sourcing of the default-prior BF01 = 8.49; any Bayesian-affirmative null phrasing. Bayes factors are reported descriptively only; BF01(period) = 1.03 / 1.17 (pre-specified priors), 8.49 only as a sensitivity bracket with disclosed convergence caveats. Single-home: the register decision is voiced once in the Discussion (TB-55) with exactly one Results cross-reference; D6 references DEC-047.

**TB inventory (post-HK audit, 2026-07-31).**

| Range | Run / workbook | Status |
|---|---|---|
| TB-01…12 | T1 | per T1 workbook (not re-audited in HK) |
| TB-13…19 | T2 | 7/7 READY (T2.md l.29) |
| TB-20…28 | T8 | per T8 workbook; T8.md already post-gate aligned [DEC-044 → DEC-047] |
| TB-29 | — | never assigned; documented gap, append-only, no renumbering (T5.md l.7) |
| TB-30…35 | T5 | READY; TB-35 finalized post-gate (T5.md l.58) |
| TB-36…45 | TH_a | READY, except TB-41/42 DRAFT (figure-dependent — finalize in M with the figures) |
| TB-46…51 | TH_c | READY, except TB-46 DRAFT (embedding sentence = M-phase authorship per DEC-047 grouping) |
| TB-52…56 | TH_b | READY, except TB-56 DRAFT (near-interpretive; M-phase Limitations); TB-55 = register voice (Discussion, single home) |
| TB-57…64 | T7 | per T7 workbook; TB-64 DRAFT = designated M-phase discussion flag (T7.md l.9) |
| TB-65…68 | TG | TB-65 finalized READY in the TF workbook; TB-68 superseded (TF.md l.9–10) |
| TB-69…71 | TF | READY |

**DRAFT set reserved for M finalization:** TB-41, TB-42 (with figures) · TB-46 (embedding sentence) · TB-56 (Limitations wording) · TB-64 (discussion flag). Plus the TH.md verdict sentence [DEC-047, manuscript-phase item].

**HK session record (deviations from the HK bootstrap, both author-approved 2026-07-31):**
- TB distribution correction: TH_a = TB-36…45, **TH_c = TB-46…51**, TH_b = TB-52…56 — the audit and flips therefore covered three TH workbooks; `output/TH_c_results_workbook.xlsx` joined the HK commit.
- HK-Q2 resolved as **no ERROR #37** (rationale in §1.2; DEC-047 lex specialis over the DEC-045 post-run list).
- TB-36/37 received their gate-conditional sentences (Tier-2 embedding; Tier-1 equivalence conclusion) verbatim from the DEC-047 licensed families; TB-55 rewritten to the register; TB-39/48–51 flipped READY unchanged (register-neutral).
- Workbook run-banner lines (rows 2–3) intentionally left at run-time provenance wording (historical record; per-block Note fields carry the DEC-047 state).

**Open external inputs (Datenagenda; verified 2026-07-31):**
- **#37** SD(COD) benchmarks per instrument (Volker) — unblocks manuscript row A6 / TB-08.
- **#16** PRISMA basics: search date, databases, hit/screening counts, inter-coder details (Volker) — required before Ch. 3.
- **#36** COE-overlap refresh on the final 120-study corpus — before Methods; cheap, deterministic from the two study lists.
- Minor: **#17** lookup upkeep (non-blocking) · **#23** Capelle-Blancard PRISMA note + drop-one sensitivity note · **#33** 2021 search metadata (deferred; waiver otherwise).

**Known inherited workbook defects (pre-existing in the committed files; proven on pristine copies; NOT touched in HK — optional micro-fix at a later documented touch):** TH_b `4_Formula_Reference` B6/B8/B9 and Status `Update_Scoping` I23 are documentation/note cells stored as formulas (leading "=") and render as formula errors in any recalculating client.

---

## §3 P1 agenda — positioning decision map (Ablauf 4–6)

P1 output = one joint decision map before any drafting (C-session precedent: map before spec). Contents:

- a. **Claim ladder × vocabulary × chapters:** map [DEC-044] tiers and the DEC-047 register onto the TB→chapter assignment; enforce the single-home rule (TB-55 = Discussion voice, one Results cross-reference; D6 cites DEC-047; cross-run statistics keep their one canonical location).
- b. **Delta analysis vs. draft 20260612:** claim–evidence audit of the existing draft against the final numbers and the register; identify over-claims relative to the observational design; Paris framing re-anchor throughout Intro → RQ → Hypotheses.
- c. **Rulings to collect:** TB-64 finalization · title/abstract re-anchor per DEC-044 · OSF/repro-package question.
- d. **Sequencing:** Ablauf 4–6 is a coupled iterative block (Guardrail G4: Narrativ → Hypothesen → Theorie as primary order, no rigid one-shot lock); chapters 7–11 follow the map (Ch. 2 → 3 → 4 → 1 → 5; blockwise sessions, one commit package per block, author preference).
- e. **DRAFT-set finalization plan:** schedule TB-41/42 with figure production, TB-46/56 with their chapters, TB-64 at the discussion-flag ruling.

---

## §4 Companion protocol (frozen wording)

- **Hub role.** The Companion chat carries direction and prioritization, co-review (its role prompt lives there), decision maps, bootstrap authorship, and postmortems. It does not carry heavy builds — workbooks, long scripts, chapter drafts run in task sessions.
- **No live context sharing between chats.** Continuity runs over three channels only: PK swap after every commit · a §0 canary at the start of every substantive Companion block · the author's handoff.
- **Sync ritual.** After each task-session commit, the author posts three lines in the Companion — commit hash · delivered · open forks — or just "Sync", upon which the Companion pulls state from PK + chat search itself.
- **Rollover rule.** If the Companion context degrades, author `BOOTSTRAP_COMPANION.md` (same mechanics as session bootstraps) and continue in a fresh chat.

---

## §5 Working conventions

- German discussion / English artifacts, code, and log entries.
- Complete files only — never insertion snippets; every delivery with a file→target-folder placement table.
- Commit ritual: Explorer placement → certutil MD5 spot-check immediately after placement (xlsx binary unaffected by autocrlf; .md hashes valid only pre-add) → ONE CMD block `git status` → `git add` (explicit file list) → `git commit` → `git log -1 --stat` pasted back for verification → PK swap.
- Hard sequencing: C-blocks (commit commands) are delivered only AFTER line-wise author verification of the B-stage certutil output against the machine-generated MD5 table; any mismatch aborts the block (ERROR #22/#29/#30 lessons). Tracked paths derived from git evidence only, never from convention lines (#21/#32).
- Log discipline continues in the M phase: DEC for every methodology-relevant framing decision (log-first, same commit as the artifact it governs); ERROR log bilateral (Claude errors and withdrawn author proposals alike).
- Result-blind discipline has served its purpose; reporting is now licensed within the DEC-047 register. The locked vocabulary and the single-home rule remain binding for all M-phase prose.
- PK carries the draft (20260612), all run .md feeds, and the methods corpus; request repo workbook/Status copies only when a task edits them (edit basis = repo file, never the PK copy).
