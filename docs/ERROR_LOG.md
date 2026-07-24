# ERROR_LOG — FOMA CER–COD–Paris

Append-only process-error register (author ruling 2026-07-18, T5 session; file
created in the T5 post-run commit). Entries are numbered and never edited or
deleted; future closures are recorded as follow-up entries referencing the
number. Referenced from DECISION_LOG entries as "project error log #n".
Entry texts are kept verbatim as ruled (original language preserved).

#1 2026-07-15 [Claude/T8] fit3l(NULL) — metafor 5.0.1 lehnt NULL-mods ab (DEC-031e)
#2 2026-07-15 [Claude/T8] Parametrisierungs-Fragilität mB nicht antizipiert trotz T2-Cell-Means-Evidenz (DEC-031e)
#3 2026-07-15 [Autor/T8] fit3l(NULL) in zwei Review-Zyklen (v2, v3) unbemerkt (DEC-031e)
#4 2026-07-15 [Claude/T8] staler Output-Kontrakt im cc_prompt_T8 (T8_sessionInfo.txt; Fix @ 62d80d4)
#5 2026-07-15 [Claude/T8] Status-Dateiname CERCOD vs CER-COD → fatal pathspec, Commit-Fehlversuch
#6 2026-07-16 [Claude/T8] Zählfehler Commits ahead (5 statt 4)
#7 2026-07-15/18 [Claude/T8→T5] Key_Results-Z11-No-Op (Existenz-Check statt Wert-Update, unbedingter Erfolgs-Print) — GESCHLOSSEN mit Z11-Befüllung im T5-Status-Touch
#8 2026-07-18 [Claude/T5] Gating-Liste unvollständig — T8-Muster-Referenzen nicht angefordert
#9 2026-07-19 [Claude/T5] Recalc-Pass fälschlich autorseitig instruiert (Pass ist containerseitig via xlsx-Skill-Skript); Nachholung deckte zwei Workbook-Baufehler auf — locale-fragile TEXT-Formatcodes und CONCAT ohne _xlfn-Präfix (#NAME?) — beide behoben (locale-neutrale Formelkonstruktion; CONCATENATE); GESCHLOSSEN im T5-Post-Run-Paket
#10 2026-07-22 [Claude/T5-Faden] Zähl-Anker-Fehler Overlap-Disclosure — Shad/Lemma trotz Doppelkanal-Indiz (COE-Titel "…Cost of Debt and Equity Reduction") verworfen, um den v8-Pin "5 Studien" [Datenagenda #11] zu erhalten; die H-Q10-v1-Formulierung "präzisiert DEC-031b, widerspricht ihr nicht" übersah den Widerspruch zur geloggten DEC-024-Mitgliederliste; von der H-Session gefangen, aufgelöst per F22-Cross-Note ("the same ESPR article") + v10-Korpus-Check (65 Studien: Shad/Lemma enthalten, Ng & Rezaee 2012 und Ould Daoud nicht — Update-Batch-Zugänge) → Overlap supersediert auf 7/120 · 6/115 · 5/113, 60/2.713 est-ES, 0 geteilte ES [DEC-045]; GESCHLOSSEN mit dem DEC-045-Paket-Commit
#11 2026-07-22 [Claude/H-Session] Vorzeichenfehler NCP_33 im H10-Flatness-Test — qnorm(.975)+qnorm(2/3) (≈2,3907 = 67%-Power-ncp) statt MINUS (≈1,5293 = 33%); pp33 clippte systematisch bei 1, der "flacher als 33%"-Test hätte quasi immer gefeuert — anti-konservativ ZUGUNSTEN der Null-These; im Autor-Review (externe T5-Querprüfung) prä-Commit gefangen; Fix + unabhängige Verifier-Nachrechnung (O13: NCP-Rekonstruktion 1e-9, Flatness-Stouffer 1e-10, Clip-Share-Präsenz) im TH-a-Paket; GESCHLOSSEN mit dem DEC-045-Paket-Commit
#12 2026-07-24 [Claude/H-Session] Unvollständige Umsetzung des gerulten H7-Robustheitsfixes in R/06 — tryCatch-Guard deckte nur den fit3l-Aufruf, nicht den nachgelagerten CR2/Satterthwaite-Schritt (coef_test/conf_int); bei Schritt 001 (1 Cluster) konvergierte der Fit (Single-Level-Warnung, sigma2 auf 0 fixiert), vcovCR verweigerte Einzelcluster-Daten → harter Abbruch statt not_estimable-Zeile; im ersten kanonischen TH-a-Lauf von CC gefangen (STOP-Protokoll eingehalten, keine Outputs geschrieben, Baum sauber); Fix = Guard über den gesamten Schrittkörper, Verifier unverändert (O10 deckte den Fall bereits per ne-Exemption); GESCHLOSSEN mit dem Fix-Commit
