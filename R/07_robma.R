# =====================================================================
# R/07_robma.R — TH-b: Bayes battery H2a (level) / H2b (moderation)
# FOMA CER–COD–Paris | verifier-paired · FOUNDATIONAL (pre-execution
# diff review, author ruling B-Q1 2026-07-27) · author GO before run
# ---------------------------------------------------------------------
# Authority: DEC-045 (H2a/H2b pins; priors; fallback rule) · DEC-046
#   (F66 closure: RoBMA 3.6.1 + BayesTools 0.2.23 pinned per upstream
#   reproduction guidance; y/se scale path — priors act verbatim on the
#   Fisher-z scale; effect_direction = "negative" [P-T5-2 transfer];
#   t_RoBMA = 1,764.8 s) · DEC-031b (prior sets; COE companion = ONLY
#   admissible external prior source; circular-prior prohibition) ·
#   DEC-044 (framing gate: NO interpretation anywhere in this script) ·
#   DEC-042a/b (domains) · DEC-017 (rho) · F65 pattern (identity checks
#   live in the paired verifier).
# Scope: H2a = RoBMA on one-effect-per-cluster aggregates, k = 114,
#   three prior sets (PSMA defaults primary · COE-informed · wide).
#   H2b = RoBMA.reg on cluster x period aggregates, 113 rows (Li et al.
#   2022 = the single both-period cluster, disclosed), moderation prior
#   sets (contrast-informed Normal(0, 0.025) · contrast-wide
#   Normal(0, 0.050) · package factor default). RoBMA.reg exported on
#   the pinned version (v3 handshake) — the DEC-045 fallback does NOT
#   fire.
# Not here (single-home): level pre/post cell estimates (T2/B1),
#   frequentist selection models (T5/D2), D3 label (H2 supersedes).
# Output: output/TH_b_results.csv — T2 schema (36 columns);
#   deterministic row budget N_ROWS = 30 (7 design + 15 H2a + 8 H2b;
#   all planned keys always written; MCMC failures surface as
#   not_estimable rows, never as missing rows);
#   output/TH_b_run_meta.txt (md5, pins, per-fit priors/timings/
#   diagnostics, BFPAIR machine lines, sessionInfo).
# Result framing: NONE. BF01 values are written raw; band labels and
#   any adjudication live downstream of the documented gate-resolution
#   step [DEC-044].
# [R7-PRE] Extraction smoke test: before any canonical fit, both
#   extraction machineries run on tiny SYNTHETIC fits (non-canonical
#   MCMC settings, objects discarded) so accessor mismatches fix-zone-
#   stop in minutes, not after hours of canonical sampling.
# =====================================================================

suppressPackageStartupMessages({
  library(RoBMA)        # 3.6.1 pin [DEC-046]
  library(BayesTools)   # 0.2.23 pin [DEC-046]
  library(metafor)      # aggregate.escalc (T1/A5 convention)
  library(here)
  library(readr)
})

# ------------------------------ 0. Constants (FROZEN ZONE) ------------
ROBMA_PIN <- "3.6.1"; BT_PIN <- "0.2.23"              # DEC-046
RHO           <- 0.6                                   # DEC-017
DAT_PREP_MD5  <- "6702ef3dc45fe0b693b13f50ebd1576b"    # input contract pin
SEED          <- 20260710L
N_SET <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L     # DEC-042a
N_SUB <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L     # DEC-042b
K_NA_ES <- 8L;  K_NA_ST <- 2L                          # DEC-042b
POST16 <- c(es = 711L, st = 31L, cl = 31L)             # v12 design constants
K_AGG_FULL <- 114L                                     # T1/A5 convention
H2B_ROWS <- 113L; H2B_POST <- 31L                      # DEC-045
H2B_PRE  <- H2B_ROWS - H2B_POST                        # = 82 (arithmetic pin)
H2B_BOTH <- 1L                                         # Li et al. 2022 (disclosed)

# Prior constants [DEC-031b; DEC-045; DEC-046 scale path: Fisher-z]
MU_COE  <- -0.041                    # COE Table 2 overall r (z ~ r, T8/B8)
SD_COE  <- 0.083 / 3.92              # = 0.0212 (provenance arithmetic)
SD_WIDE <- 2 * SD_COE                # = 0.0423 ("wide = 2 sigma")
SD_CONTRAST      <- 0.025            # secondary SESOI band /2 [DEC-045]
SD_CONTRAST_WIDE <- 0.050
EFF_DIR <- "negative"                # P-T5-2 transfer [DEC-046]
TRANSF  <- "none"; PSCALE <- "none"  # explicit == y-route defaults [DEC-046]

# [P-T5-4 analog, RoBMA/MCMC signature list — REVIEW POINT at the B-Q1
# diff review; extendable only by DEC] case-insensitive substrings:
NONCONV_SIG <- c("converg", "r-hat", "rhat", "effective sample size",
                 "bridge sampl", "node inconsistent", "unable to initialize")

SUBSET_FULL <- "full"; SUBSET_DEF <- "defined"
N_ROWS_EXPECTED <- 30L    # 7 design + 3x5 H2a + (3+3+2) H2b

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

`%||%` <- function(a, b) if (is.null(a)) b else a

# Version hard asserts [DEC-046] -----------------------------------------
if (!identical(as.character(packageVersion("RoBMA")), ROBMA_PIN) ||
    !identical(as.character(packageVersion("BayesTools")), BT_PIN))
  stop("VERSION-PIN ANOMALY [DEC-046] — installed RoBMA ",
       packageVersion("RoBMA"), " / BayesTools ",
       packageVersion("BayesTools"), "; pinned ", ROBMA_PIN, " / ", BT_PIN)
if (!("RoBMA.reg" %in% getNamespaceExports("RoBMA")))
  stop("VERSION-PIN ANOMALY [DEC-046] — RoBMA.reg not exported (H2b carrier)")
for (fn in c("prior", "prior_factor"))
  if (!(fn %in% getNamespaceExports("RoBMA")))
    stop("PACKAGE-API MISMATCH (fix zone: Paket-API) — RoBMA does not ",
         "export ", fn, "(); adjust the accessor, not the pins.")

# ------------------------------ 1. Load + input contract --------------
f_prep <- here("output", "dat_prep.rds")
stopifnot(file.exists(f_prep))
md5_obs <- unname(tools::md5sum(f_prep))
if (!identical(md5_obs, DAT_PREP_MD5))
  stop("INPUT CONTRACT HARD STOP — dat_prep.rds md5 mismatch: observed ",
       md5_obs, ", pinned ", DAT_PREP_MD5)
pr <- readRDS(f_prep)
stopifnot(is.list(pr), !is.null(pr$dat), pr$n == N_SET, pr$seed == SEED)
set.seed(pr$seed)
dat <- pr$dat

need <- c("zi", "vi", "cluster_id", "study", "esid", "pp_mid_lag0")
miss <- setdiff(need, names(dat))
if (length(miss)) stop("SCHEMA HARD STOP — missing columns: ",
                       paste(miss, collapse = ", "))
stopifnot(nrow(dat) == N_SET,
          length(unique(dat$study)) == N_SET_ST,
          length(unique(dat$cluster_id)) == N_SET_CL,
          is.numeric(dat$zi), all(is.finite(dat$zi)),
          is.numeric(dat$vi), all(is.finite(dat$vi)), all(dat$vi > 0))

na_win <- is.na(dat$pp_mid_lag0)                       # DEC-042b
stopifnot(sum(na_win) == K_NA_ES,
          length(unique(dat$study[na_win])) == K_NA_ST)
sub <- dat[!na_win, , drop = FALSE]
stopifnot(nrow(sub) == N_SUB,
          length(unique(sub$study)) == N_SUB_ST,
          length(unique(sub$cluster_id)) == N_SUB_CL,
          all(sub$pp_mid_lag0 %in% 0:1))
p16 <- sub$pp_mid_lag0 == 1
stopifnot(sum(p16) == POST16["es"],
          length(unique(sub$study[p16])) == POST16["st"],
          length(unique(sub$cluster_id[p16])) == POST16["cl"])

# ------------------------------ 2. Aggregates [T1/A5 convention] ------
# make_agg — verbatim from committed R/05_bias.R [DEC-031g/F65 call pin]
make_agg <- function(d, expected_k) {
  X <- data.frame(yi = d$zi, vi = d$vi, cluster_id = d$cluster_id)
  datE <- metafor::escalc(measure = "GEN", yi = yi, vi = vi, data = X)
  agg  <- aggregate(datE, cluster = cluster_id, struct = "CS", rho = RHO)
  stopifnot(nrow(agg) == expected_k, !anyNA(agg$yi), all(agg$vi > 0))
  agg
}
AGG_NOTE <- sprintf(
  "one-effect-per-cluster aggregates: metafor aggregate.escalc, struct=\"CS\", rho=%.1f (T1/A5 convention [DEC-031g/F65])", RHO)

agg_full <- make_agg(dat, expected_k = K_AGG_FULL)                 # H2a
pre  <- sub[sub$pp_mid_lag0 == 0, , drop = FALSE]
post <- sub[sub$pp_mid_lag0 == 1, , drop = FALSE]
agg_pre  <- make_agg(pre,  expected_k = H2B_PRE)
agg_post <- make_agg(post, expected_k = H2B_POST)
both_cl <- intersect(unique(pre$cluster_id), unique(post$cluster_id))
stopifnot(length(both_cl) == H2B_BOTH)                 # Li et al. 2022 pin
d113 <- rbind(
  data.frame(y = agg_pre$yi,  se = sqrt(agg_pre$vi),  period = "pre",
             stringsAsFactors = FALSE),
  data.frame(y = agg_post$yi, se = sqrt(agg_post$vi), period = "post",
             stringsAsFactors = FALSE))
d113$period <- factor(d113$period, levels = c("pre", "post"))
h2b_cl <- c(agg_pre$cluster_id, agg_post$cluster_id)
stopifnot(nrow(d113) == H2B_ROWS,
          sum(d113$period == "pre")  == H2B_PRE,
          sum(d113$period == "post") == H2B_POST,
          length(unique(h2b_cl)) == N_SUB_CL,
          all(is.finite(d113$y)), all(d113$se > 0))
H2B_DOM <- sprintf("period domain %d/%d/%d [DEC-042b]; %d cluster x period rows (pre %d + post %d; both-period cluster n = %d, disclosed: %s)",
                   N_SUB, N_SUB_ST, N_SUB_CL, H2B_ROWS, H2B_PRE, H2B_POST,
                   H2B_BOTH, paste(both_cl, collapse = "; "))

# ------------------------------ 3. Helpers ----------------------------
row_base <- function(analysis_id, spec, subset, term, metric,
                     estimator = "RoBMA_3.6.1", rho = RHO,
                     k_es = NA_integer_, k_study = NA_integer_,
                     k_cluster = NA_integer_,
                     est_z = NA_real_, se_z = NA_real_,
                     ci_lb_z = NA_real_, ci_ub_z = NA_real_,
                     est_r = NA_real_, ci_lb_r = NA_real_, ci_ub_r = NA_real_,
                     value = NA_real_, ms_input = FALSE,
                     ms_label = NA_character_, note = NA_character_) {
  data.frame(
    analysis_id = analysis_id, spec = spec, subset = subset, term = term,
    metric = metric, estimator = estimator, rho = rho,
    k_es = k_es, k_study = k_study, k_cluster = k_cluster,
    est_z = est_z, se_z = se_z, t_stat = NA_real_, df = NA_real_, p = NA_real_,
    ci_lb_z = ci_lb_z, ci_ub_z = ci_ub_z,
    pi_lb_z = NA_real_, pi_ub_z = NA_real_,
    est_r = est_r, ci_lb_r = ci_lb_r, ci_ub_r = ci_ub_r,
    pi_lb_r = NA_real_, pi_ub_r = NA_real_,
    sigma2_cluster = NA_real_, sigma2_study = NA_real_, sigma2_esid = NA_real_,
    pct_cluster = NA_real_, pct_study = NA_real_, pct_esid = NA_real_,
    pct_sampling = NA_real_,
    typical_v = NA_real_, value = value,
    ms_input = ms_input, ms_label = ms_label, note = note,
    stringsAsFactors = FALSE)
}
design_row <- function(term, value, note) {
  row_base("TH_b_design", "design", SUBSET_FULL, term, metric = "count",
           estimator = "descriptive", rho = NA_real_, value = value,
           note = note)
}

is_nonconv <- function(msg) any(vapply(
  NONCONV_SIG, function(s) grepl(s, msg, ignore.case = TRUE), logical(1)))

# Off-spine fit guard [P-T5-4 analog]: listed condition -> not_estimable;
# unlisted -> S5 hard stop. Warnings collected as metadata only.
robma_guard <- function(expr, what) {
  warns <- character(0)
  out <- withCallingHandlers(
    tryCatch(list(ok = TRUE, fit = expr()),
             error = function(e) list(ok = FALSE, msg = conditionMessage(e))),
    warning = function(w) { warns <<- c(warns, conditionMessage(w))
                            invokeRestart("muffleWarning") })
  out$warns <- warns
  if (!out$ok && !is_nonconv(out$msg))
    stop("S5 HARD STOP [P-T5-4] — unlisted condition in ", what, ": ", out$msg)
  out
}

# Extraction accessors (fix-zone stops on API mismatch; validated by the
# [R7-PRE] smoke test before any canonical fit).
fixzone <- function(what, detail)
  stop("PACKAGE-API MISMATCH (fix zone: Paket-API) — ", what, ": ", detail,
       ". Adjust the accessor to the installed package version; do NOT ",
       "change model calls or pins.")
num1 <- function(x) { x <- suppressWarnings(as.numeric(x)); x[1] }
get_col <- function(df, cands, what) {
  hit <- intersect(cands, colnames(df))
  if (!length(hit)) fixzone(what, paste0("none of columns {",
    paste(cands, collapse = ", "), "} in {",
    paste(colnames(df), collapse = ", "), "}"))
  hit[[1]]
}
find_bf10 <- function(s, pattern, what) {
  for (el in s) {
    if ((is.data.frame(el) || is.matrix(el)) && !is.null(rownames(el))) {
      i <- grep(pattern, rownames(el), ignore.case = TRUE)
      if (length(i) == 1) {
        cn <- get_col(as.data.frame(el),
                      c("inclusion_BF", "Inclusion BF", "inclusion_bf", "BF"),
                      what)
        v <- num1(as.data.frame(el)[i, cn])
        if (!is.finite(v) || v <= 0) fixzone(what, paste0("BF10 = ", v))
        return(v)
      }
    }
  }
  fixzone(what, paste0("no unique row matching '", pattern,
                       "' in summary elements {",
                       paste(names(s), collapse = ", "), "}"))
}
find_est <- function(s, pattern, what) {
  for (el in s) {
    if ((is.data.frame(el) || is.matrix(el)) && !is.null(rownames(el))) {
      df <- as.data.frame(el)
      i <- grep(pattern, rownames(df), ignore.case = TRUE)
      if (length(i) >= 1) {
        i <- i[[1]]
        cm <- get_col(df, c("Mean", "mean", "Median", "median"), what)
        cl <- get_col(df, c("0.025", "2.5%", "lCI", "l.CI"), what)
        cu <- get_col(df, c("0.975", "97.5%", "uCI", "u.CI"), what)
        return(list(label = rownames(df)[i], n_match = length(
                      grep(pattern, rownames(df), ignore.case = TRUE)),
                    est = num1(df[i, cm]), lb = num1(df[i, cl]),
                    ub = num1(df[i, cu])))
      }
    }
  }
  fixzone(what, paste0("no row matching '", pattern, "'"))
}
extract_level <- function(fit, what) {
  s <- summary(fit)
  list(bf10_eff = find_bf10(s, "^effect",       paste0(what, "/BF effect")),
       bf10_het = find_bf10(s, "^heterogeneit", paste0(what, "/BF het")),
       bf10_bias = find_bf10(s, "bias",          paste0(what, "/BF bias")),
       mu  = find_est(s, "^mu$|^mu ",  paste0(what, "/mu")),
       tau = find_est(s, "^tau$|^tau ", paste0(what, "/tau")))
}
extract_reg <- function(fit, what, need_coef = TRUE) {
  s <- summary(fit)
  out <- list(bf10_per = find_bf10(s, "period", paste0(what, "/BF period")),
              tau = find_est(s, "^tau$|^tau ", paste0(what, "/tau")))
  if (need_coef) {
    co <- find_est(s, "period", paste0(what, "/coef period"))
    if (co$n_match != 1)
      fixzone(paste0(what, "/coef period"),
              paste0(co$n_match, " matching rows (expect exactly 1 under ",
                     "the treatment contrast)"))
    out$coef <- co
  }
  out
}

FIT_META <- character(0); BFPAIR <- character(0); TFIT <- character(0)
log_fit <- function(key, g, elapsed, contrast, fit) {
  pri <- tryCatch(utils::capture.output(print(fit$priors)),
                  error = function(e) paste("priors echo n/a:",
                                            conditionMessage(e)))
  FIT_META <<- c(FIT_META,
    sprintf("FITMETA|%s|elapsed_s=%.1f|warnings=%d|contrast=%s", key,
            elapsed, length(g$warns), contrast),
    if (length(g$warns)) paste0("  warn: ", g$warns) else NULL,
    paste0("  ", pri))
  TFIT <<- c(TFIT, sprintf("TFIT|%s|elapsed_s=%.1f", key, elapsed))
}
log_bf <- function(key, comp, bf10) {
  BFPAIR <<- c(BFPAIR, sprintf("BFPAIR|%s|%s|BF10=%.12g|BF01=%.12g",
                               key, comp, bf10, 1 / bf10))
}

# ------------------------------ 4. [R7-PRE] extraction smoke test -----
cat("R7-PRE — extraction smoke test (synthetic, non-canonical MCMC) ...\n")
smoke <- function() {
  set.seed(SEED)
  ys <- rnorm(8, 0, 0.05); ses <- rep(0.08, 8)
  f1 <- RoBMA(y = ys, se = ses, effect_direction = EFF_DIR,
              transformation = TRANSF, prior_scale = PSCALE,
              sample = 500, burnin = 250, adapt = 100, chains = 2,
              autofit = FALSE, parallel = FALSE, seed = SEED, silent = TRUE)
  e1 <- extract_level(f1, "smoke/level")
  stopifnot(is.finite(e1$bf10_eff), is.finite(e1$mu$est),
            is.finite(e1$tau$est),
            abs(e1$bf10_eff * (1 / e1$bf10_eff) - 1) < 1e-9)
  ds <- data.frame(y = rnorm(10, 0, 0.05), se = rep(0.08, 10),
                   period = factor(rep(c("pre", "post"), 5),
                                   levels = c("pre", "post")))
  f2 <- RoBMA.reg(~ period, data = ds, test_predictors = "period",
                  priors = list(period = RoBMA::prior_factor(
                    "normal", parameters = list(mean = 0, sd = 0.15),
                    contrast = "treatment")),
                  effect_direction = EFF_DIR, transformation = TRANSF,
                  prior_scale = PSCALE,
                  sample = 500, burnin = 250, adapt = 100, chains = 2,
                  autofit = FALSE, parallel = FALSE, seed = SEED,
                  silent = TRUE)
  e2 <- extract_reg(f2, "smoke/reg", need_coef = TRUE)
  stopifnot(is.finite(e2$bf10_per), is.finite(e2$coef$est),
            is.finite(e2$tau$est))
  invisible(TRUE)
}
sm <- tryCatch(smoke(), error = function(e) e)
if (inherits(sm, "error"))
  fixzone("R7-PRE smoke test", conditionMessage(sm))
cat("R7-PRE PASS — both extraction machineries validated; canonical fits start\n")

# ------------------------------ 5. Canonical fits ---------------------
rows <- list()
h2a_dom <- sprintf("estimation set %d/%d/%d [DEC-042a]; k = %d aggregates",
                   N_SET, N_SET_ST, N_SET_CL, K_AGG_FULL)
base_call_note <- sprintf(
  "RoBMA 3.6.1 [DEC-046]; y/se input, transformation=\"none\", prior_scale=\"none\" (priors act on Fisher-z verbatim); effect_direction=\"%s\" [P-T5-2]; seed %d; sequential chains, 3.x defaults incl. autofit=TRUE; %s",
  EFF_DIR, SEED, AGG_NOTE)

h2a_specs <- list(
  psma_default = list(pe = NULL, lab = "PSMA package defaults (primary [DEC-031b]); default priors echoed verbatim in run_meta"),
  coe_informed = list(pe = RoBMA::prior("normal",
                        parameters = list(mean = MU_COE, sd = SD_COE)),
                      lab = sprintf("COE-informed effect prior Normal(%.3f, %.6f); sigma = 0.083/3.92 = 0.0212 [DEC-031b provenance arithmetic]; COE companion = only admissible external prior source", MU_COE, SD_COE)),
  coe_wide     = list(pe = RoBMA::prior("normal",
                        parameters = list(mean = MU_COE, sd = SD_WIDE)),
                      lab = sprintf("wide effect prior Normal(%.3f, %.6f) = 2 x COE sigma (~0.042) [DEC-045]", MU_COE, SD_WIDE)))

for (sp in names(h2a_specs)) {
  key <- paste0("h2a_", sp)
  cat(sprintf("H2a fit %s ... (t_RoBMA ref 1764.8 s)\n", sp))
  args <- list(y = agg_full$yi, se = sqrt(agg_full$vi),
               effect_direction = EFF_DIR, transformation = TRANSF,
               prior_scale = PSCALE, seed = SEED, parallel = FALSE)
  if (!is.null(h2a_specs[[sp]]$pe)) args$priors_effect <- h2a_specs[[sp]]$pe
  tt <- system.time(g <- robma_guard(function() do.call(RoBMA::RoBMA, args),
                                     key))
  nte <- function(term, metric, note_extra) row_base(
    "H2a", sp, SUBSET_FULL, term, metric = metric,
    k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
    note = paste0("not_estimable — ", g$msg, "; ", note_extra))
  if (!g$ok) {
    FIT_META <- c(FIT_META, sprintf("FITMETA|%s|NOT_ESTIMABLE|%s", key, g$msg))
    nn <- paste0(base_call_note, "; ", h2a_specs[[sp]]$lab, "; ", h2a_dom)
    rows <- c(rows, list(nte("mu_avg", "Fisher_z", nn),
                         nte("tau_avg", "tau", nn),
                         nte("bf01_effect", "BF01", nn),
                         nte("bf01_heterogeneity", "BF01", nn),
                         nte("bf01_bias", "BF01", nn)))
    next
  }
  fit <- g$fit
  ex <- extract_level(fit, key)
  log_fit(key, g, tt[["elapsed"]], "n/a (level model)", fit)
  for (cc in c("effect", "heterogeneity", "bias"))
    log_bf(key, cc, switch(cc, effect = ex$bf10_eff,
                           heterogeneity = ex$bf10_het, bias = ex$bf10_bias))
  nn <- paste0(base_call_note, "; ", h2a_specs[[sp]]$lab, "; ", h2a_dom)
  prim <- identical(sp, "psma_default")
  rows <- c(rows, list(
    row_base("H2a", sp, SUBSET_FULL, "mu_avg", metric = "Fisher_z",
             k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
             est_z = ex$mu$est, ci_lb_z = ex$mu$lb, ci_ub_z = ex$mu$ub,
             est_r = tanh(ex$mu$est), ci_lb_r = tanh(ex$mu$lb),
             ci_ub_r = tanh(ex$mu$ub),
             ms_input = prim, ms_label = if (prim) "robma_mu_primary"
                                         else NA_character_,
             note = paste0(nn, "; model-averaged posterior mean, 95% central CI; summary row '", ex$mu$label, "'")),
    row_base("H2a", sp, SUBSET_FULL, "tau_avg", metric = "tau",
             k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
             est_z = ex$tau$est, ci_lb_z = ex$tau$lb, ci_ub_z = ex$tau$ub,
             note = paste0(nn, "; model-averaged tau on the Fisher-z scale; no tanh (scale parameter)")),
    row_base("H2a", sp, SUBSET_FULL, "bf01_effect", metric = "BF01",
             k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
             value = 1 / ex$bf10_eff,
             ms_input = prim, ms_label = if (prim) "bf01_level_primary"
                                         else NA_character_,
             note = paste0(nn, sprintf("; inclusion BF10 (effect) = %.6g; BF01 = 1/BF10 quantifies evidence FOR the null of the effect component; raw value, band labelling downstream [DEC-044]", ex$bf10_eff))),
    row_base("H2a", sp, SUBSET_FULL, "bf01_heterogeneity", metric = "BF01",
             k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
             value = 1 / ex$bf10_het,
             note = paste0(nn, sprintf("; inclusion BF10 (heterogeneity) = %.6g; BF01 = 1/BF10", ex$bf10_het))),
    row_base("H2a", sp, SUBSET_FULL, "bf01_bias", metric = "BF01",
             k_es = N_SET, k_study = N_SET_ST, k_cluster = K_AGG_FULL,
             value = 1 / ex$bf10_bias,
             note = paste0(nn, sprintf("; inclusion BF10 (publication bias) = %.6g; BF01 = 1/BF10", ex$bf10_bias)))))
  rm(fit); invisible(gc())
}

h2b_specs <- list(
  contrast_informed = list(sd = SD_CONTRAST, contrast = "treatment",
    lab = "contrast prior Normal(0, 0.025) on the post-minus-pre period contrast (treatment contrast, ref = pre); sigma from the SECONDARY SESOI +-0.05 ~ +-2 sigma [DEC-045]",
    coef = TRUE, prim = TRUE),
  contrast_wide     = list(sd = SD_CONTRAST_WIDE, contrast = "treatment",
    lab = "wide contrast prior Normal(0, 0.050), treatment contrast (ref = pre) [DEC-045]",
    coef = TRUE, prim = FALSE),
  factor_default    = list(sd = NA_real_, contrast = "package default",
    lab = "package default factor prior and contrast (echoed verbatim in run_meta); coefficient row intentionally not reported for this set (package-internal parameterization; contrast estimate claims live on the treatment-contrast fits) [DEC-046]",
    coef = FALSE, prim = FALSE))

for (sp in names(h2b_specs)) {
  key <- paste0("h2b_", sp); cfg <- h2b_specs[[sp]]
  cat(sprintf("H2b fit %s ...\n", sp))
  args <- list(formula = ~ period, data = d113, test_predictors = "period",
               effect_direction = EFF_DIR, transformation = TRANSF,
               prior_scale = PSCALE, seed = SEED, parallel = FALSE)
  if (is.finite(cfg$sd))
    args$priors <- list(period = RoBMA::prior_factor(
      "normal", parameters = list(mean = 0, sd = cfg$sd),
      contrast = "treatment"))
  tt <- system.time(g <- robma_guard(function()
    do.call(RoBMA::RoBMA.reg, args), key))
  nn <- paste0(base_call_note, "; RoBMA.reg [DEC-045: only admissible ",
               "moderation route]; ", cfg$lab, "; ", H2B_DOM)
  nteB <- function(term, metric) row_base(
    "H2b", sp, SUBSET_DEF, term, metric = metric,
    k_es = N_SUB, k_study = N_SUB_ST, k_cluster = H2B_ROWS,
    note = paste0("not_estimable — ", g$msg, "; ", nn))
  if (!g$ok) {
    FIT_META <- c(FIT_META, sprintf("FITMETA|%s|NOT_ESTIMABLE|%s", key, g$msg))
    rows <- c(rows, c(if (cfg$coef) list(nteB("coef_period", "z_diff")),
                      list(nteB("bf01_period", "BF01"),
                           nteB("tau_avg", "tau"))))
    next
  }
  fit <- g$fit
  ex <- extract_reg(fit, key, need_coef = cfg$coef)
  log_fit(key, g, tt[["elapsed"]], cfg$contrast, fit)
  log_bf(key, "period", ex$bf10_per)
  out <- list()
  if (cfg$coef) out <- c(out, list(
    row_base("H2b", sp, SUBSET_DEF, "coef_period", metric = "z_diff",
             k_es = N_SUB, k_study = N_SUB_ST, k_cluster = H2B_ROWS,
             est_z = ex$coef$est, ci_lb_z = ex$coef$lb, ci_ub_z = ex$coef$ub,
             ms_input = cfg$prim,
             ms_label = if (cfg$prim) "robma_contrast_primary"
                        else NA_character_,
             note = paste0(nn, "; post-minus-pre contrast on the Fisher-z scale; z-only, no tanh transform of differences; summary row '", ex$coef$label, "'"))))
  out <- c(out, list(
    row_base("H2b", sp, SUBSET_DEF, "bf01_period", metric = "BF01",
             k_es = N_SUB, k_study = N_SUB_ST, k_cluster = H2B_ROWS,
             value = 1 / ex$bf10_per,
             ms_input = cfg$prim,
             ms_label = if (cfg$prim) "bf01_moderation_primary"
                        else NA_character_,
             note = paste0(nn, sprintf("; inclusion BF10 (period moderator) = %.6g; BF01 = 1/BF10 quantifies evidence FOR the null of Paris moderation; raw value, band labelling downstream [DEC-044]", ex$bf10_per))),
    row_base("H2b", sp, SUBSET_DEF, "tau_avg", metric = "tau",
             k_es = N_SUB, k_study = N_SUB_ST, k_cluster = H2B_ROWS,
             est_z = ex$tau$est, ci_lb_z = ex$tau$lb, ci_ub_z = ex$tau$ub,
             note = paste0(nn, "; model-averaged tau on the Fisher-z scale"))))
  rows <- c(rows, out)
  rm(fit); invisible(gc())
}

# ------------------------------ 6. Design rows ------------------------
rows <- c(rows, list(
  design_row("subset_estimation", N_SET,
             sprintf("%d ES / %d studies / %d clusters [DEC-042a]; H2a domain", N_SET, N_SET_ST, N_SET_CL)),
  design_row("agg_k_full", K_AGG_FULL, paste0(AGG_NOTE, "; H2a basis")),
  design_row("h2b_domain_es", N_SUB,
             sprintf("%d ES / %d studies / %d clusters [DEC-042b]; H2b domain", N_SUB, N_SUB_ST, N_SUB_CL)),
  design_row("h2b_rows", H2B_ROWS,
             "cluster x period aggregate rows [DEC-045]; per-cell D2 aggregation"),
  design_row("h2b_rows_pre", H2B_PRE,
             "pre-cell aggregates (= 113 - 31, arithmetic pin)"),
  design_row("h2b_rows_post", H2B_POST,
             "post-cell aggregates [DEC-042b; v12 design constant]"),
  design_row("h2b_both_period_clusters", H2B_BOTH,
             paste0("single both-period cluster (disclosed): ",
                    paste(both_cl, collapse = "; "), " [DEC-045]"))))

# ------------------------------ 7. Assemble + write -------------------
res <- do.call(rbind, rows)
stopifnot(identical(names(res), SCHEMA))
if (nrow(res) != N_ROWS_EXPECTED) {
  print(table(res$analysis_id, res$spec))
  stop(sprintf("ROW BUDGET MISMATCH: got %d, expected %d.",
               nrow(res), N_ROWS_EXPECTED))
}
key4 <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "||")
stopifnot(!anyDuplicated(key4))
stopifnot(!any(res$analysis_id %in% c("D3", "B1")),          # single-home
          !any(grepl("^bp_", res$ms_label[!is.na(res$ms_label)])),
          !any(grepl("cell_pre|cell_post", res$term)))
stopifnot(sum(res$ms_input) == 4L)

dir.create(here("output"), showWarnings = FALSE)
write_csv(res, here("output", "TH_b_results.csv"), na = "")

meta <- c(
  sprintf("TH-b run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "authority: DEC-045 (H2a/H2b pins) · DEC-046 (F66 closure, version + scale-path pins) · DEC-031b · DEC-044 (framing-neutral)",
  sprintf("dat_prep md5:  %s (asserted == pin %s)", md5_obs, DAT_PREP_MD5),
  sprintf("versions: R %s | RoBMA %s (pin %s) | BayesTools %s (pin %s) | rjags %s | JAGS %s",
          getRversion(), packageVersion("RoBMA"), ROBMA_PIN,
          packageVersion("BayesTools"), BT_PIN, packageVersion("rjags"),
          tryCatch(as.character(rjags::jags.version()),
                   error = function(e) "see load banner")),
  sprintf("seed %d; effect_direction \"%s\" [P-T5-2/DEC-046]; transformation/prior_scale \"none\" (priors on Fisher-z verbatim); sequential chains + single-thread Rblas = target load [DEC-046]; 3.x MCMC defaults incl. autofit=TRUE (per-fit realizations below)", SEED, EFF_DIR),
  sprintf("prior constants [DEC-031b/045/046]: COE mu %.3f | COE sigma %.10f (= 0.083/3.92) | wide sigma %.10f (= 2x) | contrast sigma %.3f | contrast wide %.3f",
          MU_COE, SD_COE, SD_WIDE, SD_CONTRAST, SD_CONTRAST_WIDE),
  sprintf("domains: H2a %d/%d/%d, k_agg %d [DEC-042a]; H2b %s",
          N_SET, N_SET_ST, N_SET_CL, K_AGG_FULL, H2B_DOM),
  sprintf("[P-T5-4 analog] not-estimable signature list: {%s}; any other condition = S5 hard stop; extraction mismatches = fix-zone stop",
          paste(NONCONV_SIG, collapse = ", ")),
  "execution order: h2a_psma_default, h2a_coe_informed, h2a_coe_wide, h2b_contrast_informed, h2b_contrast_wide, h2b_factor_default",
  sprintf("t_RoBMA reference [DEC-046]: 1764.8 s; projection T = 3t + 3*kappa*t (kappa pinned at package review); actual per-fit timings below"),
  "", "-- per-fit metadata (priors verbatim, timings, warnings) --",
  FIT_META, "", "-- BF pairs (machine lines) --", BFPAIR,
  "", "-- fit timings (machine lines) --", TFIT,
  "", sprintf("N_ROWS = %d (7 design + 15 H2a + 8 H2b); ms_input inventory = 4 (robma_mu_primary, bf01_level_primary, bf01_moderation_primary, robma_contrast_primary)",
              N_ROWS_EXPECTED),
  "result framing: NONE; BF01 raw; band labelling + adjudication deferred to the documented gate-resolution step [DEC-044]",
  "", "sessionInfo():", utils::capture.output(utils::sessionInfo()))
writeLines(meta, here("output", "TH_b_run_meta.txt"))
cat(sprintf("TH-b written: %d rows x %d cols -> output/TH_b_results.csv\n",
            nrow(res), ncol(res)))
cat("Input-contract asserts: ALL PASSED (see paired verifier for output checks).\n")
