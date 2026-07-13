# =============================================================================
# R/01_verify_outputs.R -- paired verifier for R/01_core.R (T1, Block A)
# Checks O1-O21, numbered PASS/FAIL; exit status 1 on any FAIL.
# ORACLE INDEPENDENCE: this script does NOT source 01_core.R. Constants below
# are intentionally duplicated. dat_prep schema is BINDING (author ruling
# 2026-07-12, R/00_prep.R list contract: pr$dat / pr$n / pr$seed).
# Convention: verifier = oracle for the Claude-Code run [Setup tab; Addendum A.7].
# =============================================================================

# ---- duplicated config (keep in sync with 01_core.R) ---------------------------
PATH_DAT_PREP <- here::here("output", "dat_prep.rds")
DIR_OUT <- here::here("output"); DIR_FIG <- file.path(DIR_OUT, "figures")
REQUIRED_COLS <- c("zi", "vi", "cluster_id", "study", "esid",
                   "pp_mid_lag0", "n_eff")   # binding schema
K_ES <- 2713L; K_STUDY <- 115L; K_CLUSTER <- 114L; K_STUDY_POST <- 31L
RHO_SET <- c(0.6, 0.4, 0.8)
SD_COD_BP_GRID <- c(100, 150, 200); SMALL_BENCH_R <- 0.07

RES_PATH  <- file.path(DIR_OUT, "T1_results.csv")
META_PATH <- file.path(DIR_OUT, "T1_run_meta.txt")
FIGS <- c(file.path(DIR_FIG, "T1_A7_caterpillar_cluster.pdf"),
          file.path(DIR_FIG, "T1_A7_caterpillar_cluster.png"),
          file.path(DIR_FIG, "T1_A8_forest_study.pdf"))

SCHEMA <- c("analysis_id", "spec", "subset", "metric", "estimator", "rho",
            "k_es", "k_study", "k_cluster",
            "est_z", "se_z", "t_stat", "df", "p",
            "ci_lb_z", "ci_ub_z", "pi_lb_z", "pi_ub_z",
            "est_r", "ci_lb_r", "ci_ub_r", "pi_lb_r", "pi_ub_r",
            "sigma2_cluster", "sigma2_study", "sigma2_esid",
            "pct_cluster", "pct_study", "pct_esid", "pct_sampling", "typical_v",
            "value", "ms_input", "ms_label", "note")

EXPECTED_SPECS <- rbind(
  c("A1", "headline"), c("A2", "var_decomposition"),
  c("A3", "pi_overall"), c("A3", "pi_pre"), c("A3", "pi_post"),
  c("A4", "rho_0.4"), c("A4", "rho_0.8"),
  c("A5", "one_effect_per_cluster"), c("A5", "uwls3"),
  c("A5", "hs_es_level"), c("A5", "waap_uwls"),
  c("A6", "bp_per_1sd_sd100"), c("A6", "bp_per_1sd_sd150"),
  c("A6", "bp_per_1sd_sd200"), c("A6", "small_benchmark_ratio"))

# ---- harness -------------------------------------------------------------------
results <- character(0); n_fail <- 0L
check <- function(id, ok, desc, detail = "") {
  status <- if (isTRUE(ok)) "PASS" else "FAIL"
  if (!isTRUE(ok)) n_fail <<- n_fail + 1L
  line <- sprintf("%-4s %s -- %s%s", id, status, desc,
                  if (nzchar(detail)) paste0(" [", detail, "]") else "")
  results[[length(results) + 1L]] <<- line
  cat(line, "\n")
}
near <- function(a, b, tol) all(is.finite(a) & is.finite(b)) && all(abs(a - b) <= tol)

# ---- O1 files ------------------------------------------------------------------
paths <- c(RES_PATH, META_PATH, FIGS)
check("O1", all(file.exists(paths)), "all output files exist",
      paste(basename(paths)[!file.exists(paths)], collapse = ", "))
if (!file.exists(RES_PATH)) { cat("ABORT: results CSV missing.\n"); quit(status = 1L) }

res <- read.csv(RES_PATH, stringsAsFactors = FALSE)

# ---- O2 schema -----------------------------------------------------------------
check("O2", identical(names(res), SCHEMA), "CSV schema exact (names + order)",
      paste(setdiff(SCHEMA, names(res)), collapse = ", "))

# ---- O3 spec inventory ----------------------------------------------------------
got <- paste(res$analysis_id, res$spec, sep = "::")
exp <- paste(EXPECTED_SPECS[, 1], EXPECTED_SPECS[, 2], sep = "::")
check("O3", identical(sort(got), sort(exp)) && !anyDuplicated(got),
      sprintf("spec inventory complete (%d rows), no duplicates", length(exp)),
      paste(c(setdiff(exp, got), setdiff(got, exp)), collapse = ", "))

row_of <- function(aid, sp) res[res$analysis_id == aid & res$spec == sp, , drop = FALSE]
hl <- row_of("A1", "headline")

# ---- O4 headline / full-set k --------------------------------------------------
full3l <- res[res$subset == "all" & res$estimator %in%
                c("3LMA-RVE_CR2", "3LMA-RVE_REML"), ]
check("O4", nrow(hl) == 1 &&
        hl$k_es == K_ES && hl$k_study == K_STUDY && hl$k_cluster == K_CLUSTER &&
        all(full3l$k_es == K_ES & full3l$k_study == K_STUDY &
              full3l$k_cluster == K_CLUSTER),
      "k identities on full-set 3LMA rows (2713/115/114) [DEC-042a]")

# ---- O5 period cells ------------------------------------------------------------
pre <- row_of("A3", "pi_pre"); post <- row_of("A3", "pi_post")
check("O5", nrow(pre) == 1 && nrow(post) == 1 &&
        (pre$k_es + post$k_es) == K_ES &&
        post$k_study == K_STUDY_POST &&
        pre$k_study >= 1 && pre$k_study <= K_STUDY &&
        post$k_cluster >= 1,
      "period cells: k_es(pre)+k_es(post)=2713; post studies = 31 [Addendum A.3]",
      sprintf("pre %s/%s, post %s/%s", pre$k_es, pre$k_study, post$k_es, post$k_study))

# ---- O6 est within CI ------------------------------------------------------------
zrows <- res[!is.na(res$est_z) & !is.na(res$ci_lb_z) & !is.na(res$ci_ub_z), ]
rrows <- res[!is.na(res$est_r) & !is.na(res$ci_lb_r) & !is.na(res$ci_ub_r), ]
check("O6", all(zrows$ci_lb_z < zrows$est_z & zrows$est_z < zrows$ci_ub_z) &&
        all(rrows$ci_lb_r < rrows$est_r & rrows$est_r < rrows$ci_ub_r),
      "estimate strictly inside its CI (z and r scales), all applicable rows")

# ---- O7 PI wider than CI ----------------------------------------------------------
pirows <- res[!is.na(res$pi_lb_z) & !is.na(res$ci_lb_z), ]
check("O7", all(pirows$pi_lb_z <= pirows$ci_lb_z & pirows$pi_ub_z >= pirows$ci_ub_z),
      "PI encloses CI wherever both present (F55 construction)")

# ---- O8 variance decomposition ------------------------------------------------------
a2 <- row_of("A2", "var_decomposition")
pct_sum <- a2$pct_cluster + a2$pct_study + a2$pct_esid + a2$pct_sampling
check("O8", nrow(a2) == 1 &&
        all(c(a2$sigma2_cluster, a2$sigma2_study, a2$sigma2_esid) >= 0) &&
        near(pct_sum, 1, 1e-8) && a2$typical_v > 0,
      "A2: sigma2 >= 0; pct shares sum to 1; typical_v > 0",
      sprintf("pct_sum = %.10f", pct_sum))

# ---- O9 rho grid ---------------------------------------------------------------------
rhos <- sort(res$rho[res$analysis_id %in% c("A1", "A4")])
check("O9", identical(rhos, sort(RHO_SET)), "rho set on A1+A4 = {0.4, 0.6, 0.8}",
      paste(rhos, collapse = ", "))

# ---- O10 tanh consistency --------------------------------------------------------------
both <- res[!is.na(res$est_z) & !is.na(res$est_r), ]
ok10 <- near(both$est_r, tanh(both$est_z), 1e-10)
cib  <- res[!is.na(res$ci_lb_z) & !is.na(res$ci_lb_r), ]
ok10b <- near(cib$ci_lb_r, tanh(cib$ci_lb_z), 1e-10) &&
         near(cib$ci_ub_r, tanh(cib$ci_ub_z), 1e-10)
check("O10", ok10 && ok10b, "r == tanh(z) identity on estimates and CI endpoints")

# ---- reload dat_prep for recomputation checks (O21 emitted at the end) ------------------
pr_ok <- FALSE
if (file.exists(PATH_DAT_PREP)) {
  pr <- readRDS(PATH_DAT_PREP)
  pr_ok <- is.list(pr) && !is.null(pr$dat) &&
           identical(as.integer(pr$n), K_ES) &&
           identical(as.integer(pr$seed), 20260710L) &&
           all(REQUIRED_COLS %in% names(pr$dat))
}
if (pr_ok) {
  dr <- pr$dat
  d  <- data.frame(yi = as.numeric(dr$zi), vi = as.numeric(dr$vi),
                   cluster = factor(dr$cluster_id), study = factor(dr$study),
                   period = as.integer(as.character(dr$pp_mid_lag0)),
                   n_eff = as.numeric(dr$n_eff))
}

if (pr_ok) {
  r_h <- tanh(d$yi)
  t_i <- r_h * sqrt(d$n_eff) / sqrt(1 - r_h^2)
  rp3 <- t_i / sqrt(t_i^2 + d$n_eff + 3)
  v3  <- (1 - rp3^2) / (d$n_eff + 3)
  w3  <- 1 / v3

  # ---- O11 UWLS+3 identity ----
  u3_ref <- sum(w3 * rp3) / sum(w3)
  u3_row <- row_of("A5", "uwls3")
  check("O11", nrow(u3_row) == 1 && near(u3_row$est_r, u3_ref, 1e-8),
        "UWLS+3 point estimate == independent weighted-mean recomputation",
        sprintf("ref %.10f vs csv %.10f", u3_ref, u3_row$est_r))

  # ---- O12 HS identity ----
  rbar_ref <- sum(d$n_eff * r_h) / sum(d$n_eff)
  se_ref   <- sqrt(sum(d$n_eff * (r_h - rbar_ref)^2) / sum(d$n_eff) / length(r_h))
  hs_row <- row_of("A5", "hs_es_level")
  ok12 <- nrow(hs_row) == 1 && near(hs_row$est_r, rbar_ref, 1e-10) &&
          near(hs_row$ci_ub_r - hs_row$est_r, 1.96 * se_ref, 1e-8)
  check("O12", ok12, "HS bare-bones estimate + CI half-width recomputation")

  # ---- O14 WAAP logic ----
  n_pow_ref <- sum(sqrt(v3) <= abs(u3_ref) / 2.8)
  wa <- row_of("A5", "waap_uwls")
  if (n_pow_ref >= 2L) {
    ok14 <- nrow(wa) == 1 && wa$k_es == n_pow_ref
    det14 <- sprintf("powered = %d; csv k_es = %s", n_pow_ref, wa$k_es)
  } else {
    ok14 <- nrow(wa) == 1 && grepl("reduces to UWLS", wa$note, fixed = TRUE) &&
            near(wa$est_r, u3_row$est_r, 1e-10)
    det14 <- sprintf("powered = %d -> fallback path", n_pow_ref)
  }
  check("O14", ok14, "WAAP: powered-count / fallback consistency vs recomputation", det14)
} else {
  check("O11", FALSE, "UWLS+3 recomputation (dat_prep contract unavailable)")
  check("O12", FALSE, "HS recomputation (dat_prep contract unavailable)")
  check("O14", FALSE, "WAAP recomputation (dat_prep contract unavailable)")
}

# ---- O13 one-effect-per-cluster ------------------------------------------------------
opc <- row_of("A5", "one_effect_per_cluster")
check("O13", nrow(opc) == 1 && opc$k_es == K_CLUSTER && opc$k_cluster == K_CLUSTER,
      "one_effect_per_cluster: k_es == k_cluster == 114")

# ---- O15 A6 translation identities ----------------------------------------------------
ok15 <- TRUE; det15 <- ""
for (sd_bp in SD_COD_BP_GRID) {
  rw <- row_of("A6", sprintf("bp_per_1sd_sd%d", sd_bp))
  if (nrow(rw) != 1 || !near(rw$value, hl$est_r * sd_bp, 1e-10)) {
    ok15 <- FALSE; det15 <- paste0(det15, "sd", sd_bp, " ") }
  if (nrow(rw) == 1 && !grepl("PENDING DEC-012a", rw$note, fixed = TRUE)) {
    ok15 <- FALSE; det15 <- paste0(det15, "DEC-012a-flag-missing ") }
}
bench <- row_of("A6", "small_benchmark_ratio")
if (nrow(bench) != 1 || !near(bench$value, hl$est_r / SMALL_BENCH_R, 1e-10)) ok15 <- FALSE
check("O15", ok15, "A6: bp rows == est_r * SD grid; DEC-012a flag present; benchmark ratio",
      det15)

# ---- O16 figures nonzero / PDF headers -------------------------------------------------
ok16 <- all(file.exists(FIGS)) && all(file.info(FIGS)$size > 5000)
for (f in FIGS[grepl("\\.pdf$", FIGS)]) {
  if (file.exists(f)) {
    hdr <- readBin(f, "raw", n = 4L)
    if (!identical(rawToChar(hdr), "%PDF")) ok16 <- FALSE
  }
}
check("O16", ok16, "figures exist, > 5 KB, PDFs carry %PDF header")

# ---- O17 run meta ----------------------------------------------------------------------
if (file.exists(META_PATH)) {
  meta <- readLines(META_PATH, warn = FALSE)
  ok17 <- any(grepl("md5", meta)) && any(grepl("sessionInfo", meta)) &&
          any(grepl("metafor", meta)) && any(grepl("clubSandwich", meta))
} else ok17 <- FALSE
check("O17", ok17, "run meta: dat_prep md5 + sessionInfo + package stamp present")

# ---- O18 Satterthwaite df floor --------------------------------------------------------
dfr <- res$df[!is.na(res$df) & res$estimator != "RE_REML_KnHa"]
check("O18", all(dfr >= 4), "CR2 Satterthwaite df >= 4 on all robust-inference rows",
      sprintf("min df = %.2f", suppressWarnings(min(dfr))))

# ---- O19 completeness -------------------------------------------------------------------
core3l <- res[res$estimator == "3LMA-RVE_CR2", ]
est_rows <- res[res$analysis_id != "A2", ]   # A2 = decomposition row, carries no estimate
check("O19", !anyNA(est_rows$est_r) &&
        !anyNA(core3l$est_z) && !anyNA(core3l$se_z) &&
        !anyNA(core3l$ci_lb_z) && !anyNA(core3l$ci_ub_z),
      "no NA in est_r on estimate rows; 3LMA rows complete (est/se/CI on z scale)")

# ---- O20 A3-overall == A1 identity -------------------------------------------------------
a3o <- row_of("A3", "pi_overall")
check("O20", nrow(a3o) == 1 &&
        near(a3o$est_z, hl$est_z, 1e-12) &&
        near(a3o$pi_lb_z, hl$pi_lb_z, 1e-12) &&
        near(a3o$pi_ub_z, hl$pi_ub_z, 1e-12),
      "A3 pi_overall row identical to A1 fit (est + PI bounds)")

# ---- O21 dat_prep re-assert ----------------------------------------------------------------
check("O21", pr_ok && nrow(d) == K_ES &&
        nlevels(droplevels(d$study)) == K_STUDY &&
        nlevels(droplevels(d$cluster)) == K_CLUSTER &&
        all(d$period %in% c(0L, 1L)),
      "dat_prep list contract (pr$n=2713, pr$seed=20260710, schema) + 2713/115/114; period binary")

# ---- summary ------------------------------------------------------------------------------
cat("\n============================================================\n")
cat(sprintf("T1 VERIFY: %d/%d PASS%s\n", length(results) - n_fail, length(results),
            if (n_fail) sprintf(" -- %d FAIL", n_fail) else ""))
cat("============================================================\n")
if (n_fail > 0L) quit(status = 1L)
