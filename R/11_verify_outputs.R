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
DAT_CANDIDATES <- c("output/dat_prep.rds", "data/dat_prep.rds")  # .RDS variant removed (case-insensitive NTFS duplicate hit, mirrors main-script fixzone)
hit <- DAT_CANDIDATES[file.exists(DAT_CANDIDATES)]
hit <- hit[vapply(hit, function(p) unname(tools::md5sum(p)) == "6702ef3dc45fe0b693b13f50ebd1576b", logical(1))]
chk("V03", length(hit) == 1, "dat_prep md5 pin"); dat <- readRDS(hit[1])
if (!is.data.frame(dat)) dat <- dat$dat   # accessor fix: dat_prep.rds is a container list(dat, built, seed, n, sessionInfo)
dat <- as.data.frame(dat)
chk("V04", nrow(dat) == 2713 && length(unique(dat$study)) == 115 && length(unique(dat$cluster_id)) == 114, "domain 2713/115/114")
es <- escalc(measure = "GEN", yi = dat$zi, vi = dat$vi, data = dat)
agg <- aggregate(es, cluster = cluster_id, struct = "CS", rho = 0.6)
gA <- rma.uni(yi, vi, data = agg, method = "REML", test = "knha")
chk("V05", abs(unname(gA$beta[1]) - (-0.0616608386540629)) < 1e-9 && gA$dfs == 113, "Gate A re-check (F65 by value)")
V <- impute_covariance_matrix(dat$vi, cluster = dat$cluster_id, r = 0.6)
f3 <- rma.mv(yi = dat$zi, V = V, data = dat, random = ~ 1 | cluster_id / study / esid, method = "REML", sparse = TRUE)
# V06 [DEC-050c]: Gate-B match vs committed T1_results.csv; row located by label key (value uniqueness dropped per O20/F55 A1==A3 identity)
t1 <- utils::read.csv("output/T1_results.csv", stringsAsFactors = FALSE, check.names = FALSE)
nt1 <- as.data.frame(suppressWarnings(lapply(t1, as.numeric)))
hits <- if ("analysis_id" %in% colnames(t1)) which(t1$analysis_id == "A1") else which(t1$spec == "headline")
if (length(hits) != 1) stop(sprintf("[S-V06] label-key row (analysis_id=='A1' / spec=='headline') not unique in T1_results.csv (hits = %d)", length(hits)), call. = FALSE)
found <- function(x, tol) any(abs(as.matrix(nt1) - x) < tol, na.rm = TRUE)
chk("V06", abs(as.numeric(f3$beta) - as.numeric(t1$est_z[hits])) <= 1e-6 && length(f3$sigma2) == 3 &&
    all(vapply(f3$sigma2, found, logical(1), tol = 1e-6)),
    sprintf("Gate B [DEC-048/DEC-050c]: 3L refit |est - est_z| <= 1e-6 on label row %d (A1 headline); all three sigma2 found (1e-6)", hits))
chk("V07", sum(dat$es_method == "star-bound") == 99, "G1 definition count 99")
pfc <- meta$proxyfill_col; pv <- dat[[pfc]]; pv <- if (is.logical(pv)) pv else pv %in% c(1, "1", TRUE, "TRUE", "yes")
chk("V08", sum(pv) == 296, sprintf("G2 proxy-fill count 296 via '%s' [DEC-050a]", pfc))
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
