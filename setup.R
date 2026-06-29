# =============================================================================
# setup.R — environment bootstrap for FOMA-CER-COD-Paris
# Meta-analysis: Corporate Environmental Responsibility -> Cost of Debt,
# Paris Agreement as temporal moderator.
# Source this at the top of every analysis script so all scripts share one
# package set and so a session fingerprint is recorded for reproducibility.
# =============================================================================

# SECTION 1 — Core packages -----------------------------------------------------
# Loaded here (not inside each script) so that the analysis layer can assume a
# fixed, lockfile-pinned namespace and never re-declares dependencies ad hoc.
library(metafor)       # random-effects / multilevel meta-analytic models
library(clubSandwich)  # cluster-robust (RVE) variance estimators
library(tidyverse)     # data wrangling + plotting grammar
library(here)          # project-root-relative paths (no setwd, no abs paths)
library(readxl)        # read the raw .xlsx effect-size database
library(readr)         # fast, typed CSV I/O for processed data + output

# SECTION 2 — Session fingerprint ----------------------------------------------
# An abbreviated sessionInfo() is printed (not the full dump) because the only
# reproducibility-relevant facts are the R version and the versions of the
# packages we actually model with — everything else lives in renv.lock.
.key_pkgs <- c("metafor", "clubSandwich", "tidyverse",
               "here", "readxl", "readr")

cat(strrep("=", 80), "\n", sep = "")
cat("Session fingerprint\n")
cat(strrep("=", 80), "\n", sep = "")
cat(R.version.string, "\n\n")

# vapply (not a loop) keeps the version lookup a single typed expression.
.key_versions <- vapply(.key_pkgs,
                        function(p) as.character(packageVersion(p)),
                        character(1))
print(data.frame(package = .key_pkgs,
                 version = .key_versions,
                 row.names = NULL))
cat(strrep("=", 80), "\n", sep = "")
