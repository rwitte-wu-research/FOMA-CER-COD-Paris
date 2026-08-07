# =============================================================================
# R/19_figures_p6.R -- S1-P6 figure micro-package: A7 re-render + A8 rebuild
# Scope [S1 bootstrap P6; Item 13; DEC-061 family rulings; DEC-063 structure]:
#   (A7) output/figures/T1_A7_caterpillar_cluster.(pdf|png) -> Figure 3
#        mirror of R/14 v6 Section 7 on the v12.1 structure (113 clusters);
#        Fisher-z family axis, ruling-Z window, F-CAP; pooled/PI identity-
#        bound to output/T1_results.csv A3/pi_overall; register cross-assert
#        against the post-merge anchor row `headline_v12_1`.
#   (A8) output/figures/T1_A8_forest_study.(pdf|png) -> Appendix Figure A1
#        rebuild of the legacy R/01 Sec. 11 study forest in the R/14 pattern:
#        Fisher-z axis (matches the placed appendix caption verbatim and the
#        DEC-061 family ruling; the legacy r-axis PDF sat in a latent caption-
#        artifact mismatch, #56 class -- resolved here), F-CAP (no embedded
#        caption -- resolves the "3LMA-RVE" legend, Item 13), PNG added for
#        the docx embed; cairo devices (glyph safety, S1 lesson).
# Sources (committed): R/00_prep.R (v12.1 internally), output/T1_results.csv,
# output/robustness_register.csv. Meta: output/fig_run_meta_p6.txt (own file;
# R/14's fig_run_meta.txt untouched). Verifier: R/19_verify_outputs.R.
# =============================================================================

# SECTION 1 -- Environment ------------------------------------------------------
source(here::here("setup.R"))

# SECTION 2 -- Constants --------------------------------------------------------
REGISTER_CSV <- here::here("output", "robustness_register.csv")
T1_CSV       <- here::here("output", "T1_results.csv")
FIG_DIR      <- here::here("output", "figures")
EXP_ES       <- 2713L
EXP_STUDIES  <- 115L
EXP_CLUSTERS <- 113L     # v12.1 (DEC-063)
RHO_HEADLINE <- 0.6
FIG_W <- 7; FIG_H <- 5; FIG_DPI <- 300
stopifnot(file.exists(REGISTER_CSV), file.exists(T1_CSV),
          file.exists(here::here("R", "00_prep.R")))
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

save_fig <- function(path, plot, width, height, dpi = FIG_DPI) {
  if (grepl("\\.pdf$", path)) {
    ggplot2::ggsave(path, plot, width = width, height = height,
                    device = grDevices::cairo_pdf)
  } else {
    ggplot2::ggsave(path, plot, width = width, height = height, dpi = dpi,
                    device = grDevices::png, type = "cairo")
  }
}

# SECTION 3 -- Pooled reference (post-merge register anchor) --------------------
reg <- readr::read_csv(REGISTER_CSV, show_col_types = FALSE)
headline_z <- reg$est_z[reg$spec == "headline_v12_1"]
stopifnot(length(headline_z) == 1L, is.finite(headline_z))

# SECTION 4 -- Estimation set via committed prep (reads v12.1 internally) -------
source(here::here("R", "00_prep.R"))
stopifnot(exists("d"), exists("est"), is.logical(est), length(est) == nrow(d))
es <- d[est, , drop = FALSE]
stopifnot(nrow(es) == EXP_ES,
          dplyr::n_distinct(es$study)      == EXP_STUDIES,
          dplyr::n_distinct(es$cluster_id) == EXP_CLUSTERS)
es <- dplyr::mutate(es,
  zi = as.numeric(.data$d_fisher_z),
  vi = 1 / (as.numeric(.data$n_eff) - 3))
stopifnot(all(is.finite(es$zi)), all(is.finite(es$vi)), all(es$vi > 0))

# SECTION 5 -- T1 identity (A3/pi_overall) --------------------------------------
t1  <- readr::read_csv(T1_CSV, show_col_types = FALSE)
pio <- t1[t1$analysis_id == "A3" & t1$spec == "pi_overall", , drop = FALSE]
stopifnot(nrow(pio) == 1L, is.finite(pio$est_z),
          is.finite(pio$pi_lb_z), is.finite(pio$pi_ub_z),
          abs(pio$est_z - headline_z) < 1e-10)
t1_pool <- pio$est_z; t1_pi_lb <- pio$pi_lb_z; t1_pi_ub <- pio$pi_ub_z

# SECTION 6 -- Aggregation (ported verbatim from R/01_core.R / R/14 v6) ---------
agg_rho <- function(dd, unit_col, rho) {
  esc <- metafor::escalc(measure = "GEN", yi = dd$yi, vi = dd$vi,
                         data = data.frame(agg_unit = dd[[unit_col]]))
  ag  <- aggregate(esc, cluster = agg_unit, rho = rho)
  data.frame(unit = ag$agg_unit, yi = as.numeric(ag$yi), vi = as.numeric(ag$vi))
}

# SECTION 7 -- A7: cluster caterpillar (z scale, ruling-Z window) ---------------
agc <- agg_rho(data.frame(yi = es$zi, vi = es$vi, cluster = es$cluster_id),
               "cluster", RHO_HEADLINE)
stopifnot(nrow(agc) == EXP_CLUSTERS,
          all(is.finite(agc$yi)), all(is.finite(agc$vi)), all(agc$vi > 0))
agc <- dplyr::mutate(agc,
  ci_lb = .data$yi - 1.96 * sqrt(.data$vi),
  ci_ub = .data$yi + 1.96 * sqrt(.data$vi),
  rank  = rank(.data$yi, ties.method = "first"))
Y_WIN <- c(-0.6, 0.5)
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
save_fig(file.path(FIG_DIR, "T1_A7_caterpillar_cluster.pdf"), p_cat, FIG_W, FIG_H)
save_fig(file.path(FIG_DIR, "T1_A7_caterpillar_cluster.png"), p_cat, FIG_W, FIG_H)

# SECTION 8 -- A8: study forest (r scale, labeled, A4 portrait, F-CAP) ----------
ags <- agg_rho(data.frame(yi = es$zi, vi = es$vi, study = es$study),
               "study", RHO_HEADLINE)
stopifnot(nrow(ags) == EXP_STUDIES, all(is.finite(ags$yi)), all(ags$vi > 0))
ags <- dplyr::mutate(ags,
  ci_lb = .data$yi - 1.96 * sqrt(.data$vi),
  ci_ub = .data$yi + 1.96 * sqrt(.data$vi),
  label = as.character(.data$unit))
p_for <- ggplot2::ggplot(ags, ggplot2::aes(x = yi, y = stats::reorder(label, yi))) +
  ggplot2::geom_vline(xintercept = 0, colour = "grey60", linewidth = 0.3) +
  ggplot2::geom_vline(xintercept = t1_pool, linetype = "dashed",
                      colour = "black", linewidth = 0.4) +
  ggplot2::geom_linerange(ggplot2::aes(xmin = ci_lb, xmax = ci_ub),
                          colour = "grey45", alpha = 0.6, linewidth = 0.35) +
  ggplot2::geom_point(size = 0.8, colour = "grey15") +
  ggplot2::labs(x = "Study aggregate (Fisher z), 95% CI", y = NULL) +
  ggplot2::theme_classic(base_size = 7) +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 4.6),
                 panel.grid.minor = ggplot2::element_blank())
save_fig(file.path(FIG_DIR, "T1_A8_forest_study.pdf"), p_for, 8.27, 11.69)
save_fig(file.path(FIG_DIR, "T1_A8_forest_study.png"), p_for, 8.27, 11.69)

# SECTION 9 -- Run meta (own file; R/14 meta untouched) --------------------------
meta <- c(
  sprintf("19_figures_p6.R run: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  sprintf("estimation set: %d ES / %d studies / %d clusters",
          nrow(es), dplyr::n_distinct(es$study), dplyr::n_distinct(es$cluster_id)),
  sprintf("A7 caterpillar: k = %d aggregates; pooled_z = %.10f; PI_z = [%.10f; %.10f]",
          nrow(agc), t1_pool, t1_pi_lb, t1_pi_ub),
  sprintf("A8 forest: k = %d study aggregates; pooled_z = %.10f", nrow(ags), t1_pool),
  "", capture.output(sessionInfo()))
writeLines(meta, here::here("output", "fig_run_meta_p6.txt"))
message("[R19 DONE] A7 pair re-rendered + A8 pair rebuilt (F-CAP); meta written.")
