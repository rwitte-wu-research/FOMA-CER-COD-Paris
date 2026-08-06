# =============================================================================
# 14_figures.R — manuscript figures for Ch. 4 (M2)
# Builds three figure pairs (pdf + png) as BUILD ARTIFACTS from committed
# sources only — no re-estimation anywhere:
#   (1) output/figures/D1_funnel_contour.(pdf|png)   -> Appendix Figure A2
#       contour-enhanced funnel, Fisher-z scale, estimation set (2,713 ES),
#       pooled reference line read from output/robustness_register.csv.
#   (2) output/figures/TH_a_H7_cumulative.(pdf|png)  -> Figure 4 (Sec. 4.2.4)
#       chronological cumulative meta-analysis, 113 steps, values verbatim
#       from output/TH_a_results.csv (H7 rows); 10-cluster display floor
#       [DEC-045/H-Q17]: point-only below 10 clusters, CI band from step 10.
#   (3) output/figures/TH_a_H8_rolling.(pdf|png)     -> Figure 5 (Sec. 4.2.4)
#       rolling six-year windows (step 1 y, anchor 1998), values verbatim
#       from output/TH_a_results.csv (H8 rows); tiers per [DEC-045 S6]:
#       >=10 clusters full CI, 5-9 clusters point-only, <5 not estimable.
#   (4) output/figures/T1_A7_caterpillar_cluster.(pdf|png) -> Figure 3 (Sec. 4.1.1)
#       cluster-level caterpillar, Fisher-z scale; CS rho = 0.6 aggregates on
#       cluster_id (agg logic ported verbatim from R/01_core.R Sec. 10); pooled
#       line + PI bounds identity-bound to output/T1_results.csv A3/pi_overall
#       and cross-asserted against the register headline [DEC-061]; display
#       window per the ruling-Z analogue [DEC-061 sec. 2].
#
# Decision basis: M2 chapter DEC DEC-054 (figure
# package ruling A5-A8 + hub ack 2026-08-02); manuscript pipeline ruling
# (tables/figures = build artifacts from committed CSVs); DEC-045 S6/H-Q17
# display floors; ch3 Sec. 3.3.1 vi spec (Fisher-z sampling variance
# 1/(n - 3), n = n_obs firm-years; the n_firms basis is the G-register fork).
# v5 (rulings Z + F-CAP, 2026-08-03): funnel display window |z| <= 1 with an
# out-of-range annotation; embedded figure captions removed — the manuscript
# captions carry the legends.
# v6 (DEC-061, 2026-08-06): A7 caterpillar re-homed from R/01_core.R Sec. 10 as
# a build artifact — Fisher-z scale (family axis), R/14 family style, F-CAP
# (no embedded caption/legend/estimator label); resolves ERROR #56.
# v6.1 (DEC-061 §2, author display ruling 2026-08-06): ruling-Z analogue —
# fixed display window ylim [-0.6, 0.5] with funnel-style out-of-range
# annotation (one extreme cluster aggregate, z ~ -2.6, previously masked by
# the tanh bound of the r-scale display).
#
# Sources (all committed): R/00_prep.R (canonical estimation-set
# construction: `est` = d_es_usable == 1 & duplicate in {NA, 0} &
# is.finite(n_eff); reads data/CER-COD_data_v12.xlsx internally),
# output/robustness_register.csv, output/TH_a_results.csv, output/T1_results.csv.
# Output: output/figures/*.(pdf|png) + output/fig_run_meta.txt.
# Verifier: R/14_verify_outputs.R (run immediately after; PASS required).
# =============================================================================

# SECTION 1 — Environment ------------------------------------------------------
source(here::here("setup.R"))

# SECTION 2 — Constants (contract against the committed sources) ---------------
REGISTER_CSV   <- here::here("output", "robustness_register.csv")
THA_CSV        <- here::here("output", "TH_a_results.csv")
T1_CSV         <- here::here("output", "T1_results.csv")
FIG_DIR        <- here::here("output", "figures")

EXP_ES         <- 2713L    # estimation set, effect sizes
EXP_STUDIES    <- 115L
EXP_CLUSTERS   <- 114L
EXP_H7_STEPS   <- 113L     # cumulative steps [TB-41]
EXP_H8_WINDOWS <- 21L      # rolling windows, 20 estimable [TB-42]
FLOOR_FULL     <- 10L      # CI display floor [DEC-045/H-Q17; S6]
FLOOR_DESC     <- 5L       # descriptive tier lower bound [DEC-045 S6]
RHO_HEADLINE   <- 0.6      # CS working correlation [DEC-031; plan par. 3]

FIG_W <- 7; FIG_H <- 5; FIG_DPI <- 300

stopifnot(file.exists(REGISTER_CSV), file.exists(THA_CSV), file.exists(T1_CSV),
          file.exists(here::here("R", "00_prep.R")))
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

# SECTION 3 — Pooled reference from the committed register ----------------------
reg <- readr::read_csv(REGISTER_CSV, show_col_types = FALSE)
stopifnot("spec" %in% names(reg), "est_z" %in% names(reg))
headline_z <- reg$est_z[reg$spec == "headline"]
stopifnot(length(headline_z) == 1L, is.finite(headline_z))

# SECTION 4 — Figure A2: contour-enhanced funnel (z scale) ---------------------
# Estimation set via the committed prep: R/00_prep.R defines `d` (full corpus)
# and the logical `est` (usable & non-duplicate & finite n_eff), with its own
# internal asserts (2,730 usable; 16 usable no-n rows dropped; 1 duplicate).
# We source it rather than re-deriving any rule; expect its ok()-lines on the
# console. Side effect (writing the gitignored data/processed mirrors) is
# expected and harmless.
source(here::here("R", "00_prep.R"))
stopifnot(exists("d"), exists("est"), is.logical(est), length(est) == nrow(d))
es <- d[est, , drop = FALSE]
stopifnot(nrow(es) == EXP_ES)
stopifnot(dplyr::n_distinct(es$study)      == EXP_STUDIES)
stopifnot(dplyr::n_distinct(es$cluster_id) == EXP_CLUSTERS)

es <- dplyr::mutate(es,
  zi  = as.numeric(.data$d_fisher_z),
  vi  = 1 / (as.numeric(.data$n_eff) - 3),   # ch3 Sec. 3.3.1 spec; n = n_eff
  sei = sqrt(.data$vi))
stopifnot(all(is.finite(es$zi)), all(is.finite(es$sei)), all(es$sei > 0))

se_max  <- max(es$sei) * 1.02
se_grid <- seq(0, se_max, length.out = 400)
contour_poly <- function(z_lo, z_hi) {
  data.frame(x = c(z_lo * se_grid, rev(z_hi * se_grid)),
             y = c(se_grid, rev(se_grid)))
}
z90 <- qnorm(0.95); z95 <- qnorm(0.975); z99 <- qnorm(0.995)

p_funnel <- ggplot2::ggplot() +
  ggplot2::geom_polygon(data = contour_poly(-z99, z99),
                        ggplot2::aes(x, y), fill = "grey97") +
  ggplot2::geom_polygon(data = contour_poly(-z95, z95),
                        ggplot2::aes(x, y), fill = "grey90") +
  ggplot2::geom_polygon(data = contour_poly(-z90, z90),
                        ggplot2::aes(x, y), fill = "grey82") +
  ggplot2::geom_vline(xintercept = 0, linewidth = 0.3, colour = "grey40") +
  ggplot2::geom_point(data = es, ggplot2::aes(x = zi, y = sei),
                      shape = 21, size = 1.1, stroke = 0.25,
                      fill = "white", colour = "grey25", alpha = 0.6) +
  ggplot2::geom_vline(xintercept = headline_z, linetype = "dashed",
                      linewidth = 0.5, colour = "black") +
  ggplot2::scale_y_reverse(limits = c(se_max, 0), expand = c(0, 0)) +
  ggplot2::coord_cartesian(xlim = c(-1, 1)) +
  ggplot2::annotate("text", x = -0.98, y = 0.005, hjust = 0, vjust = 1,
                    size = 2.8, colour = "grey35",
                    label = sprintf(
                      "%d effect sizes beyond display range (max |z| = %.2f)",
                      sum(abs(es$zi) > 1), max(abs(es$zi)))) +
  ggplot2::labs(x = "Effect size (Fisher z)", y = "Standard error") +
  ggplot2::theme_classic(base_size = 11)

ggplot2::ggsave(file.path(FIG_DIR, "D1_funnel_contour.pdf"), p_funnel,
                width = FIG_W, height = FIG_H)
ggplot2::ggsave(file.path(FIG_DIR, "D1_funnel_contour.png"), p_funnel,
                width = FIG_W, height = FIG_H, dpi = FIG_DPI)

# SECTION 5 — Figure 4: chronological cumulative meta-analysis -----------------
tha <- readr::read_csv(THA_CSV, show_col_types = FALSE)
need_cols <- c("analysis_id", "spec", "term", "est_z",
               "ci_lb_z", "ci_ub_z", "k_cluster", "note")
stopifnot(all(need_cols %in% names(tha)))

h7 <- tha |>
  dplyr::filter(.data$analysis_id == "H7", .data$spec == "cumulative") |>
  dplyr::mutate(step = as.integer(sub("^step_", "", .data$term))) |>
  dplyr::arrange(.data$step)
stopifnot(nrow(h7) == EXP_H7_STEPS,
          identical(h7$step, seq_len(EXP_H7_STEPS)),
          is.na(h7$est_z[1]),                       # step 1 not estimable
          all(!is.na(h7$est_z[-1])))
h7 <- dplyr::mutate(h7, tier_full = !is.na(.data$k_cluster) &
                                     .data$k_cluster >= FLOOR_FULL)
stopifnot(min(h7$step[h7$tier_full]) == 10L)        # floor reached at step 10

p_cum <- ggplot2::ggplot(h7[!is.na(h7$est_z), ],
                         ggplot2::aes(x = step, y = est_z)) +
  ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey60") +
  ggplot2::geom_ribbon(data = ~ dplyr::filter(.x, .data$tier_full),
                       ggplot2::aes(ymin = ci_lb_z, ymax = ci_ub_z),
                       fill = "grey80", alpha = 0.7) +
  ggplot2::geom_line(linewidth = 0.5, colour = "grey20") +
  ggplot2::geom_point(data = ~ dplyr::filter(.x, !.data$tier_full),
                      size = 1.2, shape = 16, colour = "grey20") +
  ggplot2::geom_hline(yintercept = headline_z, linetype = "dashed",
                      linewidth = 0.4) +
  ggplot2::labs(x = "Cumulative step (studies added in sample-window order)",
                y = "Pooled estimate (Fisher z)") +
  ggplot2::theme_classic(base_size = 11)

ggplot2::ggsave(file.path(FIG_DIR, "TH_a_H7_cumulative.pdf"), p_cum,
                width = FIG_W, height = FIG_H)
ggplot2::ggsave(file.path(FIG_DIR, "TH_a_H7_cumulative.png"), p_cum,
                width = FIG_W, height = FIG_H, dpi = FIG_DPI)

# SECTION 6 — Figure 5: rolling six-year windows -------------------------------
h8 <- tha |>
  dplyr::filter(.data$analysis_id == "H8", .data$spec == "rolling") |>
  dplyr::mutate(
    win_start = as.integer(sub(".*window \\[(\\d{4}),.*", "\\1", .data$note)),
    win_end   = as.integer(sub(".*window \\[\\d{4}, (\\d{4})\\).*", "\\1",
                               .data$note)),
    win_mid   = .data$win_start + (.data$win_end - .data$win_start) / 2) |>
  dplyr::arrange(.data$win_start)
stopifnot(nrow(h8) == EXP_H8_WINDOWS,
          all(is.finite(h8$win_start)),
          all(h8$win_end - h8$win_start == 6L),
          sum(is.na(h8$est_z)) == 1L,
          h8$win_start[is.na(h8$est_z)] == 2002L)   # the <5-cluster window
h8 <- dplyr::mutate(h8,
  tier = dplyr::case_when(
    is.na(.data$est_z)                 ~ "not_estimable",
    .data$k_cluster >= FLOOR_FULL      ~ "full",
    .data$k_cluster >= FLOOR_DESC      ~ "descriptive",
    TRUE                               ~ "not_estimable"))
stopifnot(sum(h8$tier != "not_estimable") == 20L)

p_roll <- ggplot2::ggplot(dplyr::filter(h8, .data$tier != "not_estimable"),
                          ggplot2::aes(x = win_mid, y = est_z)) +
  ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey60") +
  ggplot2::geom_errorbar(data = ~ dplyr::filter(.x, .data$tier == "full"),
                         ggplot2::aes(ymin = ci_lb_z, ymax = ci_ub_z),
                         width = 0.35, linewidth = 0.4, colour = "grey30") +
  ggplot2::geom_point(ggplot2::aes(shape = tier), size = 2,
                      colour = "grey15", fill = "white") +
  ggplot2::scale_shape_manual(
    values = c(full = 16, descriptive = 21), guide = "none") +
  ggplot2::geom_hline(yintercept = headline_z, linetype = "dashed",
                      linewidth = 0.4) +
  ggplot2::annotate("text", x = 2005, y = max(h8$est_z, na.rm = TRUE),
                    label = "2002 window: < 5 clusters (not estimable)",
                    size = 2.8, hjust = 0, colour = "grey35") +
  ggplot2::labs(x = "Window midpoint (six-year windows, step 1 year, anchor 1998)",
                y = "Window mean (Fisher z)") +
  ggplot2::theme_classic(base_size = 11)

ggplot2::ggsave(file.path(FIG_DIR, "TH_a_H8_rolling.pdf"), p_roll,
                width = FIG_W, height = FIG_H)
ggplot2::ggsave(file.path(FIG_DIR, "TH_a_H8_rolling.png"), p_roll,
                width = FIG_W, height = FIG_H, dpi = FIG_DPI)

# SECTION 7 — Figure 3: cluster-level caterpillar (z scale) [DEC-061] ----------
# Pooled + PI from the committed T1 battery (A3/pi_overall row; identical fit
# to the headline, T1 verifier identity O20); cross-asserted vs. the register.
t1  <- readr::read_csv(T1_CSV, show_col_types = FALSE)
pio <- t1[t1$analysis_id == "A3" & t1$spec == "pi_overall", , drop = FALSE]
stopifnot(nrow(pio) == 1L, is.finite(pio$est_z),
          is.finite(pio$pi_lb_z), is.finite(pio$pi_ub_z),
          abs(pio$est_z - headline_z) < 1e-10)
t1_pool <- pio$est_z; t1_pi_lb <- pio$pi_lb_z; t1_pi_ub <- pio$pi_ub_z

# Aggregation ported verbatim from R/01_core.R (agg_rho; Borenstein CS
# aggregation via metafor::aggregate.escalc, rho as working correlation).
agg_rho <- function(dd, unit_col, rho) {
  esc <- metafor::escalc(measure = "GEN", yi = dd$yi, vi = dd$vi,
                         data = data.frame(agg_unit = dd[[unit_col]]))
  ag  <- aggregate(esc, cluster = agg_unit, rho = rho)
  data.frame(unit = ag$agg_unit, yi = as.numeric(ag$yi), vi = as.numeric(ag$vi))
}
agc <- agg_rho(data.frame(yi = es$zi, vi = es$vi, cluster = es$cluster_id),
               "cluster", RHO_HEADLINE)
stopifnot(nrow(agc) == EXP_CLUSTERS,
          all(is.finite(agc$yi)), all(is.finite(agc$vi)), all(agc$vi > 0))
agc <- dplyr::mutate(agc,
  ci_lb = .data$yi - 1.96 * sqrt(.data$vi),
  ci_ub = .data$yi + 1.96 * sqrt(.data$vi),
  rank  = rank(.data$yi, ties.method = "first"))

Y_WIN <- c(-0.6, 0.5)   # ruling-Z analogue window (covers the PI bounds with margin)
n_out <- sum(agc$yi < Y_WIN[1] | agc$yi > Y_WIN[2])

p_cat <- ggplot2::ggplot(agc, ggplot2::aes(x = rank, y = yi)) +
  ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey60") +
  ggplot2::geom_linerange(ggplot2::aes(ymin = ci_lb, ymax = ci_ub),
                          colour = "grey45", alpha = 0.6, linewidth = 0.35) +
  ggplot2::geom_point(size = 0.9, colour = "grey15") +
  ggplot2::geom_hline(yintercept = t1_pool, linetype = "dashed",
                      linewidth = 0.4, colour = "black") +
  ggplot2::geom_hline(yintercept = c(t1_pi_lb, t1_pi_ub), linetype = "dotted",
                      linewidth = 0.4, colour = "grey30") +
  ggplot2::labs(x = sprintf("Cluster aggregates (k = %d), sorted", nrow(agc)),
                y = "Cluster aggregate (Fisher z)") +
  ggplot2::theme_classic(base_size = 11) +
  ggplot2::theme(axis.text.x  = ggplot2::element_blank(),
                 axis.ticks.x = ggplot2::element_blank()) +
  ggplot2::coord_cartesian(ylim = Y_WIN) +
  ggplot2::annotate("text", x = 3, y = Y_WIN[2] - 0.01, hjust = 0, vjust = 1,
                    size = 2.8, colour = "grey35",
                    label = sprintf("%d cluster aggregate%s beyond display range (z = %.2f)",
                                    n_out, ifelse(n_out == 1L, "", "s"),
                                    agc$yi[which.max(abs(agc$yi))]))

ggplot2::ggsave(file.path(FIG_DIR, "T1_A7_caterpillar_cluster.pdf"), p_cat,
                width = FIG_W, height = FIG_H)
ggplot2::ggsave(file.path(FIG_DIR, "T1_A7_caterpillar_cluster.png"), p_cat,
                width = FIG_W, height = FIG_H, dpi = FIG_DPI)

# SECTION 8 — Run meta ----------------------------------------------------------
meta <- c(
  sprintf("14_figures.R run: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  sprintf("estimation set: %d ES / %d studies / %d clusters",
          nrow(es), dplyr::n_distinct(es$study),
          dplyr::n_distinct(es$cluster_id)),
  sprintf("headline_z (register): %.10f", headline_z),
  sprintf("H7 steps: %d (floor at step %d)", nrow(h7),
          min(h7$step[h7$tier_full])),
  sprintf("H8 windows: %d (estimable: %d)", nrow(h8),
          sum(h8$tier != "not_estimable")),
  sprintf("A7 caterpillar: k = %d aggregates; pooled_z = %.10f; PI_z = [%.10f; %.10f]",
          nrow(agc), t1_pool, t1_pi_lb, t1_pi_ub),
  "", capture.output(sessionInfo()))
writeLines(meta, here::here("output", "fig_run_meta.txt"))

message("14_figures.R: all four figure pairs written to output/figures/.")
