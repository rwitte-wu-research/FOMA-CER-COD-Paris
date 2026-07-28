# =============================================================================
# R/10_moderators.R — T7 / Block C: narrative moderators (C0-C9)
# Implements DEC-043 + DEC-048 (analysis_plan A.14). FOMA CER-COD-Paris.
#
# Spine (verbatim): random ~1|cluster_id/study/esid; V blocks within
#   cluster_id, rho=0.6; CR2/Satterthwaite on cluster_id [D31.1/A.2]
# Input contract : output/dat_prep.rds (md5 6702ef3dc45fe0b693b13f50ebd1576b,
#   n = 2713, seed 20260710)
# Outputs        : output/T7_results.csv (200 rows) ·
#   output/T7_background_C0.csv · output/T7_run_meta.txt ·
#   output/T7_sessionInfo.txt
# Executor       : docs/cc_prompt_T7.md — executor only, no result framing
#   [DEC-047]. STOP semantics: [GATES] FAIL / [S5] -> stop; API field
#   mismatch -> labelled [FIXZONE] stop (accessor-only repair permitted).
# =============================================================================

suppressPackageStartupMessages({
  library(metafor)
  library(clubSandwich)
})

set.seed(20260710)
T0_ALL <- proc.time()["elapsed"]

msg <- function(...) { cat(sprintf(...), "\n"); flush.console() }

META <- character(0)
add_meta <- function(...) META <<- c(META, sprintf(...))

# =============================================================================
# FROZEN ZONE — pins [DEC-043 / DEC-048 / A.14]. Do not edit below this line
# except via a logged DEC.
# =============================================================================

MD5_PIN  <- "6702ef3dc45fe0b693b13f50ebd1576b"
SEED_PIN <- 20260710
RHO      <- 0.6
SPINE    <- "random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6; CR2/Satterthwaite on cluster_id [D31.1/A.2]"

NCE <- "99_NCE"
W_ETS <- "with ETS/CT"; O_ETS <- "without ETS/CT"

# F65 anchor (A5 one-per-cluster row; full precision BY VALUE) [DEC-031g]
F65 <- list(est = -0.0616608386540629, se = 0.0243306602731784, df = 113,
            p = 0.0126367644358383, lb = -0.109864264918875, ub = -0.0134574123892513)

# Non-convergence signature list [P-T5-4]; unlisted condition => S5 stop.
SIGS <- c("converg", "opposite sign")
# Contrast-level CR2 degeneracy signature (Wald/vcov not positive definite) [DEC-049]
PD_SIG <- "positive definite"

# Panels: pinned substantive level order (reference/first = B5/DEC-043 refs).
PANELS <- list(
  C1 = list(col = "CER_measure",     levels = c("performance", "disclosure")),
  C2 = list(col = "COD_instrument",  levels = c("loan (interest rate)", "bond (yield)", "rating", "derivativ (CDS spread)")),
  C3 = list(col = "industry",        levels = c("non-sensitive", "sensitive")),
  C4 = list(col = "regulation3",     levels = c("without ETS/CT", "with ETS/CT")),
  C5 = list(col = "country_region",  levels = c("1_US", "2_Europe", "3_AsiaPac")),
  C6 = list(col = "country_econ",    levels = c("1_developed", "2_developing")),
  C7 = list(col = "country_culture", levels = c("1_western", "2_non_western")),
  C8 = list(col = "country_legal",   levels = c("1_common law", "2_civil law"))
)

# Domain pins (ES / studies / clusters) [A.14]
PIN_MA <- list(C1 = c(2713,115,114), C2 = c(2713,115,114), C3 = c(2260,94,93),
               C4 = c(1804,85,84),  C5 = c(1927,91,91),  C6 = c(1622,80,79),
               C7 = c(1956,96,95),  C8 = c(1663,83,82))
PIN_MB <- list(C1 = c(2705,113,112), C2 = c(2705,113,112), C3 = c(2254,93,92),
               C4 = c(1796,83,82),  C5 = c(1919,89,89),  C6 = c(1614,78,77),
               C7 = c(1948,94,93),  C8 = c(1655,81,80))
PIN_MPRE <- list(C3 = c(1754,74,73), C4 = c(1465,64,63))
PIN_GLOBAL <- list(est = c(2713,115,114), period = c(2705,113,112),
                   post = c(711,31,31),  pre = c(1994,83,82))
PIN_REG3_POST <- c(with = 14, without = 6, nce = 11)
PIN_CELL_POST <- c(C2_cds = 0, C5_us = 1, C8_common = 2, C6_developed = 3,
                   C2_rating = 3, C3_sensitive = 3, C4_without = 6)
PIN_V1 <- list(cc = c(1762,80,80), period = c(1754,78,78), post = c(315,19,19))
PIN_V2 <- list(cc = c(1330,58,58), period = c(1324,57,57), post = c(117,9,9))

# Coding-absence disclosure constants (design facts, frozen) [DEC-048]
ABSENCE <- data.frame(
  panel = c("C2","C5","C8"),
  level = c("derivativ (CDS spread)", "1_US", "1_common law"),
  ep_es = c(299,551,612), ep_st = c(10,16,25), ep_cl = c(10,16,24),
  mp_es = c(299,550,606), mp_st = c(10,15,23), mp_cl = c(10,15,22),
  stringsAsFactors = FALSE)

N_ROWS_PIN <- 200
DF_RULE <- 5      # no p below this Satterthwaite df [DEC-024 echo]
CELL_MIN <- 3     # descriptive below this cluster count [Battery C]

SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r","ci_ub_r",
            "pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study","sigma2_esid",
            "pct_cluster","pct_study","pct_esid","pct_sampling","typical_v",
            "value","ms_input","ms_label","note")

# ms_input inventory (exactly 10 TRUE) [DEC-048]; keys = analysis_id::spec::term
MS_KEYS <- c(paste0("C", 1:8, "::paris_mid::interaction_HTZ"),
             "C_family::multiplicity::interaction_HTZ_holm",
             "C9::unified_cc_v1::pp_mid_lag0")

# ============================ end FROZEN ZONE ================================

fail <- function(tag, ...) stop(sprintf("[%s] FAIL %s", tag, sprintf(...)), call. = FALSE)
gate <- function(ok, what) { msg("[GATES] %-52s %s", what, ifelse(ok, "PASS", "FAIL"));
                             if (!ok) fail("GATES", what); add_meta("GATE PASS: %s", what) }

dom <- function(dd) c(nrow(dd), length(unique(dd$study)), length(unique(dd$cluster_id)))
dom_eq <- function(dd, pin) all(dom(dd) == pin)
dstr <- function(dd) paste(dom(dd), collapse = "/")

# --- S1: input contract ------------------------------------------------------
msg("[S1] input contract")
if (!file.exists("output/dat_prep.rds")) fail("GATES", "output/dat_prep.rds missing")
md5 <- unname(tools::md5sum("output/dat_prep.rds"))
gate(identical(md5, MD5_PIN), sprintf("md5(dat_prep) == %s", MD5_PIN))
dp <- readRDS("output/dat_prep.rds")
gate(is.list(dp) && !is.null(dp$dat) && !is.null(dp$n) && dp$n == 2713,
     "dat_prep list contract ($dat, $n == 2713)")
dat <- as.data.frame(dp$dat)

pick <- function(cands, what) {
  hit <- cands[cands %in% names(dat)]
  if (!length(hit)) fail("GATES", "column resolve '%s': none of {%s}; available: %s",
                         what, paste(cands, collapse = ", "), paste(names(dat), collapse = ", "))
  hit[1]
}
COL <- c(zi = pick(c("zi","yi_z","yi"), "zi"), vi = pick(c("vi","vi_z"), "vi"))
need <- c("cluster_id","study","esid","pp_mid_lag0","sample_mid","CER_measure",
          "COD_instrument","industry","regulation_sample_start","regulation_sample_end",
          "country_region","country_econ","country_culture","country_legal")
miss <- setdiff(need, names(dat))
if (length(miss)) fail("GATES", "dat_prep columns missing: %s", paste(miss, collapse = ", "))
add_meta("column mapping: zi=%s vi=%s (others literal)", COL["zi"], COL["vi"])

d <- data.frame(zi = as.numeric(dat[[COL["zi"]]]), vi = as.numeric(dat[[COL["vi"]]]),
                cluster_id = as.character(dat$cluster_id), study = as.character(dat$study),
                esid = as.character(dat$esid), pp = as.integer(dat$pp_mid_lag0),
                sample_mid = as.numeric(dat$sample_mid), stringsAsFactors = FALSE)
for (m in c("CER_measure","COD_instrument","industry","country_region",
            "country_econ","country_culture","country_legal"))
  d[[m]] <- trimws(as.character(dat[[m]]))
d$reg_start <- trimws(as.character(dat$regulation_sample_start))
d$reg_end   <- trimws(as.character(dat$regulation_sample_end))
gate(all(!is.na(d$zi)) && all(is.finite(d$vi)) && all(d$vi > 0), "zi/vi numeric, vi > 0")

# --- S2: regulation3 (Q11a end-anchored; Q11b any-with) + gate ---------------
d$regulation3 <- d$reg_end
d$regulation3_any <- ifelse(d$reg_start == W_ETS | d$reg_end == W_ETS, W_ETS,
                     ifelse(d$reg_start == O_ETS | d$reg_end == O_ETS, O_ETS, NCE))
post_cl <- function(sel) length(unique(d$cluster_id[sel & d$pp %in% 1L]))
gate(post_cl(d$regulation3 == W_ETS) == PIN_REG3_POST["with"] &&
     post_cl(d$regulation3 == O_ETS) == PIN_REG3_POST["without"] &&
     post_cl(d$regulation3 == NCE)   == PIN_REG3_POST["nce"],
     "regulation3 (end-anchored) post clusters == 14/6/11 [Q11a]")

# --- S3: design gates (re-derivation in R) -----------------------------------
gate(dom_eq(d, PIN_GLOBAL$est), sprintf("estimation set == %s", paste(PIN_GLOBAL$est, collapse="/")))
dP <- d[d$pp %in% c(0L,1L), ]
gate(dom_eq(dP, PIN_GLOBAL$period), sprintf("period domain == %s", paste(PIN_GLOBAL$period, collapse="/")))
gate(dom_eq(dP[dP$pp == 1L, ], PIN_GLOBAL$post), "post cell == 711/31/31")
gate(dom_eq(dP[dP$pp == 0L, ], PIN_GLOBAL$pre),  "pre (M-pre outer) == 1994/83/82")
gate(post_cl(d$industry == "sensitive") == 3, "industry sensitive x post clusters == 3")
for (P in names(PANELS)) {
  cl <- PANELS[[P]]$col
  gate(dom_eq(d[d[[cl]] != NCE, ], PIN_MA[[P]]),  sprintf("%s M_A domain == %s", P, paste(PIN_MA[[P]], collapse="/")))
  gate(dom_eq(dP[dP[[cl]] != NCE, ], PIN_MB[[P]]), sprintf("%s M_B domain == %s", P, paste(PIN_MB[[P]], collapse="/")))
}
for (P in names(PIN_MPRE)) {
  cl <- PANELS[[P]]$col
  gate(dom_eq(d[d$pp %in% 0L & d[[cl]] != NCE, ], PIN_MPRE[[P]]),
       sprintf("%s M-pre domain == %s", P, paste(PIN_MPRE[[P]], collapse="/")))
}
cc1 <- d[d$regulation3 != NCE & d$country_region != NCE, ]
gate(dom_eq(cc1, PIN_V1$cc) && dom_eq(cc1[cc1$pp %in% c(0L,1L), ], PIN_V1$period) &&
     dom_eq(cc1[cc1$pp %in% 1L, ], PIN_V1$post), "V1 complete case == 1762/80/80 · 1754/78/78 · 315/19/19")
cc2 <- d[d$industry != NCE & d$regulation3 != NCE & d$country_region != NCE &
         d$country_econ != NCE & d$country_culture != NCE & d$country_legal != NCE, ]
gate(dom_eq(cc2, PIN_V2$cc) && dom_eq(cc2[cc2$pp %in% c(0L,1L), ], PIN_V2$period) &&
     dom_eq(cc2[cc2$pp %in% 1L, ], PIN_V2$post), "V2 complete case == 1330/58/58 · 1324/57/57 · 117/9/9")
gate(post_cl(d$COD_instrument == "derivativ (CDS spread)") == 0 &&
     post_cl(d$country_region == "1_US") == 1 &&
     post_cl(d$country_legal == "1_common law") == 2 &&
     post_cl(d$country_econ == "1_developed") == 3 &&
     post_cl(d$COD_instrument == "rating") == 3 &&
     post_cl(d$regulation3 == O_ETS) == 6,
     "ex-ante small-cell pins (CDS0/US1/common2/dev3/rating3/without6)")

# --- S4: F65 identity (T1 anchor row by value + pinned aggregate refit) ------
msg("[S4] F65 identity")
if (!file.exists("output/T1_results.csv")) fail("GATES", "output/T1_results.csv missing")
t1 <- utils::read.csv("output/T1_results.csv", stringsAsFactors = FALSE, check.names = FALSE)
num_t1 <- as.data.frame(suppressWarnings(lapply(t1, function(x) as.numeric(x))))
hit_rows <- which(apply(num_t1, 1, function(r) any(abs(r - F65$est) < 1e-9, na.rm = TRUE)))
gate(length(hit_rows) == 1, sprintf("F65 A5 row located BY VALUE, unique (rows hit: %d)", length(hit_rows)))
rowv <- suppressWarnings(as.numeric(unlist(num_t1[hit_rows, ])))
near <- function(x, tol = 1e-9) any(abs(rowv - x) < tol, na.rm = TRUE)
gate(near(F65$se) && near(F65$p) && near(F65$lb) && near(F65$ub) && near(F65$df, 1e-9),
     "F65 se/p/CI/df all matched in-row at 1e-9")
gate(identical(round(F65$est - (F65$est %% 1e-12), 3), round(F65$est, 3)) || TRUE,
     sprintf("F65 display canary %.3f == -0.062", round(F65$est, 3)))
if (abs(round(F65$est, 3) - (-0.062)) > 1e-12) fail("GATES", "display canary != -0.062")

es_obj <- escalc(measure = "GEN", yi = zi, vi = vi, data = d)
agg <- aggregate(es_obj, cluster = cluster_id, struct = "CS", rho = RHO)
gate(nrow(agg) == 114, "A5 aggregation k == 114")
fA5 <- rma.uni(yi, vi, data = agg, method = "REML", test = "knha")
gate(abs(as.numeric(fA5$beta) - F65$est) <= 1e-6 && abs(fA5$se - F65$se) <= 1e-6 &&
     abs(fA5$pval - F65$p) <= 1e-6 && (fA5$k - 1) == 113,
     "F65 pinned aggregate refit |delta| <= 1e-6, df == 113")
add_meta("F65 refit: est=%.15g se=%.15g p=%.15g", as.numeric(fA5$beta), fA5$se, fA5$pval)

# --- S5: machinery + smoke test ---------------------------------------------
build_V <- function(dd) {
  n <- nrow(dd); V <- matrix(0, n, n)
  diag(V) <- dd$vi
  for (ix in split(seq_len(n), dd$cluster_id)) {
    if (length(ix) > 1L) {
      s <- sqrt(dd$vi[ix]); B <- RHO * tcrossprod(s); diag(B) <- dd$vi[ix]
      V[ix, ix] <- B
    }
  }
  V
}

LADDER <- list(list(optimizer = "nlminb"),
               list(optimizer = "optim", optmethod = "BFGS"),
               list(optimizer = "optim", optmethod = "Nelder-Mead"))
CERT <- character(0)

fit3l <- function(dd, X, tag, method = "REML") {
  last <- NULL
  for (i in seq_along(LADDER)) {
    ctl <- LADDER[[i]]
    res <- tryCatch(rma.mv(yi = dd$zi, V = build_V(dd), mods = X, intercept = FALSE,
                           random = ~ 1 | cluster_id/study/esid, data = dd,
                           method = method, sparse = TRUE, control = ctl),
                    error = function(e) e)
    if (!inherits(res, "error")) {
      lab <- if (is.null(ctl$optmethod)) ctl$optimizer else paste0(ctl$optimizer, "/", ctl$optmethod)
      CERT <<- c(CERT, sprintf("FIT %-18s optimizer=%s rung=%d converged", tag, lab, i))
      return(res)
    }
    last <- conditionMessage(res)
  }
  if (any(vapply(SIGS, function(s) grepl(s, tolower(last)), logical(1)))) {
    CERT <<- c(CERT, sprintf("FIT %-18s NOT_ESTIMABLE: %s", tag, last))
    return(structure(list(msg = last), class = "t7_not_estimable"))
  }
  stop(sprintf("[S5] unlisted non-convergence condition in %s: %s", tag, last), call. = FALSE)
}

resolve <- function(nms, cands, what) {
  hit <- cands[cands %in% nms]
  if (!length(hit)) stop(sprintf("[FIXZONE] %s fields not found; have: {%s}; expected one of {%s}",
                                 what, paste(nms, collapse = ", "), paste(cands, collapse = ", ")), call. = FALSE)
  hit[1]
}

pd_fail <- function(m) structure(list(msg = m), class = "t7_pd_fail")
safe_wald <- function(fit, Cmat, Vc) {
  wt <- tryCatch(Wald_test(fit, constraints = Cmat, vcov = Vc, test = "HTZ"),
                 error = function(e) e)
  if (inherits(wt, "error")) {
    if (grepl(PD_SIG, tolower(conditionMessage(wt))))
      return(pd_fail(conditionMessage(wt)))
    stop(sprintf("[S5] unlisted Wald condition: %s", conditionMessage(wt)), call. = FALSE)
  }
  wt
}

msg("[S5] smoke test (API accessors + V semantics + zero-fit path)")
sm <- d[d$cluster_id %in% unique(d$cluster_id)[1:8], ]
Vs <- build_V(sm)
i2 <- which(sm$cluster_id == sm$cluster_id[1])[1:2]
stopifnot(abs(Vs[i2[1], i2[2]] - RHO * sqrt(sm$vi[i2[1]] * sm$vi[i2[2]])) < 1e-12)
# Synthetic smoke regressor BY CONSTRUCTION: the row index varies WITHIN every
# cluster, so every cluster contributes identifying variation and the CR2
# adjustment cannot degenerate via single-cluster leverage. Immune to
# window-level constancy and prefix composition of any real column [#24/DEC-049].
Xs <- cbind(a = 1, b = as.numeric(scale(seq_len(nrow(sm)))))
fs <- fit3l(sm, Xs, "smoke")
stopifnot(!inherits(fs, "t7_not_estimable"))
Vc <- vcovCR(fs, cluster = sm$cluster_id, type = "CR2")
ct <- coef_test(fs, vcov = Vc, test = "Satterthwaite")
ACC <- list(beta = resolve(names(ct), c("beta","Est","est","Coef"), "coef_test beta"),
            se   = resolve(names(ct), c("SE","se"), "coef_test SE"),
            df   = resolve(names(ct), c("df_Satt","df"), "coef_test df"),
            p    = resolve(names(ct), c("p_Satt","p_t","p_val","p"), "coef_test p"))
wt <- safe_wald(fs, matrix(c(0, 1), 1), Vc)
if (inherits(wt, "t7_pd_fail"))
  stop("[S5] smoke Wald degenerate on the SYNTHETIC design - genuine anomaly, investigate: ",
       wt$msg, call. = FALSE)
WACC <- list(F = resolve(names(wt), c("Fstat","F"), "Wald_test F"),
             dfn = resolve(names(wt), c("df_num","df1","num_df"), "Wald_test df_num"),
             dfd = resolve(names(wt), c("df_denom","df2","df","denom_df"), "Wald_test df_denom"),
             p = resolve(names(wt), c("p_val","p","pval"), "Wald_test p"))
f0 <- rma.mv(yi = rep(0, nrow(sm)), V = Vs, mods = Xs, intercept = FALSE, data = sm,
             method = "FE", sparse = TRUE)
w0 <- safe_wald(f0, matrix(c(0, 1), 1), vcovCR(f0, cluster = sm$cluster_id, type = "CR2"))
if (inherits(w0, "t7_pd_fail"))
  stop("[S5] smoke zero-fit Wald degenerate on the SYNTHETIC design - genuine anomaly: ",
       w0$msg, call. = FALSE)
stopifnot(is.finite(as.numeric(w0[[WACC$dfd]])))
add_meta("accessors coef_test={%s} Wald_test={%s}", paste(unlist(ACC), collapse = ","),
         paste(unlist(WACC), collapse = ","))
msg("[GATES] %-52s PASS", "smoke test (accessors, V semantics, zero-fit)")

ctab <- function(fit, dd) coef_test(fit, vcov = vcovCR(fit, cluster = dd$cluster_id, type = "CR2"),
                                    test = "Satterthwaite")
contrast1 <- function(fit, dd, cvec) {
  Vc <- vcovCR(fit, cluster = dd$cluster_id, type = "CR2")
  est <- sum(cvec * as.numeric(fit$beta)); v <- drop(t(cvec) %*% as.matrix(Vc) %*% cvec)
  if (!is.finite(v) || v <= 0) return(pd_fail(sprintf("contrast variance = %s", format(v))))
  wt <- safe_wald(fit, matrix(cvec, 1), Vc)
  if (inherits(wt, "t7_pd_fail")) return(wt)
  Fv <- as.numeric(wt[[WACC$F]]); dfd <- as.numeric(wt[[WACC$dfd]]); pv <- as.numeric(wt[[WACC$p]])
  list(est = est, se = sqrt(v), t = sign(est) * sqrt(max(Fv, 0)), df = dfd, p = pv)
}
blockF <- function(fit, dd, Cmat) {
  Vc <- vcovCR(fit, cluster = dd$cluster_id, type = "CR2")
  wt <- safe_wald(fit, Cmat, Vc)
  if (inherits(wt, "t7_pd_fail")) return(wt)
  list(F = as.numeric(wt[[WACC$F]]), dfn = as.numeric(wt[[WACC$dfn]]),
       dfd = as.numeric(wt[[WACC$dfd]]), p = as.numeric(wt[[WACC$p]]))
}

ROWS <- list()
add_row <- function(...) {
  r <- setNames(as.list(rep(NA_character_, length(SCHEMA))), SCHEMA)
  r[c("k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p","ci_lb_z","ci_ub_z",
      "pi_lb_z","pi_ub_z","est_r","ci_lb_r","ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster",
      "sigma2_study","sigma2_esid","rho","value")] <- list(NA_real_)
  r$ms_input <- FALSE
  a <- list(...)
  mk <- paste(a$analysis_id, if (is.null(a$spec)) "" else a$spec, a$term, sep = "::")
  r[names(a)] <- a
  if (mk %in% MS_KEYS) { r$ms_input <- TRUE; r$ms_label <- gsub("::", "_", tolower(mk)) }
  ROWS[[length(ROWS) + 1L]] <<- r
}

emit_est <- function(id, spec, subset, term, cs, dd_dom, sig, note, pi_df = NULL,
                     descr = FALSE, r_scale = TRUE) {
  if (inherits(cs, "t7_pd_fail") || !is.finite(cs$se) || cs$se <= 0) {
    m <- if (inherits(cs, "t7_pd_fail")) cs$msg else sprintf("SE = %s", format(cs$se))
    emit_ne(id, spec, subset, term, dd_dom,
            paste0("contrast not estimable under CR2 (", PD_SIG,
                   "; single/near-single-cluster cell leverage) [DEC-049]: ", m, "; ", note))
    return(invisible(NULL))
  }
  est <- cs$est; se <- cs$se; tt <- cs$t; df <- cs$df; p <- cs$p
  no_p <- descr || (is.finite(df) && df < DF_RULE)
  ci <- est + c(-1, 1) * qt(.975, df) * se
  pil <- piu <- NA_real_
  if (!is.null(pi_df)) {
    sd_pi <- sqrt(se^2 + sum(sig)); pil <- est - qt(.975, df) * sd_pi; piu <- est + qt(.975, df) * sd_pi
  }
  add_row(analysis_id = id, spec = spec, subset = subset, term = term, metric = "Fisher_z",
          estimator = "3LMA-RVE_CR2", rho = RHO, k_es = dd_dom[1], k_study = dd_dom[2],
          k_cluster = dd_dom[3], est_z = est, se_z = se,
          t_stat = if (no_p) NA_real_ else tt, df = df, p = if (no_p) NA_real_ else p,
          ci_lb_z = ci[1], ci_ub_z = ci[2], pi_lb_z = pil, pi_ub_z = piu,
          est_r = if (r_scale) tanh(est) else NA_real_,
          ci_lb_r = if (r_scale) tanh(ci[1]) else NA_real_,
          ci_ub_r = if (r_scale) tanh(ci[2]) else NA_real_,
          pi_lb_r = if (r_scale && is.finite(pil)) tanh(pil) else NA_real_,
          pi_ub_r = if (r_scale && is.finite(piu)) tanh(piu) else NA_real_,
          sigma2_cluster = sig[1], sigma2_study = sig[2], sigma2_esid = sig[3],
          note = if (no_p) paste0("descriptive [DEC-048 double rule]; ", note) else note)
}
emit_F <- function(id, spec, subset, term, bf, dd_dom, sig, note, flagged = FALSE) {
  if (inherits(bf, "t7_pd_fail")) {
    add_row(analysis_id = id, spec = spec, subset = subset, term = term, metric = "F_test",
            estimator = "not_estimable", rho = RHO, k_es = dd_dom[1], k_study = dd_dom[2],
            k_cluster = dd_dom[3],
            note = paste0("HTZ not computable under CR2 (", PD_SIG, ") [DEC-049]: ",
                          bf$msg, "; ", note))
    return(invisible(NULL))
  }
  add_row(analysis_id = id, spec = spec, subset = subset, term = term, metric = "F_test",
          estimator = "3LMA-RVE_CR2", rho = RHO, k_es = dd_dom[1], k_study = dd_dom[2],
          k_cluster = dd_dom[3], t_stat = bf$F, df = bf$dfd, p = bf$p,
          sigma2_cluster = sig[1], sigma2_study = sig[2], sigma2_esid = sig[3],
          note = paste0(note, "; HTZ; num_df = ", bf$dfn,
                        if (flagged) "; touches <3-cluster cell [DEC-048]" else ""))
}
emit_ne <- function(id, spec, subset, term, dd_dom, note) {
  add_row(analysis_id = id, spec = spec, subset = subset, term = term, metric = "Fisher_z",
          estimator = "not_estimable", rho = RHO, k_es = dd_dom[1], k_study = dd_dom[2],
          k_cluster = dd_dom[3], note = note)
}

# --- S6: panels C1-C8 --------------------------------------------------------
msg("[S6] panels C1-C8")
HOLM_P <- setNames(rep(NA_real_, 8), names(PANELS))
t_probe <- NA_real_

for (P in names(PANELS)) {
  colP <- PANELS[[P]]$col; LV <- PANELS[[P]]$levels; L <- length(LV)
  dA <- d[d[[colP]] %in% LV, ]
  XA <- sapply(LV, function(l) as.numeric(dA[[colP]] == l)); colnames(XA) <- LV
  tA0 <- proc.time()["elapsed"]
  fA <- fit3l(dA, XA, paste0(P, "_MA"))
  if (P == "C1") { t_probe <- proc.time()["elapsed"] - tA0
    msg("[COSTPROBE] t(M_A C1 fit) = %.1f s; projection ~ 22 x t = %.1f min", t_probe, 22 * t_probe / 60) }
  sigA <- fA$sigma2; stopifnot(length(sigA) == 3)
  ctA <- ctab(fA, dA)
  noteA <- paste0("rma.mv mods=~ 0 + ", colP, " (cell means, NCE excluded); ", SPINE,
                  "; domain = M_A classified [A.14]")
  for (i in seq_along(LV)) {
    dl <- dom(dA[dA[[colP]] == LV[i], ])
    cs <- list(est = ctA[[ACC$beta]][i], se = ctA[[ACC$se]][i], t = ctA[[ACC$beta]][i]/ctA[[ACC$se]][i],
               df = ctA[[ACC$df]][i], p = ctA[[ACC$p]][i])
    emit_est(P, "levels", "classified", paste0("lvl::", LV[i]), cs, dl, sigA, noteA, pi_df = TRUE)
  }
  for (i in 1:(L-1)) for (j in (i+1):L) {
    cv <- rep(0, L); cv[i] <- 1; cv[j] <- -1
    cs <- contrast1(fA, dA, cv)
    emit_est(P, "levels", "classified", paste0("pair::", LV[i], " - ", LV[j]), cs, dom(dA), sigA,
             paste0("pairwise contrast (z scale); ", noteA), r_scale = FALSE)
  }
  Comn <- t(sapply(2:L, function(j) { v <- rep(0, L); v[1] <- 1; v[j] <- -1; v }))
  emit_F(P, "levels", "classified", "levels_HTZ", blockF(fA, dA, matrix(Comn, ncol = L)),
         dom(dA), sigA, paste0("H0: all level means equal; ", noteA))

  # M_B: nonempty level x period cells
  dB <- dP[dP[[colP]] %in% LV, ]
  cells <- expand.grid(lvl = LV, per = c(0L, 1L), stringsAsFactors = FALSE)
  cells$n_cl <- mapply(function(l, p2) length(unique(dB$cluster_id[dB[[colP]] == l & dB$pp == p2])),
                       cells$lvl, cells$per)
  live <- cells[cells$n_cl > 0, ]
  XB <- do.call(cbind, lapply(seq_len(nrow(live)), function(k)
    as.numeric(dB[[colP]] == live$lvl[k] & dB$pp == live$per[k])))
  colnames(XB) <- paste0(live$lvl, "||", ifelse(live$per == 1, "post", "pre"))
  fB <- fit3l(dB, XB, paste0(P, "_MB")); sigB <- fB$sigma2
  ctB <- ctab(fB, dB)
  noteB <- paste0("rma.mv mods=~ 0 + cell(", colP, " x pp_mid_lag0), nonempty cells; ", SPINE,
                  "; domain = M_B period+classified [A.14]")
  cget <- function(nm) { i <- match(nm, colnames(XB)); list(est = ctB[[ACC$beta]][i],
           se = ctB[[ACC$se]][i], t = ctB[[ACC$beta]][i]/ctB[[ACC$se]][i],
           df = ctB[[ACC$df]][i], p = ctB[[ACC$p]][i]) }
  for (l in LV) for (pp2 in c(0L, 1L)) {
    nm <- paste0(l, "||", ifelse(pp2 == 1, "post", "pre"))
    dl <- dom(dB[dB[[colP]] == l & dB$pp == pp2, ])
    trm <- paste0(ifelse(pp2 == 1, "cell_post::", "cell_pre::"), l)
    if (nm %in% colnames(XB)) {
      ncl <- cells$n_cl[cells$lvl == l & cells$per == pp2]
      emit_est(P, "paris_mid", "defined_classified", trm, cget(nm), dl, sigB, noteB,
               descr = ncl < CELL_MIN)
    } else emit_ne(P, "paris_mid", "defined_classified", trm, dl,
                   paste0("0 clusters in cell (empty by design; ex-ante pin) [DEC-048]; ", noteB))
  }
  diff_ok <- LV[vapply(LV, function(l) all(paste0(l, "||", c("pre","post")) %in% colnames(XB)), logical(1))]
  cvec_diff <- function(l) { v <- rep(0, ncol(XB));
    v[match(paste0(l, "||post"), colnames(XB))] <- 1
    v[match(paste0(l, "||pre"),  colnames(XB))] <- -1; v }
  for (l in LV) {
    trm <- paste0("diff::", l)
    if (l %in% diff_ok) {
      ncl_min <- min(cells$n_cl[cells$lvl == l])
      cs <- contrast1(fB, dB, cvec_diff(l))
      emit_est(P, "paris_mid", "defined_classified", trm, cs, dom(dB), sigB,
               paste0("post minus pre within level (z scale); ", noteB),
               descr = ncl_min < CELL_MIN, r_scale = FALSE)
    } else emit_ne(P, "paris_mid", "defined_classified", trm, dom(dB),
                   paste0("diff not estimable: one period cell empty [DEC-048]; ", noteB))
  }
  flagged <- any(cells$n_cl[cells$lvl %in% diff_ok] < CELL_MIN)
  if (length(diff_ok) >= 2) {
    Cint <- t(sapply(diff_ok[-1], function(l) cvec_diff(l) - cvec_diff(diff_ok[1])))
    bf <- blockF(fB, dB, matrix(Cint, ncol = ncol(XB)))
    if (!inherits(bf, "t7_pd_fail")) HOLM_P[P] <- bf$p
    emit_F(P, "paris_mid", "defined_classified", "interaction_HTZ", bf, dom(dB), sigB,
           paste0("H0: Paris shift equal across levels {", paste(diff_ok, collapse = ", "), "}; ", noteB),
           flagged = flagged)
  }
  msg("  %s done (%s levels; M_A %s; M_B %s)", P, L, dstr(dA), dstr(dB))
}
msg("[PANELS DONE] rows so far = %d", length(ROWS))

# Holm family row [R7]
fin <- HOLM_P[is.finite(HOLM_P)]
adj <- p.adjust(fin, method = "holm")
add_row(analysis_id = "C_family", spec = "multiplicity", subset = "defined_classified",
        term = "interaction_HTZ_holm", metric = "p_holm", estimator = "derived",
        value = min(adj), note = paste0("Holm over the panel interaction-HTZ p-values [DEC-048]; ",
        "m_effective = ", length(fin), " of 8 (ne panels excluded per DEC-049, disclosed); ",
        "adjusted: ", paste(sprintf("%s=%.4g", names(adj), adj), collapse = "; "),
        "; n significant at .05 = ", sum(adj < .05)))

# --- S7: M-pre (C3/C4) [DEC-031c] -------------------------------------------
for (P in names(PIN_MPRE)) {
  colP <- PANELS[[P]]$col; LV <- PANELS[[P]]$levels
  dm <- d[d$pp %in% 0L & d[[colP]] %in% LV, ]
  dm$ts_knot <- dm$sample_mid - 2015.5
  Xm <- cbind(sapply(LV, function(l) as.numeric(dm[[colP]] == l)),
              sapply(LV, function(l) as.numeric(dm[[colP]] == l) * dm$ts_knot))
  colnames(Xm) <- c(paste0("int::", LV), paste0("slope::", LV))
  fm <- fit3l(dm, Xm, paste0(P, "_Mpre")); sigM <- fm$sigma2; ctM <- ctab(fm, dm)
  noteM <- paste0("rma.mv mods=~ 0 + ", colP, " + ", colP,
                  ":ts_knot (ts_knot = sample_mid - 2015.5), pre domain, NCE excluded [DEC-031c]; ", SPINE)
  for (i in seq_along(colnames(Xm))) {
    cs <- list(est = ctM[[ACC$beta]][i], se = ctM[[ACC$se]][i],
               t = ctM[[ACC$beta]][i]/ctM[[ACC$se]][i], df = ctM[[ACC$df]][i], p = ctM[[ACC$p]][i])
    emit_est(P, "m_pre", "pre_classified", paste0("mpre_", colnames(Xm)[i]), cs, dom(dm), sigM,
             noteM, r_scale = grepl("^int::", colnames(Xm)[i]))
  }
  cv <- rep(0, ncol(Xm)); cv[length(LV) + 1] <- 1; cv[length(LV) + 2] <- -1
  emit_F(P, "m_pre", "pre_classified", "mpre_slope_HTZ", blockF(fm, dm, matrix(cv, 1)),
         dom(dm), sigM, paste0("H0: pre-trend slopes equal across exposure levels; ", noteM))
}

# --- S8: Q11b any-with sensitivity (C4 M_B refit) ----------------------------
da <- dP[dP$regulation3_any %in% c(O_ETS, W_ETS), ]
gate(all(dom(da) == PIN_MB$C4), "any-with M_B domain == end-anchored C4 M_B domain [Q11b]")
LVa <- c(O_ETS, W_ETS)
cells_a <- expand.grid(lvl = LVa, per = c(0L,1L), stringsAsFactors = FALSE)
cells_a$n_cl <- mapply(function(l, p2) length(unique(da$cluster_id[da$regulation3_any == l & da$pp == p2])),
                       cells_a$lvl, cells_a$per)
Xa <- do.call(cbind, lapply(seq_len(nrow(cells_a)), function(k)
  as.numeric(da$regulation3_any == cells_a$lvl[k] & da$pp == cells_a$per[k])))
colnames(Xa) <- paste0(cells_a$lvl, "||", ifelse(cells_a$per == 1, "post", "pre"))
fa <- fit3l(da, Xa, "C4_anywith"); siga <- fa$sigma2; cta <- ctab(fa, da)
notea <- paste0("rma.mv mods=~ 0 + cell(regulation3_any x pp_mid_lag0); any-with coding sensitivity, ",
                "appendix, descriptive framing [DEC-048 Q11b]; ", SPINE)
for (k in seq_len(nrow(cells_a))) {
  nm <- colnames(Xa)[k]
  cs <- list(est = cta[[ACC$beta]][k], se = cta[[ACC$se]][k], t = cta[[ACC$beta]][k]/cta[[ACC$se]][k],
             df = cta[[ACC$df]][k], p = cta[[ACC$p]][k])
  dl <- dom(da[da$regulation3_any == cells_a$lvl[k] & da$pp == cells_a$per[k], ])
  emit_est("C4", "paris_mid_anywith", "defined_classified",
           paste0(ifelse(cells_a$per[k] == 1, "cell_post::", "cell_pre::"), cells_a$lvl[k]),
           cs, dl, siga, notea, descr = cells_a$n_cl[k] < CELL_MIN)
}
cva <- function(l) { v <- rep(0, ncol(Xa)); v[match(paste0(l,"||post"), colnames(Xa))] <- 1
                     v[match(paste0(l,"||pre"), colnames(Xa))] <- -1; v }
for (l in LVa) emit_est("C4", "paris_mid_anywith", "defined_classified", paste0("diff::", l),
                        contrast1(fa, da, cva(l)), dom(da), siga,
                        paste0("post minus pre within level (z scale); ", notea),
                        descr = min(cells_a$n_cl[cells_a$lvl == l]) < CELL_MIN, r_scale = FALSE)
emit_F("C4", "paris_mid_anywith", "defined_classified", "interaction_HTZ",
       blockF(fa, da, matrix(cva(W_ETS) - cva(O_ETS), 1)), dom(da), siga,
       paste0("H0: Paris shift equal across any-with exposure levels; ", notea))

# --- S9: disclosure rows -----------------------------------------------------
for (P in names(PANELS)) {
  colP <- PANELS[[P]]$col
  dn <- d[d[[colP]] == NCE, ]; dl <- dom(dn)
  add_row(analysis_id = P, spec = "design", subset = "nce", term = "nce_excluded",
          metric = "count", estimator = "descriptive", k_es = dl[1], k_study = dl[2],
          k_cluster = dl[3], value = dl[1],
          note = sprintf("99_NCE rows excluded from %s analyses [DEC-048 NCE regime]: %d ES / %d studies / %d clusters",
                         P, dl[1], dl[2], dl[3]))
}
for (k in seq_len(nrow(ABSENCE))) {
  a <- ABSENCE[k, ]
  add_row(analysis_id = a$panel, spec = "design", subset = "defined", term = "end_coding_absence",
          metric = "count", estimator = "descriptive", k_es = a$ep_es, k_study = a$ep_st,
          k_cluster = a$ep_cl, value = a$mp_cl,
          note = sprintf(paste0("coding-robustness of the empty/thin post cell for level '%s': under the ",
                 "maximally inclusive end coding an end-'post' cell of %d/%d/%d (ES/studies/clusters) emerges, ",
                 "of which %d/%d/%d are majority-pre windows — the absence is coding-robust, not coding-dependent ",
                 "[DEC-048; design facts frozen 2026-07-28]"),
                 a$level, a$ep_es, a$ep_st, a$ep_cl, a$mp_es, a$mp_st, a$mp_cl))
}

# --- S10: C9 design rule + V1/V2 --------------------------------------------
msg("[S10] C9 unified (V1/V2)")
mk_fac <- function(dd, col, ref) { f <- factor(dd[[col]]); relevel(f, ref = ref) }
REFS <- c(CER_measure = "performance", COD_instrument = "loan (interest rate)",
          industry = "non-sensitive", regulation3 = "without ETS/CT",
          country_region = "1_US", country_econ = "1_developed",
          country_culture = "1_western", country_legal = "1_common law")

design_rule <- function(dd, mods_cols, variant) {
  ddp <- dd[dd$pp %in% c(0L, 1L), ]
  base_terms <- paste0("factor_", mods_cols)
  df_ <- data.frame(pp = ddp$pp)
  for (mc in mods_cols) df_[[paste0("factor_", mc)]] <- mk_fac(ddp, mc, REFS[[mc]])
  Xmain <- model.matrix(as.formula(paste("~ pp +", paste(base_terms, collapse = " + "))), df_)
  out <- list(); echo <- list()
  for (mc in mods_cols) {
    lv_post <- unique(ddp[[mc]][ddp$pp == 1L])
    if (length(lv_post) < 2) {
      echo[[mc]] <- list(df = NA_real_, verdict = "excluded_structural",
                         note = sprintf("only post level(s): %s", paste(lv_post, collapse = ", ")))
      next
    }
    Xi <- model.matrix(as.formula(paste0("~ pp * factor_", mc)), df_)
    intc <- grep("^pp:factor_", colnames(Xi), value = TRUE)
    Xfull <- cbind(Xmain, Xi[, intc, drop = FALSE])
    f0 <- rma.mv(yi = rep(0, nrow(ddp)), V = build_V(ddp), mods = Xfull, intercept = FALSE,
                 data = ddp, method = "FE", sparse = TRUE)
    Cm <- matrix(0, length(intc), ncol(Xfull)); Cm[cbind(seq_along(intc), ncol(Xmain) + seq_along(intc))] <- 1
    w0 <- safe_wald(f0, Cm, vcovCR(f0, cluster = ddp$cluster_id, type = "CR2"))
    if (inherits(w0, "t7_pd_fail")) {
      echo[[mc]] <- list(df = NA_real_, verdict = "excluded_pd",
                         note = sprintf("design HTZ not computable (%s) [DEC-049]", PD_SIG))
    } else {
      dfd <- as.numeric(w0[[WACC$dfd]])
      echo[[mc]] <- list(df = dfd, verdict = ifelse(dfd >= DF_RULE, "admitted", "excluded_df"),
                         note = sprintf("design-df (outcome-zeroed FE, CR2/HTZ) = %.3f", dfd))
    }
  }
  echo
}

fit_variant <- function(dd, mods_cols, variant, dom_pin_p) {
  ddp <- dd[dd$pp %in% c(0L, 1L), ]
  echo <- design_rule(dd, mods_cols, variant)
  for (mc in mods_cols)
    add_row(analysis_id = "C9", spec = "design_rule", subset = variant, term = paste0("rule::", mc),
            metric = "design_df", estimator = "descriptive",
            value = if (is.na(echo[[mc]]$df)) NA_real_ else echo[[mc]]$df,
            note = sprintf("%s; verdict = %s [DEC-043 mechanical rule: identifiability + design-df >= %d]",
                           echo[[mc]]$note, echo[[mc]]$verdict, DF_RULE))
  admitted <- names(echo)[vapply(echo, function(e) identical(e$verdict, "admitted"), logical(1))]
  df_ <- data.frame(pp = ddp$pp)
  for (mc in mods_cols) df_[[paste0("factor_", mc)]] <- mk_fac(ddp, mc, REFS[[mc]])
  rhs <- paste(c("pp", paste0("factor_", mods_cols),
                 if (length(admitted)) paste0("pp:factor_", admitted)), collapse = " + ")
  X <- model.matrix(as.formula(paste("~", rhs)), df_)
  fv <- fit3l(ddp, X, paste0("C9_", variant)); sig <- fv$sigma2
  fv2 <- tryCatch(rma.mv(yi = ddp$zi, V = build_V(ddp), mods = X, intercept = FALSE,
                         random = ~ 1 | cluster_id/study/esid, data = ddp, method = "REML",
                         sparse = TRUE, control = list(optimizer = "optim", optmethod = "BFGS")),
                  error = function(e) NULL)
  hard <- if (!is.null(fv2)) max(abs(as.numeric(fv$beta) - as.numeric(fv2$beta))) else NA_real_
  CERT <<- c(CERT, sprintf("FIT C9_%s hardening refit max|dBeta| = %s [A.11 < 1e-5]",
                           variant, format(hard, digits = 6)))
  if (is.finite(hard) && hard >= 1e-5) fail("GATES", "C9 %s hardening refit |dBeta| >= 1e-5", variant)
  ctv <- ctab(fv, ddp)
  noteV <- paste0("rma.mv mods=~ pp_mid_lag0 + mains(", paste(mods_cols, collapse = ", "),
                  ") + admitted pp interactions {", paste(admitted, collapse = ", "),
                  "}; reference coding, refs per DEC-043; complete case, NCE excluded; ", SPINE)
  for (i in seq_len(ncol(X))) {
    cs <- list(est = ctv[[ACC$beta]][i], se = ctv[[ACC$se]][i],
               t = ctv[[ACC$beta]][i]/ctv[[ACC$se]][i], df = ctv[[ACC$df]][i], p = ctv[[ACC$p]][i])
    trm <- colnames(X)[i]
    trm <- sub("^\\(Intercept\\)$", "intercept", trm)
    trm <- gsub("factor_", "", trm, fixed = TRUE)
    trm <- sub("^pp$", "pp_mid_lag0", trm); trm <- sub("^pp:", "pp:", trm)
    emit_est("C9", paste0("unified_", variant), variant, trm, cs, dom(ddp), sig, noteV,
             r_scale = FALSE)
  }
  for (mc in mods_cols) {
    if (mc %in% admitted) {
      intc <- grep(paste0("^pp:factor_", mc), colnames(X))
      Cm <- matrix(0, length(intc), ncol(X)); Cm[cbind(seq_along(intc), intc)] <- 1
      emit_F("C9", paste0("unified_", variant), variant, paste0("block_HTZ::", mc),
             blockF(fv, ddp, Cm), dom(ddp), sig,
             paste0("H0: all pp x ", mc, " interaction coefficients = 0; ", noteV))
    } else {
      lvn <- length(levels(df_[[paste0("factor_", mc)]])) - 1L
      for (j in seq_len(lvn))
        emit_ne("C9", paste0("unified_", variant), variant,
                paste0("pp:", mc, "::coef", j), dom(ddp),
                sprintf("interaction block excluded by the mechanical rule (verdict = %s) [DEC-043]; %s",
                        echo[[mc]]$verdict, noteV))
      add_row(analysis_id = "C9", spec = paste0("unified_", variant), subset = variant,
              term = paste0("block_HTZ::", mc), metric = "F_test", estimator = "not_estimable",
              rho = RHO, k_es = dom(ddp)[1], k_study = dom(ddp)[2], k_cluster = dom(ddp)[3],
              note = sprintf("block excluded by the mechanical rule (verdict = %s) [DEC-043]",
                             echo[[mc]]$verdict))
    }
  }
  invisible(NULL)
}

fit_variant(cc1, c("CER_measure","COD_instrument","regulation3","country_region"), "cc_v1", PIN_V1$period)
fit_variant(cc2, c("CER_measure","COD_instrument","industry","regulation3","country_region",
                   "country_econ","country_culture","country_legal"), "cc_v2", PIN_V2$period)
msg("[C9 DONE] certificates = %d", length(CERT))

# --- S11: C0 background (separate file; never in results) [K5/r15] ----------
msg("[S11] C0 background association matrix")
mods8 <- c("CER_measure","COD_instrument","industry","regulation3","country_region",
           "country_econ","country_culture","country_legal")
cram <- function(x, y) {
  tb <- table(x, y); n <- sum(tb)
  chi <- suppressWarnings(chisq.test(tb, correct = FALSE)$statistic)
  as.numeric(sqrt(chi / (n * (min(dim(tb)) - 1))))
}
modal <- function(v) names(sort(table(v), decreasing = TRUE))[1]
dcl <- aggregate(d[mods8], by = list(cluster_id = d$cluster_id), FUN = modal)
c0 <- list()
for (i in seq_along(mods8)) for (j in seq_along(mods8)) if (i < j) {
  c0[[length(c0) + 1]] <- data.frame(basis = "es_level", var1 = mods8[i], var2 = mods8[j],
                                     n = nrow(d), cramers_v = cram(d[[mods8[i]]], d[[mods8[j]]]))
  c0[[length(c0) + 1]] <- data.frame(basis = "cluster_modal", var1 = mods8[i], var2 = mods8[j],
                                     n = nrow(dcl), cramers_v = cram(dcl[[mods8[i]]], dcl[[mods8[j]]]))
}
c0 <- do.call(rbind, c0)
utils::write.csv(c0, "output/T7_background_C0.csv", row.names = FALSE, na = "")

# --- S12: assemble + write ---------------------------------------------------
res <- do.call(rbind, lapply(ROWS, function(r) as.data.frame(r, stringsAsFactors = FALSE)))
res <- res[, SCHEMA]
if (nrow(res) != N_ROWS_PIN) fail("GATES", "row budget: %d != %d", nrow(res), N_ROWS_PIN)
key <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "|")
if (any(duplicated(key))) fail("GATES", "4-key duplicates: %s", paste(key[duplicated(key)], collapse = "; "))
if (sum(res$ms_input) != 10) fail("GATES", "ms_input TRUE count %d != 10", sum(res$ms_input))
utils::write.csv(res, "output/T7_results.csv", row.names = FALSE, na = "")

writeLines(c(sprintf("T7 run_meta — %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
             sprintf("R: %s | metafor %s | clubSandwich %s", R.version.string,
                     as.character(utils::packageVersion("metafor")),
                     as.character(utils::packageVersion("clubSandwich"))),
             sprintf("seed = %d | rho = %.1f | md5(dat_prep) = %s", SEED_PIN, RHO, md5),
             sprintf("spine: %s", SPINE),
             sprintf("[COSTPROBE] t(M_A C1) = %.1f s; projection ~ 22 fits", t_probe),
             META, CERT,
             sprintf("rows = %d | ms_input TRUE = %d | elapsed = %.1f min",
                     nrow(res), sum(res$ms_input), (proc.time()["elapsed"] - T0_ALL)/60)),
           "output/T7_run_meta.txt")
writeLines(capture.output(sessionInfo()), "output/T7_sessionInfo.txt")

msg("[WRITE] output/T7_results.csv (%d rows) · T7_background_C0.csv (%d rows) · run_meta · sessionInfo",
    nrow(res), nrow(c0))
msg("[DONE] elapsed %.1f min", (proc.time()["elapsed"] - T0_ALL)/60)
