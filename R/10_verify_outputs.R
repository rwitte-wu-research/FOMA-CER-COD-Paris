# =============================================================================
# R/10_verify_outputs.R — paired verifier for R/10_moderators.R (T7 / Block C)
# Implements the check battery of DEC-043 / DEC-048 / A.14. Exit 0 required.
# Independent re-derivation: this file does not source R/10_moderators.R.
# =============================================================================

suppressPackageStartupMessages({ library(metafor); library(clubSandwich) })
set.seed(20260710)

CHK <- data.frame(id = character(0), desc = character(0), pass = logical(0),
                  stringsAsFactors = FALSE)
check <- function(id, desc, expr) {
  ok <- tryCatch(isTRUE(expr), error = function(e) { message(id, " ERROR: ",
                 conditionMessage(e)); FALSE })
  CHK <<- rbind(CHK, data.frame(id = id, desc = desc, pass = ok))
  cat(sprintf("%-4s %-64s %s\n", id, desc, ifelse(ok, "PASS", "FAIL")))
  invisible(ok)
}

MD5_PIN <- "6702ef3dc45fe0b693b13f50ebd1576b"; RHO <- 0.6
NCE <- "99_NCE"; W_ETS <- "with ETS/CT"; O_ETS <- "without ETS/CT"
F65 <- list(est = -0.0616608386540629, se = 0.0243306602731784, df = 113,
            p = 0.0126367644358383, lb = -0.109864264918875, ub = -0.0134574123892513)
PANEL_COL <- c(C1 = "CER_measure", C2 = "COD_instrument", C3 = "industry", C4 = "regulation3",
               C5 = "country_region", C6 = "country_econ", C7 = "country_culture",
               C8 = "country_legal")
PANEL_L <- c(C1 = 2, C2 = 4, C3 = 2, C4 = 2, C5 = 3, C6 = 2, C7 = 2, C8 = 2)
PIN_MA <- list(C1=c(2713,115,114),C2=c(2713,115,114),C3=c(2260,94,93),C4=c(1804,85,84),
               C5=c(1927,91,91),C6=c(1622,80,79),C7=c(1956,96,95),C8=c(1663,83,82))
PIN_MB <- list(C1=c(2705,113,112),C2=c(2705,113,112),C3=c(2254,93,92),C4=c(1796,83,82),
               C5=c(1919,89,89),C6=c(1614,78,77),C7=c(1948,94,93),C8=c(1655,81,80))
PIN_MPRE <- list(C3=c(1754,74,73), C4=c(1465,64,63))
PIN_V1 <- list(cc=c(1762,80,80), period=c(1754,78,78), post=c(315,19,19))
PIN_V2 <- list(cc=c(1330,58,58), period=c(1324,57,57), post=c(117,9,9))
ABSENCE <- data.frame(panel=c("C2","C5","C8"),
                      ep=c(299,551,612), ep_st=c(10,16,25), ep_cl=c(10,16,24),
                      mp_cl=c(10,15,22))

# --- V01 files ---------------------------------------------------------------
F_RES <- "output/T7_results.csv"; F_C0 <- "output/T7_background_C0.csv"
F_RM <- "output/T7_run_meta.txt"; F_SI <- "output/T7_sessionInfo.txt"
check("V01", "all four T7 outputs + dat_prep + T1/T8 CSVs exist",
      all(file.exists(c(F_RES, F_C0, F_RM, F_SI, "output/dat_prep.rds",
                        "output/T1_results.csv", "output/T8_results.csv"))))

res <- utils::read.csv(F_RES, stringsAsFactors = FALSE, check.names = FALSE)
t8h <- names(utils::read.csv("output/T8_results.csv", nrows = 1, check.names = FALSE))
check("V02", "36-column schema identical to committed T8_results.csv",
      ncol(res) == 36 && identical(names(res), t8h))
check("V03", "row budget == 200", nrow(res) == 200)
key <- paste(res$analysis_id, res$spec, res$subset, res$term, sep = "|")
check("V04", "4-key unique, no missing keys",
      !any(duplicated(key)) && !any(is.na(res$analysis_id) | res$analysis_id == "" |
                                    is.na(res$term) | res$term == ""))

# --- V05-V10 design re-derivation -------------------------------------------
check("V05", "md5(dat_prep) pin",
      identical(unname(tools::md5sum("output/dat_prep.rds")), MD5_PIN))
dp <- readRDS("output/dat_prep.rds"); dat <- as.data.frame(dp$dat)
zi_col <- intersect(c("zi","yi_z","yi"), names(dat))[1]
vi_col <- intersect(c("vi","vi_z"), names(dat))[1]
d <- data.frame(zi = as.numeric(dat[[zi_col]]), vi = as.numeric(dat[[vi_col]]),
                cluster_id = as.character(dat$cluster_id), study = as.character(dat$study),
                esid = as.character(dat$esid), pp = as.integer(dat$pp_mid_lag0),
                sample_mid = as.numeric(dat$sample_mid), stringsAsFactors = FALSE)
for (m in unname(PANEL_COL[c("C1","C2","C3","C5","C6","C7","C8")]))
  d[[m]] <- trimws(as.character(dat[[m]]))
d$regulation3 <- trimws(as.character(dat$regulation_sample_end))
dom <- function(dd) c(nrow(dd), length(unique(dd$study)), length(unique(dd$cluster_id)))
dP <- d[d$pp %in% c(0L,1L), ]
check("V06", "global domains 2713/115/114 · 2705/113/112 · 711/31/31 · 1994/83/82",
      all(dom(d) == c(2713,115,114)) && all(dom(dP) == c(2705,113,112)) &&
      all(dom(dP[dP$pp==1L,]) == c(711,31,31)) && all(dom(dP[dP$pp==0L,]) == c(1994,83,82)))
pcl <- function(sel) length(unique(d$cluster_id[sel & d$pp %in% 1L]))
check("V07", "regulation3 end-anchored post clusters == 14/6/11",
      pcl(d$regulation3==W_ETS)==14 && pcl(d$regulation3==O_ETS)==6 && pcl(d$regulation3==NCE)==11)
ok8 <- TRUE
for (P in names(PANEL_COL)) { cl <- PANEL_COL[[P]]
  ok8 <- ok8 && all(dom(d[d[[cl]]!=NCE,])==PIN_MA[[P]]) && all(dom(dP[dP[[cl]]!=NCE,])==PIN_MB[[P]]) }
for (P in names(PIN_MPRE)) { cl <- PANEL_COL[[P]]
  ok8 <- ok8 && all(dom(d[d$pp %in% 0L & d[[cl]]!=NCE,])==PIN_MPRE[[P]]) }
check("V08", "per-panel M_A/M_B + M-pre domain pins (A.14)", ok8)
check("V09", "ex-ante small-cell pins (CDS0/US1/common2/dev3/rating3/sens3/without6)",
      pcl(d$COD_instrument=="derivativ (CDS spread)")==0 && pcl(d$country_region=="1_US")==1 &&
      pcl(d$country_legal=="1_common law")==2 && pcl(d$country_econ=="1_developed")==3 &&
      pcl(d$COD_instrument=="rating")==3 && pcl(d$industry=="sensitive")==3 &&
      pcl(d$regulation3==O_ETS)==6)
cc1 <- d[d$regulation3!=NCE & d$country_region!=NCE, ]
cc2 <- d[d$industry!=NCE & d$regulation3!=NCE & d$country_region!=NCE &
         d$country_econ!=NCE & d$country_culture!=NCE & d$country_legal!=NCE, ]
check("V10", "C9 V1/V2 complete-case pins",
      all(dom(cc1)==PIN_V1$cc) && all(dom(cc1[cc1$pp %in% c(0L,1L),])==PIN_V1$period) &&
      all(dom(cc1[cc1$pp %in% 1L,])==PIN_V1$post) &&
      all(dom(cc2)==PIN_V2$cc) && all(dom(cc2[cc2$pp %in% c(0L,1L),])==PIN_V2$period) &&
      all(dom(cc2[cc2$pp %in% 1L,])==PIN_V2$post))

# --- V11-V22 results-internal checks ----------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
is_blank <- function(x) is.na(x) | x == ""
ne_rows <- res[res$estimator == "not_estimable", ]
panel_ne <- ne_rows[ne_rows$analysis_id %in% names(PANEL_COL), ]
cds_terms <- c("cell_post::derivativ (CDS spread)", "diff::derivativ (CDS spread)")
cds_ok <- sum(panel_ne$analysis_id == "C2" & panel_ne$term %in% cds_terms) == 2
extra_ne <- panel_ne[!(panel_ne$analysis_id == "C2" & panel_ne$term %in% cds_terms), ]
check("V11", "panel ne: CDS pair present; any further ne rows carry the DEC-049 PD signature",
      cds_ok && all(grepl("DEC-049", extra_ne$note)))

cellmap <- do.call(rbind, lapply(names(PANEL_COL), function(P) { cl <- PANEL_COL[[P]]
  lv <- setdiff(unique(d[[cl]]), NCE)
  do.call(rbind, lapply(lv, function(l) data.frame(P = P, l = l,
    pre = length(unique(dP$cluster_id[dP[[cl]]==l & dP$pp==0L])),
    post = length(unique(dP$cluster_id[dP[[cl]]==l & dP$pp==1L])), stringsAsFactors = FALSE)))}))
est_rows <- res[res$metric == "Fisher_z" & res$estimator == "3LMA-RVE_CR2", ]
descr_flag <- grepl("^descriptive", est_rows$note)
v12a <- all(is_blank(est_rows$p[descr_flag])) && all(is_blank(est_rows$t_stat[descr_flag]))
v12b <- all(!is_blank(est_rows$p[!descr_flag & num(est_rows$df) >= 5]))
v12c <- all(num(est_rows$df[!descr_flag]) >= 5 | is_blank(est_rows$df[!descr_flag]))
cellrows <- est_rows[grepl("^cell_(pre|post)::", est_rows$term) &
                     est_rows$spec == "paris_mid", ]
v12d <- TRUE
for (i in seq_len(nrow(cellrows))) {
  P <- cellrows$analysis_id[i]; l <- sub("^cell_(pre|post)::", "", cellrows$term[i])
  per <- ifelse(grepl("^cell_post", cellrows$term[i]), "post", "pre")
  ncl <- cellmap[cellmap$P == P & cellmap$l == l, per]
  if (length(ncl) == 1 && ncl < 3 && !grepl("^descriptive", cellrows$note[i])) v12d <- FALSE
}
check("V12", "double rule: descriptive rows blank p/t; <3-cluster cells flagged; df<5 => no p",
      v12a && v12b && v12c && v12d)

zonly <- est_rows[grepl("^(pair::|diff::)", est_rows$term) | est_rows$analysis_id == "C9", ]
lvlrows <- est_rows[grepl("^(lvl::|cell_pre::|cell_post::|mpre_int::)", est_rows$term), ]
check("V13", "z-only on pairs/diffs/C9; tanh identity on level/cell rows (1e-12)",
      all(is_blank(zonly$est_r)) &&
      all(abs(num(lvlrows$est_r) - tanh(num(lvlrows$est_z))) < 1e-12, na.rm = TRUE))
pirows <- est_rows[!is_blank(est_rows$pi_lb_z), ]
check("V14", "PI exactly on the 19 M_A level rows; PI encloses CI",
      nrow(pirows) == 19 && all(grepl("^lvl::", pirows$term)) &&
      all(num(pirows$pi_lb_z) <= num(pirows$ci_lb_z) + 1e-12) &&
      all(num(pirows$pi_ub_z) >= num(pirows$ci_ub_z) - 1e-12))
paircnt <- table(factor(est_rows$analysis_id[grepl("^pair::", est_rows$term)],
                        levels = names(PANEL_COL)))
check("V15", "pairwise contrast counts per panel == 1/6/1/1/3/1/1/1",
      all(paircnt == c(1,6,1,1,3,1,1,1)))
hrows <- res[res$term == "interaction_HTZ" & res$spec == "paris_mid", ]
holm <- res[res$term == "interaction_HTZ_holm", ]
h_est <- hrows[hrows$estimator == "3LMA-RVE_CR2", ]
h_ne  <- hrows[hrows$estimator == "not_estimable", ]
padj <- p.adjust(num(h_est$p), method = "holm")
check("V16", "8 interaction HTZ rows; ne only with DEC-049; Holm == min over finite p (recomputed)",
      nrow(hrows) == 8 && nrow(holm) == 1 && all(is.finite(num(h_est$p))) &&
      all(grepl("DEC-049", h_ne$note)) && nrow(h_est) >= 1 &&
      abs(num(holm$value) - min(padj)) < 1e-12 &&
      grepl(paste0("m_effective = ", nrow(h_est), " of 8"), holm$note))
mpre <- res[res$spec == "m_pre", ]
check("V17", "M-pre: 10 rows, domains == pins",
      nrow(mpre) == 10 &&
      all(num(mpre$k_es[mpre$analysis_id=="C3"]) == PIN_MPRE$C3[1]) &&
      all(num(mpre$k_es[mpre$analysis_id=="C4"]) == PIN_MPRE$C4[1]))
aw <- res[res$spec == "paris_mid_anywith", ]
check("V18", "any-with: 7 rows on the pinned C4 M_B domain",
      nrow(aw) == 7 && all(num(aw$k_es[aw$term=="interaction_HTZ"]) == PIN_MB$C4[1]))
ncer <- res[res$term == "nce_excluded", ]
v19 <- nrow(ncer) == 8
for (P in names(PANEL_COL)) { cl <- PANEL_COL[[P]]
  ddn <- dom(d[d[[cl]] == NCE, ])
  r1 <- ncer[ncer$analysis_id == P, ]
  v19 <- v19 && nrow(r1) == 1 && all(num(unlist(r1[c("k_es","k_study","k_cluster")])) == ddn) }
abr <- res[res$term == "end_coding_absence", ]
v19b <- nrow(abr) == 3 && all(num(abr$k_es[match(ABSENCE$panel, abr$analysis_id)]) == ABSENCE$ep) &&
        all(num(abr$value[match(ABSENCE$panel, abr$analysis_id)]) == ABSENCE$mp_cl)
check("V19", "disclosure rows: 8 NCE (re-derived) + 3 coding-absence (frozen constants)",
      v19 && v19b)
echo <- res[res$spec == "design_rule", ]
struct <- echo[grepl("excluded_structural", echo$note), ]
check("V20", "12 rule-echo rows; V2 structural exclusions == the 4 country dims",
      nrow(echo) == 12 && sum(echo$subset == "cc_v1") == 4 && sum(echo$subset == "cc_v2") == 8 &&
      all(struct$subset == "cc_v2") &&
      setequal(sub("^rule::", "", struct$term),
               c("country_region","country_econ","country_culture","country_legal")))
adm <- echo[grepl("verdict = admitted", echo$note), ]
v20b <- TRUE
for (i in seq_len(nrow(echo))) {
  mc <- sub("^rule::", "", echo$term[i]); vr <- echo$subset[i]
  bh <- res[res$term == paste0("block_HTZ::", mc) & res$subset == vr, ]
  admitted <- grepl("verdict = admitted", echo$note[i])
  v20b <- v20b && nrow(bh) == 1 &&
    ((admitted && ((bh$estimator == "3LMA-RVE_CR2" && is.finite(num(bh$t_stat))) ||
                   (bh$estimator == "not_estimable" && grepl("DEC-049", bh$note)))) ||
     (!admitted && bh$estimator == "not_estimable"))
}
check("V21", "rule verdicts consistent with V1/V2 block rows (admitted<->F, excluded<->ne)", v20b)
cnt <- function(sel) sum(sel)
sub_tot <- c(lvl = cnt(grepl("^lvl::", res$term)), pair = cnt(grepl("^pair::", res$term)),
             lHTZ = cnt(res$term == "levels_HTZ"),
             cells = cnt(grepl("^cell_(pre|post)::", res$term) & res$spec == "paris_mid"),
             diffs = cnt(grepl("^diff::", res$term) & res$spec == "paris_mid"),
             iHTZ = cnt(res$term == "interaction_HTZ" & res$spec == "paris_mid"),
             holm = nrow(holm), mpre = nrow(mpre), aw = nrow(aw), nce = nrow(ncer),
             abs = nrow(abr),
             v1 = cnt(res$subset == "cc_v1" & res$spec != "design_rule"),
             v2 = cnt(res$subset == "cc_v2" & res$spec != "design_rule"),
             echo = nrow(echo))
check("V22", "block subtotals 19/15/8/38/19/8/1/10/7/8/3/20/32/12 sum to 200",
      all(sub_tot == c(19,15,8,38,19,8,1,10,7,8,3,20,32,12)) && sum(sub_tot) == 200)

# --- V23-V24 identity gates --------------------------------------------------
t1 <- utils::read.csv("output/T1_results.csv", stringsAsFactors = FALSE, check.names = FALSE)
nt1 <- as.data.frame(suppressWarnings(lapply(t1, as.numeric)))
hits <- which(apply(nt1, 1, function(r) any(abs(r - F65$est) < 1e-9, na.rm = TRUE)))
rowv <- if (length(hits) == 1) suppressWarnings(as.numeric(unlist(nt1[hits, ]))) else NA_real_
near <- function(x, tol = 1e-9) any(abs(rowv - x) < tol, na.rm = TRUE)
es_obj <- escalc(measure = "GEN", yi = zi, vi = vi, data = d)
agg <- aggregate(es_obj, cluster = cluster_id, struct = "CS", rho = RHO)
fA5 <- tryCatch(rma.uni(yi, vi, data = agg, method = "REML", test = "knha"),
                error = function(e) NULL)
check("V23", "F65: A5 row unique by value; se/p/CI/df in-row 1e-9; pinned refit |d|<=1e-6, df 113",
      length(hits) == 1 && near(F65$se) && near(F65$p) && near(F65$lb) && near(F65$ub) &&
      near(F65$df) && !is.null(fA5) && nrow(agg) == 114 &&
      abs(as.numeric(fA5$beta) - F65$est) <= 1e-6 && abs(fA5$se - F65$se) <= 1e-6 &&
      abs(fA5$pval - F65$p) <= 1e-6 && (fA5$k - 1) == 113)
bV <- function(dd) { n <- nrow(dd); V <- matrix(0, n, n); diag(V) <- dd$vi
  for (ix in split(seq_len(n), dd$cluster_id)) if (length(ix) > 1L) {
    s <- sqrt(dd$vi[ix]); B <- RHO * tcrossprod(s); diag(B) <- dd$vi[ix]; V[ix, ix] <- B }
  V }
fH <- tryCatch(rma.mv(yi = d$zi, V = bV(d), random = ~ 1 | cluster_id/study/esid,
                      data = d, method = "REML", sparse = TRUE), error = function(e) NULL)
found <- function(x, tol) any(abs(as.matrix(nt1) - x) < tol, na.rm = TRUE)
check("V24", "3L headline refit: est + all three variance components found in T1_results (1e-6)",
      !is.null(fH) && found(as.numeric(fH$beta), 1e-6) &&
      length(fH$sigma2) == 3 && all(vapply(fH$sigma2, found, logical(1), tol = 1e-6)))

# --- V25-V27 hygiene ---------------------------------------------------------
check("V25", "single-home: analysis_id set == {C1..C8, C9, C_family}; no C0 in results",
      setequal(unique(res$analysis_id), c(paste0("C", 1:8), "C9", "C_family")))
c0 <- utils::read.csv(F_C0, stringsAsFactors = FALSE)
check("V26", "C0 file: 56 rows (28 pairs x 2 bases), V in [0,1]",
      nrow(c0) == 56 && setequal(unique(c0$basis), c("es_level","cluster_modal")) &&
      all(num(c0$cramers_v) >= 0 & num(c0$cramers_v) <= 1 + 1e-12, na.rm = TRUE))
rm_txt <- readLines(F_RM, warn = FALSE)
check("V27", "run_meta: seed, md5, COSTPROBE, >=20 FIT certificates, 2 hardening lines; sessionInfo nonempty",
      any(grepl("seed = 20260710", rm_txt)) && any(grepl(MD5_PIN, rm_txt)) &&
      any(grepl("\\[COSTPROBE\\]", rm_txt)) && sum(grepl("^FIT ", rm_txt)) >= 20 &&
      sum(grepl("hardening refit", rm_txt)) == 2 && file.size(F_SI) > 0)

# --- summary -----------------------------------------------------------------
cat(sprintf("\n[T7-VERIFY] %d/%d PASS\n", sum(CHK$pass), nrow(CHK)))
if (!all(CHK$pass)) { cat("FAILED:", paste(CHK$id[!CHK$pass], collapse = ", "), "\n")
  quit(save = "no", status = 1) }
quit(save = "no", status = 0)
