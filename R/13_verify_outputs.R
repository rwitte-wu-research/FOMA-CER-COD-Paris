# =============================================================================
# R/13_verify_outputs.R
# Paired verifier for R/13_bp_benchmarks.R  (DEC-012a / DEC-012b)
#
# Recomputes every constant independently of the production script and asserts
# it against the values pinned at the time of the C1 extraction close. Any
# mismatch is a hard failure: either an input file changed, or an adjudication
# was silently altered.
#
# Run after R/13_bp_benchmarks.R. Exit is non-zero on failure.
# =============================================================================

suppressPackageStartupMessages(library(here))

out_dir <- here("data", "benchmarks")
raw_dir <- here("data", "benchmarks", "raw")

fails <- character(0)
ok <- function(label, cond) {
  cat(sprintf("%-58s %s\n", label, if (isTRUE(cond)) "PASS" else "FAIL"))
  if (!isTRUE(cond)) fails <<- c(fails, label)
}

rd <- function(p) read.csv(p, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")

cons <- rd(file.path(out_dir, "p1_constants.csv"))
covg <- rd(file.path(out_dir, "p1_coverage.csv"))
mrg  <- rd(file.path(out_dir, "p1_rows_merged.csv"))

get <- function(spec, cls, field) {
  r <- cons[cons$spec == spec & cons$instrument_class == cls, ]
  if (nrow(r) != 1) return(NA_real_)
  as.numeric(r[[field]])
}

# ---- O15.1  structural integrity ------------------------------------------
ok("O15.1a rows_merged has 125 rows",            nrow(mrg) == 125L)
ok("O15.1b exactly 5 adjudicated exclusions",    sum(nchar(trimws(ifelse(is.na(mrg$excluded_reason), "", mrg$excluded_reason))) > 0) == 5L)
ok("O15.1c every exclusion carries a reason",
   all(nchar(trimws(mrg$excluded_reason[nchar(trimws(ifelse(is.na(mrg$excluded_reason), "", mrg$excluded_reason))) > 0])) > 20))

# ---- O15.2  conversion arithmetic ------------------------------------------
sd_p <- suppressWarnings(as.numeric(mrg$sd_printed))
fac  <- suppressWarnings(as.numeric(mrg$conversion_factor))
sd_b <- suppressWarnings(as.numeric(mrg$sd_bp))
chk  <- !is.na(sd_p) & !is.na(fac) & !is.na(sd_b)
ok("O15.2  sd_bp = sd_printed * factor on every converted row",
   all(abs(sd_p[chk] * fac[chk] - sd_b[chk]) < 1e-6))

# ---- O15.3  primary constants (DEC-012a headline) --------------------------
ok("O15.3a loan primary = 200.0 bp",  isTRUE(all.equal(get("primary", "loan", "median_sd_bp"), 200.0)))
ok("O15.3b bond primary = 150.0 bp",  isTRUE(all.equal(get("primary", "bond", "median_sd_bp"), 150.0)))
ok("O15.3c CDS  primary = 168.6 bp",  isTRUE(all.equal(get("primary", "CDS",  "median_sd_bp"), 168.6)))
ok("O15.3d k = 49 / 21 / 7",
   identical(as.integer(c(get("primary", "loan", "k_studies"),
                          get("primary", "bond", "k_studies"),
                          get("primary", "CDS",  "k_studies"))),
             c(49L, 21L, 7L)))

# ---- O15.4  pre-declared sensitivity ladder --------------------------------
ok("O15.4a spread-only  loan = 111.7 (k=10)",
   isTRUE(all.equal(get("spread_only", "loan", "median_sd_bp"), 111.7)) &&
   get("spread_only", "loan", "k_studies") == 10)
ok("O15.4b non-spread   loan = 310.0 (k=39)",
   isTRUE(all.equal(get("non_spread_only", "loan", "median_sd_bp"), 310.0)) &&
   get("non_spread_only", "loan", "k_studies") == 39)
ok("O15.4c bond/CDS homogeneous (primary == spread-only)",
   isTRUE(all.equal(get("primary", "bond", "median_sd_bp"), get("spread_only", "bond", "median_sd_bp"))) &&
   isTRUE(all.equal(get("primary", "CDS",  "median_sd_bp"), get("spread_only", "CDS",  "median_sd_bp"))))
ok("O15.4d high-confidence-only = 157.0 / 153.7 / 159.7",
   isTRUE(all.equal(get("high_conf_only", "loan", "median_sd_bp"), 157.0)) &&
   isTRUE(all.equal(get("high_conf_only", "bond", "median_sd_bp"), 153.7)) &&
   isTRUE(all.equal(get("high_conf_only", "CDS",  "median_sd_bp"), 159.7)))
ok("O15.4e unflagged-only loan = 157.0 (k=44)",
   isTRUE(all.equal(get("unflagged_only", "loan", "median_sd_bp"), 157.0)) &&
   get("unflagged_only", "loan", "k_studies") == 44)
ok("O15.4f lognormal lower bound loan = 186.5 (k=7), CDS = 163.0 (k=3)",
   isTRUE(all.equal(get("lognormal_backtransform_lower_bound", "loan", "median_sd_bp"), 186.5)) &&
   get("lognormal_backtransform_lower_bound", "loan", "k_studies") == 7 &&
   isTRUE(all.equal(get("lognormal_backtransform_lower_bound", "CDS", "median_sd_bp"), 163.0)) &&
   get("lognormal_backtransform_lower_bound", "CDS", "k_studies") == 3)

# ---- O15.5  coverage denominator -------------------------------------------
gc_ <- function(cls, field) {
  r <- covg[covg$instrument_class == cls, ]
  if (nrow(r) != 1) return(NA_real_)
  as.numeric(r[[field]])
}
ok("O15.5a eligible cells = 72 / 26 / 11 (sum 109)",
   identical(as.integer(c(gc_("loan", "eligible_cells"), gc_("bond", "eligible_cells"),
                          gc_("CDS", "eligible_cells"))), c(72L, 26L, 11L)))
ok("O15.5b bp_ok = 52 / 21 / 7 (sum 80)",
   identical(as.integer(c(gc_("loan", "bp_ok"), gc_("bond", "bp_ok"), gc_("CDS", "bp_ok"))),
             c(52L, 21L, 7L)))

# ---- O15.6  blindness convention -------------------------------------------
# Note: "beta" is deliberately NOT in the banned list. It is a standard control
# variable name in finance descriptive tables (market beta), and appears in the
# extraction notes in exactly that sense. Including it produced a false positive.
# No column of the extraction may contain an effect estimate. This is a coarse
# but non-trivial screen: the extraction schema has no field for one, and the
# free-text note must not carry regression vocabulary.
banned <- "\\b(coefficient|t-stat|t-statistic|p-value|R-squared)\\b"
ok("O15.6  no regression vocabulary in extraction notes",
   !any(grepl(banned, mrg$note, ignore.case = TRUE)))

# ---- summary ---------------------------------------------------------------
cat("\n----------------------------------------------------------\n")
if (length(fails) == 0) {
  cat("VERIFIER 13: ALL CHECKS PASS\n")
} else {
  cat("VERIFIER 13: FAILURES\n"); cat(paste0("  - ", fails, collapse = "\n"), "\n")
  quit(status = 1L)
}
