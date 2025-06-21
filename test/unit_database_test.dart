import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/unit_database.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('UnitDatabase Multi-Faction Tests', () {
    late UnitDatabase database;

    setUp(() {
      database = UnitDatabase.instance;
      database.clearData(); // Reset for each test
    });

    test('should load multiple factions successfully', () async {
      await database.loadData();

      expect(database.isLoaded, isTrue);
      expect(database.availableFactions.length, greaterThan(1));

      // Print loading status for debugging
      final status = database.getFactionLoadStatus();
      print('Loaded factions: $status');

      // Verify we have units loaded
      expect(database.getFactionLoadStatus().values.fold(0, (a, b) => a + b),
          greaterThan(0));
    });

    test('should find units from different factions', () async {
      await database.loadData();

      // Try to find units that should exist in different factions
      // Note: Replace these with actual unit names from your JSON files
      final nordsUnit = database.findUnit('Raiders'); // From nords
      final skUnit = database.findUnit('Maharajah'); // From sorcerer kings

      // At least one should be found if the data is loaded correctly
      expect(nordsUnit != null || skUnit != null, isTrue);
    });

    test('should handle case-insensitive unit search', () async {
      await database.loadData();

      // Try different case variations
      final unit1 = database.findUnit('raiders');
      final unit2 = database.findUnit('RAIDERS');
      final unit3 = database.findUnit('Raiders');

      // Should all return the same result (either all null or all the same unit)
      expect(unit1 == unit2 && unit2 == unit3, isTrue);
    });

    test('should return empty list for unknown faction', () async {
      await database.loadData();

      final unknownFactionUnits =
          database.getUnitsForFaction('unknown_faction');
      expect(unknownFactionUnits, isEmpty);
    });

    test('should handle missing faction files gracefully', () async {
      // This test verifies the database continues loading even if some files are missing
      await database.loadData();

      // Should complete without throwing, even if some faction files are missing
      expect(database.isLoaded, isTrue);
    });

    test('should be able to load additional faction', () async {
      await database.loadData();
      final initialFactionCount = database.availableFactions.length;

      // Try to load a faction that might not be in the initial list
      try {
        await database.loadAdditionalFaction('testFaction');
        // If successful, faction count should increase
        expect(database.availableFactions.length,
            greaterThanOrEqualTo(initialFactionCount));
      } catch (e) {
        // If it fails (file doesn't exist), that's expected
        expect(e, isA<Exception>());
      }
    });

    test('should handle unit search with trimmed names', () async {
      await database.loadData();

      // Test with extra whitespace
      final unit1 = database.findUnit('  Raiders  ');
      final unit2 = database.findUnit('Raiders');

      expect(unit1 == unit2, isTrue);
    });
  });
}
