# =============================================================================
# R/00_verify_prep.R — paired verifier for T0.4 (v2: coverage gaps closed)
# v2 changes (per CC adversarial findings, 2026-07-12):
#   - column-existence guard: a missing column is a FAIL, never a vacuous PASS
#   - V3 covers ALL 12 closed lists (was 3)
#   - V4 covers all 13 factor columns + ids, non-vacuous (was 3 ids)
#   - V5 recounts cells for ALL 10 Paris codings (was pp_mid only) + df presence
#   - V6 block added: S3 identity re-runs (was missing vs spec)
#   - V7 added: estimation-set inventory (115 studies / 114 clusters; the 5
#     documented full-drop studies) + N15 set
# =============================================================================
suppressPackageStartupMessages({ library(readxl); library(here) })
LOG <- here("output", "verify_prep_log.txt"); RES <- list()
chk <- function(id, desc, cond) {
  RES[[length(RES) + 1]] <<- sprintf("%-4s %-4s %s", id, ifelse(isTRUE(cond), "PASS", "FAIL"), desc)
  isTRUE(cond)
}
has <- function(df, cols) all(cols %in% names(df))   # existence guard

d  <- as.data.frame(read_excel(here("data","CER-COD_data_v12.xlsx"), sheet = "data", guess_max = 5000))
lk <- as.data.frame(read_excel(here("data","CER-COD_data_v12.xlsx"), sheet = "lookup"))
pr <- readRDS(here("output","dat_prep.rds")); dat <- pr$dat
dq <- read.csv(here("output","design_quantities_v12.csv"), stringsAsFactors = FALSE)

nnum <- function(x) suppressWarnings(as.numeric(x))
E    <- nnum(d[["sample_size\nno_firm-years_rounded"]])
usab <- nnum(d[["d_es_usable"]]) == 1
dup  <- nnum(d[["duplicate"]]) == 1
allok <- TRUE

# --- V1: corpus + estimation-set constants -----------------------------------
allok <- chk("V1a", "corpus rows == 2852",  nrow(d) == 2852) && allok
allok <- chk("V1b", "usable == 2730",       sum(usab, na.rm = TRUE) == 2730) && allok
allok <- chk("V1c", "estimation set == 2713 (fresh recount)",
             sum(usab & !(dup %in% TRUE) & is.finite(E), na.rm = TRUE) == 2713) && allok
allok <- chk("V1d", "RDS n == 2713", nrow(dat) == 2713 && pr$n == 2713) && allok
allok <- chk("V1e", "non-convertible 122 / duplicate 1 / usable-no-n 16",
             sum(d$es_method == "non-convertible") == 122 &&
             sum(dup, na.rm = TRUE) == 1 &&
             sum(usab & !is.finite(E), na.rm = TRUE) == 16) && allok

# --- V2: independent grid re-derivation --------------------------------------
ds <- nnum(d$d_sample_start); de <- nnum(d$d_sample_end); m <- (ds + de) / 2
cmpn <- function(a, b, tol = 1e-9) all(abs(ifelse(is.na(a), -9, a) - ifelse(is.na(b), -9, b)) < tol)
s16 <- pmin(1, pmax(0, (de - 2015) / (de - ds + 1)))
allok <- chk("V2a", "share_2016 independent re-derivation",
             cmpn(s16, nnum(d[["sample_post share_2016"]]))) && allok
allok <- chk("V2b", "pp_mid independent (mid >= 2015.5)",
             cmpn(as.numeric(m >= 2015.5), nnum(d$pp_mid_lag0))) && allok
allok <- chk("V2c", "pp_start independent (start >= 2016; R-18)",
             cmpn(as.numeric(ds >= 2016), nnum(d$pp_start_lag0))) && allok
allok <- chk("V2d", "median split independent (> 2013 frozen)",
             cmpn(as.numeric(m > 2013), nnum(d[["pp_median split"]]))) && allok
allok <- chk("V2e", "tertile split independent (2011/2014 frozen)",
             cmpn(1 + (m > 2011) + (m > 2014), nnum(d[["pp_tertial split"]]))) && allok

# --- V3: ALL closed lists (single check, existence-guarded) -------------------
CL <- list(
  industry        = c("non-sensitive","sensitive","99_NCE"),
  regulation_sample_start = c("with ETS/CT","without ETS/CT","99_NCE"),
  regulation_sample_end   = c("with ETS/CT","without ETS/CT","99_NCE"),
  country_region  = c("1_US","2_Europe","3_AsiaPac","99_NCE"),
  country_econ    = c("1_developed","2_developing","99_NCE"),
  country_culture = c("1_western","2_non_western","99_NCE"),
  country_legal   = c("1_common law","2_civil law","99_NCE"),
  q_status        = c("0_published","1_not published"),
  q_VHB           = c("1_VHB high","0_VHB low","99_NCE"),
  field           = c("1_fin/acc/econ","2_sust","3_mgmt"),
  pp_window_class = c("pre-only","post-only","mixed"),
  COD_instrument  = c("bond (yield)","derivativ (CDS spread)","loan (interest rate)","rating")
)
v3ok <- has(d, names(CL))
if (v3ok) for (cn in names(CL))
  v3ok <- v3ok && length(setdiff(unique(na.omit(as.character(d[[cn]]))), CL[[cn]])) == 0
allok <- chk("V3", sprintf("ALL %d closed lists (incl. column existence)", length(CL)), v3ok) && allok

# --- V4: RDS internals (non-vacuous) ------------------------------------------
FACS <- c("CER_measure","COD_instrument","industry","regulation_sample_start",
          "country_region","country_econ","country_culture","country_legal",
          "q_VHB","q_status","field","ES_measure","es_method")
IDS  <- c("study","cluster_id","esid")
allok <- chk("V4a", "required columns EXIST in RDS (ids + 13 factors + zi/vi/n_eff)",
             has(dat, c(IDS, FACS, "zi","vi","vi_k10","vi_k20","n_eff"))) && allok
allok <- chk("V4b", "zi finite; vi > 0", all(is.finite(dat$zi)) && all(dat$vi > 0)) && allok
allok <- chk("V4c", "zi == atanh(r); vi == 1/(n_eff-3)",
             max(abs(dat$zi - atanh(pmin(pmax(dat$r_raw, -0.999999), 0.999999)))) < 1e-9 &&
             max(abs(dat$vi - 1/(dat$n_eff - 3))) < 1e-12) && allok
allok <- chk("V4d", "no NA in ids AND all 13 factor columns (non-vacuous)",
             has(dat, c(IDS, FACS)) &&
             !any(sapply(dat[, c(IDS, FACS)], anyNA))) && allok
allok <- chk("V4e", "starbound: corpus 99; RDS flags consistent",
             sum(d$es_method == "star-bound") == 99 &&
             sum(dat$flag_starbound) == sum(dat$es_method == "star-bound")) && allok
allok <- chk("V4f", "RDS cluster_id matches lookup mapping study-by-study",
             has(dat, "cluster_id") &&
             all(dat$cluster_id == lk$cluster_id[match(dat$study, lk$study)])) && allok

# --- V5: design-quantities recount for ALL codings ----------------------------
cod <- list(pp_mid = nnum(dat$pp_mid_lag0), pp_median = nnum(dat$pp_median_lag0),
            end_lag0 = nnum(dat$pp_end_lag0), end_lag1 = nnum(dat$pp_end_lag1),
            end_lag2 = nnum(dat$pp_end_lag2), end_lag3 = nnum(dat$pp_end_lag3),
            share_lag1_bin = as.numeric(nnum(dat$pp_share_lag1) >= 0.5),
            share_lag2_bin = as.numeric(nnum(dat$pp_share_lag2) >= 0.5),
            share_lag3_bin = as.numeric(nnum(dat$pp_share_lag3) >= 0.5),
            clean_window = ifelse(dat$pp_window_class == "post-only", 1,
                            ifelse(dat$pp_window_class == "pre-only", 0, NA)))
v5ok <- all(names(cod) %in% dq$quantity)
if (v5ok) for (n in names(cod)) {
  rr <- dq[dq$quantity == n, ]
  v5ok <- v5ok && nrow(rr) == 1 &&
          as.numeric(rr$k_post) == sum(cod[[n]] == 1, na.rm = TRUE) &&
          as.numeric(rr$k_pre)  == sum(cod[[n]] == 0, na.rm = TRUE) &&
          as.numeric(rr$st_post) == length(unique(dat$study[cod[[n]] == 1 & !is.na(cod[[n]])]))
}
allok <- chk("V5a", "cells (k + post-studies) match CSV for ALL 10 codings", v5ok) && allok
allok <- chk("V5b", "upgrade adjudication rows present",
             all(c("clean_window_upgrade_df_ge_5",
                   "split_selmodels_upgrade_poststudies_ge_20") %in% dq$quantity)) && allok
allok <- chk("V5c", "df_paris_design finite for all 10 codings",
             "df_paris_design" %in% names(dq) &&
             all(is.finite(nnum(dq$df_paris_design[dq$quantity %in% names(cod)])))) && allok

# --- V6: identity re-runs (spec block; was missing in v1) ---------------------
allok <- chk("V6a", "sample_median == sample_mid",
             cmpn(nnum(d$sample_median), nnum(d$sample_mid))) && allok
allok <- chk("V6b", "pp_share_lag0 == share_2016 (continuous identity)",
             cmpn(nnum(d$pp_share_lag0), nnum(d[["sample_post share_2016"]]))) && allok
allok <- chk("V6c", "end_lag0 == 1 <=> share_2016 > 0",
             all((nnum(d$pp_end_lag0) == 1) == (nnum(d[["sample_post share_2016"]]) > 0),
                 na.rm = TRUE)) && allok
allok <- chk("V6d", "pp_start == 1 <=> share_2016 == 1 (clean_post)",
             all((nnum(d$pp_start_lag0) == 1) == (nnum(d[["sample_post share_2016"]]) == 1),
                 na.rm = TRUE)) && allok
allok <- chk("V6e", "window_class rule re-run",
             all(ifelse(is.na(ds), is.na(d$pp_window_class),
                 d$pp_window_class == ifelse(ds >= 2016, "post-only",
                                      ifelse(de < 2016, "pre-only", "mixed"))))) && allok

# --- V7: estimation-set inventory (design facts) -------------------------------
DROP5 <- c("Johnson (2020)", "Kumar & Firoz (2018)", "Ould Daoud Ellili (2020)",
           "Piechocka-Ka\u0142u\u017cna et al (2021)", "Polbennikov et al (2016)")
allok <- chk("V7a", "estimation set: 115 studies / 114 clusters",
             length(unique(dat$study)) == 115 &&
             length(unique(dat$cluster_id)) == 114) && allok
allok <- chk("V7b", "exactly the 5 documented studies drop fully at S4",
             setequal(setdiff(unique(d$study), unique(dat$study)), DROP5)) && allok
allok <- chk("V7c", "N15 within-study set == {Li et al (2022)} under headline coding",
             { tb <- tapply(dat$pp_mid_lag0, dat$study,
                            function(x) length(unique(na.omit(x))))
               setequal(names(tb)[tb > 1], "Li et al (2022)") }) && allok

writeLines(c(sprintf("T0.4 verifier v2 — %s", Sys.time()), unlist(RES),
             sprintf("RESULT: %s", ifelse(allok, "ALL PASS", "FAILURES PRESENT"))), LOG)
cat(paste(unlist(RES), collapse = "\n"), "\n")
if (!allok) quit(status = 1) else message("[VERIFY v2] ALL PASS -> ", LOG)
