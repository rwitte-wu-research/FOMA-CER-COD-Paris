# =============================================================================
# R/19_verify_outputs.R -- paired verifier for R/19_figures_p6.R (S1-P6)
# Independently re-reads committed sources; asserts files, numeric identity,
# structure. Run immediately after R/19; PASS required before staging.
# =============================================================================
v_ok   <- function(fmt, ...) message(sprintf(paste0("PASS  ", fmt), ...))
v_fail <- function(fmt, ...) stop(sprintf(paste0("FAIL  ", fmt), ...), call. = FALSE)
source(here::here("setup.R"))

# V1 -- files present, non-empty ------------------------------------------------
figs <- file.path(here::here("output", "figures"),
  c("T1_A7_caterpillar_cluster.pdf", "T1_A7_caterpillar_cluster.png",
    "T1_A8_forest_study.pdf", "T1_A8_forest_study.png"))
meta_p <- here::here("output", "fig_run_meta_p6.txt")
for (f in c(figs, meta_p)) if (!file.exists(f) || file.size(f) == 0L)
  v_fail("V1: missing/empty %s", basename(f))
v_ok("V1: 4 figure files + fig_run_meta_p6.txt present, non-empty")

# V2 -- structure re-derivation (committed prep on v12.1) -----------------------
source(here::here("R", "00_prep.R"))
es <- d[est, , drop = FALSE]
if (nrow(es) != 2713L)                                v_fail("V2: ES != 2713")
if (dplyr::n_distinct(es$study) != 115L)              v_fail("V2: studies != 115")
if (dplyr::n_distinct(es$cluster_id) != 113L)         v_fail("V2: clusters != 113")
v_ok("V2: estimation set 2,713 / 115 / 113 (v12.1)")

# V3 -- A7/A8 numeric identity --------------------------------------------------
es <- dplyr::mutate(es, zi = as.numeric(d_fisher_z),
                        vi = 1 / (as.numeric(n_eff) - 3))
agg_rho <- function(dd, unit_col, rho) {
  esc <- metafor::escalc(measure = "GEN", yi = dd$yi, vi = dd$vi,
                         data = data.frame(agg_unit = dd[[unit_col]]))
  ag  <- aggregate(esc, cluster = agg_unit, rho = rho)
  data.frame(unit = ag$agg_unit, yi = as.numeric(ag$yi), vi = as.numeric(ag$vi))
}
agc <- agg_rho(data.frame(yi = es$zi, vi = es$vi, cluster = es$cluster_id), "cluster", 0.6)
ags <- agg_rho(data.frame(yi = es$zi, vi = es$vi, study   = es$study),      "study",   0.6)
if (nrow(agc) != 113L) v_fail("V3: cluster aggregates != 113")
if (nrow(ags) != 115L) v_fail("V3: study aggregates != 115")
t1  <- readr::read_csv(here::here("output", "T1_results.csv"), show_col_types = FALSE)
pio <- t1[t1$analysis_id == "A3" & t1$spec == "pi_overall", , drop = FALSE]
reg <- readr::read_csv(here::here("output", "robustness_register.csv"), show_col_types = FALSE)
hz  <- reg$est_z[reg$spec == "headline_v12_1"]
if (nrow(pio) != 1L || length(hz) != 1L)          v_fail("V3: reference rows not unique")
if (abs(pio$est_z - hz) >= 1e-10)                 v_fail("V3: T1 A3 vs register anchor diverge")
v_ok("V3: aggregates 113/115; pooled identity T1-A3 == register headline_v12_1")

# V4 -- meta-line consistency ----------------------------------------------------
ml <- readLines(meta_p, warn = FALSE)
a7 <- grep("^A7 caterpillar:", ml, value = TRUE)
a8 <- grep("^A8 forest:", ml, value = TRUE)
if (length(a7) != 1L || length(a8) != 1L) v_fail("V4: meta lines missing")
n7 <- as.numeric(regmatches(a7, regexec("k = (\\d+)", a7))[[1]][2])
n8 <- as.numeric(regmatches(a8, regexec("k = (\\d+)", a8))[[1]][2])
p7 <- as.numeric(regmatches(a7, regexec("pooled_z = (-?\\d+\\.\\d+)", a7))[[1]][2])
if (n7 != 113 || n8 != 115)               v_fail("V4: meta k diverges (A7 %s / A8 %s)", n7, n8)
if (abs(p7 - pio$est_z) >= 1e-8)          v_fail("V4: meta pooled_z diverges")
v_ok("V4: fig_run_meta_p6 consistent (k 113/115; pooled_z matches)")
message("R/19 VERIFIER: ALL PASS (4/4)")
