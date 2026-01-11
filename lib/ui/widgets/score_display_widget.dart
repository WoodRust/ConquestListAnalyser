import 'package:flutter/material.dart';
import '../../models/list_score.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final ListScore score;

  const ScoreDisplayWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Army Summary Section
          _buildArmySummary(),
          const SizedBox(height: 20),

          // Scores Section
          const Text(
            'Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildScoreGrid(context),

          const SizedBox(height: 24),
          // Regiment Details Section
          const Text(
            'Regiment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRegimentTable(context),
        ],
      ),
    );
  }

  Widget _buildRegimentTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 12,
          headingRowColor:
              MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
          columns: const [
            DataColumn(
              label: Text(
                'Regiment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Stands',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Defense',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Resolve',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Wounds',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Points',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Pts/Wound',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Hit Vol.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Cleave',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Ranged',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            DataColumn(
              label: Text(
                'Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
          rows: score.armyList.regiments.map((regiment) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 100,
                    child: Text(
                      regiment.unit.name,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.stands.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.unit.characteristics.defense.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.unit.characteristics.resolve.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.totalWounds.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.pointsCost.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.pointsPerWound.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.expectedHitVolume.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.cleaveRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.rangedExpectedHits.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                DataCell(
                  Text(
                    regiment.barrageRange > 0
                        ? regiment.barrageRange.toString()
                        : '-',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildArmySummary() {
    final armyList = score.armyList;

    // Calculate regiment count with breakdown
    // Calculate regiment count
    final regularRegiments = armyList.nonCharacterRegiments.length;
    final monsterCharacters = armyList.characterMonsters.length;
    final totalRegiments = regularRegiments + monsterCharacters;

    // Calculate character count
    final totalCharacters = armyList.characters.length;

    // Calculate activation count (total items)
    final totalActivations = armyList.regiments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Army name and faction
        Text(
          armyList.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${armyList.faction} • ${armyList.totalPoints}/${armyList.pointsLimit} points',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),

        // Regiment breakdown in compact rows
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Regiments',
                totalRegiments.toString(),
                Icons.group,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Characters',
                totalCharacters.toString(),
                Icons.person,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Activations',
                totalActivations.toString(),
                Icons.play_arrow,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Regiment class breakdown
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Light',
                armyList.lightRegimentCount.toString(),
                Icons.flash_on,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Medium',
                armyList.mediumRegimentCount.toString(),
                Icons.shield,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Heavy',
                armyList.heavyRegimentCount.toString(),
                Icons.security,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGrid(BuildContext context) {
    return Column(
      children: [
        // First row - Total wounds and efficiency
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Total Wounds',
                score.totalWounds.toString(),
                Icons.favorite,
                Colors.red,
                context,
                () => _showTotalWoundsTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Points/Wound',
                score.pointsPerWound.toStringAsFixed(1),
                Icons.trending_up,
                Colors.green,
                context,
                () => _showPointsPerWoundTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEffectiveWoundsDefenseCompactScoreCard(
                'Eff. Wounds (Def)',
                score.effectiveWoundsDefense.toStringAsFixed(1),
                Icons.favorite_border,
                Colors.deepPurple,
                score.effectiveWoundsDefense,
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row - Defense effective wounds efficiency and D&R metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Pts/Eff. Wound (Def)',
                score.pointsPerEffectiveWoundDefense.toStringAsFixed(2),
                Icons.calculate,
                Colors.blueGrey,
                context,
                () => _showPointsPerEffectiveWoundDefenseTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEffectiveWoundsDefenseResolveCompactScoreCard(
                'Eff. Wounds (D&R)',
                score.effectiveWoundsDefenseResolve.toStringAsFixed(1),
                Icons.shield_outlined,
                Colors.teal,
                score.effectiveWoundsDefenseResolve,
                context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Pts/Eff. Wound (D&R)',
                score.pointsPerEffectiveWoundDefenseResolve.toStringAsFixed(2),
                Icons.calculate_outlined,
                Colors.teal,
                context,
                () =>
                    _showPointsPerEffectiveWoundDefenseResolveTooltip(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Third row - Resolve impact and combat metrics
        Row(
          children: [
            Expanded(
              child: _buildResolveImpactCompactScoreCard(
                'Resolve Impact',
                '${score.resolveImpactPercentage.toStringAsFixed(1)}%',
                Icons.psychology,
                Colors.deepOrange,
                score.resolveImpactPercentage,
                context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Hit Volume',
                score.expectedHitVolume.toStringAsFixed(1),
                Icons.gps_fixed,
                Colors.blue,
                context,
                () => _showHitVolumeTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Cleave',
                score.cleaveRating.toStringAsFixed(1),
                Icons.cut,
                Colors.orange,
                context,
                () => _showCleaveTooltip(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Fourth row - Speed and defensive metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Avg Speed',
                score.averageSpeed.toStringAsFixed(1),
                Icons.directions_run,
                Colors.amber,
                context,
                () => _showAvgSpeedTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEvasionCompactScoreCard(
                'Evasion',
                score.evasion.toStringAsFixed(1),
                Icons.flash_on,
                Colors.lime,
                score.evasion,
                context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToughnessCompactScoreCard(
                'Toughness',
                score.toughness.toStringAsFixed(1),
                Icons.security,
                Colors.brown,
                score.toughness,
                context,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Fifth row - Ranged metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Ranged Hits',
                score.rangedExpectedHits.toStringAsFixed(1),
                Icons.my_location,
                Colors.purple,
                context,
                () => _showRangedHitsTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Armor Pierce',
                score.rangedArmorPiercingRating.toStringAsFixed(1),
                Icons.shield,
                Colors.indigo,
                context,
                () => _showArmorPierceTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Max Range',
                score.maxRange.toString(),
                Icons.speed,
                Colors.cyan,
                context,
                () => _showMaxRangeTooltip(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sixth row - Magic Capability and Expected Healing Capability
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Magic Capability',
                score.magicCapability.toString(),
                Icons.auto_fix_high,
                Colors.deepPurple,
                context,
                () => _showMagicCapabilityTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCardWithInfo(
                'Healing Capability',
                score.expectedHealingCapability.toString(),
                Icons.healing,
                Colors.teal.shade700,
                context,
                () => _showExpectedHealingCapabilityTooltip(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactScoreCardWithInfo(String title, String value,
      IconData icon, Color color, BuildContext context, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToughnessCompactScoreCard(String title, String value,
      IconData icon, Color color, double toughnessValue, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showToughnessTooltip(context, toughnessValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvasionCompactScoreCard(String title, String value,
      IconData icon, Color color, double evasionValue, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showEvasionTooltip(context, evasionValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectiveWoundsDefenseCompactScoreCard(
      String title,
      String value,
      IconData icon,
      Color color,
      double effectiveWoundsValue,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showEffectiveWoundsDefenseTooltip(
                  context, effectiveWoundsValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectiveWoundsDefenseResolveCompactScoreCard(
      String title,
      String value,
      IconData icon,
      Color color,
      double effectiveWoundsValue,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showEffectiveWoundsDefenseResolveTooltip(
                  context, effectiveWoundsValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolveImpactCompactScoreCard(
      String title,
      String value,
      IconData icon,
      Color color,
      double resolveImpactValue,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () =>
                  _showResolveImpactTooltip(context, resolveImpactValue),
              child: Icon(
                Icons.info_outline,
                color: color.withOpacity(0.7),
                size: 12,
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

  void _showEffectiveWoundsDefenseTooltip(
      BuildContext context, double effectiveWoundsValue) {
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
              const SizedBox(height: 12),
              Text(
                'Your army has ${effectiveWoundsValue.toStringAsFixed(1)} effective wounds vs ${score.totalWounds} raw wounds.',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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

  void _showEffectiveWoundsDefenseResolveTooltip(
      BuildContext context, double effectiveWoundsValue) {
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
              const SizedBox(height: 12),
              Text(
                'Your army has ${effectiveWoundsValue.toStringAsFixed(1)} true effective wounds vs ${score.effectiveWoundsDefense.toStringAsFixed(1)} defense-only effective wounds.',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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

  void _showResolveImpactTooltip(
      BuildContext context, double resolveImpactValue) {
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
              const SizedBox(height: 12),
              Text(
                'Your army loses ${resolveImpactValue.abs().toStringAsFixed(1)}% of its defensive survivability due to resolve wounds.',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.totalWounds} total wounds',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.pointsPerWound.toStringAsFixed(1)} pts/wound',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.pointsPerEffectiveWoundDefense.toStringAsFixed(2)} pts/eff. wound (def)',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.pointsPerEffectiveWoundDefenseResolve.toStringAsFixed(2)} pts/eff. wound (D&R)',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(
                'Compare to defense only: ${score.pointsPerEffectiveWoundDefense.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600]),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.averageSpeed.toStringAsFixed(1)}" average march',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.expectedHitVolume.toStringAsFixed(1)} expected hits',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.cleaveRating.toStringAsFixed(1)} cleave rating',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.maxRange}" maximum range',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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

  void _showRangedHitsTooltip(BuildContext context) {
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.rangedExpectedHits.toStringAsFixed(1)} expected ranged hits',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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

  void _showArmorPierceTooltip(BuildContext context) {
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.rangedArmorPiercingRating.toStringAsFixed(1)} armor piercing rating',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.magicCapability} spell dice',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
              const SizedBox(height: 12),
              Text(
                'Your army: ${score.expectedHealingCapability} wounds/turn',
                style:
                    const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
}
