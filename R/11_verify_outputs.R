# R/11_verify_outputs.R -- TG verifier [DEC-050]. Independent re-checks; prints V01-V12 PASS/FAIL.
suppressPackageStartupMessages({ library(metafor); library(clubSandwich) })
ok <- c(); chk <- function(id, cond, msg = "") { s <- isTRUE(cond)
  cat(sprintf("%s %s %s\n", id, if (s) "PASS" else "FAIL", msg)); ok <<- c(ok, s) }
res <- read.csv("output/TG_results.csv", check.names = FALSE)
meta <- jsonlite::fromJSON("output/TG_run_meta.json")
hdr7 <- colnames(read.csv("output/T7_results.csv", nrows = 1, check.names = FALSE))
chk("V01", identical(colnames(res), hdr7), "36-col header parity vs T7_results.csv")
keycols <- intersect(c("analysis_id", "spec", "subset", "term"), colnames(res))
key <- do.call(paste, c(res[keycols], sep = "|"))
chk("V02", !any(duplicated(key)), "AK key uniqueness (analysis_id|spec|subset|term)")
DAT_CANDIDATES <- c("output/dat_prep.rds", "data/dat_prep.rds", "output/dat_prep.RDS")
hit <- DAT_CANDIDATES[file.exists(DAT_CANDIDATES)]
hit <- hit[vapply(hit, function(p) unname(tools::md5sum(p)) == "6702ef3dc45fe0b693b13f50ebd1576b", logical(1))]
chk("V03", length(hit) == 1, "dat_prep md5 pin"); dat <- as.data.frame(readRDS(hit[1]))
chk("V04", nrow(dat) == 2713 && length(unique(dat$study)) == 115 && length(unique(dat$cluster_id)) == 114, "domain 2713/115/114")
es <- escalc(measure = "GEN", yi = dat$zi, vi = dat$vi, data = dat)
agg <- aggregate(es, cluster = cluster_id, struct = "CS", rho = 0.6)
gA <- rma.uni(yi, vi, data = agg, method = "REML", test = "knha")
chk("V05", abs(unname(gA$beta[1]) - (-0.0616608386540629)) < 1e-9 && gA$dfs == 113, "Gate A re-check (F65 by value)")
V <- impute_covariance_matrix(dat$vi, cluster = dat$cluster_id, r = 0.6)
f3 <- rma.mv(yi = dat$zi, V = V, data = dat, random = ~ 1 | cluster_id / study / esid, method = "REML", sparse = TRUE)
chk("V06", abs(round(unname(f3$beta[1]), 3) - (-0.062)) < 1e-9, sprintf("Gate B 3L headline canary -0.062 (got %.4f)", unname(f3$beta[1])))
chk("V07", sum(dat$es_method == "star-bound") == 99, "G1 definition count 99")
pfc <- meta$proxyfill_col; pv <- dat[[pfc]]; pv <- if (is.logical(pv)) pv else pv %in% c(1, "1", TRUE, "TRUE", "yes")
chk("V08", sum(pv) == 297, sprintf("G2 proxy-fill count 297 via '%s'", pfc))
chk("V09", meta$adj_int_share >= 0.99, sprintf("G3 adjustment-recovery integer share %.4f >= .99", meta$adj_int_share))
lev_ok <- length(setdiff(unique(dat$q_VHB), c("1_VHB high", "0_VHB low", "99_NCE"))) == 0
chk("V10", lev_ok, "G7 level set {high, low, 99_NCE}")
pcol <- grep("^p$|^pval|p_value", colnames(res), ignore.case = TRUE, value = TRUE)[1]
pv2 <- suppressWarnings(as.numeric(res[[pcol]])); pv2 <- pv2[is.finite(pv2)]
chk("V11", all(pv2 >= 0 & pv2 <= 1) && nrow(res) <= 60, sprintf("p in [0,1]; budget %d <= 60", nrow(res)))
d_g4 <- dat[dat$es_method == "bivariate", ]; d_g9 <- dat[dat$ES_measure == "bivariate", ]
chk("V12", nrow(d_g9) - nrow(d_g4) == 2 && length(unique(d_g9$study)) - length(unique(d_g4$study)) == 1,
    "G4/G9 near-identity delta (2 ES / 1 study)")
cat(sprintf("TG VERIFIER: %d/%d PASS\n", sum(ok), length(ok)))
if (!all(ok)) quit(status = 1)
