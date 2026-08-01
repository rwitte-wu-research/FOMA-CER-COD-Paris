# BOOTSTRAP — M1 Session (Ch. 3 Methods assembly)

Authored in the M session (P1), 2026-08-01. Conversation language: German; all artifacts, edits, and log entries: English. Ships in the P1 collective commit [DEC-052]; opening prompt of the M1 session.

**Phase goal:** Assemble Chapter 3 (Methods) from the 13 READY text blocks, the battery pins, and the #36 overlap paragraph, per `docs/M_PHASE_MAP.md` (the single source for mapping, anchors, vocabulary, and sequencing). Output: `manuscript/ch3_methods.md` (layout per DEC-052.i).

---

## §1 Canary (mandatory — STOP on any mismatch, request current files)

Verify against the PK before any work:

1. `DECISION_LOG.md` — last entry **DEC-052** (2026-08-01, FROZEN; DLI count 68 → 69).
2. `ERROR_LOG.md` — last entry **#36** (2026-07-31, CLOSED). P1 appended nothing.
3. `analysis_plan.md` — last addendum **A.16** (TF pins, 2026-07-29). P1 appended nothing (hypothesis architecture is a manuscript matter, logged in DEC-052).
4. `CERCOD_Status.xlsx` / repo `docs/CER-COD_Status.xlsx` — Ablauf Nr 4/5/6 = "erledigt (P1-Positionierungskarte per DEC-052, 2026-08-01; docs/M_PHASE_MAP.md)"; DecisionLog_Index count = 69 with DEC-052 appended; Datenagenda #36 carries the pull-in note "(P1-Commit, DEC-052/R7)".
5. `docs/M_PHASE_MAP.md` present; ruling register R1–R7 with R5 = DEFERRED → M7.

**Git anchor (self-locating):** anchor = the commit introducing this file; verify via `git log --follow docs/BOOTSTRAP_M1_SESSION.md`. Predecessor anchor: the HK collective commit (introduces `docs/BOOTSTRAP_M_SESSION.md`).

---

## §2 M1 entry state & mission

**Binding inputs:** Map §1 (claim architecture + locked vocabulary), §3 (RQ/H anchors — the Methods declaration paragraph must match O-A'), §5 (Ch.-3 TB list), §6 (single-home register: overlap tiers live HERE in Methods; §4.2/TB-43 will carry the single cross-reference).

**TB inventory for Ch. 3 (all READY; workbooks = source of record, use verbatim):**
TB-01 (model) · TB-02 (prediction intervals) · TB-03 (sample) [T1] · TB-16, TB-17, TB-18 (Paris coding suite + defence) [T2] · TB-20 (identification battery) [T8] · TB-30 (publication-bias battery) [T5] · TB-38 (inference plan / language gate) [TH_a] · TB-47 (H1 power calibration; dual home with appendix) [TH_c] · TB-52 (RoBMA procedure) [TH_b] · TB-57 (moderator design), TB-63 (conventions) [T7]. Plus: #36 self-overlap paragraph — DRAFT prose block in `docs/overlap_disclosure_v12.md` (no TB number; adapt author-count placeholder).

**Proposed section walk (M1 may refine; PRISMA section written last within the session):**
3.1 Search, screening & inclusion — draft-20260612 substance (database list, inclusion criteria + fn. 1–3, Appendix-1 search strings) + `[PENDING #16]` slots (search date, hit/screening counts, inter-coder) + `[PENDING #23]` Capelle-Blancard PRISMA note slot
3.2 Corpus & self-overlap — v12 quantities + #36 paragraph
3.3 Effect sizes — PCC regime (van Aert 2023), conversion & variance conventions [TB-03]
3.4 Paris coding [TB-16/17/18]
3.5 Model & inference [TB-01/02] + SESOI/TOST/register pre-specification [TB-38]
3.6 Moderator analysis design [TB-57/63] + O-A' declaration paragraph (two-tier pre-registered heterogeneity analysis answering RQ3; no H3+)
3.7 Identification battery [TB-20]
3.8 Publication-bias battery [TB-30]
3.9 Bayesian sensitivity [TB-52]
3.10 Power & design sensitivity anchor [TB-47]
Data availability — `[PENDING R5]` slot (ruling at M7)

**Table/figure stubs:** Table 1 (variables & coding; rebuild from draft footnotes 6–7 + final panel definitions) · Fig. 2 PRISMA flow `[PENDING #16]`.

**Out of scope for M1:** any Results/Discussion prose; TB-28 flip (M2); TB-08 (#37, M2); title/abstract (M6).

---

## §3 Working conventions (unchanged)

German discussion / English artifacts. Complete files only; every delivery with a file→target-folder placement table. Commit ritual: Explorer placement → certutil MD5 spot-check immediately after placement (.md hashes valid only pre-add) → ONE CMD block `git status` → `git add` (explicit file list) → `git commit` → `git log -1 --stat` pasted back → PK swap. Hard sequencing: C-block only AFTER line-wise author verification of the B-stage certutil output. Log discipline: DEC for any methodology-relevant framing decision (log-first, same commit); ERROR log bilateral. Locked vocabulary and single-home rule bind all prose.

---

## §4 Open items relevant to M1

- **#16** (Volker, requested 2026-07-31): if absent at session start, write with hard `[PENDING #16]` slots; submission stays gated on them.
- **#23** (requested 2026-07-31): PRISMA note + drop-one sensitivity note; slot in 3.1.
- **#33**: not an M1 item; waiver decision at M7.
- Draft-20260612 reusable Methods assets are inventoried in Map §9 (Ch.-3 verdict).
