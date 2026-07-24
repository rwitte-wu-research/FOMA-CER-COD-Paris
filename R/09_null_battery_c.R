# =====================================================================
# R/09_null_battery_c.R — TH-c: H1 (MDE precompute stream + REML
#   calibration), H3 (1,260-cell multiverse curve + 10-cell core joint
#   permutation), H5 + H4 (cluster-level TIME-TRANSLATION permutation,
#   B = 500, 23 ladder fits per replicate in ONE pass).
# FOMA CER–COD–Paris | verifier-paired | overnight run (~13–15 h @ W=11)
# ---------------------------------------------------------------------
# Authority: DEC-045 (as amended 2026-07-22: clean_window enumeration,
#   delta grid, rstudent THRESHOLD = 3, winsor P1/P99, vi_k10/k20 direct
#   consumption via the vi-internal identity, ES_measure) · DEC-031e/f ·
#   DEC-042a/b · A.13 · H-Q14/15/16/18/20 + R1–R3 (Master v2) ·
#   F65 anchors · TH-a design row h4_admissible_years (cross-run).
# Determinism: PERMS (500 cluster permutations) generated FIRST under
#   seed 20260710, saved to output/TH_c_perms.rds (md5 in run_meta);
#   workers receive replicate indices — scheduling-invariant (W = 1 or
#   11); Windows CRAN reference BLAS is single-threaded, env guards set
#   defensively per worker. Execution order pinned: PERMS -> rstudent/
#   winsor masks -> H1 stream -> H1 calibration -> permutation pass ->
#   H3 curve. FIT_LOG: named fits logged individually; simulation /
#   permutation fits logged as COUNTERS (rung usage, fallbacks,
#   failures) — 11,700+ certificate lines would be unreadable.
# H1 delta mechanics: with fixed variance components the noise stream
#   (b, SE_CR2, df) is delta-invariant; delta enters analytically as a
#   noncentral shift of the contrast estimate — one B = 5,000 stream per
#   scenario serves the whole 9-point grid (documented; exact, not an
#   approximation).
# OPC estimator pin (H3): aggregates are formed at CLUSTER x CELL level
#   (metafor aggregate.escalc, struct = "CS", per-cell rho), mirroring
#   the D2 / H2b cluster-x-period convention; diff via rma cell-means
#   (test = "t"). UWLS+3 cells: weighted LS cell means (weights 1/vi),
#   classic t on the difference — descriptive curve only; all H3
#   inference lives in the 10-cell 3L core permutation [DEC-045 S3].
# Output: output/TH_c_results.csv (36-col T2 schema; N_ROWS_C = 1,347),
#   output/TH_c_run_meta.txt, output/TH_c_perms.rds.
# Result framing: NONE.
# ---------------------------------------------------------------------
# Row budget (auditable):
#   10 design + 68 H1 (6 x [9 power + mde80 + mde90] + 2 calibration)
# + 1,265 H3 (1,260 cells + 2 observed core stats + 2 p_perm + 1 eff_B)
# + 2 H5 (p_perm_race + eff_B) + 2 H4 (p_perm_sup + eff_B) = 1,347.
# =====================================================================

suppressPackageStartupMessages({
  library(metafor)
  library(clubSandwich)
  library(here)
  library(readr)
  library(parallel)
  library(Matrix)
})

# ------------------------------ 0. Constants (FROZEN ZONE) ------------
RHO   <- 0.6; RHO_GRID <- c(0.4, 0.6, 0.8)             # DEC-017 / H3 grid
KNOT  <- 2015.5
SEED  <- 20260710L
N_SET <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L      # DEC-042a
N_SUB <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L      # DEC-042b
B_PERM <- 500L                                          # S5 (rule fired)
B_H1   <- 5000L                                         # N2 (R1 stream)
N_CAL  <- 200L                                          # H-Q14 calibration
DELTA_GRID <- seq(0, 0.08, by = 0.01)                   # DEC-045 (z-scale)
W_TARGET <- 11L                                         # benchmark pin
H4_YEARS <- 2008:2019; H4_DF_MIN <- 5
RSTUDENT_THR <- 3                                        # DEC-045 amendment
WINSOR_Q <- c(0.01, 0.99)
FAIL_MAX_SHARE <- 0.01                                   # verifier FAIL above
CODINGS <- c("paris_mid", "tie_break_median", "end_any_exposure",
             "share_recut_2017", "share_recut_2018", "share_recut_2019",
             "end_lag1", "end_lag2", "end_lag3", "clean_window")
OUTLIERS <- c("none", "rstudent", "winsor")
ES_SETS  <- c("full", "no_starbound")
DF_BASES <- c("dfE", "k10", "k20")
ESTIMATORS <- c("3LMA-RVE_CR2", "one_per_cluster", "UWLS3")

# F65 embedded anchors
A_T8_RACE <- c(est = 0.026448035562024352, se = 0.025130655338122518,
               df = 18.84196672031063,     p  = 0.3059167280532321)
A_T1A2 <- c(cl = 0.0197455486661123, st = 1.02092128749543e-09,
            es = 0.0118831792865472)
SIGMA_COE <- 0.083 / 3.92               # DEC-031b PI-derived; tau2 = ^2

N_ROWS_C <- 1347L
SUBSET_LAB <- "defined"

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

`%||%` <- function(a, b) if (is.null(a)) b else a
near0 <- function(a, b, tol) all(is.finite(a) & is.finite(b)) &&
  all(abs(a - b) <= tol)

# ------------------------------ 1. Load + input contract --------------
pr <- readRDS(here("output", "dat_prep.rds"))
stopifnot(is.list(pr), !is.null(pr$dat), pr$n == N_SET, pr$seed == SEED)
dat <- pr$dat
need <- c("zi","vi","vi_k10","vi_k20","ES_measure","cluster_id",
          "study","esid","sample_mid","sample_mid_c","sample_median",
          "pp_mid_lag0","pp_median_lag0","pp_end_lag0","pp_end_lag1",
          "pp_end_lag2","pp_end_lag3","share_2016","share_2017",
          "share_2018","share_2019","pp_window_class","flag_starbound",
          "d_sample_start","d_sample_end")
miss <- setdiff(need, names(dat))
if (length(miss)) stop("SCHEMA HARD STOP — missing columns: ",
                       paste(miss, collapse = ", "))
stopifnot(nrow(dat) == N_SET,
          length(unique(dat$study)) == N_SET_ST,
          length(unique(dat$cluster_id)) == N_SET_CL,
          all(dat$vi > 0))

# PCC flag + vi_k identity gates [DEC-045 amendment]
esm <- factor(dat$ES_measure)
stopifnot(nlevels(esm) == 2)
biv_lvl <- levels(esm)[grepl("bivar", levels(esm), ignore.case = TRUE)]
stopifnot(length(biv_lvl) == 1)
is_pcc <- esm != biv_lvl
# [runtime fix 2026-07-24 #3, author-ruled] dat_prep$n_obs mirrors the RAW
# workbook extraction column (on PCC rows: 85x "FLAG", 156x NA, 2x
# spaced-text; where numeric it equals the clean firm-years basis
# exactly). The pinned identity therefore re-anchors vi-internally:
# under the F21 base convention vi = 1/(n - 3), the k-shift identity is
# algebraically vi_k10 = 1/(1/vi - 10) and vi_k20 = 1/(1/vi - 20) on
# PCC rows. No n column is consumed anywhere in TH-c; this validates
# the precomputed k-columns AND the base-vi convention at once.
# Author-verified on dat_prep before commit (max abs dev ~ 1e-15).
# Tiny-n edge (v12-verified): exactly one PCC row has n = 18 <= 23, so
# 1/(n - 23) is nonpositive there -- that row is excluded from the k20
# identity AND from every k20 cell (df_basis filter below), disclosed
# in the vi_k_identity design row. vi_k10 is strictly positive
# everywhere (min n = 18 > 13).
stopifnot(is.numeric(dat$vi), is.numeric(dat$vi_k10),
          is.numeric(dat$vi_k20),
          all(is.finite(dat$vi_k10) & dat$vi_k10 > 0))
k20_bad <- !is.finite(dat$vi_k20) | dat$vi_k20 <= 0
stopifnot(all(is_pcc[k20_bad]), sum(k20_bad) <= 3L)
ok20 <- is_pcc & !k20_bad
stopifnot(near0(dat$vi_k10[is_pcc], 1 / (1 / dat$vi[is_pcc] - 10), 1e-9),
          near0(dat$vi_k20[ok20],  1 / (1 / dat$vi[ok20]  - 20), 1e-9))
dat$k20_bad <- k20_bad
dat$vi_dfE <- dat$vi
dat$vi_k10 <- ifelse(is_pcc, dat$vi_k10, dat$vi)   # bivariate rows keep base
dat$vi_k20 <- ifelse(is_pcc, dat$vi_k20, dat$vi)

na_win <- is.na(dat$pp_mid_lag0)
sub <- dat[!na_win, , drop = FALSE]
stopifnot(nrow(sub) == N_SUB,
          length(unique(sub$study)) == N_SUB_ST,
          length(unique(sub$cluster_id)) == N_SUB_CL)
ctr <- unique(round(sub$sample_mid - sub$sample_mid_c, 9))
stopifnot(length(ctr) == 1); CENTER <- as.numeric(ctr)

# Canonical share_Y from windows [F60] — permutation re-derivation base
share_y_of <- function(dend, L, Y) pmin(pmax((dend - Y + 1) / L, 0), 1)
sub$winL <- sub$d_sample_end - sub$d_sample_start + 1
stopifnot(near0(share_y_of(sub$d_sample_end, sub$winL, 2016),
                sub$share_2016, 1e-9))

# ------------------------------ 2. Runtime anchors (F65) --------------
read_committed <- function(f) {
  p <- here("output", f)
  if (!file.exists(p)) stop("ANCHOR HARD STOP — committed file missing: ", f)
  read.csv(p, stringsAsFactors = FALSE)
}
t1 <- read_committed("T1_results.csv")
rA2 <- t1[t1$analysis_id == "A2" & t1$spec == "var_decomposition", ]
stopifnot(nrow(rA2) == 1,
          near0(c(rA2$sigma2_cluster, rA2$sigma2_study, rA2$sigma2_esid),
                unname(A_T1A2), 1e-9))
S2_OWN <- unname(A_T1A2)
t8 <- read_committed("T8_results.csv")
rRC <- t8[t8$analysis_id == "B4" & t8$spec == "race" &
            t8$term == "pp_mid_lag0", ]
stopifnot(nrow(rRC) == 1,
          near0(c(rRC$est_z, rRC$se_z, rRC$df, rRC$p),
                unname(A_T8_RACE), 1e-9))
tha <- read_committed("TH_a_results.csv")
rADM <- tha[tha$analysis_id == "TH_design" &
              tha$term == "h4_admissible_years", ]
stopifnot(nrow(rADM) == 1)

# ------------------------------ 3. Ladder fit machinery ---------------
FIT_LOG <- character(0)
LADDER_OPTS <- list(
  list(label = "nlminb",            control = list(optimizer = "nlminb")),
  list(label = "optim/BFGS",        control = list(optimizer = "optim",
                                                   optmethod = "BFGS")),
  list(label = "optim/Nelder-Mead", control = list(optimizer = "optim",
                                                   optmethod = "Nelder-Mead")))
fit3l_q <- function(fml, d, rho, vcol = "vi_dfE") {
  # quiet ladder core (workers/simulation): returns list(m, rung) or the
  # last error condition; caller decides logging vs counting
  V <- impute_covariance_matrix(vi = d[[vcol]], cluster = d$cluster_id,
                                r = rho)
  one <- function(ctrl) rma.mv(yi = zi, V = V, mods = fml,
                               random = ~ 1 | cluster_id/study/esid,
                               data = d, sparse = TRUE, method = "REML",
                               control = ctrl)
  last <- NULL
  for (k in seq_along(LADDER_OPTS)) {
    m <- tryCatch(one(LADDER_OPTS[[k]]$control), error = function(e) e)
    if (!inherits(m, "error")) return(list(m = m, rung = k))
    last <- m
  }
  last
}
fit3l <- function(fml, d, tag, rho = RHO, vcol = "vi_dfE") {
  out <- fit3l_q(fml, d, rho, vcol)
  if (inherits(out, "error"))
    stop("DEC-031f R5 STOP -- all ladder rungs failed for '", tag, "': ",
         conditionMessage(out))
  FIT_LOG <<- c(FIT_LOG, sprintf(
    "%s [k=%d] -- optimizer %s (ladder rung %d/3); converged (metafor-certified)%s [DEC-031f R2/R3; DEC-045 every-spine-fit pin]",
    tag, nrow(d), LADDER_OPTS[[out$rung]]$label, out$rung,
    if (out$rung > 1L) "; FALLBACK" else ""))
  out$m
}
vcr <- function(m, d) vcovCR(m, cluster = d$cluster_id, type = "CR2")
coef_idx <- function(ct, nm) {
  cn <- if (!is.null(ct$Coef)) as.character(ct$Coef) else rownames(ct)
  which(cn == nm)
}

cm_diff <- function(m, d) {
  lc <- linear_contrast(m, vcov = vcr(m, d),
                        contrasts = rbind(diff = c(-1, 1)), level = .95)
  dfd <- (lc$df %||% lc$df_Satt)[1]
  list(est = lc$Est[1], se = lc$SE[1], t = lc$Est[1] / lc$SE[1], df = dfd,
       p = 2 * stats::pt(-abs(lc$Est[1] / lc$SE[1]), df = dfd),
       lb = lc$CI_L[1], ub = lc$CI_U[1])
}

row_base <- function(analysis_id, spec, term, metric,
                     subset = SUBSET_LAB, estimator = "3LMA-RVE_CR2",
                     rho = RHO, k_es = NA_integer_, k_study = NA_integer_,
                     k_cluster = NA_integer_,
                     est_z = NA_real_, se_z = NA_real_, t_stat = NA_real_,
                     df = NA_real_, p = NA_real_,
                     ci_lb_z = NA_real_, ci_ub_z = NA_real_,
                     est_r = NA_real_, ci_lb_r = NA_real_,
                     ci_ub_r = NA_real_, sigma2 = NULL, value = NA_real_,
                     ms_input = FALSE, ms_label = NA_character_,
                     note = NA_character_) {
  data.frame(analysis_id = analysis_id, spec = spec, subset = subset,
             term = term, metric = metric, estimator = estimator, rho = rho,
             k_es = k_es, k_study = k_study, k_cluster = k_cluster,
             est_z = est_z, se_z = se_z, t_stat = t_stat, df = df, p = p,
             ci_lb_z = ci_lb_z, ci_ub_z = ci_ub_z,
             pi_lb_z = NA_real_, pi_ub_z = NA_real_,
             est_r = est_r, ci_lb_r = ci_lb_r, ci_ub_r = ci_ub_r,
             pi_lb_r = NA_real_, pi_ub_r = NA_real_,
             sigma2_cluster = if (!is.null(sigma2)) sigma2[1] else NA_real_,
             sigma2_study   = if (!is.null(sigma2)) sigma2[2] else NA_real_,
             sigma2_esid    = if (!is.null(sigma2)) sigma2[3] else NA_real_,
             pct_cluster = NA_real_, pct_study = NA_real_,
             pct_esid = NA_real_, pct_sampling = NA_real_,
             typical_v = NA_real_, value = value,
             ms_input = ms_input, ms_label = ms_label, note = note,
             stringsAsFactors = FALSE)
}
design_row <- function(term, metric, value = NA_real_, note = NA_character_)
  row_base("TH_design", "design", term, metric = metric,
           estimator = "descriptive", rho = NA_real_, value = value,
           note = note)

rows <- list()

# ------------------------------ 4. PERMS first (determinism pin) ------
set.seed(SEED)
CL_IDS <- sort(unique(as.character(sub$cluster_id)))
stopifnot(length(CL_IDS) == N_SUB_CL)
PERMS <- vapply(seq_len(B_PERM), function(b) sample.int(N_SUB_CL),
                integer(N_SUB_CL))                    # 112 x 500
saveRDS(PERMS, here("output", "TH_c_perms.rds"))
PERM_MD5 <- unname(tools::md5sum(here("output", "TH_c_perms.rds")))

# ------------------------------ 5. Fixed masks (rstudent / winsor) ----
mMask <- fit3l(~ 1, dat, "H3_mask_spine (full-set intercept, rho .6)")
mu0 <- as.numeric(mMask$beta[1, 1]); s2sum <- sum(mMask$sigma2)
res_std <- (dat$zi - mu0) / sqrt(dat$vi + s2sum)
MASK_OUT <- abs(res_std) > RSTUDENT_THR               # fixed row mask
WB <- stats::quantile(dat$zi, WINSOR_Q, type = 7, names = FALSE)
dat$zi_wins <- pmin(pmax(dat$zi, WB[1]), WB[2])
sub$zi_wins <- dat$zi_wins[!na_win]
sub$mask_out <- MASK_OUT[!na_win]
sub$is_pcc <- is_pcc[!na_win]

# ------------------------------ 6. H1 — precompute stream -------------
# Design: X = [1, pp_mid] on the period domain (E2/B1 contrast design).
h1_dom <- sub
clF <- factor(as.character(h1_dom$cluster_id), levels = CL_IDS)
clidx <- as.integer(clF)
X <- cbind(1, h1_dom$pp_mid_lag0)
scen_tab <- rbind(
  data.frame(fam = "own", mult = c(0.5, 1, 2)),
  data.frame(fam = "coe", mult = c(0.5, 1, 2)))
own_tot <- sum(S2_OWN); own_prop <- S2_OWN / own_tot
coe_tot <- SIGMA_COE^2

h1_stream <- function(s2vec, tag) {
  # per-cluster Sigma, Chol, GLS/CR2/Satt precompute (y-free), then the
  # B_H1 noise stream; returns list(df, b2, SE)
  C <- N_SUB_CL
  Xl <- split.data.frame(X, clidx)
  vil <- split(h1_dom$vi, clidx)
  stl <- split(as.character(h1_dom$study), clidx)
  Ll <- vector("list", C); Wl <- Xw <- vector("list", C)
  XtWX <- matrix(0, 2, 2)
  for (c in seq_len(C)) {
    v <- vil[[c]]; n <- length(v)
    Vs <- RHO * sqrt(v) %o% sqrt(v); diag(Vs) <- v          # sampling V
    Zst <- outer(stl[[c]], stl[[c]], "==") * s2vec[2]        # study RE
    Sig <- Vs + s2vec[1] + Zst + diag(s2vec[3], n)           # cluster RE
    Ll[[c]] <- t(chol(Sig))
    Wl[[c]] <- chol2inv(chol(Sig))
    Xw[[c]] <- crossprod(Xl[[c]], Wl[[c]])                   # 2 x n
    XtWX <- XtWX + Xw[[c]] %*% Xl[[c]]
  }
  M <- solve(XtWX)
  # CR2 adjustment + contrast vectors g_c (c = (0,1))
  gl <- vector("list", C); Smat <- matrix(0, 2, C)
  for (c in seq_len(C)) {
    Hc <- Xl[[c]] %*% M %*% Xw[[c]]                          # n x n
    Gc <- (diag(nrow(Hc)) - Hc)
    Phi <- Ll[[c]] %*% t(Ll[[c]])
    Ge <- Gc %*% Phi %*% t(Gc)
    ei <- eigen((Phi + t(Phi)) / 2, symmetric = TRUE)
    Ph <- ei$vectors %*% diag(sqrt(pmax(ei$values, 0)),
                              nrow(Hc)) %*% t(ei$vectors)
    Phin <- ei$vectors %*% diag(1 / sqrt(pmax(ei$values, 1e-14)),
                                nrow(Hc)) %*% t(ei$vectors)
    Bi <- Phin %*% Ge %*% Phin
    eb <- eigen((Bi + t(Bi)) / 2, symmetric = TRUE)
    Bh <- eb$vectors %*% diag(1 / sqrt(pmax(eb$values, 1e-14)),
                              nrow(Hc)) %*% t(eb$vectors)
    Ai <- Ph %*% Bh %*% Phin                                 # CR2 adjuster
    w2 <- M[2, , drop = FALSE] %*% Xw[[c]]                   # 1 x n
    gl[[c]] <- as.numeric(w2 %*% Ai)                         # via A_c'
    Smat[, c] <- crossprod(Xl[[c]], gl[[c]])
  }
  gvec <- numeric(nrow(X)); for (c in seq_len(C))
    gvec[clidx == c] <- gl[[c]]
  # Satterthwaite df (y-free): r_c = ghat_c - W X M X_c' g_c ; Lam = R' Omega R
  WX <- matrix(0, nrow(X), 2)
  for (c in seq_len(C)) WX[clidx == c, ] <- t(Xw[[c]])
  Rm <- matrix(0, nrow(X), C)
  for (c in seq_len(C)) {
    rc <- numeric(nrow(X)); rc[clidx == c] <- gl[[c]]
    rc <- rc - WX %*% (M %*% Smat[, c])
    Rm[, c] <- rc
  }
  OR <- matrix(0, nrow(X), C)
  for (c in seq_len(C)) {
    Phi <- Ll[[c]] %*% t(Ll[[c]])
    OR[clidx == c, ] <- Phi %*% Rm[clidx == c, , drop = FALSE]
  }
  Lam <- crossprod(Rm, OR)
  df_s <- sum(diag(Lam))^2 / sum(Lam^2)
  # noise stream
  Lb <- Matrix::bdiag(Ll)
  ordback <- order(order(clidx))
  E <- matrix(stats::rnorm(nrow(X) * B_H1), nrow(X), B_H1)
  Y0s <- as.matrix(Lb %*% E)                                 # cluster-sorted
  Y0 <- Y0s[ordback, , drop = FALSE]
  Pmat <- matrix(0, 2, nrow(X))
  for (c in seq_len(C)) Pmat[, clidx == c] <- M %*% Xw[[c]]
  Bhat <- Pmat %*% Y0                                        # 2 x B
  G1 <- rowsum(gvec * Y0, clidx)                             # C x B
  U <- G1 - t(Smat) %*% Bhat
  SE <- sqrt(colSums(U^2))
  FIT_LOG <<- c(FIT_LOG, sprintf(
    "H1 stream %s -- precompute OK (df_Satt = %.4f, y-free); B = %d matrix-vector replicates [H-Q14/R1]",
    tag, df_s, B_H1))
  list(df = df_s, b2 = as.numeric(Bhat[2, ]), SE = SE)
}

h1_scen_rows <- list(); mde_primary <- NA_real_
for (i in seq_len(nrow(scen_tab))) {
  fam <- scen_tab$fam[i]; mlt <- scen_tab$mult[i]
  s2v <- if (fam == "own") S2_OWN * mlt else own_prop * (coe_tot * mlt)
  lab <- sprintf("%s_x%.1f", fam, mlt)
  st <- h1_stream(s2v, lab)
  crit <- stats::qt(0.975, df = st$df)
  pw <- vapply(DELTA_GRID, function(d)
    mean(abs(d + st$b2) / st$SE > crit), numeric(1))
  interp <- function(target) {
    j <- which(pw >= target)[1]
    if (is.na(j)) return(NA_real_)
    if (j == 1L) return(DELTA_GRID[1])
    DELTA_GRID[j - 1] + (target - pw[j - 1]) / (pw[j] - pw[j - 1]) * 0.01
  }
  m80 <- interp(0.80); m90 <- interp(0.90)
  if (fam == "own" && mlt == 1) mde_primary <- m80
  nsc <- sprintf(
    "H1 scenario %s: fixed VC (cluster/study/esid) = %.6g/%.6g/%.6g%s; design X = [1, pp_mid] on 2,705/112; CR2/Satterthwaite two-sided alpha=.05, df precomputed y-free; delta enters as noncentral shift of one B=%d stream [DEC-045/H-Q14/R1]",
    lab, s2v[1], s2v[2], s2v[3],
    if (fam == "coe") sprintf(" (one-level lower bound: tau2_COE = (0.083/3.92)^2 x %.1f, allocated by T1/A2 proportions [S4])", mlt) else
      sprintf(" (= T1/A2 components x %.1f)", mlt), B_H1)
  for (j in seq_along(DELTA_GRID))
    h1_scen_rows[[length(h1_scen_rows) + 1L]] <- row_base(
      "H1", lab, sprintf("power_delta_%.2f", DELTA_GRID[j]), "count",
      k_es = N_SUB, k_cluster = N_SUB_CL, df = st$df,
      value = pw[j], note = nsc)
  h1_scen_rows[[length(h1_scen_rows) + 1L]] <- row_base(
    "H1", lab, "mde_power80", "Fisher_z",
    k_es = N_SUB, k_cluster = N_SUB_CL, df = st$df, value = m80,
    ms_input = (fam == "own" && mlt == 1),
    ms_label = if (fam == "own" && mlt == 1) "h1_mde_primary" else NA_character_,
    note = paste0(nsc, "; MDE = smallest delta with power >= .80, linear interpolation on the 9-point grid; NA = above grid ceiling 0.08"))
  h1_scen_rows[[length(h1_scen_rows) + 1L]] <- row_base(
    "H1", lab, "mde_power90", "Fisher_z",
    k_es = N_SUB, k_cluster = N_SUB_CL, df = st$df, value = m90,
    note = paste0(nsc, "; co-reported 90% criterion"))
}
rows <- c(rows, h1_scen_rows)

# H1 calibration: 200 full-REML replicates at the primary-scenario MDE
cal_delta <- if (is.finite(mde_primary)) mde_primary else 0.08
cal_note0 <- sprintf(
  "calibration subset [H-Q14]: %d full REML (ladder) + CR2/Satt refits at delta = %.6f (primary scenario%s); optimism = 0.80 - rejection rate (positive = stream optimistic)",
  N_CAL, cal_delta,
  if (!is.finite(mde_primary)) "; MDE above grid ceiling -> calibrated at 0.08 (disclosed)" else "")
s2p <- S2_OWN
CAL_CNT <- c(fits = 0L, fallback = 0L, fail = 0L)
cal_rej <- rep(NA, N_CAL)
{
  C <- N_SUB_CL
  vil <- split(h1_dom$vi, clidx); stl <- split(as.character(h1_dom$study), clidx)
  Ll <- vector("list", C)
  for (c in seq_len(C)) {
    v <- vil[[c]]; n <- length(v)
    Vs <- RHO * sqrt(v) %o% sqrt(v); diag(Vs) <- v
    Zst <- outer(stl[[c]], stl[[c]], "==") * s2p[2]
    Ll[[c]] <- t(chol(Vs + s2p[1] + Zst + diag(s2p[3], n)))
  }
  Lb <- Matrix::bdiag(Ll); ordback <- order(order(clidx))
  dcal <- h1_dom
  for (r in seq_len(N_CAL)) {
    e <- stats::rnorm(nrow(X))
    y <- as.numeric(Lb %*% e)[ordback] + cal_delta * h1_dom$pp_mid_lag0
    dcal$zi <- y
    dcal$pp_cell <- factor(dcal$pp_mid_lag0, levels = c(0, 1))
    out <- fit3l_q(~ 0 + pp_cell, dcal, RHO)
    CAL_CNT["fits"] <- CAL_CNT["fits"] + 1L
    if (inherits(out, "error")) { CAL_CNT["fail"] <- CAL_CNT["fail"] + 1L; next }
    if (out$rung > 1L) CAL_CNT["fallback"] <- CAL_CNT["fallback"] + 1L
    dc <- cm_diff(out$m, dcal)
    cal_rej[r] <- abs(dc$t) > stats::qt(0.975, df = dc$df)
  }
}
cal_rate <- mean(cal_rej, na.rm = TRUE)
rows <- c(rows, list(
  row_base("H1", "calibration", "rejection_rate", "count",
           k_es = N_SUB, k_cluster = N_SUB_CL, value = cal_rate,
           note = sprintf("%s; n effective = %d/%d", cal_note0,
                          sum(!is.na(cal_rej)), N_CAL)),
  row_base("H1", "calibration", "optimism_diff", "count",
           value = 0.80 - cal_rate,
           note = paste0(cal_note0, "; reported as a design row [DEC-045]"))))

# ------------------------------ 7. Coding derivation (shared) ---------
derive_codings <- function(d) {
  s16 <- share_y_of(d$d_sample_end, d$winL, 2016)
  s17 <- share_y_of(d$d_sample_end, d$winL, 2017)
  s18 <- share_y_of(d$d_sample_end, d$winL, 2018)
  s19 <- share_y_of(d$d_sample_end, d$winL, 2019)
  list(paris_mid        = as.integer(s16 >= 0.5),
       tie_break_median = as.integer(s16 >  0.5),   # ties -> Pre [DEC-024]
       end_any_exposure = as.integer(s16 >  0),
       share_recut_2017 = as.integer(s17 >= 0.5),
       share_recut_2018 = as.integer(s18 >= 0.5),
       share_recut_2019 = as.integer(s19 >= 0.5),
       end_lag1         = as.integer(s17 >  0),
       end_lag2         = as.integer(s18 >  0),
       end_lag3         = as.integer(s19 >  0),
       clean_window     = ifelse(s16 == 1, 1L, ifelse(s16 == 0, 0L, NA_integer_)))
}
cod_obs <- derive_codings(sub)
stopifnot(identical(cod_obs$paris_mid, as.integer(sub$pp_mid_lag0)),
          identical(cod_obs$tie_break_median, as.integer(sub$pp_median_lag0)),
          identical(cod_obs$end_any_exposure, as.integer(sub$pp_end_lag0)),
          identical(cod_obs$end_lag1, as.integer(sub$pp_end_lag1)),
          identical(cod_obs$end_lag2, as.integer(sub$pp_end_lag2)),
          identical(cod_obs$end_lag3, as.integer(sub$pp_end_lag3)),
          identical(cod_obs$share_recut_2017,
                    as.integer(sub$share_2017 >= 0.5)),
          identical(is.na(cod_obs$clean_window),
                    !(sub$pp_window_class %in% c("pre-only", "post-only"))))

# ------------------------------ 8. Permutation pass (H5+H4+H3 core) ---
medC <- tapply(sub$sample_mid, clF, stats::median)     # by CL_IDS order
adm_years <- H4_YEARS[vapply(as.character(H4_YEARS), function(y)
  grepl(y, rADM$note, fixed = TRUE), logical(1))]
stopifnot(length(adm_years) == rADM$value)

perm_worker <- function(b) {
  for (ev in c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS",
               "MKL_NUM_THREADS")) do.call(Sys.setenv,
                                           stats::setNames(list("1"), ev))
  pi_b <- PERMS[, b]
  dlt <- (medC[pi_b] - medC)[as.integer(clF)]          # per-ES Delta_c
  d <- sub
  d$d_sample_end <- d$d_sample_end + dlt
  d$sample_mid <- d$sample_mid + dlt
  d$sample_mid_c <- d$sample_mid - CENTER
  cods <- derive_codings(d)
  cnt <- c(fits = 0L, fallback = 0L, fail = 0L)
  one_fit <- function(fml, dd) {
    out <- fit3l_q(fml, dd, RHO)
    cnt["fits"] <<- cnt["fits"] + 1L
    if (inherits(out, "error")) { cnt["fail"] <<- cnt["fail"] + 1L
      return(NULL) }
    if (out$rung > 1L) cnt["fallback"] <<- cnt["fallback"] + 1L
    out$m
  }
  # H5: race statistic
  d$pp_b <- cods$paris_mid
  mR <- one_fit(~ sample_mid_c + pp_b, d)
  t_race <- if (is.null(mR)) NA_real_ else {
    ct <- coef_test(mR, vcov = vcovCR(mR, cluster = d$cluster_id,
                                      type = "CR2"), test = "Satterthwaite")
    abs(ct$tstat[coef_idx(ct, "pp_b")][1])
  }
  # H4: 12 grid-year break fits (budget), sup over admissible
  tj <- rep(NA_real_, length(H4_YEARS)); names(tj) <- H4_YEARS
  for (Y in H4_YEARS) {
    sY <- share_y_of(d$d_sample_end, d$winL, Y)
    cY <- as.integer(sY >= 0.5)
    if (length(unique(cY)) < 2L) { cnt["fits"] <- cnt["fits"] + 1L
      cnt["fail"] <- cnt["fail"] + 1L; next }
    d$pp_cell <- factor(cY, levels = c(0, 1))
    mY <- one_fit(~ 0 + pp_cell, d)
    if (is.null(mY)) next
    lc <- linear_contrast(mY, vcov = vcovCR(mY, cluster = d$cluster_id,
                                            type = "CR2"),
                          contrasts = rbind(diff = c(-1, 1)), level = .95)
    tj[as.character(Y)] <- abs(lc$Est[1] / lc$SE[1])
  }
  t_sup <- if (all(is.na(tj[as.character(adm_years)]))) NA_real_ else
    max(tj[as.character(adm_years)], na.rm = TRUE)
  # H3 core: 10 coding-family |t| under the SAME permutation
  tc <- rep(NA_real_, length(CODINGS)); names(tc) <- CODINGS
  pc <- tc
  for (cd in CODINGS) {
    cv <- cods[[cd]]
    keep <- !is.na(cv)
    if (length(unique(cv[keep])) < 2L) { cnt["fits"] <- cnt["fits"] + 1L
      cnt["fail"] <- cnt["fail"] + 1L; next }
    dd <- d[keep, , drop = FALSE]
    dd$pp_cell <- factor(cv[keep], levels = c(0, 1))
    mC <- one_fit(~ 0 + pp_cell, dd)
    if (is.null(mC)) next
    lc <- linear_contrast(mC, vcov = vcovCR(mC, cluster = dd$cluster_id,
                                            type = "CR2"),
                          contrasts = rbind(diff = c(-1, 1)), level = .95)
    dfd <- (lc$df %||% lc$df_Satt)[1]
    tc[cd] <- abs(lc$Est[1] / lc$SE[1])
    pc[cd] <- 2 * stats::pt(-tc[cd], df = dfd)
  }
  list(t_race = t_race, t_sup = t_sup,
       core_share_sig = mean(pc < 0.05, na.rm = TRUE),
       core_median_t = stats::median(tc, na.rm = TRUE),
       n_core_ok = sum(!is.na(tc)), cnt = cnt)
}

cl <- makeCluster(min(W_TARGET, max(1L, detectCores() - 1L)))
clusterEvalQ(cl, suppressPackageStartupMessages({
  library(metafor); library(clubSandwich); library(stats)
}))
clusterExport(cl, c("PERMS", "medC", "clF", "sub", "CENTER", "CODINGS",
                    "H4_YEARS", "adm_years", "share_y_of",
                    "derive_codings", "fit3l_q", "LADDER_OPTS", "RHO",
                    "coef_idx", "%||%"), envir = environment())
perm_res <- parLapply(cl, seq_len(B_PERM), perm_worker)
stopCluster(cl)

t_race_b <- vapply(perm_res, function(x) x$t_race, numeric(1))
t_sup_b  <- vapply(perm_res, function(x) x$t_sup, numeric(1))
sh_b     <- vapply(perm_res, function(x) x$core_share_sig, numeric(1))
mt_b     <- vapply(perm_res, function(x) x$core_median_t, numeric(1))
CNT <- Reduce(`+`, lapply(perm_res, function(x) x$cnt))
stopifnot(CNT["fail"] / CNT["fits"] <= FAIL_MAX_SHARE)

# Observed statistics: race from T8 (single-home; refit identity)
sub$pp_cell <- factor(sub$pp_mid_lag0, levels = c(0, 1))
mRobs <- fit3l(~ sample_mid_c + pp_mid_lag0, sub, "H5_race_obs (T8 refit)")
ctR <- coef_test(mRobs, vcov = vcr(mRobs, sub), test = "Satterthwaite")
iR <- coef_idx(ctR, "pp_mid_lag0")
stopifnot(near0(c(ctR$beta[iR][1], ctR$SE[iR][1]),
                unname(A_T8_RACE[c("est", "se")]), 1e-6))
t_race_obs <- abs(ctR$tstat[iR][1])
t_sup_obs <- tha[tha$analysis_id == "H4" & tha$spec == "sup_break" &
                   tha$term == "observed_sup", "value"]
stopifnot(length(t_sup_obs) == 1, is.finite(t_sup_obs))

p_perm <- function(obs, vec) {
  ok <- is.finite(vec); (1 + sum(vec[ok] >= obs)) / (sum(ok) + 1)
}
np_r <- sum(is.finite(t_race_b)); np_s <- sum(is.finite(t_sup_b))
rows <- c(rows, list(
  row_base("H5", "perm_race", "p_perm", "count",
           k_es = N_SUB, k_cluster = N_SUB_CL,
           value = p_perm(t_race_obs, t_race_b),
           ms_input = TRUE, ms_label = "h5_p_perm",
           note = sprintf(
             "time-translation permutation [H-Q20]: p = (1 + %d) / (%d + 1); observed |t_race| = %.6f (pp_mid coefficient of the T8 race model; point estimate/p_CR2 live in T8 — single-home [4a]); B = %d, exceed count = %d of %d effective",
             sum(t_race_b[is.finite(t_race_b)] >= t_race_obs), np_r,
             t_race_obs, B_PERM,
             sum(t_race_b[is.finite(t_race_b)] >= t_race_obs), np_r)),
  row_base("H5", "perm_race", "eff_B", "count", value = np_r,
           note = sprintf("effective replicates (finite race statistic) of %d; failed replicates dropped from the denominator, share <= %.2f enforced", B_PERM, FAIL_MAX_SHARE)),
  row_base("H4", "perm_sup", "p_perm", "count",
           k_es = N_SUB, k_cluster = N_SUB_CL,
           value = p_perm(t_sup_obs, t_sup_b),
           ms_input = TRUE, ms_label = "h4_p_perm",
           note = sprintf(
             "time-translation permutation, identical list as H5 [H-Q16/H-Q20]: p = (1 + %d) / (%d + 1); observed sup |t| = %.6f (from TH_a_results.csv observed_sup); admissible years fixed at the observed design: %s; exceed count = %d of %d effective",
             sum(t_sup_b[is.finite(t_sup_b)] >= t_sup_obs), np_s, t_sup_obs,
             paste(adm_years, collapse = ", "),
             sum(t_sup_b[is.finite(t_sup_b)] >= t_sup_obs), np_s)),
  row_base("H4", "perm_sup", "eff_B", "count", value = np_s,
           note = sprintf("effective replicates (finite sup statistic) of %d", B_PERM))))

# ------------------------------ 9. H3 — observed core + p_perm --------
core_t <- rep(NA_real_, length(CODINGS)); names(core_t) <- CODINGS
core_p <- core_t
core_cells <- list()
for (cd in CODINGS) {
  cv <- cod_obs[[cd]]; keep <- !is.na(cv)
  dd <- sub[keep, , drop = FALSE]
  dd$pp_cell <- factor(cv[keep], levels = c(0, 1))
  mC <- fit3l(~ 0 + pp_cell, dd, sprintf("H3_core_%s", cd))
  dc <- cm_diff(mC, dd)
  core_t[cd] <- abs(dc$t); core_p[cd] <- dc$p
  core_cells[[cd]] <- dc
}
obs_share <- mean(core_p < 0.05); obs_medt <- stats::median(core_t)
npc <- sum(is.finite(sh_b))
rows <- c(rows, list(
  row_base("H3", "core_curve", "observed_share_sig", "count",
           k_es = N_SUB, k_cluster = N_SUB_CL, value = obs_share,
           note = sprintf("Simonsohn whole-curve statistic 1: share of the 10 core cells with p < .05 (observed); core = B3 coding family x 3LMA-RVE x rho .6 x dfE x outlier none x full set [S3]; per-cell |t|: %s",
                          paste(sprintf("%s=%.4f", CODINGS, core_t),
                                collapse = ", "))),
  row_base("H3", "core_curve", "observed_median_t", "count",
           k_es = N_SUB, k_cluster = N_SUB_CL, value = obs_medt,
           note = "Simonsohn whole-curve statistic 2: median |t| over the 10 core cells (observed)"),
  row_base("H3", "core_curve", "p_perm_share_sig", "count",
           value = p_perm(obs_share, sh_b),
           ms_input = TRUE, ms_label = "h3_p_perm_share",
           note = sprintf("joint permutation [H-Q15/R3]: ONE cluster time-translation per replicate applied to all 10 core cells (codings re-derived); p = (1 + %d)/(%d + 1)",
                          sum(sh_b[is.finite(sh_b)] >= obs_share), npc)),
  row_base("H3", "core_curve", "p_perm_median_t", "count",
           value = p_perm(obs_medt, mt_b),
           note = sprintf("joint permutation, statistic 2; p = (1 + %d)/(%d + 1)",
                          sum(mt_b[is.finite(mt_b)] >= obs_medt),
                          sum(is.finite(mt_b)))),
  row_base("H3", "core_curve", "eff_B", "count", value = npc,
           note = sprintf("effective replicates of %d; mean estimable core cells per replicate = %.2f",
                          B_PERM, mean(vapply(perm_res, function(x)
                            x$n_core_ok, numeric(1)))))))

# ------------------------------ 10. H3 — full 1,260-cell curve --------
cell_grid <- expand.grid(coding = CODINGS, outlier = OUTLIERS,
                         es_set = ES_SETS, df_basis = DF_BASES,
                         estimator = ESTIMATORS, rho = RHO_GRID,
                         stringsAsFactors = FALSE)
cell_grid <- cell_grid[!(cell_grid$estimator == "UWLS3" &
                           cell_grid$rho != RHO), ]      # rho inert -> .6 tag
stopifnot(nrow(cell_grid) == 1260L)

cell_fun <- function(i) {
  for (ev in c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS",
               "MKL_NUM_THREADS")) do.call(Sys.setenv,
                                           stats::setNames(list("1"), ev))
  g <- cell_grid[i, ]
  cv <- cod_obs[[g$coding]]
  keep <- !is.na(cv)
  if (g$es_set == "no_starbound") keep <- keep & sub$flag_starbound == 0
  if (g$df_basis == "k20")        keep <- keep & !sub$k20_bad
  if (g$outlier == "rstudent")    keep <- keep & !sub$mask_out
  dd <- sub[keep, , drop = FALSE]
  cvk <- cv[keep]
  if (g$outlier == "winsor") dd$zi <- dd$zi_wins
  vcol <- c(dfE = "vi_dfE", k10 = "vi_k10", k20 = "vi_k20")[[g$df_basis]]
  base <- list(spec = sprintf("%s|%s|%s|%s", g$coding, g$outlier,
                              g$es_set, g$df_basis),
               k_es = nrow(dd),
               k_study = length(unique(dd$study)),
               k_cluster = length(unique(dd$cluster_id)))
  fail <- function(msg) c(base, list(est = NA_real_, se = NA_real_,
                                     t = NA_real_, df = NA_real_,
                                     p = NA_real_, note = msg, rung = NA))
  if (length(unique(cvk)) < 2L)
    return(fail("not_estimable: single-cell domain"))
  if (g$estimator == "3LMA-RVE_CR2") {
    dd$pp_cell <- factor(cvk, levels = c(0, 1))
    out <- fit3l_q(~ 0 + pp_cell, dd, g$rho, vcol)
    if (inherits(out, "error"))
      return(fail(paste0("not_estimable: ", conditionMessage(out))))
    dc <- cm_diff(out$m, dd)
    return(c(base, list(est = dc$est, se = dc$se, t = dc$t, df = dc$df,
                        p = dc$p, note = "", rung = out$rung)))
  }
  if (g$estimator == "one_per_cluster") {
    dd$vi <- dd[[vcol]]; dd$cellv <- cvk
    ag <- tryCatch({
      es <- metafor::escalc(measure = "GEN", yi = zi, vi = vi, data = dd)
      es$agg_id <- interaction(dd$cluster_id, dd$cellv, drop = TRUE)
      aggregate(es, cluster = agg_id, struct = "CS", rho = g$rho)
    }, error = function(e) e)
    if (inherits(ag, "error"))
      return(fail(paste0("not_estimable: ", conditionMessage(ag))))
    m <- tryCatch(metafor::rma(yi, vi, mods = ~ 0 + factor(cellv),
                               data = ag, test = "t"),
                  error = function(e) e)
    if (inherits(m, "error") || length(coef(m)) < 2L)
      return(fail("not_estimable: OPC cell fit failed"))
    est <- coef(m)[2] - coef(m)[1]
    se <- sqrt(vcov(m)[1, 1] + vcov(m)[2, 2] - 2 * vcov(m)[1, 2])
    dfv <- m$k - 2
    return(c(base, list(est = unname(est), se = se, t = unname(est) / se,
                        df = dfv,
                        p = 2 * stats::pt(-abs(est / se), df = dfv),
                        note = "cluster x cell aggregates (D2/H2b convention)",
                        rung = NA)))
  }
  # UWLS3
  wdd <- 1 / dd[[vcol]]
  m <- tryCatch(stats::lm(dd$zi ~ 0 + factor(cvk), weights = wdd),
                error = function(e) e)
  if (inherits(m, "error") || length(coef(m)) < 2L)
    return(fail("not_estimable: UWLS cell fit failed"))
  ct <- summary(m)$coefficients
  est <- ct[2, 1] - ct[1, 1]
  vc <- stats::vcov(m)
  se <- sqrt(vc[1, 1] + vc[2, 2] - 2 * vc[1, 2])
  dfv <- m$df.residual
  c(base, list(est = unname(est), se = se, t = unname(est) / se, df = dfv,
               p = 2 * stats::pt(-abs(est / se), df = dfv),
               note = "weighted LS cell means (1/vi); descriptive curve only",
               rung = NA))
}

cl <- makeCluster(min(W_TARGET, max(1L, detectCores() - 1L)))
clusterEvalQ(cl, suppressPackageStartupMessages({
  library(metafor); library(clubSandwich); library(stats)
}))
clusterExport(cl, c("cell_grid", "cod_obs", "sub", "fit3l_q",
                    "LADDER_OPTS", "cm_diff", "vcr", "RHO", "%||%"),
              envir = environment())
cell_res <- parLapply(cl, seq_len(nrow(cell_grid)), cell_fun)
stopCluster(cl)

CELL_CNT <- c(fits = 0L, fallback = 0L, fail = 0L)
core_key <- sprintf("%s|none|full|dfE", CODINGS)
for (i in seq_len(nrow(cell_grid))) {
  g <- cell_grid[i, ]; r <- cell_res[[i]]
  is_core <- g$estimator == "3LMA-RVE_CR2" && g$rho == RHO &&
    r$spec %in% core_key
  if (g$estimator == "3LMA-RVE_CR2") {
    CELL_CNT["fits"] <- CELL_CNT["fits"] + 1L
    if (is.na(r$est)) CELL_CNT["fail"] <- CELL_CNT["fail"] + 1L
    else if (!is.na(r$rung) && r$rung > 1L)
      CELL_CNT["fallback"] <- CELL_CNT["fallback"] + 1L
  }
  rows[[length(rows) + 1L]] <- row_base(
    "H3", r$spec, "diff", "Fisher_z",
    subset = sprintf("%s|r%.1f", g$estimator, g$rho),
    estimator = g$estimator, rho = g$rho,
    k_es = r$k_es, k_study = r$k_study, k_cluster = r$k_cluster,
    est_z = r$est, se_z = r$se, t_stat = r$t, df = r$df, p = r$p,
    ms_input = is_core,
    ms_label = if (is_core) sprintf("h3_core_%s", g$coding) else NA_character_,
    note = paste0(
      sprintf("multiverse cell %d/1260: coding=%s, outlier=%s, es_set=%s, df_basis=%s, estimator=%s, rho=%.1f [DEC-045 S2]; ",
              i, g$coding, g$outlier, g$es_set, g$df_basis, g$estimator,
              g$rho),
      if (nzchar(r$note)) r$note else "descriptive curve cell",
      if (is_core) "; CORE cell (inference via joint permutation); verifier identity vs committed T2 diff at 1e-6" else ""))
}

# ------------------------------ 11. Design rows -----------------------
rows <- c(rows, list(
  design_row("perm_list", "count", value = B_PERM,
             note = sprintf("output/TH_c_perms.rds: %d x %d cluster permutations, generated FIRST under seed %d; md5 = %s; workers receive indices (scheduling-invariant)",
                            N_SUB_CL, B_PERM, SEED, PERM_MD5)),
  design_row("execution_order", "count",
             note = "pinned: PERMS -> masks -> H1 stream -> H1 calibration -> permutation pass (H5+H4+H3 core, ONE pass, 23 fits/replicate) -> H3 curve [DEC-045]"),
  design_row("blas_note", "count",
             note = "Windows CRAN reference BLAS is single-threaded; OMP/OPENBLAS/MKL thread env guards additionally set per worker [determinism pin]"),
  design_row("center_sample_mid", "year", value = CENTER,
             note = "derived in-script (constancy asserted); race consistency with R/08"),
  design_row("t8_race_anchor", "count",
             note = sprintf("F65 gates PASSED: committed T8 B4/race/pp_mid_lag0 matched embedded constants at 1e-9; observed refit identity at 1e-6; |t_race_obs| = %.6f", t_race_obs)),
  design_row("h4_admissible_echo", "count", value = length(adm_years),
             note = sprintf("read from TH_a_results.csv design row and membership-verified: %s; recomputation identity via the observed permutation-pass machinery",
                            paste(adm_years, collapse = ", "))),
  design_row("rstudent_mask", "count", value = sum(MASK_OUT),
             note = sprintf("|standardized marginal residual| > %g from the full-set intercept spine (mu = %.6f, sum sigma2 = %.6f), computed ONCE, fixed across cells and replicates [DEC-045 amendment]",
                            RSTUDENT_THR, mu0, s2sum)),
  design_row("winsor_bounds", "count", value = NA_real_,
             note = sprintf("zi winsorized at empirical P1/P99 of the full estimation set: [%.6f, %.6f], computed once", WB[1], WB[2])),
  design_row("vi_k_identity", "count", value = sum(is_pcc),
             note = sprintf("load assert PASSED: vi_k10 = 1/(1/vi - 10) and vi_k20 = 1/(1/vi - 20) on PCC rows (1e-9; algebraically identical to 1/(n-13), 1/(n-23) under the F21 base convention vi = 1/(n-3)); bivariate rows carry base vi in the k-columns; the raw n_obs extraction column is NOT consumed; k20 basis excludes %d row(s) with nonpositive/NA vi_k20 (tiny-n edge, n <= 23) from all k20 cells -- disclosed [DEC-045 amendment; author ruling 2026-07-24]", sum(dat$k20_bad))),
  design_row("core_cells", "count", value = length(CODINGS),
             note = paste("core cell keys:", paste(core_key, collapse = "; ")))))

# ------------------------------ 12. Assemble + write ------------------
res <- do.call(rbind, rows)
stopifnot(identical(names(res), SCHEMA))
if (nrow(res) != N_ROWS_C) {
  print(table(res$analysis_id))
  stop(sprintf("ROW BUDGET MISMATCH: got %d, expected %d.",
               nrow(res), N_ROWS_C))
}
key <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "||")
stopifnot(!anyDuplicated(key))
stopifnot(!any(res$spec %in% c("race", "break_only", "trend_only")),
          !any(res$term == "observed_sup"))              # single-home [4a]

dir.create(here("output"), showWarnings = FALSE)
write_csv(res, here("output", "TH_c_results.csv"), na = "")
meta <- c(
  sprintf("TH-c run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("dat_prep md5:  %s",
          unname(tools::md5sum(here("output", "dat_prep.rds")))),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("PERMS md5: %s (%d x %d, generated first under seed %d)",
          PERM_MD5, N_SUB_CL, B_PERM, SEED),
  sprintf("workers: %d (target %d); Windows reference BLAS single-threaded + env guards",
          min(W_TARGET, max(1L, detectCores() - 1L)), W_TARGET),
  "anchor gates PASSED: T1/A2 (1e-9), T8 race (1e-9 CSV, 1e-6 refit), TH_a admissible set (membership)",
  sprintf("H1: delta grid {%s} z-scale; B = %d per scenario; delta = noncentral shift of one stream (exact); df_Satt precomputed y-free per scenario",
          paste(sprintf("%.2f", DELTA_GRID), collapse = ", "), B_H1),
  sprintf("H1 calibration: %d ladder REML fits at delta = %.6f; counters fits/fallback/fail = %d/%d/%d",
          N_CAL, cal_delta, CAL_CNT["fits"], CAL_CNT["fallback"],
          CAL_CNT["fail"]),
  sprintf("permutation pass: B = %d x 23 ladder fits; counters fits/fallback/fail = %d/%d/%d (fail share %.4f <= %.2f enforced)",
          B_PERM, CNT["fits"], CNT["fallback"], CNT["fail"],
          CNT["fail"] / CNT["fits"], FAIL_MAX_SHARE),
  sprintf("H3 curve: 1,260 cells; 3L ladder counters fits/fallback/fail = %d/%d/%d",
          CELL_CNT["fits"], CELL_CNT["fallback"], CELL_CNT["fail"]),
  sprintf("masks: rstudent |resid| > %g -> %d ES flagged; winsor bounds [%.6f, %.6f]",
          RSTUDENT_THR, sum(MASK_OUT), WB[1], WB[2]),
  "OPC pin: cluster x cell aggregates (aggregate.escalc, struct CS, per-cell rho), D2/H2b convention; UWLS3 = weighted LS cell means, descriptive only",
  sprintf("named-fit convergence certificates (%d):", length(FIT_LOG)),
  paste0("  ", FIT_LOG),
  "", "sessionInfo():", utils::capture.output(utils::sessionInfo()))
writeLines(meta, here("output", "TH_c_run_meta.txt"))
cat(sprintf("TH-c written: %d rows x %d cols -> output/TH_c_results.csv\n",
            nrow(res), ncol(res)))
cat("Input-contract + anchor asserts: ALL PASSED (see paired verifier).\n")
