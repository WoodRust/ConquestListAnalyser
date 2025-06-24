import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Unit Model Tests', () {
    late Map<String, dynamic> testUnitJson;
    late Unit testUnit;

    setUp(() {
      testUnitJson = {
        'name': 'Raiders',
        'faction': 'Nords',
        'type': 'infantry',
        'regimentClass': 'light',
        'characteristics': {
          'march': 6,
          'volley': 1,
          'clash': 2,
          'attacks': 4,
          'wounds': 4,
          'resolve': 2,
          'defense': 1,
          'evasion': 1
        },
        'specialRules': [
          {
            'name': 'Flurry',
            'description':
                'This Stand may re-roll failed Hit rolls when performing a Clash Action.'
          }
        ],
        'numericSpecialRules': {'impact': 2, 'tenacious': 1},
        'supremacyAbilities': [], // Add empty array for tests
        'drawEvents': [],
        'points': 120,
        'pointsPerAdditionalStand': 40
      };
      testUnit = Unit.fromJson(testUnitJson);
    });

    test('should create Unit from JSON correctly', () {
      expect(testUnit.name, equals('Raiders'));
      expect(testUnit.faction, equals('Nords'));
      expect(testUnit.woundsPerStand, equals(4));
      expect(testUnit.points, equals(120));
      expect(testUnit.supremacyAbilities, isEmpty); // Test new field
    });

    test('should calculate points cost correctly', () {
      expect(testUnit.calculatePointsCost(1), equals(120));
      expect(testUnit.calculatePointsCost(3), equals(200)); // 120 + (2 * 40)
      expect(testUnit.calculatePointsCost(5), equals(280)); // 120 + (4 * 40)
    });

    test('should handle single stand units without additional cost', () {
      final singleStandJson = Map<String, dynamic>.from(testUnitJson);
      singleStandJson.remove('pointsPerAdditionalStand');
      final singleStandUnit = Unit.fromJson(singleStandJson);

      expect(singleStandUnit.calculatePointsCost(1), equals(120));
      expect(singleStandUnit.calculatePointsCost(3), equals(120));
    });

    test('should handle JSON without supremacyAbilities field', () {
      final jsonWithoutSupremacy = Map<String, dynamic>.from(testUnitJson);
      jsonWithoutSupremacy.remove('supremacyAbilities');

      final unitWithoutSupremacy = Unit.fromJson(jsonWithoutSupremacy);
      expect(unitWithoutSupremacy.supremacyAbilities, isEmpty);
    });
  });
}
