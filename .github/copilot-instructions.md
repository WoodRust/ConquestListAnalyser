# Conquest List Analyser - AI Coding Agent Guide

## Project Overview
Flutter desktop/mobile app for analyzing army lists from the "Conquest: The Last Argument of Kings" tabletop wargame. Parses flat text army lists, calculates tactical scores (offense, defense, mobility), and provides shareable analysis.

## Architecture

### Core Data Flow
1. **Input** → User pastes flat text list (from game's list builder)
2. **Parse** → `ListParser` converts text to structured `ArmyList` with `Regiment`s
3. **Enrich** → `UnitDatabase` loads unit stats from JSON faction files
4. **Score** → `ScoringEngine` calculates combat metrics using army-wide effects
5. **Display** → `ScoreDisplayWidget` shows results

### Key Components
- **Models** (`lib/models/`): Data classes - `ArmyList`, `Regiment`, `Unit`, `ListScore`
- **Services** (`lib/services/`): Business logic - parsing, scoring, data loading
- **UI** (`lib/ui/`): Flutter widgets for input and score display
- **Data** (`assets/data/`): JSON files per faction (e.g., `nords.json`) + `special_rules.json`

### Critical Concept: Army-Wide Effects
The `ArmyEffectManager` handles **supremacy abilities** - warlord characters that grant army-wide stat buffs (e.g., "+1 Evasion to all Infantry"). These modify scoring calculations dynamically.

**Example**: Vargyr Lord's "Feral Hunters" ability grants Flurry (re-roll failed hits) to all Brutes in the army.

## Data Model Patterns

### Unit vs Regiment
- `Unit`: Base template (stats, special rules) loaded from JSON
- `Regiment`: Specific instance in an army (unit type + stand count + points + upgrades)

### Special Rules
- **Boolean rules**: Stored in `unit.specialRules` list (e.g., "Flurry", "Shield")
- **Numeric rules**: Stored in `unit.numericSpecialRules` map (e.g., `{"cleave": 2, "impact": 3}`)
- Rules defined in `special_rules.json` (reference only - not parsed at runtime)

### Character Types
- **Regular characters**: `regimentClass: "character"`, `type: "infantry"` - excluded from total wounds/speed
- **Character monsters**: `regimentClass: "character"`, `type: "monster"` - **INCLUDED** in all calculations (see tests)

## Testing Strategy

### Test Organization
- **Unit tests**: Mock dependencies (e.g., `MockUnitDatabase` in `list_parser_test.dart`)
- **Integration tests**: Full scoring pipeline with real units (e.g., `scoring_engine_test.dart`)
- **Edge case tests**: Character monsters, supremacy abilities, special rule interactions

### Critical Test Patterns
```dart
// Always mock UnitDatabase in parser tests
mockDatabase = MockUnitDatabase();
parser = ListParser(database: mockDatabase);

// Test character monster inclusion explicitly
test('should include character monster in X calculation', () {...});
```

### Running Tests
```bash
flutter test                    # All tests
flutter test test/scoring_engine_test.dart  # Specific file
```

## Development Workflows

### Adding a New Faction
1. Create `assets/data/NewFaction.json` (follow `nords.json` structure)
2. Add faction name to `UnitDatabase._availableFactions` list
3. Test with sample list from the game

### Adding New Scoring Metrics
1. Add field to `ListScore` model
2. Implement calculation in `ScoringEngine._calculateNewMetric()`
3. Call in `calculateScores()` and pass to constructor
4. Update `toShareableText()` for display
5. Write integration test with known expected values

### Parsing New List Formats
- List format: Header (game name, list name/points, faction) → Character lines (`== Name [pts]: upgrades`) → Regiment lines (`* Name (stands) [pts]: upgrades`)
- Extend `ListParser._parseRegimentLine()` or `_parseCharacterLine()` for new patterns

## Common Patterns

### Calculating Expected Hits
```dart
// Base: attacks * ((clash + 1) / 6)
// Add special rules: +1 attack for Leader, re-rolls for Flurry
// See Regiment.calculateExpectedHitVolume() for full logic
```

### Handling Army Effects
```dart
// Always get effects first in scoring calculations
final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
// Then pass to regiment-level calculations
final effectiveDefense = regiment.getEffectiveDefense(armyEffects);
```

### Effective Wounds Formula
```dart
// effectiveWounds = totalWounds / (1 - defenseStat/6)
// Handles survivability better than raw wounds
// See _calculateEffectiveWoundsDefense() for implementation
```

## Known Quirks

- **Officer upgrades**: Parsed but not yet applied to stats (e.g., "Captain" text stored in `regiment.upgrades`)
- **Null march values**: Some units have no march stat - handle with `march ?? 0`
- **Barrage range**: Stored separately as `barrageRange` in `numericSpecialRules`
- **Case sensitivity**: Faction names in JSON use mixed case (e.g., "SorcererKings", "nords") - match exactly

## Key Files Reference

- [lib/services/scoring_engine.dart](lib/services/scoring_engine.dart) - Main calculation logic
- [lib/services/list_parser.dart](lib/services/list_parser.dart) - Text parsing rules
- [lib/services/army_effect_manager.dart](lib/services/army_effect_manager.dart) - Supremacy ability system
- [lib/models/regiment.dart](lib/models/regiment.dart) - Expected hit volume calculations
- [test/scoring_engine_test.dart](test/scoring_engine_test.dart) - Integration test examples
- [assets/data/nords.json](assets/data/nords.json) - Example faction data structure

## Dependencies
- `shared_preferences: ^2.2.2` - Persistent storage (currently unused)
- `flutter_test` - Testing framework
- `flutter_lints: ^3.0.0` - Linting rules

Target SDK: `>=3.0.0 <4.0.0`, Flutter: `>=3.10.0`
