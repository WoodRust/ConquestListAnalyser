import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/ui/widgets/score_display_widget.dart';
import 'package:conquest_analyzer/models/list_score.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ScoreDisplayWidget Regiment Class Count Tests', () {
    late Unit lightUnit;
    late Unit mediumUnit;
    late Unit heavyUnit;
    late Unit characterUnit;

    setUp(() {
      lightUnit = Unit(
        name: 'Light Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 120,
      );

      mediumUnit = Unit(
        name: 'Medium Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 160,
      );

      heavyUnit = Unit(
        name: 'Heavy Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 200,
      );

      characterUnit = Unit(
        name: 'Test Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 1,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 150,
      );
    });

    Widget createTestWidget(ListScore score) {
      return MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(score: score),
        ),
      );
    }

    testWidgets('should display regiment class counts in info section',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: lightUnit, stands: 2, pointsCost: 160), // Light
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120), // Light
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 160), // Medium
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200), // Heavy
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Character (excluded)
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Test Faction',
        totalPoints: 790,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 23, // 2*4 + 1*4 + 1*5 + 1*6 = 23
        pointsPerWound: 34.35,
        expectedHitVolume: 25.5,
        cleaveRating: 12.3,
        rangedExpectedHits: 5.2,
        rangedArmorPiercingRating: 3.1,
        maxRange: 24,
        averageSpeed: 5.0,
        toughness: 2.1, // Added toughness parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify the regiment class counts are displayed
      expect(find.text('Light: 2'), findsOneWidget);
      expect(find.text('Medium: 1'), findsOneWidget);
      expect(find.text('Heavy: 1'), findsOneWidget);
    });

    testWidgets('should display zero counts correctly',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(
            unit: characterUnit, stands: 1, pointsCost: 150), // Only character
      ];

      final armyList = ArmyList(
        name: 'Character Only Army',
        faction: 'Test Faction',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 0, // Characters excluded
        pointsPerWound: 0.0,
        expectedHitVolume: 5.0,
        cleaveRating: 1.0,
        rangedExpectedHits: 0.5,
        rangedArmorPiercingRating: 0.0,
        maxRange: 0,
        averageSpeed: 0.0,
        toughness: 0.0, // Added toughness parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // All counts should be zero
      expect(find.text('Light: 0'), findsOneWidget);
      expect(find.text('Medium: 0'), findsOneWidget);
      expect(find.text('Heavy: 0'), findsOneWidget);
    });

    testWidgets('should display high counts correctly',
        (WidgetTester tester) async {
      final regiments = <Regiment>[];
      // Add many regiments of each type
      for (int i = 0; i < 15; i++) {
        regiments.add(Regiment(unit: lightUnit, stands: 1, pointsCost: 120));
      }
      for (int i = 0; i < 8; i++) {
        regiments.add(Regiment(unit: mediumUnit, stands: 1, pointsCost: 160));
      }
      for (int i = 0; i < 3; i++) {
        regiments.add(Regiment(unit: heavyUnit, stands: 1, pointsCost: 200));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test Faction',
        totalPoints: 4080, // 15*120 + 8*160 + 3*200
        pointsLimit: 5000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 118, // 15*4 + 8*5 + 3*6 = 60 + 40 + 18 = 118
        pointsPerWound: 34.58,
        expectedHitVolume: 156.0,
        cleaveRating: 45.0,
        rangedExpectedHits: 12.5,
        rangedArmorPiercingRating: 8.2,
        maxRange: 18,
        averageSpeed: 5.0,
        toughness: 1.6, // Added toughness parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify high counts are displayed correctly
      expect(find.text('Light: 15'), findsOneWidget);
      expect(find.text('Medium: 8'), findsOneWidget);
      expect(find.text('Heavy: 3'), findsOneWidget);
    });

    testWidgets('should display army info section with proper layout',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120),
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 160),
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Balanced Army',
        faction: 'Test Faction',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 15, // 4 + 5 + 6
        pointsPerWound: 32.0,
        expectedHitVolume: 18.5,
        cleaveRating: 8.5,
        rangedExpectedHits: 3.2,
        rangedArmorPiercingRating: 1.5,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness: 2.0, // Added toughness parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify the layout and all information is present
      expect(find.text('Balanced Army'), findsOneWidget);
      expect(find.text('Faction: Test Faction'), findsOneWidget);
      expect(find.text('Points: 480/2000'), findsOneWidget);
      expect(find.text('Regiments: 3'), findsOneWidget);
      expect(find.text('Characters: 0'), findsOneWidget);
      expect(find.text('Activations: 3'), findsOneWidget);

      // Verify regiment class counts are in the same section
      expect(find.text('Light: 1'), findsOneWidget);
      expect(find.text('Medium: 1'), findsOneWidget);
      expect(find.text('Heavy: 1'), findsOneWidget);

      // Verify the counts are in a Row layout (all should be found)
      final lightWidget = tester.widget<Text>(find.text('Light: 1'));
      final mediumWidget = tester.widget<Text>(find.text('Medium: 1'));
      final heavyWidget = tester.widget<Text>(find.text('Heavy: 1'));
      expect(lightWidget, isNotNull);
      expect(mediumWidget, isNotNull);
      expect(heavyWidget, isNotNull);
    });

    testWidgets('should display regiment class counts with mixed compositions',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120), // Light
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120), // Light
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120), // Light
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200), // Heavy
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Character (excluded)
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Character (excluded)
      ];

      final armyList = ArmyList(
        name: 'Light Heavy Army',
        faction: 'Test Faction',
        totalPoints: 960,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 18, // 3*4 + 1*6 = 18
        pointsPerWound: 53.33,
        expectedHitVolume: 22.0,
        cleaveRating: 8.0,
        rangedExpectedHits: 2.5,
        rangedArmorPiercingRating: 1.0,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness: 1.3, // Added toughness parameter (mostly light units)
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Should show 3 light, 0 medium, 1 heavy
      expect(find.text('Light: 3'), findsOneWidget);
      expect(find.text('Medium: 0'), findsOneWidget);
      expect(find.text('Heavy: 1'), findsOneWidget);

      // Should also show correct character and regiment counts
      expect(find.text('Regiments: 6'), findsOneWidget);
      expect(find.text('Characters: 2'), findsOneWidget);
      expect(find.text('Activations: 6'), findsOneWidget);
    });

    testWidgets('should handle scrolling with long army lists',
        (WidgetTester tester) async {
      // Create a large army that might require scrolling
      final regiments = <Regiment>[];
      for (int i = 0; i < 50; i++) {
        regiments.add(Regiment(unit: lightUnit, stands: 1, pointsCost: 120));
      }

      final armyList = ArmyList(
        name: 'Massive Army',
        faction: 'Test Faction',
        totalPoints: 6000,
        pointsLimit: 10000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 200, // 50*4
        pointsPerWound: 30.0,
        expectedHitVolume: 300.0,
        cleaveRating: 120.0,
        rangedExpectedHits: 25.0,
        rangedArmorPiercingRating: 15.0,
        maxRange: 24,
        averageSpeed: 6.0,
        toughness: 1.0, // Added toughness parameter (all light units)
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Should be able to find the regiment counts even in a scrollable view
      expect(find.text('Light: 50'), findsOneWidget);
      expect(find.text('Medium: 0'), findsOneWidget);
      expect(find.text('Heavy: 0'), findsOneWidget);

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display toughness tooltip when info icon is tapped',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200),
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Tooltip Test Army',
        faction: 'Test Faction',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 16, // 2*5 + 1*6 = 16
        pointsPerWound: 25.0,
        expectedHitVolume: 20.0,
        cleaveRating: 10.0,
        rangedExpectedHits: 5.0,
        rangedArmorPiercingRating: 2.0,
        maxRange: 12,
        averageSpeed: 4.5,
        toughness: 2.6, // Specific value for tooltip test
        calculatedAt: DateTime.now(),
      );

      // Use a larger test surface to ensure the widget is visible
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget(score));

      // Verify toughness score card is displayed with info icon
      expect(find.text('Toughness'), findsOneWidget);
      expect(find.text('2.6'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Scroll down to ensure the toughness card is visible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify no dialog is shown initially
      expect(find.byType(AlertDialog), findsNothing);

      // Tap the info icon to show tooltip
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Verify tooltip dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.text('Toughness'),
          findsAtLeast(
              1)); // Will find both the score card title and dialog title
      expect(find.text('On average, each wound in your army has 2.6 defense.'),
          findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to close tooltip
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify tooltip is closed
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('On average, each wound in your army has 2.6 defense.'),
          findsNothing);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display toughness score card',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200),
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Toughness Display Test',
        faction: 'Test Faction',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 16, // 2*5 + 1*6 = 16
        pointsPerWound: 25.0,
        expectedHitVolume: 20.0,
        cleaveRating: 10.0,
        rangedExpectedHits: 5.0,
        rangedArmorPiercingRating: 2.0,
        maxRange: 12,
        averageSpeed: 4.5,
        toughness: 2.3, // Medium-high toughness
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify toughness score card is displayed
      expect(find.text('Toughness'), findsOneWidget);
      expect(find.text('2.3'), findsOneWidget);

      // Verify the security icon is used for toughness
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('should display all score cards including toughness',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120),
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 160),
        Regiment(unit: heavyUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Complete Score Test',
        faction: 'Test Faction',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 15, // 4 + 5 + 6
        pointsPerWound: 32.0,
        expectedHitVolume: 18.5,
        cleaveRating: 8.5,
        rangedExpectedHits: 3.2,
        rangedArmorPiercingRating: 1.5,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness:
            2.1, // Changed to avoid collision with defense values in table
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify all score cards are present
      expect(find.text('Total Wounds'), findsOneWidget);
      expect(find.text('Points per Wound'), findsOneWidget);
      expect(find.text('Expected Hit Volume'), findsOneWidget);
      expect(find.text('Cleave Rating'), findsOneWidget);
      expect(find.text('Ranged Expected Hits'), findsOneWidget);
      expect(find.text('Ranged Armor Piercing'), findsOneWidget);
      expect(find.text('Max Range'), findsOneWidget);
      expect(find.text('Average Speed'), findsOneWidget);
      expect(find.text('Toughness'), findsOneWidget);

      // Verify corresponding values (avoiding conflicts with defense values in breakdown table)
      expect(find.text('15'), findsOneWidget);
      expect(find.text('32.00'), findsOneWidget);
      expect(find.text('18.5'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
      expect(find.text('3.2'), findsOneWidget);
      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('2.1'),
          findsOneWidget); // Changed from 2.0 to avoid collision
    });
  });
}
