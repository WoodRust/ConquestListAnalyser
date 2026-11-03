# Conquest List Analyser – agent notes

## Verification
- `flutter test` – full suite. As of commit 2387d18, 4 tests already fail on main (reinforcement_integration_test load, scoring_engine_test "varying defensive profiles", supremacy_abilities_test "mixed army", toughness_score_test "extreme defense values").
- `flutter analyze` – the existing codebase has many info/warning lints in tests; check only for new `error`s.

## Data
- Faction data lives in `assets/data/<faction>.json`; canonical rule wording is in `assets/data/special_rules.json`.
- Numeric keys read by code: `cleave`, `barrage`, `barrageRange`, `armorPiercingValue` (not `armorPiercing`), `impact`, `spellDice`, `regeneration`, `scoringStands`.
- Yoroni modular stands use `isModularStand`, `commandModifiers` (applied when the stand leads) and `regimentModifiers` (applied when the stand type is present). List lines use `* Modular Regiment (n) [pts]: Leader (L), Leader (k), Other`.
