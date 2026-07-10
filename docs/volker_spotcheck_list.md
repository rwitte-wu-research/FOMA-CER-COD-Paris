# Consolidated spot-check list — v12 coding decisions (2026-07-10)

Status: "confirmed" = author-approved (rulings P-05, r21, E-10/E-23); kept here as audit documentation.
"OPEN" = please verify against staging files / classifications.

## A. Country-scheme extension rules (P-05 — confirmed 2026-07-10)
| # | Rule | Classification | Status |
|---|------|----------------|--------|
| 1 | Egypt | region 99_NCE · culture non-western · legal civil (French origin) | confirmed |
| 2 | South Africa | region 99_NCE · legal common law (La Porta English origin) | confirmed |
| 3 | United Arab Emirates | legal 99_NCE (mixed Islamic/civil, not in La Porta) | confirmed |
| 4 | "18 named European + Other" | region 2_Europe · culture western · legal 99_NCE | confirmed |
| 5 | "37/57-country dual green-patent sample" | all 99_NCE | confirmed |
| 6 | "~20 EM economies (syndication venues)" | econ per basket · rest 99_NCE | confirmed |

## B. field codings, 60 new studies (E-08) — 8 flagged rows
| # | Study/journal | Coded | Status |
|---|---------------|-------|--------|
| 1 | Energies | 2_sust | confirmed (r21 block) |
| 2 | SAGE Open | 3_mgmt | confirmed |
| 3 | Int. J. of Ethics and Systems | 3_mgmt | confirmed |
| 4 | European Research Studies Journal | 1_fin/acc/econ | confirmed |
| 5 | Economics and Business Review | 1_fin/acc/econ | confirmed |
| 6-8 | 3 journal-less WPs (Ben Slimane, Zheng, Zhou) | 1_fin/acc/econ (content-based) | confirmed |

## C. Regulation recodes (P-03, E-12) — 3 flagged
| # | Study | Fill | Rationale | Status |
|---|-------|------|-----------|--------|
| 1 | Höck et al (2020) | with ETS/CT (both) | all-European; EU ETS since 2005; per-row windows unreported | confirmed |
| 2 | Sze et al (2021) | start = without ETS/CT | mirrors coded end (accretion); AUS-repeal caveat | confirmed |
| 3 | Yilmaz (2022) | 99_NCE (both) | heterogeneous incl. AUS CT repeal 2014 | confirmed |

## D. Subsample-map interpretations (r21/E-20) — 5 flagged
| # | Value | Interpreted as | Status |
|---|-------|----------------|--------|
| 1 | EM | Emerging Markets → econ 2_developing | confirmed |
| 2 | DAP | Developed Asia-Pacific → region 3_AsiaPac, econ 1_developed | confirmed |
| 3 | DNA | Developed North America → region 99_NCE, econ 1_developed, culture western | confirmed |
| 4 | DE | Developed Europe → region 2_Europe, econ 1_developed, culture western | confirmed |
| 5 | North America | region 99_NCE, culture western (US+Canada presumed) | confirmed |

## E. OPEN items for Volker
| # | Item | Question |
|---|------|----------|
| 1 | Subsample values "Central" / "Eastern" / "Western" (n=3 rows) | Which geography? Currently inherit paper level (R-20) |
| 2 | n_obs = 'FLAG' (176 cells; R-19) | Adjudicate raw n_obs; col E currently uses n_firms x window-years proxy |
| 3 | d_country truncation artefacts (raw layer, D4-WARN) | Optional hygiene pass in staging exports; no analysis impact (column not used for derivation) |
| 4 | 16 usable-ES rows without any n (Ould Daoud Ellili 2020; Piechocka-Kałużna et al 2021) | Re-check papers for firm counts; else rows drop from estimation |
