# =============================================================================
# R/01_core.R -- T1 / Block A (A1-A8): core pooled analysis battery
# FOMA CER-COD (Paris moderator)
# -----------------------------------------------------------------------------
# Decision basis / source pointers:
#   [DEC-031]  Block A annex (roles); D31.1 inference unit = cluster_id;
#              D31.6 sample-size basis = column E ("n_eff").
#   [DEC-031a] .4 catalogue names; .6 inference conventions (no pairwise
#              spec-vs-headline tests); .7 figure inventory (A7/A8).
#   [DEC-042/042a] v12 canonical; estimation set 2,713 ES / 115 studies /
#              114 clusters (asserted constants).
#   [analysis_plan.md] par.3 (3LMA-RVE, rho = 0.6, grid 0.4/0.8), par.5 (CR2
#              everywhere), par.11 (output contract), Addendum A.1/A.2/A.7/A.8.
#   [DEC-012/DEC-012a] A6 economic translation (bp); extraction rule fixed
#              (instrument-level median SD(COD): loan/bond/CDS; Volker task);
#              constants PENDING DEC-012a -- placeholder grid, hard-flagged.
#   Author rulings 2026-07-12 (Gate 2): F53 -> DEC-012a (pending constants);
#              F54 ES-level HS/WAAP; F55 PI incl. omega^2 (plan Addendum A.8);
#              F56 V blocks on cluster_id (sample overlap, substantive).
#   UWLS+3: Stanley et al. (2024, RSM) Eq. (2)/(4)/(9) -- rp3 = t/sqrt(t^2+df+3),
#              var3 = (1-rp3^2)/(df+3) = 1/(t^2+df+3); df ~= n_eff [F21/DEC-028].
#   HS:     Stanley et al. (2025) Eq. (9)-(11), bare-bones n-weighted.
#   WAAP:   Stanley, Doucouliagos & Ioannidis (2017): powered iff
#              SE_i <= |UWLS|/2.8; <2 powered -> WAAP-UWLS fallback.
# Conventions fixed a priori; NO result-dependent branching anywhere below.
# Prediction-interval convention (F55, author-ruled; plan Addendum A.8):
#   PI = b +/- t_{df_Satt} * sqrt(SE_CR2^2 + sum of ALL THREE sigma2).
# Output contract [plan par.11]: output/T1_results.csv (long format, `spec`
#   column) + output/figures/* + output/T1_run_meta.txt.
# Paired verifier: R/01_verify_outputs.R (checks O1-O21).
# Canonical run: Claude Code via Rscript, verifier as oracle [Addendum A.7].
# =============================================================================

# ---- 0. CONFIG ---------------------------------------------------------------
# dat_prep schema is BINDING (author ruling 2026-07-12, from R/00_prep.R):
#   readRDS() returns a LIST `pr` with pr$dat (2,713 rows), pr$n, pr$seed.
#   Columns used in T1: zi, vi, cluster_id, study, esid, pp_mid_lag0, n_eff.
#   Present but unused in T1: r_raw, vi_k10/vi_k20, flag_starbound,
#   flag_proxy_n, sample_mid_c, pp_share_lag0, moderator factors (Blocks B-H).
# NO schema fix zone in this script: a schema mismatch is a STOP condition,
#   not a patch target (CC fix scope = syntax / package-API signatures only).
PATH_DAT_PREP <- here::here("output", "dat_prep.rds")   # T0.4 product (gitignored)
DIR_OUT       <- here::here("output")
DIR_FIG       <- file.path(DIR_OUT, "figures")
REQUIRED_COLS <- c("zi", "vi", "cluster_id", "study", "esid",
                   "pp_mid_lag0", "n_eff")

# Asserted design constants [DEC-042a; Addendum A.1/A.3] -- run stops on mismatch
K_ES <- 2713L; K_STUDY <- 115L; K_CLUSTER <- 114L; K_STUDY_POST <- 31L

RHO_HEADLINE <- 0.6                # [DEC-017]
RHO_GRID     <- c(0.4, 0.8)        # [E1 / battery A4]
SEED         <- 20260710           # battery seed convention; T1 is deterministic

# A6 (DEC-012/DEC-012a): Delta COD in bp per 1-SD CER = tanh(z_pooled) * SD.
# DEC-012a rule (author 2026-07-12): benchmark = median SD(COD) PER INSTRUMENT
# (loan/bond/CDS separately); Volker extraction pending. The generic grid below
# is a PLACEHOLDER until those constants land; A6 rows then re-key to
# bp_per_1sd_{loan,bond,cds} in a deterministic constants-patch re-run.
SD_COD_BP_GRID <- c(100, 150, 200) # <<< PLACEHOLDER -- PENDING DEC-012a >>>
SMALL_BENCH_R  <- 0.07             # Doucouliagos (2011) "small" anchor [DEC-012]

PLOT_NAVY <- "#1F3864"             # output contract [plan par.11]
PLOT_FAMILY_TRY <- "DejaVu Serif"  # falls back to "serif" if unavailable

# ---- 1. Libraries & session --------------------------------------------------
suppressPackageStartupMessages({
  library(metafor)       # 5.0.1 per renv lockfile
  library(clubSandwich)  # 0.7.0 per renv lockfile
  library(ggplot2)
})
set.seed(SEED)
dir.create(DIR_OUT, showWarnings = FALSE, recursive = TRUE)
dir.create(DIR_FIG, showWarnings = FALSE, recursive = TRUE)

# ---- 2. Load + input contract (fail fast) ------------------------------------
if (!file.exists(PATH_DAT_PREP))
  stop("output/dat_prep.rds not found. Run R/00_prep.R + R/00_verify_prep.R ",
       "first (T0.4). STOP condition -- do not improvise paths.")
pr <- readRDS(PATH_DAT_PREP)
if (!is.list(pr) || is.null(pr$dat))
  stop("dat_prep.rds is not the R/00_prep.R list contract (pr$dat missing). ",
       "STOP condition -- binding schema per author ruling 2026-07-12.")
stopifnot(
  "pr$n != 2713 [DEC-042a]" = identical(as.integer(pr$n), K_ES),
  "pr$seed != 20260710"     = identical(as.integer(pr$seed), 20260710L)
)
dat_raw <- pr$dat

missing_cols <- setdiff(REQUIRED_COLS, names(dat_raw))
if (length(missing_cols))
  stop("dat_prep schema contract violated -- missing column(s): ",
       paste(missing_cols, collapse = ", "),
       ". Binding schema (author ruling 2026-07-12); STOP condition, do not patch.")

d <- data.frame(
  yi      = as.numeric(dat_raw$zi),      # Fisher-z PCC, direction-harmonized
  vi      = as.numeric(dat_raw$vi),      # 1/(n_eff - 3) [D31.6]
  cluster = factor(dat_raw$cluster_id),  # inference unit [D31.1]
  study   = factor(dat_raw$study),
  esid    = factor(dat_raw$esid),
  period  = as.integer(as.character(dat_raw$pp_mid_lag0)),  # factor-safe 0/1
  n_eff   = as.numeric(dat_raw$n_eff)    # column-E basis [D31.6]
)

stopifnot(
  "NA in yi/vi"            = !anyNA(d$yi) && !anyNA(d$vi),
  "non-positive vi"        = all(d$vi > 0),
  "NA/invalid n_eff"       = all(is.finite(d$n_eff) & d$n_eff > 3),
  "period not in {0,1}"    = all(d$period %in% c(0L, 1L)),
  "NA cluster/study/esid"  = !anyNA(d$cluster) && !anyNA(d$study) && !anyNA(d$esid)
)
# Estimation-set identity [DEC-042a] -- STRICT: no silent filtering here.
if (nrow(d) != K_ES)
  stop("Estimation set mismatch: nrow = ", nrow(d), ", expected ", K_ES,
       " [DEC-042a]. dat_prep must already BE the estimation set; ",
       "do not filter inside 01_core.R.")
stopifnot(
  "study count != 115"   = nlevels(droplevels(d$study))   == K_STUDY,
  "cluster count != 114" = nlevels(droplevels(d$cluster)) == K_CLUSTER
)

# ---- 3. Helpers (frozen) ------------------------------------------------------
`%||%` <- function(a, b) if (is.null(a)) b else a
pick_df <- function(x) as.numeric(x$df_Satt %||% x$df)

fit_3lma <- function(dd, rho) {
  # CHE working model [Pustejovsky & Tipton 2022]. V blocks on CLUSTER_ID
  # [D31.1; F56 author-confirmed 2026-07-12]: the one multi-study cluster
  # (Sandra/Ofogbe, DEC-042a) exists BECAUSE of sample overlap, so sampling
  # errors correlate at CLUSTER level -- V on cluster_id is substantively
  # correct, not merely wording-compliant. Not thematized in Methods.
  V <- clubSandwich::impute_covariance_matrix(vi = dd$vi, cluster = dd$cluster, r = rho)
  metafor::rma.mv(yi = yi, V = V, random = ~ 1 | cluster/study/esid,
                  data = dd, sparse = TRUE, method = "REML")
}

rob_stats <- function(m, dd) {
  ct <- clubSandwich::coef_test(m, vcov = "CR2", cluster = dd$cluster,
                                test = "Satterthwaite")
  ci <- clubSandwich::conf_int(m, vcov = "CR2", cluster = dd$cluster)
  list(est = as.numeric(ct$beta[1]), se = as.numeric(ct$SE[1]),
       t = as.numeric(ct$tstat[1]),  df = pick_df(ct)[1],
       p = as.numeric(ct$p_Satt[1]),
       ci_lb = as.numeric(ci$CI_L[1]), ci_ub = as.numeric(ci$CI_U[1]),
       sigma2 = as.numeric(m$sigma2))
}

pi_bounds <- function(est, se, df, sigma2_sum) {
  # F55 [author ruling 2026-07-12; plan Addendum A.8]: sigma2_sum = ALL THREE
  # variance components incl. effect-level omega^2 -- effect-level
  # heterogeneity is real and the PI shows the plausible range of a single
  # new effect, so omitting omega^2 would understate it (conservative choice).
  # Pre/post-period PIs are constructed identically on their subset fits.
  half <- qt(0.975, df) * sqrt(se^2 + sigma2_sum)
  c(lb = est - half, ub = est + half)
}

agg_rho <- function(dd, unit_col, rho) {
  # Borenstein CS aggregation (metafor::aggregate.escalc), rho as working corr.
  esc <- metafor::escalc(measure = "GEN", yi = dd$yi, vi = dd$vi,
                         data = data.frame(agg_unit = dd[[unit_col]]))
  ag  <- aggregate(esc, cluster = agg_unit, rho = rho)
  data.frame(unit = ag$agg_unit, yi = as.numeric(ag$yi), vi = as.numeric(ag$vi))
}

typical_v <- function(vi) {
  # Higgins-Thompson "typical" sampling variance (I^2 machinery)
  w <- 1 / vi; k <- length(vi)
  (k - 1) * sum(w) / (sum(w)^2 - sum(w^2))
}

SCHEMA <- c("analysis_id", "spec", "subset", "metric", "estimator", "rho",
            "k_es", "k_study", "k_cluster",
            "est_z", "se_z", "t_stat", "df", "p",
            "ci_lb_z", "ci_ub_z", "pi_lb_z", "pi_ub_z",
            "est_r", "ci_lb_r", "ci_ub_r", "pi_lb_r", "pi_ub_r",
            "sigma2_cluster", "sigma2_study", "sigma2_esid",
            "pct_cluster", "pct_study", "pct_esid", "pct_sampling", "typical_v",
            "value", "ms_input", "ms_label", "note")

new_row <- function(...) {
  r <- setNames(as.list(rep(NA, length(SCHEMA))), SCHEMA)
  a <- list(...); r[names(a)] <- a
  as.data.frame(r, stringsAsFactors = FALSE)
}

kset <- function(dd) list(k_es = nrow(dd),
                          k_study = nlevels(droplevels(dd$study)),
                          k_cluster = nlevels(droplevels(dd$cluster)))

rows <- list()

# ---- 4. A1 -- headline 3LMA-RVE (rho = 0.6) -----------------------------------
m1 <- fit_3lma(d, RHO_HEADLINE)
s1 <- rob_stats(m1, d)
s1_pi <- pi_bounds(s1$est, s1$se, s1$df, sum(s1$sigma2))
k1 <- kset(d)
rows$A1 <- new_row(analysis_id = "A1", spec = "headline", subset = "all",
  metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO_HEADLINE,
  k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
  est_z = s1$est, se_z = s1$se, t_stat = s1$t, df = s1$df, p = s1$p,
  ci_lb_z = s1$ci_lb, ci_ub_z = s1$ci_ub,
  pi_lb_z = s1_pi["lb"], pi_ub_z = s1_pi["ub"],
  est_r = tanh(s1$est), ci_lb_r = tanh(s1$ci_lb), ci_ub_r = tanh(s1$ci_ub),
  pi_lb_r = tanh(s1_pi["lb"]), pi_ub_r = tanh(s1_pi["ub"]),
  sigma2_cluster = s1$sigma2[1], sigma2_study = s1$sigma2[2],
  sigma2_esid = s1$sigma2[3],
  ms_input = TRUE, ms_label = "headline_pooled",
  note = "rma.mv ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6 [D31.1/F56: sample-overlap cluster]; CR2/Satterthwaite on cluster_id")

# ---- 5. A2 -- variance decomposition ------------------------------------------
tv <- typical_v(d$vi)
tot <- sum(s1$sigma2) + tv
rows$A2 <- new_row(analysis_id = "A2", spec = "var_decomposition", subset = "all",
  metric = "Fisher_z", estimator = "3LMA-RVE_REML", rho = RHO_HEADLINE,
  k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
  sigma2_cluster = s1$sigma2[1], sigma2_study = s1$sigma2[2],
  sigma2_esid = s1$sigma2[3],
  pct_cluster = s1$sigma2[1] / tot, pct_study = s1$sigma2[2] / tot,
  pct_esid = s1$sigma2[3] / tot, pct_sampling = tv / tot, typical_v = tv,
  ms_input = TRUE, ms_label = "variance_decomposition",
  note = "Cluster/study split weakly identified by design (1 multi-study cluster, DEC-042a); battery A2: '+Cluster-Ebene wo schaetzbar'. Sampling share via Higgins-Thompson typical v.")

# ---- 6. A3 -- prediction intervals: overall + per period ----------------------
rows$A3_overall <- new_row(analysis_id = "A3", spec = "pi_overall", subset = "all",
  metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO_HEADLINE,
  k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
  est_z = s1$est, se_z = s1$se, df = s1$df,
  ci_lb_z = s1$ci_lb, ci_ub_z = s1$ci_ub,
  pi_lb_z = s1_pi["lb"], pi_ub_z = s1_pi["ub"],
  est_r = tanh(s1$est), ci_lb_r = tanh(s1$ci_lb), ci_ub_r = tanh(s1$ci_ub),
  pi_lb_r = tanh(s1_pi["lb"]), pi_ub_r = tanh(s1_pi["ub"]),
  ms_input = TRUE, ms_label = "pi_overall",
  note = "Identical fit to A1 (verifier identity O20). PI = est +/- t_dfSatt*sqrt(SE_CR2^2+sum(sigma2)) [F55].")

for (pp in c(0L, 1L)) {
  lab <- if (pp == 0L) "pre" else "post"
  dp  <- droplevels(d[d$period == pp, , drop = FALSE])
  mp  <- fit_3lma(dp, RHO_HEADLINE)
  sp  <- rob_stats(mp, dp)
  ppi <- pi_bounds(sp$est, sp$se, sp$df, sum(sp$sigma2))
  kp  <- kset(dp)
  rows[[paste0("A3_", lab)]] <- new_row(analysis_id = "A3",
    spec = paste0("pi_", lab), subset = lab,
    metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO_HEADLINE,
    k_es = kp$k_es, k_study = kp$k_study, k_cluster = kp$k_cluster,
    est_z = sp$est, se_z = sp$se, t_stat = sp$t, df = sp$df, p = sp$p,
    ci_lb_z = sp$ci_lb, ci_ub_z = sp$ci_ub,
    pi_lb_z = ppi["lb"], pi_ub_z = ppi["ub"],
    est_r = tanh(sp$est), ci_lb_r = tanh(sp$ci_lb), ci_ub_r = tanh(sp$ci_ub),
    pi_lb_r = tanh(ppi["lb"]), pi_ub_r = tanh(ppi["ub"]),
    sigma2_cluster = sp$sigma2[1], sigma2_study = sp$sigma2[2],
    sigma2_esid = sp$sigma2[3],
    ms_input = TRUE, ms_label = paste0("pi_", lab),
    note = "Descriptive per-period fit on pp_mid_lag0 subset; straddling studies appear in both cells (design fact); NO between-group test here (that is B1) [DEC-031a.6].")
}

# ---- 7. A4 -- rho sensitivity --------------------------------------------------
for (rr in RHO_GRID) {
  mr <- fit_3lma(d, rr)
  sr <- rob_stats(mr, d)
  rpi <- pi_bounds(sr$est, sr$se, sr$df, sum(sr$sigma2))
  rows[[paste0("A4_", rr)]] <- new_row(analysis_id = "A4",
    spec = sprintf("rho_%.1f", rr), subset = "all",
    metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = rr,
    k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
    est_z = sr$est, se_z = sr$se, t_stat = sr$t, df = sr$df, p = sr$p,
    ci_lb_z = sr$ci_lb, ci_ub_z = sr$ci_ub,
    pi_lb_z = rpi["lb"], pi_ub_z = rpi["ub"],
    est_r = tanh(sr$est), ci_lb_r = tanh(sr$ci_lb), ci_ub_r = tanh(sr$ci_ub),
    pi_lb_r = tanh(rpi["lb"]), pi_ub_r = tanh(rpi["ub"]),
    sigma2_cluster = sr$sigma2[1], sigma2_study = sr$sigma2[2],
    sigma2_esid = sr$sigma2[3],
    ms_input = FALSE, ms_label = NA,
    note = "Spec-label compatible with catalogue G long table [battery A4 remark].")
}

# ---- 8. A5 -- estimator robustness --------------------------------------------
# (a) one-effect-per-cluster, Borenstein rho aggregation [DEC-031a.4 primary]
agc <- agg_rho(d, "cluster", RHO_HEADLINE)
m_opc <- metafor::rma(yi = yi, vi = vi, data = agc, method = "REML", test = "knha")
rows$A5_opc <- new_row(analysis_id = "A5", spec = "one_effect_per_cluster",
  subset = "all", metric = "Fisher_z", estimator = "RE_REML_KnHa", rho = RHO_HEADLINE,
  k_es = nrow(agc), k_study = NA, k_cluster = nrow(agc),
  est_z = as.numeric(m_opc$beta), se_z = m_opc$se, t_stat = as.numeric(m_opc$zval),
  df = m_opc$k - 1, p = m_opc$pval,
  ci_lb_z = m_opc$ci.lb, ci_ub_z = m_opc$ci.ub,
  est_r = tanh(as.numeric(m_opc$beta)),
  ci_lb_r = tanh(m_opc$ci.lb), ci_ub_r = tanh(m_opc$ci.ub),
  ms_input = FALSE, ms_label = NA,
  note = "aggregate.escalc CS rho=0.6 within cluster_id; RE REML + Knapp-Hartung on k=114 aggregates.")

# (b) UWLS+3 [Stanley et al. 2024; plan par.9]: PCC metric, df ~= n_eff (F21)
r_h  <- tanh(d$yi)   # harmonized r = tanh(zi); do NOT use pr$dat$r_raw (pre-harmonization)
t_i  <- r_h * sqrt(d$n_eff) / sqrt(1 - r_h^2)     # invert coding-time route
rp3  <- t_i / sqrt(t_i^2 + d$n_eff + 3)           # Eq (9), df+3 = n_eff+3
v3   <- (1 - rp3^2) / (d$n_eff + 3)               # S2^2 at df+3 = 1/(t^2+df+3)
w3   <- 1 / v3
f_u3 <- lm(rp3 ~ 1, weights = w3)
se_conv <- summary(f_u3)$coefficients[1, 2]        # conventional UWLS SE
ct_u3 <- clubSandwich::coef_test(f_u3, vcov = "CR2", cluster = d$cluster,
                                 test = "Satterthwaite")
ci_u3 <- clubSandwich::conf_int(f_u3, vcov = "CR2", cluster = d$cluster)
u3_est <- as.numeric(ct_u3$beta[1])
rows$A5_uwls3 <- new_row(analysis_id = "A5", spec = "uwls3", subset = "all",
  metric = "PCC_r", estimator = "UWLS+3_CR2", rho = NA,
  k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
  est_z = atanh(u3_est), se_z = NA,
  t_stat = as.numeric(ct_u3$tstat[1]), df = pick_df(ct_u3)[1],
  p = as.numeric(ct_u3$p_Satt[1]),
  ci_lb_z = atanh(as.numeric(ci_u3$CI_L[1])), ci_ub_z = atanh(as.numeric(ci_u3$CI_U[1])),
  est_r = u3_est, ci_lb_r = as.numeric(ci_u3$CI_L[1]), ci_ub_r = as.numeric(ci_u3$CI_U[1]),
  ms_input = FALSE, ms_label = NA,
  note = sprintf("rp3=t/sqrt(t^2+n_eff+3), var3=1/(t^2+n_eff+3) [Stanley et al. 2024 Eq 2/4/9; df~=n_eff per F21]; CR2 on cluster_id [plan par.5]; conventional UWLS SE = %.6f.", se_conv))

# (c) HS bare-bones [Stanley et al. 2025 Eq 9-11] -- appendix (F54 convention)
n_i   <- d$n_eff
r_bar <- sum(n_i * r_h) / sum(n_i)
sd2_r <- sum(n_i * (r_h - r_bar)^2) / sum(n_i)
se_hs <- sqrt(sd2_r / length(r_h))
rows$A5_hs <- new_row(analysis_id = "A5", spec = "hs_es_level", subset = "all",
  metric = "PCC_r", estimator = "HS_bare_bones", rho = NA,
  k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
  est_z = atanh(r_bar), se_z = NA, df = NA, p = NA,
  ci_lb_z = atanh(r_bar - 1.96 * se_hs), ci_ub_z = atanh(r_bar + 1.96 * se_hs),
  est_r = r_bar, ci_lb_r = r_bar - 1.96 * se_hs, ci_ub_r = r_bar + 1.96 * se_hs,
  ms_input = FALSE, ms_label = NA,
  note = sprintf("n-weighted mean r; SE = SD_w/sqrt(k), k = %d ES -- anti-conservative under dependence; descriptive appendix benchmark [F54]. SE_HS = %.6f.", length(r_h), se_hs))

# (d) WAAP-UWLS [Stanley et al. 2017] -- appendix; proxy effect = UWLS+3
powered <- sqrt(v3) <= abs(u3_est) / 2.8
n_pow   <- sum(powered)
if (n_pow >= 2L) {
  f_w  <- lm(rp3[powered] ~ 1, weights = w3[powered])
  cl_w <- droplevels(d$cluster[powered])
  ct_w <- clubSandwich::coef_test(f_w, vcov = "CR2", cluster = cl_w,
                                  test = "Satterthwaite")
  ci_w <- clubSandwich::conf_int(f_w, vcov = "CR2", cluster = cl_w)
  rows$A5_waap <- new_row(analysis_id = "A5", spec = "waap_uwls", subset = "powered",
    metric = "PCC_r", estimator = "WAAP_CR2", rho = NA,
    k_es = n_pow, k_study = NA, k_cluster = nlevels(cl_w),
    est_z = atanh(as.numeric(ct_w$beta[1])),
    t_stat = as.numeric(ct_w$tstat[1]), df = pick_df(ct_w)[1],
    p = as.numeric(ct_w$p_Satt[1]),
    ci_lb_z = atanh(as.numeric(ci_w$CI_L[1])), ci_ub_z = atanh(as.numeric(ci_w$CI_U[1])),
    est_r = as.numeric(ct_w$beta[1]),
    ci_lb_r = as.numeric(ci_w$CI_L[1]), ci_ub_r = as.numeric(ci_w$CI_U[1]),
    ms_input = FALSE, ms_label = NA,
    note = sprintf("Adequately powered: SE_i <= |UWLS+3|/2.8; k_powered = %d of %d ES.", n_pow, k1$k_es))
} else {
  rows$A5_waap <- new_row(analysis_id = "A5", spec = "waap_uwls", subset = "all",
    metric = "PCC_r", estimator = "WAAP_fallback_UWLS", rho = NA,
    k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
    est_z = atanh(u3_est), est_r = u3_est,
    ci_lb_r = as.numeric(ci_u3$CI_L[1]), ci_ub_r = as.numeric(ci_u3$CI_U[1]),
    ci_lb_z = atanh(as.numeric(ci_u3$CI_L[1])), ci_ub_z = atanh(as.numeric(ci_u3$CI_U[1])),
    ms_input = FALSE, ms_label = NA,
    note = sprintf("WAAP-UWLS: %d adequately powered (<2) -> reduces to UWLS+3 [Stanley et al. 2017]. Power statement feeds the null narrative (Ioannidis et al. 2017).", n_pow))
}

# ---- 9. A6 -- economic translation (DEC-012/012a; constants pending) -----------
r_head <- tanh(s1$est)
for (sd_bp in SD_COD_BP_GRID) {
  rows[[paste0("A6_", sd_bp)]] <- new_row(analysis_id = "A6",
    spec = sprintf("bp_per_1sd_sd%d", sd_bp), subset = "all",
    metric = "bp_COD", estimator = "translation", rho = NA,
    k_es = k1$k_es, k_study = k1$k_study, k_cluster = k1$k_cluster,
    est_r = r_head, value = r_head * sd_bp,
    ci_lb_r = tanh(s1$ci_lb), ci_ub_r = tanh(s1$ci_ub),
    ms_input = TRUE, ms_label = sprintf("bp_translation_sd%d", sd_bp),
    note = sprintf("Delta COD (bp) per 1-SD CER = tanh(z_pooled) * SD_COD_bp; SD_COD_bp = %d <<< PLACEHOLDER -- PENDING DEC-012a (instrument medians via Volker task) >>>. CI endpoints scale identically (value column = point).", sd_bp))
}
rows$A6_bench <- new_row(analysis_id = "A6", spec = "small_benchmark_ratio",
  subset = "all", metric = "ratio", estimator = "translation", rho = NA,
  est_r = r_head, value = r_head / SMALL_BENCH_R,
  ms_input = TRUE, ms_label = "doucouliagos_small_ratio",
  note = "Pooled r over Doucouliagos (2011) 'small' benchmark 0.07 [DEC-012 rationale]; constant-free.")

# ---- 10. A7 -- caterpillar plot (cluster aggregates, unlabeled) ----------------
fam <- PLOT_FAMILY_TRY
save_fig <- function(path, plot, width, height, dpi = 300) {
  dev <- if (grepl("\\.pdf$", path)) grDevices::cairo_pdf else NULL
  tryCatch(
    ggsave(path, plot, width = width, height = height, dpi = dpi, device = dev),
    error = function(e) {   # font fallback: rebuild with generic serif
      message("save_fig fallback to 'serif' for ", basename(path), ": ", conditionMessage(e))
      ggsave(path, plot + theme(text = element_text(family = "serif")),
             width = width, height = height, dpi = dpi, device = dev)
    })
}
agc$r    <- tanh(agc$yi)
agc$r_lb <- tanh(agc$yi - 1.96 * sqrt(agc$vi))
agc$r_ub <- tanh(agc$yi + 1.96 * sqrt(agc$vi))
agc$rank <- rank(agc$r, ties.method = "first")
p7 <- ggplot(agc, aes(x = rank, y = r)) +
  geom_hline(yintercept = tanh(s1$est), colour = PLOT_NAVY, linewidth = 0.6) +
  geom_hline(yintercept = c(tanh(s1_pi["lb"]), tanh(s1_pi["ub"])),
             colour = PLOT_NAVY, linetype = "dashed", linewidth = 0.4) +
  geom_linerange(aes(ymin = r_lb, ymax = r_ub), colour = PLOT_NAVY, alpha = 0.45) +
  geom_point(colour = PLOT_NAVY, size = 0.9) +
  labs(x = sprintf("Cluster aggregates (k = %d), sorted", nrow(agc)),
       y = "Partial correlation (r)",
       caption = "Solid line: pooled 3LMA-RVE estimate; dashed: 95% prediction interval.") +
  theme_minimal(base_family = fam, base_size = 10) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        panel.grid.minor = element_blank())
save_fig(file.path(DIR_FIG, "T1_A7_caterpillar_cluster.pdf"), p7, 7.5, 4.8)
save_fig(file.path(DIR_FIG, "T1_A7_caterpillar_cluster.png"), p7, 7.5, 4.8)

# ---- 11. A8 -- study-level forest plot (labeled, full page) --------------------
ags <- agg_rho(d, "study", RHO_HEADLINE)
ags$r    <- tanh(ags$yi)
ags$r_lb <- tanh(ags$yi - 1.96 * sqrt(ags$vi))
ags$r_ub <- tanh(ags$yi + 1.96 * sqrt(ags$vi))
ags$label <- as.character(ags$unit)
p8 <- ggplot(ags, aes(x = r, y = reorder(label, r))) +
  geom_vline(xintercept = tanh(s1$est), colour = PLOT_NAVY, linewidth = 0.5) +
  geom_vline(xintercept = 0, colour = "grey55", linewidth = 0.3) +
  geom_linerange(aes(xmin = r_lb, xmax = r_ub), colour = PLOT_NAVY, alpha = 0.6) +
  geom_point(colour = PLOT_NAVY, size = 0.8) +
  labs(x = "Partial correlation (r), 95% CI",
       y = NULL,
       caption = sprintf("Study-level rho=0.6 aggregates (k = %d); vertical line: pooled 3LMA-RVE estimate.", nrow(ags))) +
  theme_minimal(base_family = fam, base_size = 7) +
  theme(panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 4.6))
save_fig(file.path(DIR_FIG, "T1_A8_forest_study.pdf"), p8, 8.27, 11.69)  # A4 full page

# ---- 12. Write outputs ---------------------------------------------------------
res <- do.call(rbind, rows)
res <- res[, SCHEMA]
write.csv(res, file.path(DIR_OUT, "T1_results.csv"), row.names = FALSE, na = "")

meta <- c(
  sprintf("T1 run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("dat_prep path: %s", PATH_DAT_PREP),
  sprintf("dat_prep md5:  %s", unname(tools::md5sum(PATH_DAT_PREP))),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("rows/studies/clusters: %d / %d / %d", nrow(d),
          nlevels(d$study), nlevels(d$cluster)),
  sprintf("seed: %d (T1 deterministic; set defensively)", SEED),
  sprintf("SD_COD_BP_GRID (PLACEHOLDER, PENDING DEC-012a): %s",
          paste(SD_COD_BP_GRID, collapse = ", ")),
  "", "sessionInfo():", capture.output(sessionInfo())
)
writeLines(meta, file.path(DIR_OUT, "T1_run_meta.txt"))

cat("T1 complete:", nrow(res), "result rows ->", file.path(DIR_OUT, "T1_results.csv"), "\n")
