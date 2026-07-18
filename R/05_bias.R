# =====================================================================
# R/05_bias.R — T5: publication-bias battery (Block D: D1/D2/D4/D5)
# FOMA CER–COD–Paris | verifier-paired (NOT on the Gate-2 list [DEC-031 I];
# author GO before execution is mandatory)
# ---------------------------------------------------------------------
# Authority: DEC-010 (conditional PET-PEESE, side-by-side reporting) ·
#   DEC-014 (CR2 everywhere) · DEC-016 (selection-model secondary) ·
#   DEC-031 Battery D + D31.1 (cluster_id spine) · DEC-031a.1 (q_status ->
#   Block D) · DEC-031a.4 (trim-and-fill excluded, Carter et al. 2019) ·
#   DEC-031a.5 (pre/post upgrade FIRED: post cell 31 >= 20 studies) ·
#   DEC-031b (D3 = N3 machinery -> H-session) · DEC-042a/b (domains) ·
#   DEC-031f + plan A.11 (optimizer ladder) · DEC-031g (T5 execution
#   pins P-T5-1..5; F63/F64/F65) · plan §8 + Addendum A.12.
# Scope: D1 FAT-PET-PEESE (full estimation set) · D2 3PSM + p-uniform*
#   (one-effect-per-cluster aggregates) · D4 pre/post split (PET-PEESE +
#   selection models per period) · D5 grey-literature panel (q_status,
#   main-effects cell-means). D3 (RoBMA) executes in the H-session
#   [DEC-031g]; NO bp-translation rows [P-T5-5]; NO trim-and-fill
#   [DEC-031a.4].
# Domains: D1/D2/D5 = estimation set 2,713 ES / 115 studies / 114
#   clusters [DEC-042a]; D4 = period cells on the 2,705 window domain
#   (pre 1,994 ES / 83 studies · post 711 ES / 31 studies / 31 clusters;
#   8 ES / 2 studies NA listwise) [DEC-042b].
# Spine: rma.mv REML, V = impute_covariance_matrix(vi, cluster_id, r=0.6),
#   random = ~1 | cluster_id/study/esid, CR2 + Satterthwaite on
#   cluster_id [D31.1/A.2]. Continuous-regressor fits (PET/PEESE: sez,
#   sez^2) use the DEC-031f ladder nlminb -> optim/BFGS ->
#   optim/Nelder-Mead, first metafor-certified fit wins [R2]; optimizer
#   disclosed per fit [R3]; fallback rows note-flagged [R3]; factor-only
#   D5 runs cell-means under the default optimizer [R1]; all-rungs-fail
#   = stop [R5]; one BFGS control re-fit, |dbeta| < 1e-5 [R6].
# Off-spine (selmodel / puni_star): the ladder does NOT apply. Documented
#   non-convergence (pinned signature list NONCONV_SIG) -> planned rows
#   written as not_estimable with the full condition text in `note`; any
#   other error -> hard stop (S5) [P-T5-4, sharpened]. Package-API field
#   mismatches raise a labelled "fix zone" stop (Paket-API), distinct
#   from S5.
# Output: output/T5_results.csv — T2 schema (36 columns, incl. `term`);
#   deterministic row budget (all planned keys always written; failures
#   surface as not_estimable values, never as missing rows);
#   output/T5_run_meta.txt (md5, pins, certificates, sessionInfo).
# Result framing: NONE. This script computes and writes; it does not
#   interpret. Verdict language is produced downstream (workbook/chat).
# ---------------------------------------------------------------------
# Deviation disclosures vs the committed T8 pattern (R/08_identification.R):
#   (i)   hard md5 assert on output/dat_prep.rds (bootstrap input
#         contract; T8 wrote the md5 to run_meta only);
#   (ii)  `subset` carries the row's domain ("full" | "defined_pre" |
#         "defined_post"), not one constant — T5 spans two domains;
#   (iii) metric vocabulary extended by: "tau2", "LRT_test", "flag"
#         (documented here; verifier pins the closed set);
#   (iv)  aggregate-based rows keep ES provenance in k_es/k_study and
#         carry the number of analysis units (clusters) in k_cluster.
# Column conventions otherwise aligned 1:1 with committed
# T1/T2/T8_results.csv (est_r = tanh on LEVEL rows only; differences/
# slopes z-only; Wald rows: F in t_stat, Satterthwaite denominator df in
# df, numerator df in note; pi_* = NA throughout [A.8]; ms_input logical).
# =====================================================================

suppressPackageStartupMessages({
  library(metafor)
  library(clubSandwich)
  library(puniform)      # 0.2.8 [F64, DEC-031g]
  library(here)
  library(readr)
})

# ------------------------------ 0. Constants (FROZEN ZONE) ------------
RHO           <- 0.6                       # DEC-017
DAT_PREP_MD5  <- "6702ef3dc45fe0b693b13f50ebd1576b"   # input contract pin
N_SET  <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L   # DEC-042a
N_PRE  <- 1994L; N_PRE_ST <- 83L                      # DEC-042b / T1 pin
N_POST <-  711L; N_POST_ST <- 31L; N_POST_CL <- 31L   # v12 design constants
K_NA_ES <- 8L;   K_NA_ST <- 2L                        # DEC-042b
K_AGG_FULL <- 114L                                    # one-per-cluster
ALPHA_RULE <- 0.05          # PET->PEESE alignment rule [DEC-010; P-T5-1]
STEPS_3PSM <- 0.025         # DEC-016 / DEC-031 Battery D
SEL_ALT    <- "less"        # selection favors significant NEGATIVE effects
PUNI_SIDE  <- "left"        #   [plan §8.2; P-T5-2 direction pins, jointly]
QS_LEVELS  <- c("0_published", "1_not published")     # v12 verbatim
QS_REF     <- "0_published"
QS_PIN <- data.frame(level = QS_LEVELS,               # DEC-031g (F60 pattern)
                     es = c(2033L, 680L),
                     st = c( 101L,  14L),
                     cl = c( 100L,  14L))
SEED    <- 20260710L
TOL_R6  <- 1e-5             # DEC-031f R6
# [P-T5-4] pinned non-convergence signatures (case-insensitive substrings;
# REVIEW POINT at package review; extendable only by DEC):
NONCONV_SIG <- c("converg", "opposite sign")
SUBSET_FULL <- "full"; SUBSET_PRE <- "defined_pre"; SUBSET_POST <- "defined_post"
# Row budget (auditable; W1 pattern):
#   9 design
# + D1: 2 (pet) + 2 (peese) + 1 (rule flag)                       =  5
# + D4 pet/peese: 5 (pre) + 5 (post)                              = 10
# + D2 selection_full: 9  (mu_unadjusted_ML, tau2_unadjusted,
#       mu_3psm, tau2_3psm, delta_3psm, lrt_3psm,
#       mu_punistar, tau2_punistar, mu_anchor_reml_knha)          =  9
# + D4 selection: 8 (pre) + 8 (post)   (as D2 minus the anchor)   = 16
# + D5 grey_panel: 2 cells + 1 contrast + 1 Wald                  =  4
N_ROWS_EXPECTED <- 9L + 5L + 10L + 9L + 16L + 4L      # = 53

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

`%||%` <- function(a, b) if (is.null(a)) b else a

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

need <- c("zi", "vi", "cluster_id", "study", "esid", "pp_mid_lag0", "q_status")
miss <- setdiff(need, names(dat))
if (length(miss)) stop("SCHEMA HARD STOP — missing columns: ",
                       paste(miss, collapse = ", "))
stopifnot(nrow(dat) == N_SET,
          length(unique(dat$study)) == N_SET_ST,
          length(unique(dat$cluster_id)) == N_SET_CL,
          is.numeric(dat$vi), all(is.finite(dat$vi)), all(dat$vi > 0),
          is.numeric(dat$zi), all(is.finite(dat$zi)))

# [P-T5-2] sez derived in-script; the raw v12 SE column is never read.
dat$sez <- sqrt(dat$vi)
stopifnot(all(is.finite(dat$sez)), all(dat$sez > 0),
          max(abs(dat$sez^2 - dat$vi)) < 1e-12)

# Period cells [DEC-042b]; NA listwise from period cells only
na_win <- is.na(dat$pp_mid_lag0)
stopifnot(sum(na_win) == K_NA_ES,
          length(unique(dat$study[na_win])) == K_NA_ST)
pre  <- dat[!na_win & dat$pp_mid_lag0 == 0, , drop = FALSE]
post <- dat[!na_win & dat$pp_mid_lag0 == 1, , drop = FALSE]
stopifnot(nrow(pre)  == N_PRE,  length(unique(pre$study))  == N_PRE_ST,
          nrow(post) == N_POST, length(unique(post$study)) == N_POST_ST,
          length(unique(post$cluster_id)) == N_POST_CL)
K_AGG_PRE  <- length(unique(pre$cluster_id))     # derived, disclosed
K_AGG_POST <- length(unique(post$cluster_id))
stopifnot(K_AGG_POST == N_POST_CL)

# q_status: pinned cell inventory [DEC-031g, F60 pattern]
stopifnot(!anyNA(dat$q_status), setequal(unique(dat$q_status), QS_LEVELS))
for (i in seq_len(nrow(QS_PIN))) {
  m <- dat$q_status == QS_PIN$level[i]
  stopifnot(sum(m) == QS_PIN$es[i],
            length(unique(dat$study[m]))      == QS_PIN$st[i],
            length(unique(dat$cluster_id[m])) == QS_PIN$cl[i])
}
dat$qs <- stats::relevel(factor(dat$q_status, levels = QS_LEVELS), ref = QS_REF)
stopifnot(identical(levels(dat$qs), QS_LEVELS))

# ------------------------------ 2. Spine helpers ----------------------
FIT_LOG <- character(0)   # [DEC-031e/f] convergence certificates -> run_meta
LADDER_OPTS <- list(
  list(label = "nlminb",            control = list(optimizer = "nlminb")),
  list(label = "optim/BFGS",        control = list(optimizer = "optim",
                                                   optmethod = "BFGS")),
  list(label = "optim/Nelder-Mead", control = list(optimizer = "optim",
                                                   optmethod = "Nelder-Mead")))

fit3l <- function(fml, data, V, tag, ladder = FALSE) {
  one <- function(ctrl) rma.mv(yi = zi, V = V, mods = fml,
                               random = ~ 1 | cluster_id/study/esid,
                               data = data, sparse = TRUE, method = "REML",
                               control = ctrl)
  if (!ladder) {                     # [R1] factor-only: default optimizer
    m <- one(LADDER_OPTS[[1]]$control)     # failure halts -> S-stop [R5]
    FIT_LOG <<- c(FIT_LOG, sprintf(
      "%s -- optimizer nlminb; converged (metafor-certified: rma.mv halts unless certified); ladder n/a (factor-only, cell-means) [DEC-031f R1]",
      tag))
    return(list(m = m, optimizer = "nlminb", fallback = FALSE))
  }
  errs <- character(0)               # [R2] deterministic ladder
  for (k in seq_along(LADDER_OPTS)) {
    o <- LADDER_OPTS[[k]]
    m <- tryCatch(one(o$control), error = function(e) e)
    if (!inherits(m, "error")) {
      fb <- k > 1L
      FIT_LOG <<- c(FIT_LOG, sprintf(
        "%s -- optimizer %s (ladder rung %d/3); converged (metafor-certified)%s [DEC-031f R2/R3]%s",
        tag, o$label, k, if (fb) "; FALLBACK" else "",
        if (length(errs)) paste0("; prior rungs failed: ",
                                 paste(errs, collapse = " | ")) else ""))
      return(list(m = m, optimizer = o$label, fallback = fb))
    }
    errs <- c(errs, sprintf("%s: %s", o$label, conditionMessage(m)))
  }
  stop("DEC-031f R5 STOP — all ladder rungs failed for '", tag, "': ",
       paste(errs, collapse = " | "))               # -> parameterization review
}

vcr <- function(m, cl) vcovCR(m, cluster = cl, type = "CR2")

SPINE <- "random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6; CR2/Satterthwaite on cluster_id [D31.1/A.2]"
mnote <- function(mods, dom) sprintf("rma.mv mods=%s; %s; domain %s", mods, SPINE, dom)

row_base <- function(analysis_id, spec, subset, term, metric,
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

design_row <- function(term, metric, value, note) {
  row_base("T5_design", "design", SUBSET_FULL, term, metric = metric,
           estimator = "descriptive", rho = NA_real_, value = value,
           note = note)
}

# ------------------------------ 3. Off-spine guards [P-T5-4] ----------
is_nonconv <- function(msg) any(vapply(
  NONCONV_SIG, function(s) grepl(s, msg, ignore.case = TRUE), logical(1)))

try_offspine <- function(expr, what) {
  # returns list(ok, obj | msg, warns); non-listed errors -> S5 hard stop
  warns <- character(0)
  out <- withCallingHandlers(
    tryCatch(list(ok = TRUE, obj = expr()),
             error = function(e) list(ok = FALSE,
                                      msg = conditionMessage(e))),
    warning = function(w) {
      warns <<- c(warns, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
  out$warns <- warns
  if (!out$ok && !is_nonconv(out$msg))
    stop("S5 HARD STOP [P-T5-4] — unlisted condition in ", what, ": ",
         out$msg)
  out
}

need_field <- function(obj, candidates, what) {
  for (nm in candidates) {
    v <- obj[[nm]]
    if (!is.null(v)) return(as.numeric(v)[1])
  }
  stop("PACKAGE-API MISMATCH (fix zone: Paket-API) — ", what,
       ": none of the fields {", paste(candidates, collapse = ", "),
       "} present on the object; adjust the accessor to the installed ",
       "package version. Do NOT change model calls or pins.")
}

# ------------------------------ 4. Aggregation [F63/F65 call pin] -----
make_agg <- function(d, expected_k) {
  X <- data.frame(yi = d$zi, vi = d$vi, cluster_id = d$cluster_id)
  datE <- metafor::escalc(measure = "GEN", yi = yi, vi = vi, data = X)
  agg  <- aggregate(datE, cluster = cluster_id, struct = "CS", rho = RHO)
  stopifnot(nrow(agg) == expected_k, !anyNA(agg$yi), all(agg$vi > 0))
  agg
}
AGG_NOTE <- sprintf(
  "one-effect-per-cluster aggregates: metafor aggregate.escalc, struct=\"CS\", rho=%.1f (T1/A5 convention [DEC-031g/F65])", RHO)

# ------------------------------ 5. PET-PEESE engine (D1/D4) -----------
rows <- list()

pet_peese_block <- function(d, analysis_id, spec_pet, spec_peese, spec_rule,
                            subset_lab, dom_lab, k_es, k_st, k_cl) {
  V  <- impute_covariance_matrix(vi = d$vi, cluster = d$cluster_id, r = RHO)
  fp <- fit3l(~ sez, d, V, tag = paste0(analysis_id, "_", spec_pet),
              ladder = TRUE)
  fe <- fit3l(~ I(sez^2), d, V, tag = paste0(analysis_id, "_", spec_peese),
              ladder = TRUE)
  fb_note <- function(f) if (f$fallback) sprintf(
    "; OPTIMIZER FALLBACK: %s (deterministic ladder [DEC-031f R2/R3])",
    f$optimizer) else ""
  out <- list()
  emit <- function(f, spec, terms_map, base_note) {
    m  <- f$m
    ct <- coef_test(m, vcov = vcr(m, d$cluster_id), test = "Satterthwaite")
    ci <- conf_int(m, vcov = vcr(m, d$cluster_id), level = .95)
    dfv <- ct$df_Satt %||% ct$df
    pv  <- ct$p_Satt  %||% ct$p
    cf  <- if (!is.null(ct$Coef)) as.character(ct$Coef) else rownames(ct)
    stopifnot(length(cf) == 2L, cf[1] %in% c("intrcpt", "(Intercept)"))
    lapply(seq_along(cf), function(i) {
      trm <- terms_map[i]
      lvl <- trm == "intercept"
      row_base(analysis_id, spec, subset_lab, trm, metric = "Fisher_z",
               k_es = k_es, k_study = k_st, k_cluster = k_cl,
               est_z = ct$beta[i], se_z = ct$SE[i], t_stat = ct$tstat[i],
               df = dfv[i], p = pv[i],
               ci_lb_z = ci$CI_L[i], ci_ub_z = ci$CI_U[i],
               est_r  = if (lvl) tanh(ct$beta[i])  else NA_real_,
               ci_lb_r = if (lvl) tanh(ci$CI_L[i]) else NA_real_,
               ci_ub_r = if (lvl) tanh(ci$CI_U[i]) else NA_real_,
               sigma2 = m$sigma2,
               note = paste0(base_note, fb_note(f)))
    })
  }
  n_pet <- paste0(
    mnote("~ sez (sez = sqrt(vi), in-script [P-T5-2])", dom_lab),
    "; intercept = PET estimate of the selection-adjusted mean, slope = FAT (Egger-type small-study test) [DEC-010; plan Section 8.1]")
  n_pee <- paste0(
    mnote("~ I(sez^2) (== vi [P-T5-2])", dom_lab),
    "; intercept = PEESE estimate; computed and reported unconditionally, side by side [DEC-010; P-T5-1]")
  out <- c(out, emit(fp, spec_pet,  c("intercept", "sez"),    n_pet))
  out <- c(out, emit(fe, spec_peese, c("intercept", "sez_sq"), n_pee))
  # [P-T5-1] alignment rule: mechanical flag; identical rule in every subgroup
  ctp <- coef_test(fp$m, vcov = vcr(fp$m, d$cluster_id),
                   test = "Satterthwaite")
  p_int <- (ctp$p_Satt %||% ctp$p)[1]
  sel_peese <- as.numeric(is.finite(p_int) && p_int < ALPHA_RULE)
  out <- c(out, list(row_base(
    analysis_id, spec_rule, subset_lab, "pet_peese_rule", metric = "flag",
    estimator = "rule", rho = NA_real_,
    k_es = k_es, k_study = k_st, k_cluster = k_cl,
    value = sel_peese,
    ms_input = identical(analysis_id, "D1"),
    ms_label = if (identical(analysis_id, "D1")) "pet_peese_rule_full"
               else NA_character_,
    note = sprintf(
      "conditional PET->PEESE alignment [DEC-010; DEC-031g P-T5-1]: value 1 = PEESE carries the corrected-estimate claim (PET intercept p = %.6f < %.2f, two-sided, CR2/Satterthwaite), value 0 = PET carries it; both models reported side by side regardless; identical rule in every subgroup",
      p_int, ALPHA_RULE))))
  attr(out, "fits") <- list(pet = fp, peese = fe, p_int = p_int)
  out
}

d1 <- pet_peese_block(dat, "D1", "pet", "peese", "rule",
                      SUBSET_FULL, "2,713/115/114 [DEC-042a]",
                      N_SET, N_SET_ST, N_SET_CL)
d4a <- pet_peese_block(pre, "D4", "pet_pre", "peese_pre", "rule_pre",
                       SUBSET_PRE,
                       sprintf("pre cell 1,994/83/%d [DEC-042b]", K_AGG_PRE),
                       N_PRE, N_PRE_ST, K_AGG_PRE)
d4b <- pet_peese_block(post, "D4", "pet_post", "peese_post", "rule_post",
                       SUBSET_POST, "post cell 711/31/31 [DEC-042b]",
                       N_POST, N_POST_ST, N_POST_CL)
rows <- c(rows, d1, d4a, d4b)

# ms_input on the D1 model rows + pre/post PET intercepts [pinned inventory]
mark_ms <- function(rws, aid, spc, trm, lab) {
  for (i in seq_along(rws)) {
    r <- rws[[i]]
    if (is.data.frame(r) && r$analysis_id == aid && r$spec == spc &&
        r$term == trm) {
      rws[[i]]$ms_input <- TRUE; rws[[i]]$ms_label <- lab
    }
  }
  rws
}
rows <- mark_ms(rows, "D1", "pet",   "intercept", "pet_full")
rows <- mark_ms(rows, "D1", "pet",   "sez",       "fat_full")
rows <- mark_ms(rows, "D1", "peese", "intercept", "peese_full")
rows <- mark_ms(rows, "D4", "pet_pre",  "intercept", "pet_pre")
rows <- mark_ms(rows, "D4", "pet_post", "intercept", "pet_post")

# [DEC-031f R6] control re-fit: first nlminb-converged ladder fit under BFGS,
# on the identical domain (candidate list ordered full set first)
r6_line <- "R6 control fit: SKIPPED — no nlminb-converged continuous-regressor fit (all fallback); disclosed per DEC-031f R6"
cand <- Filter(function(x) identical(x$fit$optimizer, "nlminb"), list(
  list(fit = attr(d1,  "fits")$pet,   d = dat,  lab = "D1 pet"),
  list(fit = attr(d1,  "fits")$peese, d = dat,  lab = "D1 peese"),
  list(fit = attr(d4a, "fits")$pet,   d = pre,  lab = "D4 pet_pre"),
  list(fit = attr(d4b, "fits")$pet,   d = post, lab = "D4 pet_post")))
if (length(cand)) {
  c0 <- cand[[1]]
  m6 <- rma.mv(yi = zi,
               V = impute_covariance_matrix(vi = c0$d$vi,
                                            cluster = c0$d$cluster_id,
                                            r = RHO),
               mods = formula(c0$fit$m),
               random = ~ 1 | cluster_id/study/esid,
               data = c0$d, sparse = TRUE, method = "REML",
               control = list(optimizer = "optim", optmethod = "BFGS"))
  dmax <- max(abs(as.numeric(coef(c0$fit$m)) - as.numeric(coef(m6))))
  if (!(dmax < TOL_R6))
    stop("DEC-031f R6 STOP — BFGS control re-fit deviates (", c0$lab,
         "): max|dbeta| = ", format(dmax, digits = 6), " >= ", TOL_R6)
  r6_line <- sprintf(
    "R6 control fit: PASS — %s (nlminb) re-fit under optim/BFGS on the identical domain, max|dbeta| = %.3e < 1e-5 [DEC-031f R6]",
    c0$lab, dmax)
}

# ------------------------------ 6. Selection models (D2/D4) -----------
selection_block <- function(d, analysis_id, spec, subset_lab, dom_lab,
                            k_es, k_st, k_agg, with_anchor = FALSE) {
  agg <- make_agg(d, expected_k = k_agg)
  base_note <- sprintf("%s; domain %s; k = %d aggregates from %d ES",
                       AGG_NOTE, dom_lab, k_agg, k_es)
  out <- list()
  vrow <- function(term, metric, estimator, value, note,
                   ms_input = FALSE, ms_label = NA_character_) {
    row_base(analysis_id, spec, subset_lab, term, metric = metric,
             estimator = estimator, rho = RHO,
             k_es = k_es, k_study = k_st, k_cluster = k_agg,
             value = value, ms_input = ms_input, ms_label = ms_label,
             note = note)
  }
  erow <- function(term, estimator, est, se, zval, pval, lb, ub, note,
                   ms_input = FALSE, ms_label = NA_character_) {
    row_base(analysis_id, spec, subset_lab, term, metric = "Fisher_z",
             estimator = estimator, rho = RHO,
             k_es = k_es, k_study = k_st, k_cluster = k_agg,
             est_z = est, se_z = se, t_stat = zval, df = NA_real_, p = pval,
             ci_lb_z = lb, ci_ub_z = ub,
             est_r = tanh(est), ci_lb_r = tanh(lb), ci_ub_r = tanh(ub),
             ms_input = ms_input, ms_label = ms_label, note = note)
  }
  ne_note <- function(msg) sprintf(
    "not estimable [P-T5-4]: documented non-convergence — %s", msg)

  # -- unadjusted RE/ML base (also the 3PSM base model) [F63 = (a)]
  m_ml <- rma(yi = yi, vi = vi, data = agg, method = "ML")
  out <- c(out, list(
    erow("mu_unadjusted_ML", "RE_ML_cluster_agg",
         as.numeric(m_ml$beta)[1], m_ml$se[1], m_ml$zval[1], m_ml$pval[1],
         m_ml$ci.lb[1], m_ml$ci.ub[1],
         paste0(base_note,
                "; rma.uni method=\"ML\" (selmodel base [DEC-031g/F63]); z-test")),
    vrow("tau2_unadjusted", "tau2", "RE_ML_cluster_agg", m_ml$tau2,
         paste0(base_note, "; between-aggregate tau2, ML"))))

  # -- 3PSM {mu, tau2, delta}: selmodel stepfun, steps = 0.025,
  #    alternative = "less" [P-T5-2]
  s3 <- try_offspine(function() selmodel(m_ml, type = "stepfun",
                                         steps = STEPS_3PSM,
                                         alternative = SEL_ALT),
                     what = paste0(analysis_id, "/", spec, " selmodel 3PSM"))
  n3 <- paste0(base_note, sprintf(
    "; selmodel(type=\"stepfun\", steps=%.3f, alternative=\"%s\") on the ML base -> 3PSM {mu, tau2, delta} [DEC-016; DEC-031g/F63; P-T5-2: selection favors significant negative effects]",
    STEPS_3PSM, SEL_ALT))
  if (length(s3$warns)) n3 <- paste0(n3, "; warnings: ",
                                     paste(unique(s3$warns), collapse = " | "))
  if (s3$ok) {
    o <- s3$obj
    d_est <- as.numeric(o$delta); d_est <- d_est[length(d_est)]
    out <- c(out, list(
      erow("mu_3psm", "selmodel_3PSM_ML",
           need_field(o, c("beta", "b"), "3PSM mu"),
           need_field(o, c("se"), "3PSM se"),
           need_field(o, c("zval"), "3PSM zval"),
           need_field(o, c("pval"), "3PSM pval"),
           need_field(o, c("ci.lb"), "3PSM ci.lb"),
           need_field(o, c("ci.ub"), "3PSM ci.ub"),
           n3, ms_input = with_anchor, ms_label = if (with_anchor)
             "mu_3psm_full" else NA_character_),
      vrow("tau2_3psm", "tau2", "selmodel_3PSM_ML",
           need_field(o, c("tau2"), "3PSM tau2"), n3),
      vrow("delta_3psm", "delta", "selmodel_3PSM_ML", d_est,
           paste0(n3, "; relative publication probability of one-sided p > ",
                  STEPS_3PSM, " results (reference interval weight = 1)")),
      {
        lrt  <- need_field(o, c("LRT"),  "3PSM LRT stat")
        lrtp <- need_field(o, c("LRTp"), "3PSM LRT p")
        lrdf <- length(as.numeric(o$delta)) - 1
        row_base(analysis_id, spec, subset_lab, "lrt_3psm",
                 metric = "LRT_test", estimator = "selmodel_3PSM_ML",
                 rho = RHO, k_es = k_es, k_study = k_st, k_cluster = k_agg,
                 t_stat = lrt, df = lrdf, p = lrtp,
                 note = paste0(n3, "; LRT of H0: delta = 1 (no selection); chi-square stat in t_stat, df in df"))
      }))
  } else {
    out <- c(out, list(
      erow("mu_3psm", "selmodel_3PSM_ML", NA_real_, NA_real_, NA_real_,
           NA_real_, NA_real_, NA_real_,
           paste0(n3, "; ", ne_note(s3$msg))),
      vrow("tau2_3psm", "tau2", "selmodel_3PSM_ML", NA_real_,
           paste0(n3, "; ", ne_note(s3$msg))),
      vrow("delta_3psm", "delta", "selmodel_3PSM_ML", NA_real_,
           paste0(n3, "; ", ne_note(s3$msg))),
      row_base(analysis_id, spec, subset_lab, "lrt_3psm",
               metric = "LRT_test", estimator = "selmodel_3PSM_ML",
               rho = RHO, k_es = k_es, k_study = k_st, k_cluster = k_agg,
               note = paste0(n3, "; ", ne_note(s3$msg)))))
  }

  # -- p-uniform* [side = "left"; P-T5-2]
  pu <- try_offspine(function() puni_star(yi = agg$yi, vi = agg$vi,
                                          side = PUNI_SIDE, method = "ML"),
                     what = paste0(analysis_id, "/", spec, " puni_star"))
  npu <- paste0(base_note, sprintf(
    "; puni_star(side=\"%s\", method=\"ML\") [DEC-016; van Aert & van Assen; P-T5-2 direction pin, jointly with selmodel alternative=\"less\"]",
    PUNI_SIDE))
  if (length(pu$warns)) npu <- paste0(npu, "; warnings: ",
                                      paste(unique(pu$warns), collapse = " | "))
  if (pu$ok) {
    o <- pu$obj
    out <- c(out, list(
      erow("mu_punistar", "puni_star_ML",
           need_field(o, c("est"), "puni_star est"),
           NA_real_,
           need_field(o, c("L.0", "L0"), "puni_star test stat"),
           need_field(o, c("pval.0", "pval0"), "puni_star p"),
           need_field(o, c("ci.lb"), "puni_star ci.lb"),
           need_field(o, c("ci.ub"), "puni_star ci.ub"),
           paste0(npu, "; test statistic (L.0) in t_stat; SE not part of the p-uniform* output"),
           ms_input = with_anchor, ms_label = if (with_anchor)
             "mu_punistar_full" else NA_character_),
      vrow("tau2_punistar", "tau2", "puni_star_ML",
           need_field(o, c("tau2", "tau2.est"), "puni_star tau2"), npu)))
  } else {
    out <- c(out, list(
      erow("mu_punistar", "puni_star_ML", NA_real_, NA_real_, NA_real_,
           NA_real_, NA_real_, NA_real_, paste0(npu, "; ", ne_note(pu$msg))),
      vrow("tau2_punistar", "tau2", "puni_star_ML", NA_real_,
           paste0(npu, "; ", ne_note(pu$msg)))))
  }

  # -- T1/A5 identity anchor (full-set block only) [DEC-031g/F65]
  if (with_anchor) {
    mA <- rma(yi = yi, vi = vi, data = agg, method = "REML", test = "knha")
    out <- c(out, list(row_base(
      analysis_id, spec, subset_lab, "mu_anchor_reml_knha",
      metric = "Fisher_z", estimator = "RE_REML_knha_cluster_agg",
      rho = RHO, k_es = k_es, k_study = k_st, k_cluster = k_agg,
      est_z = as.numeric(mA$beta)[1], se_z = mA$se[1],
      t_stat = mA$zval[1], df = mA$k - mA$p, p = mA$pval[1],
      ci_lb_z = mA$ci.lb[1], ci_ub_z = mA$ci.ub[1],
      est_r = tanh(as.numeric(mA$beta)[1]),
      ci_lb_r = tanh(mA$ci.lb[1]), ci_ub_r = tanh(mA$ci.ub[1]),
      note = paste0(base_note,
        "; rma.uni method=\"REML\", test=\"knha\" == T1/A5 one-per-cluster identity anchor [DEC-031g/F65]; verifier re-fits independently and checks against committed output/T1_results.csv"))))
  }
  out
}

rows <- c(rows, selection_block(dat,  "D2", "selection_full", SUBSET_FULL,
                                "2,713/115/114 [DEC-042a]",
                                N_SET, N_SET_ST, K_AGG_FULL,
                                with_anchor = TRUE))
rows <- c(rows, selection_block(pre,  "D4", "selection_pre",  SUBSET_PRE,
                                sprintf("pre cell 1,994/83/%d [DEC-042b]",
                                        K_AGG_PRE),
                                N_PRE, N_PRE_ST, K_AGG_PRE))
rows <- c(rows, selection_block(post, "D4", "selection_post", SUBSET_POST,
                                "post cell 711/31/31 [DEC-042b; upgrade FIRED per DEC-031a.5: post cell 31 >= 20 studies]",
                                N_POST, N_POST_ST, K_AGG_POST))

# ------------------------------ 7. D5 — grey-literature panel ---------
V_full <- impute_covariance_matrix(vi = dat$vi, cluster = dat$cluster_id,
                                   r = RHO)
n5 <- paste0(
  mnote("~ 0 + qs (cell-means [DEC-031f R1]; q_status)",
        "2,713/115/114 [DEC-042a]"),
  "; grey-literature selection panel, main-effects only [DEC-031a.1; DEC-031g Q2]; Paris-interaction variant in the on-demand register; cell inventory pinned ex ante (F60 pattern [DEC-031g])")
f5 <- fit3l(~ 0 + qs, dat, V_full, tag = "D5_grey_panel (cell-means)",
            ladder = FALSE)
m5  <- f5$m
ct5 <- coef_test(m5, vcov = vcr(m5, dat$cluster_id), test = "Satterthwaite")
ci5 <- conf_int(m5, vcov = vcr(m5, dat$cluster_id), level = .95)
df5 <- ct5$df_Satt %||% ct5$df
p5  <- ct5$p_Satt  %||% ct5$p
cf5 <- if (!is.null(ct5$Coef)) as.character(ct5$Coef) else rownames(ct5)
stopifnot(length(cf5) == 2L,
          grepl("0_published", cf5[1], fixed = TRUE),
          grepl("not published", cf5[2], fixed = TRUE))   # level-order guard
cell_terms <- c("cell_published", "cell_not_published")
cell_notes <- c(
  sprintf("published cell; pinned: %d ES / %d studies / %d clusters [DEC-031g]",
          QS_PIN$es[1], QS_PIN$st[1], QS_PIN$cl[1]),
  sprintf("not-published (WP/grey) cell; pinned: %d ES / %d studies / %d clusters [DEC-031g]; >= 3 clusters -> full inference (descriptive-only rule does not fire)",
          QS_PIN$es[2], QS_PIN$st[2], QS_PIN$cl[2]))
for (i in 1:2) {
  rows <- c(rows, list(row_base(
    "D5", "grey_panel", SUBSET_FULL, cell_terms[i], metric = "Fisher_z",
    k_es = N_SET, k_study = N_SET_ST, k_cluster = N_SET_CL,
    est_z = ct5$beta[i], se_z = ct5$SE[i], t_stat = ct5$tstat[i],
    df = df5[i], p = p5[i],
    ci_lb_z = ci5$CI_L[i], ci_ub_z = ci5$CI_U[i],
    est_r = tanh(ct5$beta[i]), ci_lb_r = tanh(ci5$CI_L[i]),
    ci_ub_r = tanh(ci5$CI_U[i]), sigma2 = m5$sigma2,
    note = paste0(n5, "; ", cell_notes[i]))))
}
lc5 <- linear_contrast(m5, vcov = vcr(m5, dat$cluster_id),
                       contrasts = rbind(diff = c(-1, 1)), level = .95)
df5d <- lc5$df %||% lc5$df_Satt
p5d  <- 2 * stats::pt(-abs(lc5$Est / lc5$SE), df = df5d)
rows <- c(rows, list(row_base(
  "D5", "grey_panel", SUBSET_FULL, "contrast_np_minus_p",
  metric = "Fisher_z",
  k_es = N_SET, k_study = N_SET_ST, k_cluster = N_SET_CL,
  est_z = lc5$Est[1], se_z = lc5$SE[1], t_stat = lc5$Est[1] / lc5$SE[1],
  df = df5d[1], p = p5d[1],
  ci_lb_z = lc5$CI_L[1], ci_ub_z = lc5$CI_U[1], sigma2 = m5$sigma2,
  ms_input = TRUE, ms_label = "grey_contrast",
  note = paste0(n5,
    "; not-published minus published contrast (-1, +1); difference of Fisher-z means; no tanh transform of differences"))))
w5 <- Wald_test(m5, constraints = constrain_equal(1:2),
                vcov = vcr(m5, dat$cluster_id), test = "HTZ")
rows <- c(rows, list(row_base(
  "D5", "grey_panel", SUBSET_FULL, "wald_between_groups", metric = "F_test",
  k_es = N_SET, k_study = N_SET_ST, k_cluster = N_SET_CL,
  t_stat = w5$Fstat, df = w5$df_denom, p = w5$p_val, sigma2 = m5$sigma2,
  note = paste0(n5, "; H0: cell means equal; HTZ; num_df = ", w5$df_num))))

# ------------------------------ 8. Design rows (T5_design) ------------
rows <- c(rows, list(
  design_row("subset_estimation", "count", N_SET,
             "2,713 ES / 115 studies / 114 clusters [DEC-042a]; D1/D2/D5 domain; run date in T5_run_meta.txt"),
  design_row("period_pre", "count", N_PRE,
             sprintf("1,994 ES / 83 studies / %d clusters (pre cell) [DEC-042b]", K_AGG_PRE)),
  design_row("period_post", "count", N_POST,
             "711 ES / 31 studies / 31 clusters (post cell) [DEC-042b; v12 design constant]"),
  design_row("period_na", "count", K_NA_ES,
             "8 ES / 2 studies without recoverable windows; listwise from period cells only [DEC-042b]"),
  design_row("agg_k_full", "count", K_AGG_FULL,
             paste0(AGG_NOTE, "; full estimation set -> 114 aggregates")),
  design_row("agg_k_pre", "count", K_AGG_PRE,
             "one-effect-per-cluster aggregates, pre cell (derived; disclosed, not pinned)"),
  design_row("agg_k_post", "count", K_AGG_POST,
             "one-effect-per-cluster aggregates, post cell (= 31, pinned via post-cell clusters)"),
  design_row("qs_cell_published", "count", QS_PIN$es[1],
             sprintf("q_status = \"0_published\": %d ES / %d studies / %d clusters [DEC-031g pin; F60 pattern]",
                     QS_PIN$es[1], QS_PIN$st[1], QS_PIN$cl[1])),
  design_row("qs_cell_not_published", "count", QS_PIN$es[2],
             sprintf("q_status = \"1_not published\": %d ES / %d studies / %d clusters [DEC-031g pin; F60 pattern]; the single multi-study cluster lies inside the published cell",
                     QS_PIN$es[2], QS_PIN$st[2], QS_PIN$cl[2]))
))

# ------------------------------ 9. Assemble + write -------------------
res <- do.call(rbind, rows)
stopifnot(identical(names(res), SCHEMA))
if (nrow(res) != N_ROWS_EXPECTED) {
  print(table(res$analysis_id, res$spec))
  stop(sprintf("ROW BUDGET MISMATCH: got %d, expected %d — see block table above.",
               nrow(res), N_ROWS_EXPECTED))
}
key <- paste(res$analysis_id, res$spec, res$term, sep = "||")
stopifnot(!anyDuplicated(key))
stopifnot(!any(grepl("^bp_", res$ms_label[!is.na(res$ms_label)])),  # P-T5-5
          !any(res$analysis_id == "D3"))                            # Q1

dir.create(here("output"), showWarnings = FALSE)
write_csv(res, here("output", "T5_results.csv"), na = "")

fits_pp <- list(D1 = attr(d1, "fits"), D4_pre = attr(d4a, "fits"),
                D4_post = attr(d4b, "fits"))
rule_lines <- vapply(names(fits_pp), function(nm) sprintf(
  "  %s: PET intercept p = %.6f -> %s carries the corrected-estimate claim [P-T5-1]",
  nm, fits_pp[[nm]]$p_int,
  if (fits_pp[[nm]]$p_int < ALPHA_RULE) "PEESE" else "PET"), character(1))

meta <- c(
  sprintf("T5 run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("dat_prep md5:  %s (asserted == pin %s)", md5_obs, DAT_PREP_MD5),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("domains: full %d/%d/%d [DEC-042a]; period pre %d/%d/%d, post %d/%d/%d, NA %d/%d [DEC-042b]",
          N_SET, N_SET_ST, N_SET_CL, N_PRE, N_PRE_ST, K_AGG_PRE,
          N_POST, N_POST_ST, N_POST_CL, K_NA_ES, K_NA_ST),
  sprintf("aggregates: full %d / pre %d / post %d (%s)",
          K_AGG_FULL, K_AGG_PRE, K_AGG_POST, AGG_NOTE),
  sprintf("q_status pins [DEC-031g, F60 pattern]: %s",
          paste(sprintf("%s = %d/%d/%d", QS_PIN$level, QS_PIN$es, QS_PIN$st,
                        QS_PIN$cl), collapse = "; ")),
  "sez provenance [P-T5-2]: sez = sqrt(vi), derived in-script; raw SE column never read; PEESE regressor I(sez^2) == vi",
  sprintf("direction pins [P-T5-2]: selmodel alternative=\"%s\"; puni_star side=\"%s\" (selection favors significant negative effects)",
          SEL_ALT, PUNI_SIDE),
  sprintf("PET->PEESE rule [P-T5-1]: both always computed and reported; alignment at two-sided alpha = %.2f on the CR2/Satterthwaite PET intercept:",
          ALPHA_RULE),
  rule_lines,
  sprintf("[P-T5-4] not-estimable signature list (case-insensitive substrings): {%s}; any other off-spine condition = S5 hard stop",
          paste(NONCONV_SIG, collapse = ", ")),
  "D3 (RoBMA) executes in the H-session [DEC-031g]; no bp rows [P-T5-5]; trim-and-fill excluded [DEC-031a.4]",
  sprintf("Convergence certificates (%d fits):", length(FIT_LOG)),
  paste0("  ", FIT_LOG),
  r6_line,
  sprintf("N_ROWS = %d (budget: 9 design + 15 PET/PEESE/rule + 25 selection + 4 grey panel)",
          N_ROWS_EXPECTED),
  "", "sessionInfo():", utils::capture.output(utils::sessionInfo()))
writeLines(meta, here("output", "T5_run_meta.txt"))
cat(sprintf("T5 written: %d rows x %d cols -> output/T5_results.csv\n",
            nrow(res), ncol(res)))
cat("Input-contract asserts: ALL PASSED (see paired verifier for output checks).\n")
