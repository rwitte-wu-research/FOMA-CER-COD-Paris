#!/usr/bin/env python3
# =============================================================================
# build_ch4_tables.py — manuscript table builder for Chapter 4 (M2)
# Generates the four Chapter-4 tables as Markdown from the committed results
# CSVs (manuscript pipeline ruling, Map §7: tables are build artifacts; no
# hand-transcription, no Excel intermediate):
#   Table 2  — robustness register        <- output/robustness_register.csv
#   Table 3  — moderator panels (M_A/M_B) <- output/T7_results.csv
#   Table 4  — bias-method triangulation  <- output/robustness_register.csv
#                                            + output/T5_results.csv
#   Table A.1 — pairwise level contrasts  <- output/T7_results.csv
# Keys: analysis_id :: spec :: term. Rounding: r/CI 3 dp (positive bounds
# unsigned); Δz 3 dp signed, |Δz| < 0.0005 -> "0.000" [ruling A3]. Hard
# asserts on all design constants (23 register rows; 8 panels; 15 pairs;
# D6 row set) — any mismatch stops the build.
# Output: stdout (redirect as needed). Embedded in manuscript/ch4_results.md
# at M2; provenance comments there cite this script @ the package commit.
# =============================================================================
import csv, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
P_REG = os.path.join(ROOT, "output", "robustness_register.csv")
P_T7  = os.path.join(ROOT, "output", "T7_results.csv")
P_T5  = os.path.join(ROOT, "output", "T5_results.csv")

def die(msg):
    sys.stderr.write(f"BUILD FAIL: {msg}\n"); sys.exit(1)

def r3(x):
    if x is None or x == "": return "\u2014"
    x = float(x)
    return f"\u2212{abs(x):.3f}" if x < 0 else f"{x:.3f}"

def dz3(x):
    if x is None or x == "": return "\u2014"
    x = float(x)
    if abs(x) < 0.0005: return "0.000"            # ruling A3
    return f"\u2212{abs(x):.3f}" if x < 0 else f"+{x:.3f}"

def p3(x):
    if x is None or x == "": return "\u2014"
    return f"{float(x):.3f}"

def ci(lb, ub):
    if lb is None or lb == "": return "\u2014"
    return f"[{r3(lb)}; {r3(ub)}]"

def load(path):
    if not os.path.exists(path): die(f"missing source: {path}")
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))

# ---------------------------------------------------------------- Table 2 ----
REG_LBL = {
 "headline": "Headline model (CHE\u2013RVE)",
 "one_effect_per_cluster": "One effect per cluster (Knapp\u2013Hartung)",
 "uwls3": "UWLS+3",
 "rho_0.4": "Working correlation \u03c1 = 0.4",
 "rho_0.8": "Working correlation \u03c1 = 0.8",
 "no_starbound": "Excluding star-bound effect sizes",
 "no_nobs_proxyfill": "Excluding proxy-filled sample sizes",
 "n_firms_variance": "Sampling variance on firm counts",
 "direct_r_only": "Directly reported correlations only",
 "pcc_df_k10": "Partial-correlation df, k = 10",
 "pcc_df_k20": "Partial-correlation df, k = 20",
 "one_per_cluster_median": "Cluster-median aggregation",
 "panel_q_vhb": "Panel: journal quality",
 "panel_field": "Panel: research field",
 "panel_es_measure": "Panel: effect-size type",
 "panel_es_method": "Panel: conversion route",
 "outlier_rstudent": "Excluding studentized-residual outliers (13 ES)",
 "outlier_mad": "Excluding MAD outliers (275 ES)",
 "winsor": "Winsorized (P1/P99)",
 "trim_1_99": "Trimmed (P1/P99)",
 "leave_one_out": "Leave-one-out (114 cluster refits)",
 "influence_diagnostics": "Influence diagnostics",
 "loso_post_cell": "Post-Paris leave-one-study-out",
}
REG_PTR = {"panel_q_vhb": "reported in text", "panel_field": "reported in text",
           "panel_es_measure": "reported in text", "panel_es_method": "reported in text",
           "leave_one_out": "summary in text; Appendix",
           "influence_diagnostics": "Appendix", "loso_post_cell": "Section 4.2.1"}
REG_GRP = {"headline": "A", "one_effect_per_cluster": "A", "uwls3": "A",
           "rho_0.4": "A", "rho_0.8": "A"}
GRP_HDR = {"A": "*Anchor specifications*", "G": "*Design variants*", "F": "*Outlier and influence*"}
GRP_OF = lambda s, i: REG_GRP.get(s, "G" if i < 16 else "F")

def table2(reg):
    if len(reg) != 23: die(f"register rows {len(reg)} != 23")
    out = ["**Table 2.** Robustness register for the pooled CER\u2013COD association "
           "(23 pre-specified specifications; \u0394 on the Fisher-z scale against the "
           "headline; full register machine-readable in the online appendix).", "",
           "| Specification | k (ES) | r | 95% CI | \u0394z vs. headline |",
           "|---|---|---|---|---|"]
    last = None
    for i, r in enumerate(reg):
        s = r["spec"]
        g = GRP_OF(s, i)
        if g != last:
            out.append(f"| {GRP_HDR[g]} | | | | |"); last = g
        if r.get("est_r"):
            d = "(reference)" if s == "headline" else dz3(r["delta_vs_headline_z"])
            k = f"{int(r['k_es']):,}" if r.get("k_es") else "114"
            out.append(f"| {REG_LBL[s]} | {k} | {r3(r['est_r'])} | "
                       f"{ci(r['ci_lb_r'], r['ci_ub_r'])} | {d} |")
        else:
            out.append(f"| {REG_LBL[s]} | \u2014 | \u2014 | {REG_PTR[s]} | \u2014 |")
    return "\n".join(out)

# ---------------------------------------------------------------- Table 3 ----
PANELS = {
 "C1": ("CER measurement", {"lvl::performance": "Performance-based",
                            "lvl::disclosure": "Disclosure-based"}),
 "C2": ("Debt instrument", {"lvl::loan (interest rate)": "Loan (interest rate)",
                            "lvl::bond (yield)": "Bond (yield)",
                            "lvl::rating": "Rating",
                            "lvl::derivativ (CDS spread)": "CDS spread"}),
 "C3": ("Industry sensitivity", {"lvl::non-sensitive": "Non-sensitive",
                                 "lvl::sensitive": "Sensitive"}),
 "C4": ("Carbon regulation", {"lvl::without ETS/CT": "Without ETS/CT",
                              "lvl::with ETS/CT": "With ETS/CT"}),
 "C5": ("Country region", {"lvl::1_US": "United States", "lvl::2_Europe": "Europe",
                           "lvl::3_AsiaPac": "Asia-Pacific"}),
 "C6": ("Economic development", {"lvl::1_developed": "Developed",
                                 "lvl::2_developing": "Developing"}),
 "C7": ("Cultural cluster", {"lvl::1_western": "Western",
                             "lvl::2_non_western": "Non-western"}),
 "C8": ("Legal origin", {"lvl::1_common law": "Common law",
                         "lvl::2_civil law": "Civil law"}),
}
T3_NOTE = ("*Note.* Level tests = panel omnibus HTZ; interaction tests = "
           "period-interaction HTZ; Holm-adjusted minimum across the eight "
           "interaction tests = .616. Shifts without p are reported descriptively "
           "under the pre-specified small-cell rule (Section 3.3.2); \u2014 = no "
           "estimable post-Paris cell (Section 4.3 text). Pairwise level "
           "contrasts: Appendix Table A.1. NEC categories excluded per "
           "Section 3.3.2.")

def index_t7(rows):
    D = {}
    for r in rows:
        D[(r.get("analysis_id", ""), r.get("spec", ""), r.get("term", ""))] = r
    return D

def table3(D):
    out = ["**Table 3.** Moderator analysis, all eight panels: level tests (M_A) "
           "and period-interaction tests (M_B).", "",
           "| Panel / level | k (ES / cl) | r | 95% CI | Paris shift \u0394z | p (shift) |",
           "|---|---|---|---|---|---|"]
    for cid, (pname, lv) in PANELS.items():
        om = D.get((cid, "levels", "levels_HTZ")) or die(f"{cid}: levels_HTZ missing")
        ih = D.get((cid, "paris_mid", "interaction_HTZ")) or die(f"{cid}: interaction_HTZ missing")
        out.append(f"| **{pname}** \u2014 level test p = {p3(om['p'])}; "
                   f"interaction test p = {p3(ih['p'])} | | | | | |")
        for t, lab in lv.items():
            L = D.get((cid, "levels", t)) or die(f"{cid}: {t} missing")
            dif = D.get((cid, "paris_mid", "diff::" + t.replace("lvl::", "")))
            kk = f"{int(float(L['k_es'])):,} / {int(float(L['k_cluster']))}"
            ez = dif.get("est_z") if dif else None
            pp = dif.get("p") if dif else None
            out.append(f"| \u2003{lab} | {kk} | {r3(L['est_r'])} | "
                       f"{ci(L['ci_lb_r'], L['ci_ub_r'])} | {dz3(ez)} | {p3(pp)} |")
    out += ["", T3_NOTE]
    return "\n".join(out)

# ---------------------------------------------------------------- Table 4 ----
D6_ROWS = [  # (analysis_id, spec, term, display name, note)
 ("D2", "selection_full", "mu_unadjusted_ML", "Unadjusted RE/ML on aggregates",
  "aggregate base model (k = 114)"),
 ("D1", "pet", "intercept", "PET (regression-corrected)",
  "not claim-carrying (PEESE selected per rule)"),
 ("D1", "peese", "intercept", "PEESE (regression-corrected)",
  "claim-carrying per pre-specified rule"),
 ("D2", "selection_full", "mu_3psm", "3PSM (selection-adjusted)",
  "\u03b4 = 0.49; LRT p = .025"),
 ("D2", "selection_full", "mu_punistar", "p-uniform* (selection-adjusted)",
  "concordant with 3PSM"),
 ("D5", "grey_panel", "contrast_np_minus_p",
  "Grey-literature contrast (unpub. \u2212 pub.)", "direct check: precise null"),
]
ROBMA_ROW = ("| RoBMA (Bayesian model averaging) | \u2014 | model-averaged mean "
             "between \u22120.009 and +0.008 | cross-cited from Section 4.2.2; "
             "strong selection-component inclusion |")

def table4(reg, t5):
    hz = [r for r in reg if r["spec"] == "headline"]
    if len(hz) != 1: die("headline row not unique in register")
    h = hz[0]
    D = index_t7(t5)  # same key structure
    out = ["**Table 4.** Triangulation of the pooled association across "
           "publication-bias methods (Fisher-z scale).", "",
           "| Method | est (z) | 95% CI | Note |", "|---|---|---|---|",
           f"| Unadjusted CHE\u2013RVE headline | {r3(h['est_z'])} | "
           f"{ci(h['ci_lb_z'], h['ci_ub_z'])} | reference (2,713 ES / 114 clusters) |"]
    for aid, sp, tm, name, note in D6_ROWS:
        r = D.get((aid, sp, tm)) or die(f"T5 row {aid}|{sp}|{tm} missing")
        out.append(f"| {name} | {r3(r['est_z'])} | {ci(r['ci_lb_z'], r['ci_ub_z'])} | {note} |")
    out.append(ROBMA_ROW)
    return "\n".join(out)

# --------------------------------------------------------------- Table A.1 ---
PAIR_LBL = {
 "performance - disclosure": ("CER measurement", "Performance-based \u2212 Disclosure-based"),
 "loan (interest rate) - bond (yield)": ("Debt instrument", "Loan \u2212 Bond"),
 "loan (interest rate) - rating": ("Debt instrument", "Loan \u2212 Rating"),
 "loan (interest rate) - derivativ (CDS spread)": ("Debt instrument", "Loan \u2212 CDS spread"),
 "bond (yield) - rating": ("Debt instrument", "Bond \u2212 Rating"),
 "bond (yield) - derivativ (CDS spread)": ("Debt instrument", "Bond \u2212 CDS spread"),
 "rating - derivativ (CDS spread)": ("Debt instrument", "Rating \u2212 CDS spread"),
 "non-sensitive - sensitive": ("Industry sensitivity", "Non-sensitive \u2212 Sensitive"),
 "without ETS/CT - with ETS/CT": ("Carbon regulation", "Without ETS/CT \u2212 With ETS/CT"),
 "1_US - 2_Europe": ("Country region", "United States \u2212 Europe"),
 "1_US - 3_AsiaPac": ("Country region", "United States \u2212 Asia-Pacific"),
 "2_Europe - 3_AsiaPac": ("Country region", "Europe \u2212 Asia-Pacific"),
 "1_developed - 2_developing": ("Economic development", "Developed \u2212 Developing"),
 "1_western - 2_non_western": ("Cultural cluster", "Western \u2212 Non-western"),
 "1_common law - 2_civil law": ("Legal origin", "Common law \u2212 Civil law"),
}

def table_a1(t7):
    pairs = [r for r in t7 if r.get("spec") == "levels"
             and str(r.get("term", "")).startswith("pair::")
             and r.get("analysis_id") in PANELS]
    if len(pairs) != 15: die(f"pairwise rows {len(pairs)} != 15")
    out = ["**Appendix Table A.1.** Pairwise level contrasts across the eight "
           "moderator panels (Fisher-z scale; nominal p-values, reported "
           "descriptively; contrasts without p follow the small-cell rule, "
           "Section 3.3.2; the inferential home for moderation is the "
           "eight-test interaction family, Table 3).", "",
           "| Panel | Contrast | \u0394z | p (nominal) |", "|---|---|---|---|"]
    for r in pairs:
        key = r["term"][6:]
        panel, lab = PAIR_LBL.get(key, ("?", key))
        out.append(f"| {panel} | {lab} | {dz3(r.get('est_z'))} | {p3(r.get('p'))} |")
    return "\n".join(out)

# ------------------------------------------------------------------- main ----
def main():
    reg = load(P_REG)
    t7 = load(P_T7)
    t5 = load(P_T5)
    D7 = index_t7(t7)
    sep = "\n\n" + "-" * 78 + "\n\n"
    print(table2(reg), end=sep)
    print(table3(D7), end=sep)
    print(table4(reg, t5), end=sep)
    print(table_a1(t7))

if __name__ == "__main__":
    main()
