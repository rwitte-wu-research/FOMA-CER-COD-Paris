# =============================================================================
# 01_prep.R — provisional analysis-ready dataset (T0.4)
# Reads the raw effect-size database, renames to snake_case, derives the
# Fisher-z effect-size metric, the effect id, the Paris pre/post codings, the
# continuous time axis (publication year, E8 interim), the categorical
# moderators, and carries regulation as raw (E9 deferred). Surfaces — does NOT
# resolve — the four data-integrity items that need Volker's extraction sheet
# (F1 extremes, F2 non-integer n, F3 n<10, F4 regulation semantics).
#
# Decision basis: DEC-002, DEC-005, DEC-013, DEC-015; analysis_plan.md §1-3,6,9.
# Pending baked in (confirm/override): E8 (time = publication year),
# E9 (regulation deferred), n-coding rule (Volker — F2).
#
# Output (data/processed is gitignored): cer_cod_prepared.rds + .csv mirror.
# docs/data_dictionary.md (committed) documents every derived column + F1-F4.
# =============================================================================

# SECTION 1 — Environment -------------------------------------------------------
# setup.R loads the lockfile-pinned package set (readxl/readr/tidyverse/here);
# we never re-library() ad hoc so the analysis layer shares one namespace.
source(here::here("setup.R"))

# SECTION 2 — Constants ---------------------------------------------------------
# Every expected shape/count is named here (no magic numbers downstream) so the
# hard-asserts read as a contract against the raw extraction.

# The on-disk filename retains the project's COD label; the analysis plan's
# `FOMA_CERCOE_Data_v1.xlsx` is the historical name for this same file.
RAW_XLSX   <- here::here("data", "CER-COD_data_v1.xlsx")
RAW_SHEET  <- "Tabelle1"

EXPECT_ROWS    <- 1306L      # effect sizes
EXPECT_COLS    <- 17L        # source columns
EXPECT_STUDIES <- 66L        # distinct `study`

YEAR_MIN <- 2010L            # publication-year plausibility window (E8)
YEAR_MAX <- 2024L

# Near-perfect |r| that flags a likely extraction/sign error (DEC-013). Both
# known extremes sit just under 1, so |r| < 1 holds for ALL rows — this is the
# *flag* threshold, not a validity bound.
EXTREME_R_FLAG <- 0.99

N_FRACTIONAL_THRESH <- 1e-9  # tolerance for "n is not an integer" (F2)
N_SMALL_THRESH      <- 10L    # fragile-vz cutoff (F3)
FISHER_VAR_DF       <- 3L     # vz = 1/(n - 3): Fisher-z large-sample variance

# Expected category level counts — asserted so a silent recode error stops the
# run rather than propagating a mislabelled moderator into every model.
EXPECT_ES   <- c(bivariate = 1270L, partial = 36L)                 # ES_measure B/P
EXPECT_CER  <- c(Performance = 1063L, Disclosure = 243L)
EXPECT_COD  <- c(interest = 631L, rating = 300L,
                 yields = 233L, derivativ = 142L)
EXPECT_IND  <- c(`1` = 185L, `0` = 1121L)                          # 1 = sensitive
EXPECT_JQ   <- c(HIGH = 551L, LOW = 755L)

# Expected pre/post splits per coding (post / pre). Headline = end_lag0.
EXPECT_PARIS <- list(
  end_lag0 = c(post = 728L, pre = 578L),   # HEADLINE (DEC-005)
  lag1     = c(post = 562L, pre = 744L),
  lag2     = c(post = 506L, pre = 800L),
  lag3     = c(post = 252L, pre = 1054L),
  median   = c(post = 686L, pre = 620L),
  mean     = c(post = 945L, pre = 361L)
)

# SECTION 3 — Helpers -----------------------------------------------------------
# stop_unless(): a named hard-assert. We fail loudly at prep time because every
# downstream model trusts these invariants without re-checking them.
stop_unless <- function(cond, msg) {
  if (!isTRUE(cond)) stop("[01_prep] assertion failed: ", msg, call. = FALSE)
  invisible(TRUE)
}

# recode_bin(): map a two-label character column to 0/1 integer and guarantee
# the recode is *bijective* — every raw value must be one of the two expected
# labels (no third level, no NA leaks in), so the 0/1 counts equal the raw
# label counts by construction. Stops otherwise.
recode_bin <- function(x, one_label, zero_label, what) {
  stopifnot(length(one_label) == 1L, length(zero_label) == 1L)
  unknown <- setdiff(unique(x), c(one_label, zero_label))
  stop_unless(length(unknown) == 0L,
              sprintf("%s has unexpected label(s): %s",
                      what, paste(unknown, collapse = ", ")))
  out <- if_else(x == one_label, 1L, 0L)
  # Bijection check: recoded 1s/0s must equal the raw label tallies exactly.
  stop_unless(sum(out == 1L) == sum(x == one_label) &&
              sum(out == 0L) == sum(x == zero_label),
              sprintf("%s recode not bijective vs raw labels", what))
  out
}

# expect_counts(): assert a factor's level tally equals a named constant vector.
expect_counts <- function(x, expected, what) {
  obs <- table(x)
  for (lvl in names(expected)) {
    got <- if (lvl %in% names(obs)) as.integer(obs[[lvl]]) else 0L
    stop_unless(got == expected[[lvl]],
                sprintf("%s level '%s': got %d, expected %d",
                        what, lvl, got, expected[[lvl]]))
  }
  # No extra, unexpected levels.
  stop_unless(setequal(names(obs), names(expected)),
              sprintf("%s has unexpected levels: %s", what,
                      paste(setdiff(names(obs), names(expected)),
                            collapse = ", ")))
  invisible(TRUE)
}

# SECTION 4 — Read + shape asserts ----------------------------------------------
# Hard-assert the raw shape BEFORE any transformation: 1306×17, 66 studies.
raw <- readxl::read_excel(RAW_XLSX, sheet = RAW_SHEET)

stop_unless(nrow(raw) == EXPECT_ROWS,
            sprintf("row count %d != %d", nrow(raw), EXPECT_ROWS))
stop_unless(ncol(raw) == EXPECT_COLS,
            sprintf("col count %d != %d", ncol(raw), EXPECT_COLS))
stop_unless(dplyr::n_distinct(raw$study) == EXPECT_STUDIES,
            sprintf("distinct studies %d != %d",
                    dplyr::n_distinct(raw$study), EXPECT_STUDIES))

# SECTION 5 — Rename to snake_case ----------------------------------------------
# Source names carry embedded spaces (`event_sample end_lag0`, ...); rename once
# here so nothing downstream needs backticks. Map per the T0.4 spec.
dat <- raw |>
  dplyr::rename(
    study           = "study",
    outcome_id      = "outcome",
    r               = "corr",
    n               = "sample",
    paris_end_lag0  = "event_sample end_lag0",
    paris_end_lag1  = "event_sample end_lag1",
    paris_end_lag2  = "event_sample end_lag2",
    paris_end_lag3  = "event_sample end_lag3",
    paris_median    = "event_sample median_lag0",
    paris_mean      = "event_sample mean_lag0",
    cod_measure     = "COD_measure",
    cer_measure     = "CER_measure",
    es_measure      = "ES_measure",
    industry        = "industry",
    regulation_start = "regulation_start",
    regulation_end   = "regulation_end",
    journal_q       = "journal_q"
  )

# SECTION 6 — Effect-size metric [plan §2, DEC-015] -----------------------------
# Fisher's z stabilises the variance of r; vz uses n AS CODED. We deliberately
# do NOT touch n — the non-integer-n issue (F2) is a flag for the Volker check,
# and resolving the n-rule is a future re-prep, not this script. min(n-3) ≈ 2.56
# (> 0), so vz is finite and strictly positive throughout.
dat <- dat |>
  dplyr::mutate(
    z   = atanh(r),
    vz  = 1 / (n - FISHER_VAR_DF),
    sez = sqrt(vz)
  )

# |r| < 1 for every row (both known extremes sit just under 1, DEC-013). Assert
# the strict bound for ALL rows — it holds; the extremes are flagged separately.
stop_unless(all(abs(dat$r) < 1), "some |r| >= 1 (atanh would be non-finite)")
stop_unless(all(is.finite(dat$z)) && all(is.finite(dat$vz)) && all(dat$vz > 0),
            "z/vz not all finite & positive")

# SECTION 7 — Effect id [plan §3.1] ---------------------------------------------
# Global unique id for the `~ 1 | study/esid` random structure (DEC-002).
dat <- dat |> dplyr::mutate(esid = seq_len(dplyr::n()))

# SECTION 8 — Paris pre/post coding [plan §6, DEC-005] --------------------------
# Headline = end_lag0 ("1_Post"/"0_Pre"). Lag1-3 share that label scheme; the
# median/mean window codings use bare "Post"/"Pre". Each recode is bijective.
dat <- dat |>
  dplyr::mutate(
    post_paris  = recode_bin(paris_end_lag0, "1_Post", "0_Pre", "paris_end_lag0"),
    post_lag1   = recode_bin(paris_end_lag1, "1_Post", "0_Pre", "paris_end_lag1"),
    post_lag2   = recode_bin(paris_end_lag2, "1_Post", "0_Pre", "paris_end_lag2"),
    post_lag3   = recode_bin(paris_end_lag3, "1_Post", "0_Pre", "paris_end_lag3"),
    post_median = recode_bin(paris_median,   "Post",   "Pre",   "paris_median"),
    post_mean   = recode_bin(paris_mean,     "Post",   "Pre",   "paris_mean")
  )

# Cross-check the headline + variant splits against the expected constants.
stop_unless(sum(dat$post_paris)  == EXPECT_PARIS$end_lag0[["post"]], "post_paris split")
stop_unless(sum(dat$post_lag1)   == EXPECT_PARIS$lag1[["post"]],     "post_lag1 split")
stop_unless(sum(dat$post_lag2)   == EXPECT_PARIS$lag2[["post"]],     "post_lag2 split")
stop_unless(sum(dat$post_lag3)   == EXPECT_PARIS$lag3[["post"]],     "post_lag3 split")
stop_unless(sum(dat$post_median) == EXPECT_PARIS$median[["post"]],   "post_median split")
stop_unless(sum(dat$post_mean)   == EXPECT_PARIS$mean[["post"]],     "post_mean split")

# SECTION 9 — Continuous time axis [E8 — interim] -------------------------------
# Publication year parsed from the "(YYYY)" tag in `study`. This is the INTERIM
# time axis (E8): the identification-grade SAMPLE year (plan §4, T8 Moves 1-2)
# stays gated until Volker's sample years arrive. We retain BOTH the raw
# uncentred `pub_year` and a provisional `pub_year_c`. The centring here (by the
# effect-level mean) is NOT the locked definitive centring — that choice is
# deferred to T8, which may recentre. Keeping the raw column lets T8 recentre
# without a re-prep.
dat <- dat |>
  dplyr::mutate(pub_year = as.integer(stringr::str_match(study, "\\((\\d{4})")[, 2]))

stop_unless(all(!is.na(dat$pub_year)), "some study has no parseable (YYYY) year")
stop_unless(all(dat$pub_year >= YEAR_MIN & dat$pub_year <= YEAR_MAX),
            sprintf("pub_year outside [%d, %d]", YEAR_MIN, YEAR_MAX))
# Per-study resolution check: all 66 studies map to a single year in range.
stop_unless(dplyr::n_distinct(dat$study[is.na(dat$pub_year)]) == 0L,
            "unresolved study-year present")

pub_year_mean <- mean(dat$pub_year)          # provisional centring constant (T8 may recentre)
dat <- dat |> dplyr::mutate(pub_year_c = pub_year - pub_year_mean)

# SECTION 10 — Categorical moderators [plan §3] ---------------------------------
# Recode to interpretable factors/integers, then assert each level tally equals
# its constant. es_type/cer_type/cod_instrument as labelled factors; the binary
# moderators as 0/1 integers (sensitive_industry: 1 = sensitive [confirm];
# journal_high: HIGH = 1).
dat <- dat |>
  dplyr::mutate(
    es_type        = factor(dplyr::recode(es_measure, B = "bivariate", P = "partial"),
                            levels = c("bivariate", "partial")),
    cer_type       = factor(cer_measure, levels = c("Performance", "Disclosure")),
    cod_instrument = factor(cod_measure,
                            levels = c("interest", "rating", "yields", "derivativ")),
    sensitive_industry = as.integer(industry),     # 1 = sensitive (confirm)
    journal_high       = if_else(journal_q == "HIGH", 1L, 0L)
  )

expect_counts(dat$es_type, c(bivariate = EXPECT_ES[["bivariate"]],
                             partial   = EXPECT_ES[["partial"]]), "es_type")
expect_counts(dat$cer_type, EXPECT_CER, "cer_type")
expect_counts(dat$cod_instrument, EXPECT_COD, "cod_instrument")
stop_unless(sum(dat$sensitive_industry == 1L) == EXPECT_IND[["1"]] &&
            sum(dat$sensitive_industry == 0L) == EXPECT_IND[["0"]],
            "sensitive_industry split")
stop_unless(sum(dat$journal_high == 1L) == EXPECT_JQ[["HIGH"]] &&
            sum(dat$journal_high == 0L) == EXPECT_JQ[["LOW"]],
            "journal_high split")

# SECTION 11 — Regulation, raw [E9 — pending Volker] ----------------------------
# Carry regulation_start/_end as RAW factors only. The 0/1/9/NA semantics are
# unknown (F4), so we do NOT construct a regulation moderator yet (plan §7).
# regulation_end is numeric (0/1/9); regulation_start is character incl. literal
# "NA" — factor() both as-is to preserve their raw value vocabulary.
dat <- dat |>
  dplyr::mutate(
    regulation_start = factor(as.character(regulation_start)),
    regulation_end   = factor(as.character(regulation_end))
  )

# SECTION 12 — Data-integrity flags [DEC-013, DEC-015] --------------------------
# These do not alter the data; they quantify what the verifier surfaces and what
# the dictionary records for the Volker extraction check.
flag_extreme <- dat |>
  dplyr::filter(abs(r) > EXTREME_R_FLAG) |>
  dplyr::select(esid, study, r, n)                                   # F1

is_fractional <- abs(dat$n - round(dat$n)) > N_FRACTIONAL_THRESH
n_fractional  <- sum(is_fractional)                                  # F2
n_small       <- sum(dat$n < N_SMALL_THRESH)                        # F3
small_rows    <- dat |>
  dplyr::filter(n < N_SMALL_THRESH) |>
  dplyr::arrange(n) |>
  dplyr::select(esid, study, r, n)

# SECTION 13 — n-distribution [DEC-015] -----------------------------------------
n_stats <- list(
  median   = median(dat$n),
  q25      = unname(quantile(dat$n, 0.25)),
  q75      = unname(quantile(dat$n, 0.75)),
  min      = min(dat$n),
  max      = max(dat$n),
  share_lt200 = mean(dat$n < 200),
  count_lt100 = sum(dat$n < 100)
)

# SECTION 14 — Write processed dataset ------------------------------------------
# data/processed/ is gitignored (Setup §5): rds is the analysis input, csv the
# human-readable mirror. dir is part of the repo scaffold; create if missing.
proc_dir <- here::here("data", "processed")
if (!dir.exists(proc_dir)) dir.create(proc_dir, recursive = TRUE)
rds_path <- file.path(proc_dir, "cer_cod_prepared.rds")
csv_path <- file.path(proc_dir, "cer_cod_prepared.csv")
saveRDS(dat, rds_path)
readr::write_csv(dat, csv_path)

# SECTION 15 — Data dictionary (committed) --------------------------------------
# Built from the live objects so every number in the doc is the number just
# written. Documents each derived column + the four flags F1-F4.
dict_path <- here::here("docs", "data_dictionary.md")

fmt_rows <- function(df) {
  apply(df, 1, function(row)
    sprintf("| %s | %s | %s | %s |",
            row[["esid"]], row[["study"]],
            formatC(as.numeric(row[["r"]]), format = "f", digits = 4),
            formatC(as.numeric(row[["n"]]), format = "f", digits = 4)))
}

dict <- c(
  "# Data Dictionary — `cer_cod_prepared` (T0.4)",
  "",
  "Provisional analysis-ready dataset produced by [`R/01_prep.R`](../R/01_prep.R)",
  "from `data/CER-COD_data_v1.xlsx` (sheet `Tabelle1`). The processed files",
  "(`data/processed/cer_cod_prepared.{rds,csv}`) are gitignored; this dictionary",
  "is committed. Decision basis: DEC-002, DEC-005, DEC-013, DEC-015;",
  "analysis_plan.md §1–§3, §6, §9.",
  "",
  sprintf("**Shape:** %d effect sizes × %d columns, %d studies. No rows dropped.",
          nrow(dat), ncol(dat), dplyr::n_distinct(dat$study)),
  "",
  "## Columns",
  "",
  "| column | type | derivation / meaning |",
  "|---|---|---|",
  "| `study` | chr | Study label incl. `(YYYY)` publication tag (cluster id). |",
  "| `outcome_id` | num | Within-source outcome index (raw `outcome`). |",
  "| `r` | num | Reported correlation (raw `corr`); **unaltered**. |",
  "| `n` | num | Sample size as coded (raw `sample`); **unaltered** — see F2. |",
  "| `z` | num | Fisher's z = `atanh(r)` [plan §2]. |",
  "| `vz` | num | Sampling variance = `1/(n-3)` on n as coded. |",
  "| `sez` | num | `sqrt(vz)` (used by FAT-PET-PEESE, plan §8). |",
  "| `esid` | int | Global effect id for `~ 1 | study/esid` [DEC-002]. |",
  "| `paris_end_lag0..3` | chr | Raw end-window Paris labels (`1_Post`/`0_Pre`). |",
  "| `paris_median`,`paris_mean` | chr | Raw window-midpoint labels (`Post`/`Pre`). |",
  "| `post_paris` | int | **HEADLINE** 0/1 from `paris_end_lag0` [DEC-005]. |",
  "| `post_lag1..3` | int | 0/1 lag variants (coding-sensitivity panel). |",
  "| `post_median`,`post_mean` | int | 0/1 window-midpoint variants. |",
  "| `pub_year` | int | Publication year parsed from `study`; raw uncentred (E8 interim axis). |",
  sprintf("| `pub_year_c` | num | **Provisional** centring: `pub_year` − %.3f (effect-level mean). Centring is **not locked** — definitive centring deferred to T8, which may recentre; the raw `pub_year` is retained so T8 can recentre without a re-prep. |", pub_year_mean),
  "| `es_type` | fct | `bivariate`/`partial` (raw `ES_measure` B/P) [DEC-004]. |",
  "| `cer_type` | fct | `Performance`/`Disclosure` (raw `CER_measure`). |",
  "| `cod_instrument` | fct | `interest`/`rating`/`yields`/`derivativ`. |",
  "| `sensitive_industry` | int | 1 = sensitive, 0 = not (raw `industry`). |",
  "| `journal_high` | int | 1 = HIGH, 0 = LOW (raw `journal_q`). |",
  "| `regulation_start` | fct | Raw `0/1/9/NA` — semantics deferred (F4, E9). |",
  "| `regulation_end` | fct | Raw `0/1/9` — semantics deferred (F4, E9). |",
  "",
  "## n-distribution [DEC-015]",
  "",
  sprintf("- Median n = **%.2f**; IQR ≈ [%.2f, %.2f]; min = %.4f, max = %.0f.",
          n_stats$median, n_stats$q25, n_stats$q75, n_stats$min, n_stats$max),
  sprintf("- Share n < 200 = **%.1f%%**; count n < 100 = %d.",
          100 * n_stats$share_lt200, n_stats$count_lt100),
  "",
  "## Data-integrity flags (for the Volker extraction check)",
  "",
  "### F1 — near-perfect extremes [DEC-013]",
  "Implausible CER–COD correlations → source-verify (do **not** drop):",
  "",
  "| esid | study | r | n |",
  "|---|---|---|---|",
  fmt_rows(flag_extreme),
  "",
  "### F2 — non-integer n (n-derivation rule unknown)",
  sprintf("**%d/%d (%.1f%%)** effects carry a fractional `n` (ratio-like → likely a",
          n_fractional, nrow(dat), 100 * n_fractional / nrow(dat)),
  "study total split across effects). **Volker: what is the n-derivation rule?**",
  "Until resolved, T1 inverse-variance weights are provisional.",
  "",
  "### F3 — n < 10 (fragile variance)",
  sprintf("**%d** effects have n < %d → `vz = 1/(n-3)` is fragile. Smallest first:",
          n_small, N_SMALL_THRESH),
  "",
  "| esid | study | r | n |",
  "|---|---|---|---|",
  fmt_rows(small_rows),
  "",
  "### F4 — regulation semantics unknown [E9]",
  "`regulation_start`/`regulation_end` carry raw `0/1/9/NA`; the direction/",
  "meaning is undefined, so **no regulation moderator is constructed** (plan §7).",
  "Resolution gated on Volker (E9).",
  "",
  "## Carved out — gated, NOT in this dataset",
  "- **Sample-year `year_c`** (identification time axis, plan §4 / T8 Moves 1–2)",
  "  — gated until Volker's sample years arrive; `pub_year` is the interim axis.",
  "- **Regulation moderator** (plan §7) — gated until E9 (F4).",
  "- **T1 weight trust** — provisional until F2 (n-rule) is resolved.",
  ""
)
writeLines(dict, dict_path)

# SECTION 16 — Console summary --------------------------------------------------
cat(strrep("=", 80), "\n", sep = "")
cat("01_prep.R — provisional analysis-ready dataset written\n")
cat(strrep("=", 80), "\n", sep = "")
cat(sprintf("rows x cols : %d x %d   (studies: %d)\n",
            nrow(dat), ncol(dat), dplyr::n_distinct(dat$study)))
cat(sprintf("rds         : %s\n", rds_path))
cat(sprintf("csv         : %s\n", csv_path))
cat(sprintf("dictionary  : %s\n", dict_path))
cat(sprintf("post_paris  : %d post / %d pre   (headline, end_lag0)\n",
            sum(dat$post_paris), sum(dat$post_paris == 0L)))
cat(sprintf("pub_year    : all 66 resolved, range [%d, %d], centred at %.3f\n",
            min(dat$pub_year), max(dat$pub_year), pub_year_mean))
cat(sprintf("n median    : %.2f   share n<200: %.1f%%\n",
            n_stats$median, 100 * n_stats$share_lt200))
cat(strrep("-", 80), "\n", sep = "")
cat("FLAGS (surfaced for the Volker extraction check):\n")
cat(sprintf("  F1 extremes      : %d rows (|r| > %.2f) — source-verify, not dropped\n",
            nrow(flag_extreme), EXTREME_R_FLAG))
cat(sprintf("  F2 non-integer n : %d (%.1f%%) — n-derivation rule unknown\n",
            n_fractional, 100 * n_fractional / nrow(dat)))
cat(sprintf("  F3 n < 10        : %d — fragile vz\n", n_small))
cat( "  F4 regulation    : raw 0/1/9/NA carried; no moderator built (E9)\n")
cat(strrep("=", 80), "\n", sep = "")

# SECTION 17 — Reproducibility --------------------------------------------------
.key_pkgs <- c("readxl", "readr", "tidyverse", "here")
cat("R version:", R.version.string, "\n")
print(data.frame(package = .key_pkgs,
                 version = vapply(.key_pkgs,
                                  function(p) as.character(packageVersion(p)),
                                  character(1)),
                 row.names = NULL))
cat("run timestamp:", format(Sys.time()), "\n")
