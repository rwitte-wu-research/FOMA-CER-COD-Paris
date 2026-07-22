# =============================================================================
# R/06_verify_outputs.R -- paired verifier for R/06_null_battery_a.R (TH-a).
# Checks O1-O17, numbered PASS/FAIL; exit status 1 on any FAIL.
# ORACLE INDEPENDENCE: this script does NOT source 06_null_battery_a.R.
# Constants below are intentionally duplicated. Ordering/counts/selection
# rules are recomputed from output/dat_prep.rds; anchors are re-read from
# the committed T1/T2 CSVs (F65 pattern). No model refits in the verifier.
# Convention: verifier = oracle for the Claude-Code run [Setup tab; A.7].
# =============================================================================

PATH_DAT_PREP <- here::here("output", "dat_prep.rds")
DIR_OUT   <- here::here("output")
RES_PATH  <- file.path(DIR_OUT, "TH_a_results.csv")
META_PATH <- file.path(DIR_OUT, "TH_a_run_meta.txt")
T1_PATH   <- file.path(DIR_OUT, "T1_results.csv")
T2_PATH   <- file.path(DIR_OUT, "T2_results.csv")

K_ES <- 2713L; K_STUDY <- 115L; K_CLUSTER <- 114L
K_SUB <- 2705L; K_SUB_ST <- 113L; K_SUB_CL <- 112L
K_NA <- 8L; K_NA_ST <- 2L; K_POST_ST <- 31L
N_ROWS <- 177L
TIE <- c(es = 79L, st = 5L, cl = 5L)
H4_YEARS <- 2008:2019; H4_DF_MIN <- 5
H8_STARTS <- seq(1998L, 2018L, by = 1L); H8_WIDTH <- 6L
H7_STEPS <- 113L; H7_FLOOR_K <- 10L
H10_KMIN <- 5L; H10_ALPHA <- 0.05
KNOT <- 2015.5
BAND_E1P <- atanh(0.070); BAND_E1S <- atanh(0.05); BAND_E2 <- 0.05

A_T1A1 <- c(est = -0.058646736610098,  se = 0.013856549617299,
            df = 111.671795029271,
            lb = -0.0861025946387978,  ub = -0.0311908785813981)
A_T2B1_DIFF <- c(est = 0.0101759067104026, se = 0.0181072824212575,
                 df = 14.9920663728925,    p  = 0.582435725630516)
COE_SL <- c(r = -0.039, lb = -0.046, ub = -0.032)

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

# ---- harness ----------------------------------------------------------------
results <- character(0); n_fail <- 0L
check <- function(id, ok, desc, detail = "") {
  detail <- paste(detail, collapse = " ")
  status <- if (isTRUE(ok)) "PASS" else "FAIL"
  if (!isTRUE(ok)) n_fail <<- n_fail + 1L
  line <- sprintf("%-4s %s -- %s%s", id, status, desc,
                  if (nzchar(detail)) paste0(" [", detail, "]") else "")
  results[[length(results) + 1L]] <<- line
  cat(line, "\n")
}
near <- function(a, b, tol) length(a) == length(b) &&
  all(is.finite(a) & is.finite(b)) && all(abs(a - b) <= tol)

# ---- O1 files exist; no TH figures ------------------------------------------
th_figs <- list.files(DIR_OUT, pattern = "TH.*\\.(pdf|png|svg|jpe?g)$",
                      recursive = TRUE, ignore.case = TRUE)
check("O1", file.exists(RES_PATH) && file.exists(META_PATH) &&
        length(th_figs) == 0,
      "TH_a_results.csv + TH_a_run_meta.txt exist; no TH figure files",
      if (length(th_figs)) paste("figures:", paste(th_figs, collapse = ", "))
      else "")
if (!file.exists(RES_PATH)) { cat("ABORT: results CSV missing.\n"); quit(status = 1L) }
res <- read.csv(RES_PATH, stringsAsFactors = FALSE)

# ---- O2 schema exact --------------------------------------------------------
check("O2", identical(names(res), SCHEMA),
      "CSV schema exact: 36 names + order (T2 schema)",
      paste(c(setdiff(SCHEMA, names(res)), setdiff(names(res), SCHEMA)),
            collapse = ", "))

# ---- dat_prep contract + recomputation base ---------------------------------
pr_ok <- FALSE
if (file.exists(PATH_DAT_PREP)) {
  pr <- readRDS(PATH_DAT_PREP)
  pr_ok <- is.list(pr) && !is.null(pr$dat) &&
    identical(as.integer(pr$n), K_ES) &&
    identical(as.integer(pr$seed), 20260710L) &&
    all(c("zi","vi","cluster_id","study","esid","sample_mid","pp_mid_lag0",
          "pp_window_class","d_sample_start","d_sample_end") %in% names(pr$dat)) &&
    nrow(pr$dat) == K_ES
}
if (pr_ok) {
  dd <- pr$dat
  pm <- as.integer(as.character(dd$pp_mid_lag0))
  st <- as.character(dd$study)
  ok_na <- sum(is.na(pm)) == K_NA &&
    length(unique(st[is.na(pm)])) == K_NA_ST
  sb <- dd[!is.na(pm), , drop = FALSE]
  pmS <- pm[!is.na(pm)]; stS <- st[!is.na(pm)]
  clS <- as.character(sb$cluster_id)
} else ok_na <- FALSE
check("O3", pr_ok && ok_na &&
        nrow(sb) == K_SUB && length(unique(stS)) == K_SUB_ST &&
        length(unique(clS)) == K_SUB_CL,
      "dat_prep contract: n/seed; NA structure 8/2; period domain 2705/113/112")

row_of <- function(aid, sp, tm, ss = NULL) {
  r <- res[res$analysis_id == aid & res$spec == sp & res$term == tm, , drop = FALSE]
  if (!is.null(ss)) r <- r[r$subset == ss, , drop = FALSE]
  r
}

# ---- O4 row inventory exact (177 keys) --------------------------------------
if (pr_ok) {
  med  <- tapply(sb$sample_mid, sb$study, stats::median)
  ordS <- names(med)[order(med, names(med), method = "radix")]
  exp_inv <- rbind(
    data.frame(a = "E1", s = "tost_pooled", ss = "defined",
               t = c("pooled_mean", "tost_band_0.070", "tost_band_0.050")),
    data.frame(a = "E2", s = "tost_paris", ss = "defined",
               t = c("cell_pre", "cell_post", "diff", "tost_band_0.050")),
    data.frame(a = "E3", s = "gate", ss = "defined",
               t = c("config_e2_requirement", "config_bf_ladder", "status")),
    data.frame(a = "H4", s = sprintf("break_%d", H4_YEARS), ss = "defined",
               t = "break"),
    data.frame(a = "H4", s = "sup_break", ss = "defined", t = "observed_sup"),
    data.frame(a = "H6", s = "zarea_transplant", ss = "defined",
               t = c("cell_pre", "cell_post", "diff")),
    data.frame(a = "H7", s = "cumulative", ss = ordS,
               t = sprintf("step_%03d", seq_len(H7_STEPS))),
    data.frame(a = "H8", s = "rolling",
               ss = sprintf("%d-%d", H8_STARTS, H8_STARTS + H8_WIDTH - 1L),
               t = "window_mean"),
    data.frame(a = "H9", s = "external_size", ss = "defined",
               t = c("own_pooled", "coe_study_level")),
    data.frame(a = "H10", s = "pcurve", ss = "defined",
               t = c("count_significant", "right_skew_binomial",
                     "right_skew_stouffer", "flatness_vs_33")),
    data.frame(a = "H11", s = "within_study", ss = "Li et al (2022)",
               t = c("pre_mean", "post_mean", "within_diff")),
    data.frame(a = "TH_design", s = "design", ss = "defined",
               t = c("h6_tie_inventory", "h4_admissible_years",
                     "h7_floor_step", "h7_order_head", "h8_window_anchor",
                     "h10_selection_rule", "h11_straddle_studies",
                     "h11_pool_across")))
  got <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "::")
  exp <- paste(exp_inv$a, exp_inv$s, exp_inv$ss, exp_inv$t, sep = "::")
  check("O4", nrow(res) == N_ROWS && length(exp) == N_ROWS &&
          identical(sort(got), sort(exp)) && !anyDuplicated(got),
        sprintf("row inventory exact: %d keys incl. the 113 recomputed H7 (subset = added study, ordered) [DEC-045]", N_ROWS),
        paste(utils::head(c(setdiff(exp, got), setdiff(got, exp)), 4),
              collapse = " ; "))
} else check("O4", FALSE, "row inventory (dat_prep unavailable)")

# ---- O5 E1 anchors: committed T1 + refit identity ----------------------------
ok5 <- FALSE
if (file.exists(T1_PATH)) {
  t1 <- read.csv(T1_PATH, stringsAsFactors = FALSE)
  rA1 <- t1[t1$analysis_id == "A1" & t1$spec == "headline", , drop = FALSE]
  e1 <- row_of("E1", "tost_pooled", "pooled_mean")
  ok5 <- nrow(rA1) == 1 && nrow(e1) == 1 &&
    near(c(rA1$est_z, rA1$se_z, rA1$df, rA1$ci_lb_z, rA1$ci_ub_z),
         unname(A_T1A1), 1e-9) &&
    near(c(e1$est_z, e1$se_z, e1$df, e1$ci_lb_z, e1$ci_ub_z),
         unname(A_T1A1), 1e-6) &&
    e1$k_es == K_ES && e1$k_study == K_STUDY && e1$k_cluster == K_CLUSTER
}
check("O5", ok5,
      "E1: committed T1/A1 matches embedded constants (1e-9); TH-a refit row matches at 1e-6 [F65]")

# ---- O6 E2 anchors ----------------------------------------------------------
ok6 <- FALSE
if (file.exists(T2_PATH)) {
  t2 <- read.csv(T2_PATH, stringsAsFactors = FALSE)
  rB1d <- t2[t2$analysis_id == "B1" & t2$spec == "paris_mid" &
               t2$term == "diff", , drop = FALSE]
  e2 <- row_of("E2", "tost_paris", "diff")
  ok6 <- nrow(rB1d) == 1 && nrow(e2) == 1 &&
    near(c(rB1d$est_z, rB1d$se_z, rB1d$df, rB1d$p),
         unname(A_T2B1_DIFF), 1e-9) &&
    near(c(e2$est_z, e2$se_z, e2$df, e2$p), unname(A_T2B1_DIFF), 1e-6) &&
    e2$k_es == K_SUB
}
check("O6", ok6,
      "E2: committed T2/B1 diff matches embedded constants (1e-9); TH-a refit diff matches at 1e-6 [F65]")

# ---- O7 TOST arithmetic recomputed ------------------------------------------
tost_ok <- function(r, band) {
  if (nrow(r) != 1 || !is.finite(r$est_z) || !is.finite(r$se_z) ||
      !is.finite(r$df)) return(FALSE)
  p_low <- 1 - stats::pt((r$est_z + band) / r$se_z, df = r$df)
  p_up  <- stats::pt((r$est_z - band) / r$se_z, df = r$df)
  q90 <- stats::qt(0.95, df = r$df)
  lb <- r$est_z - q90 * r$se_z; ub <- r$est_z + q90 * r$se_z
  pass <- (lb > -band) && (ub < band)
  near(r$p, max(p_low, p_up), 1e-10) &&
    near(c(r$ci_lb_z, r$ci_ub_z), c(lb, ub), 1e-10) &&
    identical(as.numeric(pass), as.numeric(r$value)) &&
    identical(pass, r$p < 0.05)
}
check("O7",
      tost_ok(row_of("E1", "tost_pooled", "tost_band_0.070"), BAND_E1P) &&
      tost_ok(row_of("E1", "tost_pooled", "tost_band_0.050"), BAND_E1S) &&
      tost_ok(row_of("E2", "tost_paris",  "tost_band_0.050"), BAND_E2),
      "TOST arithmetic recomputed from est/se/df: arm p's, max rule, 90% CI, pass flag == (p < .05), all three rows (1e-10)")

# ---- O8 H4: df fields, admissible set, sup identity --------------------------
h4 <- res[res$analysis_id == "H4" & res$term == "break", , drop = FALSE]
supr <- row_of("H4", "sup_break", "observed_sup")
admr <- row_of("TH_design", "design", "h4_admissible_years")
ok8 <- nrow(h4) == length(H4_YEARS) && all(is.finite(h4$df)) &&
  all(is.finite(h4$t_stat)) && nrow(supr) == 1 && nrow(admr) == 1
if (ok8) {
  adm_idx <- h4$df >= H4_DF_MIN
  ok8 <- admr$value == sum(adm_idx) &&
    near(supr$value, max(abs(h4$t_stat[adm_idx])), 1e-10)
  yrs <- sub("break_", "", h4$spec[adm_idx])
  ok8 <- ok8 && all(vapply(yrs, function(y)
    grepl(y, admr$note, fixed = TRUE), logical(1)))
}
check("O8", ok8,
      sprintf("H4: 12 break rows finite; admissible set (df >= %d) count + membership match design row; sup == max|t| over admissible (1e-10)", H4_DF_MIN))

# ---- O9 H6 tie recomputation + domain identities ----------------------------
if (pr_ok) {
  tie <- sb$sample_mid == KNOT
  d6 <- row_of("H6", "zarea_transplant", "diff")
  c6p <- row_of("H6", "zarea_transplant", "cell_pre")
  c6q <- row_of("H6", "zarea_transplant", "cell_post")
  ok9 <- sum(tie) == TIE["es"] &&
    length(unique(stS[tie])) == TIE["st"] &&
    length(unique(clS[tie])) == TIE["cl"] &&
    nrow(d6) == 1 && d6$k_es == K_SUB - TIE["es"] &&
    d6$k_cluster == K_SUB_CL - TIE["cl"] &&
    c6p$k_es + c6q$k_es == d6$k_es &&
    c6q$k_study == K_POST_ST - TIE["st"] &&
    near(c6q$est_z - c6p$est_z, d6$est_z, 1e-10) &&
    grepl("midpoint + tie-exclusion", d6$note, fixed = TRUE) &&
    grepl("within our 3L-RVE framework", d6$note, fixed = TRUE)
  check("O9", ok9,
        "H6: tie inventory 79/5/5 recomputed; domain 2626/108/107; post 26 studies; diff == post - pre (1e-10); wording pin present")
} else check("O9", FALSE, "H6 (dat_prep unavailable)")

# ---- O10 H7 ordering, cumulation, floor -------------------------------------
if (pr_ok) {
  h7 <- res[res$analysis_id == "H7", , drop = FALSE]
  h7 <- h7[order(h7$term), , drop = FALSE]
  cum_es <- vapply(seq_len(H7_STEPS), function(s)
    sum(stS %in% ordS[seq_len(s)]), integer(1))
  cum_cl <- vapply(seq_len(H7_STEPS), function(s)
    length(unique(clS[stS %in% ordS[seq_len(s)]])), integer(1))
  flr <- row_of("TH_design", "design", "h7_floor_step")
  exp_floor <- which(cum_cl >= H7_FLOOR_K)[1]
  ne <- grepl("not_estimable", h7$note)
  est_ok <- !anyNA(h7$est_z[!ne]) && !anyNA(h7$ci_lb_z[!ne]) &&
    all(is.na(h7$est_z[ne]))
  idx_pre  <- setdiff(seq_len(exp_floor - 1L), which(ne))
  idx_post <- setdiff(exp_floor:H7_STEPS, which(ne))
  flag_ok <- all(grepl("point-only", h7$note[idx_pre])) &&
    !any(grepl("point-only", h7$note[idx_post]))
  ok10 <- nrow(h7) == H7_STEPS &&
    identical(h7$subset, ordS) &&
    identical(h7$k_es, cum_es) &&
    identical(h7$k_cluster, cum_cl) &&
    identical(h7$k_study, seq_len(H7_STEPS)) &&
    h7$k_es[H7_STEPS] == K_SUB &&
    est_ok && nrow(flr) == 1 && flr$value == exp_floor && flag_ok
  check("O10", ok10,
        sprintf("H7: 113 rows; subset order == recomputed (median, ties alpha); cumulated k_es/k_cluster identical; final = 2705; floor step = %d; flags consistent; not_estimable steps exempt (NA est + note tag)", exp_floor),
        sprintf("not_estimable steps: %d", sum(ne)))
} else check("O10", FALSE, "H7 (dat_prep unavailable)")

# ---- O11 H8 windows: bounds, tiers, recomputed cluster counts ----------------
if (pr_ok) {
  ok11 <- TRUE; det11 <- ""
  for (s0 in H8_STARTS) {
    lab <- sprintf("%d-%d", s0, s0 + H8_WIDTH - 1L)
    w <- sb$sample_mid >= s0 & sb$sample_mid < s0 + H8_WIDTH
    kC <- length(unique(clS[w]))
    r <- row_of("H8", "rolling", "window_mean", ss = lab)
    if (nrow(r) != 1 || r$k_cluster != kC || r$k_es != sum(w)) {
      ok11 <- FALSE; det11 <- paste0(det11, lab, " "); next }
    if (kC < 5L)      { if (!is.na(r$est_z) || !grepl("not_estimable", r$note))
                          { ok11 <- FALSE; det11 <- paste0(det11, lab, " ") } }
    else if (kC < 10L){ if (is.na(r$est_z) || !is.na(r$se_z) || !is.na(r$p) ||
                            !is.na(r$ci_lb_z) || !grepl("descriptive tier", r$note))
                          { ok11 <- FALSE; det11 <- paste0(det11, lab, " ") } }
    else              { if (anyNA(c(r$est_z, r$se_z, r$df, r$p, r$ci_lb_z,
                                    r$ci_ub_z)))
                          { ok11 <- FALSE; det11 <- paste0(det11, lab, " ") } }
  }
  check("O11", ok11,
        "H8: 21 windows; k recomputed from dat_prep; tier structure (<5 not_estimable / 5-9 est-only / >=10 full) enforced", det11)
} else check("O11", FALSE, "H8 (dat_prep unavailable)")

# ---- O12 H9 constants echo ---------------------------------------------------
r9a <- row_of("H9", "external_size", "own_pooled")
r9b <- row_of("H9", "external_size", "coe_study_level")
check("O12",
      nrow(r9a) == 1 && nrow(r9b) == 1 &&
        near(r9a$est_r, tanh(A_T1A1["est"]), 1e-6) &&
        near(c(r9b$est_r, r9b$ci_lb_r, r9b$ci_ub_r), unname(COE_SL), 1e-12) &&
        is.na(r9b$est_z) && grepl("Table 3", r9b$note) &&
        grepl("no cluster-robust inference", r9b$note) &&
        grepl("7/120", r9b$note) && grepl("5/113", r9b$note) &&
        grepl("0 shared", r9b$note),
      "H9: own pooled r == tanh(T1/A1); COE study-level constants + SE-provenance + three-tier overlap + zero-shared-ES disclosures present")

# ---- O13 H10 selection + arithmetic recomputed -------------------------------
if (pr_ok) {
  pf <- sb[pmS == 1L, , drop = FALSE]
  pf <- pf[!duplicated(as.character(pf$study)), , drop = FALSE]
  z_i <- abs(pf$zi) / sqrt(pf$vi)
  p_i <- 2 * stats::pnorm(-z_i)
  k_sig <- sum(p_i < H10_ALPHA)
  rc <- row_of("H10", "pcurve", "count_significant")
  tests <- res[res$analysis_id == "H10" & res$term != "count_significant", ]
  ok13 <- nrow(rc) == 1 && rc$value == k_sig && nrow(pf) == K_POST_ST &&
    nrow(tests) == 3
  if (ok13) {
    if (k_sig >= H10_KMIN) {
      ok13 <- !anyNA(tests$value) && all(tests$value >= 0 & tests$value <= 1)
      ps <- p_i[p_i < H10_ALPHA]
      pp <- pmin(pmax(ps / H10_ALPHA, 1e-12), 1 - 1e-12)
      z_rs <- sum(stats::qnorm(pp)) / sqrt(k_sig)
      rrs <- row_of("H10", "pcurve", "right_skew_stouffer")
      ok13 <- ok13 && near(rrs$value, stats::pnorm(z_rs), 1e-10)
    } else {
      ok13 <- all(is.na(tests$value)) &&
        all(grepl("not_estimable", tests$note)) &&
        all(grepl("infeasible", tests$note))
    }
  }
  NCP <- stats::qnorm(0.975) - stats::qnorm(2/3)   # independent recompute
  rfl <- row_of("H10", "pcurve", "flatness_vs_33")
  mm <- regmatches(rfl$note, regexpr("NCP_33 = [0-9]+\\.[0-9]+", rfl$note))
  ok13 <- ok13 && nrow(rfl) == 1 && length(mm) == 1 &&
    near(as.numeric(sub("NCP_33 = ", "", mm)), NCP, 1e-9)
  if (k_sig >= H10_KMIN && ok13) {
    zs_sig <- z_i[p_i < H10_ALPHA]
    pp33v <- pmin(pmax((1 - stats::pnorm(zs_sig - NCP)) / (1/3), 1e-12),
                  1 - 1e-12)
    z33v <- sum(stats::qnorm(pp33v)) / sqrt(k_sig)
    ok13 <- near(rfl$value, 1 - stats::pnorm(z33v), 1e-10) &&
      grepl("clip share", rfl$note)
  }
  check("O13", ok13,
        sprintf("H10: first-reported selection recomputed (31 post studies); k_sig = %d; branch rows consistent; NCP_33 recomputed independently (1e-9, note parse) + flatness Stouffer identity (1e-10) when feasible", k_sig))
} else check("O13", FALSE, "H10 (dat_prep unavailable)")

# ---- O14 H11 recomputation ---------------------------------------------------
if (pr_ok) {
  li <- sb[as.character(sb$study) == "Li et al (2022)", , drop = FALSE]
  lp <- li$zi[li$pp_mid_lag0 == 0]; lq <- li$zi[li$pp_mid_lag0 == 1]
  both <- sum(tapply(pmS, stS, function(x) min(x) == 0 && max(x) == 1))
  wc <- as.character(dd$pp_window_class)
  straddle <- sum(tapply(wc, st, function(x) any(x == "mixed", na.rm = TRUE)))
  rpre <- row_of("H11", "within_study", "pre_mean", ss = "Li et al (2022)")
  rpost <- row_of("H11", "within_study", "post_mean", ss = "Li et al (2022)")
  rdif <- row_of("H11", "within_study", "within_diff", ss = "Li et al (2022)")
  rstr <- row_of("TH_design", "design", "h11_straddle_studies")
  rpool <- row_of("TH_design", "design", "h11_pool_across")
  ok14 <- length(lp) == 12L && length(lq) == 5L && both == 1L &&
    near(rpre$est_z, mean(lp), 1e-10) && near(rpre$value, stats::sd(lp), 1e-10) &&
    near(rpost$est_z, mean(lq), 1e-10) &&
    near(rdif$est_z, mean(lq) - mean(lp), 1e-10) &&
    is.na(rdif$p) && is.na(rdif$ci_lb_z) &&
    rstr$value == straddle && rpool$value == straddle - 1L &&
    straddle == 73L
  check("O14", ok14,
        "H11: Li et al (2022) 12/5 recomputed; means/SD/diff at 1e-10; no p/CI on diff; straddle 73, pool-across 72")
} else check("O14", FALSE, "H11 (dat_prep unavailable)")

# ---- O15 CI containment + tanh identity on level rows ------------------------
zr <- res[!is.na(res$est_z) & !is.na(res$ci_lb_z) & !is.na(res$ci_ub_z), ]
lvl <- res[res$term %in% c("cell_pre", "cell_post", "pooled_mean",
                           "window_mean", "pre_mean", "post_mean") |
             res$analysis_id == "H7", ]
lvl <- lvl[!is.na(lvl$est_r) & !is.na(lvl$est_z), ]
check("O15",
      all(zr$ci_lb_z < zr$est_z & zr$est_z < zr$ci_ub_z) &&
        near(lvl$est_r, tanh(lvl$est_z), 1e-10),
      "est strictly inside CI wherever both present; r == tanh(z) on all level rows (1e-10)")

# ---- O16 run_meta contents ---------------------------------------------------
ok16 <- FALSE
if (file.exists(META_PATH)) {
  meta <- readLines(META_PATH, warn = FALSE)
  ok16 <- any(grepl("md5", meta)) && any(grepl("2713", meta)) &&
    any(grepl("20260710", meta)) &&
    any(grepl("anchor gates PASSED", meta)) &&
    any(grepl("TOST bands", meta)) &&
    any(grepl("admissible years", meta, ignore.case = TRUE)) &&
    any(grepl("floor step", meta)) &&
    any(grepl("sessionInfo", meta)) && any(grepl("metafor", meta)) &&
    any(grepl("clubSandwich", meta)) &&
    any(grepl("Convergence certificates", meta)) &&
    any(grepl("NCP_33", meta)) && any(grepl("ladder rung", meta))
}
check("O16",
      ok16,
      "run_meta: md5 + contract echo + anchor gates + TOST bands + H4 set + H7 floor + certificates + sessionInfo")

# ---- O17 absence checks + E3 framing neutrality ------------------------------
e3 <- res[res$analysis_id == "E3", ]
check("O17",
      !any(grepl("^bp_", res$term)) &&
        !any(res$spec %in% c("race", "break_only", "trend_only")) &&
        nrow(e3) == 3 && all(is.na(e3$est_z)) &&
        any(grepl("deferred", e3$note)) &&
        !any(grepl("evidence of absence confirmed", res$note, ignore.case = TRUE)),
      "absence: no bp_ rows [P-T5-5]; no duplicated T8 race/break/trend keys [single-home 4a]; E3 = 3 config rows, estimate-free, resolution deferred (framing-neutral)")

# ---- summary ----------------------------------------------------------------
cat("\n============================================================\n")
cat(sprintf("TH-a VERIFY: %d/%d PASS%s\n", length(results) - n_fail,
            length(results),
            if (n_fail) sprintf(" -- %d FAIL", n_fail) else ""))
cat("============================================================\n")
if (n_fail > 0L) quit(status = 1L)
