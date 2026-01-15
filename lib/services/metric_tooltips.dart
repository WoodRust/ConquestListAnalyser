import 'package:flutter/material.dart';

/// Centralized tooltip definitions for all metrics
/// Used by both ScoreDisplayWidget and CompareListsScreen
class MetricTooltips {
  static void showDamagePotentialTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Damage Potential'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Measures your army\'s offensive capability and damage output.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Includes:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '• Melee damage (hit volume and cleave)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Ranged damage (expected hits and armor piercing)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Threat range (max range)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Magic capabilities (spells and support)',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showDurabilityTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Durability'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Measures your army\'s survivability and ability to withstand damage.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Includes:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '• Wound totals (raw and effective)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Defensive stats (Defense, Resolve, Evasion, Toughness)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Efficiency metrics (points per wound)',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '• Healing capabilities',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showTotalWoundsTooltip(BuildContext context, {int? totalWounds}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Total Wounds'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total raw wounds across all regiments in your army (excluding regular characters).',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Sum of (Stands × Wounds per Stand)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Raiders (3 stands, 4 wounds each) = 12 wounds',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Huscarls (5 stands, 6 wounds each) = 30 wounds',
                style: TextStyle(fontSize: 14),
              ),
              if (totalWounds != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: $totalWounds total wounds',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showPointsPerWoundTooltip(BuildContext context,
      {double? pointsPerWound}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Points per Wound'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Average cost per wound across your army. Lower is generally better as it means more wounds for your points.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Total Points ÷ Total Wounds',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 10-12: Excellent (cheap wounds)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 13-15: Good (average)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 16-20: Fair (elite units)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 21+: Expensive (monsters/characters)',
                style: TextStyle(fontSize: 14),
              ),
              if (pointsPerWound != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${pointsPerWound.toStringAsFixed(1)} pts/wound',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showEffectiveWoundsDefenseTooltip(BuildContext context,
      {double? effectiveWoundsValue, int? totalWounds}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Effective Wounds (Defense)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Effective Wounds represents how much damage your army can absorb, accounting for defensive characteristics only.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Sum of (Regiment Wounds × (6 ÷ (6 - Best Defense)))',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Best Defense = Highest of Defense or Evasion (including army bonuses)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Defense/Evasion 1: 6÷5 = 1.2× wounds',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Defense/Evasion 2: 6÷4 = 1.5× wounds',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Defense/Evasion 3: 6÷3 = 2.0× wounds',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Defense/Evasion 4: 6÷2 = 3.0× wounds',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Defense/Evasion 5: 6÷1 = 6.0× wounds',
                style: TextStyle(fontSize: 14),
              ),
              if (effectiveWoundsValue != null && totalWounds != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army has ${effectiveWoundsValue.toStringAsFixed(1)} effective wounds vs $totalWounds raw wounds.',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showPointsPerEffectiveWoundDefenseTooltip(BuildContext context,
      {double? pointsPerEffWound}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Points per Eff. Wound (Defense)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cost per effective wound considering DEFENSE/EVASION only. This shows your baseline survivability efficiency.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Total Points ÷ Effective Wounds (Defense)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lower is better - means more defense per point spent.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 5-8: Excellent defensive efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 9-11: Good defensive efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 12-15: Average defensive efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 16+: Lower defensive efficiency',
                style: TextStyle(fontSize: 14),
              ),
              if (pointsPerEffWound != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${pointsPerEffWound.toStringAsFixed(2)} pts/eff. wound (def)',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showEffectiveWoundsDefenseResolveTooltip(BuildContext context,
      {double? effectiveWoundsValue, double? effectiveWoundsDefense}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Effective Wounds (Defense & Resolve)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This shows your army\'s true survivability, accounting for both defense and resolve characteristics.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'How it works:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '1. Failed defense rolls = wounds taken',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '2. Each wound triggers a resolve roll',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '3. Failed resolve rolls = additional wounds',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Wounds ÷ (Defense Failure Rate × Wound Multiplier)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Where Wound Multiplier = 1 + (Failed Resolve Rate)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples (Defense 3):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Resolve 2: Takes 67% more wounds than defense-only',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Resolve 4: Takes 33% more wounds than defense-only',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Resolve 6: Takes same wounds as defense-only',
                style: TextStyle(fontSize: 14),
              ),
              if (effectiveWoundsValue != null &&
                  effectiveWoundsDefense != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army has ${effectiveWoundsValue.toStringAsFixed(1)} true effective wounds vs ${effectiveWoundsDefense.toStringAsFixed(1)} defense-only effective wounds.',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showPointsPerEffectiveWoundDefenseResolveTooltip(
      BuildContext context,
      {double? pointsPerEffWoundDefResolve,
      double? pointsPerEffWoundDef}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Points per Eff. Wound (Defense & Resolve)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cost per effective wound considering BOTH defense/evasion AND resolve. This reflects TOTAL survivability including morale.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Total Points ÷ Effective Wounds (Defense & Resolve)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lower is better - means more total survivability per point spent.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 5-8: Excellent total efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 9-11: Good total efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 12-15: Average total efficiency',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 16+: Lower total efficiency',
                style: TextStyle(fontSize: 14),
              ),
              if (pointsPerEffWoundDefResolve != null &&
                  pointsPerEffWoundDef != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${pointsPerEffWoundDefResolve.toStringAsFixed(2)} pts/eff. wound (D&R)',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compare to defense only: ${pointsPerEffWoundDef.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showResolveImpactTooltip(BuildContext context,
      {double? resolveImpactValue}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resolve Impact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resolve Impact shows how much survivability your army loses due to resolve wounds multiplying on top of failed defenses.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: ((Defense&Resolve - Defense) ÷ Defense) × 100',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Negative values = resolve makes army less survivable',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                'Positive values = resolve improves survivability (rare)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Impact Categories:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• -0% to -10%: Excellent resolve',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• -11% to -30%: Good resolve',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• -31% to -50%: Poor resolve',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• -51% and worse: Terrible resolve',
                style: TextStyle(fontSize: 14),
              ),
              if (resolveImpactValue != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army loses ${resolveImpactValue.abs().toStringAsFixed(1)}% of its defensive survivability due to resolve wounds.',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showHitVolumeTooltip(BuildContext context,
      {double? expectedHitVolume}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hit Volume'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expected number of hits your army deals in melee combat per round.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Attacks × ((Clash + 1) ÷ 6)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Modifiers: +1 attack for Leader, re-rolls for Flurry',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 12 attacks, Clash 2: 12 × (3/6) = 6 expected hits',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 12 attacks, Clash 3: 12 × (4/6) = 8 expected hits',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 12 attacks, Clash 4: 12 × (5/6) = 10 expected hits',
                style: TextStyle(fontSize: 14),
              ),
              if (expectedHitVolume != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${expectedHitVolume.toStringAsFixed(1)} expected hits',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showCleaveTooltip(BuildContext context, {double? cleaveRating}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cleave Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Measures your army\'s ability to penetrate armor in melee. Cleave reduces enemy defense rolls.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Hit Volume × Cleave Value',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'How Cleave works:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Cleave (1): Enemy defense reduced by 1',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Cleave (2): Enemy defense reduced by 2',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Cleave (3): Enemy defense reduced by 3',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Example: 10 hits with Cleave (2) = 20 cleave rating',
                style: TextStyle(fontSize: 14),
              ),
              if (cleaveRating != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${cleaveRating.toStringAsFixed(1)} cleave rating',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showAvgSpeedTooltip(BuildContext context, {double? averageSpeed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Average Speed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Average march distance across your army (excluding regular characters). Higher speed = better mobility.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: (Sum of Regiment Marches) ÷ Regiment Count',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Speed Categories:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 4-5: Slow (heavy infantry, brutes)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 6: Standard (most infantry)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 7-8: Fast (light infantry, cavalry)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 9+: Very fast (flying, mounted)',
                style: TextStyle(fontSize: 14),
              ),
              if (averageSpeed != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${averageSpeed.toStringAsFixed(1)}" average march',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showEvasionTooltip(BuildContext context, {double? evasionValue}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Evasion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (evasionValue != null)
                Text(
                  'On average, each wound in your army has ${evasionValue.toStringAsFixed(1)} evasion.',
                  style: const TextStyle(fontSize: 16),
                ),
              if (evasionValue == null)
                const Text(
                  'Average evasion characteristic per wound across all regiments in your army.',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showToughnessTooltip(BuildContext context,
      {double? toughnessValue}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Toughness'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (toughnessValue != null)
                Text(
                  'On average, each wound in your army has ${toughnessValue.toStringAsFixed(1)} defense.',
                  style: const TextStyle(fontSize: 16),
                ),
              if (toughnessValue == null)
                const Text(
                  'Average defense characteristic per wound across all regiments in your army.',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showRangedHitsTooltip(BuildContext context,
      {double? rangedExpectedHits}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ranged Hits'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expected number of hits your army deals with ranged attacks (barrage) per round.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Barrage × Stands × ((Volley + 1) ÷ 6)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Modifiers: +1 barrage for Leader',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Barrage(5), 3 stands, Volley 3: 15 × (4/6) = 10 hits',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Barrage(3), 4 stands, Volley 2: 12 × (3/6) = 6 hits',
                style: TextStyle(fontSize: 14),
              ),
              if (rangedExpectedHits != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${rangedExpectedHits.toStringAsFixed(1)} expected ranged hits',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showArmorPierceTooltip(BuildContext context,
      {double? armorPiercingRating}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Armor Piercing Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Measures your army\'s ability to penetrate armor with ranged attacks.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Ranged Hits × Armor Piercing Value',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'How Armor Piercing works:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• AP (1): Enemy defense reduced by 1',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• AP (2): Enemy defense reduced by 2',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• AP (3): Enemy defense reduced by 3',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Example: 8 ranged hits with AP (2) = 16 armor piercing rating',
                style: TextStyle(fontSize: 14),
              ),
              if (armorPiercingRating != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${armorPiercingRating.toStringAsFixed(1)} armor piercing rating',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showMaxRangeTooltip(BuildContext context, {int? maxRange}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Max Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Maximum barrage range in your army. Shows how far you can engage enemies.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Common Ranges:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 0: No ranged units',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 12"-16": Short range (bows, crossbows)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 18"-24": Medium range (longbows)',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 30"+: Long range (artillery)',
                style: TextStyle(fontSize: 14),
              ),
              if (maxRange != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: $maxRange" maximum range',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showMagicCapabilityTooltip(BuildContext context,
      {int? magicCapability}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Magic Capability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total magical power available to your army, measured by spell dice from Priests and Wizards.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Sum of all spell dice from units with Priest(X) or Wizard(X)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Shaman with Priest(6) = 6 spell dice',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Ice Jotnar with Priest(5) = 5 spell dice',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Two Shamans = 12 total spell dice',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 0 dice: No magical support',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 5-6 dice: Light magical support',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 10-12 dice: Moderate magical power',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 15+ dice: Magic-heavy army',
                style: TextStyle(fontSize: 14),
              ),
              if (magicCapability != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: $magicCapability spell dice',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showExpectedHealingCapabilityTooltip(BuildContext context,
      {double? healingCapability}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Expected Healing Capability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total wounds your army can heal per turn through regeneration and healing spells.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Formula: Regeneration + Healing Spells',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Examples:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Trolls with Regeneration(6) = 6 wounds/turn',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Werewargs with Regeneration(3) = 3 wounds/turn',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• Two Troll regiments = 12 total wounds/turn',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• 0: No self-healing',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 3-6: Light regeneration',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 9-12: Moderate sustain',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '• 15+: High regeneration army',
                style: TextStyle(fontSize: 14),
              ),
              if (healingCapability != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Your army: ${healingCapability.toStringAsFixed(0)} wounds/turn',
                  style: const TextStyle(
                      fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showReinforcementTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reinforcement Timing'),
          content: const SingleChildScrollView(
            child: Text(
              'Shows the percentile distribution of regiments (excluding regular characters) that have '
              'arrived on the battlefield by the end of each turn, based on Monte Carlo '
              'simulation (10,000 runs).\n\n'
              'Format:\n'
              '• Top line: 20th%-50th%-80th% (percentiles)\n'
              '• Bottom line: Regiment counts\n\n'
              'Reading the numbers:\n'
              '• 20th percentile: In 1 out of 5 games, you\'ll get this many or fewer regiments\n'
              '• 50th percentile (median): In half your games, you\'ll get this many regiments\n'
              '• 80th percentile: In 1 out of 5 games, you\'ll get this many or more regiments\n\n'
              'Narrow percentile ranges indicate predictable reinforcement arrival, '
              'while wide ranges indicate high variance/swinginess in deployment timing.\n\n'
              'The simulation accounts for:\n'
              '• Weight class (Light/Medium/Heavy)\n'
              '• Flank special rule (auto-arrival)\n'
              '• Forward Force character ability\n'
              '• Player selecting one unit per turn\n'
              '• D6 reinforcement rolls per game rules\n\n'
              'Note: Regular characters are excluded from the calculation as they cannot '
              'arrive without a regiment, but character monsters (which count as regiments) are included.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
