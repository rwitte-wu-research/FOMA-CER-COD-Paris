# =====================================================================
# R/08_identification.R — T8: Paris identification battery (Block B: B2/B4/B5/B8)
# FOMA CER–COD–Paris | GATE-2 FOUNDATIONAL SCRIPT (pre-execution diff-review)
# ---------------------------------------------------------------------
# Authority: DEC-007 (7-move toolkit) · DEC-021 (time axis) · DEC-024
#   (dose promoted to identification; z(0)/z(0.6)/z(1), in-support contrast,
#   quadratic check) · DEC-031 Battery B + D31.1 (cluster_id spine) ·
#   DEC-031a.9 (naming: pp_mid_lag0 binary, pp_share_lag0 continuous dose) ·
#   DEC-042a/b (estimation set 2,713; period/dose domain 2,705) ·
#   analysis_plan §4 + Addendum A.2/A.3 · F60 ruling 2026-07-14 (placebo
#   recode in-script from canonical share_Y formula, ties→Post, 2016
#   identity gate; cell sizes pinned) · F61 (B5 covariates = §6 drift set).
# Domain: dose/period cells N = 2,705 ES / 113 studies / 112 clusters
#   (window-based codings; 8 ES / 2 studies NA listwise) [DEC-042b].
# Spine: rma.mv REML, V = impute_covariance_matrix(vi, cluster_id, r=0.6),
#   random = ~1 | cluster_id/study/esid, CR2 + Satterthwaite on cluster_id.
# Output: output/T8_results.csv — T2 schema (36 columns, incl. `term`),
#   N_ROWS derived from pinned B5 level counts (= 83 on v12);
#   output/T8_run_meta.txt (md5, pins, sessionInfo appended).
# Gate-2 review 2026-07-15 (v3): W1 auditable row budget · W2 delta*
#   hardening · W3 run-meta contract · W4 offset identity (verifier O26).
# Result framing: NONE. This script computes and writes; it does not
#   interpret. Verdict language is produced downstream (workbook/chat).
# ---------------------------------------------------------------------
# Column conventions (aligned 1:1 with committed T1/T2_results.csv):
#   subset   = "defined" (complete cases on window codings [DEC-042b])
#   metric   = "Fisher_z" (model estimates/predictions/contrasts) |
#              "F_test" (Wald) | typed scalars: count/corr/share/year/
#              rank/pseudo_R2/delta/E_value
#   estimator= "3LMA-RVE_CR2" (model + fit-derived scalars) |
#              "descriptive" (design constants) | "Oster_analog" |
#              "EValue_approx"
#   sigma2_* = filled on every row of a fitted model (T2 pattern);
#              pct_* / typical_v = NA (T1/A2 owns the decomposition)
#   est_r    = tanh(est_z) on LEVEL rows (intercepts, predictions) only;
#              difference/slope/contrast rows are z-only (T2 diff pattern)
#   pi_*     = NA throughout (PIs live in T1/A3 per A.8)
#   Wald rows: F in t_stat, Satterthwaite denominator df in df,
#              numerator df in note (test = "HTZ")
#   ms_input = logical (TRUE/FALSE)
# =====================================================================

suppressPackageStartupMessages({
  library(metafor)
  library(clubSandwich)
  library(here)
  library(readr)
})

# ------------------------------ 0. Constants (FROZEN ZONE) ------------
RHO           <- 0.6                      # DEC-017
KNOT          <- 2015.5                   # Paris threshold: mid >= 2015.5 [A.3]
PLACEBO_YEARS <- 2008:2015                # Battery B4 cell; F60 ruling
PRED_SHARES   <- c(0, 0.6, 1)             # DEC-024 (roles fixed)
CONTRAST_MAIN <- 0.6                      # pinned contrast point [DEC-024]
SESOI_CONTRAST<- 0.05                     # |dr| secondary SESOI [DEC-031 Block E]
SESOI_POOLED  <- 0.070                    # |r| primary SESOI (F27v2) [DEC-031]
OSTER_RMAX_F  <- 1.3                      # Rmax = min(1.3 * R2_controlled, 1) [Oster 2019]
OSTER_GUARD   <- 0.005                    # min (R2_c - R2_u) for informative bounds
B5_COVARS     <- c("country_region", "COD_instrument", "CER_measure")  # F61
B5_REFS       <- c(country_region = "1_US",
                   COD_instrument = "loan (interest rate)",
                   CER_measure    = "performance")
B5_LEVELS     <- c(country_region = 4L, COD_instrument = 4L,
                   CER_measure = 2L)   # v12 pin, 2,705 domain [W1]
N_SET   <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L   # DEC-042a
N_SUB   <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L   # DEC-042b (v12-derived)
K_PERIOD_NA_ES <- 8L; K_PERIOD_NA_ST <- 2L             # DEC-042b
POST16  <- c(es = 711L, st = 31L, cl = 31L)            # v12 design constants
SHARE_DISTINCT <- 41L                                  # T2 pin P1
SEED <- 20260710L
# Row budget (auditable; F58 lesson) [W1]:
#   11 design + (3+5) B2 linear + (4+1) B2 quadratic + 2 trend_only
# + 2 break_only + 3 race + (8*2+1) placebo + (4+1) segmented
# + (2+D+2) B5 composition_adj + (3+D+1) B5 trend_composition + 8 B8
# = 69 + 2*D,  D = sum(B5_LEVELS - 1) = 7  =>  83 on v12.
N_ROWS_EXPECTED <- 69L + 2L * sum(B5_LEVELS - 1L)
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

need <- c("zi","vi","cluster_id","study","esid","sample_mid","sample_mid_c",
          "pp_mid_lag0","pp_share_lag0","d_sample_start","d_sample_end",
          B5_COVARS)
miss <- setdiff(need, names(dat))
if (length(miss)) stop("SCHEMA HARD STOP — missing columns: ",
                       paste(miss, collapse = ", "))
stopifnot(nrow(dat) == N_SET,
          length(unique(dat$study)) == N_SET_ST,
          length(unique(dat$cluster_id)) == N_SET_CL)

na_win <- is.na(dat$pp_mid_lag0)                       # DEC-042b
stopifnot(sum(na_win) == K_PERIOD_NA_ES,
          length(unique(dat$study[na_win])) == K_PERIOD_NA_ST)
sub <- dat[!na_win, , drop = FALSE]
stopifnot(nrow(sub) == N_SUB,
          length(unique(sub$study)) == N_SUB_ST,
          length(unique(sub$cluster_id)) == N_SUB_CL,
          !anyNA(sub$pp_share_lag0), !anyNA(sub$sample_mid),
          !anyNA(sub$sample_mid_c),
          !anyNA(sub$d_sample_start), !anyNA(sub$d_sample_end))
stopifnot(is.numeric(sub$pp_mid_lag0), all(sub$pp_mid_lag0 %in% 0:1),
          is.numeric(sub$pp_share_lag0), is.numeric(sub$sample_mid),
          is.numeric(sub$sample_mid_c), is.numeric(sub$vi), all(sub$vi > 0))

# Centering constant of the canonical time axis (derived, not assumed)
ctr <- unique(round(sub$sample_mid - sub$sample_mid_c, 9))
stopifnot(length(ctr) == 1)
CENTER <- as.numeric(ctr)                 # reported as design row
OFFSET <- KNOT - CENTER                   # evaluate predictions at calendar 2015.5

# Canonical share_Y formula [F60; derived_manifest "DEC-024-Grid"]:
#   share_Y = clip((d_sample_end - Y + 1) / (d_sample_end - d_sample_start + 1), 0, 1)
#   pp_Y    = 1{ share_Y >= 0.5 }  (ties→Post [DEC-024])  <=>  sample_mid >= Y - 0.5
share_y <- function(Y) {
  L <- sub$d_sample_end - sub$d_sample_start + 1
  pmin(pmax((sub$d_sample_end - Y + 1) / L, 0), 1)
}
stopifnot(max(abs(share_y(2016) - sub$pp_share_lag0)) < 1e-9)          # identity gate
stopifnot(all(as.integer(share_y(2016) >= 0.5) == as.integer(sub$pp_mid_lag0)))
for (Y in c(PLACEBO_YEARS, 2016L)) {
  stopifnot(all((share_y(Y) >= 0.5) == (sub$sample_mid >= Y - 0.5)))
}
stopifnot(length(unique(sub$pp_share_lag0)) == SHARE_DISTINCT)
p16 <- sub$pp_mid_lag0 == 1
stopifnot(sum(p16) == POST16["es"],
          length(unique(sub$study[p16])) == POST16["st"],
          length(unique(sub$cluster_id[p16])) == POST16["cl"])

# B5 factors: pinned reference levels; 99_NCE kept as own level (n stays 2,705)
for (v in B5_COVARS) {
  sub[[v]] <- stats::relevel(factor(sub[[v]]), ref = B5_REFS[[v]])
  stopifnot(!anyNA(sub[[v]]),
            nlevels(sub[[v]]) == B5_LEVELS[[v]])   # [W1] level pin
}
sub$ts_knot <- sub$sample_mid - KNOT      # segmented-MR time (knot-invariant)

# ------------------------------ 2. Spine helpers ----------------------
V6 <- impute_covariance_matrix(vi = sub$vi, cluster = sub$cluster_id, r = RHO)

fit3l <- function(fml) {
  rma.mv(yi = zi, V = V6, mods = fml,
         random = ~ 1 | cluster_id/study/esid,
         data = sub, sparse = TRUE, method = "REML")
}
vcr <- function(m) vcovCR(m, cluster = sub$cluster_id, type = "CR2")

SPINE <- "random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6; CR2/Satterthwaite on cluster_id [D31.1/A.2]; k = complete cases on window codings [DEC-042b]"
mnote <- function(mods) sprintf("rma.mv mods=%s; %s", mods, SPINE)

row_base <- function(analysis_id, spec, term, metric,
                     estimator = "3LMA-RVE_CR2", rho = RHO,
                     k_es = N_SUB, k_study = N_SUB_ST, k_cluster = N_SUB_CL,
                     est_z = NA_real_, se_z = NA_real_, t_stat = NA_real_,
                     df = NA_real_, p = NA_real_,
                     ci_lb_z = NA_real_, ci_ub_z = NA_real_,
                     est_r = NA_real_, ci_lb_r = NA_real_, ci_ub_r = NA_real_,
                     sigma2 = NULL, value = NA_real_, ms_input = FALSE,
                     ms_label = NA_character_, note = NA_character_) {
  data.frame(
    analysis_id = analysis_id, spec = spec, subset = SUBSET_LAB, term = term,
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

coef_rows <- function(m, analysis_id, spec, model_note,
                      ms = character(0), ms_lab = c(), note_map = c()) {
  ct <- coef_test(m, vcov = vcr(m), test = "Satterthwaite")
  ci <- conf_int(m, vcov = vcr(m), level = .95)
  dfv <- ct$df_Satt %||% ct$df
  pv  <- ct$p_Satt  %||% ct$p
  s2  <- m$sigma2   # nesting order: cluster_id, study, esid
  lapply(seq_len(nrow(ct)), function(i) {
    trm0 <- if (!is.null(ct$Coef)) as.character(ct$Coef[i]) else rownames(ct)[i]
    trm  <- if (trm0 %in% c("intrcpt", "(Intercept)")) "intercept" else trm0
    lvl  <- trm == "intercept"
    sfx  <- if (trm %in% names(note_map)) paste0("; ", note_map[[trm]]) else ""
    row_base(
      analysis_id, spec, trm, metric = "Fisher_z",
      est_z = ct$beta[i], se_z = ct$SE[i], t_stat = ct$tstat[i],
      df = dfv[i], p = pv[i],
      ci_lb_z = ci$CI_L[i], ci_ub_z = ci$CI_U[i],
      est_r  = if (lvl) tanh(ct$beta[i]) else NA_real_,
      ci_lb_r = if (lvl) tanh(ci$CI_L[i]) else NA_real_,
      ci_ub_r = if (lvl) tanh(ci$CI_U[i]) else NA_real_,
      sigma2 = s2,
      ms_input = trm %in% ms,
      ms_label = if (trm %in% names(ms_lab)) ms_lab[[trm]] else NA_character_,
      note = paste0(model_note, sfx))
  })
}

pred_contrast_rows <- function(m, analysis_id, spec, model_note) {
  # Predictions at calendar KNOT (sample_mid_c = OFFSET), share in PRED_SHARES;
  # contrasts on the dose slope (time held fixed → cancels).
  Lp <- rbind(p0  = c(1, OFFSET, 0),
              p06 = c(1, OFFSET, 0.6),
              p1  = c(1, OFFSET, 1))
  Lc <- rbind(c06 = c(0, 0, CONTRAST_MAIN),
              c10 = c(0, 0, 1))
  lc  <- linear_contrast(m, vcov = vcr(m), contrasts = rbind(Lp, Lc), level = .95)
  dfl <- lc$df %||% lc$df_Satt
  pvl <- 2 * stats::pt(-abs(lc$Est / lc$SE), df = dfl)
  s2  <- m$sigma2
  terms <- c("pred_share_0", "pred_share_0.6", "pred_share_1",
             "contrast_0_to_0.6", "contrast_0_to_1")
  sfx <- c(
    "model-implied cell mean at calendar 2015.5, dose = 0; dose-0 endpoint support: 611 ES / 27 studies at share = 0 (v12)",
    "model-implied cell mean at calendar 2015.5, dose = 0.6; pinned contrast point [DEC-024]",
    "model-implied cell mean at calendar 2015.5, dose = 1; marginal support: 318 ES / 13 clusters at share = 1 (v12); joint (mid, share) support caveat: share = 1 implies mid >= 2016",
    "= 0.6 x dose slope; pinned headline dose contrast [DEC-024]; difference of Fisher-z means; no tanh transform of differences",
    "= dose slope; full-regime contrast; marginal support v12 (see pred_share_1); difference of Fisher-z means; no tanh transform of differences")
  lapply(seq_along(terms), function(i) {
    lvl <- i <= 3
    row_base(analysis_id, spec, terms[i], metric = "Fisher_z",
             est_z = lc$Est[i], se_z = lc$SE[i],
             t_stat = lc$Est[i] / lc$SE[i], df = dfl[i], p = pvl[i],
             ci_lb_z = lc$CI_L[i], ci_ub_z = lc$CI_U[i],
             est_r  = if (lvl) tanh(lc$Est[i]) else NA_real_,
             ci_lb_r = if (lvl) tanh(lc$CI_L[i]) else NA_real_,
             ci_ub_r = if (lvl) tanh(lc$CI_U[i]) else NA_real_,
             sigma2 = s2,
             ms_input = terms[i] == "contrast_0_to_0.6",
             ms_label = if (terms[i] == "contrast_0_to_0.6")
               "dose_contrast_0_06" else NA_character_,
             note = paste0(model_note, "; ", sfx[i]))
  })
}

wald_row <- function(m, idx, analysis_id, spec, term, model_note, h0) {
  wt <- Wald_test(m, constraints = constrain_zero(idx),
                  vcov = vcr(m), test = "HTZ")
  row_base(analysis_id, spec, term, metric = "F_test",
           t_stat = wt$Fstat, df = wt$df_denom, p = wt$p_val,
           sigma2 = m$sigma2,
           note = paste0(model_note, "; ", h0, "; HTZ; num_df = ", wt$df_num))
}

design_row <- function(term, metric, value = NA_real_, note = NA_character_) {
  row_base("T8_design", "design", term, metric = metric,
           estimator = "descriptive", rho = NA_real_, value = value, note = note)
}

scalar_row <- function(analysis_id, spec, term, metric, estimator, value, note,
                       rho = NA_real_, k_na = TRUE,
                       ms_input = FALSE, ms_label = NA_character_) {
  row_base(analysis_id, spec, term, metric = metric, estimator = estimator,
           rho = rho,
           k_es = if (k_na) NA_integer_ else N_SUB,
           k_study = if (k_na) NA_integer_ else N_SUB_ST,
           k_cluster = if (k_na) NA_integer_ else N_SUB_CL,
           value = value, ms_input = ms_input, ms_label = ms_label, note = note)
}

rows <- list()

# ------------------------------ 3. Design rows (T8_design) ------------
rows <- c(rows, list(
  design_row("subset_dose_period", "count", value = N_SUB,
             note = "2,705 ES / 113 studies / 112 clusters [DEC-042b]; run date in T8_run_meta.txt"),
  design_row("period_na", "count", value = K_PERIOD_NA_ES,
             note = "8 ES / 2 studies / 2 clusters (Bhattacharya & Sharma 2019; Ng & Rezaee 2012) [DEC-042b]; provenance for workbook Tab 5_Data_Provenance"),
  design_row("post_cell_2016", "count", value = as.numeric(POST16["es"]),
             note = "711 ES / 31 studies / 31 clusters (v12 design constant)"),
  design_row("corr_sample_mid_share", "corr",
             value = stats::cor(sub$sample_mid, sub$pp_share_lag0),
             note = "ES-level Pearson on 2,705; supersedes stale 0.70 pin (v8-era) — plan Section 4 disclosure updates [DEC-031 counts-re-derive]"),
  design_row("share_distinct", "count", value = SHARE_DISTINCT,
             note = "distinct pp_share_lag0 values; T2 pin P1 confirmed"),
  design_row("share_p95_es", "share",
             value = as.numeric(stats::quantile(sub$pp_share_lag0, .95)),
             note = "v12 supersedes the stale p95 = 0.6 pin; contrast point 0.6 retained by role [DEC-024; DEC-031 counts-re-derive]"),
  design_row("share_eq1", "count", value = sum(sub$pp_share_lag0 == 1),
             note = sprintf("%d studies / %d clusters at share = 1",
                            length(unique(sub$study[sub$pp_share_lag0 == 1])),
                            length(unique(sub$cluster_id[sub$pp_share_lag0 == 1])))),
  design_row("share_eq0", "count", value = sum(sub$pp_share_lag0 == 0),
             note = sprintf("%d studies at share = 0",
                            length(unique(sub$study[sub$pp_share_lag0 == 0])))),
  design_row("center_sample_mid", "year", value = CENTER,
             note = "derived in-script: sample_mid - sample_mid_c (constancy asserted); predictions evaluated at calendar 2015.5 via offset"),
  design_row("study_mid_median", "year",
             value = stats::median(tapply(sub$sample_mid, sub$study, stats::median)),
             note = "study-level median of sample_mid (placebo-support disclosure; supersedes stale 2012)"),
  design_row("studies_mid_ge2016", "count",
             value = sum(tapply(sub$sample_mid, sub$study, stats::median) >= 2016),
             note = "studies with study-level median sample_mid >= 2016 (supersedes stale 8)")
))

# ------------------------------ 4. B2 — dose model --------------------
nD <- mnote("~ sample_mid_c + pp_share_lag0")
mD <- fit3l(~ sample_mid_c + pp_share_lag0)
rows <- c(rows, coef_rows(
  mD, "B2", "dose_linear", nD,
  ms = "pp_share_lag0",
  ms_lab = c(pp_share_lag0 = "dose_slope"),
  note_map = c(pp_share_lag0 = "identification core [DEC-024]; interpret only alongside trend (corr disclosure row)")))
rows <- c(rows, pred_contrast_rows(mD, "B2", "dose_linear", nD))

nDq <- mnote("~ sample_mid_c + pp_share_lag0 + I(pp_share_lag0^2)")
mDq <- fit3l(~ sample_mid_c + pp_share_lag0 + I(pp_share_lag0^2))
crQ <- coef_rows(mDq, "B2", "dose_quadratic", nDq,
  note_map = c("I(pp_share_lag0^2)" = "quadratic-in-share check [DEC-024]"))
for (i in seq_along(crQ)) {
  if (crQ[[i]]$term == "I(pp_share_lag0^2)") crQ[[i]]$term <- "pp_share_lag0_sq"
}
rows <- c(rows, crQ)
stopifnot(identical(names(coef(mDq))[3:4],
                    c("pp_share_lag0", "I(pp_share_lag0^2)")))  # idx guard
rows <- c(rows, list(wald_row(
  mDq, idx = 3:4, "B2", "dose_quadratic", "wald_share_joint", nDq,
  h0 = "H0: share = share^2 = 0 (joint dose signal)")))

# ------------------------------ 5. B4 — trend vs break ----------------
nT <- mnote("~ sample_mid_c")
mT <- fit3l(~ sample_mid_c)
rows <- c(rows, coef_rows(mT, "B4", "trend_only", nT,
  note_map = c(sample_mid_c = "secular drift, no break term")))

nB <- mnote("~ pp_mid_lag0")
mB <- fit3l(~ pp_mid_lag0)
rows <- c(rows, coef_rows(
  mB, "B4", "break_only", nB,
  note_map = c(
    intercept = "pre-cell mean; parameterization-equivalent to T2/B1 cell_pre (~0+factor(coding))",
    pp_mid_lag0 = "equals T2/B1 paris_mid diff (verifier identity O15); realized vs design df disclosure: design df = 31.9 [T0.4]; difference of Fisher-z means; no tanh transform of differences")))

nR <- mnote("~ sample_mid_c + pp_mid_lag0")
mR <- fit3l(~ sample_mid_c + pp_mid_lag0)
rows <- c(rows, coef_rows(
  mR, "B4", "race", nR,
  ms = c("sample_mid_c", "pp_mid_lag0"),
  ms_lab = c(sample_mid_c = "race_trend", pp_mid_lag0 = "race_break"),
  note_map = c(pp_mid_lag0 = "Move 1: break net of smooth drift [Identifikation tab]; difference of Fisher-z means")))

# Placebo break years [F60: canonical share_Y recode, ties→Post; cells pinned]
b_abs <- c()
plc_pin <- data.frame(Y=integer(0), es=integer(0), st=integer(0), cl=integer(0))
for (Y in PLACEBO_YEARS) {
  ppY <- as.integer(share_y(Y) >= 0.5)
  sub$pp_break_tmp <- ppY
  kA <- sum(ppY == 1); kS <- length(unique(sub$study[ppY == 1]))
  kC <- length(unique(sub$cluster_id[ppY == 1]))
  plc_pin <- rbind(plc_pin, data.frame(Y = Y, es = kA, st = kS, cl = kC))
  nP <- mnote(sprintf("~ pp_break_%d", Y))
  mP <- fit3l(~ pp_break_tmp)
  cr <- coef_rows(mP, "B4", sprintf("placebo_%d", Y), nP)
  cr[[2]]$term <- sprintf("pp_break_%d", Y)
  cr[[2]]$note <- paste0(
    nP, sprintf("; post cell pinned: %d ES / %d studies / %d clusters; rule: share_%d >= 0.5, ties to Post [F60/DEC-024]; difference of Fisher-z means",
                kA, kS, kC, Y))
  b_abs[as.character(Y)] <- abs(cr[[2]]$est_z)
  rows <- c(rows, cr)
}
sub$pp_break_tmp <- NULL
b_abs["2016"] <- abs(as.numeric(mB$beta["pp_mid_lag0", 1]))
rk <- as.integer(rank(-b_abs, ties.method = "min")[["2016"]])
rows <- c(rows, list(scalar_row(
  "B4", "placebo_summary", "rank_2016_abs_break", metric = "rank",
  estimator = "3LMA-RVE_CR2", rho = RHO, value = rk,
  ms_input = TRUE, ms_label = "placebo_rank_2016",
  note = sprintf(
    "rank of |2016 break| among cutoffs 2008-2016 (1 = largest of 9), break-only form; |b| by year: %s",
    paste(sprintf("%s=%.4f", names(b_abs), b_abs), collapse = ", ")))))

# Segmented meta-regression (ITS; Move 2), knot-invariant parameterization
nS <- mnote("~ ts_knot * pp_mid_lag0 (ts_knot = sample_mid - 2015.5)")
mS <- fit3l(~ ts_knot * pp_mid_lag0)
crS <- coef_rows(mS, "B4", "segmented", nS,
  ms = "pp_mid_lag0",
  ms_lab = c(pp_mid_lag0 = "seg_level_shift"))
map <- c("intercept" = "level_at_knot_pre", "ts_knot" = "slope_pre",
         "pp_mid_lag0" = "level_shift_2016", "ts_knot:pp_mid_lag0" = "slope_change_2016")
for (i in seq_along(crS)) {
  if (crS[[i]]$term %in% names(map)) crS[[i]]$term <- map[[crS[[i]]$term]]
}
crS[[1]]$note <- paste0(nS, "; pre-segment level AT the knot (calendar 2015.5); NB: differs from the sample_mid_c-model intercept unless CENTER = 2015.5 (see design row center_sample_mid)")
rows <- c(rows, crS)
stopifnot(identical(names(coef(mS))[3:4],
                    c("pp_mid_lag0", "ts_knot:pp_mid_lag0")))    # idx guard
rows <- c(rows, list(wald_row(
  mS, idx = 3:4, "B4", "segmented", "wald_break_joint", nS,
  h0 = "H0: level shift = slope change = 0 at 2015.5")))

# ------------------------------ 6. B5 — composition control -----------
nC <- mnote("~ pp_mid_lag0 + country_region + COD_instrument + CER_measure")
mC <- fit3l(stats::reformulate(c("pp_mid_lag0", B5_COVARS)))
rows <- c(rows, coef_rows(mC, "B5", "composition_adj", nC,
  ms = "pp_mid_lag0", ms_lab = c(pp_mid_lag0 = "paris_comp_adj"),
  note_map = c(pp_mid_lag0 = "Move 4 core: Paris net of composition {region, instrument, CER measure} [F61; Section 6 drift disclosure]; difference of Fisher-z means")))
idx_comp_C <- which(!(names(coef(mC)) %in% c("intrcpt", "pp_mid_lag0")))
rows <- c(rows, list(wald_row(
  mC, idx = idx_comp_C, "B5", "composition_adj", "wald_composition_joint", nC,
  h0 = "H0: all composition coefficients = 0")))
d_unadj <- as.numeric(mC$beta["pp_mid_lag0", 1] - mB$beta["pp_mid_lag0", 1])
rows <- c(rows, list(scalar_row(
  "B5", "composition_adj", "delta_vs_break_only", metric = "Fisher_z",
  estimator = "3LMA-RVE_CR2", rho = RHO, value = d_unadj,
  note = "composition-adjusted minus unadjusted Paris coefficient (z-scale); anchor = break_only on the identical 2,705 domain [F61-P1]; verdict read-out: delta-beta + adjusted CI vs SESOI band (|r| = 0.070 primary, |delta r| = 0.05 secondary), not p-survival [F61-P3]")))

nF <- mnote("~ sample_mid_c + pp_mid_lag0 + country_region + COD_instrument + CER_measure")
mF <- fit3l(stats::reformulate(c("sample_mid_c", "pp_mid_lag0", B5_COVARS)))
rows <- c(rows, coef_rows(mF, "B5", "trend_composition", nF,
  ms = "pp_mid_lag0", ms_lab = c(pp_mid_lag0 = "paris_final_model"),
  note_map = c(pp_mid_lag0 = "final identification model: trend + composition [Identifikation tab, Move 7 target]; difference of Fisher-z means")))
idx_comp_F <- which(!(names(coef(mF)) %in% c("intrcpt", "sample_mid_c", "pp_mid_lag0")))
rows <- c(rows, list(wald_row(
  mF, idx = idx_comp_F, "B5", "trend_composition", "wald_composition_joint", nF,
  h0 = "H0: all composition coefficients = 0 (trend held)")))

# [F61-P2/P3] mechanical inference-status flags + read-out coding on B5 rows
for (i in seq_along(rows)) {
  r <- rows[[i]]
  if (!is.data.frame(r) || r$analysis_id != "B5") next
  if (identical(r$term, "pp_mid_lag0")) {
    st <- if (is.finite(r$df) && r$df >= 5)
      sprintf("full inference (df = %.1f >= 5)", r$df)
    else sprintf("descriptive (df = %.1f < 5)", r$df)
    rows[[i]]$note <- paste0(r$note,
      "; DEC-024 transfer rule applied: ", st,
      "; verdict read-out: delta-beta + adjusted CI vs SESOI band (|r| = 0.070 primary, |delta r| = 0.05 secondary), not p-survival [F61-P3]")
  }
  if (grepl("99_NCE", r$term)) {
    rows[[i]]$note <- paste0(r$note,
      "; level retained for domain completeness (99_NCE); not interpreted [F61-P2]")
  }
}

# ------------------------------ 7. B8 — bounding ----------------------
m0 <- fit3l(NULL)  # intercept-only on the same subset (R2 baseline only;
                   # its estimate is deliberately not written to the CSV)
S0 <- sum(m0$sigma2); SU <- sum(mR$sigma2); SC <- sum(mF$sigma2)   # [F61-P1] uncontrolled = race
R2u <- 1 - SU / S0; R2c <- 1 - SC / S0
bU  <- as.numeric(mR$beta["pp_mid_lag0", 1])                       # [F61-P1]
bC  <- as.numeric(mF$beta["pp_mid_lag0", 1])
Rmax <- min(OSTER_RMAX_F * R2c, 1)

oster_note <- paste0(
  "Oster-logic ANALOG on variance-component pseudo-R2: R2 = 1 - sum(sigma2_model)/sum(sigma2_intercept-only), same subset/V; ",
  "uncontrolled = race (time trend held in both models [F61-P1]), controlled = trend_composition; Rmax = min(1.3 x R2_c, 1) [Oster 2019]; pseudo-R2 can be negative (REML)")
den <- R2c - R2u
if (is.finite(den) && den > OSTER_GUARD) {
  beta_star  <- bC - (bU - bC) * (Rmax - R2c) / den
  delta_star <- (bC * den) / ((bU - bC) * (Rmax - R2c))
  guard_note <- oster_note
  guard_note_d <- oster_note
  if (!is.finite(delta_star)) {                     # [W2] second denominator
    delta_star   <- NA_real_
    guard_note_d <- paste0(oster_note,
      "; GUARD: |b_U - b_C| or (Rmax - R2_c) degenerate — delta* undefined, reported NA")
  }
} else {
  beta_star <- NA_real_; delta_star <- NA_real_
  guard_note <- paste0(oster_note, "; GUARD: R2_c - R2_u <= ", OSTER_GUARD,
                       " — bound uninformative, reported NA")
  guard_note_d <- guard_note
}

evalue_r <- function(r) {
  r <- abs(r); if (!is.finite(r) || r <= 0) return(1)
  if (r >= 1) return(Inf)
  d  <- 2 * r / sqrt(1 - r^2)
  RR <- exp(0.91 * d); if (RR < 1) RR <- 1 / RR
  RR + sqrt(RR * (RR - 1))
}
ciF <- conf_int(mF, vcov = vcr(mF), level = .95)
cfn <- if (!is.null(ciF$Coef)) as.character(ciF$Coef) else rownames(ciF)
iP  <- which(cfn == "pp_mid_lag0")
edge <- max(abs(c(ciF$CI_L[iP], ciF$CI_U[iP])))
ev_note <- "|delta z| read as |delta r| (third-order approx at these magnitudes); r->d = 2r/sqrt(1-r^2), RR approx exp(0.91 d) [VanderWeele & Ding 2017]"

rows <- c(rows, list(
  scalar_row("B8", "oster", "r2_uncontrolled", metric = "pseudo_R2",
             estimator = "Oster_analog", value = R2u, note = oster_note),
  scalar_row("B8", "oster", "r2_controlled", metric = "pseudo_R2",
             estimator = "Oster_analog", value = R2c, note = oster_note),
  scalar_row("B8", "oster", "beta_star_delta1", metric = "Fisher_z",
             estimator = "Oster_analog", value = beta_star,
             ms_input = TRUE, ms_label = "oster_beta_star",
             note = paste0(guard_note, "; delta = 1; z-scale")),
  scalar_row("B8", "oster", "delta_for_beta_zero", metric = "delta",
             estimator = "Oster_analog", value = delta_star,
             note = paste0(guard_note_d,
                           "; CAVEAT: near-null coefficients make delta* mechanically unstable — read jointly with beta_star and the mask E-values")),
  scalar_row("B8", "evalue", "evalue_point", metric = "E_value",
             estimator = "EValue_approx", value = evalue_r(bC),
             note = paste0("on |final-model Paris coefficient|; ", ev_note)),
  scalar_row("B8", "evalue", "evalue_ci_edge", metric = "E_value",
             estimator = "EValue_approx", value = evalue_r(edge),
             note = paste0("on max |CR2 CI bound| of the final-model Paris coefficient; ", ev_note)),
  scalar_row("B8", "evalue", "evalue_mask_sesoi_contrast", metric = "E_value",
             estimator = "EValue_approx", value = evalue_r(SESOI_CONTRAST),
             ms_input = TRUE, ms_label = "evalue_mask_005",
             note = paste0("confounding strength needed to mask a true |delta r| = 0.05 contrast [DEC-031 Block E secondary SESOI]; ", ev_note)),
  scalar_row("B8", "evalue", "evalue_mask_sesoi_pooled", metric = "E_value",
             estimator = "EValue_approx", value = evalue_r(SESOI_POOLED),
             note = paste0("mask reference at the pooled-mean SESOI |r| = 0.070 (F27v2) [DEC-031 Block E primary]; ", ev_note))
))

# ------------------------------ 8. Assemble + write -------------------
res <- do.call(rbind, rows)
stopifnot(identical(names(res), SCHEMA))
if (nrow(res) != N_ROWS_EXPECTED) {                          # [W1] diagnostic
  print(table(res$analysis_id, res$spec))
  stop(sprintf("ROW BUDGET MISMATCH: got %d, expected %d — see block table above.",
               nrow(res), N_ROWS_EXPECTED))
}
key <- paste(res$analysis_id, res$spec, res$term, sep = "||")
stopifnot(!anyDuplicated(key))

dir.create(here("output"), showWarnings = FALSE)
write_csv(res, here("output", "T8_results.csv"), na = "")
meta <- c(                                                  # [W3]
  sprintf("T8 run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("dat_prep md5:  %s",
          unname(tools::md5sum(here("output", "dat_prep.rds")))),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("domain: %d ES / %d studies / %d clusters [DEC-042b]",
          N_SUB, N_SUB_ST, N_SUB_CL),
  sprintf("CENTER (derived) = %.9f; OFFSET to calendar 2015.5 = %.9f",
          CENTER, OFFSET),
  sprintf("B5_LEVELS: %s (v12 pin, W1); reference levels: %s -- override of prep default (largest cell) per F61",
          paste(sprintf("%s=%d", names(B5_LEVELS), B5_LEVELS), collapse = ", "),
          paste(sprintf("%s=%s", names(B5_REFS), B5_REFS), collapse = "; ")),
  "F61 scope: B5 covariates = Move-4 drift set {region, instrument, CER measure}; without prejudice to DEC-043 (unified composition).",
  "F61-P1 Oster pair: uncontrolled = race, controlled = trend_composition (same 2,705 domain); delta anchor = break_only.",
  sprintf("F60 placebo post cells (in-script recode, ties->Post): %s",
          paste(sprintf("%d: %d/%d/%d", plc_pin$Y, plc_pin$es, plc_pin$st,
                        plc_pin$cl), collapse = "; ")),
  "SESOI sources: pooled 0.070 primary (F27v2), contrast 0.05 secondary [DEC-031 Block E].",
  sprintf("N_ROWS derived = %d (budget: 69 + 2*sum(B5_LEVELS-1)) [W1]",
          N_ROWS_EXPECTED),
  "", "sessionInfo():", utils::capture.output(utils::sessionInfo()))
writeLines(meta, here("output", "T8_run_meta.txt"))
cat(sprintf("T8 written: %d rows x %d cols -> output/T8_results.csv\n",
            nrow(res), ncol(res)))
cat("Input-contract asserts: ALL PASSED (see paired verifier for output checks).\n")
