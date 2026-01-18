import 'package:flutter/material.dart';
import '../../models/list_score.dart';
import '../../services/metric_tooltips.dart';
import '../widgets/reinforcement_distribution_graph.dart';

class CompareListsScreen extends StatelessWidget {
  final List<ListScore> listsToCompare;

  const CompareListsScreen({
    super.key,
    required this.listsToCompare,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Results'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Metrics', icon: Icon(Icons.analytics)),
              Tab(text: 'Regiment Details', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMetricsTab(context),
            _buildRegimentDetailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsTab(BuildContext context) {
    return Column(
      children: [
        _buildStickyHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: _buildMetricsTable(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRegimentDetailsTab() {
    return SingleChildScrollView(
      child: _buildRegimentDetailsTable(),
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
        // Army Composition Section
        _buildArmyCompositionSectionHeader(),
        _buildMetricRow(
            'Regiments',
            listsToCompare
                .map((l) => (l.armyList.nonCharacterRegiments.length +
                        l.armyList.characterMonsters.length)
                    .toDouble())
                .toList(),
            true,
            null,
            false),
        _buildMetricRow(
            'Characters',
            listsToCompare
                .map((l) => l.armyList.characters.length.toDouble())
                .toList(),
            false,
            null,
            false),
        _buildMetricRow(
            'Activations',
            listsToCompare
                .map((l) => l.armyList.regiments.length.toDouble())
                .toList(),
            true,
            null,
            false),
        _buildMetricRow(
            'Scoring Stands',
            listsToCompare
                .map((l) => l.scoringStands.toDouble())
                .toList(),
            true,
            () => MetricTooltips.showScoringStandsTooltip(context),
            false),
        _buildMetricRow(
            'Light Regiments',
            listsToCompare
                .map((l) => l.armyList.lightRegimentCount.toDouble())
                .toList(),
            false,
            null,
            false),
        _buildMetricRow(
            'Medium Regiments',
            listsToCompare
                .map((l) => l.armyList.mediumRegimentCount.toDouble())
                .toList(),
            false,
            null,
            false),
        _buildMetricRow(
            'Heavy Regiments',
            listsToCompare
                .map((l) => l.armyList.heavyRegimentCount.toDouble())
                .toList(),
            false,
            null,
            false),

        // Durability Section
        _buildDurabilitySectionHeader(context),
        _buildMetricRow('Total Wounds',
            listsToCompare.map((l) => l.totalWounds.toDouble()).toList(), true,
            () => MetricTooltips.showTotalWoundsTooltip(context), false),
        _buildMetricRow('Points per Wound',
            listsToCompare.map((l) => l.pointsPerWound).toList(), true,
            () => MetricTooltips.showPointsPerWoundTooltip(context), true),
        _buildMetricRow('Effective Wounds (Defense)',
            listsToCompare.map((l) => l.effectiveWoundsDefense).toList(), true,
            () => MetricTooltips.showEffectiveWoundsDefenseTooltip(context), false),
        _buildMetricRow(
            'Pts per Eff. Wound (Def)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefense)
                .toList(),
            true,
            () => MetricTooltips.showPointsPerEffectiveWoundDefenseTooltip(context), true),
        _buildMetricRow(
            'Effective Wounds (D&R)',
            listsToCompare.map((l) => l.effectiveWoundsDefenseResolve).toList(),
            true,
            () => MetricTooltips.showEffectiveWoundsDefenseResolveTooltip(context), false),
        _buildMetricRow(
            'Pts per Eff. Wound (D&R)',
            listsToCompare
                .map((l) => l.pointsPerEffectiveWoundDefenseResolve)
                .toList(),
            true,
            () => MetricTooltips.showPointsPerEffectiveWoundDefenseResolveTooltip(context), true),
        _buildMetricRow(
            'Resolve Impact',
            listsToCompare.map((l) => l.resolveImpactPercentage).toList(),
            true,
            () => MetricTooltips.showResolveImpactTooltip(context), false),
        _buildMetricRow(
            'Toughness', listsToCompare.map((l) => l.toughness).toList(), true,
            () => MetricTooltips.showToughnessTooltip(context), false),
        _buildMetricRow(
            'Evasion', listsToCompare.map((l) => l.evasion).toList(), true,
            () => MetricTooltips.showEvasionTooltip(context), false),
        _buildMetricRow(
            'Expected Healing Capability',
            listsToCompare
                .map((l) => l.expectedHealingCapability.toDouble())
                .toList(),
            true,
            () => MetricTooltips.showExpectedHealingCapabilityTooltip(context), false),

        // Damage Potential Section
        _buildDamagePotentialSectionHeader(context),
        _buildMetricRow('Expected Hit Volume',
            listsToCompare.map((l) => l.expectedHitVolume).toList(), true,
            () => MetricTooltips.showHitVolumeTooltip(context), false),
        _buildMetricRow('Impact Expected Volume',
            listsToCompare.map((l) => l.impactExpectedVolume).toList(), true,
            () => MetricTooltips.showImpactExpectedVolumeTooltip(context), false),
        _buildMetricRow('Cleave Rating',
            listsToCompare.map((l) => l.cleaveRating).toList(), true,
            () => MetricTooltips.showCleaveTooltip(context), false),
        _buildMetricRow('Ranged Expected Hits',
            listsToCompare.map((l) => l.rangedExpectedHits).toList(), true,
            () => MetricTooltips.showRangedHitsTooltip(context), false),
        _buildMetricRow(
            'Ranged Armor Piercing',
            listsToCompare.map((l) => l.rangedArmorPiercingRating).toList(),
            true,
            () => MetricTooltips.showArmorPierceTooltip(context), false),
        _buildMetricRow('Max Range',
            listsToCompare.map((l) => l.maxRange.toDouble()).toList(), true,
            () => MetricTooltips.showMaxRangeTooltip(context), false),
        _buildMetricRow(
            'Magic Capability',
            listsToCompare.map((l) => l.magicCapability.toDouble()).toList(),
            true,
            () => MetricTooltips.showMagicCapabilityTooltip(context), false),

        // Mobility
        _buildMetricRow('Average Speed',
            listsToCompare.map((l) => l.averageSpeed).toList(), true,
            () => MetricTooltips.showAvgSpeedTooltip(context), false),
        
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
      ],
    );
  }

  Widget _buildArmyCompositionSectionHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          top: BorderSide(color: Colors.blue.shade200, width: 2),
          bottom: BorderSide(color: Colors.blue.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Army Composition',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
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

  Widget _buildDurabilitySectionHeader(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(
          top: BorderSide(color: Colors.purple.shade200, width: 2),
          bottom: BorderSide(color: Colors.purple.shade200, width: 1),
        ),
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
                      'Durability',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.info_outline, size: 18, color: Colors.purple.shade700),
                    onPressed: () => MetricTooltips.showDurabilityTooltip(context),
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

  Widget _buildDamagePotentialSectionHeader(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(
          top: BorderSide(color: Colors.red.shade200, width: 2),
          bottom: BorderSide(color: Colors.red.shade200, width: 1),
        ),
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
                      'Damage Potential',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.info_outline, size: 18, color: Colors.red.shade700),
                    onPressed: () => MetricTooltips.showDamagePotentialTooltip(context),
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
                    onPressed: () => MetricTooltips.showReinforcementTooltip(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.show_chart, size: 18, color: Colors.orange.shade700),
                    tooltip: 'View distribution graphs',
                    onPressed: () => _showReinforcementGraphs(context),
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
    // Extract percentiles for this turn
    final p20Values = lists.map((list) {
      return list.reinforcementMetrics?.getP20(turnIndex + 1);
    }).toList();
    final p50Values = lists.map((list) {
      return list.reinforcementMetrics?.getP50(turnIndex + 1);
    }).toList();
    final p80Values = lists.map((list) {
      return list.reinforcementMetrics?.getP80(turnIndex + 1);
    }).toList();
    
    // Extract regiment counts
    final r20Values = lists.map((list) {
      return list.reinforcementMetrics?.getRegimentCount(turnIndex + 1, 20);
    }).toList();
    final r50Values = lists.map((list) {
      return list.reinforcementMetrics?.getRegimentCount(turnIndex + 1, 50);
    }).toList();
    final r80Values = lists.map((list) {
      return list.reinforcementMetrics?.getRegimentCount(turnIndex + 1, 80);
    }).toList();

    // Find best median (highest)
    double? bestMedian;
    final validMedians = p50Values.where((v) => v != null).map((v) => v!).toList();
    if (validMedians.isNotEmpty) {
      bestMedian = validMedians.reduce((a, b) => a > b ? a : b);
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
            final p20 = p20Values[index];
            final p50 = p50Values[index];
            final p80 = p80Values[index];
            final r20 = r20Values[index];
            final r50 = r50Values[index];
            final r80 = r80Values[index];

            if (p20 == null || p50 == null || p80 == null || r20 == null || r50 == null || r80 == null) {
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

            final isHighlighted = bestMedian != null && (p50 - bestMedian).abs() < 0.01;

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
                        '${p20.round()}%-${p50.round()}%-${p80.round()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$r20-$r50-$r80',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
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

  void _showReinforcementGraphs(BuildContext context) {
    // Show graphs for each list in a scrollable view
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 900,
            height: 700,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reinforcement Distribution Comparison',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: listsToCompare.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final list = listsToCompare[index];
                      if (list.reinforcementMetrics == null) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  list.armyList.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('No reinforcement data available'),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Card(
                        clipBehavior: Clip.none,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.armyList.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: ReinforcementDistributionGraph(
                                  metrics: list.reinforcementMetrics!,
                                  specificTurn: null,
                                  compact: true,
                                  showLegend: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegimentDetailsTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Regiment Details for All Lists',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...listsToCompare.map((listScore) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // List header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listScore.armyList.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listScore.armyList.faction} • ${listScore.armyList.totalPoints}/${listScore.armyList.pointsLimit} points',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Regiment table for this list
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    horizontalMargin: 0,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Text('Regiment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Stands', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Defense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Resolve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Wounds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Points', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Pts/Wound', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Hit Vol.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Cleave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Ranged', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                      DataColumn(label: Text('Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), numeric: true),
                    ],
                    rows: listScore.armyList.regiments.map((regiment) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 120,
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
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

}
