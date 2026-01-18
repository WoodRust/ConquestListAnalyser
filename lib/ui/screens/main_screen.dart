import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/list_parser.dart';
import '../../services/scoring_engine.dart';
import '../../models/list_score.dart';
import '../../repositories/saved_lists_repository.dart';
import '../widgets/list_input_widget.dart';
import '../widgets/saved_lists_section.dart';
import 'compare_lists_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ListParser _parser = ListParser();
  final ScoringEngine _scoringEngine = ScoringEngine();
  final SavedListsRepository _repository = SavedListsRepository();
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<State<SavedListsSection>> _savedListsKey = GlobalKey();

  bool _isLoading = false;
  String? _errorMessage;

  /// Analyze the army list and calculate scores
  Future<void> _analyzeList(String inputText) async {
    if (inputText.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse list first to extract name
      final armyList = await _parser.parseList(inputText);
      
      setState(() {
        _isLoading = false;
      });

      // Show save dialog immediately with pre-filled name
      final customName = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(
            text: armyList.name,
          );
          return AlertDialog(
            title: const Text('Save List'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter a name for this list',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (customName == null || customName.trim().isEmpty) {
        setState(() {
          _errorMessage = null;
        });
        return;
      }

      // Now run scoring calculations with loading state
      setState(() {
        _isLoading = true;
      });

      final score = _scoringEngine.calculateScores(armyList);

      // Create updated army list with custom name
      final updatedArmyList = armyList.copyWith(name: customName);
      final updatedScore = ListScore(
        armyList: updatedArmyList,
        totalWounds: score.totalWounds,
        pointsPerWound: score.pointsPerWound,
        expectedHitVolume: score.expectedHitVolume,
        impactExpectedVolume: score.impactExpectedVolume,
        cleaveRating: score.cleaveRating,
        rangedExpectedHits: score.rangedExpectedHits,
        rangedArmorPiercingRating: score.rangedArmorPiercingRating,
        maxRange: score.maxRange,
        averageSpeed: score.averageSpeed,
        toughness: score.toughness,
        evasion: score.evasion,
        effectiveWoundsDefense: score.effectiveWoundsDefense,
        effectiveWoundsDefenseResolve: score.effectiveWoundsDefenseResolve,
        resolveImpactPercentage: score.resolveImpactPercentage,
        pointsPerEffectiveWoundDefense: score.pointsPerEffectiveWoundDefense,
        pointsPerEffectiveWoundDefenseResolve:
            score.pointsPerEffectiveWoundDefenseResolve,
        scoringStands: score.scoringStands,
        magicCapability: score.magicCapability,
        expectedHealingCapability: score.expectedHealingCapability,
        reinforcementMetrics: score.reinforcementMetrics,
        calculatedAt: score.calculatedAt,
      );

      // Save the list
      final id = _repository.generateId();
      await _repository.saveList(id, updatedScore);

      setState(() {
        _isLoading = false;
      });

      // Refresh saved lists section
      (_savedListsKey.currentState as dynamic)?.refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List saved successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing list: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Share list results
  void _shareList(String shareText) {
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results copied to clipboard!')),
    );
  }

  /// Navigate to compare/analysis screen
  void _navigateToAnalysis(List<ListScore> lists) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareListsScreen(
          listsToCompare: lists,
        ),
      ),
    );
  }

  /// Load a list into the input field
  void _loadListToInput(ListScore score) {
    setState(() {
      _inputController.text = _reconstructListText(score);
    });
  }

  /// Reconstruct list text from a loaded score
  String _reconstructListText(ListScore score) {
    final buffer = StringBuffer();
    buffer.writeln('=== The Last Argument of Kings ===');
    buffer.writeln();
    buffer.writeln('${score.armyList.name} [${score.armyList.totalPoints}/${score.armyList.pointsLimit}]');
    buffer.writeln(score.armyList.faction);
    buffer.writeln();

    for (final regiment in score.armyList.regiments) {
      if (regiment.unit.regimentClass == 'character') {
        buffer.write('== ${regiment.unit.name} [${regiment.pointsCost}]');
      } else {
        buffer.write(
            '* ${regiment.unit.name} (${regiment.stands}) [${regiment.pointsCost}]');
      }

      if (regiment.upgrades.isNotEmpty) {
        buffer.write(': ${regiment.upgrades.join(", ")}');
      }

      if (regiment.isWarlord) {
        buffer.write(' [Warlord]');
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquest List Analyzer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section - smaller
            ListInputWidget(
              controller: _inputController,
              onAnalyze: _analyzeList,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // Saved Lists section - takes remaining space
            Expanded(
              child: Stack(
                children: [
                  SavedListsSection(
                    key: _savedListsKey,
                    repository: _repository,
                    onListLoad: _loadListToInput,
                    onCompare: _navigateToAnalysis,
                    onShare: _shareList,
                    showEmptyState: true,
                  ),
                  // Loading overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Calculating scores...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Error overlay
                  if (_errorMessage != null)
                    Container(
                      color: Colors.black26,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                  child: const Text('Dismiss'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
