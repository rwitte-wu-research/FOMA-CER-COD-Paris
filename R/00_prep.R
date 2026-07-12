# =============================================================================
# R/00_prep.R — T0.4 data preparation (FOMA CER–COD, v12)
# Gate: pre-execution diff review. RESULT-BLIND: no pooled estimates computed.
# Governing: DEC-024/028/031/031a/031b/042/042a. Input: data/CER-COD_data_v12.xlsx
# Output: output/dat_prep.rds · output/design_quantities_v12.csv
# =============================================================================
suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr)
  library(metafor); library(clubSandwich); library(here)
})
set.seed(20260710)
dir.create(here("output"), showWarnings = FALSE)

fail <- function(msg) stop(paste0("[T0.4 ASSERT FAIL] ", msg), call. = FALSE)
ok   <- function(cond, msg) if (!isTRUE(cond)) fail(msg) else message("[ok] ", msg)

# --- S1: load + name normalization ------------------------------------------
XLSX <- here("data", "CER-COD_data_v12.xlsx")
d  <- read_excel(XLSX, sheet = "data",  guess_max = 5000)
lk <- read_excel(XLSX, sheet = "lookup", guess_max = 200)
cm <- read_excel(XLSX, sheet = "country_map")
sm <- read_excel(XLSX, sheet = "subsample_country_map")

nm <- c("ES (corr_coeff)"                      = "r_raw",
        "sample_size\nno_firms_rounded"        = "n_firms",
        "sample_size\nno_firm-years_rounded"   = "n_eff",       # column E (n_obs-else-proxy)
        "sample_post share_2016"               = "share_2016",
        "sample_post share_2017"               = "share_2017",
        "sample_post share_2018"               = "share_2018",
        "sample_post share_2019"               = "share_2019",
        "pp_median split"                      = "pp_median_split",
        "pp_tertial split"                     = "pp_tertial_split")
for (old in names(nm)) if (old %in% names(d)) names(d)[names(d) == old] <- nm[[old]]
message("[S1] columns normalized: ", paste(nm, collapse = ", "))

num <- function(x) suppressWarnings(as.numeric(x))
d <- d %>% mutate(across(c(r_raw, n_firms, n_eff, d_sample_start, d_sample_end,
                           sample_start, sample_end, sample_mid, sample_median,
                           starts_with("share_"), starts_with("pp_"), -pp_window_class,
                           d_fisher_z, d_es_usable, duplicate), num, .names = "{.col}"))

# --- S2: cross-language recomputation (hard gate) ---------------------------
tol <- 1e-9
eqn <- function(a, b) all(abs(ifelse(is.na(a), -9, a) - ifelse(is.na(b), -9, b)) < tol)
eqs <- function(a, b) all(ifelse(is.na(a), "\u00a7", as.character(a)) ==
                          ifelse(is.na(b), "\u00a7", as.character(b)))

ds <- d$d_sample_start; de <- d$d_sample_end
L  <- de - ds + 1; mid <- (ds + de) / 2
shr <- function(cut) pmin(1, pmax(0, (de - cut + 1) / L))

ok(eqn(d$sample_mid,    mid),                       "S2 grid: sample_mid == (s+e)/2")
ok(eqn(d$sample_median, mid),                       "S2 grid: sample_median == sample_mid")
for (y in 2016:2019)
  ok(eqn(d[[paste0("share_", y)]], shr(y)),         paste0("S2 grid: share_", y))
for (k in 0:3)
  ok(eqn(d[[paste0("pp_share_lag", k)]], shr(2016 + k)),
     paste0("S2 grid: pp_share_lag", k, " == continuous share(", 2016 + k, ")"))
ok(eqn(d$pp_mid_lag0,    as.numeric(mid >= 2015.5)), "S2 grid: pp_mid == 1{mid>=2015.5}")
ok(eqn(d$pp_median_lag0, as.numeric(mid >= 2016)),   "S2 grid: pp_median == 1{mid>=2016}")
ok(eqn(d$pp_start_lag0,  as.numeric(ds  >= 2016)),   "S2 grid: pp_start == 1{start>=2016} (R-18)")
for (k in 0:3)
  ok(eqn(d[[paste0("pp_end_lag", k)]], as.numeric(de >= 2016 + k)),
     paste0("S2 grid: pp_end_lag", k))
wc <- ifelse(is.na(ds), NA, ifelse(ds >= 2016, "post-only", ifelse(de < 2016, "pre-only", "mixed")))
ok(eqs(d$pp_window_class, wc),                       "S2 grid: window_class rule")
ok(eqn(d$pp_median_split,  as.numeric(mid > 2013)),  "S2 grid: median split > 2013 (frozen)")
ok(eqn(d$pp_tertial_split, 1 + (mid > 2011) + (mid > 2014)), "S2 grid: tertiles 2011/2014 (frozen)")

# q classes (P-09) + field via lookup
qcls <- function(status, letter) ifelse(status == "working paper", "99_NCE",
          ifelse(!is.na(letter) & letter %in% c("A+","A","B","C"), "1_VHB high", "0_VHB low"))
lkI <- lk %>% mutate(q_status_class_r = ifelse(q_status == "working paper",
                                               "1_not published", "0_published"),
                     q_vhb_class_r    = qcls(q_status, q_vhb))
d2 <- d %>% left_join(lkI %>% select(study, q_status_class_r, q_vhb_class_r,
                                     field_lk = field, c_region, c_econ, c_culture, c_legal),
                      by = "study")
ok(eqs(d$q_status, d2$q_status_class_r), "S2 q: q_status == lookup class")
ok(eqs(d$q_VHB,    d2$q_vhb_class_r),    "S2 q: q_VHB == P-09 rule")
ok(eqs(d$field,    d2$field_lk),         "S2 q: field == lookup")

# country: subsample override else paper (Bannier/Srivisal hardcode exception)
EXC <- c("Bannier et al (2022)", "Srivisal et al (2021)")
smI <- sm %>% rename(skey = value)
cchk <- function(dcol, scol, lcol) {
  ov <- smI[[scol]][match(d$row_skey, smI$skey)]
  expv <- ifelse(!is.na(d$row_skey) & !is.na(ov) & ov != "", ov, d2[[lcol]])
  keep <- !(d$study %in% EXC)
  ok(eqs(d[[dcol]][keep], expv[keep]), paste0("S2 country: ", dcol, " == subsample-else-paper"))
}
cchk("country_region",  "region",  "c_region")
cchk("country_econ",    "econ",    "c_econ")
cchk("country_culture", "culture", "c_culture")
cchk("country_legal",   "legal",   "c_legal")

# column E == n_obs-if-numeric-else-proxy
nobs <- num(gsub(",", "", as.character(d$n_obs)))
proxy <- d$n_firms * L
ok(eqn(d$n_eff, ifelse(is.finite(nobs), nobs, proxy)), "S2 E: n_eff == n_obs-else-proxy (R-16b/R-19)")

# Fisher-z recompute vs stored derivation
zi_chk <- atanh(pmin(pmax(d$r_raw, -0.999999), 0.999999))
mm <- is.finite(zi_chk) & is.finite(d$d_fisher_z)
ok(max(abs(zi_chk[mm] - d$d_fisher_z[mm])) < 1e-9, "S2 z: atanh(r) == d_fisher_z")

# --- S3: structural assertions -----------------------------------------------
CL <- list(
  industry        = c("non-sensitive", "sensitive", "99_NCE"),
  regulation_sample_start = c("with ETS/CT", "without ETS/CT", "99_NCE"),
  regulation_sample_end   = c("with ETS/CT", "without ETS/CT", "99_NCE"),
  country_region  = c("1_US", "2_Europe", "3_AsiaPac", "99_NCE"),
  country_econ    = c("1_developed", "2_developing", "99_NCE"),
  country_culture = c("1_western", "2_non_western", "99_NCE"),
  country_legal   = c("1_common law", "2_civil law", "99_NCE"),
  q_status        = c("0_published", "1_not published"),
  q_VHB           = c("1_VHB high", "0_VHB low", "99_NCE"),
  field           = c("1_fin/acc/econ", "2_sust", "3_mgmt"),
  pp_window_class = c("pre-only", "post-only", "mixed"),
  COD_instrument  = c("bond (yield)", "derivativ (CDS spread)", "loan (interest rate)", "rating")
)
for (cn in names(CL)) {
  bad <- setdiff(unique(na.omit(as.character(d[[cn]]))), CL[[cn]])
  ok(length(bad) == 0, paste0("S3 closed list ", cn,
                              if (length(bad)) paste0(" — off-list: ", paste(bad, collapse = "|")) else ""))
}
ok(all(d$study %in% lk$study),        "S3 keys: data studies subset of lookup")
ok(n_distinct(d$study) == 120,        "S3 keys: 120 studies")
ok(n_distinct(lk$cluster_id) == 119,  "S3 keys: 119 cluster_ids (Sandra/Ofogbe merged)")
ok(eqn(d$pp_share_lag0, d$share_2016),"S3 identity: pp_share_lag0 == share_2016")
ok(all((d$pp_end_lag0 == 1) == (d$share_2016 > 0), na.rm = TRUE), "S3 identity: end_lag0 <=> share>0")
ok(all((d$pp_start_lag0 == 1) == (d$share_2016 == 1), na.rm = TRUE), "S3 identity: start<=>share=1 (clean_post)")

# --- S4: estimation set (DEC-042a) -------------------------------------------
ok(nrow(d) == 2852,                              "S4 corpus: 2,852 rows")
ok(sum(d$d_es_usable == 1, na.rm = TRUE) == 2730,"S4 corpus: 2,730 usable")
ok(sum(d$es_method == "non-convertible") == 122, "S4 corpus: 122 non-convertibles")
ok(sum(d$duplicate == 1, na.rm = TRUE) == 1,     "S4 corpus: 1 duplicate tag")
est <- d$d_es_usable == 1 & (is.na(d$duplicate) | d$duplicate == 0) & is.finite(d$n_eff)
ok(sum(d$d_es_usable == 1 & !is.finite(d$n_eff)) == 16, "S4 corpus: 16 usable no-n rows (drop)")
ok(sum(est) == 2713,                             "S4 ESTIMATION SET n = 2,713 (DEC-042a)")
dat <- d[est, ]

# --- S5: effect sizes (DEC-028) ----------------------------------------------
dat <- dat %>% mutate(
  zi      = atanh(pmin(pmax(r_raw, -0.999999), 0.999999)),
  vi      = 1 / (n_eff - 3),
  vi_k10  = ifelse(n_eff > 13, 1 / (n_eff - 10 - 3), NA_real_),
  vi_k20  = ifelse(n_eff > 23, 1 / (n_eff - 20 - 3), NA_real_),
  flag_starbound = es_method == "star-bound",
  flag_proxy_n   = !is.finite(num(gsub(",", "", as.character(n_obs))))
)
ok(all(is.finite(dat$zi) & is.finite(dat$vi) & dat$vi > 0), "S5 zi/vi finite and positive")
message("[S5] vi_k10 NA rows: ", sum(is.na(dat$vi_k10)),
        " | vi_k20 NA rows: ", sum(is.na(dat$vi_k20)),
        " | starbound: ", sum(dat$flag_starbound), " | proxy-n: ", sum(dat$flag_proxy_n))

# --- S6: ids + factors (reference = largest cell; pure convention) -----------
dat <- dat %>%
  select(-cluster_id) %>%                               # drop raw col 68 to avoid .x/.y suffix collision
  left_join(lk %>% select(study, cluster_id), by = "study") %>%
  mutate(esid = row_number(),
         sample_mid_c = sample_mid - mean(sample_mid, na.rm = TRUE))
reflev <- function(x) names(sort(table(x), decreasing = TRUE))[1]
FACS <- c("CER_measure","COD_instrument","industry","regulation_sample_start",
          "country_region","country_econ","country_culture","country_legal",
          "q_VHB","q_status","field","ES_measure","es_method")
for (f in FACS) dat[[f]] <- relevel(factor(dat[[f]]), ref = reflev(dat[[f]]))
message("[S6] reference levels: ",
        paste(sprintf("%s=%s", FACS, sapply(FACS, function(f) levels(dat[[f]])[1])),
              collapse = " | "))

# --- S7: design quantities + upgrade adjudication (dummy-outcome df) ---------
cell <- function(flag, name) {
  tibble(quantity = name,
         k_pre  = sum(flag == 0, na.rm = TRUE), k_post = sum(flag == 1, na.rm = TRUE),
         st_pre  = n_distinct(dat$study[flag == 0 & !is.na(flag)]),
         st_post = n_distinct(dat$study[flag == 1 & !is.na(flag)]),
         cl_pre  = n_distinct(dat$cluster_id[flag == 0 & !is.na(flag)]),
         cl_post = n_distinct(dat$cluster_id[flag == 1 & !is.na(flag)]))
}
codings <- list(pp_mid = dat$pp_mid_lag0, pp_median = dat$pp_median_lag0,
                end_lag0 = dat$pp_end_lag0, end_lag1 = dat$pp_end_lag1,
                end_lag2 = dat$pp_end_lag2, end_lag3 = dat$pp_end_lag3,
                share_lag1_bin = as.numeric(dat$pp_share_lag1 >= 0.5),
                share_lag2_bin = as.numeric(dat$pp_share_lag2 >= 0.5),
                share_lag3_bin = as.numeric(dat$pp_share_lag3 >= 0.5),
                clean_window = ifelse(dat$pp_window_class == "post-only", 1,
                               ifelse(dat$pp_window_class == "pre-only", 0, NA)))
dq <- bind_rows(lapply(names(codings), function(n) cell(codings[[n]], n)))

# design-only Satterthwaite df: DUMMY outcome (df depend on X, V, cluster only)
df_design <- function(flag) {
  keep <- !is.na(flag)
  y_dummy <- rnorm(sum(keep))                       # seeded; coefficients meaningless
  m <- try(rma.mv(y_dummy, V = dat$vi[keep],
                  mods = ~ factor(flag[keep]),
                  random = ~ 1 | cluster_id / study / esid,
                  data = dat[keep, ], sparse = TRUE), silent = TRUE)
  if (inherits(m, "try-error")) return(NA_real_)
  ct <- clubSandwich::coef_test(m, vcov = "CR2", cluster = dat$cluster_id[keep])
  ct$df_Satt[2]
}
dq$df_paris_design <- sapply(names(codings), function(n) df_design(codings[[n]]))

upg <- tibble(
  quantity = c("clean_window_upgrade_df_ge_5", "split_selmodels_upgrade_poststudies_ge_20"),
  value    = c(dq$df_paris_design[dq$quantity == "clean_window"] >= 5,
               dq$st_post[dq$quantity == "pp_mid"] >= 20))
post <- dat$pp_mid_lag0 == 1
dom  <- dat[post & !is.na(post), ] %>% count(study, name = "k") %>%
        mutate(share = k / sum(k)) %>% arrange(desc(share))
comp <- bind_rows(
  dat[post & !is.na(post), ] %>% count(country_region) %>%
    mutate(quantity = paste0("postcell_region_", country_region), share = n / sum(n)) %>%
    select(quantity, n, share),
  dat[post & !is.na(post), ] %>% count(CER_measure) %>%
    mutate(quantity = paste0("postcell_CER_", CER_measure), share = n / sum(n)) %>%
    select(quantity, n, share))
n15 <- dat %>% group_by(study) %>%
  summarise(mixed = n_distinct(na.omit(pp_mid_lag0)) == 2, .groups = "drop") %>%
  filter(mixed)
message("[S7] N15 within-study set: ", nrow(n15), " studies | post-cell top-3 dominance: ",
        paste(sprintf("%s %.1f%%", head(dom$study, 3), 100 * head(dom$share, 3)), collapse = " · "))

write.csv(bind_rows(dq %>% mutate(across(everything(), as.character)),
                    upg %>% mutate(across(everything(), as.character)),
                    comp %>% mutate(across(everything(), as.character)),
                    dom %>% transmute(quantity = paste0("postcell_dom_", study),
                                      n = as.character(k), share = as.character(share)),
                    tibble(quantity = "n15_within_study_set",
                           value = paste(n15$study, collapse = "; "))),
          here("output", "design_quantities_v12.csv"), row.names = FALSE, na = "")

# --- S8: save (no effect statistics printed) ---------------------------------
saveRDS(list(dat = dat, built = Sys.time(), seed = 20260710,
             n = nrow(dat), sessionInfo = sessionInfo()),
        here("output", "dat_prep.rds"))
message("[T0.4 DONE] estimation set n = ", nrow(dat),
        " | design_quantities_v12.csv written | NO pooled estimates computed.")
