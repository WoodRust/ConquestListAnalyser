import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/ui/widgets/score_display_widget.dart';
import 'package:conquest_analyzer/models/list_score.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ScoreDisplayWidget Evasion UI Tests', () {
    late Unit testUnit;

    setUp(() {
      testUnit = Unit(
        name: 'Test Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 3,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );
    });

    Widget createTestWidget(ListScore score) {
      return MaterialApp(
        home: Scaffold(
          body: ScoreDisplayWidget(score: score),
        ),
      );
    }

    testWidgets('should display evasion score card with correct value',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 2, pointsCost: 200),
      ];
      final armyList = ArmyList(
        name: 'Evasion Test Army',
        faction: 'Test Faction',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 10,
        pointsPerWound: 20.0,
        expectedHitVolume: 15.0,
        cleaveRating: 5.0,
        rangedExpectedHits: 2.5, // Changed to avoid conflict
        rangedArmorPiercingRating: 1.5,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness: 2.0,
        evasion: 3.1, // Changed to unique value for testing
        effectiveWoundsDefense: 12.0, // Added required parameter
        effectiveWoundsDefenseResolve: 14.0, // Added required parameter
        resolveImpactPercentage: 15.0, // Added required parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify evasion score card is displayed
      expect(find.text('Evasion'), findsOneWidget);
      expect(find.text('3.1'), findsOneWidget); // Updated to match unique value
      expect(find.byIcon(Icons.flash_on), findsOneWidget);

      // Verify evasion score card is specifically found by looking for its container
      final evasionCard = find.ancestor(
        of: find.text('Evasion'),
        matching: find.byType(Container),
      );
      expect(evasionCard, findsOneWidget);

      // Verify the evasion value appears within the evasion card
      final evasionValueInCard = find.descendant(
        of: evasionCard.first,
        matching: find.text('3.1'),
      );
      expect(evasionValueInCard, findsOneWidget);
    });

    testWidgets('should display evasion info icon and handle tap',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 1, pointsCost: 160),
      ];
      final armyList = ArmyList(
        name: 'Evasion Info Test',
        faction: 'Test Faction',
        totalPoints: 160,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 5,
        pointsPerWound: 32.0,
        expectedHitVolume: 10.0,
        cleaveRating: 3.1, // Changed from 3.0 to unique value
        rangedExpectedHits: 2.0,
        rangedArmorPiercingRating: 1.0,
        maxRange: 8,
        averageSpeed: 5.0,
        toughness: 2.3, // Changed from 2.0 to unique value
        evasion: 3.7, // Changed from 3.0 to unique value
        effectiveWoundsDefense: 8.0, // Added required parameter
        effectiveWoundsDefenseResolve: 10.0, // Added required parameter
        resolveImpactPercentage: 20.0, // Added required parameter
        calculatedAt: DateTime.now(),
      );

      // Use a larger test surface to ensure the widget is visible
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget(score));

      // Scroll down to ensure the evasion card is visible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Verify evasion card is displayed with info icon
      expect(find.text('Evasion'), findsOneWidget);
      expect(find.text('3.7'), findsOneWidget); // Updated to unique value
      expect(find.byIcon(Icons.info_outline),
          findsAtLeast(1)); // Both toughness and evasion have info icons

      // Verify no dialog is shown initially
      expect(find.byType(AlertDialog), findsNothing);

      // Find the evasion card specifically
      final evasionCard = find.ancestor(
        of: find.text('Evasion'),
        matching: find.byType(Container),
      );

      // Find info icon within the evasion card area
      final infoIconInEvasionCard = find.descendant(
        of: evasionCard,
        matching: find.byIcon(Icons.info_outline),
      );

      expect(infoIconInEvasionCard, findsOneWidget);

      // Tap the info icon that's specifically in the evasion card
      await tester.tap(infoIconInEvasionCard);
      await tester.pumpAndSettle();

      // Verify evasion tooltip dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Evasion'), findsAtLeast(1)); // Title and card
      expect(find.text('On average, each wound in your army has 3.7 evasion.'),
          findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to close tooltip
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify tooltip is closed
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('On average, each wound in your army has 3.7 evasion.'),
          findsNothing);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display correct evasion value in multiple contexts',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 3, pointsCost: 300),
      ];
      final armyList = ArmyList(
        name: 'Multiple Context Test',
        faction: 'Test Faction',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 15,
        pointsPerWound: 20.0,
        expectedHitVolume: 25.0,
        cleaveRating: 8.0,
        rangedExpectedHits: 5.0,
        rangedArmorPiercingRating: 2.0,
        maxRange: 16,
        averageSpeed: 5.0,
        toughness: 2.2, // Changed from 2.0 to unique value
        evasion: 3.4, // Changed from 3.0 to unique value
        effectiveWoundsDefense: 18.0, // Added required parameter
        effectiveWoundsDefenseResolve: 22.0, // Added required parameter
        resolveImpactPercentage: 25.0, // Added required parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify the unique values are displayed correctly
      expect(find.text('2.2'), findsOneWidget); // Unique toughness value
      expect(find.text('3.4'), findsOneWidget); // Unique evasion value
    });

    testWidgets('should handle scrolling with evasion card included',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 5, pointsCost: 500),
      ];
      final armyList = ArmyList(
        name: 'Scrolling Test Army',
        faction: 'Test Faction',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 25,
        pointsPerWound: 20.0,
        expectedHitVolume: 48.5, // Changed to unique value
        cleaveRating: 14.7, // Changed to unique value
        rangedExpectedHits: 7.8, // Changed to unique value
        rangedArmorPiercingRating: 3.9, // Changed to unique value
        maxRange: 18,
        averageSpeed: 5.2, // Changed to unique value
        toughness: 2.7, // Changed to unique value
        evasion: 3.9, // Changed to unique value
        effectiveWoundsDefense: 30.0, // Added required parameter
        effectiveWoundsDefenseResolve: 35.0, // Added required parameter
        resolveImpactPercentage: 40.0, // Added required parameter
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify evasion card is findable (might need scrolling)
      expect(find.text('Evasion'), findsOneWidget);

      // Verify there are multiple info icons now (including the new effective wounds icons)
      expect(find.byIcon(Icons.info_outline), findsAtLeast(2));

      // Test scrolling to bottom to ensure evasion card is accessible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be able to find evasion after scrolling
      expect(find.text('Evasion'), findsOneWidget);
    });
  });
}
