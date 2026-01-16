import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/reinforcement_metrics.dart';

/// Dialog displaying reinforcement timing distribution across percentiles
class ReinforcementDistributionGraph extends StatefulWidget {
  final ReinforcementMetrics metrics;
  final int? specificTurn; // null = show all turns, 1-5 = show specific turn
  final bool compact; // If true, renders without dialog wrapper and reduced padding
  final bool showLegend; // If true, shows legend (only used in non-compact mode)

  const ReinforcementDistributionGraph({
    super.key,
    required this.metrics,
    this.specificTurn,
    this.compact = false,
    this.showLegend = true,
  });

  @override
  State<ReinforcementDistributionGraph> createState() =>
      _ReinforcementDistributionGraphState();
}

class _ReinforcementDistributionGraphState
    extends State<ReinforcementDistributionGraph> {
  // Track which turns are visible (all visible by default)
  final Map<int, bool> _visibleTurns = {
    1: true,
    2: true,
    3: true,
    4: true,
  };

  @override
  void initState() {
    super.initState();
    // If showing specific turn, only that turn is visible
    if (widget.specificTurn != null) {
      for (int turn = 1; turn <= 4; turn++) {
        _visibleTurns[turn] = turn == widget.specificTurn;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactContent();
    }
    
    final title = widget.specificTurn != null
        ? 'Turn ${widget.specificTurn} Distribution'
        : 'Reinforcement Distribution';

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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
            const SizedBox(height: 8),
            Text(
              'Regiment count by percentile (${widget.metrics.totalEligibleRegiments} total regiments)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Legend with checkboxes (only show if all turns mode)
            if (widget.specificTurn == null && widget.showLegend) ...[
              Wrap(
                spacing: 16,
                children: [
                  for (int turn = 1; turn <= 5; turn++)
                    _buildLegendItem(turn),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Graph
            Expanded(
              child: _buildGraph(),
            ),

            const SizedBox(height: 16),

            // Footer explanation
            Text(
              'X-axis: Percentiles (10th to 90th) | Y-axis: Regiment count',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact legend at top (only if showing all turns)
        if (widget.specificTurn == null && widget.showLegend) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (int turn = 1; turn <= 4; turn++)
                _buildCompactLegendItem(turn),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Graph takes remaining space
        Expanded(
          child: _buildGraph(),
        ),
      ],
    );
  }

  Widget _buildCompactLegendItem(int turn) {
    final color = _getTurnColor(turn);
    final isVisible = _visibleTurns[turn] ?? true;

    return InkWell(
      onTap: () {
        setState(() {
          _visibleTurns[turn] = !isVisible;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Checkbox(
              value: isVisible,
              onChanged: (value) {
                setState(() {
                  _visibleTurns[turn] = value ?? true;
                });
              },
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 20,
            height: 2,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            'T$turn',
            style: TextStyle(
              fontSize: 11,
              color: isVisible ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(int turn) {
    final color = _getTurnColor(turn);
    final isVisible = _visibleTurns[turn] ?? true;

    return GestureDetector(
      onTap: () {
        setState(() {
          _visibleTurns[turn] = !isVisible;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isVisible,
              onChanged: (value) {
                setState(() {
                  _visibleTurns[turn] = value ?? true;
                });
              },
              activeColor: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 30,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            'Turn $turn',
            style: TextStyle(
              fontSize: 14,
              color: isVisible ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraph() {
    final percentiles = [10, 20, 30, 40, 50, 60, 70, 80, 90];
    final maxY = widget.metrics.totalEligibleRegiments.toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY > 10 ? (maxY / 10).ceilToDouble() : 1,
          verticalInterval: 10,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY > 10 ? (maxY / 5).ceilToDouble() : 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 10,
              getTitlesWidget: (value, meta) {
                if (value % 10 == 0 && value >= 10 && value <= 90) {
                  return Text(
                    'P${value.toInt()}',
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 10,
        maxX: 90,
        minY: 0,
        maxY: maxY,
        lineBarsData: _buildLineBars(percentiles),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              if (touchedSpots.isEmpty) return [];
              
              // Sort by turn (ascending)
              final sortedSpots = touchedSpots.toList()
                ..sort((a, b) => a.barIndex.compareTo(b.barIndex));
              
              // Get percentile from first spot (all should have same x)
              final percentile = sortedSpots.first.x.toInt();
              
              // Build tooltip with P value at top, then turns
              final tooltipItems = <LineTooltipItem>[];
              
              for (int i = 0; i < sortedSpots.length; i++) {
                final spot = sortedSpots[i];
                final turn = spot.barIndex + 1;
                final regimentCount = spot.y.toInt();
                
                String text;
                if (i == 0) {
                  // First line: show P value
                  text = 'P$percentile\nTurn $turn: $regimentCount reg';
                } else {
                  // Subsequent lines: just turn and count
                  text = 'Turn $turn: $regimentCount reg';
                }
                
                tooltipItems.add(
                  LineTooltipItem(
                    text,
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              
              return tooltipItems;
            },
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBars(List<int> percentiles) {
    final List<LineChartBarData> bars = [];

    for (int turn = 1; turn <= 4; turn++) {
      if (!(_visibleTurns[turn] ?? true)) continue;

      final spots = percentiles.map((p) {
        final regimentCount =
            widget.metrics.getRegimentCount(turn, p).toDouble();
        return FlSpot(p.toDouble(), regimentCount);
      }).toList();

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getTurnColor(turn),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _getTurnColor(turn),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      );
    }

    return bars;
  }

  Color _getTurnColor(int turn) {
    final colors = [
      Colors.green, // Turn 1
      Colors.lightGreen, // Turn 2
      Colors.amber, // Turn 3
      Colors.orange, // Turn 4
    ];
    return colors[turn - 1];
  }
}
