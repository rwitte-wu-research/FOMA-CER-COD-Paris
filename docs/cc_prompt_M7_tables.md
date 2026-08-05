# Run Protocol — M7 Appendix Tables Build (Tables A.2–A.4) — R, author-run

**Status:** v2. Supersedes the withdrawn Python version (ERROR #49). Direct
`Rscript.exe` invocation is blocked by the organization's Device Guard policy
as of 2026-08-05 (M7 DEC environment note); the canonical run path is the
author-run via RStudio `source()`.

**Context:** M7 pre-submission session, governed by the M7 DEC. The script
builds the Online-Appendix Tables A.2–A.4 as Markdown fragments from committed
run CSVs (build-artifact rule, DEC-054). Deterministic, base-R-only,
self-checking: hard pins guard published TB values; on any violation it stops
with diagnostics.

## Steps

1. Open the project in RStudio (File > Open Project >
   `C:\R_Projects\FOMA-CER-COD-Paris\*.Rproj`), or set the working directory
   manually:

   ```r
   setwd("C:/R_Projects/FOMA-CER-COD-Paris")
   ```

2. Verify: `getwd()` must return `"C:/R_Projects/FOMA-CER-COD-Paris"`.

3. Run:

   ```r
   source("scripts/build_appendix_tables.R")
   ```

4. Expected on success: three Markdown table blocks (A.2 · A.3 with 114 rows ·
   A.4) in the console and the closing line
   `[build_appendix_tables] ALL PINS PASS -- written to output/appendix_tables_A2_A4.md`.

5. **Deliver back to the session:** the file `output\appendix_tables_A2_A4.md`
   (upload, or copy its content from an editor). The file is canonical UTF-8.
   On failure (`STOP [...]` or `PIN FAIL`), paste the complete console output
   verbatim and stop; the session patches the script.

## Guard rails

- Read-only with respect to the repo except for `output\appendix_tables_A2_A4.md`.
- No `git add`, no `git commit`, no pushes, no other file edits.
- Do not re-run analyses or touch any other R script.
