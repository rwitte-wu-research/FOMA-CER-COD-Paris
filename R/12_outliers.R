# R/12_outliers.R -- TF run: outliers & influence block F (F1-F7) [DEC-051, route amended per DEC-051a]
# Spine verbatim: random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6;
# CR2/Satterthwaite on cluster_id [D31.1/A.2]. Seed 20260710.
# Budget: <= 130 model fits (planned 121 incl. Gate A + smoke); TF_results.csv <= 40 rows.
# Runtime (this machine; serial F1 pass empirically > 10 h on 2026-07-30): rstudent pass
# parallel snow (ncpus = 8) ~1.5-3 h; LOO (W = 8) ~15-25 min; total ~2-3.5 h [DEC-051a].
# Outputs written ONLY after all stops/asserts pass (no outputs on a stop).
suppressPackageStartupMessages({ library(metafor); library(clubSandwich); library(parallel) })
set.seed(20260710)

## ---------------- FIXZONE (CC may edit ONLY this block: paths + column binds) ----------------
DAT_CANDIDATES <- c("output/dat_prep.rds", "data/dat_prep.rds")  # .RDS variant removed: case-insensitive NTFS made it a duplicate hit of candidate 1 (S-A length==2)
MD5_PIN <- "6702ef3dc45fe0b693b13f50ebd1576b"
COL <- list(zi = "zi", vi = "vi")               # block F consumes only zi/vi + the id trio (cluster_id/study/esid, bound by name below)
HEADER_SRC <- "output/T7_results.csv"           # 36-column schema transplant [DEC-048]
W_PSOCK <- 8L                                   # LOO parallelization; worker pin per DEC-051a (RAM 15.7 GB total / ~5.8 GB available); designed serial fallback prints a note
RS_NCPUS <- 8L                                  # F1 rstudent pass: parallel snow workers, pin per DEC-051a (measured RAM)
## ---------------------------------------------------------------------------------------------

TOL_T <- 1e-9; TOL_L <- 1e-6
F65 <- list(est = -0.0616608386540629, se = 0.0243306602731784, df = 113,
            p = 0.0126367644358383, lb = -0.109864264918875, ub = -0.0134574123892513)
DOM <- c(es = 2713L, study = 115L, cluster = 114L)
RSTUDENT_THRESH <- 3        # conditional rule resolved: no threshold row in committed T1_results.csv [DEC-051 no. 2]
MAD_K <- 3; MAD_B <- 1.4826 # Leys et al. 2013 [DEC-051 no. 3]
WINSOR_P <- c(0.01, 0.99); Q_TYPE <- 7L  # empirical percentiles, R default type (A.13/H3 pin) [DEC-051 no. 5]
MAX_FITS <- 130L; MAX_ROWS <- 40L; LOO_NE_MAX <- 5L
FITS <- 0L
stop_s <- function(code, msg) stop(sprintf("[%s] %s", code, msg), call. = FALSE)

## ---- M0: bind + inventory (hard asserts; auto-continue on PASS) ----
hit <- DAT_CANDIDATES[file.exists(DAT_CANDIDATES)]
hit <- hit[vapply(hit, function(p) unname(tools::md5sum(p)) == MD5_PIN, logical(1))]
if (length(hit) != 1) stop_s("S-A", "dat_prep not found by md5 pin; extend DAT_CANDIDATES (fixzone)")
dat <- readRDS(hit[1])
if (!is.data.frame(dat)) dat <- dat$dat   # accessor fix: dat_prep.rds is a container list(dat, built, seed, n, sessionInfo)
dat <- as.data.frame(dat)
cat("M0 dat_prep:", hit[1], "| md5 OK |", nrow(dat), "rows\n")
need <- c(unlist(COL), "cluster_id", "study", "esid")
miss <- setdiff(need, colnames(dat))
if (length(miss)) stop_s("S-A", paste("missing columns (rebind in fixzone):", paste(miss, collapse = ", ")))
stopifnot(nrow(dat) == DOM["es"],
          length(unique(dat$study)) == DOM["study"],
          length(unique(dat$cluster_id)) == DOM["cluster"])
zi <- dat[[COL$zi]]; vi <- dat[[COL$vi]]
if (!all(is.finite(zi)) || !all(is.finite(vi)) || any(vi <= 0)) stop_s("S-A", "zi/vi not finite-positive on the estimation set")
cat("M0 PASS\n")

## ---- Gate A: F65 pre-flight aggregate identity [DEC-048] ----
es <- escalc(measure = "GEN", yi = dat[[COL$zi]], vi = dat[[COL$vi]], data = dat)
agg <- aggregate(es, cluster = cluster_id, struct = "CS", rho = 0.6)
gA <- rma.uni(yi, vi, data = agg, method = "REML", test = "knha"); FITS <- FITS + 1L
stopifnot(abs(unname(gA$beta[1]) - F65$est) < TOL_T, abs(gA$se - F65$se) < TOL_T,
          gA$dfs == F65$df, abs(gA$pval - F65$p) < TOL_T,
          abs(gA$ci.lb - F65$lb) < TOL_L, abs(gA$ci.ub - F65$ub) < TOL_L)
cat("Gate A (F65 aggregate) PASS\n")

## ---- spine fitter with optimizer ladder [DEC-031f] + signature policies [P-T5-4, DEC-049] ----
LADDER <- list(list(optimizer = "nlminb"), list(optimizer = "optim", optmethod = "BFGS"),
               list(optimizer = "nlminb", rel.tol = 1e-7))
fit3l <- function(d, mods = NULL, vi_override = NULL) {
  v <- if (is.null(vi_override)) d[[COL$vi]] else vi_override
  V <- impute_covariance_matrix(v, cluster = d$cluster_id, r = 0.6)
  for (ct in LADDER) {
    f <- tryCatch(if (is.null(mods))   # API fix: metafor 5.x rejects an explicit NULL 'mods' variable; omit the arg instead
                    rma.mv(yi = d[[COL$zi]], V = V, data = d,
                           random = ~ 1 | cluster_id / study / esid, method = "REML",
                           sparse = TRUE, control = ct)
                  else
                    rma.mv(yi = d[[COL$zi]], V = V, mods = mods, data = d,
                           random = ~ 1 | cluster_id / study / esid, method = "REML",
                           sparse = TRUE, control = ct),
                  error = function(e) e, warning = function(w) w)
    if (inherits(f, "rma.mv")) return(f)
    m <- conditionMessage(f)
    if (grepl("positive definite", m, ignore.case = TRUE)) return(structure(list(msg = m), class = "not_estimable"))
    if (!grepl("converg|opposite sign", m, ignore.case = TRUE)) stop_s("S5", paste("unlisted signature:", m))
  }
  structure(list(msg = "ladder exhausted"), class = "not_estimable")
}
ct_int <- function(f, d) clubSandwich::coef_test(f, vcov = "CR2", cluster = d$cluster_id, test = "Satterthwaite")

## ---- accessors (toy-probe-validated in the smoke block; tolerant, never guessed) [#16/#28] ----
rstudent_z <- function(rs) {
  z <- NULL
  if (is.list(rs) && !is.null(rs$z)) z <- rs$z
  else if (is.data.frame(rs) && "z" %in% colnames(rs)) z <- rs[["z"]]
  else if (is.list(rs) && !is.null(rs$obs) && !is.null(rs$obs$z)) z <- rs$obs$z
  if (is.null(z)) stop_s("S-F1", paste("rstudent accessor: no 'z' component; structure:",
      paste(utils::capture.output(utils::str(rs, max.level = 2)), collapse = " ~ ")))
  as.numeric(z)
}
hat_vec <- function(f) {
  h <- tryCatch(hatvalues(f), error = function(e) stop_s("S-F1", paste("hatvalues API:", conditionMessage(e))))
  h <- as.numeric(h)
  if (!length(h)) stop_s("S-F1", "hatvalues returned length 0")
  h
}

## ---- Smoke [S-F1 toy probes], synthetically conditioned per DEC-049a (no zero outcome) ----
n_toy <- 24L
toy <- data.frame(cluster_id = rep(sprintf("tc%02d", 1:6), each = 4),
                  study      = rep(sprintf("ts%02d", 1:12), each = 2),
                  esid       = sprintf("te%02d", 1:n_toy))
toy[[COL$zi]] <- sin(1:n_toy)                       # deterministic non-degenerate outcome [DEC-049a]
toy[[COL$vi]] <- 0.01 + 0.002 * ((1:n_toy) %% 5)    # row-index-conditioned positive variances [#24/#26]
f_toy <- fit3l(toy); FITS <- FITS + 1L
if (inherits(f_toy, "not_estimable")) stop_s("S-F1", paste("toy spine fit not estimable:", f_toy$msg))
tt_toy <- ct_int(f_toy, toy)
if (!is.finite(tt_toy$beta[1]) || !is.finite(tt_toy$SE[1])) stop_s("S-F1", "toy CR2 coef_test non-finite")
rs_toy <- tryCatch(rstudent(f_toy, reestimate = FALSE),
                   error = function(e) stop_s("S-F1", paste("rstudent API:", conditionMessage(e))))
z_toy <- rstudent_z(rs_toy)
if (length(z_toy) != n_toy || sum(is.finite(z_toy)) < n_toy - 2L)
  stop_s("S-F1", sprintf("rstudent toy length/finiteness: len=%d finite=%d expected=%d", length(z_toy), sum(is.finite(z_toy)), n_toy))
rs_toy_p <- tryCatch(rstudent(f_toy, reestimate = FALSE, parallel = "snow", ncpus = 2L),
                     error = function(e) stop_s("S-F1", paste("rstudent parallel API:", conditionMessage(e))))
z_toy_p <- rstudent_z(rs_toy_p)
if (length(z_toy_p) != n_toy || max(abs(z_toy_p - z_toy), na.rm = TRUE) > 1e-12)
  stop_s("S-F1", "rstudent parallel/serial identity violated on toy (tol 1e-12)")
h_toy <- hat_vec(f_toy)
if (length(h_toy) != n_toy) stop_s("S-F1", sprintf("hatvalues toy length %d != %d", length(h_toy), n_toy))
stopifnot(is.finite(mad(toy[[COL$zi]], constant = MAD_B)), mad(toy[[COL$zi]], constant = MAD_B) > 0)
q_toy <- quantile(toy[[COL$zi]], WINSOR_P, type = Q_TYPE, names = FALSE)
stopifnot(length(q_toy) == 2L, q_toy[1] < q_toy[2])
cat("Smoke [S-F1 probes] PASS (toy spine + rstudent serial/parallel identity + hatvalues/mad/quantile API)\n")

## ---- full-set spine fit + F1/F6 identification ----
f_full <- fit3l(dat); FITS <- FITS + 1L
if (inherits(f_full, "not_estimable")) stop_s("S5", paste("full-set spine not estimable -- genuine anomaly:", f_full$msg))
mu_full <- as.numeric(coef(f_full))[1]
vf <- as.numeric(vcov(f_full)[1, 1])              # model-based Var(mu_hat), Cook's D denominator [DEC-051 no. 8]
cat(sprintf("F1 rstudent pass started (parallel snow, ncpus=%d): %s\n", RS_NCPUS, format(Sys.time(), "%H:%M:%S")))
t_rs0 <- proc.time()[3]
rs_full <- rstudent(f_full, reestimate = FALSE, parallel = "snow", ncpus = RS_NCPUS)   # F1: ES-wise studentized deleted residuals, sigma2 fixed; route per DEC-051a
t_rs_min <- (proc.time()[3] - t_rs0) / 60
cat(sprintf("F1 rstudent pass done: %.1f min\n", t_rs_min))
t_rs <- rstudent_z(rs_full)
if (length(t_rs) != nrow(dat)) stop_s("S-F1", sprintf("rstudent full-set length %d != %d", length(t_rs), nrow(dat)))
n_rs_na <- sum(!is.finite(t_rs))
flag_rs <- is.finite(t_rs) & abs(t_rs) > RSTUDENT_THRESH
m_med <- median(zi); m_mad <- mad(zi, constant = MAD_B)      # F6: Leys MAD, once, full estimation set
if (!is.finite(m_mad) || m_mad <= 0) stop_s("S-F1", "MAD scale not finite-positive")
flag_mad <- abs(zi - m_med) > MAD_K * m_mad
n_both <- sum(flag_rs & flag_mad)
cat(sprintf("Identification: rstudent flags=%d (NA deleted-resid=%d) | MAD flags=%d | overlap=%d\n",
            sum(flag_rs), n_rs_na, sum(flag_mad), n_both))
hv <- hat_vec(f_full)                                        # F5 ES-level leverages (no refits)
if (length(hv) != nrow(dat)) stop_s("S-F1", sprintf("hatvalues full-set length %d != %d", length(hv), nrow(dat)))

## ---- F4: cluster leave-one-out (M1 timing probe, then parallel remainder) ----
loo_fit <- function(cl) {
  d <- dat[dat$cluster_id != cl, ]
  f <- fit3l(d)
  if (inherits(f, "not_estimable"))
    return(data.frame(cluster_id_dropped = cl, k_es = nrow(d), k_study = length(unique(d$study)),
      est_z = NA_real_, se_z = NA_real_, ci_lb_z = NA_real_, ci_ub_z = NA_real_, df = NA_real_,
      sigma2_1 = NA_real_, sigma2_2 = NA_real_, sigma2_3 = NA_real_, cooks_d_cluster = NA_real_,
      status = "not_estimable", note = f$msg, stringsAsFactors = FALSE))
  tt <- ct_int(f, d); est <- tt$beta[1]
  data.frame(cluster_id_dropped = cl, k_es = nrow(d), k_study = length(unique(d$study)),
    est_z = est, se_z = tt$SE[1],
    ci_lb_z = est - qt(.975, tt$df[1]) * tt$SE[1], ci_ub_z = est + qt(.975, tt$df[1]) * tt$SE[1],
    df = tt$df[1], sigma2_1 = f$sigma2[1], sigma2_2 = f$sigma2[2], sigma2_3 = f$sigma2[3],
    cooks_d_cluster = (mu_full - est)^2 / vf,
    status = "ok", note = "", stringsAsFactors = FALSE)
}
clusters <- sort(unique(dat$cluster_id))
if (FITS + length(clusters) + 4L > MAX_FITS)
  stop_s("S-BUDGET", sprintf("projected fits %d > %d", FITS + length(clusters) + 4L, MAX_FITS))
t0 <- proc.time()[3]; loo_first <- loo_fit(clusters[1]); t1 <- (proc.time()[3] - t0) / 60
FITS <- FITS + 1L
cat(sprintf("M1 first LOO fit: %.2f min | serial x114 projection %.1f min | parallel (W=%d) ~ %.1f min\n",
            t1, t1 * length(clusters), W_PSOCK, t1 * length(clusters) / W_PSOCK))
rest <- clusters[-1]
cl_par <- tryCatch(makeCluster(W_PSOCK), error = function(e) NULL)
if (!is.null(cl_par)) {
  invisible(clusterEvalQ(cl_par, suppressPackageStartupMessages({ library(metafor); library(clubSandwich) })))
  clusterExport(cl_par, c("dat", "COL", "LADDER", "stop_s", "fit3l", "ct_int", "mu_full", "vf", "loo_fit"))
  loo_list <- parLapply(cl_par, rest, loo_fit)
  stopCluster(cl_par); par_note <- sprintf("PSOCK W=%d", W_PSOCK)
} else { loo_list <- lapply(rest, loo_fit); par_note <- "serial fallback (PSOCK unavailable)" }
FITS <- FITS + length(rest)
loo <- rbind(loo_first, do.call(rbind, loo_list))
loo <- loo[order(loo$cluster_id_dropped), ]
if (nrow(loo) != DOM["cluster"]) stop_s("S-SCHEMA", sprintf("LOO rows %d != %d", nrow(loo), DOM["cluster"]))
n_ne <- sum(loo$status == "not_estimable")
if (n_ne > LOO_NE_MAX) stop_s("S-F4", sprintf("not_estimable LOO fits = %d > %d -- inspect before proceeding; no outputs written", n_ne, LOO_NE_MAX))
cat(sprintf("M2 LOO complete: 114 fits | not_estimable=%d | %s\n", n_ne, par_note))

## ---- 36-col header transplant + name-mapped writer [#27/#28] ----
hdr <- colnames(read.csv(HEADER_SRC, nrows = 1, check.names = FALSE))
if (length(hdr) != 36) stop_s("S-SCHEMA", sprintf("header source has %d cols, expected 36", length(hdr)))
pick <- function(sem, pats) { for (p in pats) { j <- grep(p, hdr, ignore.case = TRUE, value = TRUE)
  if (length(j) >= 1) return(j[1]) }; stop_s("S-SCHEMA", paste("no header match for", sem, "-- rebind FIELDMAP (fixzone); header:", paste(hdr, collapse = "|"))) }
FIELDMAP <- c(analysis_id = pick("analysis_id", c("^analysis_id$")), spec = pick("spec", c("^spec$")),
  subset = pick("subset", c("^subset$")), term = pick("term", c("^term$")),
  k_es = pick("k_es", c("^k_es$", "^n_es$", "^k$")), n_study = pick("n_study", c("study")),
  n_cluster = pick("n_cluster", c("cluster")), est_z = pick("est_z", c("^est_z$", "^b_z$", "^est$")),
  se_z = pick("se_z", c("^se_z$", "^se$")), ci_lb_z = pick("ci_lb_z", c("lb_z", "ci.lb", "ci_lb")),
  ci_ub_z = pick("ci_ub_z", c("ub_z", "ci.ub", "ci_ub")), df = pick("df", c("^df$", "^df_")),
  p = pick("p", c("^p$", "^pval", "p_value")), est_r = pick("est_r", c("est_r", "^r$")),
  ci_lb_r = pick("ci_lb_r", c("lb_r")), ci_ub_r = pick("ci_ub_r", c("ub_r")),
  estimable = pick("estimable", c("estimab", "^estimator$")), note = pick("note", c("^note$", "comment")))  # T7 header has no 'estimable'; estimability lives in 'estimator' (vocab incl. "not_estimable")
ROWS <- list()
addrow <- function(analysis_id, spec, subset, term, d = NULL, est = NA, se = NA, lb = NA, ub = NA,
                   df = NA, p = NA, level_scale = TRUE, estimable = TRUE, note = "") {
  r <- setNames(as.list(rep(NA, 36)), hdr)
  r[[FIELDMAP["analysis_id"]]] <- analysis_id; r[[FIELDMAP["spec"]]] <- spec
  r[[FIELDMAP["subset"]]] <- subset; r[[FIELDMAP["term"]]] <- term
  if (!is.null(d)) { r[[FIELDMAP["k_es"]]] <- nrow(d); r[[FIELDMAP["n_study"]]] <- length(unique(d$study))
    r[[FIELDMAP["n_cluster"]]] <- length(unique(d$cluster_id)) }
  r[[FIELDMAP["est_z"]]] <- est; r[[FIELDMAP["se_z"]]] <- se
  r[[FIELDMAP["ci_lb_z"]]] <- lb; r[[FIELDMAP["ci_ub_z"]]] <- ub
  r[[FIELDMAP["df"]]] <- df; r[[FIELDMAP["p"]]] <- p
  if (level_scale && is.finite(est)) { r[[FIELDMAP["est_r"]]] <- tanh(est)
    if (is.finite(lb)) r[[FIELDMAP["ci_lb_r"]]] <- tanh(lb)
    if (is.finite(ub)) r[[FIELDMAP["ci_ub_r"]]] <- tanh(ub) }   # diff rows: z-only, never tanh (none emitted in TF)
  r[[FIELDMAP["estimable"]]] <- estimable; r[[FIELDMAP["note"]]] <- note
  ROWS[[length(ROWS) + 1]] <<- r
}
int_row <- function(id, spec, d, note = "", zi_override = NULL) {
  dd <- d
  if (!is.null(zi_override)) dd[[COL$zi]] <- zi_override
  f <- fit3l(dd); FITS <<- FITS + 1L
  if (inherits(f, "not_estimable")) { addrow(id, spec, "estimation", "intrcpt", dd, estimable = FALSE, note = f$msg); return(invisible()) }
  tt <- ct_int(f, dd)
  addrow(id, spec, "estimation", "intrcpt", dd, est = tt$beta[1], se = tt$SE[1],
         lb = tt$beta[1] - qt(.975, tt$df[1]) * tt$SE[1], ub = tt$beta[1] + qt(.975, tt$df[1]) * tt$SE[1],
         df = tt$df[1], p = tt$p_Satt[1], note = note)
}

## ---- F2/F3/F7 variant refits (spine verbatim on treated data) ----
int_row("F2", "outlier_rstudent", dat[!flag_rs, ],
        sprintf("drop %d ES with |rstudent(reestimate=FALSE)| > %d [DEC-051]; overlap with MAD set = %d; N5/H3 mask relation disclosed descriptively", sum(flag_rs), RSTUDENT_THRESH, n_both))
int_row("F2", "outlier_mad", dat[!flag_mad, ],
        sprintf("drop %d ES outside median +/- %d*MAD (b=%.4f, zi, full estimation set) [Leys 2013; DEC-051]; overlap with rstudent set = %d", sum(flag_mad), MAD_K, MAD_B, n_both))
qz <- quantile(zi, WINSOR_P, type = Q_TYPE, names = FALSE)
zi_w <- pmin(pmax(zi, qz[1]), qz[2]); n_wz <- sum(zi < qz[1] | zi > qz[2])
int_row("F3", "winsor", dat, zi_override = zi_w,
        note = sprintf("zi winsorized at empirical P1/P99 of the full estimation set (A.13/H3 pin; type-%d quantile); %d ES clipped; unwinsor == headline (DEC-013(a) status-quo semantics; cross-reference, no fit)", Q_TYPE, n_wz))
keep_tr <- zi >= qz[1] & zi <= qz[2]; n_tr <- sum(!keep_tr)
int_row("F7", "trim_1_99", dat[keep_tr, ],
        sprintf("drop %d ES with zi outside [P1, P99] (same percentiles as winsor) [DEC-051]", n_tr))
cat("M3 variant refits done (outlier_rstudent, outlier_mad, winsor, trim_1_99)\n")
cat("M4 influence diagnostics done (cluster Cook's D in TF_loo; ES hatvalues in TF_influence)\n")

## ---- assemble + budget + write outputs (single terminal write block) ----
res <- do.call(rbind, lapply(ROWS, function(r) as.data.frame(r, check.names = FALSE)))
colnames(res) <- hdr
if (nrow(res) > MAX_ROWS) stop_s("S-BUDGET", sprintf("%d rows > %d budget", nrow(res), MAX_ROWS))
if (FITS > MAX_FITS) stop_s("S-BUDGET", sprintf("%d model fits > %d budget", FITS, MAX_FITS))
infl <- data.frame(cluster_id = dat$cluster_id, study = dat$study, esid = dat$esid,
                   zi = zi, vi = vi, rstudent_t = t_rs, flag_rstudent = flag_rs,
                   mad_center = m_med, mad_scale = m_mad, flag_mad = flag_mad,
                   flag_both = flag_rs & flag_mad, hatvalue = hv, stringsAsFactors = FALSE)
if (nrow(infl) != DOM["es"]) stop_s("S-SCHEMA", sprintf("influence rows %d != %d", nrow(infl), DOM["es"]))
dir.create("output", showWarnings = FALSE)
write.csv(res,  "output/TF_results.csv",   row.names = FALSE)
write.csv(loo,  "output/TF_loo.csv",       row.names = FALSE)
write.csv(infl, "output/TF_influence.csv", row.names = FALSE)
meta <- list(run = "TF", dec = "DEC-051", date = as.character(Sys.time()), seed = 20260710,
             dat_md5 = MD5_PIN, dom = as.list(DOM),
             thresholds = list(rstudent = RSTUDENT_THRESH, mad_k = MAD_K, mad_b = MAD_B,
                               winsor_p = WINSOR_P, quantile_type = Q_TYPE),
             winsor_q = as.numeric(qz),
             flags = list(rstudent = sum(flag_rs), rstudent_na = n_rs_na, mad = sum(flag_mad),
                          overlap = n_both, winsorized = n_wz, trimmed = n_tr),
             rstudent_route = list(parallel = "snow", ncpus = RS_NCPUS, pass_min = round(t_rs_min, 2)),
             loo = list(n = nrow(loo), n_ne = n_ne, parallel = par_note,
                        first_fit_min = round(t1, 3)),
             fits = list(total = FITS, gateA = 1, smoke = 1, spine_full = 1,
                         variants = 4, loo = length(clusters)),
             n_rows_results = nrow(res))
writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), "output/TF_run_meta.json")
writeLines(capture.output(sessionInfo()), "output/TF_sessionInfo.txt")
cat(sprintf("M5 outputs written: TF_results (%d rows) | TF_loo (114) | TF_influence (2713)\n", nrow(res)))
cat(sprintf("TF run complete: %d result rows -> output/TF_results.csv | %d model fits\n", nrow(res), FITS))
