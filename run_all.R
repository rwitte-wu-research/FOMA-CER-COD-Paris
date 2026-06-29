# =============================================================================
# run_all.R — analysis orchestrator (SKELETON)
# Defines the canonical run order for the meta-analysis pipeline. Scripts are
# listed here so the full chain is reviewable in one place before any of it is
# executed. Every source() call is intentionally COMMENTED OUT — uncomment a
# line only when its R/NN_*.R script exists and you mean to run it.
# =============================================================================

# SECTION 1 — Environment -------------------------------------------------------
# setup.R loads the pinned package set and prints the session fingerprint.
# Kept commented so that sourcing this file has no side effects until intended.
# source(here::here("setup.R"))

# SECTION 2 — Pipeline (ordered) ------------------------------------------------
# Numbering encodes dependency order: each NN step consumes the outputs of the
# steps before it. Each analysis script is paired with an NN_*_verify.R that is
# run after it to check that step's outputs (see docs/VERIFIER_TEMPLATE.R).

# --- Data preparation --------------------------------------------------------
# source(here::here("R", "00_prepare_data.R"))      # read raw .xlsx -> tidy effect-size table (data/processed)
# source(here::here("R", "00_prepare_data_verify.R"))

# --- Headline model ----------------------------------------------------------
# source(here::here("R", "01_main_model.R"))        # primary RVE meta-analysis: CER -> COD
# source(here::here("R", "01_main_model_verify.R"))

# --- Moderation --------------------------------------------------------------
# source(here::here("R", "02_paris_moderator.R"))   # Paris Agreement as temporal moderator
# source(here::here("R", "02_paris_moderator_verify.R"))

# --- Robustness --------------------------------------------------------------
# source(here::here("R", "03_robustness.R"))        # alt specs, influence, publication bias (long-format, spec column)
# source(here::here("R", "03_robustness_verify.R"))

# --- Reporting ---------------------------------------------------------------
# source(here::here("R", "04_tables_figures.R"))    # assemble output/ tables + plots for the manuscript
# source(here::here("R", "04_tables_figures_verify.R"))

# SECTION 3 — Notes -------------------------------------------------------------
# This file performs NO work on its own. Run steps deliberately and in order;
# inspect each step's verifier output before uncommenting the next.
