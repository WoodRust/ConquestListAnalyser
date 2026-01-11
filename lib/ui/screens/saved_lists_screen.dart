import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repositories/saved_lists_repository.dart';
import '../../models/list_score.dart';
import 'compare_lists_screen.dart';

/// Screen for browsing and managing saved army lists
class SavedListsScreen extends StatefulWidget {
  const SavedListsScreen({Key? key}) : super(key: key);

  @override
  State<SavedListsScreen> createState() => _SavedListsScreenState();
}

class _SavedListsScreenState extends State<SavedListsScreen> {
  final SavedListsRepository _repository = SavedListsRepository();
  List<SavedListMetadata>? _savedLists;
  bool _isLoading = true;
  final Set<String> _selectedListIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedLists();
  }

  Future<void> _loadSavedLists() async {
    setState(() => _isLoading = true);

    try {
      final lists = await _repository.getListMetadata();
      setState(() {
        _savedLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved lists: $e')),
        );
      }
    }
  }

  Future<void> _loadList(SavedListMetadata metadata) async {
    try {
      final listScore = await _repository.loadList(metadata.id);
      if (listScore != null && mounted) {
        // Return to main screen with the loaded list
        Navigator.pop(context, listScore);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading list: $e')),
        );
      }
    }
  }

  void _toggleListSelection(String listId) {
    setState(() {
      if (_selectedListIds.contains(listId)) {
        _selectedListIds.remove(listId);
      } else {
        if (_selectedListIds.length < 4) {
          _selectedListIds.add(listId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 4 lists can be compared')),
          );
        }
      }
    });
  }

  Future<void> _compareLists() async {
    if (_selectedListIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one list')),
      );
      return;
    }

    // Load all selected lists
    final listsToCompare = <ListScore>[];
    for (final id in _selectedListIds) {
      final listScore = await _repository.loadList(id);
      if (listScore != null) {
        listsToCompare.add(listScore);
      }
    }

    if (listsToCompare.length != _selectedListIds.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading some lists')),
        );
      }
      return;
    }

    // Navigate to compare screen (works with 1 or more lists)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompareListsScreen(
            listsToCompare: listsToCompare,
          ),
        ),
      );
    }
  }

  Future<void> _deleteList(SavedListMetadata metadata) async {
    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${metadata.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteList(metadata.id);
        // Also remove from selection if it was selected
        _selectedListIds.remove(metadata.id);
        await _loadSavedLists();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('List deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting list: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedListIds.isEmpty
            ? 'Saved Lists'
            : 'Select Lists (${_selectedListIds.length})'),
        actions: [
          if (_savedLists != null && _savedLists!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              tooltip: 'Compare Lists',
              onPressed: _compareLists,
            ),
          if (_savedLists != null && _savedLists!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Lists'),
                    content: const Text(
                        'Are you sure you want to delete all saved lists?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete All',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _repository.clearAll();
                  await _loadSavedLists();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All lists deleted')),
                    );
                    _selectedListIds.clear();
                  }
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedLists == null || _savedLists!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No saved lists yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Analyze a list and tap Save to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedLists!.length,
      itemBuilder: (context, index) {
        final metadata = _savedLists![index];
        return _buildListCard(metadata);
      },
    );
  }

  Widget _buildListCard(SavedListMetadata metadata) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final isSelected = _selectedListIds.contains(metadata.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () {
          // If any selections exist, toggle selection mode
          // Otherwise, load the list
          if (_selectedListIds.isNotEmpty) {
            _toggleListSelection(metadata.id);
          } else {
            _loadList(metadata);
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleListSelection(metadata.id),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metadata.faction,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${metadata.totalPoints}/${metadata.pointsLimit} points',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saved: ${dateFormat.format(metadata.savedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteList(metadata),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
