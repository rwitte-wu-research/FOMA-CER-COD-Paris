# R/11_robustness.R -- TG run: robustness register block G (G1-G10) [DEC-050]
# Spine verbatim: random ~1|cluster_id/study/esid; V blocks within cluster_id, rho=0.6;
# CR2/Satterthwaite on cluster_id [D31.1/A.2]. Seed 20260710. Budget <= 60 rows, <= 14 fits.
suppressPackageStartupMessages({ library(metafor); library(clubSandwich) })
set.seed(20260710)

## ---------------- FIXZONE (CC may edit ONLY this block: paths + column binds) ----------------
DAT_CANDIDATES <- c("output/dat_prep.rds", "data/dat_prep.rds")  # .RDS variant removed: case-insensitive NTFS made it a duplicate hit of candidate 1 (S-A length==2)
MD5_PIN <- "6702ef3dc45fe0b693b13f50ebd1576b"
COL <- list(zi = "zi", vi = "vi", n_obs = "n_eff", n_firms = "n_firms",  # n_obs -> n_eff rebind: raw n_obs is character with FLAG/NA; n_eff is the numeric proxy-filled n (adj identity holds on 2713/2713)
            es_method = "es_method", es_measure = "ES_measure",
            q_vhb = "q_VHB", field = "field",
            proxyfill = "flag_proxy_n")  # fixed bind [DEC-050a]: estimation set = 296 (pin 297 was the usable basis incl. 134 FLAG-based)
HEADER_SRC <- "output/T7_results.csv"    # 36-column schema transplant [DEC-048]
## ---------------------------------------------------------------------------------------------

TOL_T <- 1e-9; TOL_L <- 1e-6
F65 <- list(est = -0.0616608386540629, se = 0.0243306602731784, df = 113,
            p = 0.0126367644358383, lb = -0.109864264918875, ub = -0.0134574123892513)
DOM <- c(es = 2713L, study = 115L, cluster = 114L)
stop_s <- function(code, msg) stop(sprintf("[%s] %s", code, msg), call. = FALSE)

## ---- M0: bind + inventory (hard asserts; auto-continue on PASS) ----
hit <- DAT_CANDIDATES[file.exists(DAT_CANDIDATES)]
hit <- hit[vapply(hit, function(p) unname(tools::md5sum(p)) == MD5_PIN, logical(1))]
if (length(hit) != 1) stop_s("S-A", "dat_prep not found by md5 pin; extend DAT_CANDIDATES (fixzone)")
dat <- readRDS(hit[1])
if (!is.data.frame(dat)) dat <- dat$dat   # accessor fix: dat_prep.rds is a container list(dat, built, seed, n, sessionInfo)
dat <- as.data.frame(dat)
cat("M0 dat_prep:", hit[1], "| md5 OK |", nrow(dat), "rows\n")
cat("M0 colnames:", paste(colnames(dat), collapse = " | "), "\n")
need <- c(unlist(COL[!is.na(COL)]), "cluster_id", "study", "esid")
miss <- setdiff(need, colnames(dat))
if (length(miss)) stop_s("S-A", paste("missing columns (rebind in fixzone):", paste(miss, collapse = ", ")))
stopifnot(nrow(dat) == DOM["es"],
          length(unique(dat$study)) == DOM["study"],
          length(unique(dat$cluster_id)) == DOM["cluster"])
zi <- dat[[COL$zi]]; vi <- dat[[COL$vi]]

n_sb <- sum(dat[[COL$es_method]] == "star-bound")
if (n_sb != 99L) stop_s("S-G1", sprintf("star-bound rows = %d, expected 99", n_sb))
pf <- dat[[COL$proxyfill]]; pf <- if (is.logical(pf)) pf else pf %in% c(1, "1", TRUE, "TRUE", "yes")
if (sum(pf) != 296L) stop_s("S-G2", sprintf("proxy-fill rows = %d, expected 296", sum(pf)))
cat("M0 proxyfill column:", COL$proxyfill, "| 296 OK\n")
adj <- dat[[COL$n_obs]] - 1 / vi
adj_int_share <- mean(abs(adj - round(adj)) < 1e-6)
cat(sprintf("M0 adj-recovery integer share: %.4f\n", adj_int_share))
if (adj_int_share < 0.99) stop_s("S-G3", "adjustment recovery n_obs - 1/vi not integer-valued for >=99% of rows; escalate, do not approximate")
cat("M0 PASS\n")

## ---- Gate A: F65 pre-flight aggregate identity [DEC-048] ----
es <- escalc(measure = "GEN", yi = dat[[COL$zi]], vi = dat[[COL$vi]], data = dat)
agg <- aggregate(es, cluster = cluster_id, struct = "CS", rho = 0.6)
gA <- rma.uni(yi, vi, data = agg, method = "REML", test = "knha")
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

## ---- row collector: 36-col header transplant + name-mapped writer [#27/#28] ----
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
    if (is.finite(ub)) r[[FIELDMAP["ci_ub_r"]]] <- tanh(ub) }   # diff/HTZ rows: z-only, never tanh
  r[[FIELDMAP["estimable"]]] <- estimable; r[[FIELDMAP["note"]]] <- note
  ROWS[[length(ROWS) + 1]] <<- r
}
int_row <- function(id, spec, d, note = "", vi_override = NULL, engine3l = TRUE) {
  if (engine3l) { f <- fit3l(d, vi_override = vi_override)
    if (inherits(f, "not_estimable")) { addrow(id, spec, "estimation", "intrcpt", d, estimable = FALSE, note = f$msg); return(invisible()) }
    tt <- ct_int(f, d)
    addrow(id, spec, "estimation", "intrcpt", d, est = tt$beta[1], se = tt$SE[1],
           lb = tt$beta[1] - qt(.975, tt$df[1]) * tt$SE[1], ub = tt$beta[1] + qt(.975, tt$df[1]) * tt$SE[1],
           df = tt$df[1], p = tt$p_Satt[1], note = note)
  }
}

## ---- G1-G5 spine variants ----
int_row("G1", "no_starbound",      dat[dat[[COL$es_method]] != "star-bound", ], "drop es_method==star-bound (99 ES / 11 studies)")
int_row("G2", "no_nobs_proxyfill", dat[!pf, ], "drop flag_proxy_n==TRUE (296 rows; 297 on the usable basis incl. 134 FLAG-based, one tagged duplicate exits at the estimation filter; R-19)")
nf <- dat[[COL$n_firms]]; ok3 <- is.finite(nf) & (nf - adj > 0) & (abs(adj - round(adj)) < 1e-6)
d3 <- dat[ok3, ]; vi3 <- 1 / (d3[[COL$n_firms]] - (d3[[COL$n_obs]] - 1 / d3[[COL$vi]]))
int_row("G3", "n_firms_variance", d3, sprintf("vi rebuilt on n_firms via adjustment recovery; %d rows dropped (missing/invalid n_firms)", nrow(dat) - nrow(d3)), vi_override = vi3)
int_row("G4", "direct_r_only", dat[dat[[COL$es_method]] == "bivariate", ], "es_method==bivariate; near-identical to G9 bivariate cell (delta 2 ES / 1 study)")
ppc <- dat[[COL$es_measure]] == "partial"
for (kk in c(10, 20)) { vk <- ifelse(ppc, 1 / (dat[[COL$n_obs]] - kk - 3), dat[[COL$vi]])
  keep <- is.finite(vk) & vk > 0
  int_row("G5", sprintf("pcc_df_k%d", kk), dat[keep, ], sprintf("PCC vi = 1/(n-%d-3); bivariate rows unchanged; %d rows dropped (nonpositive vi)", kk, sum(!keep)), vi_override = vk[keep]) }

## ---- G6 median aggregation (off-spine by design) ----
med <- do.call(rbind, lapply(split(dat, dat$cluster_id), function(g) {
  g <- g[order(g[[COL$zi]]), ]; n <- nrow(g)
  if (n %% 2 == 1) { i <- (n + 1) / 2; data.frame(yi = g[[COL$zi]][i], vi = g[[COL$vi]][i]) }
  else { i <- n / 2; data.frame(yi = median(g[[COL$zi]]), vi = mean(g[[COL$vi]][c(i, i + 1)])) } }))
g6 <- rma.uni(yi, vi, data = med, method = "REML", test = "knha")
addrow("G6", "one_per_cluster_median", "aggregate", "intrcpt", NULL, est = unname(g6$beta[1]), se = g6$se,
       lb = g6$ci.lb, ub = g6$ci.ub, df = g6$dfs, p = g6$pval,
       note = sprintf("114 cluster medians; vi of median-carrying row (even: mean of two middle); k=%d", nrow(med)))

## ---- G7-G10 cell-means panels (level-only, descriptive per DEC-047; no Holm) ----
panel <- function(id, spec, var, feature_note = "") {
  d <- dat; d$fct <- factor(d[[var]]); lev <- levels(d$fct)
  f <- fit3l(d, mods = ~ 0 + fct)
  if (inherits(f, "not_estimable")) { addrow(id, spec, "panel", "HTZ", d, estimable = FALSE, note = f$msg); return(invisible()) }
  tt <- ct_int(f, d)
  for (i in seq_along(lev)) { di <- d[d$fct == lev[i], ]
    addrow(id, spec, lev[i], "cell_mean", di, est = tt$beta[i], se = tt$SE[i],
           lb = tt$beta[i] - qt(.975, tt$df[i]) * tt$SE[i], ub = tt$beta[i] + qt(.975, tt$df[i]) * tt$SE[i],
           df = tt$df[i], p = tt$p_Satt[i], note = feature_note) }
  if (length(lev) > 1) {
    ht <- clubSandwich::Wald_test(f, constraints = constrain_equal(seq_along(lev)),
                                  vcov = "CR2", cluster = d$cluster_id, test = "HTZ")
    addrow(id, spec, "panel", "HTZ_omnibus", d, est = NA, se = NA, df = ht$df_denom, p = ht$p_val,
           level_scale = FALSE, note = sprintf("F=%.4f, df_num=%.1f; descriptive [DEC-047]", ht$Fstat, ht$df_num))
    pw <- clubSandwich::Wald_test(f, constraints = constrain_pairwise(seq_along(lev)),
                                  vcov = "CR2", cluster = d$cluster_id, test = "HTZ")
    cmb <- combn(seq_along(lev), 2)
    for (j in seq_len(ncol(cmb))) { a <- cmb[1, j]; b <- cmb[2, j]; w <- pw[[j]]
      addrow(id, spec, paste(lev[a], "vs", lev[b]), "pairwise_contrast", NULL,
             est = unname(coef(f)[a] - coef(f)[b]), se = abs(unname(coef(f)[a] - coef(f)[b])) / sqrt(max(w$Fstat, 1e-12)),
             df = w$df_denom, p = w$p_val, level_scale = FALSE,
             note = "CR2/Satterthwaite (HTZ 1-df); z-scale only; descriptive [DEC-047]") } }
}
panel("G7", "panel_q_vhb", COL$q_vhb, "NCE cell retained per D31.4; text feature = high vs low; publication-status inference single-homed in D5")
panel("G8", "panel_field", COL$field)
panel("G9", "panel_es_measure", COL$es_measure, "featured axis (van Aert partial vs bivariate)")
panel("G10", "panel_es_method", COL$es_method, "main-effect-only per Annex C (method artifact)")

## ---- write outputs + budget ----
res <- do.call(rbind, lapply(ROWS, function(r) as.data.frame(r, check.names = FALSE)))
colnames(res) <- hdr
if (nrow(res) > 60) stop_s("S-BUDGET", sprintf("%d rows > 60 budget", nrow(res)))
dir.create("output", showWarnings = FALSE)
write.csv(res, "output/TG_results.csv", row.names = FALSE)
meta <- list(run = "TG", dec = "DEC-050", date = as.character(Sys.time()), seed = 20260710,
             dat_md5 = MD5_PIN, proxyfill_col = COL$proxyfill, n_rows = nrow(res),
             dom = as.list(DOM), adj_int_share = adj_int_share, g3_dropped = nrow(dat) - nrow(d3))
writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), "output/TG_run_meta.json")
writeLines(capture.output(sessionInfo()), "output/TG_sessionInfo.txt")
cat(sprintf("TG run complete: %d result rows -> output/TG_results.csv\n", nrow(res)))
