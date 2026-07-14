# =============================================================================
# R/02_verify_outputs.R -- paired verifier for R/02_paris.R (T2, Block B coding
# layer). Checks O1-O17, numbered PASS/FAIL; exit status 1 on any FAIL.
# ORACLE INDEPENDENCE: this script does NOT source 02_paris.R. Constants below
# are intentionally duplicated. O12/O14 identities (LOSO k, disclosures) are
# recomputed from output/dat_prep.rds. Spec: docs/T2_spec.md (FROZEN,
# Rev. 2026-07-13b incl. F58 erratum: 96 rows).
# Convention: verifier = oracle for the Claude-Code run [Setup tab; Addendum A.7].
# =============================================================================

# ---- duplicated config (keep in sync with 02_paris.R) ---------------------------
PATH_DAT_PREP <- here::here("output", "dat_prep.rds")
DIR_OUT   <- here::here("output")
RES_PATH  <- file.path(DIR_OUT, "T2_results.csv")
META_PATH <- file.path(DIR_OUT, "T2_run_meta.txt")
DQ_PATH   <- file.path(DIR_OUT, "design_quantities_v12.csv")

K_ES <- 2713L; K_STUDY <- 115L; K_CLUSTER <- 114L; K_STUDY_POST <- 31L
K_PERIOD_NA <- 8L; K_PERIOD_NA_STUDY <- 2L
K_DEFINED <- K_ES - K_PERIOD_NA          # 2705 [DEC-042b]
N_ROWS <- 96L                            # F58 erratum: 10x3 + 31 + 1 + 31 + 3

CODING_COLS <- c("pp_mid_lag0", "pp_median_lag0",
                 "pp_end_lag0", "pp_end_lag1", "pp_end_lag2", "pp_end_lag3",
                 "share_2016", "share_2017", "share_2018", "share_2019",
                 "pp_window_class")

# P5 mapping (deliberately duplicated string literals; documented in run_meta)
CLEAN_PRE_LEVEL  <- "pre-only"
CLEAN_POST_LEVEL <- "post-only"

SCHEMA <- c("analysis_id", "spec", "subset", "term", "metric", "estimator", "rho",
            "k_es", "k_study", "k_cluster",
            "est_z", "se_z", "t_stat", "df", "p",
            "ci_lb_z", "ci_ub_z", "pi_lb_z", "pi_ub_z",
            "est_r", "ci_lb_r", "ci_ub_r", "pi_lb_r", "pi_ub_r",
            "sigma2_cluster", "sigma2_study", "sigma2_esid",
            "pct_cluster", "pct_study", "pct_esid", "pct_sampling", "typical_v",
            "value", "ms_input", "ms_label", "note")

# 10 coding models: spec label + subset label (free-field convention, run_meta)
CODING_SPECS <- rbind(
  c("paris_mid",        "defined"),
  c("tie_break_median", "defined"),
  c("end_any_exposure", "defined"),
  c("share_recut_2017", "defined"),
  c("share_recut_2018", "defined"),
  c("share_recut_2019", "defined"),
  c("end_lag1",         "defined"),
  c("end_lag2",         "defined"),
  c("end_lag3",         "defined"),
  c("clean_window",     "clean_cells"))
FULL_DOMAIN_SPECS <- setdiff(CODING_SPECS[, 1], "clean_window")
TIER1_SPECS <- c("paris_mid", "clean_window")   # hard df >= 4 [F57 two-tier]

# ---- harness --------------------------------------------------------------------
results <- character(0); n_fail <- 0L
check <- function(id, ok, desc, detail = "") {
  detail <- paste(detail, collapse = " ")   # guard: length-0 detail -> ""
  status <- if (isTRUE(ok)) "PASS" else "FAIL"
  if (!isTRUE(ok)) n_fail <<- n_fail + 1L
  line <- sprintf("%-4s %s -- %s%s", id, status, desc,
                  if (nzchar(detail)) paste0(" [", detail, "]") else "")
  results[[length(results) + 1L]] <<- line
  cat(line, "\n")
}
near <- function(a, b, tol) length(a) == length(b) &&
  all(is.finite(a) & is.finite(b)) && all(abs(a - b) <= tol)

# ---- O1 files exist; NO T2 figures ------------------------------------------------
t2_figs <- list.files(DIR_OUT, pattern = "T2.*\\.(pdf|png|svg|jpe?g)$",
                      recursive = TRUE, ignore.case = TRUE)
check("O1", file.exists(RES_PATH) && file.exists(META_PATH) && length(t2_figs) == 0,
      "T2_results.csv + T2_run_meta.txt exist; no T2 figure files [DEC-031a.7]",
      if (length(t2_figs)) paste("figures found:", paste(t2_figs, collapse = ", "))
      else "")
if (!file.exists(RES_PATH)) { cat("ABORT: results CSV missing.\n"); quit(status = 1L) }

res <- read.csv(RES_PATH, stringsAsFactors = FALSE)

# ---- O2 schema exact ---------------------------------------------------------------
check("O2", identical(names(res), SCHEMA),
      "CSV schema exact: 36 names + order (T1 schema + term after subset)",
      paste(c(setdiff(SCHEMA, names(res)), setdiff(names(res), SCHEMA)), collapse = ", "))

# ---- load dat_prep for inventory + recomputation checks ----------------------------
pr_ok <- FALSE
if (file.exists(PATH_DAT_PREP)) {
  pr <- readRDS(PATH_DAT_PREP)
  pr_ok <- is.list(pr) && !is.null(pr$dat) &&
           identical(as.integer(pr$n), K_ES) &&
           identical(as.integer(pr$seed), 20260710L) &&
           all(CODING_COLS %in% names(pr$dat)) &&
           all(c("zi", "vi", "cluster_id", "study", "esid",
                 "pp_share_lag0") %in% names(pr$dat)) &&
           nrow(pr$dat) == K_ES
}
if (pr_ok) {
  dd <- pr$dat
  pm <- as.integer(as.character(dd$pp_mid_lag0))
  md <- as.integer(as.character(dd$pp_median_lag0))
  e0 <- as.integer(as.character(dd$pp_end_lag0))
  st <- as.character(dd$study)
  post_studies <- sort(unique(st[!is.na(pm) & pm == 1L]))
  wc <- as.character(dd$pp_window_class)
  cw_def <- !is.na(wc) & wc %in% c(CLEAN_PRE_LEVEL, CLEAN_POST_LEVEL)
  CLEAN_TOTAL <- sum(cw_def)
} else {
  post_studies <- character(0)
}

row_of <- function(sp, tm) res[res$spec == sp & res$term == tm, , drop = FALSE]

# ---- O3 row inventory exact: 96 (spec, subset, term), no duplicates -----------------
if (pr_ok && length(post_studies) == K_STUDY_POST) {
  exp_inv <- rbind(
    do.call(rbind, lapply(seq_len(nrow(CODING_SPECS)), function(i)
      data.frame(spec = CODING_SPECS[i, 1], subset = CODING_SPECS[i, 2],
                 term = c("cell_pre", "cell_post", "diff")))),
    data.frame(spec = "loso_post", subset = post_studies, term = "diff"),
    data.frame(spec = "loso_post_summary", subset = "post_cell", term = "range"),
    data.frame(spec = "post_dominance", subset = post_studies, term = "weight_share"),
    data.frame(spec = c("disclosure_attenuation_end", "disclosure_knife_edge",
                        "disclosure_panel_drift"),
               subset = c("end_post", "defined", "defined"), term = "value"))
  got <- paste(res$spec, res$subset, res$term, sep = "::")
  exp <- paste(exp_inv$spec, exp_inv$subset, exp_inv$term, sep = "::")
  check("O3", nrow(res) == N_ROWS && length(exp) == N_ROWS &&
          identical(sort(got), sort(exp)) && !anyDuplicated(got),
        sprintf("row inventory exact: %d (spec, subset, term) rows, no duplicates [F58]", N_ROWS),
        paste(utils::head(c(setdiff(exp, got), setdiff(got, exp)), 4), collapse = " ; "))
} else {
  check("O3", FALSE, "row inventory (dat_prep contract unavailable for study keys)")
}

# ---- O4 domain identities -----------------------------------------------------------
ok4 <- TRUE; det4 <- ""
for (sp in FULL_DOMAIN_SPECS) {
  cp <- row_of(sp, "cell_pre"); cq <- row_of(sp, "cell_post"); df_ <- row_of(sp, "diff")
  if (nrow(cp) != 1 || nrow(cq) != 1 || nrow(df_) != 1 ||
      df_$k_es != K_DEFINED || (cp$k_es + cq$k_es) != K_DEFINED) {
    ok4 <- FALSE; det4 <- paste0(det4, sp, " ") }
}
cwp <- row_of("clean_window", "cell_pre"); cwq <- row_of("clean_window", "cell_post")
cwd <- row_of("clean_window", "diff")
if (pr_ok) {
  if (nrow(cwp) != 1 || nrow(cwq) != 1 || nrow(cwd) != 1 || cwd$k_es != CLEAN_TOTAL ||
      (cwp$k_es + cwq$k_es) != CLEAN_TOTAL || !is.finite(cwd$df) || cwd$df < 5) {
    ok4 <- FALSE; det4 <- paste0(det4, "clean_window ") }
} else { ok4 <- FALSE; det4 <- paste0(det4, "clean_window(dat_prep unavailable) ") }
check("O4", ok4,
      "domain identities: coding specs k_es = 2705 (diff row; cells sum); clean_window k = clean total, df >= 5",
      if (nzchar(det4)) paste("failed:", det4) else
        sprintf("clean total = %d; clean diff df = %.2f", CLEAN_TOTAL, cwd$df))

# ---- O5 paris_mid cells [design] ------------------------------------------------------
pmp <- row_of("paris_mid", "cell_pre"); pmq <- row_of("paris_mid", "cell_post")
check("O5", nrow(pmp) == 1 && nrow(pmq) == 1 &&
        pmq$k_study == K_STUDY_POST && (pmp$k_es + pmq$k_es) == K_DEFINED,
      "paris_mid: cell_post k_study = 31 [design]; cell_pre + cell_post k_es = 2705",
      sprintf("pre %s ES / %s st; post %s ES / %s st",
              pmp$k_es, pmp$k_study, pmq$k_es, pmq$k_study))

# ---- O6 P1 identity -------------------------------------------------------------------
if (pr_ok) {
  ok6 <- identical(is.na(dd$pp_share_lag0), is.na(dd$share_2016)) &&
    max(abs(dd$pp_share_lag0 - dd$share_2016), na.rm = TRUE) <= 1e-12 &&
    length(unique(dd$pp_share_lag0[!is.na(dd$pp_share_lag0)])) > 2L
  check("O6", ok6, "P1: pp_share_lag0 identical to share_2016 (tol 1e-12), continuous (> 2 values)",
        sprintf("distinct values = %d",
                length(unique(dd$pp_share_lag0[!is.na(dd$pp_share_lag0)]))))
} else check("O6", FALSE, "P1 identity (dat_prep contract unavailable)")

# ---- O7 P3 identity -------------------------------------------------------------------
if (pr_ok) {
  rc16 <- ifelse(is.na(dd$share_2016), NA_integer_, as.integer(dd$share_2016 >= 0.5))
  check("O7", identical(is.na(rc16), is.na(pm)) && all(rc16 == pm, na.rm = TRUE),
        "P3: (share_2016 >= 0.5, ties->Post) reproduces pp_mid_lag0 on defined rows [DEC-024]")
} else check("O7", FALSE, "P3 identity (dat_prep contract unavailable)")

# ---- O8 P4 tie-break domain + design_quantities cross-check ----------------------------
if (pr_ok) {
  dis <- which(!is.na(pm) & !is.na(md) & pm != md)
  ok8 <- all(dd$share_2016[dis] == 0.5)
  det8 <- sprintf("disagreements = %d, all at share_2016 == 0.5", length(dis))
  if (file.exists(DQ_PATH)) {
    dq <- read.csv(DQ_PATH, stringsAsFactors = FALSE)
    if (all(c("pp_mid", "pp_median") %in% dq$quantity) && "k_post" %in% names(dq)) {
      exp_dis <- as.integer(dq$k_post[dq$quantity == "pp_mid"]) -
                 as.integer(dq$k_post[dq$quantity == "pp_median"])
      ok8 <- ok8 && length(dis) == exp_dis
      det8 <- paste0(det8, sprintf("; cross-check vs design_quantities k_post(pp_mid)-k_post(pp_median) = %d", exp_dis))
    } else det8 <- paste0(det8, "; INFO: no matching design_quantities key")
  } else det8 <- paste0(det8, "; INFO: design_quantities_v12.csv not found")
  check("O8", ok8, "P4: pp_median disagreements with pp_mid only at share_2016 == 0.5; count cross-checked", det8)
} else check("O8", FALSE, "P4 tie-break (dat_prep contract unavailable)")

# ---- O9 diff identity per coding model ---------------------------------------------------
ok9 <- TRUE; det9 <- ""
for (sp in CODING_SPECS[, 1]) {
  cp <- row_of(sp, "cell_pre"); cq <- row_of(sp, "cell_post"); df_ <- row_of(sp, "diff")
  if (nrow(cp) != 1 || nrow(cq) != 1 || nrow(df_) != 1 ||
      !near(cq$est_z - cp$est_z, df_$est_z, 1e-10)) {
    ok9 <- FALSE; det9 <- paste0(det9, sp, " ") }
}
check("O9", ok9, "cell_post - cell_pre == diff (est_z, tol 1e-10), all 10 coding models", det9)

# ---- O10 est inside CI; tanh identity on cells; diff rows z-only --------------------------
zr <- res[!is.na(res$est_z) & !is.na(res$ci_lb_z) & !is.na(res$ci_ub_z), ]
rr <- res[!is.na(res$est_r) & !is.na(res$ci_lb_r) & !is.na(res$ci_ub_r), ]
cells <- res[res$term %in% c("cell_pre", "cell_post"), ]
diffs <- res[res$term == "diff", ]
ok10 <- all(zr$ci_lb_z < zr$est_z & zr$est_z < zr$ci_ub_z) &&
        all(rr$ci_lb_r < rr$est_r & rr$est_r < rr$ci_ub_r) &&
        near(cells$est_r,   tanh(cells$est_z),   1e-10) &&
        near(cells$ci_lb_r, tanh(cells$ci_lb_z), 1e-10) &&
        near(cells$ci_ub_r, tanh(cells$ci_ub_z), 1e-10) &&
        all(is.na(diffs$est_r)) && all(is.na(diffs$ci_lb_r)) && all(is.na(diffs$ci_ub_r))
check("O10", ok10,
      "est strictly inside CI (both scales); r == tanh(z) on cell rows; diff rows est_r/CI_r = NA by convention")

# ---- O11 per-coding NA structure [DEC-042b generalized] ------------------------------------
if (pr_ok) {
  ok11 <- TRUE; ref <- NULL
  for (cc in CODING_COLS) {
    na_idx <- is.na(dd[[cc]])
    sts <- sort(unique(st[na_idx]))
    if (sum(na_idx) != K_PERIOD_NA || length(sts) != K_PERIOD_NA_STUDY) ok11 <- FALSE
    if (is.null(ref)) ref <- sts else if (!identical(sts, ref)) ok11 <- FALSE
  }
  check("O11", ok11,
        "every window-derived coding: exactly 8 NA over exactly the same 2 studies [DEC-042b]",
        paste(ref, collapse = " | "))
} else check("O11", FALSE, "per-coding NA structure (dat_prep contract unavailable)")

# ---- O12 LOSO recomputation -----------------------------------------------------------------
lr <- res[res$spec == "loso_post", , drop = FALSE]
if (pr_ok) {
  k_exp <- vapply(lr$subset, function(s) sum(!is.na(pm) & st != s), integer(1))
  ok12 <- nrow(lr) == K_STUDY_POST &&
          setequal(lr$subset, post_studies) && !anyDuplicated(lr$subset) &&
          all(lr$term == "diff") &&
          all(lr$k_study == K_CLUSTER) &&            # 115 - 1 = 114 studies after drop
          all(lr$k_es == k_exp)
  check("O12", ok12,
        "LOSO: 31 rows over the 31 post studies; k_study == 114; k_es == recomputed remaining defined ES",
        if (nrow(lr)) sprintf("k_es range %d-%d", min(lr$k_es), max(lr$k_es))
        else "no loso_post rows")
} else check("O12", FALSE, "LOSO recomputation (dat_prep contract unavailable)")

# ---- O13 dominance ---------------------------------------------------------------------------
dm <- res[res$spec == "post_dominance", , drop = FALSE]
i_max <- which.max(dm$value)
ok13 <- nrow(dm) == K_STUDY_POST && near(sum(dm$value), 1, 1e-8) &&
        all(grepl("ES-count share", dm$note, fixed = TRUE))
check("O13", ok13,
      "dominance: 31 rows; weight shares sum to 1 (1e-8); note carries ES-count share",
      if (nrow(dm)) sprintf("max weight share = %.4f (%s); sum = %.10f",
                            dm$value[i_max], dm$subset[i_max], sum(dm$value))
      else "no post_dominance rows")

# ---- O14 disclosures recomputed from dat_prep -------------------------------------------------
if (pr_ok) {
  end_post <- !is.na(e0) & e0 == 1L
  v1 <- sum(end_post & dd$share_2016 < 0.5) / sum(end_post)
  def16 <- !is.na(dd$share_2016)
  v2 <- sum(def16 & dd$share_2016 >= 0.45 & dd$share_2016 <= 0.55) / sum(def16)
  v3 <- mean(dd$share_2016[def16]) -
        mean(tapply(dd$share_2016[def16], st[def16], mean))
  r1 <- row_of("disclosure_attenuation_end", "value")
  r2 <- row_of("disclosure_knife_edge", "value")
  r3 <- row_of("disclosure_panel_drift", "value")
  ok14 <- nrow(r1) == 1 && near(r1$value, v1, 1e-10) &&
          nrow(r2) == 1 && near(r2$value, v2, 1e-10) &&
          nrow(r3) == 1 && near(r3$value, v3, 1e-10)
  check("O14", ok14, "disclosures: all three values recomputed independently from dat_prep (tol 1e-10)",
        sprintf("attenuation %.6f; knife %.6f; drift %.6f", v1, v2, v3))
} else check("O14", FALSE, "disclosure recomputation (dat_prep contract unavailable)")

# ---- O15 df floors, two-tier [F57 logic] -------------------------------------------------------
d1 <- res[res$spec %in% TIER1_SPECS & res$term == "diff", ]
d2 <- res[res$spec %in% setdiff(CODING_SPECS[, 1], TIER1_SPECS) & res$term == "diff", ]
ok15 <- nrow(d1) == 2 && all(is.finite(d1$df)) && all(d1$df >= 4) &&
        nrow(d2) == 8 && all(is.finite(d2$df)) && all(d2$df > 1)
check("O15", ok15,
      "df floors: paris_mid + clean_window diff df >= 4 (hard); other coding diffs finite > 1",
      sprintf("tier1: %s; tier2: %s",
              paste(sprintf("%s=%.2f", d1$spec, d1$df), collapse = ", "),
              paste(sprintf("%s=%.2f", d2$spec, d2$df), collapse = ", ")))

# ---- O16 run_meta contents ----------------------------------------------------------------------
if (file.exists(META_PATH)) {
  meta <- readLines(META_PATH, warn = FALSE)
  ok16 <- any(grepl("md5", meta)) &&
          any(grepl("2713", meta)) && any(grepl("20260710", meta)) &&
          any(grepl("P5", meta)) &&
          any(grepl(CLEAN_PRE_LEVEL, meta, fixed = TRUE)) &&
          any(grepl(CLEAN_POST_LEVEL, meta, fixed = TRUE)) &&
          any(grepl("pp_share_lag1", meta)) &&
          any(grepl("sessionInfo", meta)) &&
          any(grepl("metafor", meta)) && any(grepl("clubSandwich", meta))
} else ok16 <- FALSE
check("O16", ok16,
      "run_meta: md5 + contract echo + P5 mapping + P2 INFO + sessionInfo + package stamp")

# ---- O17 completeness on diff / cell rows ---------------------------------------------------------
diff_all <- res[res$term == "diff", ]     # 10 coding diffs + 31 LOSO diffs
ok17 <- nrow(diff_all) == 41 &&
        !anyNA(diff_all$est_z) && !anyNA(diff_all$se_z) &&
        !anyNA(diff_all$ci_lb_z) && !anyNA(diff_all$ci_ub_z) &&
        nrow(cells) == 20 && !anyNA(cells$est_r)
check("O17", ok17,
      "no NA in est_z/se_z/CI on any diff row (41); no NA in est_r on cell rows (20)")

# ---- summary --------------------------------------------------------------------------------------
cat("\n============================================================\n")
cat(sprintf("T2 VERIFY: %d/%d PASS%s\n", length(results) - n_fail, length(results),
            if (n_fail) sprintf(" -- %d FAIL", n_fail) else ""))
cat("============================================================\n")
if (n_fail > 0L) quit(status = 1L)
