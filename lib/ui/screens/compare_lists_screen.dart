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
              child: _buildMetricsTable(),
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

  Widget _buildMetricsTable() {
    return Column(
      children: [
        _buildMetricRow(
            'Total Points',
            listsToCompare
                .map((l) => l.armyList.totalPoints.toDouble())
                .toList(),
            false),
        _buildMetricRow('Total Wounds',
            listsToCompare.map((l) => l.totalWounds.toDouble()).toList(), true),
        _buildMetricRow('Points per Wound',
            listsToCompare.map((l) => l.pointsPerWound).toList(), false),
        _buildMetricRow('Expected Hit Volume',
            listsToCompare.map((l) => l.expectedHitVolume).toList(), true),
        _buildMetricRow('Cleave Rating',
            listsToCompare.map((l) => l.cleaveRating).toList(), true),
        _buildMetricRow(
            'Magic Capability',
            listsToCompare.map((l) => l.magicCapability.toDouble()).toList(),
            true),
        _buildMetricRow(
            'Expected Healing Capability',
            listsToCompare
                .map((l) => l.expectedHealingCapability.toDouble())
                .toList(),
            true),
        _buildMetricRow('Ranged Expected Hits',
            listsToCompare.map((l) => l.rangedExpectedHits).toList(), true),
        _buildMetricRow(
            'Ranged Armor Piercing',
            listsToCompare.map((l) => l.rangedArmorPiercingRating).toList(),
            true),
        _buildMetricRow('Max Range',
            listsToCompare.map((l) => l.maxRange.toDouble()).toList(), true),
        _buildMetricRow('Effective Wounds (Defense)',
            listsToCompare.map((l) => l.effectiveWoundsDefense).toList(), true),
        _buildMetricRow(
            'Effective Wounds (D&R)',
            listsToCompare.map((l) => l.effectiveWoundsDefenseResolve).toList(),
            true),
        _buildMetricRow(
            'Pts per Eff. Wound (Def)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefense)
                .toList(),
            false),
        _buildMetricRow(
            'Pts per Eff. Wound (D&R)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefenseResolve)
                .toList(),
            false),
        _buildMetricRow(
            'Evasion', listsToCompare.map((l) => l.evasion).toList(), true),
        _buildMetricRow(
            'Toughness', listsToCompare.map((l) => l.toughness).toList(), true),
        _buildMetricRow('Average Speed',
            listsToCompare.map((l) => l.averageSpeed).toList(), true),
      ],
    );
  }

  Widget _buildMetricRow(
      String metricName, List<double> values, bool higherIsBetter) {
    // Filter out invalid values (0, infinity, NaN) for comparison
    final validValues = values.where((v) => v.isFinite && v > 0).toList();

    // Find best value if there are valid values to compare
    double? bestValue;
    if (validValues.isNotEmpty) {
      bestValue = higherIsBetter
          ? validValues.reduce((a, b) => a > b ? a : b)
          : validValues.reduce((a, b) => a < b ? a : b);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Metric name
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                metricName,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          // Values for each list
          ...List.generate(listsToCompare.length, (index) {
            final value = values[index];
            final isValid = value.isFinite && value > 0;
            final isBest = bestValue != null && isValid && value == bestValue;

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
}
