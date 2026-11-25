# Development log — 2026-11-25
Baseline: Actions run 60 (45556043239), successful.
Batch 1:
- cd8f082: shared number parser in smart tools and inventory lots.
- 187cfe8: persist language, dark mode and favorites with SharedPreferences; compact-height navigation.
- 2487289: bilingual numeric parsing tests.
- 387ccde: settings restoration test and mock preferences.
CI for this batch must be verified before declaring stable.
Remaining: financial statements including IFRS 18 presentation, costs, finance and tax tools; review recognition assumptions and monetary rounding; SQLite project/history persistence; structured reports PDF/XLSX/CSV; small-screen and export tests; release version, icon, privacy and AAB. No Play publication authorized.

Batch 1 verified: runs 61–65 completed successfully; stable run 65 (45571486234).
Batch 2:
- dad6fe1: professional tools: simplified IFRS 18 subtotals, accounting equation, break-even, IAS 2 NRV, inclusive VAT, WACC.
- da26a39: integrate eleventh section, retain existing ten sections and settings.
- Added six numerical regression tests in test/professional_tools_test.dart.
- IFRS 18 model is illustrative for non-financial entities without discontinued operations, not full compliance. Remaining: full statements, journal review, SQLite, structured export, release preparation and device testing. CI pending for batch 2.

Batch 2 verified: runs 66–69 successful; stable run 69 (45579577230).
Batch 3:
- ddc8d3c: sqflite dependency and version 0.2.0+2.
- ee31836: SQLite named project store.
- 9b08ef6: feasibility project save/open, including forecast assumptions; same name updates existing project.
- 4e2f2ae: CI release AAB artifact, no publication or production signing.
- 0bd35de: privacy draft, requires manifest and Data Safety review.
Pending: CI verification, SQLite integration/device tests, history migration, structured exports, full IFRS journal audit, additional statements, icon and production signing.

Batch 3 verified: run 74 (45588829558) analyze, tests, release APK and AAB build/upload succeeded. Device SQLite behavior not verified.
Batch 4: 98474bc clarifies IFRS 15 performance obligations and IFRS 16 elected rent recognition exemptions in bilingual notes and journal examples. CI pending for this change. Remaining: full journal audit, history, exports, additional statements, device tests, icon and production signing.

Batch 5: run 75 (45588841322) successful; runs 76/77 in progress at start. f9cb33f adds simplified IAS 7 cash reconciliation with signed flows and separate FX effect, and contribution margin/ratio and simplified operating result. 25878dc adds numerical regression tests. CI pending; no device tests or publication. Remaining: complete statements and journal review, SQLite history, structured exports, small-screen/export tests, icon and production signing.

Batch 4/5 verified: runs 76–80 successful; stable run 80 (45622463458).
Batch 6: 525c616 adds SQLite schema v2 with additive calculation_history table and v1 upgrade preserving projects; d46b7bc connects professional tools to explicit save, view and delete history. CI and device migration tests pending. History currently covers professional tools only. Remaining: structured export, migration tests, complete journal review, small-screen tests, icon and production signing. No Play publication.

Batch 6 verified: runs 81–83 successful; stable run 83 (45671766773). Device migration still untested.
Batch 7: 5671a89 adds structured history export (UTF-8 BOM CSV, XLSX numeric values, Arabic-font PDF); 53cec3f exposes export buttons in history; 9f35aec adds row, CSV and XLSX regression tests. CI pending; PDF rendering and device sharing untested. Remaining: SQLite migration tests, broader history coverage, journal review, small-screen tests, icon, privacy review and production signing. No Play publication.

Batch 8: e62c909 adds 320x480 widget regression; ab7f7d0 exposes isolated SQLite opening; bcf569b adds FFI test backend; bafaa4b adds v1-to-v2 persistence regression; 5040d18 expands conditional IAS 16, IFRS 15 and IAS 2 journal examples. Runs 84–87 were in progress at start; new tests not yet verified. Remaining: full scientific audit, broader history, PDF rendering/device sharing, icon, privacy manifest review and production signing. No publication.
