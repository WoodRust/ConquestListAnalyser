import 'package:flutter/material.dart';
import '../../models/list_score.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final ListScore score;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Army Info Section
          _buildInfoSection(),
          const SizedBox(height: 20),
          // Scores Section
          _buildScoresSection(context),
          const SizedBox(height: 20),
          // Regiment Breakdown
          _buildRegimentBreakdown(),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            score.armyList.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Faction: ${score.armyList.faction}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Points: ${score.armyList.totalPoints}/${score.armyList.pointsLimit}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Regiments: ${score.armyList.regiments.length}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Characters: ${score.armyList.characters.length}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Activations: ${score.armyList.characters.length + score.armyList.nonCharacterRegiments.length}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Regiment Class Counts - using ArmyList getters
          Row(
            children: [
              Expanded(
                child: Text(
                  'Light: ${score.armyList.lightRegimentCount}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  'Medium: ${score.armyList.mediumRegimentCount}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  'Heavy: ${score.armyList.heavyRegimentCount}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoresSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // First row of score cards
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'Total Wounds',
                score.totalWounds.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'Points per Wound',
                score.pointsPerWound.toStringAsFixed(2),
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row of score cards
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'Expected Hit Volume',
                score.expectedHitVolume.toStringAsFixed(1),
                Icons.gps_fixed,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'Cleave Rating',
                score.cleaveRating.toStringAsFixed(1),
                Icons.cut,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third row of score cards
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'Ranged Expected Hits',
                score.rangedExpectedHits.toStringAsFixed(1),
                Icons.my_location,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'Ranged Armor Piercing',
                score.rangedArmorPiercingRating.toStringAsFixed(1),
                Icons.shield,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fourth row of score cards
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                'Max Range',
                score.maxRange.toString(),
                Icons.radar,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                'Average Speed',
                score.averageSpeed.toStringAsFixed(1),
                Icons.speed,
                Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fifth row of score cards - Toughness and Evasion
        Row(
          children: [
            Expanded(
              child: _buildToughnessScoreCard(
                'Toughness',
                score.toughness.toStringAsFixed(1),
                Icons.security,
                Colors.brown,
                score.toughness,
                context,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEvasionScoreCard(
                'Evasion',
                score.evasion.toStringAsFixed(1),
                Icons.flash_on,
                Colors.amber,
                score.evasion,
                context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildToughnessScoreCard(String title, String value, IconData icon,
      Color color, double toughnessValue, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Main content centered - explicitly center the column
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Info icon positioned at top-right
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showToughnessTooltip(context, toughnessValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvasionScoreCard(String title, String value, IconData icon,
      Color color, double evasionValue, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Main content centered - explicitly center the column
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Info icon positioned at top-right
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showEvasionTooltip(context, evasionValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showToughnessTooltip(BuildContext context, double toughnessValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Toughness'),
          content: Text(
            'On average, each wound in your army has ${toughnessValue.toStringAsFixed(1)} defense.',
            style: const TextStyle(fontSize: 16),
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

  void _showEvasionTooltip(BuildContext context, double evasionValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Evasion'),
          content: Text(
            'On average, each wound in your army has ${evasionValue.toStringAsFixed(1)} evasion.',
            style: const TextStyle(fontSize: 16),
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

  Widget _buildRegimentBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Regiment Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('Unit',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Stands',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Move',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Defense',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Wounds',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Points',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('PPW',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('EHV',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Cleave',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Ranged',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('AP',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 1,
                        child: Text('Range',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Regiment rows
              ...score.armyList.regiments.asMap().entries.map((entry) {
                final index = entry.key;
                final regiment = entry.value;
                final isEven = index % 2 == 0;
                return Container(
                  padding: const EdgeInsets.all(12),
                  color: isEven ? null : Colors.grey[50],
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              regiment.unit.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (regiment.upgrades.isNotEmpty)
                              Text(
                                regiment.upgrades.join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 1, child: Text(regiment.stands.toString())),
                      Expanded(
                          flex: 1,
                          child: Text((regiment.unit.characteristics.march ?? 0)
                              .toString())),
                      Expanded(
                          flex: 1,
                          child: Text(regiment.unit.characteristics.defense
                              .toString())),
                      Expanded(
                          flex: 1,
                          child: Text(regiment.totalWounds.toString())),
                      Expanded(
                          flex: 1, child: Text(regiment.pointsCost.toString())),
                      Expanded(
                          flex: 1,
                          child:
                              Text(regiment.pointsPerWound.toStringAsFixed(1))),
                      Expanded(
                          flex: 1,
                          child: Text(regiment
                              .calculateExpectedHitVolume(
                                  armyRegiments: score.armyList.regiments)
                              .toStringAsFixed(1))),
                      Expanded(
                          flex: 1,
                          child: Text(regiment
                              .calculateCleaveRating(
                                  armyRegiments: score.armyList.regiments)
                              .toStringAsFixed(1))),
                      Expanded(
                          flex: 1,
                          child: Text(regiment
                              .calculateRangedExpectedHits()
                              .toStringAsFixed(1))),
                      Expanded(
                          flex: 1,
                          child: Text(regiment
                              .calculateRangedArmorPiercingRating()
                              .toStringAsFixed(1))),
                      Expanded(
                          flex: 1,
                          child: Text(regiment.barrageRange > 0
                              ? regiment.barrageRange.toString()
                              : '-')),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
