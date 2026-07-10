# Screening Log — FOMA update search (title/abstract)

Task: offline title/abstract screening of the update-search worklist for a first-order meta-analysis of firm-level ENVIRONMENTAL constructs (IV) -> corporate COST OF DEBT (outcome).
File screened: dbrun/screening_worklist.csv  (backup: screening_worklist.backup.csv)
Records: 1720   |   All screened: 100%   |   Pre-2020 recall rows: 114 (screened on merit, not excluded for age)   |   Missing abstract: 11

## Method
- Reasoning-based screening, not keyword matching (keyword-only would misfire: e.g. id 2, a typhoon-attribution paper containing "catastrophe bond yield", correctly excluded as no-COD-outcome).
- Recall-oriented: when torn between include and a confident exclude, defaulted to include-candidate or FLAG. Composite ESG treated as include-candidate (E/S/G separation deferred to full text).
- Records processed in 15 slices of ~115; verdicts merged back with full ID reconciliation (1720/1720 matched, 0 invalid verdicts, 0 gaps).

## Overall tally
- include-candidate             647
- FLAG                          101
- exclude:no-COD-outcome        312
- exclude:not-firm-level        206
- exclude:review-or-nonempirical  360
- exclude:no-E-construct         65
- exclude:duplicate              18
- exclude:language                1
- exclude:other                  10

Carried forward to full-text stage: include-candidate + FLAG = 748.

## Batch tallies (blocks of 50 records by row order)

| batch | rows | incl | FLAG | no-COD | not-firm | review | no-E | dup | lang | other |
|------:|-----:|-----:|-----:|-------:|--------:|-------:|-----:|----:|-----:|------:|
| 1 | 1–50 | 25 | 4 | 11 | 1 | 6 | 1 | 0 | 0 | 2 |
| 2 | 51–100 | 22 | 5 | 8 | 6 | 7 | 2 | 0 | 0 | 0 |
| 3 | 101–150 | 21 | 6 | 9 | 3 | 6 | 1 | 0 | 0 | 4 |
| 4 | 151–200 | 26 | 2 | 8 | 5 | 7 | 2 | 0 | 0 | 0 |
| 5 | 201–250 | 19 | 8 | 8 | 8 | 5 | 2 | 0 | 0 | 0 |
| 6 | 251–300 | 27 | 11 | 5 | 3 | 0 | 4 | 0 | 0 | 0 |
| 7 | 301–350 | 22 | 6 | 13 | 7 | 0 | 2 | 0 | 0 | 0 |
| 8 | 351–400 | 27 | 3 | 10 | 3 | 4 | 3 | 0 | 0 | 0 |
| 9 | 401–450 | 26 | 4 | 9 | 7 | 4 | 0 | 0 | 0 | 0 |
| 10 | 451–500 | 22 | 3 | 7 | 11 | 5 | 2 | 0 | 0 | 0 |
| 11 | 501–550 | 25 | 5 | 6 | 7 | 6 | 0 | 0 | 0 | 1 |
| 12 | 551–600 | 25 | 3 | 10 | 5 | 5 | 2 | 0 | 0 | 0 |
| 13 | 601–650 | 31 | 0 | 14 | 3 | 0 | 2 | 0 | 0 | 0 |
| 14 | 651–700 | 24 | 1 | 9 | 6 | 7 | 2 | 1 | 0 | 0 |
| 15 | 701–750 | 17 | 2 | 14 | 5 | 11 | 1 | 0 | 0 | 0 |
| 16 | 751–800 | 19 | 2 | 15 | 4 | 7 | 3 | 0 | 0 | 0 |
| 17 | 801–850 | 19 | 6 | 10 | 6 | 9 | 0 | 0 | 0 | 0 |
| 18 | 851–900 | 24 | 2 | 12 | 4 | 7 | 1 | 0 | 0 | 0 |
| 19 | 901–950 | 14 | 3 | 17 | 3 | 10 | 3 | 0 | 0 | 0 |
| 20 | 951–1000 | 9 | 2 | 10 | 8 | 15 | 4 | 1 | 0 | 1 |
| 21 | 1001–1050 | 7 | 0 | 6 | 9 | 22 | 2 | 4 | 0 | 0 |
| 22 | 1051–1100 | 9 | 0 | 9 | 9 | 14 | 7 | 2 | 0 | 0 |
| 23 | 1101–1150 | 17 | 1 | 10 | 13 | 7 | 1 | 1 | 0 | 0 |
| 24 | 1151–1200 | 25 | 1 | 9 | 3 | 11 | 0 | 1 | 0 | 0 |
| 25 | 1201–1250 | 23 | 4 | 7 | 5 | 7 | 2 | 1 | 0 | 1 |
| 26 | 1251–1300 | 20 | 5 | 8 | 2 | 14 | 0 | 1 | 0 | 0 |
| 27 | 1301–1350 | 11 | 3 | 8 | 6 | 17 | 1 | 3 | 0 | 1 |
| 28 | 1351–1400 | 15 | 3 | 7 | 5 | 16 | 3 | 1 | 0 | 0 |
| 29 | 1401–1450 | 11 | 1 | 4 | 8 | 22 | 3 | 1 | 0 | 0 |
| 30 | 1451–1500 | 8 | 0 | 9 | 12 | 20 | 1 | 0 | 0 | 0 |
| 31 | 1501–1550 | 7 | 3 | 4 | 4 | 29 | 2 | 1 | 0 | 0 |
| 32 | 1551–1600 | 12 | 0 | 3 | 10 | 23 | 2 | 0 | 0 | 0 |
| 33 | 1601–1650 | 21 | 1 | 11 | 6 | 8 | 3 | 0 | 0 | 0 |
| 34 | 1651–1700 | 12 | 1 | 9 | 8 | 19 | 1 | 0 | 0 | 0 |
| 35 | 1701–1720 | 5 | 0 | 3 | 1 | 10 | 0 | 0 | 1 | 0 |
## Borderline notes (FLAG) — 101 records for reviewer adjudication

Grouped roughly by the reason they were held rather than auto-decided.

| id | year | flag note | title (short) |
|---:|-----:|-----------|---------------|
| 18 | 2025 | insurer default risk (Z-score), not a listed COD measure | Does Climate Change Risk Impact Insurance Credit Risk? Cross Country E |
| 31 | 2026 | climate stress test on SME loan default probability | Climate Stress Testing on European SME Securitised Loans Under Climate |
| 42 | 2023 | green credit policy; cost of debt only mediator to carbon perf | How does green credit policy improve corporate social responsibility i |
| 43 | 2023 | methodological ESG score aggregation, linked to credit rating | How to combine ESG scores? A proposal based on credit rating predictio |
| 54 | 2026 | ESG and insurer default risk, not a listed COD measure | Does ESG Performance Reduce Default Risk in Insurance Firms? Evidence  |
| 66 | 2025 | ESG and credit risk (distance-to-default), not listed COD | ESG Performance and Credit Risk: Evidence From Chinese Manufacturing C |
| 69 | 2026 | carbon emissions and firm default risk (PD) | Extending Risk Horizons: Impact of Carbon Emissions on Firm Default Ri |
| 84 | 2023 | climate transition risk and firm default risk, not listed COD | Climate transition risk in determining credit risk: evidence from firm |
| 91 | 2026 | carbon cost exposure and firm default risk, not listed COD | The cost and benefit of GHG emissions and default risk |
| 104 | 2025 | country-level climate risk and aggregate loan pricing | Climate risk and loan pricing: the moderating role of trilemma policy  |
| 105 | 2024 | green innovation and credit risk/volatility, ambiguous COD | Green innovation, firm performance, and risk mitigation: evidence from |
| 112 | 2026 | ESG and credit risk KMV model, methodological | Nexus Between ESG Performance and Credit Risk in Chinese FinTech Compa |
| 114 | 2026 | multimodal ML default prediction, methodological framework | Multimodal Insights into Credit Risk Modelling: Integrating Climate an |
| 115 | 2025 | ESG score moderates cost of debt; governance is primary IV | Alternative finance in bank-firm relationship: how does board structur |
| 141 | 2025 | Unclear if empirical study or methodology-only paper | Bayesian learning models to measure the relative impact of ESG factors |
| 176 | 2024 | Outcome is default risk index, unclear if maps to COD list | Dissecting the impact of the three E, S, G pillars on credit risk |
| 183 | 2021 | Distance-to-default outcome, not explicit COD measure | Carbon emissions and default risk: International evidence from firm-le |
| 218 | 2025 | Debt cost is mediator; direction vs carbon risk unclear | Global reach, local impact: How China's outward foreign direct investm |
| 224 | 2026 | Outcome is default probability, not loan pricing | A climate stress testing exercise on loans to European small and mediu |
| 227 | 2026 | EDF outcome, unclear mapping to cost of debt | The rise of climate risks: Evidence from firms’ expected default frequ |
| 236 | 2022 | Outcome is default risk, not bond/loan/CDS/rating; verify at full text | ESG and Firm's Default Risk |
| 245 | 2023 | Outcome is default risk/creditworthiness proxy, not literal COD; verify | Does ESG performance improve firm creditworthiness? |
| 247 | 2023 | Outcome is PD, not explicit loan price; verify at full text | Assessing the influence of ESG score, industry, and stock index on fir |
| 249 | 2024 | COD appears as secondary interaction effect, not main outcome; verify | Building a sustainable future: The role of corporate social responsibi |
| 250 | 2024 | COD is mediator not final outcome; verify relevance at full text | Climate-related disclosures under the TCFD framework and business gree |
| 254 | 2024 | Cost of debt not directly modeled as DV; verify at full text | ESG rating divergence and audit fees: Evidence from China |
| 255 | 2024 | Sample may include sovereign/agency issuers, not only corporates; verify | Effects of ESG performance and sustainability disclosure on GSS bonds’ |
| 260 | 2025 | Outcome is bankruptcy risk, not literal cost of debt; verify | Corporate ESG performance and bankruptcy risk |
| 262 | 2025 | Cost of debt is a secondary consequence, not modeled directly; verify | Corporate climate risk perception and debt concentration |
| 265 | 2025 | Outcome is default risk/creditworthiness, not literal COD; verify | ESG-ETFs and the constituent firms’ default risk mitigation |
| 268 | 2025 | Unclear if outcome is market-priced COD or internal risk metric; verify | Weathering the storm: How climate risks shape bank credit risk in Euro |
| 269 | 2025 | COD raised only as narrative mechanism, not primary DV; verify | Price of climate risk: Evidence from the value of cash holdings |
| 273 | 2025 | COD is mechanism not final outcome; verify at full text | Green credit policy and corporate innovation: A study of heavily pollu |
| 279 | 2026 | Bond-level LatAm sample, firm-level status of issuers unclear; verify | Regulatory transparency and cost of ESG debt: Evidence from Latin Amer |
| 282 | 2026 | Cost of debt is a downstream consequence of innovation, not IV; verify | Green preferences of financial capital and strategic green innovation: |
| 292 | 2023 | Abstract describes exploratory/qualitative financial-sector exposure study; verify | Low-carbon transition risks for India's financial system |
| 306 | 2023 | Outcome is distance-to-default/Z-scores, not literal COD; verify | The influence of green innovation on default risk: Evidence from Europ |
| 317 | 2025 | Outcome framed as debt accessibility, not clearly a pricing measure; verify | Unlocking finance through sustainability: Evidence from Italian-listed |
| 324 | 2026 | Outcome is default distance/EDF, not literal COD; verify | The modified ESG-KMV model for default prediction |
| 325 | 2026 | Bank risk measure unspecified, unclear if market-priced COD; verify | Greenwashing and bank credit risk: Fresh evidence on the role of board |
| 339 | 2024 | Abstract describes analytical model, unclear if empirically estimated; verify | Bank-tax-interaction, carbon emission reduction investment and financi |
| 341 | 2024 | Scenario-based stress test, not firm cost-of-debt regression; verify | Will fighting climate change affect commercial banks? A carbon tax pol |
| 373 | 2021 | Ambiguous: bank's own risk vs portfolio risk | The determinants of green credit and its impact on the performance of  |
| 386 | 2025 | Primary outcome is loan amount, pricing unclear | Greenhouse gas emissions and bank lending in Japan |
| 390 | 2021 | Scenario/framework model, unclear if statistical regression | Can European electric utilities manage asset impairments arising from  |
| 405 | 2021 | Driven by borrower portfolio quality vs bank's own COD | Carbon neutrality, bank lending, and credit risk: Evidence from the Eu |
| 437 | 2024 | Simulation-based PD, unclear if statistical estimation | Assessing credit risk sensitivity to climate and energy shocks: Toward |
| 440 | 2024 | Ambiguous: institution's own risk vs portfolio risk | The impact of climate change on credit risk of rural financial institu |
| 441 | 2026 | Ambiguous: bank's own COD vs portfolio risk | Physical climate risk and banks’ credit risk: Worldwide evidence |
| 451 | 2026 | Main IV not environmental; climate risk is a mediator | Costs of bank loans and industrial robot adoption: Cross-country evide |
| 470 | 2025 | ESG risk and bank credit risk; unclear if COD metric | ESG relevance in credit risk of development banks |
| 484 | 2024 | emissions/env scores and probability of default, not listed COD metric | Effects of climate change and technological capex on credit risk cycle |
| 502 | 2023 | ESG and credit risk at bond-portfolio level, not per-firm | ESG criteria and the credit risk of corporate bond portfolios |
| 504 | 2026 | ESG performance and default risk; not explicit COD metric | ESG performance and corporate default risk: insights from investor per |
| 529 | 2026 | DSGE model with weak/ambiguous firm-level cost-of-capital regression | Green transition and stock market risk: a theoretical and empirical an |
| 530 | 2026 | robot adoption IV not clearly an environmental construct | Industrial robot adoption and green premium: evidence from China |
| 539 | 2026 | green bond borrowing costs; issuer type (sovereign/firm) unclear | Banking against sustainable finance: the effect of the European centra |
| 571 | 2025 | climate risk index and firm credit risk metric unclear | Effects of climate change on firm credit risk: evidence from China |
| 580 | 2025 | simulation-based structural credit risk model; empirical status unclear | Carbon risk pricing under ambiguity: a Knightian uncertainty approach |
| 589 | 2022 | simulation/calibration of climate-driven default risk; empirical status unclear | The impact of climate risk on corporate credit risk |
| 692 | 2025 | Borrowing costs/default risk only briefly mentioned, no abstract | Temperature fluctuations, climate uncertainty, and financing hindrance |
| 723 | 2014 | Uses credit ratings as data source but direction/outcome unclear | The Link between Firm Financial Performance and Investment in Sustaina |
| 744 | 2024 | COD mentioned as interpretation, not directly measured outcome | Carbon emission intensity, energy management practices and financial l |
| 768 | 2022 | Abstract emphasizes cost of capital, not clearly cost of debt | Do ESG Factors Influence Investment Attractiveness of the Public Compa |
| 770 | 2023 | Predictive model vs actual ratings; borderline methodological | Developing a Scoring Credit Model Based on the Methodology of Internat |
| 809 | 2026 | Unclear if loan cost is bank's own COD or issued-loan pricing | Adverse Weather Events and Costs of Bank Loans in the 4.0 Digital Cont |
| 810 | 2024 | Credit spread outcome present but driven by policy, not firm E-construct IV | IMPACTS OF NEW MONETARY POLICY TOOLS, BOND CREDIT SPREADS ON CORPORATE |
| 813 | 2023 | Firm-level vs industry-level unit unclear | Measuring climate-credit risk relationship using world input-output ta |
| 816 | 2023 | Methodology paper on credit-factor volatility, not clear firm E->COD test | Climate-change scenarios require volatility effects to imply substanti |
| 819 | 2023 | Methodological deep-learning classifier; reports carbon feature importance for risk grade | Early warning research on enterprise carbon emission reduction credit  |
| 837 | 2022 | ML classification of green credit risk; not standard COD/rating measure | Assessing and Predicting Green Credit Risk in the Paper Industry |
| 851 | 2023 | Methodological ML classifier using carbon/compliance features, not standard COD | Credit Risk Assessment of Heavy-Polluting Enterprises: A Wide-lp Penal |
| 894 | 2024 | COD2 used as moderator of intermediary effect, unclear direct ESG->COD test | The Impact of ESG on Excessive Corporate Debt |
| 919 | 2017 | fsQCA method; COD is intermediate necessary condition, primary Y is ROE | Sustainability Matter and Financial Performance of Companies |
| 931 | 2025 | Outcome 'credit risk' measure not specified; unclear if price-based COD | Linking Climate Risk to Credit Risk: Evidence from Sectorial Analysis |
| 939 | 2022 | Outcome is 'credit risk sensitivity'; unclear if maps to COD measure | CREDIT RISKS SENSITIVITY TO CARBON PRICE |
| 963 | 2023 | Discusses bond yields as background topic but own outcome is investor reaction/env perform | ROLE OF GREEN BONDS IN PROMOTING SUSTAINABILITY AND THEIR EFFECTS ON P |
| 964 | 2026 | Outcome 'credit risk' of banks; measure not specified as price-based | Climate vulnerability and credit risk: challenges and approaches for t |
| 1131 | 2026 | Comment-type article; may embed empirical bond spread results, check full text | Comment on "Beyond Green: Impacts of Green Bond Issuance on Convention |
| 1156 | 2018 | No abstract; trade-press title on ESG credit focus | Credit Risk Analysts Sharpen Their Focus On ESG. |
| 1211 | 2020 | Integrated reporting (not purely environmental) predicts cost of debt | Does it pay off? Integrated reporting and cost of debt: European evide |
| 1232 | 2024 | No abstract; title suggests env. performance on loan pricing | Effect of Corporate Environmental Performance on Banks' Loan Pricing. |
| 1233 | 2025 | Green innovation mediates credit risk; unclear if IV is E | Effect of Cross-Ownership on Firm Green Innovation. |
| 1250 | 2025 | ESG rating predicts CFP; borrowing cost mentioned as side finding | Environmental, social, and governance ratings and corporate financial  |
| 1262 | 2019 | No abstract; trade-press title on ESG in credit risk | ESG Climbs Agenda In Credit Risk Analysis. |
| 1263 | 2023 | ESG predicts portfolio-level credit risk, not clear firm COD | ESG criteria and the credit risk of corporate bond portfolios. |
| 1284 | 2019 | credit risk mechanisms, no explicit COD metric named | ESG, Material Credit Events, and Credit Risk. |
| 1287 | 2022 | title plausible: ESG and credit risk Latin America, no abstract to confirm | ESG Performance and Credit Risk in Latin America. |
| 1294 | 2023 | abstract in English but title Turkish; verify publication language | ESG Performansı ile Borç Maliyeti Arasındaki İlişki Üzerine Bir Araştı |
| 1308 | 2026 | closely related to credit risk but not explicit COD metric | ESG risks and corporate viability: Insights from default probability t |
| 1314 | 2024 | abstract English, title Chinese; verify publication language | ESG 第三方確信、負面社會責任 新聞報導與債務資金成本間之關聯性. |
| 1330 | 2026 | carbon emissions and PD, not explicit bond/loan/rating metric | Extending Risk Horizons: Impact of Carbon Emissions on Firm Default Ri |
| 1360 | 2020 | title lists ESG topics generally, no clear empirical COD study | From Mental Health to Credit Risk, Here Are Next Big ESG Topics. |
| 1376 | 2024 | green innovation reduces volatility/credit risk broadly stated | Green innovation, firm performance, and risk mitigation: evidence from |
| 1399 | 2017 | CSI/media coverage IV borderline social vs environmental; outcome 'financial risk' may not | How Media Coverage of Corporate Social Irresponsibility Increases Fina |
| 1408 | 2025 | empty abstract; title plausible for ESG->credit rating relationship | Impact of ESG Implementation on Credit Ratings and Financial Performan |
| 1502 | 2026 | climate risk portfolio model; unclear if firm cost-of-debt statistically estimated | Physical Climate Risk in Asset Management. |
| 1516 | 2024 | carbon emissions and capital market pricing; COD outcome unclear | PRICING OF CLIMATE RISKS IN THE CAPITAL MARKET OF SOUTH AFRICA. |
| 1529 | 2025 | disclosure content analysis; no clear COD statistical link | Quality over quantity? Using corporations’ climate change-related disc |
| 1602 | 2025 | climate uncertainty and financing hindrance; COD outcome unclear | Temperature fluctuations, climate uncertainty, and financing hindrance |
| 1653 | 2014 | Abstract unclear whether S&P credit ratings serve as a COD outcome or merely a data source | The Link between Firm Financial Performance and Investment in Sustaina |

## Verification performed
- ID reconciliation: 1720/1720 records received exactly one verdict from an allowed code; 0 invalid, 0 missing, 0 duplicated IDs.
- False-include audit: scanned include-candidates for review/bibliometric language; the 2 hits (ids 731, 811) are empirical studies, not reviews — correctly included.
- False-exclude audit: 109 no-COD excludes still contain a debt-term string; sampled (ids 61, 133, 923, 1154) confirm correct — outcome is loan volume/access, debt maturity, issuance amount, or rating-as-predictor, none a cost-of-debt price.
- Sovereign/household separation spot-checked under not-firm-level (206 records).
- Pre-2020 rows (114) verified screened on merit (20 include-candidate, 7 FLAG), not excluded for age.

## Known limitations
- Screening reflects abstract-level judgment; final E-vs-composite-ESG separation and effect-size convertibility are deferred to full text by design.
- "duplicate" (18) marks likely title/DOI-near duplicates surfaced during screening; de-duplication should be confirmed against the reference manager.