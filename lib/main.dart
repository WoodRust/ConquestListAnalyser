import 'package:flutter/material.dart';
import 'ui/screens/main_screen.dart';

void main() {
  runApp(const ConquestAnalyzerApp());
}

class ConquestAnalyzerApp extends StatelessWidget {
  const ConquestAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conquest List Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}
