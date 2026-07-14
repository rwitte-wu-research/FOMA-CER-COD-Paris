# =============================================================================
# R/02_paris.R -- T2 / Block B coding layer (B1, B3, B6, B7): Paris headline
# binary, coding sensitivities, post-cell LOSO, disclosures
# FOMA CER-COD (Paris moderator)
# -----------------------------------------------------------------------------
# Spec: docs/T2_spec.md (FROZEN, Rev. 2026-07-13b incl. F58 erratum 93 -> 96).
# Decision basis / source pointers:
#   [DEC-024]   headline cut pp_mid_lag0 + ties->Post recut rule.
#   [DEC-031 Annex B] battery roles; [DEC-031a] .5 upgrades fired (clean-window
#               df 12.3 >= 5 -> full inference); .6 inference conventions (no
#               pairwise spec-vs-headline tests; each coding model carries its
#               OWN moderator inference); .7 no T2 figures; .9 pp_share_lag0 =
#               continuous dose == share_2016.
#   [DEC-042/042a] v12 canonical; estimation set 2,713 ES / 115 studies /
#               114 clusters (asserted constants).
#   [DEC-042b]  8 ES / 2 studies without recoverable windows: per-coding NAs
#               are a DESIGN FACT; estimation domain for every coding-based
#               analysis = complete cases on that coding (k = 2,705); the full
#               set is never re-filtered otherwise.
#   [F55-F57 conventions carry over; F56 V blocks on cluster_id]
#   [plan par.6 + Addendum A.3] tie-break variant; design facts: df(pp_mid) =
#               31.9 (transfer rule NOT triggered -> binary carries full
#               inference); post cell = 31 studies.
# Model machinery identical to T1 (spec par.2, frozen): Fisher-z scale; V =
#   impute_covariance_matrix(vi, cluster = cluster_id, r = 0.6); rma.mv with
#   random = ~1|cluster_id/study/esid, sparse, REML; CR2 + Satterthwaite on
#   cluster_id. Per coding model three rows: cell_pre / cell_post / diff
#   (single fit ~ 0 + factor(coding); diff via CR2 linear contrast). Cell rows
#   carry both scales; DIFF ROWS ARE Z-SCALE ONLY (est_r = NA; difference of
#   Fisher-z means; no tanh transform of differences).
# NO figures [DEC-031a.7]. NO prediction intervals (A3 owns them).
# Conventions fixed a priori; NO result-dependent branching anywhere below.
# Output contract [spec par.4]: output/T2_results.csv (T1 schema + `term`
#   after `subset`; 36 columns) + output/T2_run_meta.txt.
# Paired verifier: R/02_verify_outputs.R (checks O1-O17).
# =============================================================================

# ---- 0. CONFIG: frozen constants [spec par.1; STOP S4 on any change] ---------
PATH_DAT_PREP <- here::here("output", "dat_prep.rds")   # T0.4 product
DIR_OUT       <- here::here("output")

REQUIRED_COLS <- c("zi", "vi", "cluster_id", "study", "esid", "n_eff",
                   "pp_mid_lag0", "pp_median_lag0",
                   "pp_end_lag0", "pp_end_lag1", "pp_end_lag2", "pp_end_lag3",
                   "share_2016", "share_2017", "share_2018", "share_2019",
                   "pp_share_lag0", "pp_window_class")

K_ES <- 2713L; K_STUDY <- 115L; K_CLUSTER <- 114L; K_STUDY_POST <- 31L
K_PERIOD_NA <- 8L; K_PERIOD_NA_STUDY <- 2L   # per coding column [DEC-042b]
RHO  <- 0.6                                   # [DEC-017/F56]
SEED <- 20260710                              # deterministic; set defensively

# Window-derived codings under the DEC-042b 8-NA/2-study assert [spec par.1]
CODING_COLS <- c("pp_mid_lag0", "pp_median_lag0",
                 "pp_end_lag0", "pp_end_lag1", "pp_end_lag2", "pp_end_lag3",
                 "share_2016", "share_2017", "share_2018", "share_2019",
                 "pp_window_class")

# <<< P5 STRING-LITERAL FIX ZONE (the ONLY permitted in-run adaptation) >>>
# pp_window_class level mapping resolved 2026-07-13 from dat_prep levels
# {"pre-only", "post-only", "mixed", NA} cross-checked against
# output/design_quantities_v12.csv clean_window row (k_pre 611 / k_post 318):
CLEAN_PRE_LEVEL  <- "pre-only"    # pure-pre windows
CLEAN_POST_LEVEL <- "post-only"   # pure-post windows (clean-post = 1)
# <<< end P5 fix zone >>>

# ---- 1. Libraries & session ---------------------------------------------------
suppressPackageStartupMessages({
  library(metafor)       # 5.0.1 per renv lockfile
  library(clubSandwich)  # 0.7.0 per renv lockfile
})
set.seed(SEED)
dir.create(DIR_OUT, showWarnings = FALSE, recursive = TRUE)
t_start <- Sys.time()

# ---- 2. Load + input contract (fail fast; violations = STOP S2) ----------------
if (!file.exists(PATH_DAT_PREP))
  stop("output/dat_prep.rds not found. Run R/00_prep.R + R/00_verify_prep.R ",
       "first (T0.4). STOP condition -- do not improvise paths.")
pr <- readRDS(PATH_DAT_PREP)
if (!is.list(pr) || is.null(pr$dat))
  stop("dat_prep.rds is not the R/00_prep.R list contract (pr$dat missing). ",
       "STOP condition S2.")
stopifnot(
  "pr$n != 2713 [DEC-042a]" = identical(as.integer(pr$n), K_ES),
  "pr$seed != 20260710"     = identical(as.integer(pr$seed), 20260710L)
)
dat <- pr$dat

missing_cols <- setdiff(REQUIRED_COLS, names(dat))
if (length(missing_cols))
  stop("dat_prep schema contract violated -- missing column(s): ",
       paste(missing_cols, collapse = ", "), ". STOP condition S2, do not patch.")

stopifnot(
  "estimation set != 2713 [DEC-042a]" = nrow(dat) == K_ES,
  "study count != 115"   = length(unique(dat$study))      == K_STUDY,
  "cluster count != 114" = length(unique(dat$cluster_id)) == K_CLUSTER,
  "NA in zi/vi"          = !anyNA(dat$zi) && !anyNA(dat$vi),
  "non-positive vi"      = all(dat$vi > 0)
)

# DEC-042b generalization: EXACTLY 8 NA over EXACTLY the same 2 studies,
# for every window-derived coding column actually used [spec par.1].
na_studies_ref <- NULL
for (cc in CODING_COLS) {
  na_idx <- is.na(dat[[cc]])
  if (sum(na_idx) != K_PERIOD_NA)
    stop("DEC-042b violated: ", cc, " has ", sum(na_idx), " NA (expected 8). S2.")
  st <- sort(unique(as.character(dat$study[na_idx])))
  if (length(st) != K_PERIOD_NA_STUDY)
    stop("DEC-042b violated: ", cc, " NAs span ", length(st), " studies (expected 2). S2.")
  if (is.null(na_studies_ref)) na_studies_ref <- st
  if (!identical(st, na_studies_ref))
    stop("DEC-042b violated: ", cc, " NA studies differ from other codings. S2.")
}

# Semantics pins P1/P3/P4 (fail-fast; also verified independently in O6-O8) ----
pm <- as.integer(as.character(dat$pp_mid_lag0))     # factor-safe 0/1
md <- as.integer(as.character(dat$pp_median_lag0))
stopifnot(
  "pp_mid values outside {0,1,NA}"    = all(pm[!is.na(pm)] %in% c(0L, 1L)),
  "pp_median values outside {0,1,NA}" = all(md[!is.na(md)] %in% c(0L, 1L))
)
# P1: pp_share_lag0 CONTINUOUS and identical to share_2016 [DEC-031a.9]
stopifnot(
  "P1: NA patterns differ"  = identical(is.na(dat$pp_share_lag0), is.na(dat$share_2016)),
  "P1: pp_share_lag0 != share_2016 (tol 1e-12)" =
    max(abs(dat$pp_share_lag0 - dat$share_2016), na.rm = TRUE) <= 1e-12,
  "P1: not continuous (<= 2 distinct values)" =
    length(unique(dat$pp_share_lag0[!is.na(dat$pp_share_lag0)])) > 2L
)
# P3: (share_2016 >= 0.5) ties->Post reproduces pp_mid_lag0 exactly [DEC-024]
rc16 <- ifelse(is.na(dat$share_2016), NA_integer_, as.integer(dat$share_2016 >= 0.5))
stopifnot(
  "P3: recut NA pattern differs from pp_mid" = identical(is.na(rc16), is.na(pm)),
  "P3: canonical recut != pp_mid_lag0"       = all(rc16 == pm, na.rm = TRUE)
)
# P4: tie-break variant disagrees with pp_mid only on exact-0.5 rows [plan par.6]
p4_dis <- which(!is.na(pm) & !is.na(md) & pm != md)
stopifnot(
  "P4: disagreement off the 0.5 knife edge" = all(dat$share_2016[p4_dis] == 0.5)
)
P4_COUNT <- length(p4_dis)

# P5: clean-window levels present in the data
stopifnot(
  "P5: mapped clean levels absent from pp_window_class" =
    all(c(CLEAN_PRE_LEVEL, CLEAN_POST_LEVEL) %in%
          unique(as.character(dat$pp_window_class)))
)

# Post cell [design fact: 31 studies]
post_studies <- sort(unique(as.character(dat$study[!is.na(pm) & pm == 1L])))
stopifnot("post-cell studies != 31 [design]" = length(post_studies) == K_STUDY_POST)

# ---- 3. Helpers (frozen) --------------------------------------------------------
`%||%` <- function(a, b) if (is.null(a)) b else a
pick_df <- function(x) as.numeric(x$df_Satt %||% x$df)

SCHEMA <- c("analysis_id", "spec", "subset", "term", "metric", "estimator", "rho",
            "k_es", "k_study", "k_cluster",
            "est_z", "se_z", "t_stat", "df", "p",
            "ci_lb_z", "ci_ub_z", "pi_lb_z", "pi_ub_z",
            "est_r", "ci_lb_r", "ci_ub_r", "pi_lb_r", "pi_ub_r",
            "sigma2_cluster", "sigma2_study", "sigma2_esid",
            "pct_cluster", "pct_study", "pct_esid", "pct_sampling", "typical_v",
            "value", "ms_input", "ms_label", "note")   # T1 schema + term [spec par.4]

new_row <- function(...) {
  r <- setNames(as.list(rep(NA, length(SCHEMA))), SCHEMA)
  a <- list(...); r[names(a)] <- a
  as.data.frame(r, stringsAsFactors = FALSE)
}

# Single coding-model fit [spec par.2]: ~ 0 + factor(coding) for cell means,
# CR2/Satterthwaite linear contrast (post - pre) for the diff.
fit_coding <- function(dd) {
  V <- clubSandwich::impute_covariance_matrix(vi = dd$vi, cluster = dd$cluster,
                                              r = RHO)
  m <- metafor::rma.mv(yi = yi, V = V, mods = ~ 0 + cod,
                       random = ~ 1 | cluster/study/esid,
                       data = dd, sparse = TRUE, method = "REML")
  ct <- clubSandwich::coef_test(m, vcov = "CR2", cluster = dd$cluster,
                                test = "Satterthwaite")
  ci <- clubSandwich::conf_int(m, vcov = "CR2", cluster = dd$cluster)
  lc <- clubSandwich::linear_contrast(m, vcov = "CR2", cluster = dd$cluster,
                                      contrasts = matrix(c(-1, 1), nrow = 1),
                                      test = "Satterthwaite", p_values = TRUE)
  cell <- function(i) list(est = as.numeric(ct$beta[i]), se = as.numeric(ct$SE[i]),
                           t = as.numeric(ct$tstat[i]), df = pick_df(ct)[i],
                           p = as.numeric(ct$p_Satt[i]),
                           ci_lb = as.numeric(ci$CI_L[i]), ci_ub = as.numeric(ci$CI_U[i]))
  list(pre = cell(1L), post = cell(2L),
       diff = list(est = as.numeric(lc$Est[1]), se = as.numeric(lc$SE[1]),
                   t = as.numeric(lc$Est[1]) / as.numeric(lc$SE[1]),
                   df = as.numeric(lc$df[1]), p = as.numeric(lc$p_val[1]),
                   ci_lb = as.numeric(lc$CI_L[1]), ci_ub = as.numeric(lc$CI_U[1])),
       sigma2 = as.numeric(m$sigma2))
}

# Build the model frame for a 0/1 coding vector over the full 2,713-row set;
# domain = complete cases on that coding [DEC-042b].
make_dd <- function(cod) {
  keep <- !is.na(cod)
  data.frame(
    yi      = as.numeric(dat$zi[keep]),
    vi      = as.numeric(dat$vi[keep]),
    cluster = factor(dat$cluster_id[keep]),
    study   = factor(dat$study[keep]),
    esid    = factor(dat$esid[keep]),
    cod     = factor(cod[keep], levels = c(0L, 1L))   # level order pins cell order
  )
}

cellk <- function(dd, lev) {
  i <- dd$cod == lev
  list(k_es = sum(i),
       k_study = length(unique(as.character(dd$study[i]))),
       k_cluster = length(unique(as.character(dd$cluster[i]))))
}

DIFF_NOTE <- "difference of Fisher-z means; no tanh transform of differences"

# Emit the three-row pattern (cell_pre / cell_post / diff) for one coding model.
run_coding_model <- function(aid, spec, cod, subset_lab, ms_on, note_stub,
                             expect_na8 = TRUE) {
  if (expect_na8)
    stopifnot("coding NA count != 8 [DEC-042b]" = sum(is.na(cod)) == K_PERIOD_NA)
  dd <- make_dd(cod)
  f  <- fit_coding(dd)
  kp0 <- cellk(dd, "0"); kp1 <- cellk(dd, "1")
  kd  <- list(k_es = nrow(dd),
              k_study = length(unique(as.character(dd$study))),
              k_cluster = length(unique(as.character(dd$cluster))))
  mk_cell <- function(term, s, kk) new_row(
    analysis_id = aid, spec = spec, subset = subset_lab, term = term,
    metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO,
    k_es = kk$k_es, k_study = kk$k_study, k_cluster = kk$k_cluster,
    est_z = s$est, se_z = s$se, t_stat = s$t, df = s$df, p = s$p,
    ci_lb_z = s$ci_lb, ci_ub_z = s$ci_ub,
    est_r = tanh(s$est), ci_lb_r = tanh(s$ci_lb), ci_ub_r = tanh(s$ci_ub),
    sigma2_cluster = f$sigma2[1], sigma2_study = f$sigma2[2], sigma2_esid = f$sigma2[3],
    ms_input = ms_on, ms_label = if (ms_on) paste(spec, term, sep = "_") else NA,
    note = paste0("Cell mean at coding = ", if (term == "cell_pre") "0 (pre)" else "1 (post)",
                  "; rma.mv ~0+factor(coding), V rho=0.6 on cluster_id [F56], ",
                  "CR2/Satterthwaite on cluster_id; ", note_stub))
  d_row <- new_row(
    analysis_id = aid, spec = spec, subset = subset_lab, term = "diff",
    metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO,
    k_es = kd$k_es, k_study = kd$k_study, k_cluster = kd$k_cluster,
    est_z = f$diff$est, se_z = f$diff$se, t_stat = f$diff$t, df = f$diff$df,
    p = f$diff$p, ci_lb_z = f$diff$ci_lb, ci_ub_z = f$diff$ci_ub,
    sigma2_cluster = f$sigma2[1], sigma2_study = f$sigma2[2], sigma2_esid = f$sigma2[3],
    ms_input = ms_on, ms_label = if (ms_on) paste(spec, "diff", sep = "_") else NA,
    note = paste0("post - pre moderator contrast (own formal inference per model ",
                  "[DEC-031a.6]); ", DIFF_NOTE, "; ", note_stub))
  list(rows = rbind(mk_cell("cell_pre", f$pre, kp0),
                    mk_cell("cell_post", f$post, kp1),
                    d_row),
       fit = f)
}

rows <- list()

# ---- 4. B1 -- paris_mid: headline moderation [DEC-024] ---------------------------
b1 <- run_coding_model("B1", "paris_mid", pm, "defined", TRUE,
  paste0("headline binary pp_mid_lag0; k = complete cases on coding [DEC-042b]; ",
         "transfer rule NOT triggered (design df 31.9) -> binary carries full inference"))
rows$B1 <- b1$rows
S2_B1 <- sum(b1$fit$sigma2)                 # marginal-weight constant for B6 dominance
paris_diff <- b1$fit$diff$est               # full-sample diff for the LOSO summary

# ---- 5. B3 -- coding sensitivities [plan par.6; DEC-031 Annex B] ------------------
rows$B3_median <- run_coding_model("B3", "tie_break_median", md, "defined", FALSE,
  "tie-break variant pp_median_lag0 (ties->Pre) [plan par.6]; ONE variant; sensitivity")$rows

rows$B3_end0 <- run_coding_model("B3", "end_any_exposure",
  as.integer(as.character(dat$pp_end_lag0)), "defined", FALSE,
  "pp_end_lag0 (any exposure by window end); upper-recall bound")$rows

# In-script recuts share_201x >= 0.5, ties->Post [P2; DEC-024 rule]. The prep
# columns pp_share_lag1..3 are NOT used as regressors (INFO line in run_meta).
for (yy in c(2017L, 2018L, 2019L)) {
  sh <- dat[[paste0("share_", yy)]]
  rc <- ifelse(is.na(sh), NA_integer_, as.integer(sh >= 0.5))
  rows[[paste0("B3_recut_", yy)]] <- run_coding_model("B3",
    paste0("share_recut_", yy), rc, "defined", FALSE,
    sprintf("in-script recut share_%d >= 0.5 (ties->Post) [P2/DEC-024]; main-text coding sensitivity; collapse = finding", yy))$rows
}

for (lg in 1:3) {
  rows[[paste0("B3_endlag", lg)]] <- run_coding_model("B3",
    paste0("end_lag", lg), as.integer(as.character(dat[[paste0("pp_end_lag", lg)]])),
    "defined", FALSE,
    sprintf("pp_end_lag%d; appendix [plan par.6]", lg))$rows
}

# clean_window: pure-pre vs pure-post cells [P5 mapping; DEC-031a.5 fired, df 12.3]
wc <- as.character(dat$pp_window_class)
cw <- ifelse(is.na(wc) | !(wc %in% c(CLEAN_PRE_LEVEL, CLEAN_POST_LEVEL)),
             NA_integer_, as.integer(wc == CLEAN_POST_LEVEL))
b3cw <- run_coding_model("B3", "clean_window", cw, "clean_cells", TRUE,
  sprintf("subset pp_window_class in {\"%s\",\"%s\"} [P5]; binary clean-post; FULL inference [DEC-031a.5 upgrade fired, design df 12.3]",
          CLEAN_PRE_LEVEL, CLEAN_POST_LEVEL), expect_na8 = FALSE)
stopifnot("clean_window diff df < 5 [spec par.3 assert]" = b3cw$fit$diff$df >= 5)
rows$B3_clean <- b3cw$rows
CLEAN_TOTAL <- sum(!is.na(cw))

# ---- 6. B6 -- loso_post: drop each post-cell study, refit paris_mid ---------------
loso <- vector("list", length(post_studies)); names(loso) <- post_studies
for (s in post_studies) {
  cod_s <- pm; cod_s[as.character(dat$study) == s] <- NA_integer_  # whole-study drop
  dd_s  <- make_dd(cod_s)
  f_s   <- fit_coding(dd_s)
  n_drop <- sum(!is.na(pm) & as.character(dat$study) == s)
  loso[[s]] <- list(diff = f_s$diff, sigma2 = f_s$sigma2,
                    k_es = nrow(dd_s),
                    k_study = length(unique(as.character(dat$study[as.character(dat$study) != s]))),
                    k_cluster = length(unique(as.character(dat$cluster_id[as.character(dat$study) != s]))),
                    n_drop = n_drop)
  rows[[paste0("B6_loso_", s)]] <- new_row(
    analysis_id = "B6", spec = "loso_post", subset = s, term = "diff",
    metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO,
    k_es = loso[[s]]$k_es, k_study = loso[[s]]$k_study, k_cluster = loso[[s]]$k_cluster,
    est_z = f_s$diff$est, se_z = f_s$diff$se, t_stat = f_s$diff$t,
    df = f_s$diff$df, p = f_s$diff$p,
    ci_lb_z = f_s$diff$ci_lb, ci_ub_z = f_s$diff$ci_ub,
    sigma2_cluster = f_s$sigma2[1], sigma2_study = f_s$sigma2[2], sigma2_esid = f_s$sigma2[3],
    ms_input = FALSE, ms_label = NA,
    note = sprintf("paris_mid refit without study '%s' (whole-study drop; %d defined ES removed); k_es = remaining complete cases on pp_mid_lag0; k_study/k_cluster = remaining sample after drop; %s",
                   s, n_drop, DIFF_NOTE))
}

# ---- 7. B6 -- loso_post_summary (range of the 31 diffs) ---------------------------
loso_diffs <- vapply(loso, function(x) x$diff$est, numeric(1))
i_min <- which.min(loso_diffs); i_max <- which.max(loso_diffs)
rows$B6_summary <- new_row(
  analysis_id = "B6", spec = "loso_post_summary", subset = "post_cell", term = "range",
  metric = "Fisher_z", estimator = "3LMA-RVE_CR2", rho = RHO,
  value = max(loso_diffs) - min(loso_diffs),
  ms_input = TRUE, ms_label = "loso_post_summary_range",
  note = sprintf("range = max - min over the 31 LOSO diff estimates (z scale); min diff = %.6f (drop %s); max diff = %.6f (drop %s); full-sample paris_mid diff = %.6f",
                 loso_diffs[i_min], names(loso_diffs)[i_min],
                 loso_diffs[i_max], names(loso_diffs)[i_max], paris_diff))

# ---- 8. B6 -- post_dominance: normalized weight shares in the post cell -----------
# w = 1/(vi + sum sigma2_B1): documented MARGINAL approximation -- true RVE
# weights are matrix-valued [spec par.3].
post_idx <- !is.na(pm) & pm == 1L
w_post   <- 1 / (dat$vi[post_idx] + S2_B1)
w_study  <- tapply(w_post, as.character(dat$study[post_idx]), sum)
w_share  <- as.numeric(w_study) / sum(w_post)
names(w_share) <- names(w_study)
es_count <- table(as.character(dat$study[post_idx]))
N_POST_ES <- sum(post_idx)
for (s in post_studies) {
  rows[[paste0("B6_dom_", s)]] <- new_row(
    analysis_id = "B6", spec = "post_dominance", subset = s, term = "weight_share",
    metric = "share", estimator = "IV_marginal_approx", rho = RHO,
    k_es = as.integer(es_count[[s]]), k_study = 1L,
    value = w_share[[s]],
    ms_input = FALSE, ms_label = NA,
    note = sprintf("normalized weight share, w = 1/(vi + sum sigma2_B1 = %.6f) within the post cell (pp_mid_lag0 == 1); marginal approximation, RVE weights are matrix-valued; ES-count share = %.6f (%d of %d post-cell ES)",
                   S2_B1, as.integer(es_count[[s]]) / N_POST_ES,
                   as.integer(es_count[[s]]), N_POST_ES))
}

# ---- 9. B7 -- disclosures (recomputed independently by verifier O14) ---------------
e0 <- as.integer(as.character(dat$pp_end_lag0))
end_post   <- !is.na(e0) & e0 == 1L
cont       <- end_post & dat$share_2016 < 0.5
rows$B7_atten <- new_row(
  analysis_id = "B7", spec = "disclosure_attenuation_end", subset = "end_post",
  term = "value", metric = "share", estimator = "descriptive", rho = NA,
  k_es = sum(end_post), k_study = length(unique(as.character(dat$study[end_post]))),
  value = sum(cont) / sum(end_post),
  ms_input = TRUE, ms_label = "disclosure_attenuation_end",
  note = sprintf("share of end-coded post ES (pp_end_lag0 == 1) with share_2016 < 0.5 (majority-pre contamination, recomputed on v12): %d of %d ES; study-level count: %d studies",
                 sum(cont), sum(end_post),
                 length(unique(as.character(dat$study[cont])))))

def16 <- !is.na(dat$share_2016)
knife <- def16 & dat$share_2016 >= 0.45 & dat$share_2016 <= 0.55
rows$B7_knife <- new_row(
  analysis_id = "B7", spec = "disclosure_knife_edge", subset = "defined",
  term = "value", metric = "share", estimator = "descriptive", rho = NA,
  k_es = sum(def16), k_study = length(unique(as.character(dat$study[def16]))),
  value = sum(knife) / sum(def16),
  ms_input = TRUE, ms_label = "disclosure_knife_edge",
  note = sprintf("ES share with share_2016 in [0.45, 0.55]: %d of %d defined ES; study count: %d studies",
                 sum(knife), sum(def16),
                 length(unique(as.character(dat$study[knife])))))

es_mean <- mean(dat$share_2016[def16])
st_mean <- mean(tapply(dat$share_2016[def16], as.character(dat$study[def16]), mean))
rows$B7_drift <- new_row(
  analysis_id = "B7", spec = "disclosure_panel_drift", subset = "defined",
  term = "value", metric = "share", estimator = "descriptive", rho = NA,
  k_es = sum(def16), k_study = length(unique(as.character(dat$study[def16]))),
  value = es_mean - st_mean,
  ms_input = TRUE, ms_label = "disclosure_panel_drift",
  note = sprintf("mean(share_2016) at ES level (%.6f) minus mean of study-level means (%.6f); post years contribute more observations than their calendar share",
                 es_mean, st_mean))

# ---- 10. Write outputs [spec par.4] ------------------------------------------------
res <- do.call(rbind, rows)
res <- res[, SCHEMA]
rownames(res) <- NULL
stopifnot("row inventory != 96 [spec par.3 / F58]" = nrow(res) == 96L)
write.csv(res, file.path(DIR_OUT, "T2_results.csv"), row.names = FALSE, na = "")

na_lines <- vapply(CODING_COLS, function(cc) {
  na_idx <- is.na(dat[[cc]])
  sprintf("  %-16s NA = %d over %d studies (%s)", cc, sum(na_idx),
          length(unique(as.character(dat$study[na_idx]))),
          paste(sort(unique(as.character(dat$study[na_idx]))), collapse = " | "))
}, character(1))

meta <- c(
  sprintf("T2 run meta -- %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("spec: docs/T2_spec.md (FROZEN Rev. 2026-07-13b, F58 erratum: 96 rows)"),
  sprintf("dat_prep path: %s", PATH_DAT_PREP),
  sprintf("dat_prep md5:  %s", unname(tools::md5sum(PATH_DAT_PREP))),
  sprintf("pr$n / pr$seed: %s / %s (contract asserted)", pr$n, pr$seed),
  sprintf("constants: K_ES=%d K_STUDY=%d K_CLUSTER=%d K_PERIOD_NA=%d K_STUDY_POST=%d RHO=%.1f SEED=%d",
          K_ES, K_STUDY, K_CLUSTER, K_PERIOD_NA, K_STUDY_POST, RHO, SEED),
  "",
  "per-coding NA counts [DEC-042b generalized; asserted 8 / same 2 studies]:",
  na_lines,
  "",
  sprintf("P5 clean-window level mapping (permitted in-run adaptation, resolved from data + design_quantities_v12.csv): pure-pre = \"%s\" (%d ES), pure-post = \"%s\" (%d ES); excluded level(s): \"mixed\"; clean-cell total k = %d",
          CLEAN_PRE_LEVEL, sum(cw == 0L, na.rm = TRUE),
          CLEAN_POST_LEVEL, sum(cw == 1L, na.rm = TRUE), CLEAN_TOTAL),
  sprintf("P2 INFO: prep columns pp_share_lag1..3 are numerically identical to share_2017..2019 (checked: max|diff| = %s); NOT used as regressors -- B3 recuts computed in-script as share_201x >= 0.5, ties->Post [DEC-024]",
          format(max(abs(dat$pp_share_lag1 - dat$share_2017),
                     abs(dat$pp_share_lag2 - dat$share_2018),
                     abs(dat$pp_share_lag3 - dat$share_2019), na.rm = TRUE))),
  sprintf("P1 assert passed: pp_share_lag0 == share_2016 (tol 1e-12), %d distinct values (continuous)",
          length(unique(dat$pp_share_lag0[!is.na(dat$pp_share_lag0)]))),
  "P3 assert passed: (share_2016 >= 0.5, ties->Post) reproduces pp_mid_lag0 exactly on the 2,705 defined rows",
  sprintf("P4 assert passed: pp_median_lag0 vs pp_mid_lag0 disagreements = %d, all at share_2016 == 0.5 (ties->Pre variant)", P4_COUNT),
  "",
  "free-field label conventions (unpinned by spec; fixed a priori here):",
  "  subset = 'defined' (complete cases on coding) for full-domain coding models;",
  "  'clean_cells' for clean_window; study key for loso_post / post_dominance rows;",
  "  'post_cell' for loso_post_summary; 'end_post'/'defined' for disclosures.",
  "  term = 'weight_share' on post_dominance rows; 'value' on disclosure rows.",
  "  LOSO rows: k_es = remaining complete cases on coding; k_study/k_cluster =",
  "  remaining sample after whole-study drop (115 - 1 = 114 studies).",
  "",
  sprintf("runtime: %.1f min", as.numeric(difftime(Sys.time(), t_start, units = "mins"))),
  "", "sessionInfo():", capture.output(sessionInfo())
)
writeLines(meta, file.path(DIR_OUT, "T2_run_meta.txt"))

cat("T2 complete:", nrow(res), "result rows ->", file.path(DIR_OUT, "T2_results.csv"), "\n")
