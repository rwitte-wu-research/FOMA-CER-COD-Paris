# =====================================================================
# R/08_verify_outputs.R — paired verifier for T8 (Block B: B2/B4/B5/B8)
# FOMA CER–COD–Paris | data-only: reads output/T8_results.csv +
# output/dat_prep.rds; NO model refits. Numbered checks O1–O27 with
# PASS/FAIL and non-zero exit on any FAIL [analysis_plan A.7].
# Pinned: DEC-042a/b domain · F60 placebo cells (v12-derived 2026-07-14) ·
# T2/B1 replication anchors at FULL PRECISION from committed
# F61 pins: Oster pair = race vs trend_composition (same domain); transfer-rule
# flags on both B5 pp rows; 99_NCE dummies flagged not-interpreted.
# T2_results.csv @ commit 20a4e90 (paris_mid diff + cell_pre; parameterization equivalence
# ~0+factor(coding) <-> intercept+dummy).
# =====================================================================

suppressPackageStartupMessages({ library(here); library(readr) })

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")
B5_LEVELS <- c(country_region = 4L, COD_instrument = 4L, CER_measure = 2L)  # v12 pin [W1]
N_ROWS <- 69L + 2L * sum(B5_LEVELS - 1L)   # derived row budget (= 83 on v12)
N_SET <- 2713L
N_SUB <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L
K_NA_ES <- 8L; K_NA_ST <- 2L
POST16 <- c(711L, 31L, 31L)
SHARE_DISTINCT <- 41L
# T2/B1 anchors (full precision, committed T2_results.csv)
T2_DIFF_EST <- 0.0101759067104026
T2_DIFF_SE  <- 0.0181072824212575
T2_DIFF_DF  <- 14.9920663728925
T2_DIFF_P   <- 0.582435725630516
T2_PRE_EST  <- -0.0615991565189955
TOL_EST <- 1e-6; TOL_DF <- 1e-3
PLACEBO_PIN <- data.frame(  # v12 design constants [F60 ruling 2026-07-14]
  Y  = 2008:2015,
  es = c(2367L, 2345L, 2326L, 2077L, 1769L, 1486L, 1269L, 784L),
  st = c( 100L,   99L,   98L,   93L,   82L,   69L,   55L,  38L),
  cl = c(  99L,   98L,   97L,   92L,   81L,   69L,   55L,  38L))

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

# ---- O1–O5: file, schema, row plan --------------------------------------
f_res <- here("output", "T8_results.csv")
chk("O1", "output/T8_results.csv exists", file.exists(f_res))
if (!file.exists(f_res)) { cat("ABORT: no results file.\n"); quit(status = 1) }
res <- read_csv(f_res, show_col_types = FALSE, na = c("", "NA"))
chk("O2", "36 columns, names identical to T2 schema (verbatim, in order)",
    identical(names(res), SCHEMA))
chk("O3", sprintf("row count == %d", N_ROWS), nrow(res) == N_ROWS)
key <- paste(res$analysis_id, res$spec, res$term, sep = "||")
chk("O4", "no duplicate (analysis_id, spec, term) keys", !anyDuplicated(key))
chk("O5", "analysis_id set == {T8_design, B2, B4, B5, B8}",
    setequal(unique(res$analysis_id), c("T8_design","B2","B4","B5","B8")))

# ---- O6: model-row invariants (T1/T2 label conventions) ------------------
is_fit <- res$estimator == "3LMA-RVE_CR2" &
          (!is.na(res$est_z) | res$metric == "F_test")
chk("O6", "fitted-model rows: k = 2705/113/112, rho = 0.6; subset = 'defined' everywhere; metric conventions",
    all(res$k_es[is_fit] == N_SUB) && all(res$k_study[is_fit] == N_SUB_ST) &&
    all(res$k_cluster[is_fit] == N_SUB_CL) && all(res$rho[is_fit] == 0.6) &&
    all(res$subset == "defined") &&
    all(res$metric[is_fit] %in% c("Fisher_z", "F_test")))

# ---- O7–O14: recomputation from dat_prep (design identities) ------------
pr <- readRDS(here("output", "dat_prep.rds"))
d  <- pr$dat
na_win <- is.na(d$pp_mid_lag0)
sub <- d[!na_win, , drop = FALSE]
chk("O7", "domain: pr$n = 2713; subset = 2705 ES / 113 studies / 112 clusters; NA-window = 8 ES / 2 studies",
    pr$n == N_SET && nrow(sub) == N_SUB &&
    length(unique(sub$study)) == N_SUB_ST &&
    length(unique(sub$cluster_id)) == N_SUB_CL &&
    sum(na_win) == K_NA_ES && length(unique(d$study[na_win])) == K_NA_ST)

p16 <- sub$pp_mid_lag0 == 1
chk("O8", "post cell 2016 == 711/31/31 (recomputed) and design row value == 711",
    sum(p16) == POST16[1] &&
    length(unique(sub$study[p16])) == POST16[2] &&
    length(unique(sub$cluster_id[p16])) == POST16[3] &&
    isTRUE(all.equal(getv(res,"T8_design","design","post_cell_2016","value"),
                     as.numeric(POST16[1]))))

share_y <- function(Y) {
  L <- sub$d_sample_end - sub$d_sample_start + 1
  pmin(pmax((sub$d_sample_end - Y + 1) / L, 0), 1)
}
ok9 <- TRUE
for (i in seq_len(nrow(PLACEBO_PIN))) {
  Y <- PLACEBO_PIN$Y[i]; pp <- share_y(Y) >= 0.5
  ok9 <- ok9 &&
    sum(pp) == PLACEBO_PIN$es[i] &&
    length(unique(sub$study[pp])) == PLACEBO_PIN$st[i] &&
    length(unique(sub$cluster_id[pp])) == PLACEBO_PIN$cl[i]
  nt <- getv(res, "B4", sprintf("placebo_%d", Y), sprintf("pp_break_%d", Y), "note")
  ok9 <- ok9 && grepl(sprintf("post cell pinned: %d ES / %d studies / %d clusters",
                              PLACEBO_PIN$es[i], PLACEBO_PIN$st[i],
                              PLACEBO_PIN$cl[i]), nt, fixed = TRUE)
}
chk("O9", "placebo cells 2008–2015: recomputed == pinned table == CSV notes", ok9)

chk("O10", "2016 reconstruction: share formula == pp_share_lag0 (1e-9) and binary == pp_mid_lag0 (0 mismatches)",
    max(abs(share_y(2016) - sub$pp_share_lag0)) < 1e-9 &&
    all(as.integer(share_y(2016) >= 0.5) == as.integer(sub$pp_mid_lag0)))

ok11 <- TRUE
for (Y in 2008:2016) ok11 <- ok11 && all((share_y(Y) >= 0.5) == (sub$sample_mid >= Y - 0.5))
chk("O11", "mid-rule == share-rule for all cutoffs 2008–2016", ok11)

p95 <- as.numeric(quantile(sub$pp_share_lag0, .95))
chk("O12", "share support: distinct == 41; CSV p95/eq1/eq0 == recomputed",
    length(unique(sub$pp_share_lag0)) == SHARE_DISTINCT &&
    isTRUE(all.equal(getv(res,"T8_design","design","share_distinct","value"), 41)) &&
    abs(getv(res,"T8_design","design","share_p95_es","value") - p95) < 1e-9 &&
    getv(res,"T8_design","design","share_eq1","value") == sum(sub$pp_share_lag0 == 1) &&
    getv(res,"T8_design","design","share_eq0","value") == sum(sub$pp_share_lag0 == 0))

chk("O13", "corr(sample_mid, share) CSV == recomputed (1e-6)",
    abs(getv(res,"T8_design","design","corr_sample_mid_share","value") -
        cor(sub$sample_mid, sub$pp_share_lag0)) < 1e-6)

ctr <- unique(round(sub$sample_mid - sub$sample_mid_c, 9))
chk("O14", "centering constant unique and == CSV design row (1e-9)",
    length(ctr) == 1 &&
    abs(getv(res,"T8_design","design","center_sample_mid","value") - ctr) < 1e-9)

# ---- O15: T2/B1 replication at full precision ----------------------------
e15 <- getv(res,"B4","break_only","pp_mid_lag0","est_z")
s15 <- getv(res,"B4","break_only","pp_mid_lag0","se_z")
d15 <- getv(res,"B4","break_only","pp_mid_lag0","df")
p15 <- getv(res,"B4","break_only","pp_mid_lag0","p")
i15 <- getv(res,"B4","break_only","intercept","est_z")
chk("O15", "T2/B1 replication (full precision): diff est/se/p (1e-6), df (1e-3); intercept == cell_pre (1e-6)",
    abs(e15 - T2_DIFF_EST) <= TOL_EST && abs(s15 - T2_DIFF_SE) <= TOL_EST &&
    abs(p15 - T2_DIFF_P)   <= TOL_EST && abs(d15 - T2_DIFF_DF) <= TOL_DF &&
    abs(i15 - T2_PRE_EST)  <= TOL_EST)

# ---- O16–O18: internal arithmetic identities ----------------------------
b_sh <- getv(res,"B2","dose_linear","pp_share_lag0","est_z")
chk("O16", "contrast identities: c(0->0.6) == 0.6 x slope; c(0->1) == slope (1e-10)",
    abs(getv(res,"B2","dose_linear","contrast_0_to_0.6","est_z") - 0.6 * b_sh) < 1e-10 &&
    abs(getv(res,"B2","dose_linear","contrast_0_to_1","est_z") - b_sh) < 1e-10)
chk("O17", "prediction identity: pred(1) - pred(0) == slope (1e-9)",
    abs(getv(res,"B2","dose_linear","pred_share_1","est_z") -
        getv(res,"B2","dose_linear","pred_share_0","est_z") - b_sh) < 1e-9)
has_r <- !is.na(res$est_r)
zonly <- res$term %in% c("contrast_0_to_0.6","contrast_0_to_1") |
         (res$metric == "Fisher_z" & !is.na(res$est_z) &
          !(res$term %in% c("intercept","level_at_knot_pre",
                            "pred_share_0","pred_share_0.6","pred_share_1")))
chk("O18", "est_r == tanh(est_z) wherever present (1e-10); slope/diff/contrast rows z-only",
    all(abs(res$est_r[has_r] - tanh(res$est_z[has_r])) < 1e-10) &&
    !any(has_r & zonly))

# ---- O19–O22: conventions and sanity ------------------------------------
chk("O19", "pi_* columns NA throughout (PIs live in T1/A3 [A.8])",
    all(is.na(res$pi_lb_z)) && all(is.na(res$pi_ub_z)) &&
    all(is.na(res$pi_lb_r)) && all(is.na(res$pi_ub_r)))
est_rows <- res$estimator == "3LMA-RVE_CR2" & !is.na(res$est_z)
wld <- res$metric == "F_test"
chk("O20", "sanity: estimates finite, se > 0, ci_lb < ci_ub, df > 0, p in [0,1]; Wald F finite; sigma2 present on fitted rows",
    all(is.finite(res$est_z[est_rows])) && all(res$se_z[est_rows] > 0) &&
    all(res$ci_lb_z[est_rows] < res$ci_ub_z[est_rows]) &&
    all(res$df[est_rows] > 0) &&
    all(res$p[est_rows] >= 0 & res$p[est_rows] <= 1) &&
    all(is.finite(res$t_stat[wld])) && all(res$df[wld] > 0) &&
    all(res$p[wld] >= 0 & res$p[wld] <= 1) &&
    all(is.finite(res$sigma2_cluster[est_rows | wld])) &&
    all(is.finite(res$sigma2_study[est_rows | wld])) &&
    all(is.finite(res$sigma2_esid[est_rows | wld])))
chk("O21", "Wald rows disclose numerator df (note contains 'num_df')",
    all(grepl("num_df", res$note[wld])))
ev <- res$analysis_id == "B8" & res$spec == "evalue"
r2 <- res$term %in% c("r2_uncontrolled","r2_controlled")
bs <- getv(res,"B8","oster","beta_star_delta1","value")
bn <- getv(res,"B8","oster","beta_star_delta1","note")
ds <- getv(res,"B8","oster","delta_for_beta_zero","value")
dn <- getv(res,"B8","oster","delta_for_beta_zero","note")
chk("O22", "B8: E-values >= 1 and finite; R2 finite; beta*/delta* finite or NA-with-GUARD-note",
    all(is.finite(res$value[ev]) & res$value[ev] >= 1) &&
    all(is.finite(res$value[r2])) &&
    ((is.finite(bs) && is.finite(ds)) ||
     (is.na(bs) && grepl("GUARD", bn) && is.na(ds) && grepl("GUARD", dn))))

# ---- O23: required key rows present -------------------------------------
req <- rbind(
  c("B2","dose_linear","pp_share_lag0"), c("B2","dose_linear","contrast_0_to_0.6"),
  c("B2","dose_linear","contrast_0_to_1"), c("B2","dose_linear","pred_share_0"),
  c("B2","dose_linear","pred_share_0.6"), c("B2","dose_linear","pred_share_1"),
  c("B2","dose_quadratic","pp_share_lag0_sq"), c("B2","dose_quadratic","wald_share_joint"),
  c("B4","trend_only","sample_mid_c"), c("B4","break_only","intercept"),
  c("B4","break_only","pp_mid_lag0"),
  c("B4","race","sample_mid_c"), c("B4","race","pp_mid_lag0"),
  c("B4","placebo_summary","rank_2016_abs_break"),
  c("B4","segmented","slope_pre"), c("B4","segmented","level_shift_2016"),
  c("B4","segmented","slope_change_2016"), c("B4","segmented","wald_break_joint"),
  c("B5","composition_adj","pp_mid_lag0"), c("B5","composition_adj","wald_composition_joint"),
  c("B5","composition_adj","delta_vs_break_only"),
  c("B5","trend_composition","pp_mid_lag0"), c("B5","trend_composition","wald_composition_joint"),
  c("B8","oster","r2_uncontrolled"), c("B8","oster","r2_controlled"),
  c("B8","oster","beta_star_delta1"), c("B8","oster","delta_for_beta_zero"),
  c("B8","evalue","evalue_point"), c("B8","evalue","evalue_ci_edge"),
  c("B8","evalue","evalue_mask_sesoi_contrast"), c("B8","evalue","evalue_mask_sesoi_pooled"))
req_key <- paste(req[,1], req[,2], req[,3], sep = "||")
plc_key <- paste("B4", sprintf("placebo_%d", 2008:2015),
                 sprintf("pp_break_%d", 2008:2015), sep = "||")
missing_keys <- setdiff(c(req_key, plc_key), key)
chk("O23", "all required result keys present (31 fixed + 8 placebo)",
    length(missing_keys) == 0)
if (length(missing_keys)) cat("  missing:", paste(missing_keys, collapse = "; "), "\n")

# ---- O24: mandated disclosure notes -------------------------------------
chk("O24", "mandated notes: joint-support caveat, design-df 31.9, ANALOG (Oster), approx (E-value), F60 (placebos), no-tanh, F61 flags (transfer rule, 99_NCE, race pair)",
    grepl("joint", getv(res,"B2","dose_linear","pred_share_1","note")) &&
    grepl("31.9", getv(res,"B4","break_only","pp_mid_lag0","note"), fixed = TRUE) &&
    all(grepl("ANALOG", res$note[r2])) &&
    all(grepl("approx", res$note[ev])) &&
    all(grepl("F60", res$note[grepl("^pp_break_", res$term)])) &&
    grepl("no tanh", getv(res,"B4","break_only","pp_mid_lag0","note")) &&
    grepl("transfer rule", getv(res,"B5","composition_adj","pp_mid_lag0","note")) &&
    grepl("transfer rule", getv(res,"B5","trend_composition","pp_mid_lag0","note")) &&
    all(grepl("not interpreted",
              res$note[res$analysis_id == "B5" & grepl("99_NCE", res$term)])) &&
    grepl("race", getv(res,"B8","oster","r2_uncontrolled","note")))

# ---- O25: run-meta contract [W3] -----------------------------------------
f_meta <- here("output", "T8_run_meta.txt")
meta_ok <- FALSE
if (file.exists(f_meta)) {
  mt <- readLines(f_meta, warn = FALSE)
  meta_ok <- any(grepl("md5", mt)) && any(grepl("CENTER", mt)) &&
             any(grepl("F60", mt)) && any(grepl("F61", mt)) &&
             any(grepl("sessionInfo", mt))
}
chk("O25", "output/T8_run_meta.txt exists with md5 + CENTER + F60 + F61 + sessionInfo",
    meta_ok)

# ---- O26: prediction-offset identity [W4] --------------------------------
b0_26 <- getv(res,"B2","dose_linear","intercept","est_z")
bt_26 <- getv(res,"B2","dose_linear","sample_mid_c","est_z")
p0_26 <- getv(res,"B2","dose_linear","pred_share_0","est_z")
c0_26 <- getv(res,"T8_design","design","center_sample_mid","value")
chk("O26", "pred_share_0 == intercept + (2015.5 - CENTER) * trend slope (1e-9)",
    abs(p0_26 - (b0_26 + (2015.5 - c0_26) * bt_26)) < 1e-9)

# ---- O27: ms_input inventory pinned ---------------------------------------
ms_exp <- c("B2||dose_linear||pp_share_lag0",
            "B2||dose_linear||contrast_0_to_0.6",
            "B4||race||sample_mid_c", "B4||race||pp_mid_lag0",
            "B4||placebo_summary||rank_2016_abs_break",
            "B4||segmented||level_shift_2016",
            "B5||composition_adj||pp_mid_lag0",
            "B5||trend_composition||pp_mid_lag0",
            "B8||oster||beta_star_delta1",
            "B8||evalue||evalue_mask_sesoi_contrast")
chk("O27", "ms_input == TRUE exactly on the 10 pinned rows",
    setequal(key[res$ms_input %in% TRUE], ms_exp))

cat(sprintf("\n==> T8 VERIFIER: %d/%d PASS, %d FAIL\n", n_ok, n_ok + fails, fails))
if (fails > 0) quit(status = 1)
cat("ALL CHECKS PASSED\n")
