# =============================================================================
# R/17_dropset_item18.R -- combined drop-set sensitivity (Readiness Item 18,
# extended per author ruling R-A / DEC-063 (v)); S1 window, 2026-08-07.
# -----------------------------------------------------------------------------
# RESULT-BLIND: spec sheet, drop list, every assert and the register mechanics
# were frozen before execution (S1 design review; hub FREEZE 2026-08-07).
# Fit path mirrors R/01_core.R section 3 verbatim (fit_3lma / rob_stats:
# CHE rho = 0.6, V blocks on cluster_id, CR2 Satterthwaite) on the remainder.
# Register (output/robustness_register.csv, basis md5-bound): appends TWO rows
#   headline_v12_1          -- post-erratum anchor [R3 ruling, option (ii)]
#   dropset_item18_extended -- this sensitivity; delta vs headline_v12_1
# and amends the pre-erratum anchor note (R3 Auflage a-c: anchor semantics
# secured mechanically, not positionally). Old rows stay byte-identical.
# Run route: RStudio -- setwd("C:/R_Projects/FOMA-CER-COD-Paris");
#            source(".Rprofile"); source("R/17_dropset_item18.R")
# =============================================================================
suppressPackageStartupMessages({ library(metafor); library(clubSandwich); library(here) })

REG   <- here::here("output", "robustness_register.csv")
T1CSV <- here::here("output", "T1_results.csv")
RDS   <- here::here("output", "dat_prep.rds")
REG_MD5_PRE <- "49fd8e9b5228ce137df904c9f45b42cd"   # committed basis [P3 design]
RHO_HEADLINE <- 0.6                                  # [DEC-017]

fail <- function(...) stop(paste0("[R17 ASSERT FAIL] ", ...), call. = FALSE)
ok   <- function(cond, msg) if (!isTRUE(cond)) fail(msg) else message("[ok] ", msg)

# ---- 1. basis binding --------------------------------------------------------
ok(file.exists(REG) && file.exists(T1CSV) && file.exists(RDS), "inputs present")
ok(identical(unname(tools::md5sum(REG)), REG_MD5_PRE),
   paste0("register basis md5 == ", REG_MD5_PRE))
reg_raw <- readLines(REG, warn = FALSE)
ok(length(reg_raw) == 24, "register = header + 23 rows")
ok(!any(grepl("headline_v12_1", reg_raw, fixed = TRUE)) &&
   !any(grepl("dropset_item18_extended", reg_raw, fixed = TRUE)),
   "new spec names unused")
HEADLINE_LINE_PRE <- paste0(
  "headline,T1,2713,115,114,-0.058646736610098,-0.0861025946387978,",
  "-0.0311908785813981,-0.0585795916799434,-0.085890445375146,",
  "-0.0311807676166034,0.0,TRUE,TRUE,TRUE,",
  "\"main text, Block A core (T1 workbook A1)\",reference,",
  "T1-A1 anchor for all delta columns [DEC-050 \u00a710]")
ok(identical(reg_raw[2], HEADLINE_LINE_PRE), "pre-erratum anchor line byte-identical to pin")

# ---- 2. post-erratum anchor from the committed T1 CSV ------------------------
t1 <- read.csv(T1CSV, stringsAsFactors = FALSE)
hl <- t1[t1$analysis_id == "A1" & t1$spec == "headline", ]
ok(nrow(hl) == 1, "A1 headline row unique in T1_results.csv")
ok(hl$k_es == 2713 && hl$k_study == 115 && hl$k_cluster == 113,
   "anchor k = 2713/115/113 [DEC-063]")
ok(abs(hl$est_z - (-0.058921)) < 1e-4, "anchor est_z within coarse v12.1 pin")

# ---- 3. dat_prep contract ----------------------------------------------------
pr <- readRDS(RDS); dat <- pr$dat
ok(identical(as.integer(pr$n), 2713L) && identical(as.integer(pr$seed), 20260710L),
   "pr contract n/seed")
message("[rec] dat_prep md5: ", unname(tools::md5sum(RDS)))
ok(nrow(dat) == 2713 && length(unique(dat$study)) == 115 &&
   length(unique(as.character(dat$cluster_id))) == 113, "rds census 2713/115/113")

# ---- 4. frozen drop set + per-entity incumbent-asserts -----------------------
DROP <- data.frame(
  cluster = c("Du et al (2022)", "CLUSTER Sandra/Ofogbe", "Zhou et al (2018)",
              "Azmi et al (2021)", "Cicchini et al (2026)",
              "CLUSTER Pizzutilo/Caragnano"),
  es = c(2L, 5L, 22L, 3L, 20L, 25L),
  st = c(1L, 2L, 1L, 1L, 1L, 2L), stringsAsFactors = FALSE)
cl <- as.character(dat$cluster_id)
for (i in seq_len(nrow(DROP))) {
  sub <- dat[cl == DROP$cluster[i], ]
  ok(nrow(sub) == DROP$es[i] && length(unique(sub$study)) == DROP$st[i],
     sprintf("drop entity '%s': %d ES / %d studies", DROP$cluster[i],
             DROP$es[i], DROP$st[i]))
}
ok(sum(DROP$es) == 77L && sum(DROP$st) == 8L && nrow(DROP) == 6L,
   "drop totals 77 ES / 8 studies / 6 clusters")

keep <- !(cl %in% DROP$cluster)
dd <- data.frame(yi = as.numeric(dat$zi[keep]), vi = as.numeric(dat$vi[keep]),
                 cluster = factor(as.character(dat$cluster_id[keep])),
                 study = factor(as.character(dat$study[keep])),
                 esid = factor(as.character(dat$esid[keep])))
ok(nrow(dd) == 2636 && nlevels(dd$study) == 107 && nlevels(dd$cluster) == 107,
   "remainder 2,636 ES / 107 studies / 107 clusters")
ok(nlevels(dd$study) == nlevels(dd$cluster),
   "remainder studies == clusters (all multi-study clusters in the drop set)")

# ---- 5. fit path: verbatim mirror of R/01_core.R section 3 -------------------
`%||%` <- function(a, b) if (is.null(a)) b else a
pick_df <- function(x) as.numeric(x$df_Satt %||% x$df)
fit_3lma <- function(dd, rho) {
  V <- clubSandwich::impute_covariance_matrix(vi = dd$vi, cluster = dd$cluster, r = rho)
  metafor::rma.mv(yi = yi, V = V, random = ~ 1 | cluster/study/esid,
                  data = dd, sparse = TRUE, method = "REML")
}
rob_stats <- function(m, dd) {
  ct <- clubSandwich::coef_test(m, vcov = "CR2", cluster = dd$cluster,
                                test = "Satterthwaite")
  ci <- clubSandwich::conf_int(m, vcov = "CR2", cluster = dd$cluster)
  list(est = as.numeric(ct$beta[1]), se = as.numeric(ct$SE[1]),
       df = pick_df(ct)[1], ci_lb = as.numeric(ci$CI_L[1]),
       ci_ub = as.numeric(ci$CI_U[1]))
}
m <- fit_3lma(dd, RHO_HEADLINE)
s <- rob_stats(m, dd)

# ---- 6. compose the two register rows (frozen mechanics) ---------------------
q15 <- function(x) sprintf("%.15g", x)
qf  <- function(x) if (grepl('[,"]', x)) paste0('"', gsub('"', '""', x), '"') else x
mkline <- function(spec, k_es, k_st, k_cl, ez, lz, uz, er, lr, ur, delta,
                   f1, f2, f3, rep_in, status, note)
  paste(spec, "T1", k_es, k_st, k_cl, q15(ez), q15(lz), q15(uz),
        q15(er), q15(lr), q15(ur), delta, f1, f2, f3,
        qf(rep_in), status, qf(note), sep = ",")

anchor_line <- mkline("headline_v12_1", 2713, 115, 113,
  hl$est_z, hl$ci_lb_z, hl$ci_ub_z, hl$est_r, hl$ci_lb_r, hl$ci_ub_r, "0.0",
  "TRUE", "TRUE", "TRUE",
  "main text, Block A core (T1 v12.1 re-run, Commit B 8bf2221)",
  "reference",
  "T1-A1 anchor for post-erratum (v12.1) rows [DEC-063; R3 option (ii)]")

delta  <- s$est - hl$est_z
est_r  <- tanh(s$est); ci_lb_r <- tanh(s$ci_lb); ci_ub_r <- tanh(s$ci_ub)
f_sign <- isTRUE(sign(s$est) == sign(hl$est_z))
f_ci   <- isTRUE(s$ci_ub < 0 || s$ci_lb > 0)
f_ses  <- isTRUE(abs(est_r) < 0.070)
drop_note <- paste0("Combined drop-set [Item 18; extended result-blind ",
  "2026-08-07, author ruling R-A / DEC-063 (v)]: Du et al (2022) + ",
  "CLUSTER Sandra/Ofogbe + defective-descriptives trio (Zhou et al 2018, ",
  "Azmi et al 2021, Cicchini et al 2026) + CLUSTER Pizzutilo/Caragnano ",
  "(merge bound); removes 77 ES / 8 studies / 6 clusters; remainder ",
  "studies == clusters; reported unconditionally; delta vs headline_v12_1")
drop_line <- mkline("dropset_item18_extended", 2636, 107, 107,
  s$est, s$ci_lb, s$ci_ub, est_r, ci_lb_r, ci_ub_r, sprintf("%.4f", delta),
  ifelse(f_sign, "TRUE", "FALSE"), ifelse(f_ci, "TRUE", "FALSE"),
  ifelse(f_ses, "TRUE", "FALSE"),
  "main text \u00a74.1.2 (unconditional; DEC-063 (v))", "populated", drop_note)

amended2 <- paste0(HEADLINE_LINE_PRE, " \u2014 pre-erratum anchor (rows above)")
out <- c(reg_raw[1], amended2, reg_raw[3:24], anchor_line, drop_line)

# ---- 7. write + post-write verification (R3 Auflage c mechanical) ------------
con <- file(REG, open = "wb")
writeLines(out, con, sep = "\r\n"); close(con)
chk <- read.csv(REG, stringsAsFactors = FALSE)
ok(nrow(chk) == 25, "register now 25 rows")
ok(sum(chk$spec == "headline_v12_1") == 1 &&
   sum(chk$spec == "dropset_item18_extended") == 1, "both new specs unique")
arow <- chk[chk$spec == "headline_v12_1", ]
prow <- chk[chk$spec == "dropset_item18_extended", ]
ok(abs(prow$delta_vs_headline_z - (prow$est_z - arow$est_z)) < 5e-5,
   "delta column == est_z(drop) - est_z(headline_v12_1) [R3 Auflage c]")
ok(grepl("delta vs headline_v12_1", prow$note, fixed = TRUE),
   "note ends on the v12.1-anchor reference [R3 Auflage a]")
ok(grepl("pre-erratum anchor", chk$note[chk$spec == "headline"], fixed = TRUE),
   "pre-erratum anchor note amended [R3 Auflage b]")

message("\n==== R17 SUMMARY (report unconditionally) ====")
message(sprintf("dropset_item18_extended: est_z %.6f  CI_z [%.6f; %.6f]  df %.1f",
                s$est, s$ci_lb, s$ci_ub, s$df))
message(sprintf("  r %.4f  CI_r [%.4f; %.4f]  delta_z %+.4f", est_r, ci_lb_r, ci_ub_r, delta))
message(sprintf("  flags: sign_retained %s | ci_excl_0 %s | inside_sesoi %s",
                f_sign, f_ci, f_ses))
message("register post md5: ", unname(tools::md5sum(REG)))
message("[R17 DONE] ALL ASSERTS PASS -- register 23 -> 25 rows")
