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
        ],
      ),
    );
  }

  Widget _buildArmySummary() {
    final armyList = score.armyList;
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
                armyList.regiments.length.toString(),
                Icons.group,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Characters',
                armyList.characters.length.toString(),
                Icons.person,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'Activations',
                (armyList.regiments.length + armyList.characters.length)
                    .toString(),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
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
        // First row - Basic metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCard(
                'Total Wounds',
                score.totalWounds.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCard(
                'Points/Wound',
                score.pointsPerWound.toStringAsFixed(1),
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCard(
                'Avg Speed',
                score.averageSpeed.toStringAsFixed(1),
                Icons.directions_run,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row - Combat metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCard(
                'Hit Volume',
                score.expectedHitVolume.toStringAsFixed(1),
                Icons.gps_fixed,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCard(
                'Cleave',
                score.cleaveRating.toStringAsFixed(1),
                Icons.cut,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCard(
                'Max Range',
                score.maxRange.toString(),
                Icons.speed,
                Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Third row - Ranged metrics
        Row(
          children: [
            Expanded(
              child: _buildCompactScoreCard(
                'Ranged Hits',
                score.rangedExpectedHits.toStringAsFixed(1),
                Icons.my_location,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactScoreCard(
                'Armor Pierce',
                score.rangedArmorPiercingRating.toStringAsFixed(1),
                Icons.shield,
                Colors.indigo,
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
        // Fourth row - Defensive metrics
        Row(
          children: [
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
              child: _buildEffectiveWoundsDefenseCompactScoreCard(
                'Eff. Wounds (Def)',
                score.effectiveWoundsDefense.toStringAsFixed(1),
                Icons.favorite_border,
                Colors.deepPurple,
                score.effectiveWoundsDefense,
                context,
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
          ],
        ),
        const SizedBox(height: 8),
        // Fifth row - Resolve impact metric
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
              child: Container(),
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

  Widget _buildCompactScoreCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
}
