# =====================================================================
# R/07_verify_outputs.R — paired verifier for R/07_robma.R (TH-b)
# FOMA CER–COD–Paris | numbered O-checks; ANY FAIL => exit status 1
# Authority: DEC-045 (verifier obligations) · DEC-046 (version + scale
#   pins) · DEC-031g/F65 (runtime-read anchor + embedded full-precision
#   constants + refit identity) · DEC-042a/b (domains).
# Independence: this verifier re-derives the aggregates and the H2b
#   structure from output/dat_prep.rds itself (md5-asserted) and does
#   not trust any count written by R/07.
# =====================================================================

suppressPackageStartupMessages({
  library(metafor); library(here)
})

FAILS <- character(0)
ok <- function(id, cond, msg) {
  if (isTRUE(cond)) cat(sprintf("%-4s PASS — %s\n", id, msg))
  else { cat(sprintf("%-4s FAIL — %s\n", id, msg))
         FAILS <<- c(FAILS, paste0(id, ": ", msg)) }
  invisible(cond)
}
near <- function(a, b, tol) all(is.finite(a) & is.finite(b)) &&
  all(abs(a - b) <= tol)
relnear <- function(a, b, tol) all(is.finite(a) & is.finite(b)) &&
  all(abs(a - b) <= tol * pmax(abs(a), abs(b), 1e-12))

# ---- Embedded constants (FROZEN) -------------------------------------
DAT_PREP_MD5 <- "6702ef3dc45fe0b693b13f50ebd1576b"
SEED  <- 20260710L; RHO <- 0.6
N_SET <- 2713L; N_SET_ST <- 115L; N_SET_CL <- 114L
N_SUB <- 2705L; N_SUB_ST <- 113L; N_SUB_CL <- 112L
K_NA_ES <- 8L; K_AGG_FULL <- 114L
H2B_ROWS <- 113L; H2B_POST <- 31L; H2B_PRE <- 82L; H2B_BOTH <- 1L
MU_COE <- -0.041; SD_COE <- 0.083 / 3.92; SD_WIDE <- 2 * SD_COE
# F65 full-precision T1/A5 anchors [DEC-031g]:
A5 <- c(est = -0.0616608386540629, se = 0.0243306602731784, df = 113,
        p = 0.0126367644358383, lb = -0.109864264918875,
        ub = -0.0134574123892513)
NONCONV_SIG <- c("converg", "r-hat", "rhat", "effective sample size",
                 "bridge sampl", "node inconsistent", "unable to initialize")
SCHEMA <- c("analysis_id","spec","subset","term","metric","estimator","rho",
            "k_es","k_study","k_cluster","est_z","se_z","t_stat","df","p",
            "ci_lb_z","ci_ub_z","pi_lb_z","pi_ub_z","est_r","ci_lb_r",
            "ci_ub_r","pi_lb_r","pi_ub_r","sigma2_cluster","sigma2_study",
            "sigma2_esid","pct_cluster","pct_study","pct_esid","pct_sampling",
            "typical_v","value","ms_input","ms_label","note")

# ---- O0: environment pins --------------------------------------------
ok("O0", identical(as.character(packageVersion("RoBMA")), "3.6.1") &&
        identical(as.character(packageVersion("BayesTools")), "0.2.23"),
   "installed RoBMA 3.6.1 + BayesTools 0.2.23 [DEC-046]")

# ---- O1: outputs exist -----------------------------------------------
f_csv <- here("output", "TH_b_results.csv")
f_met <- here("output", "TH_b_run_meta.txt")
ok("O1", file.exists(f_csv) && file.exists(f_met),
   "TH_b_results.csv + TH_b_run_meta.txt present")
if (length(FAILS)) { cat("ABORT — outputs missing.\n"); quit(status = 1) }
res  <- read.csv(f_csv, stringsAsFactors = FALSE)
meta <- readLines(f_met, warn = FALSE)

# ---- O2: schema -------------------------------------------------------
ok("O2", identical(names(res), SCHEMA), "36-column T2 schema, exact order")

# ---- O3: row budget + 4-key uniqueness --------------------------------
key4 <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "||")
ok("O3", nrow(res) == 30L && !anyDuplicated(key4),
   sprintf("row budget 30 (got %d) + unique 4-key id|spec|subset|term",
           nrow(res)))

# ---- O4: exact planned key inventory ---------------------------------
exp_keys <- c(
  as.vector(outer(paste0("H2a||", c("psma_default","coe_informed","coe_wide"),
                         "||full||"),
                  c("mu_avg","tau_avg","bf01_effect","bf01_heterogeneity",
                    "bf01_bias"), paste0)),
  paste0("H2b||contrast_informed||defined||",
         c("coef_period","bf01_period","tau_avg")),
  paste0("H2b||contrast_wide||defined||",
         c("coef_period","bf01_period","tau_avg")),
  paste0("H2b||factor_default||defined||", c("bf01_period","tau_avg")),
  paste0("TH_b_design||design||full||",
         c("subset_estimation","agg_k_full","h2b_domain_es","h2b_rows",
           "h2b_rows_pre","h2b_rows_post","h2b_both_period_clusters")))
ok("O4", setequal(key4, exp_keys) && length(exp_keys) == 30L,
   "planned key inventory exact (deterministic budget; failures as not_estimable, never missing)")

# ---- O5: domain columns ----------------------------------------------
h2a <- res[res$analysis_id == "H2a", ]
h2b <- res[res$analysis_id == "H2b", ]
ok("O5", all(h2a$k_es == N_SET) && all(h2a$k_study == N_SET_ST) &&
        all(h2a$k_cluster == K_AGG_FULL) &&
        all(h2b$k_es == N_SUB) && all(h2b$k_study == N_SUB_ST) &&
        all(h2b$k_cluster == H2B_ROWS),
   "k columns: H2a 2713/115/114 · H2b 2705/113/113-rows")

# ---- O6: F65 identity (dat_prep -> aggregates -> T1/A5 anchor) -------
f_prep <- here("output", "dat_prep.rds")
md5_obs <- unname(tools::md5sum(f_prep))
ok("O6a", identical(md5_obs, DAT_PREP_MD5),
   "dat_prep.rds md5 == input-contract pin")
pr <- readRDS(f_prep); dat <- pr$dat
ok("O6b", pr$n == N_SET && pr$seed == SEED && nrow(dat) == N_SET &&
        length(unique(dat$cluster_id)) == N_SET_CL,
   "dat_prep contract (n, seed, clusters)")
make_agg <- function(d, expected_k) {   # verbatim R/05 [F65 call pin]
  X <- data.frame(yi = d$zi, vi = d$vi, cluster_id = d$cluster_id)
  datE <- metafor::escalc(measure = "GEN", yi = yi, vi = vi, data = X)
  agg  <- aggregate(datE, cluster = cluster_id, struct = "CS", rho = RHO)
  stopifnot(nrow(agg) == expected_k, !anyNA(agg$yi), all(agg$vi > 0))
  agg
}
agg <- make_agg(dat, K_AGG_FULL)
t1 <- read.csv(here("output", "T1_results.csv"), stringsAsFactors = FALSE)
iA5 <- which(abs(t1$est_z - A5[["est"]]) < 1e-9 &
             abs(t1$se_z  - A5[["se"]])  < 1e-9)
ok("O6c", length(iA5) == 1,
   "T1/A5 row located BY VALUE in committed T1_results.csv (unique)")
if (length(iA5) == 1) {
  r5 <- t1[iA5, ]
  ok("O6d", near(c(r5$df, r5$p, r5$ci_lb_z, r5$ci_ub_z),
                 unname(A5[c("df","p","lb","ub")]), 1e-9) &&
          round(r5$est_z, 3) == -0.062,
     "A5 fields at 1e-9 vs embedded full-precision constants + display canary -0.062")
  m5 <- rma.uni(yi = agg$yi, vi = agg$vi, method = "REML", test = "knha")
  ok("O6e", near(c(as.numeric(m5$beta), m5$se, m5$pval),
                 unname(A5[c("est","se","p")]), 1e-6) && m5$k - 1 == 113,
     "refit identity: aggregate.escalc -> rma.uni(REML, knha), |delta| <= 1e-6, df = 113")
}

# ---- O7: H2b structure re-derivation ---------------------------------
sub <- dat[!is.na(dat$pp_mid_lag0), , drop = FALSE]
pre  <- sub[sub$pp_mid_lag0 == 0, , drop = FALSE]
post <- sub[sub$pp_mid_lag0 == 1, , drop = FALSE]
kp <- length(unique(pre$cluster_id)); kq <- length(unique(post$cluster_id))
both <- intersect(unique(pre$cluster_id), unique(post$cluster_id))
ok("O7", nrow(sub) == N_SUB && kp == H2B_PRE && kq == H2B_POST &&
        kp + kq == H2B_ROWS &&
        length(unique(sub$cluster_id)) == N_SUB_CL &&
        length(both) == H2B_BOTH,
   sprintf("H2b structure: 2705 ES; pre %d + post %d = 113 rows; 112 unique clusters; both-period n = 1 (%s)",
           kp, kq, paste(both, collapse = ";")))
dr <- res[res$term == "h2b_both_period_clusters", ]
ok("O7b", nrow(dr) == 1 && grepl(both[[1]], dr$note, fixed = TRUE),
   "both-period cluster identity echoed in the design row")

# ---- O8: prior-constant + pin echoes ---------------------------------
ci <- res[res$spec == "coe_informed" & res$term == "mu_avg", "note"]
cw <- res[res$spec == "coe_wide" & res$term == "mu_avg", "note"]
b1 <- res[res$spec == "contrast_informed" & res$term == "bf01_period", "note"]
b2 <- res[res$spec == "contrast_wide" & res$term == "bf01_period", "note"]
ok("O8a", grepl("0.083/3.92", ci, fixed = TRUE) &&
        grepl("-0.041", ci, fixed = TRUE) &&
        grepl("2 x COE", cw, fixed = TRUE) &&
        grepl("0.025", b1, fixed = TRUE) && grepl("0.050", b2, fixed = TRUE),
   "prior provenance in CSV notes (-0.041; 0.083/3.92; wide = 2x; 0.025; 0.050)")
sig_fp <- sprintf("COE sigma %.10f", SD_COE)
ok("O8b", any(grepl("RoBMA 3.6.1", meta, fixed = TRUE)) &&
        any(grepl("BayesTools 0.2.23", meta, fixed = TRUE)) &&
        any(grepl("20260710", meta, fixed = TRUE)) &&
        any(grepl("effect_direction \"negative\"", meta, fixed = TRUE)) &&
        any(grepl(sig_fp, meta, fixed = TRUE)),
   "run_meta echoes: version pins, seed, effect_direction, full-precision COE sigma")
ok("O8c", sum(grepl("^FITMETA\\|", meta)) >= 6 &&
        sum(grepl("^TFIT\\|", meta)) >= 1,
   "per-fit FITMETA blocks (>= 6 incl. not_estimable stubs) + TFIT lines")

# ---- O9: BF pair consistency (BF01 vs BF10 explicit) -----------------
bp <- meta[grepl("^BFPAIR\\|", meta)]
parse_bp <- function(l) {
  ps <- strsplit(l, "|", fixed = TRUE)[[1]]
  c(key = ps[2], comp = ps[3],
    bf10 = as.numeric(sub("BF10=", "", ps[4])),
    bf01 = as.numeric(sub("BF01=", "", ps[5])))
}
bpv <- if (length(bp)) do.call(rbind, lapply(bp, parse_bp)) else NULL
o9a <- length(bp) >= 1 &&
  all(relnear(as.numeric(bpv[, "bf10"]) * as.numeric(bpv[, "bf01"]), 1, 1e-9))
ok("O9a", o9a, sprintf("BFPAIR lines (%d): BF10 x BF01 == 1 at 1e-9 rel.",
                       length(bp)))
bfrows <- res[res$metric == "BF01" & !is.na(res$value), ]
o9b <- TRUE
for (i in seq_len(nrow(bfrows))) {
  r <- bfrows[i, ]
  kmap <- paste0(tolower(r$analysis_id), "_", r$spec)
  comp <- sub("^bf01_", "", r$term)
  j <- which(bpv[, "key"] == kmap & bpv[, "comp"] == comp)
  o9b <- o9b && length(j) == 1 &&
    relnear(r$value, as.numeric(bpv[j, "bf01"]), 1e-9) && r$value > 0
}
ok("O9b", o9b && nrow(bfrows) >= 1,
   sprintf("CSV BF01 values (%d rows) match run_meta BFPAIR at 1e-9 rel.; all > 0",
           nrow(bfrows)))

# ---- O10: metric vocabulary + scale conventions ----------------------
ok("O10", setequal(unique(res$metric),
                   c("Fisher_z", "tau", "BF01", "z_diff", "count")) &&
        all(is.na(res$est_r[res$metric == "z_diff"])) &&
        all(is.na(res$est_z[res$metric == "BF01"])) &&
        {mu <- res[res$term == "mu_avg" & !is.na(res$est_z), ];
         nrow(mu) == 0 || all(abs(mu$est_r - tanh(mu$est_z)) < 1e-12)},
   "closed metric set; z_diff never tanh-transformed; BF rows value-only; est_r = tanh(est_z) on mu rows")

# ---- O11: ms_input inventory -----------------------------------------
mi <- res[res$ms_input == TRUE | res$ms_input == "TRUE", ]
ok("O11", nrow(mi) == 4 &&
        setequal(mi$ms_label, c("robma_mu_primary", "bf01_level_primary",
                                "bf01_moderation_primary",
                                "robma_contrast_primary")),
   "ms_input inventory exact (4 pinned labels)")

# ---- O12: not_estimable integrity ------------------------------------
ne <- res[grepl("^not_estimable", res$note), ]
o12 <- TRUE
if (nrow(ne)) {
  o12 <- all(is.na(ne$est_z)) && all(is.na(ne$value)) &&
    all(vapply(ne$note, function(n) any(vapply(NONCONV_SIG, function(s)
      grepl(s, n, ignore.case = TRUE), logical(1))), logical(1)))
}
ok("O12", o12, sprintf("not_estimable rows (%d): numerics NA + listed signature in note",
                       nrow(ne)))

# ---- O13: single-home / absence checks --------------------------------
ok("O13", !any(res$analysis_id %in% c("D3", "B1")) &&
        !any(grepl("^bp_", res$ms_label[!is.na(res$ms_label)])) &&
        !any(grepl("cell_pre|cell_post", res$term)) &&
        all(res$subset %in% c("full", "defined")),
   "no D3/B1 duplication; no bp_ labels; no period cell rows; subset vocab closed")

# ---- O14: framing neutrality ------------------------------------------
ok("O14", !any(grepl("evidence of absence|supports the null|confirms",
                     c(res$note, meta), ignore.case = TRUE)),
   "no adjudication language in notes/run_meta (gate [DEC-044] untouched)")

# ---- Verdict ----------------------------------------------------------
cat(strrep("=", 72), "\n", sep = "")
if (length(FAILS)) {
  cat(sprintf("VERIFIER: %d FAIL\n", length(FAILS)))
  cat(paste0("  - ", FAILS), sep = "\n")
  quit(status = 1)
}
cat("VERIFIER: ALL CHECKS PASS (O0-O14) — exit 0\n")
