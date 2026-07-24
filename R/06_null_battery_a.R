# =====================================================================
# R/06_null_battery_a.R — TH-a: Block E (E1–E3) + Block H fast set
#   (H4 point estimates + admissibility set, H6, H7, H8, H9, H10, H11)
# FOMA CER–COD–Paris | verifier-paired (no Gate-2; author GO given in chat)
# ---------------------------------------------------------------------
# Authority: DEC-045 (E/H execution spec; supersession register S1–S9) ·
#   DEC-044 (language gate; framing-neutral output) · DEC-031 Blocks E/H ·
#   DEC-031e/f (parameterization/convergence) · DEC-042a/b (domains) ·
#   analysis_plan A.2/A.3/A.13 · F60 (canonical share_Y recode) ·
#   F65 pattern (runtime-read anchors + embedded full-precision constants).
# Domains: E1 = estimation set 2,713 ES / 115 studies / 114 clusters;
#   E2/H4/H6/H7/H8/H10/H11 = period domain 2,705 / 113 / 112 [DEC-042b].
# Spine: rma.mv REML sparse, V = impute_covariance_matrix(vi, cluster, .6),
#   random = ~1 | cluster_id/study/esid, CR2 + Satterthwaite on cluster_id.
# Output: output/TH_a_results.csv — T2 schema (36 columns);
#   deterministic row budget N_ROWS_A = 177 (all planned keys always
#   written; failures surface as not_estimable, never missing rows);
#   output/TH_a_run_meta.txt (md5, pins, certificates, sessionInfo).
# Result framing: NONE. This script computes and writes; it does not
#   interpret. Gate resolution (E3) is a documented post-run step.
# ---------------------------------------------------------------------
# Row budget (auditable):
#   8 design + 3 E1 + 4 E2 + 3 E3 + 13 H4 (12 years + sup) + 3 H6
# + 113 H7 + 21 H8 + 2 H9 + 4 H10 + 3 H11 = 177.
# =====================================================================

suppressPackageStartupMessages({
  library(metafor)
  library(clubSandwich)
  library(here)
  library(readr)
})

# ------------------------------ 0. Constants (FROZEN ZONE) ------------
RHO   <- 0.6                         # DEC-017
KNOT  <- 2015.5                      # Paris threshold: mid >= 2015.5 [A.3]
SEED  <- 20260710L
N_SET <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L    # DEC-042a
N_SUB <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L    # DEC-042b
K_NA_ES <- 8L;  K_NA_ST <- 2L                          # DEC-042b
POST16  <- c(es = 711L, st = 31L, cl = 31L)            # v12 design constants
TIE_PIN <- c(es = 79L, st = 5L, cl = 5L)               # H6 [DEC-045]
H7_STEPS   <- 113L                                     # S7 [DEC-045]
H7_FLOOR_K <- 10L                                      # display floor (clusters)
H4_YEARS   <- 2008:2019                                # sup-break grid [Annex H]
H4_DF_MIN  <- 5                                        # DEC-024 transfer rule
H8_ANCHOR  <- 1998L; H8_WIDTH <- 6L; H8_STEP <- 1L     # 21 windows [DEC-045]
H8_STARTS  <- seq(H8_ANCHOR, 2018L, by = H8_STEP)
H10_KMIN   <- 5L; H10_ALPHA <- 0.05                    # N13 rule [Annex H]
NCP_33     <- stats::qnorm(0.975) - stats::qnorm(2/3)  # z-metric 33%-power ncp:
                                     # P(Z > 1.96 - ncp) = 1/3 => ncp ~ 1.5293
                                     # [MUSS-2 package-review fix 2026-07-22]

# SESOI bands [DEC-031 Block E; DEC-045 E-pins]
SESOI_R_PRIMARY   <- 0.070          # |r| level band (F27v2)
SESOI_R_SECONDARY <- 0.05           # |dr| contrast band
BAND_E1_PRIMARY   <- atanh(SESOI_R_PRIMARY)    # z-scale level band
BAND_E1_SECONDARY <- atanh(SESOI_R_SECONDARY)
BAND_E2           <- SESOI_R_SECONDARY         # z-difference band; |dz| read
                                               # as |dr| (third-order approx,
                                               # T8/B8 convention) [DEC-045]

# F65 embedded full-precision anchors (drift canaries; runtime-read below)
A_T1A1 <- c(est = -0.058646736610098,  se = 0.013856549617299,
            df = 111.671795029271,
            lb = -0.0861025946387978,  ub = -0.0311908785813981)
A_T1A2 <- c(cl = 0.0197455486661123, st = 1.02092128749543e-09,
            es = 0.0118831792865472)
A_T2B1_PRE  <- -0.0615991565189955
A_T2B1_DIFF <- c(est = 0.0101759067104026, se = 0.0181072824212575,
                 df = 14.9920663728925,    p  = 0.582435725630516)
# COE companion constants (full text, verified 2026-07-22 [DEC-045/H-Q13])
COE_STUDY_LEVEL <- c(r = -0.039, lb = -0.046, ub = -0.032)   # Table 3, 75 units
COE_ES_LEVEL    <- c(r = -0.041, lb = -0.043, ub = -0.039)   # Table 2, k = 1,139

N_ROWS_A   <- 177L
SUBSET_LAB <- "defined"

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

`%||%` <- function(a, b) if (is.null(a)) b else a

# ------------------------------ 1. Load + input contract --------------
pr <- readRDS(here("output", "dat_prep.rds"))
stopifnot(is.list(pr), !is.null(pr$dat), pr$n == N_SET, pr$seed == SEED)
set.seed(pr$seed)
dat <- pr$dat

need <- c("zi","vi","cluster_id","study","esid","sample_mid",
          "pp_mid_lag0","pp_window_class","d_sample_start","d_sample_end")
miss <- setdiff(need, names(dat))
if (length(miss)) stop("SCHEMA HARD STOP — missing columns: ",
                       paste(miss, collapse = ", "))
stopifnot(nrow(dat) == N_SET,
          length(unique(dat$study)) == N_SET_ST,
          length(unique(dat$cluster_id)) == N_SET_CL,
          is.numeric(dat$vi), all(dat$vi > 0))

na_win <- is.na(dat$pp_mid_lag0)                        # DEC-042b
stopifnot(sum(na_win) == K_NA_ES,
          length(unique(dat$study[na_win])) == K_NA_ST)
sub <- dat[!na_win, , drop = FALSE]
stopifnot(nrow(sub) == N_SUB,
          length(unique(sub$study)) == N_SUB_ST,
          length(unique(sub$cluster_id)) == N_SUB_CL,
          !anyNA(sub$sample_mid),
          !anyNA(sub$d_sample_start), !anyNA(sub$d_sample_end),
          all(sub$pp_mid_lag0 %in% 0:1))

# Canonical share_Y [F60]; ties→Post identity gates as in R/08
share_y <- function(d, Y) {
  L <- d$d_sample_end - d$d_sample_start + 1
  pmin(pmax((d$d_sample_end - Y + 1) / L, 0), 1)
}
stopifnot(all(as.integer(share_y(sub, 2016) >= 0.5) ==
              as.integer(sub$pp_mid_lag0)))
for (Y in H4_YEARS) {
  stopifnot(all((share_y(sub, Y) >= 0.5) == (sub$sample_mid >= Y - 0.5)))
}
p16 <- sub$pp_mid_lag0 == 1
stopifnot(sum(p16) == POST16["es"],
          length(unique(sub$study[p16])) == POST16["st"],
          length(unique(sub$cluster_id[p16])) == POST16["cl"])

# ------------------------------ 2. Runtime-read anchor gates (F65) ----
read_committed <- function(fname) {
  p <- here("output", fname)
  if (!file.exists(p)) stop("ANCHOR HARD STOP — committed file missing: ", fname)
  read.csv(p, stringsAsFactors = FALSE)
}
near0 <- function(a, b, tol) all(is.finite(a) & is.finite(b)) &&
  all(abs(a - b) <= tol)

t1 <- read_committed("T1_results.csv")
rA1 <- t1[t1$analysis_id == "A1" & t1$spec == "headline", , drop = FALSE]
stopifnot(nrow(rA1) == 1,
          near0(c(rA1$est_z, rA1$se_z, rA1$df, rA1$ci_lb_z, rA1$ci_ub_z),
                unname(A_T1A1), 1e-9),
          near0(c(rA1$sigma2_cluster, rA1$sigma2_study, rA1$sigma2_esid),
                unname(A_T1A2), 1e-9))
t2 <- read_committed("T2_results.csv")
rB1p <- t2[t2$analysis_id == "B1" & t2$spec == "paris_mid" &
             t2$term == "cell_pre", , drop = FALSE]
rB1d <- t2[t2$analysis_id == "B1" & t2$spec == "paris_mid" &
             t2$term == "diff", , drop = FALSE]
stopifnot(nrow(rB1p) == 1, nrow(rB1d) == 1,
          near0(rB1p$est_z, A_T2B1_PRE, 1e-9),
          near0(c(rB1d$est_z, rB1d$se_z, rB1d$df, rB1d$p),
                unname(A_T2B1_DIFF), 1e-9))

# ------------------------------ 3. Spine helpers ----------------------
FIT_LOG <- character(0)   # [DEC-031e/f] convergence certificates -> run_meta
LADDER_OPTS <- list(      # DEC-031f ladder; applied to EVERY 3L spine fit
  list(label = "nlminb",            control = list(optimizer = "nlminb")),
  list(label = "optim/BFGS",        control = list(optimizer = "optim",
                                                   optmethod = "BFGS")),
  list(label = "optim/Nelder-Mead", control = list(optimizer = "optim",
                                                   optmethod = "Nelder-Mead")))
fit3l <- function(fml, d, tag) {
  V <- impute_covariance_matrix(vi = d$vi, cluster = d$cluster_id, r = RHO)
  one <- function(ctrl) rma.mv(yi = zi, V = V, mods = fml,
                               random = ~ 1 | cluster_id/study/esid,
                               data = d, sparse = TRUE, method = "REML",
                               control = ctrl)
  errs <- character(0)               # [R2] deterministic, first-certified-wins
  for (k in seq_along(LADDER_OPTS)) {
    o <- LADDER_OPTS[[k]]
    m <- tryCatch(one(o$control), error = function(e) e)
    if (!inherits(m, "error")) {
      FIT_LOG <<- c(FIT_LOG, sprintf(
        "%s [k=%d] -- optimizer %s (ladder rung %d/3); converged (metafor-certified)%s [DEC-031f R2/R3; DEC-045 every-spine-fit pin]%s",
        tag, nrow(d), o$label, k, if (k > 1L) "; FALLBACK" else "",
        if (length(errs)) paste0("; prior rungs failed: ",
                                 paste(errs, collapse = " | ")) else ""))
      return(m)
    }
    errs <- c(errs, sprintf("%s: %s", o$label, conditionMessage(m)))
  }
  stop("DEC-031f R5 STOP -- all ladder rungs failed for '", tag, "': ",
       paste(errs, collapse = " | "))
}
vcr <- function(m, d) vcovCR(m, cluster = d$cluster_id, type = "CR2")

SPINE <- "random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6; CR2/Satterthwaite on cluster_id [D31.1/A.2]"
mnote <- function(mods, dom) sprintf("rma.mv mods=%s; %s; domain %s", mods, SPINE, dom)

row_base <- function(analysis_id, spec, term, metric,
                     subset = SUBSET_LAB,
                     estimator = "3LMA-RVE_CR2", rho = RHO,
                     k_es = NA_integer_, k_study = NA_integer_,
                     k_cluster = NA_integer_,
                     est_z = NA_real_, se_z = NA_real_, t_stat = NA_real_,
                     df = NA_real_, p = NA_real_,
                     ci_lb_z = NA_real_, ci_ub_z = NA_real_,
                     est_r = NA_real_, ci_lb_r = NA_real_, ci_ub_r = NA_real_,
                     sigma2 = NULL, value = NA_real_, ms_input = FALSE,
                     ms_label = NA_character_, note = NA_character_) {
  data.frame(
    analysis_id = analysis_id, spec = spec, subset = subset, term = term,
    metric = metric, estimator = estimator, rho = rho,
    k_es = k_es, k_study = k_study, k_cluster = k_cluster,
    est_z = est_z, se_z = se_z, t_stat = t_stat, df = df, p = p,
    ci_lb_z = ci_lb_z, ci_ub_z = ci_ub_z,
    pi_lb_z = NA_real_, pi_ub_z = NA_real_,
    est_r = est_r, ci_lb_r = ci_lb_r, ci_ub_r = ci_ub_r,
    pi_lb_r = NA_real_, pi_ub_r = NA_real_,
    sigma2_cluster = if (!is.null(sigma2)) sigma2[1] else NA_real_,
    sigma2_study   = if (!is.null(sigma2)) sigma2[2] else NA_real_,
    sigma2_esid    = if (!is.null(sigma2)) sigma2[3] else NA_real_,
    pct_cluster = NA_real_, pct_study = NA_real_, pct_esid = NA_real_,
    pct_sampling = NA_real_,
    typical_v = NA_real_, value = value,
    ms_input = ms_input, ms_label = ms_label, note = note,
    stringsAsFactors = FALSE)
}

design_row <- function(term, metric, value = NA_real_, note = NA_character_) {
  row_base("TH_design", "design", term, metric = metric,
           estimator = "descriptive", rho = NA_real_, value = value, note = note)
}

# Cell-means period model (DEC-031e/A.11 default for factor-only) ------
cellmeans <- function(d, coding, tag) {
  d$pp_cell <- factor(coding, levels = c(0, 1))
  m  <- fit3l(~ 0 + pp_cell, d, tag)
  ct <- coef_test(m, vcov = vcr(m, d), test = "Satterthwaite")
  ci <- conf_int(m, vcov = vcr(m, d), level = .95)
  lc <- linear_contrast(m, vcov = vcr(m, d),
                        contrasts = rbind(diff = c(-1, 1)), level = .95)
  dfd <- lc$df %||% lc$df_Satt
  list(m = m,
       pre  = list(est = ct$beta[1], se = ct$SE[1], t = ct$tstat[1],
                   df = (ct$df_Satt %||% ct$df)[1],
                   p  = (ct$p_Satt  %||% ct$p)[1],
                   lb = ci$CI_L[1], ub = ci$CI_U[1]),
       post = list(est = ct$beta[2], se = ct$SE[2], t = ct$tstat[2],
                   df = (ct$df_Satt %||% ct$df)[2],
                   p  = (ct$p_Satt  %||% ct$p)[2],
                   lb = ci$CI_L[2], ub = ci$CI_U[2]),
       diff = list(est = lc$Est[1], se = lc$SE[1],
                   t = lc$Est[1] / lc$SE[1], df = dfd[1],
                   p = 2 * stats::pt(-abs(lc$Est[1] / lc$SE[1]), df = dfd[1]),
                   lb = lc$CI_L[1], ub = lc$CI_U[1]))
}
cm_rows <- function(cm, analysis_id, spec, nn, dom_k, diff_note = "",
                    ms = FALSE, ms_label = NA_character_) {
  s2 <- cm$m$sigma2
  list(
    row_base(analysis_id, spec, "cell_pre", "Fisher_z",
             k_es = dom_k$pre_es, k_study = dom_k$pre_st,
             k_cluster = dom_k$pre_cl,
             est_z = cm$pre$est, se_z = cm$pre$se, t_stat = cm$pre$t,
             df = cm$pre$df, p = cm$pre$p,
             ci_lb_z = cm$pre$lb, ci_ub_z = cm$pre$ub,
             est_r = tanh(cm$pre$est), ci_lb_r = tanh(cm$pre$lb),
             ci_ub_r = tanh(cm$pre$ub), sigma2 = s2,
             note = paste0(nn, "; cell mean at coding = 0 (pre)")),
    row_base(analysis_id, spec, "cell_post", "Fisher_z",
             k_es = dom_k$post_es, k_study = dom_k$post_st,
             k_cluster = dom_k$post_cl,
             est_z = cm$post$est, se_z = cm$post$se, t_stat = cm$post$t,
             df = cm$post$df, p = cm$post$p,
             ci_lb_z = cm$post$lb, ci_ub_z = cm$post$ub,
             est_r = tanh(cm$post$est), ci_lb_r = tanh(cm$post$lb),
             ci_ub_r = tanh(cm$post$ub), sigma2 = s2,
             note = paste0(nn, "; cell mean at coding = 1 (post)")),
    row_base(analysis_id, spec, "diff", "Fisher_z",
             k_es = dom_k$all_es, k_study = dom_k$all_st,
             k_cluster = dom_k$all_cl,
             est_z = cm$diff$est, se_z = cm$diff$se, t_stat = cm$diff$t,
             df = cm$diff$df, p = cm$diff$p,
             ci_lb_z = cm$diff$lb, ci_ub_z = cm$diff$ub, sigma2 = s2,
             ms_input = ms, ms_label = ms_label,
             note = paste0(nn,
               "; post-minus-pre contrast (-1, +1); cell-means parameterization [DEC-031e/A.11]; difference of Fisher-z means; no tanh transform of differences",
               if (nzchar(diff_note)) paste0("; ", diff_note) else "")))
}

# TOST row (two one-sided tests <=> 90% CI-in-band) [DEC-045 E-pins] ---
tost_row <- function(analysis_id, spec, term, est, se, df, band_z, band_lab,
                     dom_k, sigma2, ms = FALSE, ms_label = NA_character_,
                     extra_note = "") {
  t_low <- (est + band_z) / se           # H0: est <= -band
  t_up  <- (est - band_z) / se           # H0: est >=  band
  p_low <- 1 - stats::pt(t_low, df = df)
  p_up  <- stats::pt(t_up, df = df)
  p_tost <- max(p_low, p_up)
  q90 <- stats::qt(0.95, df = df)
  lb90 <- est - q90 * se; ub90 <- est + q90 * se
  pass <- (lb90 > -band_z) && (ub90 < band_z)
  stopifnot(identical(pass, p_tost < 0.05))            # internal identity
  row_base(analysis_id, spec, term, "Fisher_z",
           k_es = dom_k$all_es, k_study = dom_k$all_st,
           k_cluster = dom_k$all_cl,
           est_z = est, se_z = se, df = df, p = p_tost,
           ci_lb_z = lb90, ci_ub_z = ub90,
           sigma2 = sigma2, value = as.numeric(pass),
           ms_input = ms, ms_label = ms_label,
           note = paste0(
             "TOST, two one-sided tests each alpha=.05 <=> 90% CI inside band [DEC-045 E-pins]; ",
             band_lab,
             sprintf("; arm p (lower/upper) = %.6g / %.6g; TOST p = max(arms); CI columns carry the 90%% CI (TOST convention); value = 1{90%%-CI inside band} (mechanical flag, no verdict language)",
                     p_low, p_up),
             if (nzchar(extra_note)) paste0("; ", extra_note) else ""))
}

rows <- list()

# ------------------------------ 4. E1 — TOST pooled mean --------------
nE1 <- mnote("~ 1", sprintf("estimation set %d/%d/%d [DEC-042a]",
                            N_SET, N_SET_ST, N_SET_CL))
mE1 <- fit3l(~ 1, dat, "E1_pooled (T1/A1 refit)")
ctE1 <- coef_test(mE1, vcov = vcr(mE1, dat), test = "Satterthwaite")
ciE1 <- conf_int(mE1, vcov = vcr(mE1, dat), level = .95)
e1_est <- ctE1$beta[1]; e1_se <- ctE1$SE[1]
e1_df  <- (ctE1$df_Satt %||% ctE1$df)[1]
stopifnot(near0(c(e1_est, e1_se, e1_df, ciE1$CI_L[1], ciE1$CI_U[1]),
                unname(A_T1A1), 1e-6))                 # refit identity [F65]
domE1 <- list(all_es = N_SET, all_st = N_SET_ST, all_cl = N_SET_CL)
rows <- c(rows, list(
  row_base("E1", "tost_pooled", "pooled_mean", "Fisher_z",
           k_es = N_SET, k_study = N_SET_ST, k_cluster = N_SET_CL,
           est_z = e1_est, se_z = e1_se, t_stat = ctE1$tstat[1],
           df = e1_df, p = (ctE1$p_Satt %||% ctE1$p)[1],
           ci_lb_z = ciE1$CI_L[1], ci_ub_z = ciE1$CI_U[1],
           est_r = tanh(e1_est), ci_lb_r = tanh(ciE1$CI_L[1]),
           ci_ub_r = tanh(ciE1$CI_U[1]), sigma2 = mE1$sigma2,
           note = paste0(nE1, "; TH-a refit of T1/A1; verifier identity vs committed output/T1_results.csv at 1e-6 [F65]; 95% CI on this row (TOST rows carry 90%)"))),
  list(tost_row("E1", "tost_pooled", "tost_band_0.070",
           e1_est, e1_se, e1_df, BAND_E1_PRIMARY,
           sprintf("PRIMARY level band |r| = 0.070 (F27v2) -> z band atanh = %.9f", BAND_E1_PRIMARY),
           domE1, mE1$sigma2, ms = TRUE, ms_label = "e1_tost_primary",
           extra_note = "ex-ante expectation [DEC-044/DEC-045]: this arm is expected to FAIL (T1 CI edge -0.086); E2 adjudicates Tier 1; E1 calibrates the Tier-2 wording only")),
  list(tost_row("E1", "tost_pooled", "tost_band_0.050",
           e1_est, e1_se, e1_df, BAND_E1_SECONDARY,
           sprintf("SECONDARY level band |r| = 0.05 -> z band atanh = %.9f", BAND_E1_SECONDARY),
           domE1, mE1$sigma2)))

# ------------------------------ 5. E2 — TOST Paris contrast -----------
nE2 <- mnote("~ 0 + pp_cell (cell-means; estimand identical to ~ pp_mid_lag0)",
             sprintf("period domain %d/%d/%d [DEC-042b]", N_SUB, N_SUB_ST, N_SUB_CL))
cmE2 <- cellmeans(sub, sub$pp_mid_lag0, "E2_paris (T2/B1 refit)")
stopifnot(near0(cmE2$pre$est, A_T2B1_PRE, 1e-6),
          near0(c(cmE2$diff$est, cmE2$diff$se, cmE2$diff$df, cmE2$diff$p),
                unname(A_T2B1_DIFF), 1e-6))            # refit identity [F65]
domE2 <- list(pre_es = sum(!p16), pre_st = length(unique(sub$study[!p16])),
              pre_cl = length(unique(sub$cluster_id[!p16])),
              post_es = unname(POST16["es"]), post_st = unname(POST16["st"]),
              post_cl = unname(POST16["cl"]),
              all_es = N_SUB, all_st = N_SUB_ST, all_cl = N_SUB_CL)
rows <- c(rows, cm_rows(cmE2, "E2", "tost_paris", nE2, domE2,
  diff_note = "TH-a refit of T2/B1 paris_mid; verifier identity vs committed output/T2_results.csv at 1e-6 [F65]"))
rows <- c(rows, list(tost_row("E2", "tost_paris", "tost_band_0.050",
  cmE2$diff$est, cmE2$diff$se, cmE2$diff$df, BAND_E2,
  "contrast band |dr| = 0.05 (secondary SESOI = the contrast band [DEC-031 Block E]); applied on the z-difference directly; |dz| read as |dr| (third-order approx, T8/B8 convention)",
  domE2, cmE2$m$sigma2, ms = TRUE, ms_label = "e2_tost_contrast",
  extra_note = "E2 adjudicates Tier 1 (the Paris null) [DEC-045 E-pins]; dose transfer NOT triggered (design df 31.9 [DEC-024/A.3])")))

# ------------------------------ 6. E3 — gate configuration ------------
rows <- c(rows, list(
  row_base("E3", "gate", "config_e2_requirement", "count",
           estimator = "descriptive", rho = NA_real_,
           note = "Tier-1 evidence-of-absence wording REQUIRES an E2 PASS; E2 FAIL -> no Tier-1 EoA regardless of BF [DEC-045 ladder / H-Q21]"),
  row_base("E3", "gate", "config_bf_ladder", "count",
           estimator = "descriptive", rho = NA_real_,
           note = "with H2b: BF01 >= 3 full EoA; 1 < BF01 < 3 equivalence-based, BF disclosed as directionally supportive, not strong; BF01 <= 1 conflict disclosure, conservative wording; without RoBMA.reg: pre-registered configuration E2 + level BF (H2a) [DEC-045; Jeffreys/Lee-Wagenmakers bands pinned]"),
  row_base("E3", "gate", "status", "count",
           estimator = "descriptive", rho = NA_real_,
           note = "resolution deferred: documented post-run step after TH-b (N3), never an automatic rewrite [DEC-044/DEC-045]; ex-ante expectation carried on the E1 primary-band row")))

# ------------------------------ 7. H4 — sup-break point estimates -----
h4_t <- c(); h4_df <- c(); h4_rows <- list()
for (Y in H4_YEARS) {
  codY <- as.integer(share_y(sub, Y) >= 0.5)
  kA <- sum(codY == 1); kS <- length(unique(sub$study[codY == 1]))
  kC <- length(unique(sub$cluster_id[codY == 1]))
  nY <- mnote(sprintf("~ 0 + pp_cell (break %d, cell-means)", Y),
              sprintf("period domain %d/%d/%d", N_SUB, N_SUB_ST, N_SUB_CL))
  cmY <- cellmeans(sub, codY, sprintf("H4_break_%d", Y))
  h4_t[as.character(Y)]  <- abs(cmY$diff$t)
  h4_df[as.character(Y)] <- cmY$diff$df
  h4_rows[[length(h4_rows) + 1L]] <- row_base(
    "H4", sprintf("break_%d", Y), "break", "Fisher_z",
    k_es = N_SUB, k_study = N_SUB_ST, k_cluster = N_SUB_CL,
    est_z = cmY$diff$est, se_z = cmY$diff$se, t_stat = cmY$diff$t,
    df = cmY$diff$df, p = cmY$diff$p,
    ci_lb_z = cmY$diff$lb, ci_ub_z = cmY$diff$ub, sigma2 = cmY$m$sigma2,
    note = paste0(nY, sprintf(
      "; post cell: %d ES / %d studies / %d clusters; rule: share_%d >= 0.5, ties to Post [F60/DEC-024]; candidate year of the sup-break grid [DEC-045/H-Q6]; difference of Fisher-z means",
      kA, kS, kC, Y)))
}
rows <- c(rows, h4_rows)
adm <- names(h4_df)[is.finite(h4_df) & h4_df >= H4_DF_MIN]
sup_obs <- max(h4_t[adm]); sup_year <- adm[which.max(h4_t[adm])]
rows <- c(rows, list(row_base(
  "H4", "sup_break", "observed_sup", "rank",
  k_es = N_SUB, k_study = N_SUB_ST, k_cluster = N_SUB_CL,
  value = sup_obs, ms_input = TRUE, ms_label = "h4_sup_observed",
  note = sprintf(
    "sup |t| over the ADMISSIBLE candidate years (df >= %d on the break coefficient [DEC-024 transfer rule / H-Q6]); attained at %s; admissible set computed ONCE on the observed design and held fixed for the TH-c permutation [H-Q20]; |t| by year: %s; p_perm from TH-c",
    H4_DF_MIN, sup_year,
    paste(sprintf("%s=%.4f(df %.1f)", names(h4_t), h4_t, h4_df),
          collapse = ", ")))))

# ------------------------------ 8. H6 — Zarea transplantation ---------
tie <- sub$sample_mid == KNOT
stopifnot(sum(tie) == TIE_PIN["es"],
          length(unique(sub$study[tie]))     == TIE_PIN["st"],
          length(unique(sub$cluster_id[tie])) == TIE_PIN["cl"])
subZ <- sub[!tie, , drop = FALSE]
pZ <- subZ$pp_mid_lag0 == 1
domZ <- list(pre_es = sum(!pZ), pre_st = length(unique(subZ$study[!pZ])),
             pre_cl = length(unique(subZ$cluster_id[!pZ])),
             post_es = sum(pZ), post_st = length(unique(subZ$study[pZ])),
             post_cl = length(unique(subZ$cluster_id[pZ])),
             all_es = nrow(subZ), all_st = length(unique(subZ$study)),
             all_cl = length(unique(subZ$cluster_id)))
nZ <- mnote("~ 0 + pp_cell (midpoint rule, ties EXCLUDED)",
            sprintf("tie-excluded domain %d/%d/%d (79 tie ES / 5 studies / 5 clusters at sample_mid = 2015.5 removed [DEC-045/H-Q8])",
                    domZ$all_es, domZ$all_st, domZ$all_cl))
cmZ <- cellmeans(subZ, subZ$pp_mid_lag0, "H6_zarea_transplant")
zr <- cm_rows(cmZ, "H6", "zarea_transplant", nZ, domZ,
  diff_note = "under Zarea's Paris operationalization (midpoint + tie-exclusion), applied within our 3L-RVE framework [DEC-045 wording pin]; post cell 31 -> 26 studies under the tie-exclusion rule",
  ms = TRUE, ms_label = "h6_zarea_diff")
rows <- c(rows, zr)

# ------------------------------ 9. H7 — cumulative MA (113 steps) -----
med  <- tapply(sub$sample_mid, sub$study, stats::median)
ordS <- names(med)[order(med, names(med), method = "radix")]
stopifnot(length(ordS) == H7_STEPS)
s2c  <- tapply(as.character(sub$cluster_id), sub$study, function(x) x[1])
h7_rows <- vector("list", H7_STEPS)
floor_step <- NA_integer_; cum_cl <- character(0)
for (s in seq_len(H7_STEPS)) {
  cum_studies <- ordS[seq_len(s)]
  d <- sub[sub$study %in% cum_studies, , drop = FALSE]
  kC <- length(unique(d$cluster_id))
  if (is.na(floor_step) && kC >= H7_FLOOR_K) floor_step <- s
  h7_rows[[s]] <- tryCatch({
    # [runtime fix 2026-07-24] guard extended over the ENTIRE step body:
    # the ruled robustness fix ("no hard stop at single-cluster steps")
    # covered only fit3l; vcovCR requires >= 2 clusters, so at step 001
    # the fit converged and the CR2 step aborted the run. Any failure in
    # fit OR CR2/Satterthwaite now folds into the not_estimable path.
    mS <- fit3l(~ 1, d, sprintf("H7_step_%03d (+ %s)", s, ordS[s]))
    ct <- coef_test(mS, vcov = vcr(mS, d), test = "Satterthwaite")
    ci <- conf_int(mS, vcov = vcr(mS, d), level = .95)
    flg <- if (kC < H7_FLOOR_K)
      sprintf("display floor: point-only in the figure (clusters = %d < %d) [DEC-045/H-Q17; presentational only, CI retained here]", kC, H7_FLOOR_K)
    else "full display (CI band)"
    row_base(
      "H7", "cumulative", sprintf("step_%03d", s), "Fisher_z",
      subset = ordS[s],
      k_es = nrow(d), k_study = s, k_cluster = kC,
      est_z = ct$beta[1], se_z = ct$SE[1], t_stat = ct$tstat[1],
      df = (ct$df_Satt %||% ct$df)[1], p = (ct$p_Satt %||% ct$p)[1],
      ci_lb_z = ci$CI_L[1], ci_ub_z = ci$CI_U[1],
      est_r = tanh(ct$beta[1]), ci_lb_r = tanh(ci$CI_L[1]),
      ci_ub_r = tanh(ci$CI_U[1]), sigma2 = mS$sigma2,
      note = paste0(
        sprintf("cumulative 3L refit after adding study '%s' (median sample_mid = %.2f); ordering: study-wise median sample_mid, ties alphabetical [DEC-045/H-Q17]; ",
                ordS[s], med[[ordS[s]]]), flg))
  }, error = function(e) row_base(
    "H7", "cumulative", sprintf("step_%03d", s), "Fisher_z",
    subset = ordS[s],
    k_es = nrow(d), k_study = s, k_cluster = kC,
    note = paste0(
      sprintf("cumulative 3L refit after adding study '%s' (median sample_mid = %.2f); ordering: study-wise median sample_mid, ties alphabetical [DEC-045/H-Q17]; ",
              ordS[s], med[[ordS[s]]]),
      sprintf("not_estimable: %s; planned key retained (budget 177) [DEC-045; package-review robustness fix 2026-07-22 + runtime fix 2026-07-24]",
              conditionMessage(e)))))
}
rows <- c(rows, h7_rows)
stopifnot(nrow(sub[sub$study %in% ordS, ]) == N_SUB)

# ------------------------------ 10. H8 — rolling window ---------------
for (s0 in H8_STARTS) {
  w <- sub$sample_mid >= s0 & sub$sample_mid < s0 + H8_WIDTH
  d <- sub[w, , drop = FALSE]
  kC <- length(unique(d$cluster_id)); kS <- length(unique(d$study))
  lab <- sprintf("%d-%d", s0, s0 + H8_WIDTH - 1L)
  if (kC < 5L) {
    rows <- c(rows, list(row_base(
      "H8", "rolling", "window_mean", "Fisher_z", subset = lab,
      k_es = nrow(d), k_study = kS, k_cluster = kC,
      note = sprintf("not_estimable: %d clusters < 5 [DEC-045 S6 tier]; window [%d, %d); no fit attempted",
                     kC, s0, s0 + H8_WIDTH))))
    next
  }
  mW <- fit3l(~ 1, d, sprintf("H8_window_%s", lab))
  ct <- coef_test(mW, vcov = vcr(mW, d), test = "Satterthwaite")
  ci <- conf_int(mW, vcov = vcr(mW, d), level = .95)
  if (kC < 10L) {
    rows <- c(rows, list(row_base(
      "H8", "rolling", "window_mean", "Fisher_z", subset = lab,
      k_es = nrow(d), k_study = kS, k_cluster = kC,
      est_z = ct$beta[1], est_r = tanh(ct$beta[1]), sigma2 = mW$sigma2,
      note = sprintf("descriptive tier (5-9 clusters: %d) [DEC-045 S6]: estimate only; se/CI/p suppressed by rule; window [%d, %d) on sample_mid",
                     kC, s0, s0 + H8_WIDTH))))
  } else {
    rows <- c(rows, list(row_base(
      "H8", "rolling", "window_mean", "Fisher_z", subset = lab,
      k_es = nrow(d), k_study = kS, k_cluster = kC,
      est_z = ct$beta[1], se_z = ct$SE[1], t_stat = ct$tstat[1],
      df = (ct$df_Satt %||% ct$df)[1], p = (ct$p_Satt %||% ct$p)[1],
      ci_lb_z = ci$CI_L[1], ci_ub_z = ci$CI_U[1],
      est_r = tanh(ct$beta[1]), ci_lb_r = tanh(ci$CI_L[1]),
      ci_ub_r = tanh(ci$CI_U[1]), sigma2 = mW$sigma2,
      note = sprintf("full-inference tier (>= 10 clusters: %d) [DEC-045 S6]; window [%d, %d) on sample_mid; width 6 y, step 1 y, anchor 1998",
                     kC, s0, s0 + H8_WIDTH))))
  }
}

# ------------------------------ 11. H9 — external comparison ----------
rows <- c(rows, list(
  row_base("H9", "external_size", "own_pooled", "Fisher_z",
           estimator = "descriptive",
           k_es = N_SET, k_study = N_SET_ST, k_cluster = N_SET_CL,
           est_z = e1_est, est_r = tanh(e1_est),
           ci_lb_r = tanh(ciE1$CI_L[1]), ci_ub_r = tanh(ciE1$CI_U[1]),
           note = "debt-side pooled mean (E1 refit of T1/A1); descriptive channel-level size comparison, NO formal z-test [DEC-045/H-Q9; N12 scope shift disclosed]"),
  row_base("H9", "external_size", "coe_study_level", "Fisher_z",
           estimator = "descriptive", rho = NA_real_,
           k_study = 75L,
           est_r = unname(COE_STUDY_LEVEL["r"]),
           ci_lb_r = unname(COE_STUDY_LEVEL["lb"]),
           ci_ub_r = unname(COE_STUDY_LEVEL["ub"]),
           note = sprintf(
             "COE companion STUDY-LEVEL row (Table 3, 75 units; NOT the ES-level %.3f figure); SE provenance disclosure: COE main model = naive inverse variance at ES level, k = 1,139, no cluster-robust inference; overlap disclosure: 7/120 corpus, 6/115 estimation set, 5/113 period domain; 60/2,713 est ES (2.2%%); 0 shared effect sizes [DEC-045/H-Q10]",
             unname(COE_ES_LEVEL["r"])))))

# ------------------------------ 12. H10 — p-curve (conditional) -------
post_first <- sub[p16, , drop = FALSE]
post_first <- post_first[!duplicated(post_first$study), , drop = FALSE]  # first-reported (dat_prep row order)
stopifnot(nrow(post_first) == POST16["st"])
z_i <- abs(post_first$zi) / sqrt(post_first$vi)
p_i <- 2 * stats::pnorm(-z_i)
k_sig <- sum(p_i < H10_ALPHA)
sig <- p_i < H10_ALPHA
h10_note_base <- sprintf(
  "N13 rule [Annex H/DEC-045]: conditional on >= %d significant study-level post-cell p; selection = first-reported ES per post study (dat_prep row order); p reconstructed as 2*pnorm(-|zi|/sqrt(vi)) (z-metric; converted-r accuracy caveat)",
  H10_KMIN)
rows <- c(rows, list(row_base(
  "H10", "pcurve", "count_significant", "count",
  estimator = "descriptive",
  k_es = nrow(post_first), k_study = unname(POST16["st"]),
  k_cluster = unname(POST16["cl"]),
  value = k_sig, note = h10_note_base)))
if (k_sig >= H10_KMIN) {
  zs   <- z_i[sig]; ps <- p_i[sig]
  pp   <- pmin(pmax(ps / H10_ALPHA, 1e-12), 1 - 1e-12)
  z_rs <- sum(stats::qnorm(pp)) / sqrt(k_sig)
  p_rs <- stats::pnorm(z_rs)
  x25  <- sum(ps < H10_ALPHA / 2)
  p_bin <- 1 - stats::pbinom(x25 - 1L, k_sig, 0.5)
  pp33_raw <- (1 - stats::pnorm(zs - NCP_33)) / (1/3)
  n_clip_hi <- sum(pp33_raw >= 1 - 1e-12)
  n_clip_lo <- sum(pp33_raw <= 1e-12)
  pp33 <- pmin(pmax(pp33_raw, 1e-12), 1 - 1e-12)
  z_33 <- sum(stats::qnorm(pp33)) / sqrt(k_sig)
  p_33 <- 1 - stats::pnorm(z_33)
  rows <- c(rows, list(
    row_base("H10", "pcurve", "right_skew_binomial", "count",
             estimator = "descriptive", k_study = k_sig,
             value = p_bin,
             note = paste0(h10_note_base, sprintf("; share of significant p < .025: %d/%d; one-sided binomial vs 0.5 [Simonsohn et al. 2014]", x25, k_sig))),
    row_base("H10", "pcurve", "right_skew_stouffer", "count",
             estimator = "descriptive", k_study = k_sig,
             value = p_rs,
             note = paste0(h10_note_base, sprintf("; Stouffer z on pp = p/.05: z = %.4f; right-skew p = pnorm(z)", z_rs))),
    row_base("H10", "pcurve", "flatness_vs_33", "count",
             estimator = "descriptive", k_study = k_sig,
             value = p_33,
             note = paste0(h10_note_base, sprintf("; NCP_33 = %.9f (= qnorm(.975) - qnorm(2/3)); Stouffer z on pp33: z = %.4f; flatter-than-33%% p = 1 - pnorm(z); pp33 clip share (upper/lower) = %d/%d of %d", NCP_33, z_33, n_clip_hi, n_clip_lo, k_sig)))))
} else {
  for (tm in c("right_skew_binomial", "right_skew_stouffer", "flatness_vs_33")) {
    rows <- c(rows, list(row_base(
      "H10", "pcurve", tm, "count", estimator = "descriptive",
      k_study = k_sig,
      note = paste0(h10_note_base, sprintf(
        "; not_estimable: infeasible (k_sig = %d < %d) — reported as pinned [N13]", k_sig, H10_KMIN),
        if (tm == "flatness_vs_33")
          sprintf("; NCP_33 = %.9f (= qnorm(.975) - qnorm(2/3); constant echoed for the verifier)", NCP_33)
        else ""))))
  }
}

# ------------------------------ 13. H11 — within-study display --------
li <- sub[sub$study == "Li et al (2022)", , drop = FALSE]
li_pre <- li$zi[li$pp_mid_lag0 == 0]; li_post <- li$zi[li$pp_mid_lag0 == 1]
stopifnot(nrow(li) == 17L, length(li_pre) == 12L, length(li_post) == 5L)
both_cells <- names(which(tapply(sub$pp_mid_lag0, sub$study,
                                 function(x) min(x) == 0 && max(x) == 1)))
stopifnot(identical(both_cells, "Li et al (2022)"))
h11_note <- "N15 within-study display: descriptive only, explicitly NO p-values (single both-period cluster) [DEC-045/H-Q11; DEC-008 partial reopen]; unweighted mean of Fisher-z within cell; value = SD"
rows <- c(rows, list(
  row_base("H11", "within_study", "pre_mean", "Fisher_z",
           subset = "Li et al (2022)", estimator = "descriptive",
           k_es = 12L, k_study = 1L, k_cluster = 1L,
           est_z = mean(li_pre), est_r = tanh(mean(li_pre)),
           value = stats::sd(li_pre), note = h11_note),
  row_base("H11", "within_study", "post_mean", "Fisher_z",
           subset = "Li et al (2022)", estimator = "descriptive",
           k_es = 5L, k_study = 1L, k_cluster = 1L,
           est_z = mean(li_post), est_r = tanh(mean(li_post)),
           value = stats::sd(li_post), note = h11_note),
  row_base("H11", "within_study", "within_diff", "Fisher_z",
           subset = "Li et al (2022)", estimator = "descriptive",
           k_es = 17L, k_study = 1L, k_cluster = 1L,
           est_z = mean(li_post) - mean(li_pre),
           note = paste0(h11_note, "; post-minus-pre difference of unweighted cell means; z-only, no CI/p by rule"))))

# ------------------------------ 14. Design rows -----------------------
wc <- as.character(dat$pp_window_class)
straddle <- sum(tapply(wc, dat$study, function(x) any(x == "mixed", na.rm = TRUE)))
rows <- c(rows, list(
  design_row("h6_tie_inventory", "count", value = unname(TIE_PIN["es"]),
             note = sprintf("tie ES at sample_mid = 2015.5: %d ES / %d studies / %d clusters (Ho & Wong 2023; Kordschia 2020; Owolabi et al 2024; Ririmasse et al 2026; Xiang & Gong 2026); post cell 31 -> 26 studies under the Zarea tie-exclusion rule [DEC-045/H-Q8]",
                            TIE_PIN["es"], TIE_PIN["st"], TIE_PIN["cl"])),
  design_row("h4_admissible_years", "count", value = length(adm),
             note = sprintf("candidate years with break-coefficient Satterthwaite df >= %d, computed ONCE on the observed design and held fixed for the TH-c permutation [DEC-045/H-Q6/H-Q20]: %s",
                            H4_DF_MIN, paste(adm, collapse = ", "))),
  design_row("h7_floor_step", "count", value = floor_step,
             note = sprintf("first cumulative step with >= %d clusters (CI band from here; steps 1-%d point-only in the figure) [DEC-045/H-Q17]; floor study = '%s'",
                            H7_FLOOR_K, floor_step - 1L, ordS[floor_step])),
  design_row("h7_order_head", "count", value = NA_real_,
             note = sprintf("ordering: study-wise median sample_mid, ties alphabetical; first 5: %s",
                            paste(sprintf("%s (%.2f)", ordS[1:5], med[ordS[1:5]]),
                                  collapse = "; "))),
  design_row("h8_window_anchor", "year", value = H8_ANCHOR,
             note = sprintf("derived design constant: min sample_mid = %.1f -> anchor %d; width %d y, step %d y -> %d windows [DEC-045 S6]",
                            min(sub$sample_mid), H8_ANCHOR, H8_WIDTH, H8_STEP,
                            length(H8_STARTS))),
  design_row("h10_selection_rule", "count", value = NA_real_,
             note = "first-reported ES per post study = first occurrence in dat_prep row order (pinned) [DEC-045/N13]"),
  design_row("h11_straddle_studies", "count", value = straddle,
             note = "studies with any pp_window_class == 'mixed' on the estimation set (straddle the break) [DEC-045/H-Q11]"),
  design_row("h11_pool_across", "count", value = straddle - 1L,
             note = "straddling studies minus the single within-split study (Li et al 2022) = studies that pool across the break ('Paris blindness' introduction module)")))

# ------------------------------ 15. Assemble + write ------------------
res <- do.call(rbind, rows)
stopifnot(identical(names(res), SCHEMA))
if (nrow(res) != N_ROWS_A) {
  print(table(res$analysis_id, res$spec))
  stop(sprintf("ROW BUDGET MISMATCH: got %d, expected %d — see block table above.",
               nrow(res), N_ROWS_A))
}
key <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "||")
stopifnot(!anyDuplicated(key))
stopifnot(!any(grepl("^bp_", res$term)))                # P-T5-5 absence

dir.create(here("output"), showWarnings = FALSE)
write_csv(res, here("output", "TH_a_results.csv"), na = "")
meta <- c(
  sprintf("TH-a run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("dat_prep md5:  %s",
          unname(tools::md5sum(here("output", "dat_prep.rds")))),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("domains: E1 = %d/%d/%d [DEC-042a]; E2/H = %d/%d/%d [DEC-042b]",
          N_SET, N_SET_ST, N_SET_CL, N_SUB, N_SUB_ST, N_SUB_CL),
  "anchor gates PASSED: committed T1/A1 + T1/A2 + T2/B1 value-matched at 1e-9 (embedded constants); TH-a refits identity at 1e-6 [F65]",
  sprintf("TOST bands: E1 z = atanh(0.070) = %.9f primary / atanh(0.05) = %.9f secondary; E2 z-difference band = %.3f (|dz| read as |dr|, third-order approx) [DEC-045 E-pins]",
          BAND_E1_PRIMARY, BAND_E1_SECONDARY, BAND_E2),
  sprintf("H4 admissible years (df >= %d, observed design, fixed for TH-c): %s",
          H4_DF_MIN, paste(adm, collapse = ", ")),
  sprintf("H4 observed sup |t| = %.6f at %s", sup_obs, sup_year),
  sprintf("H6 tie exclusion: %d ES / %d studies / %d clusters at mid = 2015.5; domain %d/%d/%d",
          TIE_PIN["es"], TIE_PIN["st"], TIE_PIN["cl"],
          domZ$all_es, domZ$all_st, domZ$all_cl),
  sprintf("H7: %d steps; floor step = %d ('%s'); ordering = study-median sample_mid, ties alphabetical",
          H7_STEPS, floor_step, ordS[floor_step]),
  sprintf("H8: anchor %d, %d windows; tiers <5 not_estimable / 5-9 descriptive / >=10 full [S6]",
          H8_ANCHOR, length(H8_STARTS)),
  sprintf("H10: k_sig = %d (rule >= %d); branch = %s; NCP_33 = %.9f", k_sig,
          H10_KMIN,
          if (k_sig >= H10_KMIN) "tests computed" else "infeasible rows",
          NCP_33),
  "H11: Li et al (2022) 17 ES = 12 pre / 5 post (asserted); straddle per design rows",
  "E3: gate configuration written; RESOLUTION deferred to the documented post-run step [DEC-044/DEC-045]",
  sprintf("Convergence certificates (%d fits):", length(FIT_LOG)),
  paste0("  ", FIT_LOG),
  "", "sessionInfo():", utils::capture.output(utils::sessionInfo()))
writeLines(meta, here("output", "TH_a_run_meta.txt"))
cat(sprintf("TH-a written: %d rows x %d cols -> output/TH_a_results.csv\n",
            nrow(res), ncol(res)))
cat("Input-contract + anchor asserts: ALL PASSED (see paired verifier).\n")
