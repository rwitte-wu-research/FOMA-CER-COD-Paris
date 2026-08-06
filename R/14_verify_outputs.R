# =============================================================================
# 14_verify_outputs.R — verifier for R/14_figures.R (M2 figure package) — v5
# Independently re-reads all committed sources and asserts (a) the eight figure
# files exist and are non-empty, (b) the source contracts hold, (c) the
# TB-41/TB-42 pinned values are reproduced by the plotted data at 3 dp.
# v4: helper names v_ok/v_fail (R/00_prep.R defines its own ok(); sourcing it
# in V2 overwrote the verifier helpers in v3 — namespace-safe rename).
# v5 (DEC-061): + T1_A7 caterpillar pair in V1; new V6 numeric-identity block —
#   pooled/PI vs. output/T1_results.csv A3/pi_overall (register cross-check at
#   1e-10; r3 pins -0.059 / [-0.412; 0.295]), independent aggregate
#   re-derivation (k = 114, rank/order logic), fig_run_meta A7-line consistency.
# Any failure stops with a message; the runner pastes the full console output.
# =============================================================================
source(here::here("setup.R"))

v_fail <- function(...) stop(sprintf(...), call. = FALSE)
v_ok   <- function(...) message(sprintf("PASS  %s", sprintf(...)))
r3     <- function(x) round(x, 3)

FIG_DIR <- here::here("output", "figures")
files <- file.path(FIG_DIR, c(
  "D1_funnel_contour.pdf",  "D1_funnel_contour.png",
  "TH_a_H7_cumulative.pdf", "TH_a_H7_cumulative.png",
  "TH_a_H8_rolling.pdf",    "TH_a_H8_rolling.png",
  "T1_A7_caterpillar_cluster.pdf", "T1_A7_caterpillar_cluster.png"))

# V1 — outputs exist and are non-empty ----------------------------------------
for (f in files) {
  if (!file.exists(f))       v_fail("missing figure file: %s", f)
  if (file.info(f)$size < 1) v_fail("empty figure file: %s", f)
}
if (!file.exists(here::here("output", "fig_run_meta.txt")))
  v_fail("missing output/fig_run_meta.txt")
v_ok("V1: 8 figure files + fig_run_meta.txt present, non-empty")

# V2 — estimation-set contract (funnel source, via canonical prep) ------------
source(here::here("R", "00_prep.R"))
if (!exists("d") || !exists("est") || !is.logical(est))
  v_fail("V2: R/00_prep.R did not define d/est as expected")
es <- d[est, , drop = FALSE]
if (nrow(es) != 2713L)                          v_fail("V2: ES count %d != 2713", nrow(es))
if (dplyr::n_distinct(es$study) != 115L)        v_fail("V2: study count != 115")
if (dplyr::n_distinct(es$cluster_id) != 114L)   v_fail("V2: cluster count != 114")
n_bad <- sum(!is.finite(as.numeric(es$d_fisher_z)) |
             !is.finite(1 / (as.numeric(es$n_eff) - 3)))
if (n_bad != 0L) v_fail("V2: %d ES with non-finite zi or vi", n_bad)
v_ok("V2: estimation set 2,713 ES / 115 studies / 114 clusters; zi, vi finite")

# V3 — register headline (pooled reference line) -------------------------------
reg <- readr::read_csv(here::here("output", "robustness_register.csv"),
                       show_col_types = FALSE)
hz <- reg$est_z[reg$spec == "headline"]
if (length(hz) != 1L || !is.finite(hz)) v_fail("V3: register headline not readable")
if (r3(hz) != -0.059) v_fail("V3: headline z rounds to %.3f, expected -0.059", hz)
v_ok("V3: register headline z = %.6f (rounds to -0.059)", hz)

# V4 — H7 cumulative: structure + TB-41 pins -----------------------------------
tha <- readr::read_csv(here::here("output", "TH_a_results.csv"),
                       show_col_types = FALSE)
h7 <- tha |>
  dplyr::filter(.data$analysis_id == "H7", .data$spec == "cumulative") |>
  dplyr::mutate(step = as.integer(sub("^step_", "", .data$term))) |>
  dplyr::arrange(.data$step)
if (nrow(h7) != 113L)                    v_fail("V4: H7 rows %d != 113", nrow(h7))
if (!is.na(h7$est_z[1]))                 v_fail("V4: step_001 unexpectedly estimable")
if (any(is.na(h7$est_z[-1])))            v_fail("V4: NA est_z beyond step_001")
full <- !is.na(h7$k_cluster) & h7$k_cluster >= 10L
if (min(h7$step[full]) != 10L)           v_fail("V4: 10-cluster floor not at step 10")
if (r3(h7$est_z[113]) != -0.059)         v_fail("V4: end value %.3f != -0.059", h7$est_z[113])
if (r3(h7$ci_lb_z[113]) != -0.087 || r3(h7$ci_ub_z[113]) != -0.031)
  v_fail("V4: end CI [%.3f; %.3f] != [-0.087; -0.031]",
         h7$ci_lb_z[113], h7$ci_ub_z[113])
rng <- range(h7$est_z[full])
if (r3(rng[1]) != -0.095 || r3(rng[2]) != -0.015)
  v_fail("V4: post-floor range [%.3f; %.3f] != [-0.095; -0.015]", rng[1], rng[2])
v_ok("V4: H7 = 113 steps; floor at step 10; end -0.059 [-0.087; -0.031]; range [-0.095; -0.015]")

# V5 — H8 rolling: structure + TB-42 pins --------------------------------------
h8 <- tha |>
  dplyr::filter(.data$analysis_id == "H8", .data$spec == "rolling") |>
  dplyr::mutate(win_start = as.integer(sub(".*window \\[(\\d{4}),.*", "\\1",
                                           .data$note))) |>
  dplyr::arrange(.data$win_start)
if (nrow(h8) != 21L)                     v_fail("V5: H8 rows %d != 21", nrow(h8))
if (sum(is.na(h8$est_z)) != 1L)          v_fail("V5: %d non-estimable windows != 1",
                                                sum(is.na(h8$est_z)))
if (h8$win_start[is.na(h8$est_z)] != 2002L)
  v_fail("V5: non-estimable window starts %d, expected 2002",
         h8$win_start[is.na(h8$est_z)])
est_w <- h8[!is.na(h8$est_z), ]
if (nrow(est_w) != 20L)                  v_fail("V5: estimable windows != 20")
desc <- est_w$k_cluster < 10L
if (any(!is.na(est_w$ci_lb_z[desc])))
  v_fail("V5: descriptive-tier window carries a CI (rule violation)")
if (any(is.na(est_w$ci_lb_z[!desc])))
  v_fail("V5: full-tier window lacks a CI")
rng8 <- range(est_w$est_z)
if (r3(rng8[1]) != -0.087 || r3(rng8[2]) != -0.015)
  v_fail("V5: window-mean range [%.3f; %.3f] != [-0.087; -0.015]",
         rng8[1], rng8[2])
v_ok("V5: H8 = 21 windows / 20 estimable; 2002 window not estimable; tiers clean; range [-0.087; -0.015]")

# V6 — A7 caterpillar: numeric identity + logic [DEC-061] ----------------------
t1 <- readr::read_csv(here::here("output", "T1_results.csv"), show_col_types = FALSE)
pio <- t1[t1$analysis_id == "A3" & t1$spec == "pi_overall", , drop = FALSE]
if (nrow(pio) != 1L) v_fail("V6: A3/pi_overall rows %d != 1", nrow(pio))
if (abs(pio$est_z - hz) > 1e-10)
  v_fail("V6: pi_overall est_z %.12f != register headline %.12f", pio$est_z, hz)
if (r3(pio$est_z) != -0.059 || r3(pio$pi_lb_z) != -0.412 || r3(pio$pi_ub_z) != 0.295)
  v_fail("V6: pooled/PI pins violated: %.3f [%.3f; %.3f]",
         pio$est_z, pio$pi_lb_z, pio$pi_ub_z)
esc <- metafor::escalc(measure = "GEN",
                       yi = as.numeric(es$d_fisher_z),
                       vi = 1 / (as.numeric(es$n_eff) - 3),
                       data = data.frame(agg_unit = es$cluster_id))
agv <- aggregate(esc, cluster = agg_unit, rho = 0.6)
if (nrow(agv) != 114L) v_fail("V6: aggregate count %d != 114", nrow(agv))
if (!all(is.finite(as.numeric(agv$yi))) || !all(is.finite(as.numeric(agv$vi))))
  v_fail("V6: non-finite aggregate yi/vi")
rk <- rank(as.numeric(agv$yi), ties.method = "first")
if (!all(sort(rk) == 1:114)) v_fail("V6: rank is not a 1..114 permutation")
if (is.unsorted(as.numeric(agv$yi)[order(rk)]))
  v_fail("V6: ordering by rank does not sort the aggregates")
meta_l <- readLines(here::here("output", "fig_run_meta.txt"))
a7 <- grep("^A7 caterpillar:", meta_l, value = TRUE)
if (length(a7) != 1L)
  v_fail("V6: fig_run_meta lacks the A7 line (run 14_figures v6 first)")
num <- as.numeric(regmatches(a7, gregexpr("-?\\d+\\.\\d+", a7))[[1]])
if (length(num) != 3L ||
    max(abs(num - c(pio$est_z, pio$pi_lb_z, pio$pi_ub_z))) > 1e-9)
  v_fail("V6: meta A7 values diverge from T1_results.csv")
v_ok("V6: A7 identity — pooled %.10f; PI [%.10f; %.10f]; k = 114; rank/order logic clean; meta consistent",
     pio$est_z, pio$pi_lb_z, pio$pi_ub_z)

message("\n================ R/14 VERIFIER: ALL PASS ================")
