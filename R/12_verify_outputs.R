# R/12_verify_outputs.R -- TF verifier [DEC-051]. Independent re-checks; prints V01-V12 PASS/FAIL.
suppressPackageStartupMessages({ library(metafor); library(clubSandwich) })
ok <- c(); chk <- function(id, cond, msg = "") { s <- isTRUE(cond)
  cat(sprintf("%s %s %s\n", id, if (s) "PASS" else "FAIL", msg)); ok <<- c(ok, s) }
res  <- read.csv("output/TF_results.csv",   check.names = FALSE)
loo  <- read.csv("output/TF_loo.csv",       check.names = FALSE, stringsAsFactors = FALSE)
infl <- read.csv("output/TF_influence.csv", check.names = FALSE, stringsAsFactors = FALSE)
meta <- jsonlite::fromJSON("output/TF_run_meta.json")
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
n_ne <- sum(loo$status == "not_estimable")
chk("V07", nrow(loo) == 114 && setequal(loo$cluster_id_dropped, unique(dat$cluster_id)) &&
    all(is.finite(loo$est_z[loo$status == "ok"])) && n_ne <= 5,
    sprintf("TF_loo: 114 rows, cluster-set parity, ok-rows finite, ne=%d <= 5", n_ne))
kcol <- grep("^k_es$|^n_es$|^k$", colnames(res), ignore.case = TRUE, value = TRUE)[1]
scol <- grep("^spec$", colnames(res), ignore.case = TRUE, value = TRUE)[1]
k_rs  <- suppressWarnings(as.numeric(res[[kcol]][res[[scol]] == "outlier_rstudent"]))[1]
k_mad <- suppressWarnings(as.numeric(res[[kcol]][res[[scol]] == "outlier_mad"]))[1]
chk("V08", nrow(infl) == 2713 && is.logical(as.logical(infl$flag_rstudent[1])) &&
    k_rs  == 2713 - sum(infl$flag_rstudent) && k_mad == 2713 - sum(infl$flag_mad),
    sprintf("TF_influence: 2713 rows; drop-count consistency (rstudent %d, mad %d flags)", sum(infl$flag_rstudent), sum(infl$flag_mad)))
pcol <- grep("^p$|^pval|p_value", colnames(res), ignore.case = TRUE, value = TRUE)[1]
pv2 <- suppressWarnings(as.numeric(res[[pcol]])); pv2 <- pv2[is.finite(pv2)]
chk("V09", all(pv2 >= 0 & pv2 <= 1) && nrow(res) <= 40 && meta$fits$total <= 130,
    sprintf("p in [0,1]; rows %d <= 40; fits %d <= 130", nrow(res), meta$fits$total))
qv <- quantile(dat$zi, c(0.01, 0.99), type = 7, names = FALSE)
k_wz <- suppressWarnings(as.numeric(res[[kcol]][res[[scol]] == "winsor"]))[1]
k_tr <- suppressWarnings(as.numeric(res[[kcol]][res[[scol]] == "trim_1_99"]))[1]
chk("V10", all(abs(qv - as.numeric(meta$winsor_q)) < 1e-9) && k_wz == 2713 &&
    k_tr == sum(dat$zi >= qv[1] & dat$zi <= qv[2]),
    "winsor/trim percentile parity (type-7 recompute 1e-9); winsor k=2713; trim k = inside-count")
chk("V11", !any(res[[scol]] == "headline"), "single-home guard: no headline echo row in TF_results")
chk("V12", meta$run == "TF" && meta$seed == 20260710 && file.exists("output/TF_sessionInfo.txt") &&
    setequal(res[[scol]], c("outlier_rstudent", "outlier_mad", "winsor", "trim_1_99")),
    "run meta (TF, seed) + sessionInfo present + planned spec inventory {outlier_rstudent, outlier_mad, winsor, trim_1_99}")
cat(sprintf("TF VERIFIER: %d/%d PASS\n", sum(ok), length(ok)))
if (!all(ok)) quit(status = 1)
