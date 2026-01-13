import 'package:flutter/material.dart';
import '../../models/list_score.dart';

class CompareListsScreen extends StatelessWidget {
  final List<ListScore> listsToCompare;

  const CompareListsScreen({
    super.key,
    required this.listsToCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Lists'),
      ),
      body: Column(
        children: [
          _buildStickyHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildMetricsTable(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Metric name column (fixed width)
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Metric',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // List columns (flexible)
          ...listsToCompare.map((listScore) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listScore.armyList.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listScore.armyList.faction,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${listScore.armyList.totalPoints} pts',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricsTable(BuildContext context) {
    return Column(
      children: [
        // Wound metrics - paired with efficiency metrics
        _buildMetricRow('Total Wounds',
            listsToCompare.map((l) => l.totalWounds.toDouble()).toList(), true,
            () => _showTotalWoundsTooltip(context), false),
        _buildMetricRow('Points per Wound',
            listsToCompare.map((l) => l.pointsPerWound).toList(), true,
            () => _showPointsPerWoundTooltip(context), true),
        _buildMetricRow('Effective Wounds (Defense)',
            listsToCompare.map((l) => l.effectiveWoundsDefense).toList(), true,
            () => _showEffectiveWoundsDefenseTooltip(context), false),
        _buildMetricRow(
            'Pts per Eff. Wound (Def)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefense)
                .toList(),
            true,
            () => _showPointsPerEffectiveWoundDefenseTooltip(context), true),
        _buildMetricRow(
            'Effective Wounds (D&R)',
            listsToCompare.map((l) => l.effectiveWoundsDefenseResolve).toList(),
            true,
            () => _showEffectiveWoundsDefenseResolveTooltip(context), false),
        _buildMetricRow(
            'Pts per Eff. Wound (D&R)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefenseResolve)
                .toList(),
            true,
            () => _showPointsPerEffectiveWoundDefenseResolveTooltip(context), true),
        _buildMetricRow(
            'Resolve Impact',
            listsToCompare.map((l) => l.resolveImpactPercentage).toList(),
            true,
            () => _showResolveImpactTooltip(context), false),
        // Combat metrics
        _buildMetricRow('Expected Hit Volume',
            listsToCompare.map((l) => l.expectedHitVolume).toList(), true,
            () => _showHitVolumeTooltip(context), false),
        _buildMetricRow('Cleave Rating',
            listsToCompare.map((l) => l.cleaveRating).toList(), true,
            () => _showCleaveTooltip(context), false),
        _buildMetricRow('Average Speed',
            listsToCompare.map((l) => l.averageSpeed).toList(), true,
            () => _showAvgSpeedTooltip(context), false),
        // Defensive metrics
        _buildMetricRow(
            'Evasion', listsToCompare.map((l) => l.evasion).toList(), true,
            () => _showEvasionTooltip(context), false),
        _buildMetricRow(
            'Toughness', listsToCompare.map((l) => l.toughness).toList(), true,
            () => _showToughnessTooltip(context), false),
        // Ranged metrics
        _buildMetricRow('Ranged Expected Hits',
            listsToCompare.map((l) => l.rangedExpectedHits).toList(), true,
            () => _showRangedExpectedHitsTooltip(context), false),
        _buildMetricRow(
            'Ranged Armor Piercing',
            listsToCompare.map((l) => l.rangedArmorPiercingRating).toList(),
            true,
            () => _showRangedArmorPiercingTooltip(context), false),
        _buildMetricRow('Max Range',
            listsToCompare.map((l) => l.maxRange.toDouble()).toList(), true,
            () => _showMaxRangeTooltip(context), false),
        // Magic and Healing
        _buildMetricRow(
            'Magic Capability',
            listsToCompare.map((l) => l.magicCapability.toDouble()).toList(),
            true,
            () => _showMagicCapabilityTooltip(context), false),
        _buildMetricRow(
            'Expected Healing Capability',
            listsToCompare
                .map((l) => l.expectedHealingCapability.toDouble())
                .toList(),
            true,
            () => _showExpectedHealingCapabilityTooltip(context), false),
        
        // Reinforcement Timing Section
        _buildReinforcementSectionHeader(context),
        _buildReinforcementMetricRow(
            'Turn 1 Arrivals', listsToCompare, 0, context),
        _buildReinforcementMetricRow(
            'Turn 2 Arrivals', listsToCompare, 1, context),
        _buildReinforcementMetricRow(
            'Turn 3 Arrivals', listsToCompare, 2, context),
        _buildReinforcementMetricRow(
            'Turn 4 Arrivals', listsToCompare, 3, context),
        _buildReinforcementMetricRow(
            'Turn 5 Arrivals', listsToCompare, 4, context),
      ],
    );
  }

  Widget _buildReinforcementSectionHeader(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.orange.shade200, width: 2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reinforcements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
                    onPressed: () => _showReinforcementTimingTooltip(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          ...listsToCompare.map((list) => Expanded(
                child: Container(),
              )),
        ],
      ),
    );
  }

  Widget _buildReinforcementMetricRow(
      String metricName, List<ListScore> lists, int turnIndex, BuildContext context) {
    // Extract arrival percentages for this turn
    final averages = lists.map((list) {
      return list.reinforcementMetrics?.turn1Through5ArrivalPercent[turnIndex];
    }).toList();

    // Extract percentile ranges for consistency indicator
    final p20Values = lists.map((list) {
      return list.reinforcementMetrics?.turn1Through5P20[turnIndex];
    }).toList();
    final p80Values = lists.map((list) {
      return list.reinforcementMetrics?.turn1Through5P80[turnIndex];
    }).toList();

    // Find best average (highest)
    double? bestAvg;
    final validAvgs = averages.where((v) => v != null).map((v) => v!).toList();
    if (validAvgs.isNotEmpty) {
      bestAvg = validAvgs.reduce((a, b) => a > b ? a : b);
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                metricName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          ...List.generate(lists.length, (index) {
            final avg = averages[index];
            final p20 = p20Values[index];
            final p80 = p80Values[index];

            if (avg == null || p20 == null || p80 == null) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'N/A',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              );
            }

            final isHighlighted = bestAvg != null && (avg - bestAvg).abs() < 0.01;

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.green.shade100 : null,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${avg.round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${p20.round()}%-${p80.round()}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
      String metricName, List<double> values, bool shouldCompare, VoidCallback? onInfoTap, bool lowerIsBetter) {
    // Filter out invalid values (0, infinity, NaN) for comparison
    final validValues = values.where((v) => v.isFinite && v > 0).toList();

    // Find best value only if we should compare and there are valid values
    double? bestValue;
    if (shouldCompare && validValues.isNotEmpty) {
      // For metrics where lower is better (efficiency metrics) find minimum
      // For metrics where higher is better find maximum
      bestValue = lowerIsBetter
          ? validValues.reduce((a, b) => a < b ? a : b)
          : validValues.reduce((a, b) => a > b ? a : b);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Metric name with info icon
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      metricName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (onInfoTap != null)
                    InkWell(
                      onTap: onInfoTap,
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Values for each list
          ...List.generate(listsToCompare.length, (index) {
            final value = values[index];
            final isValid = value.isFinite && value > 0;
            final isBest = shouldCompare && bestValue != null && isValid && value == bestValue;

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isBest ? Colors.green.shade100 : null,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    isValid ? value.toStringAsFixed(1) : '-',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTotalWoundsTooltip(BuildContext context) {
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

  void _showPointsPerWoundTooltip(BuildContext context) {
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

  void _showHitVolumeTooltip(BuildContext context) {
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

  void _showCleaveTooltip(BuildContext context) {
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

  void _showMagicCapabilityTooltip(BuildContext context) {
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

  void _showExpectedHealingCapabilityTooltip(BuildContext context) {
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

  void _showRangedExpectedHitsTooltip(BuildContext context) {
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

  void _showRangedArmorPiercingTooltip(BuildContext context) {
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

  void _showMaxRangeTooltip(BuildContext context) {
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

  void _showEffectiveWoundsDefenseTooltip(BuildContext context) {
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

  void _showEffectiveWoundsDefenseResolveTooltip(BuildContext context) {
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

  void _showPointsPerEffectiveWoundDefenseTooltip(BuildContext context) {
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

  void _showPointsPerEffectiveWoundDefenseResolveTooltip(BuildContext context) {
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

  void _showEvasionTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Evasion'),
          content: const Text(
            'On average, each wound in your army has this much evasion.',
            style: TextStyle(fontSize: 16),
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

  void _showToughnessTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Toughness'),
          content: const Text(
            'On average, each wound in your army has this much defense.',
            style: TextStyle(fontSize: 16),
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

  void _showAvgSpeedTooltip(BuildContext context) {
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

  void _showResolveImpactTooltip(BuildContext context) {
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

  void _showReinforcementTimingTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reinforcement Timing'),
          content: const Text(
            'Shows the percentage of regiments (excluding regular characters) that arrive by each turn in Monte Carlo simulations (10,000 runs).\n\n'
            'Main percentage: Average arrival rate across all simulations.\n\n'
            'Percentile range (e.g., 20%-80%): Shows the typical range of outcomes. '
            'Narrow ranges indicate more predictable deployment, while wide ranges indicate more variation between games.\n\n'
            'Higher average percentages mean faster deployment. '
            'The best (highest) average for each turn is highlighted in green.\n\n'
            'Note: Regular characters are excluded from the count as they cannot arrive without a regiment, '
            'but character monsters (which count as regiments) are included.',
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
