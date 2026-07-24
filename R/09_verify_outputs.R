# =============================================================================
# R/09_verify_outputs.R -- paired verifier for R/09_null_battery_c.R (TH-c).
# Checks O1-O19, numbered PASS/FAIL; exit status 1 on any FAIL.
# ORACLE INDEPENDENCE: does NOT source 09_null_battery_c.R; constants
# duplicated. NO model refits: anchors are value-matched against the
# committed T2 CSV (core-cell identity), arithmetic (p_perm, MDE
# interpolation, optimism) is reconstructed from the written rows/notes,
# and data-level quantities (winsor bounds, vi_k identity, PCC count) are
# recomputed from output/dat_prep.rds.
# =============================================================================

PATH_DAT_PREP <- here::here("output", "dat_prep.rds")
DIR_OUT   <- here::here("output")
RES_PATH  <- file.path(DIR_OUT, "TH_c_results.csv")
META_PATH <- file.path(DIR_OUT, "TH_c_run_meta.txt")
PERM_PATH <- file.path(DIR_OUT, "TH_c_perms.rds")
T2_PATH   <- file.path(DIR_OUT, "T2_results.csv")

K_ES <- 2713L; K_SUB <- 2705L; K_SUB_CL <- 112L
N_ROWS <- 1347L; B_PERM <- 500L; B_H1 <- 5000L
DELTA_GRID <- seq(0, 0.08, by = 0.01)
H1_LABS <- c("own_x0.5", "own_x1.0", "own_x2.0",
             "coe_x0.5", "coe_x1.0", "coe_x2.0")
CODINGS <- c("paris_mid", "tie_break_median", "end_any_exposure",
             "share_recut_2017", "share_recut_2018", "share_recut_2019",
             "end_lag1", "end_lag2", "end_lag3", "clean_window")
OUTLIERS <- c("none", "rstudent", "winsor")
ES_SETS  <- c("full", "no_starbound")
DF_BASES <- c("dfE", "k10", "k20")
RHO_GRID <- c(0.4, 0.6, 0.8)
WINSOR_Q <- c(0.01, 0.99)

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

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
num1 <- function(pat, s) {
  m <- regmatches(s, regexpr(pat, s))
  if (length(m) != 1) return(NA_real_)
  as.numeric(gsub("[^0-9.eE+-]", "", m))
}

# ---- O1 files ----------------------------------------------------------------
figs <- list.files(DIR_OUT, pattern = "TH_c.*\\.(pdf|png|svg|jpe?g)$",
                   recursive = TRUE, ignore.case = TRUE)
check("O1", file.exists(RES_PATH) && file.exists(META_PATH) &&
        file.exists(PERM_PATH) && length(figs) == 0,
      "TH_c_results.csv + run_meta + TH_c_perms.rds exist; no TH_c figures")
if (!file.exists(RES_PATH)) { cat("ABORT: results CSV missing.\n"); quit(status = 1L) }
res <- read.csv(RES_PATH, stringsAsFactors = FALSE)

# ---- O2 schema ---------------------------------------------------------------
check("O2", identical(names(res), SCHEMA), "CSV schema exact (36, T2 order)",
      paste(c(setdiff(SCHEMA, names(res)), setdiff(names(res), SCHEMA)),
            collapse = ", "))

# ---- O3 dat_prep contract ----------------------------------------------------
pr_ok <- FALSE
if (file.exists(PATH_DAT_PREP)) {
  pr <- readRDS(PATH_DAT_PREP)
  pr_ok <- is.list(pr) && !is.null(pr$dat) &&
    identical(as.integer(pr$n), K_ES) &&
    identical(as.integer(pr$seed), 20260710L) &&
    all(c("zi","vi","vi_k10","vi_k20","n_obs","ES_measure","cluster_id",
          "study","pp_mid_lag0","flag_starbound") %in% names(pr$dat)) &&
    nrow(pr$dat) == K_ES
}
if (pr_ok) dd <- pr$dat
check("O3", pr_ok, "dat_prep contract: n/seed + TH-c consumption columns present")

row_of <- function(aid, sp, tm) res[res$analysis_id == aid & res$spec == sp &
                                      res$term == tm, , drop = FALSE]
key <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "::")

# ---- O4 row inventory exact (1,347) ------------------------------------------
exp_keys <- c(
  paste("TH_design", "design", "defined",
        c("perm_list", "execution_order", "blas_note", "center_sample_mid",
          "t8_race_anchor", "h4_admissible_echo", "rstudent_mask",
          "winsor_bounds", "vi_k_identity", "core_cells"), sep = "::"),
  unlist(lapply(H1_LABS, function(l)
    paste("H1", l, "defined",
          c(sprintf("power_delta_%.2f", DELTA_GRID),
            "mde_power80", "mde_power90"), sep = "::"))),
  paste("H1", "calibration", "defined",
        c("rejection_rate", "optimism_diff"), sep = "::"),
  paste("H3", "core_curve", "defined",
        c("observed_share_sig", "observed_median_t", "p_perm_share_sig",
          "p_perm_median_t", "eff_B"), sep = "::"),
  paste("H5", "perm_race", "defined", c("p_perm", "eff_B"), sep = "::"),
  paste("H4", "perm_sup",  "defined", c("p_perm", "eff_B"), sep = "::"))
specs4 <- as.vector(outer(
  as.vector(outer(CODINGS, OUTLIERS, paste, sep = "|")),
  as.vector(outer(ES_SETS, DF_BASES, paste, sep = "|")), paste, sep = "|"))
subs <- c(sprintf("3LMA-RVE_CR2|r%.1f", RHO_GRID),
          sprintf("one_per_cluster|r%.1f", RHO_GRID), "UWLS3|r0.6")
exp_cells <- as.vector(outer(specs4, subs, function(s, u)
  paste("H3", s, u, "diff", sep = "::")))
exp_all <- c(exp_keys, exp_cells)
check("O4", nrow(res) == N_ROWS && length(exp_all) == N_ROWS &&
        identical(sort(key), sort(exp_all)) && !anyDuplicated(key),
      sprintf("row inventory exact: %d keys (10 design + 68 H1 + 5 core + 1,260 cells + 4 perm) reconstructed from the pinned grid", N_ROWS),
      paste(utils::head(c(setdiff(exp_all, key), setdiff(key, exp_all)), 3),
            collapse = " ; "))

# ---- O5 core-cell identity vs committed T2 (1e-6) ----------------------------
ok5 <- file.exists(T2_PATH); det5 <- ""
if (ok5) {
  t2 <- read.csv(T2_PATH, stringsAsFactors = FALSE)
  for (cd in CODINGS) {
    aid <- if (cd == "paris_mid") "B1" else "B3"
    r2 <- t2[t2$analysis_id == aid & t2$spec == cd & t2$term == "diff", ]
    rc <- res[!is.na(res$ms_label) &
                res$ms_label == sprintf("h3_core_%s", cd), ]
    ok_i <- nrow(r2) == 1 && nrow(rc) == 1 &&
      identical(rc$spec, sprintf("%s|none|full|dfE", cd)) &&
      identical(rc$subset, "3LMA-RVE_CR2|r0.6") &&
      near(c(rc$est_z, rc$se_z, rc$df, rc$p),
           c(r2$est_z, r2$se_z, r2$df, r2$p), 1e-6)
    if (!ok_i) { ok5 <- FALSE; det5 <- paste0(det5, cd, " ") }
  }
}
check("O5", ok5,
      "10 core cells reproduce the committed T2 B1/B3 diff rows (est/se/df/p, 1e-6) [F65 core anchor]", det5)

# ---- O6 p_perm arithmetic from written counts --------------------------------
pp_ok <- function(aid, sp) {
  rp <- row_of(aid, sp, "p_perm"); re <- row_of(aid, sp, "eff_B")
  if (nrow(rp) != 1 || nrow(re) != 1) return(FALSE)
  m <- regmatches(rp$note,
                  regexpr("\\(1 \\+ [0-9]+\\) ?/ ?\\([0-9]+ \\+ 1\\)", rp$note))
  if (length(m) != 1) return(FALSE)
  nums <- as.numeric(regmatches(m, gregexpr("[0-9]+", m))[[1]])
  cnt <- nums[2]; eff <- nums[3]
  near(rp$value, (1 + cnt) / (eff + 1), 1e-12) && eff == re$value &&
    rp$value >= 1 / (B_PERM + 1) && rp$value <= 1
}
check("O6", pp_ok("H5", "perm_race") && pp_ok("H4", "perm_sup") &&
        pp_ok("H3", "core_curve") ||
        (pp_ok("H5", "perm_race") && pp_ok("H4", "perm_sup") && {
          rp <- row_of("H3", "core_curve", "p_perm_share_sig")
          re <- row_of("H3", "core_curve", "eff_B")
          m <- regmatches(rp$note, regexpr(
            "\\(1 \\+ [0-9]+\\)/\\([0-9]+ \\+ 1\\)", rp$note))
          nums <- as.numeric(regmatches(m, gregexpr("[0-9]+", m))[[1]])
          length(m) == 1 && near(rp$value, (1 + nums[2]) / (nums[3] + 1),
                                 1e-12) && nums[3] == re$value
        }),
      "p_perm values reproduce (1 + exceed)/(eff + 1) from the counts written in the notes; bounded in [1/(B+1), 1]")

# ---- O7 effective B ----------------------------------------------------------
effs <- c(row_of("H5", "perm_race", "eff_B")$value,
          row_of("H4", "perm_sup",  "eff_B")$value,
          row_of("H3", "core_curve", "eff_B")$value)
check("O7", length(effs) == 3 && all(is.finite(effs)) &&
        all(effs >= ceiling(0.99 * B_PERM)) && all(effs <= B_PERM),
      sprintf("effective replicates >= 0.99 x %d on all three permutation statistics", B_PERM),
      paste(effs, collapse = "/"))

# ---- O8 H1 stream sanity -----------------------------------------------------
ok8 <- TRUE; det8 <- ""
for (l in H1_LABS) {
  h <- res[res$analysis_id == "H1" & res$spec == l &
             grepl("^power_delta_", res$term), ]
  h <- h[order(h$term), ]
  dfs <- unique(round(h$df, 8))
  p0 <- h$value[h$term == "power_delta_0.00"]
  pmax_ <- h$value[h$term == "power_delta_0.08"]
  if (nrow(h) != 9 || length(dfs) != 1 || !is.finite(dfs) ||
      any(!is.finite(h$value)) || any(h$value < 0 | h$value > 1) ||
      p0 < 0.02 || p0 > 0.10 || pmax_ < p0) {
    ok8 <- FALSE; det8 <- paste0(det8, l, " ") }
}
check("O8", ok8,
      "H1 per scenario: 9 power rows; df finite + constant (y-free); power in [0,1]; power(0) in [.02,.10]; power(.08) >= power(0)", det8)

# ---- O9 MDE interpolation identity -------------------------------------------
ok9 <- TRUE; det9 <- ""
interp <- function(pw, target) {
  j <- which(pw >= target)[1]
  if (is.na(j)) return(NA_real_)
  if (j == 1L) return(DELTA_GRID[1])
  DELTA_GRID[j - 1] + (target - pw[j - 1]) / (pw[j] - pw[j - 1]) * 0.01
}
for (l in H1_LABS) {
  h <- res[res$analysis_id == "H1" & res$spec == l &
             grepl("^power_delta_", res$term), ]
  h <- h[order(h$term), ]
  pw <- h$value
  for (tt in c(80, 90)) {
    rm_ <- row_of("H1", l, sprintf("mde_power%d", tt))
    ex <- interp(pw, tt / 100)
    oki <- nrow(rm_) == 1 &&
      ((is.na(ex) && is.na(rm_$value)) ||
         (!is.na(ex) && near(rm_$value, ex, 1e-10)))
    if (!oki) { ok9 <- FALSE; det9 <- paste0(det9, l, ":", tt, " ") }
  }
}
check("O9", ok9,
      "MDE80/MDE90 reproduce the linear interpolation of the written 9-point power grid (1e-10; NA-consistent above ceiling)", det9)

# ---- O10 calibration ---------------------------------------------------------
rr <- row_of("H1", "calibration", "rejection_rate")
ro <- row_of("H1", "calibration", "optimism_diff")
check("O10", nrow(rr) == 1 && nrow(ro) == 1 &&
        is.finite(rr$value) && rr$value >= 0 && rr$value <= 1 &&
        near(ro$value, 0.80 - rr$value, 1e-10) &&
        grepl("200", rr$note) && grepl("ladder", rr$note),
      "calibration: rejection rate in [0,1]; optimism == 0.80 - rate (1e-10); n = 200 + ladder documented")

# ---- O11 winsor bounds recomputed --------------------------------------------
if (pr_ok) {
  wb <- stats::quantile(dd$zi, WINSOR_Q, type = 7, names = FALSE)
  rw <- row_of("TH_design", "design", "winsor_bounds")
  lo <- num1("\\[-?[0-9.]+", rw$note)
  hi <- num1(", -?[0-9.]+\\]", rw$note)
  check("O11", nrow(rw) == 1 && near(c(lo, hi), wb, 1e-6),
        "winsor bounds in the design note match quantile(zi, .01/.99, type 7) recomputed from dat_prep (1e-6 = print precision)",
        sprintf("recomputed [%.6f, %.6f]", wb[1], wb[2]))
} else check("O11", FALSE, "winsor recompute (dat_prep unavailable)")

# ---- O12 vi_k identity + PCC count -------------------------------------------
if (pr_ok) {
  esm <- factor(dd$ES_measure)
  biv <- levels(esm)[grepl("bivar", levels(esm), ignore.case = TRUE)]
  ok12 <- nlevels(esm) == 2 && length(biv) == 1
  if (ok12) {
    pcc <- esm != biv
    rv <- row_of("TH_design", "design", "vi_k_identity")
    nno <- suppressWarnings(as.numeric(as.character(dd$n_obs)))
    ok12 <- is.numeric(dd$vi_k10) && is.numeric(dd$vi_k20) &&
      !anyNA(nno[pcc]) &&
      near(dd$vi_k10[pcc], 1 / (nno[pcc] - 13), 1e-9) &&
      near(dd$vi_k20[pcc], 1 / (nno[pcc] - 23), 1e-9) &&
      nrow(rv) == 1 && rv$value == sum(pcc)
  }
  check("O12", ok12,
        "ES_measure has 2 levels (one bivariate); vi_k10/k20 identity on PCC rows recomputed (1e-9); design-row count == #PCC rows")
} else check("O12", FALSE, "vi_k identity (dat_prep unavailable)")

# ---- O13 permutation list artifact -------------------------------------------
ok13 <- FALSE; det13 <- ""
if (file.exists(PERM_PATH)) {
  P <- readRDS(PERM_PATH)
  md5p <- unname(tools::md5sum(PERM_PATH))
  rp <- row_of("TH_design", "design", "perm_list")
  meta <- if (file.exists(META_PATH)) readLines(META_PATH, warn = FALSE)
          else character(0)
  ok13 <- is.matrix(P) && all(dim(P) == c(K_SUB_CL, B_PERM)) &&
    all(apply(P, 2, function(x) identical(sort(x), 1:K_SUB_CL))) &&
    nrow(rp) == 1 && grepl(md5p, rp$note, fixed = TRUE) &&
    any(grepl(md5p, meta, fixed = TRUE))
  det13 <- sprintf("md5 %s", md5p)
}
check("O13", ok13,
      "TH_c_perms.rds: 112 x 500; every column a permutation of 1:112; md5 echoed in design row + run_meta", det13)

# ---- O14 rstudent design row -------------------------------------------------
rs <- row_of("TH_design", "design", "rstudent_mask")
check("O14", nrow(rs) == 1 && is.finite(rs$value) && rs$value >= 0 &&
        rs$value <= K_ES && grepl("> 3", rs$note, fixed = TRUE) &&
        grepl("computed ONCE", rs$note),
      "rstudent mask: threshold 3 + once-fixed rule documented; count in [0, 2713] (fit-derived, presence-checked)")

# ---- O15 single-home absence -------------------------------------------------
check("O15", !any(res$spec %in% c("race", "break_only", "trend_only")) &&
        !any(res$term == "observed_sup") &&
        !any(grepl("^bp_", res$term)),
      "absence: no T8 race/break/trend duplicates; no observed_sup duplicate of TH-a; no bp_ rows [4a/P-T5-5]")

# ---- O16 run_meta contents ---------------------------------------------------
ok16 <- FALSE
if (file.exists(META_PATH)) {
  meta <- readLines(META_PATH, warn = FALSE)
  ok16 <- any(grepl("20260710", meta)) && any(grepl("PERMS md5", meta)) &&
    any(grepl("counters", meta)) && any(grepl("fail share", meta)) &&
    any(grepl("single-threaded", meta)) &&
    any(grepl("ladder rung", meta)) && any(grepl("delta grid", meta)) &&
    any(grepl("NCP", meta)) == FALSE &&    # NCP lives in TH-a, not here
    any(grepl("sessionInfo", meta)) && any(grepl("metafor", meta)) &&
    any(grepl("clubSandwich", meta))
}
check("O16", ok16,
      "run_meta: seed + PERMS md5 + fit counters + fail share + BLAS note + ladder certificates + delta grid + sessionInfo")

# ---- O17 not_estimable coherence on H3 cells ---------------------------------
cells <- res[res$analysis_id == "H3" & res$subset != "defined", ]
ne <- is.na(cells$est_z)
check("O17", nrow(cells) == 1260 &&
        all(grepl("not_estimable", cells$note[ne])) &&
        !any(grepl("not_estimable", cells$note[!ne])) &&
        all(is.finite(cells$est_z[!ne])) &&
        all(cells$k_es <= K_SUB) &&
        all(is.finite(res$est_z[!is.na(res$ms_label) &
                                  grepl("^h3_core_", res$ms_label)])),
      "H3 cells: est NA <=> not_estimable note; k_es bounded by 2,705; all 10 core cells estimable",
      sprintf("not_estimable cells: %d", sum(ne)))

# ---- O18 cell key format / grid consistency ----------------------------------
sp_ok <- vapply(strsplit(cells$spec, "|", fixed = TRUE), function(x)
  length(x) == 4 && x[1] %in% CODINGS && x[2] %in% OUTLIERS &&
    x[3] %in% ES_SETS && x[4] %in% DF_BASES, logical(1))
su_ok <- cells$subset %in% subs &
  ifelse(grepl("^UWLS3", cells$subset), cells$rho == 0.6, TRUE) &
  mapply(function(s, e) startsWith(s, e), cells$subset, cells$estimator)
check("O18", all(sp_ok) && all(su_ok),
      "cell spec = coding|outlier|es_set|df_basis with pinned tokens; subset = estimator|rho tag consistent with the estimator/rho columns; UWLS3 only at rho .6")

# ---- O19 p_perm bounds global ------------------------------------------------
pp <- res$value[res$term %in% c("p_perm", "p_perm_share_sig",
                                "p_perm_median_t")]
check("O19", length(pp) == 4 && all(is.finite(pp)) &&
        all(pp >= 1 / (B_PERM + 1) - 1e-12) && all(pp <= 1),
      "all four permutation p-values inside [1/(B+1), 1]")

# ---- summary -----------------------------------------------------------------
cat("\n============================================================\n")
cat(sprintf("TH-c VERIFY: %d/%d PASS%s\n", length(results) - n_fail,
            length(results),
            if (n_fail) sprintf(" -- %d FAIL", n_fail) else ""))
cat("============================================================\n")
if (n_fail > 0L) quit(status = 1L)
