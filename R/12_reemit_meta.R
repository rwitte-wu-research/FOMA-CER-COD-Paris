# R/12_reemit_meta.R -- one-shot deterministic re-emission of TF_run_meta.json [DEC-051b, ERROR #36]
# Repairs the jsonlite digits=4 truncation of winsor_q. The three value artifacts are read-only
# inputs and remain byte-identical. Every recomputable field is recomputed from dat_prep + the
# TF CSVs with hard consistency asserts; ONLY the fields in the console-pin block below are
# sourced from the run console tee (not recomputable from artifacts) and are labeled as such.
# Acceptance: a fresh R/12_verify_outputs.R must print "TF VERIFIER: 12/12 PASS".
suppressPackageStartupMessages({ library(tools) })

## ---- Console-sourced pins (C:\Users\witte\tf_console_run1.log, 2026-07-30/31) [DEC-051b] ----
RUN_START     <- "2026-07-30 21:58:15"   # "F1 rstudent pass started (parallel snow, ncpus=8): 21:58:15"
PASS_MIN      <- 249.4                   # "F1 rstudent pass done: 249.4 min"
FIRST_FIT_MIN <- 0.44                    # "M1 first LOO fit: 0.44 min"
LOO_PARALLEL  <- "PSOCK W=8"             # "M2 LOO complete: 114 fits | not_estimable=0 | PSOCK W=8"
## --------------------------------------------------------------------------------------------

MD5_PIN <- "6702ef3dc45fe0b693b13f50ebd1576b"
stopifnot(unname(md5sum("output/dat_prep.rds")) == MD5_PIN)
dat <- readRDS("output/dat_prep.rds"); if (!is.data.frame(dat)) dat <- dat$dat
dat <- as.data.frame(dat)
stopifnot(nrow(dat) == 2713, length(unique(dat$study)) == 115, length(unique(dat$cluster_id)) == 114)
res  <- read.csv("output/TF_results.csv",   check.names = FALSE)
loo  <- read.csv("output/TF_loo.csv",       check.names = FALSE, stringsAsFactors = FALSE)
infl <- read.csv("output/TF_influence.csv", check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(res) == 4, nrow(loo) == 114, nrow(infl) == 2713)

qz    <- quantile(dat$zi, c(0.01, 0.99), type = 7, names = FALSE)  # bit-identical to the V10 verifier recompute
n_rs  <- sum(infl$flag_rstudent); n_na <- sum(!is.finite(infl$rstudent_t))
n_mad <- sum(infl$flag_mad);      n_ov <- sum(infl$flag_both)
n_out <- sum(dat$zi < qz[1] | dat$zi > qz[2])
kcol <- grep("^k_es$|^n_es$|^k$", colnames(res), ignore.case = TRUE, value = TRUE)[1]
scol <- grep("^spec$", colnames(res), ignore.case = TRUE, value = TRUE)[1]
kv <- function(sp) suppressWarnings(as.numeric(res[[kcol]][res[[scol]] == sp]))[1]
stopifnot(setequal(res[[scol]], c("outlier_rstudent", "outlier_mad", "winsor", "trim_1_99")),
          kv("outlier_rstudent") == 2713 - n_rs,
          kv("outlier_mad")      == 2713 - n_mad,
          kv("winsor")           == 2713,
          kv("trim_1_99")        == 2713 - n_out)
n_ne <- sum(loo$status == "not_estimable")
fits_total <- 3L + nrow(res) + nrow(loo)   # gateA + smoke + spine_full + 4 variants + 114 LOO
stopifnot(fits_total == 121L)              # cross-assert vs console line "121 model fits"

meta <- list(run = "TF", dec = "DEC-051/DEC-051a", date = as.character(Sys.time()),
             reemitted_per = "DEC-051b (ERROR #36); original run start per console tee",
             run_start_console = RUN_START,
             seed = 20260710, dat_md5 = MD5_PIN,
             dom = list(es = 2713L, study = 115L, cluster = 114L),
             thresholds = list(rstudent = 3, mad_k = 3, mad_b = 1.4826,
                               winsor_p = c(0.01, 0.99), quantile_type = 7L),
             winsor_q = as.numeric(qz),
             flags = list(rstudent = n_rs, rstudent_na = n_na, mad = n_mad,
                          overlap = n_ov, winsorized = n_out, trimmed = n_out),
             loo = list(n = nrow(loo), n_ne = n_ne, parallel = LOO_PARALLEL,
                        first_fit_min = FIRST_FIT_MIN),
             rstudent_route = list(parallel = "snow", ncpus = 8L, pass_min = PASS_MIN),
             fits = list(total = fits_total, gateA = 1L, smoke = 1L, spine_full = 1L,
                         variants = nrow(res), loo = nrow(loo)),
             n_rows_results = nrow(res))
writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE, digits = NA), "output/TF_run_meta.json")
chk <- jsonlite::fromJSON("output/TF_run_meta.json")
stopifnot(all(abs(as.numeric(chk$winsor_q) - qz) < 1e-12), chk$fits$total == 121)
cat(sprintf("REEMIT PASS: TF_run_meta.json rewritten (winsor_q = %.17g / %.17g | fits = %d | flags rs/mad/ov = %d/%d/%d)\n",
            qz[1], qz[2], fits_total, n_rs, n_mad, n_ov))
