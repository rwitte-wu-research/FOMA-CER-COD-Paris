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
