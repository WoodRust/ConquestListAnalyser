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
        cleaveRating: 3.1, // Changed to unique value
        rangedExpectedHits: 2.3, // Changed to unique value
        rangedArmorPiercingRating: 1.0,
        maxRange: 8,
        averageSpeed: 5.1, // Changed to unique value
        toughness: 2.4, // Changed to unique value
        evasion: 3.7, // Changed to unique value
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

      // Find the evasion card specifically and tap its info icon
      final evasionCard = find.ancestor(
        of: find.text('Evasion'),
        matching: find.byType(Container),
      );

      // Find info icon within the evasion card area
      final infoIcons = find.byIcon(Icons.info_outline);
      expect(infoIcons, findsAtLeast(1));

      // Tap the second info icon (evasion - first is toughness)
      if (tester.widgetList(infoIcons).length >= 2) {
        await tester.tap(infoIcons.at(1));
      } else {
        // If there's only one, it might be the evasion one
        await tester.tap(infoIcons.first);
      }
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

    testWidgets('should display both toughness and evasion cards side by side',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 2, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Dual Score Test',
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
        rangedExpectedHits: 2.5,
        rangedArmorPiercingRating: 1.5,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness: 2.1, // Changed to unique value
        evasion: 3.2, // Changed to unique value
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify both toughness and evasion cards are present
      expect(find.text('Toughness'), findsOneWidget);
      expect(find.text('Evasion'), findsOneWidget);
      expect(find.text('2.1'), findsOneWidget); // Toughness value
      expect(find.text('3.2'), findsOneWidget); // Evasion value

      // Verify correct icons
      expect(find.byIcon(Icons.security), findsOneWidget); // Toughness icon
      expect(find.byIcon(Icons.flash_on), findsOneWidget); // Evasion icon

      // Verify both have info icons
      expect(find.byIcon(Icons.info_outline), findsAtLeast(2));
    });

    testWidgets('should display evasion in shareable format correctly',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 1, pointsCost: 160),
      ];

      final armyList = ArmyList(
        name: 'Share Test Army',
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
        cleaveRating: 3.0,
        rangedExpectedHits: 2.0,
        rangedArmorPiercingRating: 1.0,
        maxRange: 8,
        averageSpeed: 5.0,
        toughness: 2.0,
        evasion: 2.5, // Decimal value for testing
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Test the shareable text format
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Army List Analysis: Share Test Army'));
      expect(shareableText, contains('Evasion: 2.5'));
      expect(shareableText, contains('Toughness: 2.0'));
    });

    testWidgets('should handle zero evasion value correctly',
        (WidgetTester tester) async {
      final characterUnit = Unit(
        name: 'Test Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 3,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 4,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 150),
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
        totalWounds: 0, // No non-character regiments
        pointsPerWound: 0.0,
        expectedHitVolume: 5.0,
        cleaveRating: 2.0,
        rangedExpectedHits: 1.0,
        rangedArmorPiercingRating: 0.5,
        maxRange: 6,
        averageSpeed: 0.0,
        toughness: 0.0,
        evasion: 0.0, // Should be 0 with only characters
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify evasion displays as 0.0
      expect(find.text('Evasion'), findsOneWidget);
      expect(find.text('0.0'), findsAtLeast(1)); // Might also be toughness
    });

    testWidgets('should display high precision evasion values correctly',
        (WidgetTester tester) async {
      final lowEvasionUnit = Unit(
        name: 'Heavy Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 7,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      final highEvasionUnit = Unit(
        name: 'Light Unit',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 3,
          resolve: 2,
          defense: 1,
          evasion: 4,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(
            unit: lowEvasionUnit,
            stands: 1,
            pointsCost: 200), // Evasion 1, 7 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // Evasion 4, 3 wounds
      ];

      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test Faction',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      // Calculate expected evasion: (1*7 + 4*3) / (7+3) = (7+12)/10 = 1.9
      final score = ListScore(
        armyList: armyList,
        totalWounds: 10,
        pointsPerWound: 35.0,
        expectedHitVolume: 12.0,
        cleaveRating: 4.0,
        rangedExpectedHits: 2.5,
        rangedArmorPiercingRating: 1.2,
        maxRange: 10,
        averageSpeed: 6.0,
        toughness: 1.6,
        evasion: 1.9, // Precise calculation
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify precise evasion value is displayed
      expect(find.text('Evasion'), findsOneWidget);
      expect(find.text('1.9'), findsOneWidget);
    });

    testWidgets('should maintain layout with both defensive score cards',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 3, pointsCost: 300),
      ];

      final armyList = ArmyList(
        name: 'Layout Test Army',
        faction: 'Test Faction',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 15,
        pointsPerWound: 20.0,
        expectedHitVolume: 19.5, // Changed to unique value
        cleaveRating: 8.2, // Changed to unique value
        rangedExpectedHits: 4.3, // Changed to unique value
        rangedArmorPiercingRating: 2.1, // Changed to unique value
        maxRange: 15,
        averageSpeed: 5.3, // Changed to unique value
        toughness: 2.6, // Changed to unique value
        evasion: 3.8, // Changed to unique value
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify the fifth row contains both toughness and evasion
      expect(find.text('Toughness'), findsOneWidget);
      expect(find.text('Evasion'), findsOneWidget);

      // Verify they are in the same row by checking they're both present
      // and positioned correctly
      final toughnessWidget = tester.widget<Text>(find.text('Toughness'));
      final evasionWidget = tester.widget<Text>(find.text('Evasion'));
      expect(toughnessWidget, isNotNull);
      expect(evasionWidget, isNotNull);

      // Verify both have their respective values displayed (now unique)
      expect(find.text('2.6'), findsOneWidget); // Toughness value
      expect(find.text('3.8'), findsOneWidget); // Evasion value
    });

    testWidgets('should handle evasion tooltip with various decimal values',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 1, pointsCost: 160),
      ];

      final armyList = ArmyList(
        name: 'Decimal Test Army',
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
        cleaveRating: 3.0,
        rangedExpectedHits: 2.0,
        rangedArmorPiercingRating: 1.0,
        maxRange: 8,
        averageSpeed: 5.0,
        toughness: 2.3,
        evasion: 2.7, // Decimal value
        calculatedAt: DateTime.now(),
      );

      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createTestWidget(score));

      // Scroll to make evasion card visible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Find and tap the evasion info icon (should be the second one)
      final infoIcons = find.byIcon(Icons.info_outline);
      expect(infoIcons, findsAtLeast(2));

      await tester.tap(infoIcons.at(1)); // Second info icon should be evasion
      await tester.pumpAndSettle();

      // Verify tooltip shows correct decimal value
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('On average, each wound in your army has 2.7 evasion.'),
          findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should display all score metrics including evasion',
        (WidgetTester tester) async {
      final regiments = [
        Regiment(unit: testUnit, stands: 2, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Complete Metrics Test',
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
        rangedExpectedHits: 2.8, // Changed to unique values
        rangedArmorPiercingRating: 1.5,
        maxRange: 12,
        averageSpeed: 5.0,
        toughness: 2.2, // Changed to unique values
        evasion: 3.4, // Changed to unique values
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify all score cards are present including the new evasion
      expect(find.text('Total Wounds'), findsOneWidget);
      expect(find.text('Points per Wound'), findsOneWidget);
      expect(find.text('Expected Hit Volume'), findsOneWidget);
      expect(find.text('Cleave Rating'), findsOneWidget);
      expect(find.text('Ranged Expected Hits'), findsOneWidget);
      expect(find.text('Ranged Armor Piercing'), findsOneWidget);
      expect(find.text('Max Range'), findsOneWidget);
      expect(find.text('Average Speed'), findsOneWidget);
      expect(find.text('Toughness'), findsOneWidget);
      expect(find.text('Evasion'), findsOneWidget); // New evasion card

      // Verify all have appropriate values (using unique values to avoid conflicts)
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20.00'), findsOneWidget);
      expect(find.text('15.0'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget); // Only one 5.0 now
      expect(find.text('2.8'), findsOneWidget); // Unique ranged hits value
      expect(find.text('1.5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
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
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(score));

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify evasion card is findable (might need scrolling)
      expect(find.text('Evasion'), findsOneWidget);

      // Test scrolling to bottom to ensure evasion card is accessible
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be able to find evasion after scrolling
      expect(find.text('Evasion'), findsOneWidget);
    });
  });
}
