# Theory Harvest — Chapter 2 — Run Log

<!-- Generated per cowork_prompt_theory_harvest.md v2.3 §5. FULL run; fresh complete write (pilot outputs superseded). -->

## 1. Header

| Field | Value |
|---|---|
| Run date/time | 2026-08-03/04, Gate 1 ~23:35 CEST → completion 2026-08-04 11:36 CEST |
| RUN_MODE | `FULL` |
| Agent / model | Claude Cowork, `claude-opus-5` (main loop) + `general-purpose` sub-agents, one per paper |
| Prompt version | `cowork_prompt_theory_harvest.md` v2.3 |
| PDF_LIBRARY_PATH as set | `C:\Cowork\FOMA-Extraktion-Theory\papers` |
| PDFs found (recursive) | 134 (133 `.pdf` + 1 `.PDF`; no subfolders) |
| Worklist size | 120 + 12 extras |
| Papers processed | 131 harvested (120 worklist + 11 extras) + 1 extra status-only (WP twin) |
| CSV rows | 1566 = 1432 content + 134 status |
| Record mix | frame_use 444 · key_citation 393 · counter 265 · mechanism_extra 218 · paris_policy 112 |
| Frame coverage | RISK 128 · SIG 108 · STAKE 105 · AGENCY 64 · OTHER:* 39 across 25 named theories |

## 2. Coverage table (worklist)

`n_records` = substantive (frame_use/mechanism_extra/counter/paris_policy) + key_citation. Every paper also carries one status row.

| # | study_label | status | n_records |
|---:|---|---|---:|
| 1 | `Al-Fakir Al Rabab'a et al (2023)` | done | 8 + 3 |
| 2 | `Ali et al (2023)` | done | 7 + 3 |
| 3 | `Ali et al (2026)` | done | 8 + 3 |
| 4 | `Almutairi (2026)` | done | 8 + 3 |
| 5 | `Altavilla et al (2024)` | done | 8 + 3 |
| 6 | `Apergis et al (2022)` | done | 8 + 3 |
| 7 | `Atif, Ali (2021)` | done | 8 + 3 |
| 8 | `Attig et al (2025)` | done | 8 + 3 |
| 9 | `Azmi et al (2021)` | done | 8 + 3 |
| 10 | `Bannier et al (2022)` | done | 8 + 3 |
| 11 | `Bauer, Hann (2010)` | done | 8 + 3 |
| 12 | `Ben Slimane et al (2019)` | done | 8 + 3 |
| 13 | `Bhattacharya & Sharma (2019)` | done | 8 + 3 |
| 14 | `Boermans et al (2023)` | done | 8 + 3 |
| 15 | `Borsuk & Shrimali (2026)` | done | 8 + 3 |
| 16 | `Boubaker et al (2026)` | done | 8 + 3 |
| 17 | `Brinette et al (2026)` | done | 8 + 3 |
| 18 | `Caragnano et al (2020)` | done | 8 + 3 |
| 19 | `Chava (2010)` | done | 8 + 3 |
| 20 | `Chava (2014)` | done · image-route | 8 + 3 |
| 21 | `Chen et al (2020)` | done | 8 + 3 |
| 22 | `Chen, Gao (2011)` | done | 8 + 3 |
| 23 | `Chodnicka-Jaworska (2022)` | done | 8 + 3 |
| 24 | `Christ et al (2022)` | done | 8 + 3 |
| 25 | `Cicchini et al (2026)` | done | 8 + 3 |
| 26 | `Cubas, Martinez (2018)` | done | 8 + 3 |
| 27 | `D'Arcangelo et al (2025)` | done | 8 + 3 |
| 28 | `Delis et al (2021)` | done | 8 + 3 |
| 29 | `Devalle et al (2017)` | done | 8 + 3 |
| 30 | `Ding et al (2022)` | done | 8 + 3 |
| 31 | `Drago et al (2018)` | done | 8 + 3 |
| 32 | `Drago, Carnevale (2020)` | done | 8 + 3 |
| 33 | `Du et al (2015)` | done | 8 + 3 |
| 34 | `Du et al (2022)` | done | 8 + 3 |
| 35 | `Dumrose & Höck (2023)` | done | 7 + 3 |
| 36 | `Duong et al (2025)` | done | 8 + 3 |
| 37 | `Ehlers et al (2021)` | done | 8 + 3 |
| 38 | `Eichholtz et al (2019)` | done | 8 + 3 |
| 39 | `Eliwa et al (2021)` | done | 8 + 3 |
| 40 | `Erragragui (2018)` | done | 8 + 3 |
| 41 | `Ferriani (2022)` | done | 8 + 3 |
| 42 | `Fonseka et al (2019a)` | done | 8 + 3 |
| 43 | `Fonseka et al (2019b)` | done | 8 + 3 |
| 44 | `Ge, Liu (2015)` | done | 8 + 3 |
| 45 | `Gonzales Sanches et al (2026)` | done | 8 + 3 |
| 46 | `Hamrouni et al (2019a)` | done · image-route | 8 + 3 |
| 47 | `Hansen & Marcet (2025)` | done | 8 + 3 |
| 48 | `Ho & Wong (2023)` | done | 8 + 3 |
| 49 | `Hoepner et al (2016)` | done | 8 + 3 |
| 50 | `Hu et al (2024)` | done | 8 + 3 |
| 51 | `Hui et al (2024)` | done | 8 + 3 |
| 52 | `Höck et al (2020)` | done | 8 + 3 |
| 53 | `Jang et al (2020)` | done | 8 + 3 |
| 54 | `Jiraporn et al (2014)` | done · image-route | 8 + 3 |
| 55 | `Johnson (2020)` | done | 8 + 3 |
| 56 | `Jung et al (2016)` | done | 8 + 3 |
| 57 | `Kim & Pouget (2026)` | done | 8 + 3 |
| 58 | `Kim, Kim (2022)` | done | 8 + 3 |
| 59 | `Kleimeier, Viehs (2021)` | done | 8 + 3 |
| 60 | `Kordschia (2020)` | done | 8 + 3 |
| 61 | `Kozak (2021)` | done | 8 + 3 |
| 62 | `Kumar & Firoz (2018)` | done | 8 + 3 |
| 63 | `Kölbel et al (2020)` | done | 8 + 3 |
| 64 | `Lee (2022)` | done | 8 + 3 |
| 65 | `Lemma et al (2017)` | done | 8 + 3 |
| 66 | `Li & Qiu (2026)` | done | 8 + 3 |
| 67 | `Li et al (2014)` | done | 8 + 3 |
| 68 | `Li et al (2022)` | done | 8 + 3 |
| 69 | `Lin et al (2025)` | done | 8 + 3 |
| 70 | `Liu et al (2023)` | done | 8 + 3 |
| 71 | `Luo et al (2019)` | done | 8 + 3 |
| 72 | `Ma et al (2022)` | done | 8 + 3 |
| 73 | `Maaloul, Wegener (2021)` | done | 8 + 3 |
| 74 | `Mahmoudian et al (2023)` | done | 8 + 3 |
| 75 | `Nandy, Lodh (2012)` | done | 8 + 3 |
| 76 | `Nasih et al (2024)` | done | 8 + 3 |
| 77 | `Ng & Rezaee (2012)` | done | 8 + 3 |
| 78 | `Ofogbe et al (2021)` | done | 8 + 3 |
| 79 | `Oikonomou et al (2014)` | done | 8 + 3 |
| 80 | `Okimoto & Takaoka (2024)` | done | 8 + 3 |
| 81 | `Okimoto, Takaoka (2022)` | done | 8 + 3 |
| 82 | `Ould Daoud Ellili (2020)` | done | 6 + 3 |
| 83 | `Owolabi et al (2024)` | done | 8 + 3 |
| 84 | `Palea, Drogo (2020)` | done | 8 + 3 |
| 85 | `Panjwani et al (2023)` | done | 8 + 3 |
| 86 | `Piechocka-Kałużna et al (2021)` | done | 7 + 3 |
| 87 | `Pizzutilo et al (2020)` | done | 8 + 3 |
| 88 | `Polbennikov et al (2016)` | done | 8 + 3 |
| 89 | `Ratajczak & Mikolajewicz (2021)` | done | 8 + 3 |
| 90 | `Ririmasse et al (2026)` | done | 8 + 3 |
| 91 | `Safiullah et al (2021)` | done | 8 + 3 |
| 92 | `Safiullah et al (2025)` | done | 7 + 3 |
| 93 | `Salvi et al (2021)` | done | 8 + 3 |
| 94 | `Sandra et al (2021)` | done | 8 + 3 |
| 95 | `Schneider (2010)` | done | 8 + 3 |
| 96 | `Seltzer et al (2022)` | done | 8 + 3 |
| 97 | `Shad et al (2022)` | done | 7 + 3 |
| 98 | `Shi et al (2025)` | done | 8 + 3 |
| 99 | `Srivisal et al (2021)` | done | 8 + 3 |
| 100 | `Sze et al (2021)` | done | 8 + 3 |
| 101 | `Tan et al (2021)` | done | 8 + 3 |
| 102 | `Tan et al (2026)` | done | 8 + 3 |
| 103 | `Tang et al (2023)` | done | 8 + 3 |
| 104 | `Temiz (2022)` | done | 8 + 3 |
| 105 | `Trinh et al (2024)` | done | 8 + 3 |
| 106 | `Truong, Kim (2019)` | done | 8 + 3 |
| 107 | `Wang & Wijethilake (2026)` | done | 8 + 3 |
| 108 | `Wang et al (2020)` | done | 8 + 3 |
| 109 | `Wang et al (2022a)` | done | 8 + 3 |
| 110 | `Wang et al (2025a)` | done | 8 + 3 |
| 111 | `Wang et al (2025b)` | done | 7 + 3 |
| 112 | `Wu et al (2020)` | done | 8 + 3 |
| 113 | `Xiang & Gong (2026)` | done | 7 + 3 |
| 114 | `Yang et al (2024)` | done | 8 + 3 |
| 115 | `Yilmaz (2022)` | done | 8 + 3 |
| 116 | `Zhang et al (2023)` | done | 8 + 3 |
| 117 | `Zheng (2021)` | done | 8 + 3 |
| 118 | `Zhou et al (2018)` | done | 8 + 3 |
| 119 | `Zhou et al (2024)` | done | 8 + 3 |
| 120 | `Zhu, Zhao (2022)` | done | 8 + 3 |

## 3. Matching table (Gate-2 output, author-confirmed)

Author-verified against the v12 ledger at GO 2; Fonseka #42/#43 swapped per the v12 provenance sheet, Wang et al (2025a/b) confirmed unchanged. 0 `pdf_missing`, 0 `pdf_ambiguous`.

| # | worklist label | file | flag | resolution |
|---:|---|---|---|---|
| 1 | `Al-Fakir Al Rabab'a et al (2023)` | Al-Fakir Al Rababa et al (2023) - corporate carbon perf and cost of debt.pdf | clean | filename drops apostrophe; IRFA 88 (2023) 102641 confirms |
| 2 | `Ali et al (2023)` | Ali et al (2023) - do capital markets reward corporate climante cahnge actions.pdf | clean |  |
| 3 | `Ali et al (2026)` | Ali et al (2026) - carbon risk and cost of debt.pdf | clean |  |
| 4 | `Almutairi (2026)` | Almutairi (2026) - the impact of climate change disc and cost of debt.pdf | clean |  |
| 5 | `Altavilla et al (2024)` | Altavilla et al (2024) - climate risk, bank lending and monetary policy.pdf | clean |  |
| 6 | `Apergis et al (2022)` | Apergis et al (2022) - ESG scores and cost of debt.pdf | clean |  |
| 7 | `Atif, Ali (2021)` | Atif, Ali (2021) - ESG disclosure and default risk.pdf | clean |  |
| 8 | `Attig et al (2025)` | Attig et al (2025) - creditors at the gate.pdf | clean |  |
| 9 | `Azmi et al (2021)` | Azmi et al (2021) - ESG activities and banking performance.pdf | clean |  |
| 10 | `Bannier et al (2022)` | Bannier et al (2022) - CSR and credit risk.pdf | clean |  |
| 11 | `Bauer, Hann (2010)` | Bauer, Hann (2010) - Corp env mgmt and credit risk.pdf | clean |  |
| 12 | `Ben Slimane et al (2019)` | Ben Slimane et al (2019) - ESG investing in corp bonds.pdf | **duplicate** | byte-identical copy '... (1).pdf' gets a duplicate_file status row (rule 6) |
| 13 | `Bhattacharya & Sharma (2019)` | Bhattacharya, Sharma (2019) - Doe env, social and gov perf impact credit ratings.pdf | clean |  |
| 14 | `Boermans et al (2023)` | Boermans et al (2023) - funding the fittest.pdf | clean | rule-10 probe on CONTENT pages: 0 page-sized images, 2400-4100 chars/page, normal embedded fonts -> TEXT ROUTE (p.1 is a blank DNB cover) |
| 15 | `Borsuk & Shrimali (2026)` | Borsuk, Shrimali (2026) - carbon risk and corp creditworthiness.pdf | clean |  |
| 16 | `Boubaker et al (2026)` | Boubaker et al (2026) - env practices and corp cost of debt.pdf | clean |  |
| 17 | `Brinette et al (2026)` | Brinette et al (2026) - waste mgmt and cost of debt.pdf | clean |  |
| 18 | `Caragnano et al (2020)` | Caragnano (2020) - Is it worth reducing ghg emissions.pdf | clean | filename omits 'et al'; JEM 270 (2020) 110860, 4 authors |
| 19 | `Chava (2010)` | Chava (2010) - Do env concerns affect the cost of bank loans.pdf | clean |  |
| 20 | `Chava (2014)` | Chava (2014) - Env externalities and cost of capital (2).pdf | clean | '(2)' is a download-suffix, not a version; only Chava 2014 file; IMAGE ROUTE: JSTOR scan, Code2000 OCR font, page-sized image on every sampled page |
| 21 | `Chen et al (2020)` | Chen et al (2021) - Do Banks Value Borrowers Environmental Record.pdf | **year_mismatch** | J Bus Ethics 174:687-713; online-first + (c) 2020, issue 2021. Same paper. |
| 22 | `Chen, Gao (2011)` | Chen, Gao (unknown) - The pricing of climate risk.pdf | **unknown_year** | undated SSRN working paper (Chen & Silva Gao); published version J Financ Econom Pract 12(2) 2012 NOT in library |
| 23 | `Chodnicka-Jaworska (2022)` | Chodnicka-Jaworska (2022) - ESG impact on energy sector default risk.pdf | clean |  |
| 24 | `Christ et al (2022)` | Christ et al (unknown) - Corporate Sustainability Performance and the Cost of Debt.pdf | **unknown_year** | undated working paper (Christ, Hertel, Kocian); no year anywhere on p.1 |
| 25 | `Cicchini et al (2026)` | Cicchini et al (2026) - ghg emission and the cost of debt.pdf | clean |  |
| 26 | `Cubas, Martinez (2018)` | Cubas-Diaz, Martinez Sedano (2018) - Do credit ratings take into account the sust perf of companies.pdf | clean | worklist label abbreviates both surnames |
| 27 | `D'Arcangelo et al (2025)` | DArcangelo et al (2025) - the effect of climate policies on firm financing.pdf | clean | filename drops apostrophe; JEM 387 (2025) 125866 |
| 28 | `Delis et al (2021)` | Delis et al (2021) - Being stranded with fossil fuel reserves.pdf | clean |  |
| 29 | `Devalle et al (2017)` | devalle (2017) - The linkage between ESG perf and credit ratings.pdf | clean | IJBM 12(9) 2017; Devalle, Fiandrino & Cantino |
| 30 | `Ding et al (2022)` | Ding et al (2022) - Env administrative penalty, corp env disclsoures and the cost of debt.pdf | clean |  |
| 31 | `Drago et al (2018)` | Drago et al (2018) - Do corporate social responsibility ratings affect credit default swap spreads.pdf | clean |  |
| 32 | `Drago, Carnevale (2020)` | Drago, Carnevale (2020) - Do CSR Ratings Affect Loan Spreads.pdf | clean |  |
| 33 | `Du et al (2015)` | Du et al (2017) - Do lenders applaud corp env perf.pdf | **year_mismatch** | J Bus Ethics 143:179-207; accepted+online+(c) 2015, issue 2017. Same paper. |
| 34 | `Du et al (2022)` | Du et al (2022) - Will environmental information disclosure afect bank credit decisions  and corp debt financing costs.pdf | clean |  |
| 35 | `Dumrose & Höck (2023)` | Dumrose, Hoeck (2023) - corporte carbon risk and credi risk.pdf | clean | filename transliterates Hoeck |
| 36 | `Duong et al (2025)` | Duong et al (2025) - do firms benefit from carbon risk mgmt.pdf | clean |  |
| 37 | `Ehlers et al (2021)` | Ehlers et al (2021) - th epricing of carbon risk in syndicated loans.pdf | clean |  |
| 38 | `Eichholtz et al (2019)` | Eichholtz et al (2019) - Env perf and the cost of debt.pdf | clean |  |
| 39 | `Eliwa et al (2021)` | Eliwa et al (2021) - ESG practices and the cost of debt.pdf | clean |  |
| 40 | `Erragragui (2018)` | Erragragui (2018) - Doe creditors price firms ESG risk.pdf | clean |  |
| 41 | `Ferriani (2022)` | Ferriani (2022) - Issuing bonds during the covid-19 pandemic.pdf | clean |  |
| 42 | `Fonseka et al (2019a)` | Fonseka et al (2019) - THe effect of env infromation disclosure and energy product type on the cost of debt.pdf | **suffix_ambiguous** | author-corrected per v12 provenance (staging filenames): staging_Fonseka_et_al_2019_energy.csv -> Pacific-Basin Finance Journal 54 (2019) 159-182 ENERGY paper |
| 43 | `Fonseka et al (2019b)` | Fonseka et al (2019) - Impact of env information disclosure and real estate segments on cost of debt.pdf | **suffix_ambiguous** | author-corrected per v12 provenance (staging filenames): staging_Fonseka_et_al_2019_realestate.csv -> Economics of Transition REAL-ESTATE paper |
| 44 | `Ge, Liu (2015)` | Ge, Liu (2015) - Corporate social responsibility and the cost of corp bonds.pdf | clean |  |
| 45 | `Gonzales Sanches et al (2026)` | Gonzales Sanches et al (2026) - corp env resp, env policy stringency and debt cost.pdf | clean |  |
| 46 | `Hamrouni et al (2019a)` | Hamrouni et al (2019) - Are corp social resp disclosures relevant for lenders.pdf | clean | no 'Hamrouni et al (2019b)' in the worklist - suffix vestigial, assignment forced; IMAGE ROUTE: no text layer at all (0 chars/page) |
| 47 | `Hansen & Marcet (2025)` | Hansen, Marcet (2025) - the diff impact of env violations on the cost of cinancing.pdf | clean |  |
| 48 | `Ho & Wong (2023)` | Ho, Wong (2023) - effect of climate-realted risk on the costs of bank loans.pdf | clean |  |
| 49 | `Hoepner et al (2016)` | Hoepner et al (2016) - The effects of corp and coutnry sust characteristics on the cost of debt.pdf | clean |  |
| 50 | `Hu et al (2024)` | Hu et al (2024) - env perf and credit ratings.pdf | clean |  |
| 51 | `Hui et al (2024)` | Hui et al (2024) - Financing sustainability  How environmental disclosures shape bank lending.pdf | clean |  |
| 52 | `Höck et al (2020)` | Höck et al (2020) - The effect of env sustainability on credit risk.pdf | clean |  |
| 53 | `Jang et al (2020)` | Jang et al (2020) - ESG Scores and the Credit Market.pdf | clean |  |
| 54 | `Jiraporn et al (2014)` | Jiraporn et al (2014) - Does CSR improve credit ratings.pdf | clean | IMAGE ROUTE: JSTOR scan, Code2000 OCR font, page-sized image on every sampled page |
| 55 | `Johnson (2020)` | Johnson (2020) - The link between env, social and corp gov disclsoure and the cost of capital.pdf | clean |  |
| 56 | `Jung et al (2016)` | Jung et al (2018) - Carbon Risk, Carbon Risk Awareness and the Cost of Debt financing.pdf | **year_mismatch** | J Bus Ethics 150:1151-1171; accepted+online+(c) 2016, issue 2018. Same paper. |
| 57 | `Kim & Pouget (2026)` | Kim, Pouget (2026) - do cabron emission affect cost of capital.pdf | clean |  |
| 58 | `Kim, Kim (2022)` | Kim, Kim (2022) - Env risk and credit ratings and the moderating effect of market competition.pdf | clean |  |
| 59 | `Kleimeier, Viehs (2021)` | Kleimeier, Viehs (2021) - Prcing carbon risk.pdf | clean | Economics Letters 205 (2021) 109936. The 2018 Kleimeier/Viehs file is a DIFFERENT paper -> extra |
| 60 | `Kordschia (2020)` | Kordschia (2019) - A risk mgmt perspective on csr and the marginal cost of debt.pdf | **year_mismatch** | Rev Manag Sci 15:1611-1643: received 2019 (filename), online 2020 (worklist), issue 2021. Surname is KORDSACHIA - worklist misspells |
| 61 | `Kozak (2021)` | Kozak (2021) - will the reduction of co2 emission lower the cost of debt.pdf | **duplicate** | byte-identical copy 'Will the reduction of co emissions...' gets a duplicate_file status row (rule 6) |
| 62 | `Kumar & Firoz (2018)` | Kumar, Firoz (2018) - Impact of carbon emissions on cost of debt.pdf | clean |  |
| 63 | `Kölbel et al (2020)` | Kölbel et al (2020) - Does the CDS market reflect regulatory climate risk disclosure.pdf | clean |  |
| 64 | `Lee (2022)` | Lee (2022) - Vol disclosure of carbon emissions information managerial ability and credit ratings.pdf | clean | 'Lee, Choi (2021)' is a different paper -> extra |
| 65 | `Lemma et al (2017)` | Lemma et al (2017) - Corp carbon risk, vol disclusre and cost of capital.pdf | clean |  |
| 66 | `Li & Qiu (2026)` | Li, Qui (2026) - env pollution and copr credit spreads.pdf | clean | filename misspells Qiu; Wenquan Li & Yancheng Qiu, March 2026 |
| 67 | `Li et al (2014)` | Li et al (2014) - Carbon emission and the cost of capital.pdf | clean |  |
| 68 | `Li et al (2022)` | Li et al (2021) - Corp social resp green fin system guidelines and cost of debt financing.pdf | **year_mismatch** | CSR & Env Mgmt, DOI 10.1002/csr.2222; accepted Nov 2021 (filename), issue 2022 (worklist). Same paper. |
| 69 | `Lin et al (2025)` | Lin et al (2025) - corp carbon emissions and the cost of bank borrowing.pdf | clean |  |
| 70 | `Liu et al (2023)` | Liu et al (2023) - the effect of gov green grip.pdf | clean |  |
| 71 | `Luo et al (2019)` | Luo et al (2019) - Env information disclosure quality.pdf | clean |  |
| 72 | `Ma et al (2022)` | Ma et al (2022) - env violations, refinancing risk.pdf | clean |  |
| 73 | `Maaloul, Wegener (2021)` | Maaloul, Wegener (2022) - Mandatory vs voluntary ghg emissions disclosure and credit risk.pdf | **year_mismatch** | SEAJ 42:1-2, 63-92; online 24 Dec 2021 (worklist), issue 2022 (filename). Same paper. |
| 74 | `Mahmoudian et al (2023)` | Mahmoudian et al (2023) - does ocst of debt relfect the value of quality greenhouse gas esmissions.pdf | clean |  |
| 75 | `Nandy, Lodh (2012)` | Nandy, Lodh (2012) - Do banks value the co-friendliness of firms in their corp lending decision.pdf | clean |  |
| 76 | `Nasih et al (2024)` | Nasih et al (2024) - the relationship of carbon emission disc on the cost of debt.pdf | clean |  |
| 77 | `Ng & Rezaee (2012)` | Ng, Rezaee (unknown) - Sustainability Disclosures and Cost of Capital.pdf | **unknown_year** | undated; SSRN abstract=2038654 (2012) consistent with the worklist year |
| 78 | `Ofogbe et al (2021)` | Ofogbe et al (2021) - The relationship between the CSR and cost of capital.pdf | clean |  |
| 79 | `Oikonomou et al (2014)` | Oikonomou et al (2014) - The effects of corp social perf on the cost of corp debt and credit ratings.pdf | clean |  |
| 80 | `Okimoto & Takaoka (2024)` | Okimoto, Takaoka (2024) - credit default swaps and corp carbon emission in japan.pdf | clean |  |
| 81 | `Okimoto, Takaoka (2022)` | Okimoto, Takaoka (2022) - Sust and credit spreads in japan.pdf | clean |  |
| 82 | `Ould Daoud Ellili (2020)` | Ould Daoud Ellili (2020) - ESG disclosure, ownership structure and cost of capital.pdf | clean |  |
| 83 | `Owolabi et al (2024)` | Owolabi et al (2024) - the impact of carbon risk on the cost of debt.pdf | clean |  |
| 84 | `Palea, Drogo (2020)` | Palea, Drogo (2020) - Carbon emissions and the cost of debt in the eurozone.pdf | clean |  |
| 85 | `Panjwani et al (2023)` | Panjawani et al (2023) - do scope 3 carbon emissions impact firms cost of debt.pdf | clean | filename misspells Panjwani; working paper dated 2 Feb 2023 |
| 86 | `Piechocka-Kałużna et al (2021)` | Piechocka-Kałużna et al (2021) - The impact of CSR ESG on cost of capital.pdf | clean |  |
| 87 | `Pizzutilo et al (2020)` | Pizzutilo et al (2020) - Dealing with carbon risk and the cost of debt.pdf | clean |  |
| 88 | `Polbennikov et al (2016)` | Polebennikov et al (2016) - ESG Ratings and Performance of corp bonds.pdf | clean | filename misspells Polbennikov; Barclays/JPM article, no year on p.1 - worklist year accepted |
| 89 | `Ratajczak & Mikolajewicz (2021)` | Ratajczak, Mikolajewicz (2021) - the impact of env, social and corp gov resp on cost of dbet.pdf | clean |  |
| 90 | `Ririmasse et al (2026)` | Ririmasse et al (2026) - carbon emission, carbon reportin cahnnels and corp debt.pdf | clean |  |
| 91 | `Safiullah et al (2021)` | Safiullah et al (2021) - Carbon emissions and the credit ratings.pdf | clean |  |
| 92 | `Safiullah et al (2025)` | Safiullah et al (2025) - carbon assurance.pdf | clean |  |
| 93 | `Salvi et al (2021)` | Salvi et al (2021) - CSR in the bond market.pdf | clean |  |
| 94 | `Sandra et al (2021)` | Sandra et al (2021) - Long-Run Relationship of CSR and cost of captital of quoted comp in nigeria stock echange.pdf | clean |  |
| 95 | `Schneider (2010)` | Schneider (2010) - Is env perf a deteminant of bond pricing#.pdf | clean |  |
| 96 | `Seltzer et al (2022)` | Seltzer et al (2022) - Climate reg risk and corp bonds.pdf | clean |  |
| 97 | `Shad et al (2022)` | Shad et al (2022) - The efficacy of sustainability reporting towards cost of debt and equity reduction.pdf | clean |  |
| 98 | `Shi et al (2025)` | Shi et al (2025) - is green an effective signal for investors.pdf | clean |  |
| 99 | `Srivisal et al (2021)` | Srivisal et al (2021) - ESG and creditworthiness.pdf | clean |  |
| 100 | `Sze et al (2021)` | Sze et al (2021) - Is the cost of corp debt influenced by ESG factors.pdf | clean |  |
| 101 | `Tan et al (2021)` | Tan et al (2021) - The impact of air pollution on the cost of debt financing.pdf | clean |  |
| 102 | `Tan et al (2026)` | Tan et al (2026) - theimpact of climate risk information disc on corp financing cost.pdf | clean |  |
| 103 | `Tang et al (2023)` | Tang et al (2023) - the impact of env info disc.pdf | clean |  |
| 104 | `Temiz (2022)` | Temiz (2022) - Env perf and cost of finance.pdf | clean |  |
| 105 | `Trinh et al (2024)` | Trinh et al (2024) - eco-innovation and corp cost of debt.pdf | clean |  |
| 106 | `Truong, Kim (2019)` | Truong, Kim (2019) - Do Corporate Social Responsibility Activities Reduce credit risk.pdf | clean |  |
| 107 | `Wang & Wijethilake (2026)` | Wang, Wijethilake (2026) - the effect of carbon disc qualitty.pdf | clean |  |
| 108 | `Wang et al (2020)` | Wang et al (2020) - Corp carbon diaxide emissions and the cost of debt financing.pdf | clean |  |
| 109 | `Wang et al (2022a)` | Wang et al (2022) - Air pollution, env violation risk and the cost of debt.pdf | clean | only one 2022 Wang file AND no 'Wang et al (2022b)' in the worklist - suffix vestigial, assignment forced. IJERPH, Evidence from China |
| 110 | `Wang et al (2025a)` | Wang et al (2025) - corp env perf and bond financing cost.pdf | **suffix_ambiguous** | author-confirmed per v12 provenance (...2025_bond.csv = a): Int Rev Financial Analysis 106 (2025) 104479, bond financing cost |
| 111 | `Wang et al (2025b)` | Wang et al (2025) - u-shaped relationshsip between corp carbon perf and cost of debt.pdf | **suffix_ambiguous** | author-confirmed per v12 provenance (...2025_ushaped.csv = b): CSR & Env Mgmt csr.2953, U-shaped relationships |
| 112 | `Wu et al (2020)` | Wu et al (2020) - An emp study on green env systems certification.PDF | clean |  |
| 113 | `Xiang & Gong (2026)` | Xiang, Gong (2026) - the value of climate disc.pdf | clean |  |
| 114 | `Yang et al (2024)` | Yang et al (2024) - the impact of env information disc on the cost of debt.pdf | clean |  |
| 115 | `Yilmaz (2022)` | Yilmaz (2022) - ESG-Based Sustainability Performance and its Impact on Cost of Capital.pdf | clean |  |
| 116 | `Zhang et al (2023)` | Zhang et al (2023) - how credit defautl swap market measures carbon risk.pdf | clean |  |
| 117 | `Zheng (2021)` | Zheng (2021) - An emprirical study of the impact of CSR and the cost of debt.pdf | clean |  |
| 118 | `Zhou et al (2018)` | Zhou et al (2018) - carbon risk, cost of debt financing and the moderating effect.pdf | clean |  |
| 119 | `Zhou et al (2024)` | Zhou et al (2024) - corp net zero transition and financing cost.pdf | clean |  |
| 120 | `Zhu, Zhao (2022)` | Zhu, Zhao (2022) - Carbon risk and the cost of bank loans.pdf | clean |  |

**Byte-identical duplicate copies (rule 6)** — one processed, one recorded as `duplicate_file:`

| copy (status row only) | processed under |
|---|---|
| Ben Slimane et al (2019) - ESG investing in corp bonds (1).pdf | Ben Slimane et al (2019) - ESG investing in corp bonds.pdf |
| Kozak (2021) - Will the reduction of co emissions lower the cost of debt financing.pdf | Kozak (2021) - will the reduction of co2 emission lower the cost of debt.pdf |

## 4. Extras table

Extra-twin test (GO-2 amendment 3) applied to **every** extra: is this a working-paper or earlier version of a matched worklist study? Evidence = first-page author/title/journal vs the matched worklist file.

| filename | label | twin test | n_records |
|---|---|---|---:|
| Cumming et al (2025) - dynamics of carbon risk, cost of debtand leverage adjustments.pdf | `EXTRA: Cumming et al (2025) - dynamics of carbon risk, cost of debtand leverage adjustments` | NOT a twin — British Accounting Review 57 (2025) 101353; no Cumming in the worklist | 11 |
| Dorfleitner, Grebler (2020) - The social and env dirvers of corp credit ratings.pdf | `EXTRA: Dorfleitner, Grebler (2020) - The social and env dirvers of corp credit ratings` | NOT a twin — Business Research 13:1343–1415; no Dorfleitner in the worklist | 11 |
| Fard et al (2020) - Env regulation and the cost of bank loans.pdf | `EXTRA: Fard et al (2020) - Env regulation and the cost of bank loans` | NOT a twin — J Financial Stability 51 (2020) 100797; no Fard in the worklist | 11 |
| Gangi et al (2020) - The impact of corp gov on scoial and env engagement.pdf | `EXTRA: Gangi et al (2020) - The impact of corp gov on scoial and env engagement` | NOT a twin — British Food Journal 123(2); no Gangi in the worklist | 11 |
| Hachenberg, Schiereck (2018) - Are green bonds priced differently from convential bonds.pdf | `EXTRA: Hachenberg, Schiereck (2018) - Are green bonds priced differently from convential bonds` | NOT a twin — J Asset Manag 19:371–383; no Hachenberg in the worklist | 11 |
| Kacperczyk, Peydro (2026) - carbon emissions and the bank lending.pdf | `EXTRA: Kacperczyk, Peydro (2026) - carbon emissions and the bank lending` | NOT a twin — WP 30 Mar 2026; no Kacperczyk in the worklist | 11 |
| Kleimeier, Viehs (2018) - carbon disc, emission levels and the cost of debt.pdf | `duplicate_version:Kleimeier, Viehs (2021)` | **TWIN** — WP ancestor of `Kleimeier, Viehs (2021)` (author ruling); status row only, no content records | 0 |
| Lee, Choi ( 2021) - Does corp carbon risk mgmt mitigate the cost of debt capital.pdf | `EXTRA: Lee, Choi ( 2021) - Does corp carbon risk mgmt mitigate the cost of debt capital` | NOT a twin — Lee & Choi, Emerging Markets Finance & Trade 57:2138–2151; worklist `Lee (2022)` is a different paper by a different author | 11 |
| Maaloul et al (2021) - The effect of ESG perf and disclosure on cost of debt.pdf | `EXTRA: Maaloul et al (2021) - The effect of ESG perf and disclosure on cost of debt` | NOT a twin — Corporate Reputation Review, ESG performance/disclosure + mediation; worklist `Maaloul, Wegener (2021)` is the SEAJ mandatory-vs-voluntary GHG paper | 11 |
| Nemoto, Liu (2020) - Measuring the effect ESG on sov funding costs.pdf | `EXTRA: Nemoto, Liu (2020) - Measuring the effect ESG on sov funding costs` | NOT a twin — ADBI Working Paper, SOVEREIGN funding costs; no Nemoto in the worklist | 11 |
| Weber et al (2010) - Incorporating Sustainability Criteria into Credit risk mgmt.pdf | `EXTRA: Weber et al (2010) - Incorporating Sustainability Criteria into Credit risk mgmt` | NOT a twin — Bus Strat Env 19:39–50; no Weber in the worklist | 11 |
| Zhou et al (2016) - CSR and credit spread.pdf | `EXTRA: Zhou et al (2016) - CSR and credit spread` | NOT a twin — Annals of Economics and Finance 17-1:79–103 (Hong Zhou, CSR/credit spreads); worklist `Zhou et al (2018)` is the Bus Strat Env carbon-risk paper | 11 |

## 5. Record-count distribution (FULL-mode substitute for the PILOT wall-clock item)

Across the 131 harvested papers:

| metric | substantive (cap 8) | key_citation (cap 3) |
|---|---:|---:|
| min | 6 | 3 |
| median | 8 | 3 |
| mean | 7.93 | 3.00 |
| max | 8 | 3 |

**Papers below the substantive cap: 8 of 131 (6.1%).**

| n | paper |
|---:|---|
| 6 | `Ould Daoud Ellili (2020)` |
| 7 | `Ali et al (2023)` |
| 7 | `Dumrose & Höck (2023)` |
| 7 | `Piechocka-Kałużna et al (2021)` |
| 7 | `Safiullah et al (2025)` |
| 7 | `Shad et al (2022)` |
| 7 | `Wang et al (2025b)` |
| 7 | `Xiang & Gong (2026)` |

**Did the cap act as a ceiling or a quota?** Honest answer: **mixed, and it is binding.**

- *Substantive records* — a ceiling, but a tight one. Eight papers came in under 8 without being asked to, which
  shows the floor is reachable; but the median is 8 and 94% of papers saturate. The cap is therefore **truncating**
  the theory-densest papers, and the harvest systematically under-represents them relative to thin ones.
- *`key_citation`* — here the cap functioned as a **quota**: every one of the 131 papers returned exactly 3. That is
  a direct artefact of §4 wording ("top-3 theory anchor citations"), which reads as an instruction to produce three.
  Treat `key_citation` counts as "the three most load-bearing anchors", not as a measure of anchor density.
- *Why saturation is credible rather than padding.* The corpus is purposively built: every study is on-topic by
  construction, and papers in this literature routinely invoke 3–4 named frames plus mechanisms and counters.
  Supporting evidence, all machine-checked: **0 near-duplicate quote pairs** across 1,432 records (>0.75 token
  overlap between any two substantive quotes in the same paper); mean **3.48 distinct substantive item_types per
  paper** (max 4) with **no paper using only one type**; mean quote length **31.4 words** against a 50-word cap,
  i.e. records are substantial rather than clipped filler; and exactly **one** reused quote string in the whole
  corpus, which is legitimate (a single Polbennikov sentence naming three anchors, split into two `key_citation`
  records with different `cited_work`).
- *Recommendation for consolidation*: treat 8 as a sampling bound, not a census. If Chapter 2 needs exhaustive
  frame coverage for the canonical papers, re-run those few with a raised cap rather than trusting the 8 as complete.

## 6. Anomalies & free observations (max 15 lines)

1. Sub-agent pipeline: one `general-purpose` sub-agent per paper, 13 batches of ≤10 run concurrently; each agent read a shared spec (`EXTRACTION_SPEC.md` encoding v2.3 rules 1–11), read only its own page-annotated text (or page images), wrote one JSON file, and returned a single status line.
2. Agents never wrote to the repo and never saw another paper — no cross-paper contamination is structurally possible, satisfying hard rule 9 at the pipeline level.
3. Every quote was re-verified centrally by the main loop, not trusted from the agent: 1,385/1,432 strict-exact (whitespace-normalised substring of the cited page), 47 via lenient normalisation (ligatures/dashes/quotes), column-span reading order, or image-route token coverage. **0 failures.**
4. Padding check ran on every paper (pairwise >0.75 token overlap between substantive quotes): 0 near-duplicate pairs corpus-wide.
5. Page folios were detected mechanically (modal offset over per-page candidate integers) and validated against the five pilot papers' known ground truth — 5/5 exact. 35 papers legitimately have no printed folios and use the §4 `pdf-N` fallback.
6. Rule-10 gate: text statistics could NOT detect the Chava-style degradation (its garble metrics look cleaner than several sound papers; ligatures swamp the signal). The reliable test is structural — a page-sized image on content pages plus an OCR font. Only 4 of 134 files qualify.
7. Image route applied to Chava (2014), Jiraporn et al (2014), Hamrouni et al (2019a) and EXTRA Lee, Choi (2021). Quotes were transcribed from rendered page images; fresh Tesseract OCR of re-rendered pages (150 dpi) served ONLY as the independent verification reference. The embedded JSTOR text layers were used for neither extraction nor verification.
8. Boermans et al (2023) — Gate-2 flagged "image route likely" on the strength of an empty first page. Content-page probe at extraction: 0 page-sized images, 2,400–4,100 chars/page, normal embedded fonts. **Verdict: text route.** Page 1 is a blank DNB working-paper cover.
9. Extra-twin test (amendment 3) applied to all 12 extras; 1 twin found — `Kleimeier, Viehs (2018)` → `duplicate_version:Kleimeier, Viehs (2021)`, status row only, no content records. Full outcomes in §4.
10. Two same-author extras were tested and cleared as distinct studies rather than versions: Maaloul et al (2021) vs Maaloul, Wegener (2021), and Zhou et al (2016) vs Zhou et al (2018) — different titles, journals and co-author sets.
11. Six worklist year mismatches all resolved to the same paper (online-first vs issue year) and were confirmed by the author against the v12 ledger; the CSV keys use the worklist year throughout.
12. `Kordschia (2020)`: the worklist label misspells the author, who is **Kordsachia**, and three distinct years attach to the paper (received 2019, online 2020, issue 2021). Label kept byte-identical as the CSV key; flagged for Chapter 2's reference list.
13. Fonseka #42/#43 file assignments were swapped on author instruction (v12 provenance sheet); both file-level orderings that the executor could infer (title- and journal-alphabetical) had pointed the other way — provenance beat inference.
14. `paris_policy` is the scarcest record type (112 of 1,432, 7.8%) and is absent from many pre-2015 papers by construction — a substantive finding for Chapter 2, not a coverage gap.
15. Container-side scratch (extracted text, OCR, per-paper JSON, scripts) lives outside the repo; V6 concerns the repo footprint, where exactly the two output files were written.

## 7. Self-check block (§7)

| Check | Result | Evidence |
|---|---|---|
| **V1 Coverage** | **PASS** | all 120/120 worklist labels have ≥1 CSV row; all 12/12 extras present |
| **V2 Completeness** | **PASS** | all 1432 non-status rows carry non-empty `verbatim_quote` and `page` |
| **V3 Quote cap** | **PASS** | longest quote 50 words; mean 31.4, median 32 |
| **V4 Key integrity** | **PASS** | every `study_label` byte-identical to a worklist string or carries the `EXTRA: ` prefix; 132 distinct labels |
| **V5 Count consistency** | **PASS** | 1566 CSV rows = 1432 content + 134 status, matching §1–§2 |
| **V6 Footprint** | **PASS** | only `docs\theory_harvest_ch2.csv` and `docs\theory_harvest_ch2.md` written; nothing else in the repo created, modified, or committed |
| **V7 Extras accounted** | **PASS** | all 12 non-worklist PDFs appear in the extras table — 11 with records, 1 with a `duplicate_version` skip reason |
| **V8 Quote fidelity** | **PASS** | rule-11 verification ran on all 1,432 quotes: 1,385 strict-exact, 47 lenient/column-span/OCR-coverage, **0 failures** |
| **V9 Cap legality** | **PASS** | max 8 substantive records per paper (0 violations) and max 3 `key_citation` per paper (0 violations) |

## 8. Handover (§9)

Both files sit in `docs\`, uncommitted, ready for the M4 package commit (log-first via the M4 DEC; ruling M4-Q11).

Three things worth deciding before consolidation: (a) the substantive cap is binding on 94% of papers — decide whether Chapter 2 needs a raised-cap re-run for the canonical studies; (b) `key_citation` behaved as a quota of exactly 3 everywhere, so anchor counts carry no density information; (c) the `Kordsachia` spelling needs fixing in the manuscript's reference list even though the CSV key stays as-is.
