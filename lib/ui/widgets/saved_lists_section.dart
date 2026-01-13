import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repositories/saved_lists_repository.dart';
import '../../models/list_score.dart';

/// Reusable widget for displaying and managing saved army lists
/// Can be embedded in other screens or used standalone
class SavedListsSection extends StatefulWidget {
  final SavedListsRepository repository;
  final Function(ListScore)? onListLoad; // Called when user taps to load a list
  final Function(List<ListScore>)? onCompare; // Called when compare button is pressed
  final Function(String)? onShare; // Called when share button is pressed for a list
  final Function()? onListsChanged; // Called when lists are added/deleted
  final bool showEmptyState; // Whether to show empty state message

  const SavedListsSection({
    Key? key,
    required this.repository,
    this.onListLoad,
    this.onCompare,
    this.onShare,
    this.onListsChanged,
    this.showEmptyState = true,
  }) : super(key: key);

  @override
  State<SavedListsSection> createState() => _SavedListsSectionState();
}

class _SavedListsSectionState extends State<SavedListsSection> {
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
      final lists = await widget.repository.getListMetadata();
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
      final listScore = await widget.repository.loadList(metadata.id);
      if (listScore != null && mounted) {
        widget.onListLoad?.call(listScore);
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
      final listScore = await widget.repository.loadList(id);
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

    // Call callback with loaded lists
    widget.onCompare?.call(listsToCompare);
  }

  Future<void> _shareList(SavedListMetadata metadata) async {
    try {
      final listScore = await widget.repository.loadList(metadata.id);
      if (listScore != null && mounted) {
        final shareText = listScore.toShareableText();
        widget.onShare?.call(shareText);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading list for sharing: $e')),
        );
      }
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
        await widget.repository.deleteList(metadata.id);
        // Also remove from selection if it was selected
        _selectedListIds.remove(metadata.id);
        await _loadSavedLists();
        widget.onListsChanged?.call();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with compare button
        if (_savedLists != null && _savedLists!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  _selectedListIds.isEmpty
                      ? 'Saved Lists'
                      : 'Selected: ${_selectedListIds.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _selectedListIds.isEmpty ? null : _compareLists,
                  icon: const Icon(Icons.analytics),
                  label: Text(_selectedListIds.length <= 1
                      ? 'Show Metrics'
                      : 'Compare Lists'),
                ),
              ],
            ),
          ),
        // Lists content
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedLists == null || _savedLists!.isEmpty) {
      if (!widget.showEmptyState) {
        return const SizedBox.shrink();
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Analyze a list above to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              // Share button
              if (widget.onShare != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () => _shareList(metadata),
                  tooltip: 'Share',
                ),
              // Delete button
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

  // Public method to refresh the list (can be called from parent)
  void refresh() {
    _loadSavedLists();
  }
}
