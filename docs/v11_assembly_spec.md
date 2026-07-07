# v11 Assembly Specification — CER-COD_data_v11.xlsx
Status: DRAFT for pre-execution diff-review (foundational artifact per review-gate rule: T0.4-class).
Governing decisions: DEC-026, -033, -035–-040. Inputs frozen at 2026-07-07 state.

## 1. Inputs
- I1 `staging/` final state: 132 staging_*.csv + 132 log_*.md + run_manifest.csv (2,716 rows; integrity-verified).
- I2 `adjudication_package_v1_rw.xlsx` — Volker/author verdicts (study-level dispositions; sheets Adjudikations-Posten, Block_Verdikte, Rulings_Verdikte).
- I3 `CER-COD_data_v10.xlsx` — legacy record (1,306 rows, 66 keys) for adoptions and value overrides.
- I4 `lookup_staging.csv` (61 records, verified; B/C→B fix; Zheng & Ng-Rezaee identity confirmed).
- I5 DEC-039 ruling layer (unit boundary, clusters, sign regimes, tags).

## 2. Output
`data/CER-COD_data_v11.xlsx`, four sheets:
- **data** — one row per effect estimate.
- **provenance** — per row: source {staging | v10-adopted | v10_version}, staging_file/v10_ID, es_method, dedup/duplicate status, verdict reference.
- **lookup** — study-level: v11_key, segment, VoR reference, DOI, journal, year, q_status, q_vhb, jif (dormant), country, industry (R4), regulation fields (F36), cluster_id.
- **buildlog** — counts per pipeline step, all verifier results.

### Column architecture (sheet data)
Block A: the **29 v10 columns, byte-identical names and order** (including historical header typos). Legacy semantics unchanged.
Block B (extension, appended): x_direction, outcome_direction, b, SE, t, p, r_bivariate, n_obs, x_lag, estimation_method, se_clustering, subsample_dimension, subsample_value, subsample_start, subsample_end, table_no, panel_model, page, cell_quote, construct_label_verbatim, outcome_label_verbatim, corpus_segment {original|update|rescreen}, cluster_id, source, es_method, construct_variant, unit, duplicate {0|1}.

## 3. Pipeline (deterministic; each step logs in/out counts)
- P1 Load & integrity: 26-field check, NUL scan, count reconciliation vs manifest (expect 2,716).
- P2 Key mapping: legacy files → v10 keys (evidence-based crosswalk incl. Fonseka a=energy/b=realestate, Jung 2016←2018, Höck/Kölbel oe-forms, Cubas, Du, Chen, Christ, Chen&Gao, M&W, Kordschia, Wang-2020/2022a, Zhou-2018). New studies → lookup keys (Wang 2025a/b; Ng & Rezaee (2012); K&V cluster key = "Kleimeier, Viehs (2021)"). v10 keys are never renamed (codebook §1).
- P3 Segment: original = v10-matched (Hui → update per DEC-038); rescreen = DEC-038 mandate set + retroactives (K&V, Kozak, Ratajczak); update = remainder.
- P4 Removals: Zhou-2016 stray file (out-of-window, 1); Zhang prod_inno rows via construct_label match (12); K&V EL-duplicate rows via deterministic identity re-test |Δr|≤0.002 against WP set (9 dropped, logged; EL-unique row kept, source=EL2021).
- P5 Duplicate tagging (carried, not estimated): Ofogbe correlation cell r=0.001/p=.9818 → duplicate=1 (counts once via Sandra set, N=1,440 per F37d).
- P6 Verdict application, VALUE-DIFF (236): deterministic re-match (T1-algorithm: r=t/√(t²+n), tolerance bands ≤0.0006 exact, ≤0.02 diff, sign harmonization incl. author-inverted rule). Studies with "Staging korrekt" → staging raw stats stand (184). Studies with "v10 korrekt" → matched row's ES set to v10 value, es_method='v10-adopted' (52; includes the 13 structural-class diffs — flagged in buildlog as propagation-ambiguous, materially trivial).
- P7 Verdict application, V10-ONLY adoptions (+160): Einzelprüfung 84 + Eichholtz 25 (unit=building/loan) + Versionsdrift 51 (source='v10_version'). Rows constructed from v10 record; es_method='v10-adopted'. **Versionsdrift dedup:** within study, |Δr|≤0.0006 vs any staging row → drop as superseded (logged); expected reduction small.
- P8 Structural exclusions stand (Lesart i): 208 v10-only rows of Delis/Seltzer (R2.7) and Tan/Wang-2022a (ambient gate) remain out; Zhou-2018/Cubas v10-only out per waiver (58).
- P9 Ruling-layer field resolutions: Trinh CER_measure→performance (104); slope rows COD_instrument→'derivativ (CDS spread)' (identified via label regex ∪ log tags; Kölbel 24 + Zhang 18 + O&T 4 + Truong 2); Wang-2020 estimation_method→'other: not stated' (28); Zhu&Zhao stay (tag construct_variant per F45a boundary); Delis price-valued tag (4); Devalle R1 regime (outcome_direction=cost, three signs inverted vs v10, row-409 via z-route |z|=2.32/p=.021); K1/K2 tags (slope-group; PSM-ATT); K3 χ²→z where b present; F37d n-fill: n_obs=FLAG → max(n_obs) within study (documented proxy for full estimation sample).
- P10 ES computation (all staging-sourced rows): r = t/√(t²+n_obs); t from (i) reported t, (ii) b/SE, (iii) two-sided p→t (sign from b); r_bivariate direct. Stars-only rows (F41e label): conservative star-bound p (\*:0.05, \*\*:0.01, \*\*\*:0.001) → es_method='star-bound' (battery treatment decided at DEC-031). Sign harmonization: flip iff XOR(x_direction=bad-CER, outcome_direction=creditworthiness); author-inverted-to-good = no flip.
- P11 cluster_id: default = v11 study key; joint clusters: {Sandra, Ofogbe}, {K&V}. 
- P12 Study-level moderator block for NEW studies: country/sample window parsed from log study blocks; regulation fields per F36 rules; **industry per R4** (sector list + >50% firm-years; borderline→mixed) from log sample descriptions. Unresolvable → residual list (Volker, expected small). Legacy moderators carry from v10 unchanged.

## 4. Verifier (paired script; numbered PASS/FAIL)
V1 input counts (2,716/132/66). V2 column architecture: Block A byte-identical to v10 header. V3 key coverage: every staging file mapped; every v10 key accounted (61 carried / 5 exits / Zhou-2018 rows per waiver). V4 balance equation: 2,716 −1 −12 −9 +160 −dedup = data rows; estimation rows = data − duplicates(1). V5 segment counts (original/update/rescreen = 61/42/18 studies). V6 no FLAG remaining in closed-list fields except documented residual list. V7 Devalle: row-409 ES ≈ −/+ per R1; no |r|>0.99 anywhere. V8 dedup log complete (K&V 9; version dedups enumerated). V9 cluster_id: exactly 2 joint clusters. V10 ES recompute spot-check: 25 random staging rows, script ES = manual formula. V11 adopted rows: ES equals v10 value exactly. V12 gold anchors present & cell-exact (Shad/Oik/Lemma/Eliwa). V13 slope rows: COD_instrument uniform. V14 star-bound rows: es_method labeled, count reported. V15 lookup join: 60 new studies matched, q_vhb/jif fields typed. V16 provenance: every row has source + es_method.

## 5. Freeze gate
This build = **v11-preliminary** (analysis-pipeline development only). **v11-freeze (DEC-041)** requires: DB re-run result (incl. any straggler mini-tranche through the v1.6 workflow) + JIF completion for all journals (b1; dormant field) + residual moderator list resolved. One rebuild, then T1.

## 6. Quality-moderator ruling (resolves DEC-023)
q-moderator = **VHB-JOURQUAL only**; WP and VHB-unrated journals = missing in that moderator (analysis-specific listwise drop). JIF collected for ALL journals (b1) as a dormant reserve field; not used unless a reviewer requires a robustness check.
