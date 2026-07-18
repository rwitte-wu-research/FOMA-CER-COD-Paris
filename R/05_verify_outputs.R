# =====================================================================
# R/05_verify_outputs.R — paired verifier for T5 (Block D: D1/D2/D4/D5)
# FOMA CER–COD–Paris | numbered checks O1–O27 with PASS/FAIL and
# non-zero exit on any FAIL [analysis_plan A.7].
# ---------------------------------------------------------------------
# Disclosed deviations from the committed T8 verifier pattern
# (R/08_verify_outputs.R, data-only):
#   (i)  O13/O14 RE-FIT the T1/A5 one-per-cluster anchor via the
#        independently pinned call (metafor aggregate.escalc,
#        struct = "CS", rho = 0.6 -> rma.uni REML, test = "knha") and
#        check it against the committed output/T1_results.csv — mandated
#        by DEC-031g/F65 (author ruling 2026-07-18). The anchor row is
#        located BY VALUE (full-precision frozen constants, 1e-9),
#        uniqueness asserted; this doubles as the CSV-drift canary.
#   (ii) O11 reads data/CER-COD_data_v12.xlsx (readxl) to assert the
#        corpus-level q_VHB / q_status study counts on RAW rows —
#        mandated by DEC-031g amendment (1).
# Pins: DEC-042a/b domains · DEC-031g (q_status cells, direction pins,
# P-T5-1 rule, P-T5-4 signatures, F65 anchor) · DEC-031f (ladder
# certificates, R6) · DEC-031a.4/5 · plan A.11/A.12.
# =====================================================================

suppressPackageStartupMessages({
  library(here); library(readr); library(metafor); library(readxl)
})

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")
N_ROWS <- 53L                     # 9 design + 15 PET/PEESE/rule + 25 selection + 4 D5
N_SET <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L
N_PRE <- 1994L; N_PRE_ST <- 83L
N_POST <- 711L; N_POST_ST <- 31L; N_POST_CL <- 31L
K_NA_ES <- 8L; K_NA_ST <- 2L
K_AGG_FULL <- 114L
DAT_PREP_MD5 <- "6702ef3dc45fe0b693b13f50ebd1576b"
RHO <- 0.6; ALPHA_RULE <- 0.05
QS_LEVELS <- c("0_published", "1_not published")
QS_PIN <- data.frame(level = QS_LEVELS, es = c(2033L, 680L),
                     st = c(101L, 14L), cl = c(100L, 14L))
# v12 raw/usable study-count asserts [DEC-031g amendment (1); labels verbatim]
VHB_RAW    <- c("1_VHB high" = 76L, "0_VHB low" = 30L, "99_NCE" = 14L)
VHB_USABLE <- c("1_VHB high" = 74L, "0_VHB low" = 29L, "99_NCE" = 14L)
QS_RAW     <- c("0_published" = 106L, "1_not published" = 14L)
QS_USABLE  <- c("0_published" = 103L, "1_not published" = 14L)
# T1/A5 one-per-cluster anchor, FULL PRECISION [DEC-031g/F65; committed
# output/T1_results.csv, programmatically extracted 2026-07-18]
A5_EST <- -0.0616608386540629
A5_SE  <-  0.0243306602731784
A5_DF  <-  113
A5_P   <-  0.0126367644358383
A5_LB  <- -0.109864264918875
A5_UB  <- -0.0134574123892513
A5_ROUND3 <- -0.062               # battery-logged display rounding
TOL_CAN <- 1e-9                   # CSV-drift canary (frozen vs runtime-read)
TOL_FIT <- 1e-6                   # re-fit identity [DEC-031f R4 tier]
NONCONV_SIG <- c("converg", "opposite sign")   # [P-T5-4] pinned

fails <- 0L; n_ok <- 0L
chk <- function(id, desc, cond) {
  cond <- isTRUE(cond)
  cat(sprintf("%-4s %s — %s\n", id, if (cond) "PASS" else "FAIL", desc))
  if (cond) n_ok <<- n_ok + 1L else fails <<- fails + 1L
  invisible(cond)
}
getv <- function(res, aid, spc, trm, col) {
  r <- res[res$analysis_id == aid & res$spec == spc & res$term == trm, col]
  if (nrow(r) == 1) r[[1]] else NA
}
grepv <- function(pat, x, fixed = FALSE) !is.na(x) && grepl(pat, x, fixed = fixed)

# ---- O1–O6: file, schema, row plan, key plan ----------------------------
f_res <- here("output", "T5_results.csv")
chk("O1", "output/T5_results.csv exists", file.exists(f_res))
if (!file.exists(f_res)) { cat("ABORT: no results file.\n"); quit(status = 1) }
res <- read_csv(f_res, show_col_types = FALSE, na = c("", "NA"))
chk("O2", "36 columns, names identical to T2 schema (verbatim, in order)",
    identical(names(res), SCHEMA))
chk("O3", sprintf("row count == %d (derived budget)", N_ROWS),
    nrow(res) == N_ROWS)
key <- paste(res$analysis_id, res$spec, res$term, sep = "||")
chk("O4", "no duplicate (analysis_id, spec, term) keys", !anyDuplicated(key))

sel_terms <- c("mu_unadjusted_ML", "tau2_unadjusted", "mu_3psm", "tau2_3psm",
               "delta_3psm", "lrt_3psm", "mu_punistar", "tau2_punistar")
planned <- c(
  paste("T5_design", "design",
        c("subset_estimation", "period_pre", "period_post", "period_na",
          "agg_k_full", "agg_k_pre", "agg_k_post",
          "qs_cell_published", "qs_cell_not_published"), sep = "||"),
  paste("D1", "pet",   c("intercept", "sez"),    sep = "||"),
  paste("D1", "peese", c("intercept", "sez_sq"), sep = "||"),
  "D1||rule||pet_peese_rule",
  paste("D4", "pet_pre",    c("intercept", "sez"),    sep = "||"),
  paste("D4", "peese_pre",  c("intercept", "sez_sq"), sep = "||"),
  "D4||rule_pre||pet_peese_rule",
  paste("D4", "pet_post",   c("intercept", "sez"),    sep = "||"),
  paste("D4", "peese_post", c("intercept", "sez_sq"), sep = "||"),
  "D4||rule_post||pet_peese_rule",
  paste("D2", "selection_full", c(sel_terms, "mu_anchor_reml_knha"), sep = "||"),
  paste("D4", "selection_pre",  sel_terms, sep = "||"),
  paste("D4", "selection_post", sel_terms, sep = "||"),
  paste("D5", "grey_panel",
        c("cell_published", "cell_not_published", "contrast_np_minus_p",
          "wald_between_groups"), sep = "||"))
chk("O5", "key set == the 53 planned keys (setequal; failures must surface as not_estimable values, never as missing rows)",
    setequal(key, planned))
if (!setequal(key, planned)) {
  cat("  missing:", paste(setdiff(planned, key), collapse = "; "), "\n")
  cat("  extra:  ", paste(setdiff(key, planned), collapse = "; "), "\n")
}
chk("O6", "analysis_id set == {T5_design, D1, D2, D4, D5}",
    setequal(unique(res$analysis_id), c("T5_design","D1","D2","D4","D5")))

# ---- O7: vocabulary invariants ------------------------------------------
est_vocab <- c("3LMA-RVE_CR2", "descriptive", "rule", "RE_ML_cluster_agg",
               "selmodel_3PSM_ML", "puni_star_ML", "RE_REML_knha_cluster_agg")
met_vocab <- c("Fisher_z", "F_test", "count", "tau2", "delta", "LRT_test",
               "flag")
sub_vocab <- c("full", "defined_pre", "defined_post")
sub_ok <- all(res$subset %in% sub_vocab) &&
  all(res$subset[res$spec %in% c("pet_pre","peese_pre","rule_pre",
                                 "selection_pre")] == "defined_pre") &&
  all(res$subset[res$spec %in% c("pet_post","peese_post","rule_post",
                                 "selection_post")] == "defined_post") &&
  all(res$subset[res$analysis_id %in% c("T5_design","D1","D2","D5")] == "full")
rho_rows <- !(res$estimator %in% c("descriptive", "rule"))
chk("O7", "vocabularies closed (estimator/metric/subset); subset matches domain; rho = 0.6 on model rows, NA on descriptive/rule",
    all(res$estimator %in% est_vocab) && all(res$metric %in% met_vocab) &&
    sub_ok && all(res$rho[rho_rows] == RHO) && all(is.na(res$rho[!rho_rows])))

# ---- O8–O10: dat_prep recomputation (design identities) -----------------
chk("O8", sprintf("dat_prep.rds md5 == pin %s", DAT_PREP_MD5),
    identical(unname(tools::md5sum(here("output", "dat_prep.rds"))),
              DAT_PREP_MD5))
pr <- readRDS(here("output", "dat_prep.rds"))
d  <- pr$dat
na_win <- is.na(d$pp_mid_lag0)
pre  <- d[!na_win & d$pp_mid_lag0 == 0, , drop = FALSE]
post <- d[!na_win & d$pp_mid_lag0 == 1, , drop = FALSE]
K_AGG_PRE_D <- length(unique(pre$cluster_id))
dom_ok <- pr$n == N_SET && nrow(d) == N_SET &&
  length(unique(d$study)) == N_SET_ST &&
  length(unique(d$cluster_id)) == N_SET_CL &&
  sum(na_win) == K_NA_ES && length(unique(d$study[na_win])) == K_NA_ST &&
  nrow(pre) == N_PRE && length(unique(pre$study)) == N_PRE_ST &&
  nrow(post) == N_POST && length(unique(post$study)) == N_POST_ST &&
  length(unique(post$cluster_id)) == N_POST_CL
spine_full <- res$subset == "full" & rho_rows
spine_pre  <- res$subset == "defined_pre"  & rho_rows
spine_post <- res$subset == "defined_post" & rho_rows
kcol_ok <- all(res$k_es[spine_full] == N_SET) &&
  all(res$k_study[spine_full] == N_SET_ST) &&
  all(res$k_es[spine_pre] == N_PRE) &&
  all(res$k_study[spine_pre] == N_PRE_ST) &&
  all(res$k_cluster[spine_pre] == K_AGG_PRE_D) &&
  all(res$k_es[spine_post] == N_POST) &&
  all(res$k_study[spine_post] == N_POST_ST) &&
  all(res$k_cluster[spine_post] == N_POST_CL) &&
  all(res$k_cluster[res$analysis_id %in% c("D1","D5") & rho_rows] == N_SET_CL) &&
  getv(res,"D2","selection_full","mu_3psm","k_cluster") == K_AGG_FULL
chk("O9", "domains recomputed from dat_prep == pins (2713/115/114; pre 1994/83; post 711/31/31; NA 8/2); k columns match row domains; pre clusters consistent",
    dom_ok && kcol_ok &&
    getv(res,"T5_design","design","agg_k_pre","value")  == K_AGG_PRE_D &&
    getv(res,"T5_design","design","agg_k_post","value") == N_POST_CL &&
    getv(res,"T5_design","design","agg_k_full","value") == K_AGG_FULL &&
    getv(res,"T5_design","design","subset_estimation","value") == N_SET &&
    getv(res,"T5_design","design","period_pre","value")  == N_PRE &&
    getv(res,"T5_design","design","period_post","value") == N_POST &&
    getv(res,"T5_design","design","period_na","value")   == K_NA_ES)
qs_ok <- !anyNA(d$q_status) && setequal(unique(d$q_status), QS_LEVELS)
for (i in seq_len(nrow(QS_PIN))) {
  m <- d$q_status == QS_PIN$level[i]
  qs_ok <- qs_ok && sum(m) == QS_PIN$es[i] &&
    length(unique(d$study[m]))      == QS_PIN$st[i] &&
    length(unique(d$cluster_id[m])) == QS_PIN$cl[i]
}
chk("O10", "q_status estimation cells recomputed == DEC-031g pins (2033/101/100; 680/14/14) == CSV design rows",
    qs_ok &&
    getv(res,"T5_design","design","qs_cell_published","value") == QS_PIN$es[1] &&
    getv(res,"T5_design","design","qs_cell_not_published","value") == QS_PIN$es[2])

# ---- O11: v12 RAW + usable corpus asserts [DEC-031g amendment (1)] ------
f_v12 <- here("data", "CER-COD_data_v12.xlsx")
o11 <- FALSE
if (file.exists(f_v12)) {
  v12 <- readxl::read_excel(f_v12, sheet = "data",
                            col_types = "text", .name_repair = "minimal")
  v12 <- v12[, c("study", "q_status", "q_VHB", "d_es_usable")]
  cnt <- function(dd, col, tab) {
    obs <- tapply(dd$study, dd[[col]], function(s) length(unique(s)))
    all(names(tab) %in% names(obs)) &&
      all(vapply(names(tab),
                 function(k) isTRUE(obs[[k]] == tab[[k]]), logical(1))) &&
      length(obs) == length(tab)
  }
  us <- v12[v12$d_es_usable == "1", , drop = FALSE]
  o11 <- cnt(v12, "q_VHB", VHB_RAW)   && cnt(v12, "q_status", QS_RAW) &&
         cnt(us,  "q_VHB", VHB_USABLE) && cnt(us,  "q_status", QS_USABLE)
}
chk("O11", "v12 raw rows: q_VHB studies 76/30/14, q_status 106/14; usable: 74/29/14, 103/14 (labels verbatim)", o11)

# ---- O12: sez provenance ------------------------------------------------
f_meta <- here("output", "T5_run_meta.txt")
mt <- if (file.exists(f_meta)) readLines(f_meta, warn = FALSE) else character(0)
chk("O12", "vi > 0 and finite in dat_prep; run_meta discloses sez = sqrt(vi) provenance (raw SE column never read)",
    all(is.finite(d$vi)) && all(d$vi > 0) &&
    any(grepl("sez = sqrt(vi)", mt, fixed = TRUE)) &&
    any(grepl("never read", mt, fixed = TRUE)))

# ---- O13–O15: T1/A5 anchor [DEC-031g/F65] -------------------------------
f_t1 <- here("output", "T1_results.csv")
o13 <- FALSE; t1row <- NULL
if (file.exists(f_t1)) {
  t1 <- read_csv(f_t1, show_col_types = FALSE, na = c("", "NA"))
  if ("est_z" %in% names(t1)) {
    hit <- which(!is.na(t1$est_z) & abs(t1$est_z - A5_EST) <= TOL_CAN)
    if (length(hit) == 1) {
      t1row <- t1[hit, ]
      cat(sprintf("  [O13] anchor row located by value in T1_results.csv: %s\n",
                  paste(unlist(t1row[intersect(c("analysis_id","spec","term"),
                                               names(t1))]), collapse = " || ")))
      o13 <- abs(t1row$se_z    - A5_SE) <= TOL_CAN &&
             t1row$df == A5_DF &&
             abs(t1row$p       - A5_P)  <= TOL_CAN &&
             abs(t1row$ci_lb_z - A5_LB) <= TOL_CAN &&
             abs(t1row$ci_ub_z - A5_UB) <= TOL_CAN &&
             abs(round(t1row$est_z, 3) - A5_ROUND3) < 1e-12
    } else {
      cat(sprintf("  [O13] value-match rows found: %d (expected exactly 1)\n",
                  length(hit)))
    }
  }
}
chk("O13", "T1/A5 anchor: unique value-located row in committed T1_results.csv; est/se/p/ci within 1e-9 of frozen constants, df == 113 exact; rounding canary -0.062 (CSV-drift check)",
    o13)

X    <- data.frame(yi = d$zi, vi = d$vi, cluster_id = d$cluster_id)
datE <- metafor::escalc(measure = "GEN", yi = yi, vi = vi, data = X)
agg  <- aggregate(datE, cluster = cluster_id, struct = "CS", rho = RHO)
mA   <- rma(yi = yi, vi = vi, data = agg, method = "REML", test = "knha")
refit_ok <- nrow(agg) == K_AGG_FULL &&
  abs(as.numeric(mA$beta)[1] - A5_EST) <= TOL_FIT &&
  abs(mA$se[1] - A5_SE) <= TOL_FIT &&
  (mA$k - mA$p) == A5_DF &&
  abs(mA$pval[1] - A5_P) <= TOL_FIT
chk("O14", "anchor RE-FIT (independently pinned call: aggregate.escalc struct=\"CS\" rho=0.6 -> rma.uni REML knha): k == 114; est/se/p within 1e-6 of frozen; df == 113",
    refit_ok)
a_est <- getv(res,"D2","selection_full","mu_anchor_reml_knha","est_z")
a_se  <- getv(res,"D2","selection_full","mu_anchor_reml_knha","se_z")
a_df  <- getv(res,"D2","selection_full","mu_anchor_reml_knha","df")
chk("O15", "T5 CSV anchor row == re-fit (1e-6) and df == 113 (transitively == T1/A5)",
    is.finite(a_est) && abs(a_est - as.numeric(mA$beta)[1]) <= TOL_FIT &&
    abs(a_se - mA$se[1]) <= TOL_FIT && a_df == A5_DF)

# ---- O16–O17: direction pins + rule flags -------------------------------
psm_specs <- rbind(c("D2","selection_full"), c("D4","selection_pre"),
                   c("D4","selection_post"))
dir_ok <- TRUE
for (i in seq_len(nrow(psm_specs))) {
  n3 <- getv(res, psm_specs[i,1], psm_specs[i,2], "mu_3psm", "note")
  np <- getv(res, psm_specs[i,1], psm_specs[i,2], "mu_punistar", "note")
  dir_ok <- dir_ok && grepv('alternative="less"', n3, fixed = TRUE) &&
    grepv('side="left"', np, fixed = TRUE)
}
chk("O16", "direction pins on all selection rows: selmodel alternative=\"less\"; puni_star side=\"left\"; run_meta line present",
    dir_ok && any(grepl('alternative="less"', mt, fixed = TRUE)) &&
    any(grepl('side="left"', mt, fixed = TRUE)))
rule_ok <- TRUE
rule_map <- rbind(c("D1","pet","rule"), c("D4","pet_pre","rule_pre"),
                  c("D4","pet_post","rule_post"))
for (i in seq_len(nrow(rule_map))) {
  p_int <- getv(res, rule_map[i,1], rule_map[i,2], "intercept", "p")
  flg   <- getv(res, rule_map[i,1], rule_map[i,3], "pet_peese_rule", "value")
  rule_ok <- rule_ok && flg %in% c(0, 1) &&
    isTRUE(flg == as.numeric(is.finite(p_int) && p_int < ALPHA_RULE))
}
chk("O17", "PET->PEESE rule flags consistent: value == 1{PET intercept p < .05} in every domain, identical rule [P-T5-1]",
    rule_ok)

# ---- O18–O19: ladder certificates + R6 ----------------------------------
pp_tags <- c("D1_pet","D1_peese","D4_pet_pre","D4_peese_pre",
             "D4_pet_post","D4_peese_post")
cert_ok <- any(grepl("Convergence certificates", mt)) &&
  all(vapply(pp_tags, function(tg) any(grepl(tg, mt, fixed = TRUE)),
             logical(1))) &&
  any(grepl("D5_grey_panel", mt, fixed = TRUE))
fb_ok <- TRUE
fb_map <- rbind(c("D1","pet","D1_pet"), c("D1","peese","D1_peese"),
                c("D4","pet_pre","D4_pet_pre"),
                c("D4","peese_pre","D4_peese_pre"),
                c("D4","pet_post","D4_pet_post"),
                c("D4","peese_post","D4_peese_post"))
for (i in seq_len(nrow(fb_map))) {
  meta_fb <- any(grepl(paste0(fb_map[i,3], " -- "), mt, fixed = TRUE) &
                 grepl("FALLBACK", mt))
  note_i  <- getv(res, fb_map[i,1], fb_map[i,2], "intercept", "note")
  fb_ok <- fb_ok && identical(meta_fb,
                              grepv("OPTIMIZER FALLBACK", note_i, fixed = TRUE))
}
chk("O18", "ladder certificates for all 6 PET/PEESE fits + D5 in run_meta; FALLBACK in run_meta <=> note flag on the corresponding CSV rows [DEC-031f R3]",
    cert_ok && fb_ok)
chk("O19", "R6 control-fit line present (PASS with max|dbeta| < 1e-5, or disclosed SKIPPED)",
    any(grepl("R6 control fit: PASS", mt, fixed = TRUE)) ||
    any(grepl("R6 control fit: SKIPPED", mt, fixed = TRUE)))

# ---- O20: not_estimable consistency [P-T5-4] ----------------------------
off <- res$estimator %in% c("selmodel_3PSM_ML", "puni_star_ML")
carrier <- off & res$term %in% c("mu_3psm", "mu_punistar")
ne_flag  <- grepl("not estimable [P-T5-4]", res$note, fixed = TRUE)
o20 <- TRUE
for (i in which(carrier)) {
  est_absent <- is.na(res$est_z[i])
  o20 <- o20 && identical(est_absent, ne_flag[i])
  if (ne_flag[i]) {
    sib <- off & res$spec == res$spec[i] &
      ((res$estimator[i] == "selmodel_3PSM_ML" &
          res$estimator == "selmodel_3PSM_ML") |
       (res$estimator[i] == "puni_star_ML" & res$estimator == "puni_star_ML"))
    o20 <- o20 && all(ne_flag[sib]) &&
      any(vapply(NONCONV_SIG, function(s)
        grepl(s, res$note[i], ignore.case = TRUE), logical(1)))
  }
}
chk("O20", "not_estimable discipline: missing estimate <=> 'not estimable [P-T5-4]' note with a pinned signature; failure propagates to all rows of that estimator block",
    o20)

# ---- O21–O23: scale conventions + sanity --------------------------------
level_terms <- c("intercept", "mu_unadjusted_ML", "mu_3psm", "mu_punistar",
                 "mu_anchor_reml_knha", "cell_published", "cell_not_published")
zonly_terms <- c("sez", "sez_sq", "contrast_np_minus_p")
has_r <- !is.na(res$est_r)
o21 <- all(abs(res$est_r[has_r] - tanh(res$est_z[has_r])) < 1e-10) &&
  !any(has_r & res$term %in% zonly_terms) &&
  all(has_r[!is.na(res$est_z) & res$term %in% level_terms])
chk("O21", "est_r == tanh(est_z) wherever present (1e-10); slope/diff/contrast rows z-only; level rows carry r",
    o21)
chk("O22", "pi_* columns NA throughout (PIs live in T1/A3 [A.8])",
    all(is.na(res$pi_lb_z)) && all(is.na(res$pi_ub_z)) &&
    all(is.na(res$pi_lb_r)) && all(is.na(res$pi_ub_r)))
spn <- res$estimator == "3LMA-RVE_CR2" & !is.na(res$est_z)
wld <- res$metric == "F_test"
zrw <- res$estimator %in% c("RE_ML_cluster_agg", "selmodel_3PSM_ML",
                            "RE_REML_knha_cluster_agg") & !is.na(res$est_z)
pun <- res$estimator == "puni_star_ML" & res$term == "mu_punistar" &
       !is.na(res$est_z)
lrt <- res$metric == "LRT_test" & !is.na(res$t_stat)
flg <- res$metric == "flag"
o23 <- all(is.finite(res$est_z[spn])) && all(res$se_z[spn] > 0) &&
  all(res$ci_lb_z[spn] < res$ci_ub_z[spn]) && all(res$df[spn] > 0) &&
  all(res$p[spn] >= 0 & res$p[spn] <= 1) &&
  all(res$se_z[zrw] > 0) && all(res$ci_lb_z[zrw] < res$ci_ub_z[zrw]) &&
  all(res$p[zrw] >= 0 & res$p[zrw] <= 1) &&
  all(res$ci_lb_z[pun] < res$ci_ub_z[pun]) &&
  all(res$p[pun] >= 0 & res$p[pun] <= 1) &&
  all(is.finite(res$t_stat[wld])) && all(res$df[wld] > 0) &&
  all(res$p[wld] >= 0 & res$p[wld] <= 1) &&
  all(grepl("num_df", res$note[wld])) &&
  all(res$t_stat[lrt] >= 0) && all(res$df[lrt] == 1) &&
  all(res$p[lrt] >= 0 & res$p[lrt] <= 1) &&
  all(res$value[flg] %in% c(0, 1)) &&
  all(is.finite(res$sigma2_cluster[spn | wld])) &&
  all(is.finite(res$sigma2_study[spn | wld])) &&
  all(is.finite(res$sigma2_esid[spn | wld]))
chk("O23", "sanity: spine rows finite/se>0/ci order/df>0/p in [0,1]; agg z-rows se>0, ci order; Wald num_df noted; LRT df==1; flags in {0,1}; sigma2 on spine rows",
    o23)

# ---- O24–O25: mandated notes + absences ---------------------------------
o24 <- grepv("side by side", getv(res,"D1","rule","pet_peese_rule","note"),
             fixed = TRUE) &&
  grepv('struct="CS"', getv(res,"D2","selection_full","mu_3psm","note"),
        fixed = TRUE) &&
  grepv("no tanh", getv(res,"D5","grey_panel","contrast_np_minus_p","note"),
        fixed = TRUE) &&
  grepv("F60 pattern", getv(res,"D5","grey_panel","cell_not_published","note"),
        fixed = TRUE) &&
  grepv("DEC-031a.5", getv(res,"D4","selection_post","mu_3psm","note"),
        fixed = TRUE) &&
  grepv("F65", getv(res,"D2","selection_full","mu_anchor_reml_knha","note"),
        fixed = TRUE) &&
  grepv("FAT", getv(res,"D1","pet","sez","note"), fixed = TRUE)
chk("O24", "mandated notes: side-by-side rule text, CS-aggregation call, no-tanh, F60-pattern qs pin, DEC-031a.5 upgrade (post selection), F65 anchor tag, FAT label",
    o24)
chk("O25", "absences: no D3/RoBMA rows [DEC-031g Q1], no bp_ labels [P-T5-5], no trim-and-fill [DEC-031a.4]",
    !any(res$analysis_id == "D3") &&
    !any(grepl("RoBMA", paste(res$spec, res$term, res$estimator))) &&
    !any(grepl("^bp_", res$ms_label[!is.na(res$ms_label)])) &&
    !any(grepl("trim", paste(res$spec, res$term), ignore.case = TRUE)))

# ---- O26: ms_input inventory pinned -------------------------------------
ms_exp <- c("D1||pet||intercept", "D1||pet||sez", "D1||peese||intercept",
            "D1||rule||pet_peese_rule",
            "D4||pet_pre||intercept", "D4||pet_post||intercept",
            "D2||selection_full||mu_3psm", "D2||selection_full||mu_punistar",
            "D5||grey_panel||contrast_np_minus_p")
chk("O26", "ms_input == TRUE exactly on the 9 pinned rows",
    setequal(key[res$ms_input %in% TRUE], ms_exp))

# ---- O27: run-meta contract ---------------------------------------------
chk("O27", "run_meta: md5 asserted-vs-pin, q_status pins, direction pins, P-T5-4 signature list, PET->PEESE outcomes, sessionInfo",
    length(mt) > 0 && any(grepl("asserted == pin", mt, fixed = TRUE)) &&
    any(grepl("q_status pins", mt, fixed = TRUE)) &&
    any(grepl("direction pins", mt, fixed = TRUE)) &&
    any(grepl("signature list", mt, fixed = TRUE)) &&
    any(grepl("PET->PEESE rule", mt, fixed = TRUE)) &&
    any(grepl("sessionInfo", mt, fixed = TRUE)))

cat(sprintf("\n==> T5 VERIFIER: %d/%d PASS, %d FAIL\n", n_ok, n_ok + fails, fails))
if (fails > 0) quit(status = 1)
cat("ALL CHECKS PASSED\n")
