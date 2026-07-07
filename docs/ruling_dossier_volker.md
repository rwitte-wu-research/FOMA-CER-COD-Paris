# ✅ VERDIKTE (Autor, 2026-07-07) — Ruling-Layer geschlossen
R1 Skalen-Lesart bestätigt (3 Vorzeichen drehen; 409-Fix) · R2 Option (b): rein mit Tag `construct_variant=price-valued` · R3 REIN — Grenzformel (Autor): **Unit = Firma und darunter (firmeneigene Assets/Entscheidungen) rein; oberhalb der Firma raus** · R4 Liste + 50%-Schwelle + `mixed` bestätigt · R5 beide behalten, **ein Cluster**, Duplikat-Korrelation zählt einmal (Sandra-Set, N=1.440; Ofogbe-Kopie Tag `duplicate`) · R6 **ein Cluster** (F47a), 9 Duplikate einfach, EL-Zeile (Scope-1, t=7.47, N=2.267) add mit Tag `source=EL2021`, EL 2021 = zitierbare VoR · R7 bestätigt · R8 geschlossen ohne Antwort (PRISMA-Prosa label-frei) · K1 rein (Tag slope-group) · K2 rein (Tag PSM-ATT) · K3 ok (χ²→z, Vorzeichen aus b) · K4 ENTFÄLLT (Datei-Beweis: volle Statistik; Reviewer-Empfehlung zurückgezogen)

---

# Ruling-Dossier für das Adjudikationsgespräch — entscheidbar ohne Paper-Zugriff
Stand: 2026-07-07 · Grundlage: adjudication_package_v1.xlsx · Alle Zahlen aus Staging/v10-Diff verifiziert.
Legende je Posten: Kontext → Evidenz → Optionen (mit Konsequenz) → Empfehlung (+ Entscheidungskriterium) → von Volker benötigt.

---

## R1 · F35a — Devalle: Erratum-Korrektur + Richtungskonflikt [3 Zeilen; blockiert T1]
**Kontext:** Ordered-Logit, Refinitiv-E-Scores → Credit Rating; Tabellen berichten Odds Ratios + |z|. v10 rechnete (OR−1)/SE als b/SE — auf Zeile 409 traf das einen gedruckten OR-Misprint (0.0966 statt ~1.0x) und erzeugte **r = +0.9998** (Fisher-z ≈ 4,3 — analytisch giftig).
**Evidenz:** Neue Extraktion nimmt die z-Route (|z| = 0.67 / 1.11 / 2.32; Vorzeichen aus OR≷1: +/+/−). Die (OR−1)/SE-Route ist seit DEC-037 verboten. **Teil 1 (Magnitude) ist damit mechanisch: 409 → |z|=2.32, p=.021.**
**Teil 2 — Richtung:** Das Paper kodiert die Rating-Variable **1 = AAA … 7 = CCC** (höher = schlechter = Kostenrichtung), interpretiert im Text aber OR>1 als „besseres Rating" — interner Widerspruch.
| Lesart | outcome_direction | v11-Vorzeichen (RU / Emis / EnvInnov) | Bedeutung |
|---|---|---|---|
| (i) Skalen-Lesart (gedruckte Kodierung) | cost, kein Flip | **+0.009 / +0.014 / −0.031** | gute CER ↑ Kosten (n.s.) bzw. EnvInnov ↓ Kosten (sig.) |
| (ii) Autoren-Prosa (creditworthiness, Flip) | Flip | −0.009 / −0.014 / +0.031 | reproduziert v10-Vorzeichenmuster |
**Empfehlung: (i).** Kriterium: Die gedruckte Variablendefinition schlägt die Interpretations-Prosa; der Widerspruch wird im Log dokumentiert. Konsequenz: alle drei v10-Vorzeichen drehen (plus 409-Magnitude-Fix).
**Von Volker:** Bestätigung; Erinnerung, ob er 2021 einen Grund für die Prosa-Lesart hatte.

## R2 · F39c — Delis: preis-bewertete Reservenvarianten [4 geflaggte Zeilen]
**Kontext:** F38 holte Reserven als embedded-emissions-Conduct rein (Mengenbestände). 4 der 32 Delis-Zeilen nutzen **preis-bewertete** Reserven (Menge × Fossilpreise → $-Wert).
**Evidenz:** Varianz der Variable stammt teils aus Marktpreisen, nicht aus der Carbon-Menge der Firma.
**Optionen:** (a) raus — nur Mengenvarianten (prinzipienrein zur F38-Grenze „market-implied = Exposure"); (b) rein mit Tag `construct_variant = price-valued` (All-Models-Linie, filterbar); (c) rein + Sensitivität ohne.
**Empfehlung: (a)**; falls maximal-inklusive Linie gewünscht (euer bisheriges Muster: F42b, F45a), ist **(b)** verteidigbar — dann Tag zwingend. Kriterium: Kommt die Variation aus der Firmenmenge oder aus dem Preis? Konsequenz: ±4 Zeilen.
**Von Volker:** nichts Spezifisches; reine Grenzziehung.

## R3 · F39e — Eichholtz: Unit-Frage Gebäude/Kredit [36 v10-Zeilen ↔ 11 neu; 31 Diff-Posten]
**Kontext:** Green-Building-Zertifizierung → CMBS-/Hypotheken-Spreads; Beobachtungseinheit = Gebäude/Kredit, nicht Firma. R2.1 sagt „unit = firm"; as-executed (v10) war die Studie mit 36 Zeilen drin.
**Evidenz:** Neue Extraktion behielt 11 Zeilen (mit Unit-FLAG); 25 v10-Zeilen offen. Abgrenzung zu den Sovereign-Exits: Hier liegt eine **bewusste Umwelt-Entscheidung des Kreditnehmers am finanzierten Asset** vor, und das Outcome preist exakt dieses Asset.
**Optionen:** (a) Exit (strikte Firm-Unit; −36 Zeilen, −1 Studie — Capelle-Logik); (b) **bleiben mit dokumentierter Asset-Level-Ausnahme**: qualifiziert, wenn (i) Zertifizierung = Entscheidung des Kreditnehmers und (ii) Outcome = Pricing desselben Assets; Tag `unit = building/loan`; (c) bleiben + Sensitivität ohne.
**Empfehlung: (b)** — sauber abgrenzbar von Capelle/Nemoto (dort Staaten-Unit ohne Conduct-Charakter); (c) als Zusatzabsicherung gratis. Konsequenz (a): Ledger 61→60 / −36.
**Von Volker:** seine damalige Unit-Überlegung; welche der 36 Zeilen ggf. Portfolio- statt Gebäudeebene sind.

## R4 · F37b — Operationalisierung `industry = sensitive` [korpusweit; Moderator-Integrität T7]
**Kontext:** Feld existiert in v10 für alle Legacy-Studien (implizite Volker-Regel), ist aber nirgends definiert; Extraktor-FLAG seit Mini-Pilot (Al-Fakir: 50,6 % vs. 25,8 % je nach Industrials-Zuordnung).
**Vorschlag zur Bestätigung/Korrektur:** sensitive-Sektorliste = {Oil & Gas, Energy, Utilities, Basic Materials/Chemicals, Mining/Metals, Paper/Forestry, Zement/Baustoffe}; **Schwelle: > 50 % der Firm-Years** (ersatzweise Firmen) im Sample; Single-Sector-Studien trivial; keine klare Mehrheit → `non-sensitive` (konservativ) — oder `mixed`-Wert analog F36b?
**Optionen für den Grenzfall:** (a) 50 %-Regel + non-sensitive als Default; (b) 50 %-Regel + neues `mixed`-Label (konsistent mit regulation-Feld).
**Empfehlung: (b)** — Symmetrie zur F36b-Logik; verhindert Fehlklassen in T7. Konsequenz: wenige Studien wechseln die Klasse; FLAGs (u. a. Al-Fakir) lösen sich mechanisch.
**Von Volker:** WAR seine implizite v10-Regel ≈ diese Liste/Schwelle? Abweichungen benennen — v10-Werte bleiben sonst unerklärlich.

## R5 · Sandra ↔ Ofogbe — Unabhängigkeit [2 + 3 Zeilen; Präzedenz für Cluster-Handling]
**Kontext:** Beide Nigeria 2021; identisches r(COD, ENP) = 0.001, p = .9818 — Zufall praktisch ausgeschlossen.
**Optionen:** (a) gleiche Datenbasis, unterschiedliche Modelle → **ein Cluster-ID** im 3LMA (beide bleiben, Abhängigkeit modelliert); (b) Quasi-Duplikat → Drop-one (die vollständigere/publizierte Fassung bleibt); (c) unabhängig → keine Aktion.
**Empfehlung:** Entscheidungsregel statt Vorab-Urteil: gleiche Stichprobe + überlappende Modelle → (a); nahezu identischer Zeilensatz → (b). Konsequenz: max. −2 oder −3 Zeilen bzw. Cluster-Vermerk.
**Von Volker:** Kenntnis der Autorenteams/Datenquelle — das ist der einzige fehlende Fakt.

## R6 · F47a — K&V-Cluster bestätigen + 1 Rest-Zeile [WP 28 ↔ EL-2021 10]
**Kontext & Evidenz:** 9/10 EL-Zeilen numerisch im 2018-WP reproduziert (±0.002); gleiches Fenster 2009–2016. Autor-ok liegt vor: **ein Studien-Cluster; WP-Zeilensatz kanonisch; EL 2021 = zitierbare VoR** (Lookup/q_VHB).
**Offen:** die 1 Nicht-Treffer-Zeile — (a) neues Modell der EL-Fassung → dem kanonischen Satz HINZUFÜGEN (Tag `source = EL2021`); (b) Rundungs-/Variantenfall → dedupen. Entscheidbar aus den beiden Staging-CSVs nebeneinander (cell_quotes vorhanden), 10 Minuten.
**Von Volker:** Kein Einspruch + das 10-Minuten-Urteil zur Restzeile.

## R7 · F35b/c — Atif: zwei Feld-Errata [1 Studie]
**b — Regulation invertiert:** v10: start=`with ETS/CT` (2006), end=`without` (2017) — USA hatten in keinem der Jahre ein nationales Schema; Extraktion: without/without (+ Subnational-Notiz, per F36g irrelevant). **Fix: without/without.** Einzige Rückfrage: Gab es eine mir unbekannte Kodier-Konvention, die das v10-Muster erklärt?
**c — CER_measure:** v10 = `performance`; Extraktion = `disclosure` mit wörtlichem Paper-Beleg (§6.4 rahmt Bloomberg-ESG explizit als Disclosure-Maß; Asset4 als Performance). **Empfehlung: Paper-Framing folgen** — Bloomberg-Zeile `disclosure`, Asset4-Zeile `performance`. Beleg liegt als cell_quote/Log-Zitat vor; kein Paper-Zugriff nötig.

## R8 · Exklusionslisten-Semantik [reine PRISMA-Doku, keine Datenwirkung]
**Kontext:** Die 42er-Liste referenziert „Excluded from paper 1/paper 2" in sich inkonsistent (Chava „PD/DTD not subject of Paper 2" vs. Chen „cost of borrowing — should be paper 2").
**Fragen:** (a) Paper 1 = COE-Companion und Paper 2 = COD — oder umgekehrt? (b) Existiert eine neuere Listenfassung (die vorliegende ist nachweislich veraltet: ~12 Einträge sind längst Korpusmitglieder)?
**Konsequenz:** ausschließlich die PRISMA-Prosa; die Rescreen-Triage war klassenbasiert und semantikunabhängig.

---

# Kurz-Rulings aus der Rescreen-Tranche (F47 b–e) — je 1 Urteil, Empfehlung steht

| # | Fall | Sachverhalt | Empfehlung + Konsequenz |
|---|---|---|---|
| K1 | **K&V Table-3 Split-Slope** | Steigungen getrennt für Gruppen (High/Low-Emitter) im selben Modell | rein; wie Subsample behandeln: `subsample_dimension = other: slope-group` + Wert — konsistent mit F34e-Geist |
| K2 | **Luo PSM/ATT-Zeilen** | Treatment-Effekt-Schätzer (ATT) statt Regressionskoeffizient | rein mit `estimation_method = other: PSM-ATT`; Pooling-Frage ggf. als Sensitivität bei DEC-031 — nicht auf Extraktionsebene lösen |
| K3 | **Bhattacharya Wald-χ² vs. b** | Tabellen berichten Wald-χ² statt t/z; Konflikt mit b-Vorzeichen | deterministische Regel: bei df=1 gilt z = √χ², Vorzeichen aus b — kein Urteil, reine Mechanik; Konfliktzellen (b fehlt/widersprüchlich) → FLAG bleibt |
| K4 | **Piechocka standardized-only** | nur standardisierte β ohne SE/t/p | PCC braucht t oder N-basierte Ableitung: Zeilen ohne jede Teststatistik sind **nicht konvertierbar** → exit mit Doku (Kriterium 1); Zeilen mit t/p normal. Kein F41e-Fall (Stars ≠ std-β) |

**Materialitäts-Übersicht für die Sitzung:** R3 (36 Zeilen) > R1 (Vorzeichen ×3 + Erratum) > R5/R6 (Präzedenzen) > R2/R7 (klein) > R4 (Moderator-Qualität) > R8 (Prosa). Empfohlene Reihenfolge im Gespräch: R6 → R1 → R3 → R4 → R2 → R7 → R5 → R8 (schnelle Bestätigungen zuerst, dann die zwei Diskussionsfälle R3/R4).
