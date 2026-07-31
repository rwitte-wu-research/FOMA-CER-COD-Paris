# BOOTSTRAP — HK Session (Housekeeping · pre-M handoff)

Authored in the Companion chat, 2026-07-31. Conversation language: German. All artifacts, edits, and log entries: English. This file is both the opening prompt of the HK session and a committed artifact (ships in this session's collective commit; HK-Q1).

**Session goal:** Repo + PK are M-phase-ready. Exactly ONE collective commit. No analyses, no new TB prose, no new DEC.

---

## §0 Canary (mandatory — STOP on any mismatch, request current files)

Verify against the PK before any work:

1. `DECISION_LOG.md` — last entry **DEC-051b** (2026-07-31, FROZEN; DLI count 67 → 68).
2. `ERROR_LOG.md` — last entry **#36** (2026-07-31, CLOSED with the DEC-051b fix commit).
3. `analysis_plan.md` — last addendum **A.16** (TF pins, 2026-07-29).
4. `CERCOD_Status.xlsx` — Analyse_Batterie F1–F7 = "erledigt (2026-07-31, TF 12/12, 06d1eeb)"; G11 = "register complete 23×18 … 06d1eeb / c1e8b6c"; Key_Results contains the TF digest row.

Git anchor: the TF P6 result-package commit ("Commit 4" per DEC-051b). The Companion did not hold its hash — read it via `git log -1 --stat` at session start and record it in the §6 commit-message context. Known script/verifier commits: 06d1eeb (run) · c1e8b6c (verifier).

---

## §1 Scope

**In scope:** (A) TB post-gate audit TH_a/TH_b · (B) Status.xlsx overview-layer sync · (C) author `docs/BOOTSTRAP_M_SESSION.md` · one collective commit + PK swap + first Companion sync.

**Out of scope:** any analysis or estimate; new TB numbers or content; **TB-64 stays DRAFT** (designated M-phase discussion flag, T7.md l.9); T7/TG/TF workbooks (TB-65 READY and TB-68 superseded are documented in TF.md — no re-verification); DecisionLog_Index (no new DEC ⇒ DLI stays at 68 — do not append).

---

## §2 Required uploads (request at session start)

1. `output/TH_a_results_workbook.xlsx` (repo copy)
2. `output/TH_b_results_workbook.xlsx` (repo copy)
3. `docs/CER-COD_Status.xlsx` (repo copy — edit basis is the repo file, never the PK copy)

`ERROR_LOG.md` (only needed if §3e fires) may be sourced from the PK copy — canary §0.2 certifies it as current. Complete-files rule applies to every delivered artifact.

---

## §3 Task A — TB post-gate audit (TH_a / TH_b)

**Background.** TH.md (2026-07-26, pre-gate) records TB-36/37/39/48–51 = BLOCKED and TB-41/42/46 = DRAFT under DEC-044 gate discipline. Gate resolved 2026-07-27 [DEC-047]. The 2026-07-29 post-gate sync verifiably updated Status.xlsx and the T5 workbook (TB-30…35 READY; T5.md l.58); no evidence exists in the PK for the TH workbooks. DEC-045 consequences list "TB-35 finalization + TB-36 ff." as a documented post-run obligation.

**Procedure.**
- a. Open tab `Manuscript_Text_Blocks` in TH_a; read status + status-note columns for TB-36…TB-51. Same in TH_b for TB-52…TB-56 (written on gate day — cross-check only).
- b. Decision rule per block:
  - already READY (or superseded) → no action; record PASS.
  - BLOCKED with a gate-conditional note → flip to READY; align wording to the DEC-047 register: equivalence-register vocabulary; BF01(period) = 1.03 in the 1–3 band; the default-prior BF01 = 8.49 only with headline-sourcing and its disclosed convergence caveats; no evidence-of-absence phrasing outside the Tier-1 wording.
  - DRAFT → read the note first: gate-conditional → finalize per DEC-047; discussion-flag (TB-64 pattern) → leave DRAFT, record the reason.
- c. Wording alignment only — no new content, no renumbering; formula-live cells untouched; after any edit, recalc-verify the workbook (openpyxl round trip must not break formulas or cached values).
- d. Findings ledger: one line per TB (id · found status · action · basis). The ledger feeds §5.
- e. **HK-Q2 (pre-ruled).** If the audit shows the TH flips were missing from the 2026-07-29 sync ⇒ append **ERROR #37** (process gap: documented DEC-045 obligation "TB-36 ff." executed late; caught by Companion status review 2026-07-31; bilateral convention; CLOSED with this commit). If already flipped ⇒ no entry.

**Stops:** `Manuscript_Text_Blocks` tab missing or schema-deviant → STOP, report. Recalc breakage after edit → STOP, do not deliver.

---

## §4 Task B — Status.xlsx overview-layer sync

Authoritative layers (Analyse_Batterie · Key_Results · DecisionLog_Index) are current — touch nothing there. Update only the stale overview cells; locate columns by header text, never by letter; keep Arial/navy style; no structural changes.

| Tab | Row (by Nr/label) | Field | New value |
|---|---|---|---|
| Ablauf | Nr 3 "Alle Analysen" | Status | erledigt (Batterie A–H komplett 2026-07-31; letzter Lauf TF 12/12) |
| Ablauf | Nr 3b | Status | erledigt (Framing A per DEC-044; Wortlaut per DEC-047) |
| Aufgaben | T3 | Status + "Status 2026-07-10" | aufgegangen in A2/A3 (T1, erledigt 2026-07-13) |
| Aufgaben | T4 | Status + "Status 2026-07-10" | aufgegangen in Block F/G (TG 2026-07-29 · TF 2026-07-31) |
| Aufgaben | T5 | both status columns | erledigt (27/27, 2026-07-19) |
| Aufgaben | T7 | both status columns | erledigt (27/27, 2026-07-29) |
| Aufgaben | T8 | both status columns | erledigt (27/27, 2026-07-15) |
| Aufgaben | T0.4 | General Note tail "Commit folgt" | replace with the T0.4 commit reference |

Then one quick full scan of both tabs for further contradicting strings ("offen", "gated", "Pending", "in Ausführung"): list finds and confirm with the author before editing; display-layer cells only.

---

## §5 Task C — Author `docs/BOOTSTRAP_M_SESSION.md`

English; ships in the same collective commit. Required sections:

1. **§0 canary** — updated values incl. this HK commit. Self-locating anchor (the file cannot contain its own hash): "anchor = the commit introducing this file; verify via `git log --follow docs/BOOTSTRAP_M_SESSION.md`".
2. **M-phase entry state** — battery 100% complete (A1–H11, register 23×18); final TB inventory from the §3 ledger (incl. TB-64 DRAFT discussion flag); open external inputs: #37 SD(COD) medians → unblocks A6/TB-08 · #16 PRISMA basics → blocks Ch. 3 · #36 COE-overlap refresh (before Methods) · minor #23/#17/#33.
3. **P1 agenda — positioning decision map (Ablauf 4–6):** claim ladder [DEC-044] × DEC-047 vocabulary × TB→chapter mapping; delta analysis vs. draft 20260612; rulings to collect (TB-64 finalization, title/abstract re-anchor per DEC-044, OSF/repro-package question).
4. **Companion protocol** — transplant §7 below verbatim.
5. **Working conventions** — German discussion / English artifacts; complete files only; commit ritual with paste-back; log discipline continues in the M phase (DEC for methodology-relevant framing decisions, ERROR bilateral).

---

## §6 Collective commit (ONE commit)

**Files:** `output/TH_a_results_workbook.xlsx` (if edited) · `output/TH_b_results_workbook.xlsx` (if edited) · `docs/CER-COD_Status.xlsx` · `docs/BOOTSTRAP_HK_SESSION.md` · `docs/BOOTSTRAP_M_SESSION.md` · `docs/ERROR_LOG.md` (only if #37 fires).

**No new DEC** — edits implement documented obligations of DEC-045/DEC-047 (Ablauf 3b per DEC-044); cite these in the commit message. Companion protocol is work organization [HK-Q3].

**Ritual:** file→target-folder table → Explorer placement → certutil MD5 spot-check immediately after placement (binary xlsx unaffected by autocrlf; for .md files: MD5 valid only pre-add) → ONE CMD block: `git status` → `git add` (explicit file list) → `git commit -m "HK: post-gate TB sync (TH_a/TH_b), status overview sync, M-session bootstrap [per DEC-045/047 obligations(, ERROR #37)]"` → `git log -1 --stat` → paste back for verification → **PK swap:** `CER-COD_Status.xlsx` (+ `ERROR_LOG.md` if changed).

---

## §7 Companion protocol (frozen wording — transplant into BOOTSTRAP_M_SESSION.md §4)

- **Hub role.** The Companion chat carries direction and prioritization, co-review (its role prompt lives there), decision maps, bootstrap authorship, and postmortems. It does not carry heavy builds — workbooks, long scripts, chapter drafts run in task sessions.
- **No live context sharing between chats.** Continuity runs over three channels only: PK swap after every commit · a §0 canary at the start of every substantive Companion block · the author's handoff.
- **Sync ritual.** After each task-session commit, the author posts three lines in the Companion — commit hash · delivered · open forks — or just "Sync", upon which the Companion pulls state from PK + chat search itself.
- **Rollover rule.** If the Companion context degrades, author `BOOTSTRAP_COMPANION.md` (same mechanics as session bootstraps) and continue in a fresh chat.

---

## §8 Exit criteria

1. TB ledger complete; every gate-conditional TH block READY or its retention explicitly justified.
2. Status.xlsx overview layers current; no contradicting status strings left vs. the authoritative layers.
3. `BOOTSTRAP_M_SESSION.md` delivered and committed.
4. `git log -1 --stat` pasted back and verified; PK swapped.
5. First execution of the sync ritual: three-line sync posted in the Companion.
