# =============================================================================
# 01_verify_outputs.R — paired verifier for 01_prep.R (T0.4)
# Independently re-checks the prepared dataset: it RE-READS the raw .xlsx and
# RE-DERIVES the expected label tallies, then compares against the processed
# output — it never trusts 01_prep.R's own asserts. Numbered checks O1..O12 plus
# a row-conservation check, each PASS / FAIL / FLAG. FLAG = a data-integrity
# item surfaced for the Volker extraction check (its count constant must still
# hold, else FAIL). Ends with a "k/k PASS" line + the FLAG list.
#
# Clone-safe: data/processed/* is gitignored, so when the processed output is
# absent the dependent checks SKIP (never FAIL).
# =============================================================================

# SECTION 1 — Harness -----------------------------------------------------------
suppressMessages({
  library(here); library(readxl); library(readr); library(dplyr); library(stringr)
})

.results <- list()   # one record per executed (non-skipped) check
.flags   <- character(0)

# check(): pass -> PASS (or FLAG when flag=TRUE); !pass -> FAIL; skip -> SKIP.
# A held FLAG counts toward k/k exactly like a PASS, and its detail is appended
# to the FLAG list printed in the summary.
check <- function(id, pass, detail, skip = FALSE, flag = FALSE) {
  status <- if (skip) "SKIP"
            else if (!isTRUE(pass)) "FAIL"
            else if (flag) "FLAG" else "PASS"
  cat(sprintf("[%-4s] %s — %s\n", id, status, detail))
  if (!skip) .results[[length(.results) + 1]] <<- list(id = id, pass = isTRUE(pass))
  if (status == "FLAG") .flags[[length(.flags) + 1]] <<- sprintf("%s: %s", id, detail)
  invisible(status)
}

require_input <- function(id, path) {
  if (file.exists(path)) return(TRUE)
  check(id, NA, sprintf("input not present, skipped: %s", path), skip = TRUE)
  FALSE
}

# SECTION 2 — Expected constants ------------------------------------------------
# Re-stated here (not imported from 01_prep.R) so the verifier is an independent
# witness to the same contract.
RAW_XLSX  <- here::here("data", "CER-COD_data_v1.xlsx")
RAW_SHEET <- "Tabelle1"
RDS_PATH  <- here::here("data", "processed", "cer_cod_prepared.rds")
CSV_PATH  <- here::here("data", "processed", "cer_cod_prepared.csv")
DICT_PATH <- here::here("docs", "data_dictionary.md")

EXPECT_ROWS <- 1306L; EXPECT_COLS <- 17L; EXPECT_STUDIES <- 66L
YEAR_MIN <- 2010L; YEAR_MAX <- 2024L
EXTREME_R_FLAG <- 0.99; N_SMALL_THRESH <- 10L
EXPECT_NONINT  <- 699L         # F2 non-integer n
EXPECT_NSMALL  <- 9L           # F3 n < 10
EXPECT_NEXTREME <- 2L          # F1
EXPECT_MEDIAN_N <- 289L        # rounded
EXPECT_SHARE_LT200 <- 37.4     # percent

EXPECT_CER <- c(Performance = 1063L, Disclosure = 243L)
EXPECT_COD <- c(interest = 631L, rating = 300L, yields = 233L, derivativ = 142L)
EXPECT_ES  <- c(bivariate = 1270L, partial = 36L)
EXPECT_IND <- c(`1` = 185L, `0` = 1121L)
EXPECT_JQ  <- c(HIGH = 551L, LOW = 755L)
# (post / pre) splits and their raw label scheme.
EXPECT_PARIS <- list(
  post_paris  = list(post = 728L, pre = 578L, one = "1_Post", zero = "0_Pre", raw = "event_sample end_lag0"),
  post_lag1   = list(post = 562L, pre = 744L, one = "1_Post", zero = "0_Pre", raw = "event_sample end_lag1"),
  post_lag2   = list(post = 506L, pre = 800L, one = "1_Post", zero = "0_Pre", raw = "event_sample end_lag2"),
  post_lag3   = list(post = 252L, pre = 1054L, one = "1_Post", zero = "0_Pre", raw = "event_sample end_lag3"),
  post_median = list(post = 686L, pre = 620L, one = "Post", zero = "Pre", raw = "event_sample median_lag0"),
  post_mean   = list(post = 945L, pre = 361L, one = "Post", zero = "Pre", raw = "event_sample mean_lag0")
)
EXPECT_REG_START <- c(`1` = 746L, `0` = 297L, `9` = 182L, `NA` = 81L)
EXPECT_REG_END   <- c(`0` = 691L, `1` = 337L, `9` = 278L)

# SECTION 3 — Re-read raw (independent witness) ---------------------------------
have_raw <- file.exists(RAW_XLSX)
if (have_raw) raw <- readxl::read_excel(RAW_XLSX, sheet = RAW_SHEET)

# O1 — raw input exists; 1306×17; 66 studies.
if (have_raw) {
  ok <- nrow(raw) == EXPECT_ROWS && ncol(raw) == EXPECT_COLS &&
        dplyr::n_distinct(raw$study) == EXPECT_STUDIES
  check("O1", ok, sprintf("raw %d×%d, %d studies",
                          nrow(raw), ncol(raw), dplyr::n_distinct(raw$study)))
} else {
  check("O1", FALSE, sprintf("raw input missing: %s", RAW_XLSX))
}

# SECTION 4 — Load processed output ---------------------------------------------
have_proc <- file.exists(RDS_PATH)
if (have_proc) dat <- readRDS(RDS_PATH)

# O2 — z/vz/sez all finite; vz > 0 everywhere.
if (require_input("O2", RDS_PATH)) {
  ok <- all(is.finite(dat$z)) && all(is.finite(dat$vz)) &&
        all(is.finite(dat$sez)) && all(dat$vz > 0)
  check("O2", ok, sprintf("z/vz/sez finite; min vz = %.4g", min(dat$vz)))
}

# O3 — post_paris ∈ {0,1}; 728 post / 578 pre; bijective vs raw end_lag0.
if (have_proc && have_raw) {
  e <- EXPECT_PARIS$post_paris
  raw_one  <- sum(raw[[e$raw]] == e$one)
  raw_zero <- sum(raw[[e$raw]] == e$zero)
  ok <- all(dat$post_paris %in% c(0L, 1L)) &&
        sum(dat$post_paris == 1L) == e$post && sum(dat$post_paris == 0L) == e$pre &&
        sum(dat$post_paris == 1L) == raw_one && sum(dat$post_paris == 0L) == raw_zero
  check("O3", ok, sprintf("post=%d pre=%d; bijective vs raw (%d/%d)",
                          sum(dat$post_paris == 1L), sum(dat$post_paris == 0L),
                          raw_one, raw_zero))
} else if (!have_proc) {
  check("O3", NA, "processed output absent", skip = TRUE)
} else {
  check("O3", FALSE, "raw absent — cannot verify bijection")
}

# O4 — lag1/2/3, median, mean recodes bijective vs raw (post/pre counts).
if (have_proc && have_raw) {
  details <- c(); all_ok <- TRUE
  for (col in c("post_lag1", "post_lag2", "post_lag3", "post_median", "post_mean")) {
    e <- EXPECT_PARIS[[col]]
    raw_one  <- sum(raw[[e$raw]] == e$one)
    raw_zero <- sum(raw[[e$raw]] == e$zero)
    ok <- sum(dat[[col]] == 1L) == e$post && sum(dat[[col]] == 0L) == e$pre &&
          sum(dat[[col]] == 1L) == raw_one && sum(dat[[col]] == 0L) == raw_zero
    all_ok <- all_ok && ok
    details <- c(details, sprintf("%s %d/%d", sub("post_", "", col),
                                  sum(dat[[col]] == 1L), sum(dat[[col]] == 0L)))
  }
  check("O4", all_ok, paste(details, collapse = " · "))
} else if (!have_proc) {
  check("O4", NA, "processed output absent", skip = TRUE)
} else {
  check("O4", FALSE, "raw absent — cannot verify bijection")
}

# O5 — pub_year resolved for all 66 studies; range ⊆ [2010, 2024].
if (require_input("O5", RDS_PATH)) {
  by_study <- dat |> dplyr::distinct(study, pub_year)
  ok <- nrow(by_study) == EXPECT_STUDIES &&
        all(!is.na(dat$pub_year)) &&
        min(dat$pub_year) >= YEAR_MIN && max(dat$pub_year) <= YEAR_MAX
  check("O5", ok, sprintf("66 studies resolved; range [%d, %d]",
                          min(dat$pub_year), max(dat$pub_year)))
}

# O6 — factor level counts == constants.
if (require_input("O6", RDS_PATH)) {
  cnt <- function(x, lvl) sum(x == lvl)
  es_ok  <- cnt(dat$es_type, "bivariate") == EXPECT_ES[["bivariate"]] &&
            cnt(dat$es_type, "partial")   == EXPECT_ES[["partial"]]
  cer_ok <- all(vapply(names(EXPECT_CER),
                       function(l) cnt(dat$cer_type, l) == EXPECT_CER[[l]], logical(1)))
  cod_ok <- all(vapply(names(EXPECT_COD),
                       function(l) cnt(dat$cod_instrument, l) == EXPECT_COD[[l]], logical(1)))
  ind_ok <- sum(dat$sensitive_industry == 1L) == EXPECT_IND[["1"]] &&
            sum(dat$sensitive_industry == 0L) == EXPECT_IND[["0"]]
  jq_ok  <- sum(dat$journal_high == 1L) == EXPECT_JQ[["HIGH"]] &&
            sum(dat$journal_high == 0L) == EXPECT_JQ[["LOW"]]
  check("O6", es_ok && cer_ok && cod_ok && ind_ok && jq_ok,
        "es 1270/36 · cer 1063/243 · cod 631/300/233/142 · ind 185/1121 · jq 551/755")
}

# O7 FLAG — non-integer n count == 699; print head + the 9 smallest.
if (require_input("O7", RDS_PATH)) {
  is_frac <- abs(dat$n - round(dat$n)) > 1e-9
  n_frac  <- sum(is_frac)
  check("O7", n_frac == EXPECT_NONINT,
        sprintf("non-integer n = %d (%.1f%%)", n_frac, 100 * n_frac / nrow(dat)),
        flag = TRUE)
  cat("        head(non-integer n):\n")
  print(utils::head(dat |> dplyr::filter(is_frac) |>
                      dplyr::select(esid, study, r, n), 5))
  cat("        9 smallest n:\n")
  print(dat |> dplyr::arrange(n) |> dplyr::slice_head(n = 9) |>
          dplyr::select(esid, study, r, n))
}

# O8 FLAG — extremes present (2 rows): study + r + n each.
if (require_input("O8", RDS_PATH)) {
  ext <- dat |> dplyr::filter(abs(r) > EXTREME_R_FLAG) |>
    dplyr::select(esid, study, r, n) |> dplyr::arrange(r)
  check("O8", nrow(ext) == EXPECT_NEXTREME,
        sprintf("%d extreme |r| > %.2f rows present", nrow(ext), EXTREME_R_FLAG),
        flag = TRUE)
  print(as.data.frame(ext))
}

# O9 FLAG — n < 10 count == 9.
if (require_input("O9", RDS_PATH)) {
  n_small <- sum(dat$n < N_SMALL_THRESH)
  check("O9", n_small == EXPECT_NSMALL,
        sprintf("n < %d count = %d", N_SMALL_THRESH, n_small), flag = TRUE)
}

# O10 — regulation raw carried; value counts == constants.
if (require_input("O10", RDS_PATH)) {
  rs <- table(as.character(dat$regulation_start))
  re <- table(as.character(dat$regulation_end))
  gs <- function(t, l) if (l %in% names(t)) as.integer(t[[l]]) else 0L
  rs_ok <- all(vapply(names(EXPECT_REG_START),
                      function(l) gs(rs, l) == EXPECT_REG_START[[l]], logical(1)))
  re_ok <- all(vapply(names(EXPECT_REG_END),
                      function(l) gs(re, l) == EXPECT_REG_END[[l]], logical(1)))
  is_factor <- is.factor(dat$regulation_start) && is.factor(dat$regulation_end)
  check("O10", rs_ok && re_ok && is_factor,
        "start 746/297/182/81 · end 691/337/278 (raw factors)")
}

# O11 — n-distribution stats == constants.
if (require_input("O11", RDS_PATH)) {
  med   <- median(dat$n)
  share <- 100 * mean(dat$n < 200)
  ok <- round(med) == EXPECT_MEDIAN_N && abs(share - EXPECT_SHARE_LT200) < 0.05
  check("O11", ok, sprintf("median n = %.2f (≈%d); share n<200 = %.1f%%",
                           med, EXPECT_MEDIAN_N, share))
}

# O12 — output files written; dictionary present and contains F1-F4.
rds_ok  <- file.exists(RDS_PATH)
csv_ok  <- file.exists(CSV_PATH)
dict_ok <- file.exists(DICT_PATH)
if (dict_ok) {
  dict_txt <- paste(readLines(DICT_PATH, warn = FALSE), collapse = "\n")
  flags_present <- all(vapply(c("F1", "F2", "F3", "F4"),
                              function(f) grepl(f, dict_txt, fixed = TRUE), logical(1)))
} else flags_present <- FALSE
# rds/csv are gitignored: SKIP that part on a fresh clone, else require them.
if (!rds_ok && !csv_ok) {
  check("O12", dict_ok && flags_present,
        sprintf("dictionary present w/ F1-F4 = %s; processed files absent (clone)",
                dict_ok && flags_present))
} else {
  check("O12", rds_ok && csv_ok && dict_ok && flags_present,
        sprintf("rds=%s csv=%s dict=%s (F1-F4=%s)",
                rds_ok, csv_ok, dict_ok, flags_present))
}

# Row conservation — no silent drops: nrow_out == 1306.
if (require_input("ROW", RDS_PATH)) {
  check("ROW", nrow(dat) == EXPECT_ROWS,
        sprintf("nrow(out) = %d (== %d expected)", nrow(dat), EXPECT_ROWS))
}

# SECTION 5 — Summary -----------------------------------------------------------
.k_total  <- length(.results)
.k_passed <- sum(vapply(.results, function(r) r$pass, logical(1)))
cat(strrep("-", 80), "\n", sep = "")
cat(sprintf("%d/%d PASS\n", .k_passed, .k_total))
if (.k_passed < .k_total) {
  failed <- vapply(Filter(function(r) !r$pass, .results),
                   function(r) r$id, character(1))
  cat("FAILED:", paste(failed, collapse = ", "), "\n")
}
if (length(.flags) > 0) {
  cat("FLAGS (surfaced for the Volker extraction check):\n")
  for (f in .flags) cat("  -", f, "\n")
}
cat(strrep("=", 80), "\n", sep = "")
