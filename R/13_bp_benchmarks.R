# =============================================================================
# R/13_bp_benchmarks.R
# SD(COD) benchmark constants in basis points — DEC-012a / DEC-012b
#
# Purpose : Recompute, deterministically and from raw extraction output only,
#           the per-instrument scale constants used to translate the pooled
#           CER-COD correlation into basis points of cost of debt.
# Inputs  : data/benchmarks/raw/p1_rows*.csv      (extraction rows, 4 batches)
#           data/benchmarks/raw/p1_status*.csv    (coverage denominator)
# Outputs : data/benchmarks/p1_rows_merged.csv    (all rows + adjudication flags)
#           data/benchmarks/p1_constants.csv      (primary + sensitivity ladder)
#           data/benchmarks/p1_coverage.csv       (coverage per instrument class)
# Paired verifier: R/13_verify_outputs.R
#
# No external packages beyond `here`. No effect estimates are read anywhere in
# this pipeline; the inputs contain descriptive statistics only.
# =============================================================================

suppressPackageStartupMessages(library(here))

raw_dir <- here("data", "benchmarks", "raw")
out_dir <- here("data", "benchmarks")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- canonical column set --------------------------------------------------
# The CDS batch predates three columns (unit_resolution, data_basis,
# label_match); they are created empty so all batches share one schema.
CANON <- c("study_key", "instrument_class", "sd_printed", "unit_printed",
           "unit_resolution", "conversion_factor", "sd_bp", "mean_printed",
           "scale_transform", "scale_type", "data_basis", "label_match",
           "plausibility_flag", "source_pointer", "confidence", "note")

ROW_FILES <- c(CDS      = "p1_rows.csv",
               bond     = "p1_rows_bond.csv",
               loan     = "p1_rows_loan_AK.csv",
               loan     = "p1_rows_loan_LZ.csv")

STATUS_FILES <- c(CDS  = "p1_status.csv",
                  bond = "p1_status_bond.csv",
                  loan = "p1_status_loan_AK.csv",
                  loan = "p1_status_loan_LZ.csv")

read_csv_strict <- function(path) {
  if (!file.exists(path)) stop("missing input file: ", path)
  d <- read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM",
                colClasses = "character")
  d[] <- lapply(d, function(x) trimws(ifelse(is.na(x), "", x)))
  d
}

read_rows <- function(fname, cls) {
  d <- read_csv_strict(file.path(raw_dir, fname))
  for (cn in CANON) if (!cn %in% names(d)) d[[cn]] <- ""
  d <- d[, CANON, drop = FALSE]
  d$instrument_class[d$instrument_class == ""] <- cls
  d$source_batch <- fname
  d
}

rows <- do.call(rbind, Map(read_rows, ROW_FILES, names(ROW_FILES)))
rownames(rows) <- NULL

# ---- adjudications (DEC-012b) ----------------------------------------------
# Each exclusion carries its documented reason. Exclusions apply to the
# BENCHMARK ONLY; every affected study retains all of its effect sizes in the
# meta-analysis itself (see DEC-012b, Consequences).
adjudicate <- function(d) {
  r <- rep("", nrow(d))

  # (1) printed descriptives internally impossible -> row cannot be used
  r[grepl("^Azmi",      d$study_key)] <- "source table internally inconsistent (SD approx. equals full printed range; means outside own min-max)"
  r[grepl("^Cicchini",  d$study_key)] <- "source table internally inconsistent (SD incompatible with printed min/max at printed N)"
  r[grepl("^Zhou et al \\(2018\\)", d$study_key)] <- "printed SD approx. 33x the arithmetic maximum on the printed support"

  # (2) row is not the outcome variable coded in the corpus
  r[grepl("^Boermans", d$study_key) & d$scale_type == "bond_yield_level"] <-
    "yield level; the coded corpus outcome for this study is the spread"

  # (3) subsample selection under rule 8: keep the panel matching the
  #     estimation sample of the published article (N = 2,267)
  r[grepl("^Kleimeier", d$study_key) & substr(d$sd_bp, 1, 3) == "240"] <-
    "Panel A; Panel B corresponds to the published estimation sample"

  r
}
rows$excluded_reason <- adjudicate(rows)

num <- function(x) suppressWarnings(as.numeric(x))
rows$sd_bp_num   <- num(rows$sd_bp)
rows$mean_num    <- num(rows$mean_printed)
rows$sd_print_num <- num(rows$sd_printed)

usable <- rows[rows$excluded_reason == "" & !is.na(rows$sd_bp_num), ]

# ---- two-stage median (DEC-012b, ruling P1-Q1) -----------------------------
# Stage 1: median within study x instrument class (one value per study).
# Stage 2: median across studies within class. Equal weight per study; this is
# the only reading consistent with DEC-012a's "count of contributing studies".
two_stage <- function(d) {
  if (nrow(d) == 0) return(data.frame())
  key <- paste(d$study_key, d$instrument_class, sep = "\r")
  s1  <- tapply(d$sd_bp_num, key, median)
  cls <- sub("^.*\r", "", names(s1))
  data.frame(instrument_class = names(tapply(s1, cls, median)),
             median_sd_bp     = round(as.numeric(tapply(s1, cls, median)), 1),
             k_studies        = as.integer(tapply(s1, cls, length)),
             stringsAsFactors = FALSE)
}

is_spread <- function(d) d$scale_type %in% c("spread_over_benchmark", "cds_spread")

specs <- list(
  primary          = usable,
  spread_only      = usable[is_spread(usable), ],
  non_spread_only  = usable[!is_spread(usable), ],
  high_conf_only   = usable[usable$confidence == "high", ],
  unflagged_only   = usable[usable$plausibility_flag == "", ]
)

constants <- do.call(rbind, lapply(names(specs), function(nm) {
  x <- two_stage(specs[[nm]])
  if (nrow(x) == 0) return(NULL)
  cbind(spec = nm, x, stringsAsFactors = FALSE)
}))
constants <- constants[order(match(constants$spec, names(specs)),
                             match(constants$instrument_class, c("loan", "bond", "CDS"))), ]

# ---- lognormal sensitivity (DEC-012b, ruling P1-Q5) ------------------------
# For log-scale rows that report mu and sigma of the logged outcome, the raw
# scale SD under lognormality is exp(mu + sigma^2/2) * sqrt(exp(sigma^2) - 1).
# Reported as a LOWER BOUND: the single available validation case (Christ et
# al., which prints both scales) understates the printed raw SD by ~28%.
ln2raw <- function(mu, s) exp(mu + s^2 / 2) * sqrt(exp(s^2) - 1)

lg <- rows[rows$excluded_reason == "" &
           rows$scale_transform == "log" &
           !is.na(rows$mean_num) & !is.na(rows$sd_print_num) &
           rows$scale_type != "other", ]
if (nrow(lg) > 0) {
  lg$sd_bp_num <- ln2raw(lg$mean_num, lg$sd_print_num)
  # exclude implied levels outside the bp-plausible corridor (amount-scale
  # outcomes, e.g. logged currency amounts, are not rates)
  lg <- lg[lg$sd_bp_num > 10 & lg$sd_bp_num < 2000, ]
  lognormal <- two_stage(lg)
  if (nrow(lognormal) > 0) {
    constants <- rbind(constants,
                       cbind(spec = "lognormal_backtransform_lower_bound",
                             lognormal, stringsAsFactors = FALSE))
  }
}

# ---- coverage --------------------------------------------------------------
read_status <- function(fname, cls) {
  d <- read_csv_strict(file.path(raw_dir, fname))
  data.frame(instrument_class = cls, status = d$status, stringsAsFactors = FALSE)
}
status <- do.call(rbind, Map(read_status, STATUS_FILES, names(STATUS_FILES)))
cov_tab <- as.data.frame.matrix(table(status$instrument_class, status$status))
coverage <- data.frame(instrument_class = rownames(cov_tab), cov_tab,
                       stringsAsFactors = FALSE, check.names = FALSE)
coverage$eligible_cells   <- rowSums(cov_tab)
coverage$coverage_percent <- round(100 * coverage$bp_ok / coverage$eligible_cells, 1)
rownames(coverage) <- NULL

# ---- write -----------------------------------------------------------------
rows_out <- rows[, c(CANON, "source_batch", "excluded_reason")]
write.csv(rows_out,   file.path(out_dir, "p1_rows_merged.csv"), row.names = FALSE, na = "")
write.csv(constants,  file.path(out_dir, "p1_constants.csv"),   row.names = FALSE, na = "")
write.csv(coverage,   file.path(out_dir, "p1_coverage.csv"),    row.names = FALSE, na = "")

cat("\n== SD(COD) benchmark constants (basis points) ==\n")
print(constants, row.names = FALSE)
cat("\n== Coverage ==\n")
print(coverage, row.names = FALSE)
cat("\nRows total:", nrow(rows),
    "| excluded by adjudication:", sum(rows$excluded_reason != ""),
    "| usable:", nrow(usable), "\n")
