# Conquest List Analyser – agent notes

## Verification
- `flutter test` – full suite. As of commit 2387d18, 4 tests already fail on main (reinforcement_integration_test load, scoring_engine_test "varying defensive profiles", supremacy_abilities_test "mixed army", toughness_score_test "extreme defense values").
- `flutter analyze` – the existing codebase has many info/warning lints in tests; check only for new `error`s.

## Data
- Faction data lives in `assets/data/<faction>.json`; canonical rule wording is in `assets/data/special_rules.json`.
- Numeric keys read by code: `cleave`, `barrage`, `barrageRange`, `armorPiercingValue` (not `armorPiercing`), `impact`, `spellDice`, `regeneration`, `scoringStands`.
- New faction files must be added to `_availableFactions` in `lib/services/unit_database.dart` (use the exact file-name casing).
- A unit may list alternative names in an optional `aliases` array (e.g. Weaver Courts "Wyrd Cavalry" -> "Wyrd Knights"); `findUnit` falls back to these.
- Weaver Courts (`WeaverCourts.json`): Gallowglass Wardens' Barrage comes from their Pick the Quarry draw event; numeric keys use the Barrage (5) (16") option.
- Yoroni modular stands use `isModularStand`, `commandModifiers` (applied when the stand leads) and `regimentModifiers` (applied when the stand type is present). List lines use `* Modular Regiment (n) [pts]: Leader (L), Leader (k), Other`.
