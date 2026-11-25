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
