# =============================================================================
# R/16_fingerprint_screen.R
# Descriptive fingerprint screen for within-corpus sample overlap
# (SUBMISSION_READINESS Item 19; systemic follow-up to ERROR #58)
#
# Purpose : Flag pairs of DIFFERENT studies in the SAME instrument class whose
#           primary papers print an identical standard deviation of the
#           cost-of-debt outcome (exact printed-string match). Output is a
#           PAIR LIST FOR ADJUDICATION — no verdicts, no merges, no refits.
#           New finds go through the F2 mechanics (own data-DEC per pair in
#           the S1 merge commit); the hub adjudicates.
# Inputs  : data/benchmarks/p1_rows_merged.csv   (committed, d30e0d8)
#           data/benchmarks/p1_coverage.csv      (registered scope anchor)
#           data/benchmarks/raw/p1_status*.csv   (per-cell status for strata)
# Output  : data/benchmarks/p1_fingerprint_pairs.csv + console summary
# Paired verifier: R/16_verify_outputs.R
#
# Result-blindness: this screen reads printed DESCRIPTIVE strings only
# (sd_printed, mean_printed, units, pointers, statuses). No effect estimate,
# no sd_bp value, no v12 access, no model object is touched anywhere.
#
# Scope reconciliation (Item 19 wording vs. instrument reach): the registered
# scope is the 80 bp_ok cells; the fingerprint instrument additionally reaches
# every further cell with at least one extracted printed-SD row (log/std/
# unclear strata). Both are screened; pairs are labelled by stratum. Cells
# without any printed row remain unscreened and are disclosed.
# =============================================================================

suppressPackageStartupMessages(library(here))

bm_dir  <- here("data", "benchmarks")
raw_dir <- file.path(bm_dir, "raw")

# Known multi-study cluster (DEC-042a: "one multi-study cluster: Sandra/
# Ofogbe"). Pairs entirely inside this set are labelled, not new finds.
KNOWN_SAME_CLUSTER <- c("Sandra et al (2021)", "Ofogbe et al (2021)")

read_csv_strict <- function(path) {
  if (!file.exists(path)) stop("missing input file: ", path)
  d <- read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM",
                colClasses = "character")
  d[] <- lapply(d, function(x) trimws(ifelse(is.na(x), "", x)))
  d
}

rows <- read_csv_strict(file.path(bm_dir, "p1_rows_merged.csv"))
covg <- read.csv(file.path(bm_dir, "p1_coverage.csv"),
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")

# ---- per-cell status lookup (registered denominators) -----------------------
STATUS_FILES <- c(CDS  = "p1_status.csv",
                  bond = "p1_status_bond.csv",
                  loan = "p1_status_loan_AK.csv",
                  loan = "p1_status_loan_LZ.csv")
status_lu <- do.call(rbind, Map(function(f, cls) {
  d <- read_csv_strict(file.path(raw_dir, f))
  data.frame(instrument_class = cls, study_key = d$study_key,
             status = d$status, stringsAsFactors = FALSE)
}, STATUS_FILES, names(STATUS_FILES)))
get_status <- function(cls, sk) {
  v <- status_lu$status[status_lu$instrument_class == cls &
                        status_lu$study_key == sk]
  if (length(v) == 1) v else paste(unique(v), collapse = "|")
}

# ---- fingerprint match ------------------------------------------------------
d <- rows[nchar(rows$sd_printed) > 0,
          c("study_key", "instrument_class", "sd_printed", "unit_printed",
            "mean_printed", "source_pointer")]

cells <- unique(d[, c("instrument_class", "study_key")])

sig_digits <- function(s) nchar(sub("^0+", "", gsub("[^0-9]", "", s)))

key <- paste(d$instrument_class, d$sd_printed, sep = "\r")
pair_rows <- list()
for (k in unique(key)) {
  sub <- d[key == k, , drop = FALSE]
  sks <- sort(unique(sub$study_key))
  if (length(sks) < 2) next
  cls <- sub$instrument_class[1]; sdv <- sub$sd_printed[1]
  cmb <- combn(sks, 2)
  for (j in seq_len(ncol(cmb))) {
    a <- cmb[1, j]; b <- cmb[2, j]
    pair_rows[[length(pair_rows) + 1]] <-
      data.frame(instrument_class = cls, study_a = a, study_b = b,
                 sd_value = sdv, stringsAsFactors = FALSE)
  }
}
pr <- do.call(rbind, pair_rows)

# aggregate to one row per (class, a, b)
agg_field <- function(cls, sk, sdvals, col) {
  m <- d[d$instrument_class == cls & d$study_key == sk &
         d$sd_printed %in% sdvals, col]
  paste(unique(m[nchar(m) > 0]), collapse = " | ")
}

pk <- unique(pr[, c("instrument_class", "study_a", "study_b")])
out <- do.call(rbind, lapply(seq_len(nrow(pk)), function(i) {
  cls <- pk$instrument_class[i]; a <- pk$study_a[i]; b <- pk$study_b[i]
  sdv <- sort(unique(pr$sd_value[pr$instrument_class == cls &
                                 pr$study_a == a & pr$study_b == b]))
  mean_a <- unique(d$mean_printed[d$instrument_class == cls & d$study_key == a &
                                  d$sd_printed %in% sdv & nchar(d$mean_printed) > 0])
  mean_b <- unique(d$mean_printed[d$instrument_class == cls & d$study_key == b &
                                  d$sd_printed %in% sdv & nchar(d$mean_printed) > 0])
  mean_match <- if (length(mean_a) == 0 && length(mean_b) == 0) "na"
                else if (length(intersect(mean_a, mean_b)) > 0) "yes" else "no"
  st_a <- get_status(cls, a); st_b <- get_status(cls, b)
  data.frame(
    instrument_class  = cls, study_a = a, study_b = b,
    matched_sd_values = paste(sdv, collapse = "; "),
    n_matching_values = length(sdv),
    sig_digits_max    = max(vapply(sdv, sig_digits, integer(1))),
    unit_a = agg_field(cls, a, sdv, "unit_printed"),
    unit_b = agg_field(cls, b, sdv, "unit_printed"),
    mean_match = mean_match,
    stratum = if (st_a == "bp_ok" && st_b == "bp_ok") "bp_ok_both" else "extended",
    same_cluster_known = if (a %in% KNOWN_SAME_CLUSTER &&
                             b %in% KNOWN_SAME_CLUSTER) "yes" else "no",
    status_a = st_a, status_b = st_b,
    source_pointer_a = agg_field(cls, a, sdv, "source_pointer"),
    source_pointer_b = agg_field(cls, b, sdv, "source_pointer"),
    stringsAsFactors = FALSE)
}))
cls_order <- c(loan = 1L, bond = 2L, CDS = 3L)
out <- out[order(cls_order[out$instrument_class], out$study_a, out$study_b), ]
rownames(out) <- NULL

write.csv(out, file.path(bm_dir, "p1_fingerprint_pairs.csv"),
          row.names = FALSE, na = "")

# ---- console summary --------------------------------------------------------
cc <- table(cells$instrument_class)
bp_ok_cells <- sum(as.integer(covg$bp_ok))
cat("\n== Fingerprint screen (Item 19 / ERROR #58 follow-up) ==\n")
cat(sprintf("Rows read: %d | row-bearing cells: %d (loan %d / bond %d / CDS %d)\n",
            nrow(rows), nrow(cells), cc["loan"], cc["bond"], cc["CDS"]))
cat(sprintf("Registered scope: %d bp_ok cells fully screened; extended sweep: %d further row-bearing cells; %d cells without printed rows remain unscreened (disclosed).\n",
            bp_ok_cells, nrow(cells) - bp_ok_cells, 109L - nrow(cells)))
cat(sprintf("Pairs found: %d (bp_ok_both %d / extended %d; known-cluster pairs %d)\n\n",
            nrow(out), sum(out$stratum == "bp_ok_both"),
            sum(out$stratum == "extended"), sum(out$same_cluster_known == "yes")))
print(out[, c("instrument_class", "study_a", "study_b", "matched_sd_values",
              "sig_digits_max", "mean_match", "stratum", "same_cluster_known")],
      row.names = FALSE)
cat("\nNo verdicts issued. Pair list for hub adjudication; new finds follow the F2 mechanics (own data-DEC per pair, S1 merge commit).\n")
