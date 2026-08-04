# R/15_fig1_framework.R -- Figure 1: conceptual framework (Chapter 2)
# FOMA CER-COD-Paris · M4 session, 2026-08-04 · ruling M4-F1 (a): scripted figure.
# Governed by the M4 DEC. Caption lives manuscript-side (F-CAP); this script renders the figure only.
# Content: H1 baseline association · H2 with the two-sided tension (amplification vs. attenuation) ·
#          RQ3 contextual dimensions · RQ4 publication-selection assessment as validity layer.
# Dependencies: base R + grid only (no renv lockfile change). Output is deterministic.
# Canonical run: author-side (RStudio, repo root as working directory) or CC-in-Windows-terminal (DEC-054 §4).

suppressPackageStartupMessages(library(grid))

## ---- configuration -------------------------------------------------------
OUT_DIR <- NULL   # default resolves to <repo root>/output/figures -- confirm/adjust before the canonical run
root    <- if (requireNamespace("here", quietly = TRUE)) here::here() else getwd()
if (is.null(OUT_DIR)) OUT_DIR <- file.path(root, "output", "figures")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
pdf_path <- file.path(OUT_DIR, "fig1_framework.pdf")
png_path <- file.path(OUT_DIR, "fig1_framework.png")

## ---- drawing routine -----------------------------------------------------
draw_fig1 <- function() {
  grid.newpage()
  gp_box   <- gpar(fill = "white", col = "black", lwd = 1.4)
  gp_head  <- gpar(fontsize = 10.5, fontface = "bold", fontfamily = "sans")
  gp_txt   <- gpar(fontsize = 8.6,  fontfamily = "sans")
  gp_small <- gpar(fontsize = 7.8,  fontfamily = "sans")

  ## RQ4 validity layer (bottom band)
  grid.rect(x = .5, y = .075, width = .94, height = .105,
            gp = gpar(fill = "grey92", col = "grey45", lwd = 1.1))
  grid.text("RQ4  \u2014  publication-selection assessment (validity layer of the design)",
            x = .5, y = .075, gp = gp_txt)

  ## RQ3 conditioning panel
  grid.roundrect(x = .5, y = .265, width = .94, height = .155,
                 r = unit(1.5, "mm"), gp = gpar(fill = "white", col = "black", lwd = 1.1, lty = "dashed"))
  grid.text("Contextual dimensions (RQ3)", x = .5, y = .312, gp = gpar(fontsize = 9, fontface = "bold"))
  grid.text("CER measurement \u00b7 COD instrument \u00b7 carbon regulation \u00b7 country / institution",
            x = .5, y = .262, gp = gp_small)
  grid.text("industry sensitivity \u00b7 economic development \u00b7 cultural cluster \u00b7 legal origin",
            x = .5, y = .225, gp = gp_small)
  grid.lines(x = c(.5, .5), y = c(.343, .485),
             gp = gpar(lwd = 1.1, lty = "dashed"),
             arrow = arrow(length = unit(2.2, "mm"), type = "closed"))

  ## H1 spine: CER -> COD
  grid.roundrect(x = .145, y = .52, width = .21, height = .12, r = unit(1.5, "mm"), gp = gp_box)
  grid.text("CER", x = .145, y = .52, gp = gp_head)
  grid.roundrect(x = .855, y = .52, width = .21, height = .12, r = unit(1.5, "mm"), gp = gp_box)
  grid.text("Cost of debt", x = .855, y = .52, gp = gp_head)
  grid.lines(x = c(.253, .747), y = c(.52, .52), gp = gpar(lwd = 2.6),
             arrow = arrow(length = unit(3.2, "mm"), type = "closed"))
  grid.text("H1 (\u2212)", x = .5, y = .553, gp = gpar(fontsize = 9.5, fontface = "bold"))

  ## Paris moderator with two-sided tension
  grid.roundrect(x = .5, y = .865, width = .46, height = .115, r = unit(1.5, "mm"), gp = gp_box)
  grid.text("Paris Agreement (12/2015)", x = .5, y = .888, gp = gp_head)
  grid.text("H2: stronger post-Paris \u2014 adjudicated, not presumed",
            x = .5, y = .842, gp = gp_small)
  grid.lines(x = c(.40, .40), y = c(.807, .60), gp = gpar(lwd = 1.4),
             arrow = arrow(length = unit(2.6, "mm"), type = "closed"))
  grid.text("amplification\n(\u00a72.2)", x = .315, y = .705, gp = gp_small, just = "right")
  grid.lines(x = c(.60, .60), y = c(.807, .60), gp = gpar(lwd = 1.4, lty = "dashed"),
             arrow = arrow(length = unit(2.6, "mm"), type = "closed"))
  grid.text("attenuation\n(\u00a72.2)", x = .685, y = .705, gp = gp_small, just = "left")
}

## ---- render (PDF primary, PNG companion) ---------------------------------
pdf(pdf_path, width = 6.5, height = 4.6, family = "sans", useDingbats = FALSE)
draw_fig1(); dev.off()
png(png_path, width = 6.5, height = 4.6, units = "in", res = 300, family = "sans")
draw_fig1(); dev.off()

## ---- embedded self-check -------------------------------------------------
stopifnot(file.exists(pdf_path), file.size(pdf_path) > 1000,
          identical(readBin(pdf_path, "raw", 5L), charToRaw("%PDF-")),
          file.exists(png_path), file.size(png_path) > 1000)
cat("fig1 OK:", pdf_path, "|", file.size(pdf_path), "bytes ·", png_path, "|", file.size(png_path), "bytes\n")
