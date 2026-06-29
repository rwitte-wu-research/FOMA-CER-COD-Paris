# =============================================================================
# VERIFIER_TEMPLATE.R — paired verifier skeleton
# Copy to R/NN_<name>_verify.R and run AFTER the matching analysis script.
# A verifier never recomputes the analysis: it independently re-checks the
# claimed outputs (files exist, shapes/columns/values are sane, the long-format
# `spec` column is present, headline numbers fall in plausible ranges, etc.).
#
# Conventions:
#   - Each check is numbered O1..On (O = "output check").
#   - Each check prints "[O# ] PASS — <detail>" or "[O# ] FAIL — <detail>".
#   - If a check's input is GITIGNORED / absent (e.g. data/processed/*.csv on a
#     fresh clone), print SKIP — never FAIL — so the verifier is clone-safe.
#   - End with a "k/k PASS" summary line (skipped checks excluded from k).
# =============================================================================

# SECTION 1 — Harness -----------------------------------------------------------
suppressMessages(library(here))

.results <- list()   # accumulates one record per executed (non-skipped) check

# check(): run one assertion. `pass` is logical; `detail` explains the outcome.
# `skip = TRUE` marks the input unavailable (gitignored/missing) -> excluded
# from the pass count rather than counted as a failure.
check <- function(id, pass, detail, skip = FALSE) {
  status <- if (skip) "SKIP" else if (isTRUE(pass)) "PASS" else "FAIL"
  cat(sprintf("[%-3s] %s — %s\n", id, status, detail))
  if (!skip) .results[[length(.results) + 1]] <<-
      list(id = id, pass = isTRUE(pass))
  invisible(status)
}

# require_input(): guard for gitignored/missing inputs. Returns TRUE when the
# file is present (proceed with real checks); when absent, emits a SKIP for `id`
# and returns FALSE so the caller can bail out of that check cleanly.
require_input <- function(id, path) {
  if (file.exists(path)) return(TRUE)
  check(id, NA, sprintf("input not present, skipped: %s", path), skip = TRUE)
  FALSE
}

# SECTION 2 — Checks ------------------------------------------------------------
# Replace the placeholders below with real assertions for this analysis step.

# O1 — primary results CSV exists and is non-empty.
out_csv <- here::here("output", "<NN_name>.csv")   # <-- set path
if (file.exists(out_csv)) {
  res <- readr::read_csv(out_csv, show_col_types = FALSE)
  check("O1", nrow(res) > 0,
        sprintf("%s has %d rows", basename(out_csv), nrow(res)))

  # O2 — long format: the `spec` column is present (all K specs in one file).
  check("O2", "spec" %in% names(res),
        "long-format `spec` column present")

  # O3 — headline spec is present and its estimate is finite / in range.
  # check("O3", ..., "headline estimate within plausible bounds")
} else {
  check("O1", FALSE, sprintf("missing results CSV: %s", out_csv))
}

# O4 — processed input is GITIGNORED: SKIP (not FAIL) when absent on a clone.
proc_csv <- here::here("data", "processed", "<NN_name>.csv")   # <-- set path
if (require_input("O4", proc_csv)) {
  # ... real checks against the processed intermediate go here ...
  check("O4", TRUE, sprintf("processed input present: %s", basename(proc_csv)))
}

# O5.. — add further checks (manuscript .md has required H2 headings, counts of
# studies/effects match, CIs ordered lo < hi, no NA in key columns, ...).

# SECTION 3 — Summary -----------------------------------------------------------
.k_total  <- length(.results)
.k_passed <- sum(vapply(.results, function(r) r$pass, logical(1)))
cat(strrep("-", 80), "\n", sep = "")
cat(sprintf("%d/%d PASS\n", .k_passed, .k_total))
if (.k_passed < .k_total) {
  failed <- vapply(Filter(function(r) !r$pass, .results),
                   function(r) r$id, character(1))
  cat("FAILED:", paste(failed, collapse = ", "), "\n")
}
