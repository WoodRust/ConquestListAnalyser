import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/list_parser.dart';
import '../../services/scoring_engine.dart';
import '../../models/list_score.dart';
import '../../repositories/saved_lists_repository.dart';
import '../widgets/list_input_widget.dart';
import '../widgets/score_display_widget.dart';
import 'saved_lists_screen.dart';

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

  ListScore? _currentScore;
  bool _isLoading = false;
  String? _errorMessage;

  /// Analyze the army list and calculate scores
  Future<void> _analyzeList(String inputText) async {
    if (inputText.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentScore = null;
    });

    try {
      final armyList = await _parser.parseList(inputText);
      final score = _scoringEngine.calculateScores(armyList);

      setState(() {
        _currentScore = score;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing list: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Share the score results
  void _shareResults() {
    if (_currentScore != null) {
      Clipboard.setData(ClipboardData(text: _currentScore!.toShareableText()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Results copied to clipboard!')),
      );
    }
  }

  /// Save the current list
  Future<void> _saveList() async {
    if (_currentScore == null) return;

    // Show dialog to optionally rename the list
    final customName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(
          text: _currentScore!.armyList.name,
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

    if (customName == null || customName.trim().isEmpty) return;

    try {
      final id = _repository.generateId();

      // Create a new army list with the custom name
      final updatedArmyList =
          _currentScore!.armyList.copyWith(name: customName);

      // Create a new score with the updated army list
      final updatedScore = ListScore(
        armyList: updatedArmyList,
        totalWounds: _currentScore!.totalWounds,
        pointsPerWound: _currentScore!.pointsPerWound,
        expectedHitVolume: _currentScore!.expectedHitVolume,
        cleaveRating: _currentScore!.cleaveRating,
        rangedExpectedHits: _currentScore!.rangedExpectedHits,
        rangedArmorPiercingRating: _currentScore!.rangedArmorPiercingRating,
        maxRange: _currentScore!.maxRange,
        averageSpeed: _currentScore!.averageSpeed,
        toughness: _currentScore!.toughness,
        evasion: _currentScore!.evasion,
        effectiveWoundsDefense: _currentScore!.effectiveWoundsDefense,
        effectiveWoundsDefenseResolve:
            _currentScore!.effectiveWoundsDefenseResolve,
        resolveImpactPercentage: _currentScore!.resolveImpactPercentage,
        pointsPerEffectiveWoundDefense:
            _currentScore!.pointsPerEffectiveWoundDefense,
        pointsPerEffectiveWoundDefenseResolve:
            _currentScore!.pointsPerEffectiveWoundDefenseResolve,
        magicCapability: _currentScore!.magicCapability,
        expectedHealingCapability: _currentScore!.expectedHealingCapability,
        calculatedAt: _currentScore!.calculatedAt,
      );

      await _repository.saveList(id, updatedScore);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving list: $e')),
        );
      }
    }
  }

  /// Navigate to saved lists screen
  Future<void> _viewSavedLists() async {
    final loadedScore = await Navigator.push<ListScore>(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedListsScreen(),
      ),
    );

    if (loadedScore != null) {
      // Reconstruct the list text and analyze
      setState(() {
        _currentScore = loadedScore;
        _inputController.text = _reconstructListText(loadedScore);
      });
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _viewSavedLists,
            tooltip: 'Saved Lists',
          ),
        ],
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

            // Results section - takes remaining space
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Analysis Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_currentScore != null)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.save),
                                  onPressed: _saveList,
                                  tooltip: 'Save List',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: _shareResults,
                                  tooltip: 'Share Results',
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildResultsContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      );
    }

    if (_currentScore != null) {
      return ScoreDisplayWidget(score: _currentScore!);
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Paste your army list above and tap "Analyze" to see the results',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
