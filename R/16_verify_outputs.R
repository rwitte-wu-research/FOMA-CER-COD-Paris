# =============================================================================
# R/16_verify_outputs.R
# Paired verifier for R/16_fingerprint_screen.R
# (SUBMISSION_READINESS Item 19; ERROR #58 systemic follow-up)
#
# Recomputes the pair list independently of the production script and asserts
# it against the written CSV, plus control pins fixed at build time:
#   positive control  — Pizzutilo/Caragnano (the ERROR #58 pair) must be found;
#   known-cluster     — Sandra/Ofogbe must be found AND labelled
#                       same_cluster_known = yes (DEC-042a single multi-study
#                       cluster; not a new find);
#   scope anchors     — 125 rows · 93 row-bearing cells · 80 bp_ok cells.
# Exit is non-zero on any failure. Descriptive strings only; no effect
# estimates are read anywhere.
# =============================================================================

suppressPackageStartupMessages(library(here))

bm_dir  <- here("data", "benchmarks")
raw_dir <- file.path(bm_dir, "raw")

fails <- character(0)
ok <- function(label, cond) {
  cat(sprintf("%-62s %s\n", label, if (isTRUE(cond)) "PASS" else "FAIL"))
  if (!isTRUE(cond)) fails <<- c(fails, label)
}

read_csv_strict <- function(path) {
  d <- read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM",
                colClasses = "character")
  d[] <- lapply(d, function(x) trimws(ifelse(is.na(x), "", x)))
  d
}

rows <- read_csv_strict(file.path(bm_dir, "p1_rows_merged.csv"))
covg <- read.csv(file.path(bm_dir, "p1_coverage.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
pairs <- read_csv_strict(file.path(bm_dir, "p1_fingerprint_pairs.csv"))

# ---- V1-V3 scope anchors ----------------------------------------------------
d <- rows[nchar(rows$sd_printed) > 0, ]
cells <- unique(d[, c("instrument_class", "study_key")])
cc <- table(cells$instrument_class)
ok("V1  merged rows == 125",                     nrow(rows) == 125L)
ok("V2  row-bearing cells == 93 (62/22/9)",
   nrow(cells) == 93L && cc[["loan"]] == 62L && cc[["bond"]] == 22L && cc[["CDS"]] == 9L)
ok("V3  registered bp_ok cells == 80 (52/21/7)",
   sum(as.integer(covg$bp_ok)) == 80L &&
   all(sort(as.integer(covg$bp_ok)) == c(7L, 21L, 52L)))

# ---- V4 schema --------------------------------------------------------------
SCHEMA <- c("instrument_class", "study_a", "study_b", "matched_sd_values",
            "n_matching_values", "sig_digits_max", "unit_a", "unit_b",
            "mean_match", "stratum", "same_cluster_known", "status_a",
            "status_b", "source_pointer_a", "source_pointer_b")
ok("V4  pairs CSV schema exact (15 columns, order)", identical(names(pairs), SCHEMA))

# ---- V5 pair count pin ------------------------------------------------------
ok("V5  pairs total == 8",                        nrow(pairs) == 8L)

get_pair <- function(a, b) pairs[pairs$study_a == a & pairs$study_b == b, ]

# ---- V6 positive control: the ERROR #58 pair --------------------------------
p1 <- get_pair("Caragnano et al (2020)", "Pizzutilo et al (2020)")
ok("V6  positive control Caragnano-Pizzutilo found",
   nrow(p1) == 1 && p1$instrument_class == "loan" &&
   grepl("(^|; )1\\.57($|; )", p1$matched_sd_values) &&
   p1$stratum == "bp_ok_both" && p1$same_cluster_known == "no")

# ---- V7 known-cluster control: Sandra/Ofogbe --------------------------------
p2 <- get_pair("Ofogbe et al (2021)", "Sandra et al (2021)")
ok("V7  known-cluster pair labelled, not a new find",
   nrow(p2) == 1 && p2$same_cluster_known == "yes" && p2$stratum == "extended")

# ---- V8 structural sanity ---------------------------------------------------
ok("V8  no self-pairs; classes valid; a < b ordering",
   all(pairs$study_a != pairs$study_b) &&
   all(pairs$instrument_class %in% c("loan", "bond", "CDS")) &&
   all(pairs$study_a < pairs$study_b))

# ---- V9 independent recomputation ------------------------------------------
key <- paste(d$instrument_class, d$sd_printed, sep = "\r")
re <- list()
for (k in unique(key)) {
  sub <- d[key == k, ]
  sks <- sort(unique(sub$study_key))
  if (length(sks) < 2) next
  cmb <- combn(sks, 2)
  for (j in seq_len(ncol(cmb)))
    re[[length(re) + 1]] <- paste(sub$instrument_class[1],
                                  cmb[1, j], cmb[2, j], sep = "\r")
}
re_set <- sort(unique(unlist(re)))
csv_set <- sort(paste(pairs$instrument_class, pairs$study_a, pairs$study_b,
                      sep = "\r"))
ok("V9  independent recomputation matches pair set exactly",
   identical(re_set, csv_set))

# ---- V10 blindness ----------------------------------------------------------
banned <- "\\b(coefficient|t-stat|t-statistic|p-value|R-squared)\\b"
ok("V10 no regression vocabulary; no estimate columns",
   !any(grepl(banned, unlist(pairs), ignore.case = TRUE)) &&
   !any(grepl("est|effect|sd_bp", names(pairs))))

# ---- summary ----------------------------------------------------------------
cat("\n----------------------------------------------------------\n")
if (length(fails) == 0) {
  cat("VERIFIER 16: ALL CHECKS PASS\n")
} else {
  cat("VERIFIER 16: FAILURES\n"); cat(paste0("  - ", fails, collapse = "\n"), "\n")
  quit(status = 1L)
}
