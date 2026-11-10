
import 'dart:io';

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _history = HistoryService();

  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _history.getEntries();

    if (!mounted) return;

    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _delete(HistoryEntry entry) async {
    await _history.deleteEntry(entry.id);

    if (mounted) {
      setState(() => _entries.removeWhere((e) => e.id == entry.id));
    }
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This removes the recorded history entries. '
          'It does not delete the archive files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _history.clear();
    if (mounted) setState(() => _entries.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive History'),
        actions: [
          IconButton(
            onPressed: _entries.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text('No archive operations recorded yet.'),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.folder_zip),
                          title: Text(entry.fileName),
                          subtitle: Text(
                            '${entry.operation}\n'
                            '${Formatters.date(entry.createdAt)}\n'
                            'Archive: ${Formatters.bytes(entry.archiveSize)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(entry),
                          ),
                          onTap: () {
                            final exists = File(entry.filePath).existsSync();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  exists
                                      ? 'Archive file is available.'
                                      : 'Archive file is no longer available.',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
