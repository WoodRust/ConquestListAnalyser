import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/list_parser.dart';
import '../../services/scoring_engine.dart';
import '../../models/list_score.dart';
import '../widgets/list_input_widget.dart';
import '../widgets/score_display_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ListParser _parser = ListParser();
  final ScoringEngine _scoringEngine = ScoringEngine();

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
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: _shareResults,
                              tooltip: 'Share Results',
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
