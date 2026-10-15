# Calendar contract

Ruleset: `bd-revised-2019-v1`.

1. Boishakh 1 is Gregorian April 14, at a civil midnight boundary.
2. Boishakh through Ashwin (months 1–6) have 31 days.
3. Kartik through Magh (months 7–10) and Choitro (12) have 30 days.
4. Falgun (11) has 29 days, or 30 when the Gregorian year **containing that
   Falgun** is leap. This is Bangla year + 594, not +593.
5. A Bangla year starts in Gregorian year +593. Leap calculations use Gregorian
   divisible-by-4, century and divisible-by-400 rules.
6. Seasons group consecutive pairs of months. They are calendar labels, not
   forecasts or astronomical boundaries.

## Scope and historical interpretation

Supported Bangla years: 1 through 9405 inclusive. Corresponding Gregorian dates:
0594-04-14 through 9999-04-13. Before Bangla 1426 / Gregorian 2019, the revised
rules are deliberately extended **proleptically**. This is not a reconstruction
of historical adoption, pre-reform dates, the 2019 transition, or traditional
astronomical calendars. Consumers must not label those earlier results as
historically observed dates.

This package does not claim authority over government holiday announcements.
No official holiday or religious-event dataset is bundled.

## Date versus instant

`fromGregorian(date)` reads only year, month and day. A local or UTC marker does
not change those fields. It never subtracts six hours. `toGregorian()` returns
the Gregorian date encoded as UTC midnight for deterministic arithmetic, not a
claim that a local midnight occurred at that UTC instant.

`fromInstant(instant, utcOffset: ...)` first converts the instant to UTC, applies
the explicit fixed offset, then extracts date components. Use +06:00 for current
Bangladesh civil time. For DST/IANA zones, resolve the correct offset externally
for each instant; a fixed offset is not an IANA timezone database.

`today()` uses the clock's civil fields. Supply `utcOffset` and a clock when
location independence or reproducible tests matter. Widgets accept an explicit
`today`; applications rebuild them when the civil day changes or the app resumes.

## Reference anchors and research trail

- Bangladesh Government Press gazette dated 19 February 2024 identifies that
  date as 6 Falgun 1430:
  https://www.dpp.gov.bd/bgpress/bangla/index.php/home/download_file/gazettes/52457_67807.pdf
- Bangla Academy calendar publication landing page:
  https://banglaacademy.gov.bd/pages/static-pages/6922dcfb933eb65569e13097

The government gazette date was available in indexed text during preparation;
the complete gazette and Academy calendar could not be fetched in this environment.
The exhaustive round-trip tests establish internal consistency, not independent
official certification. Verify any newly introduced convention against its own
published references before adding it.

Examples under this contract: 2025-04-14 → 1432-01-01;
2024-02-21 → 1430-11-08; 2024-03-14 → 1430-11-30;
2025-03-14 → 1431-11-29; 2025-12-16 → 1432-09-01.
