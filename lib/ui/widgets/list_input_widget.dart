import 'package:flutter/material.dart';

class ListInputWidget extends StatefulWidget {
  final Function(String) onAnalyze;
  final bool isLoading;

  const ListInputWidget({
    super.key,
    required this.onAnalyze,
    required this.isLoading,
  });

  @override
  State<ListInputWidget> createState() => _ListInputWidgetState();
}

class _ListInputWidgetState extends State<ListInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Army List Input',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Paste your army list in the standard format:',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Fixed height instead of Expanded
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '''=== The Last Argument of Kings ===

MyArmy [1990/2000]
Nords

== Vargyr Lord [160]: Wild Beasts

 * Goltr Beastpack (3) [160]: 
 * Werewargs (3) [160]: 

== Shaman [80]: 

 * Raiders (3) [140]: Captain''',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => widget.onAnalyze(_controller.text),
                    child: widget.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Analyze List'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed:
                      widget.isLoading ? null : () => _controller.clear(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
