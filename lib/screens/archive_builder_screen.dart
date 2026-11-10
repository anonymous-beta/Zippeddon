
import 'dart:io';

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../engine/archive_engine.dart';
import '../models/archive_config.dart';
import '../services/history_service.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';

class ArchiveBuilderScreen extends StatefulWidget {
  const ArchiveBuilderScreen({super.key});

  @override
  State<ArchiveBuilderScreen> createState() =>
      _ArchiveBuilderScreenState();
}

class _ArchiveBuilderScreenState extends State<ArchiveBuilderScreen> {
  final _engine = ArchiveEngine();
  final _storage = StorageService();
  final _history = HistoryService();
  final _share = ShareService();

  int _entries = 10;
  int _sizePerEntry = 64 * 1024;
  bool _busy = false;
  String? _message;
  File? _createdFile;

  int get _estimatedSize => _entries * _sizePerEntry;

  Future<void> _buildArchive() async {
    setState(() {
      _busy = true;
      _message = null;
      _createdFile = null;
    });

    try {
      final config = ArchiveConfig(
        entryCount: _entries,
        bytesPerEntry: _sizePerEntry,
      );

      final result = await _engine.build(config);
      final file = await _storage.saveArchive(
        result.bytes,
        result.fileName,
      );

      await _history.addEntry(
        HistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          fileName: file.uri.pathSegments.last,
          filePath: file.path,
          archiveSize: result.bytes.length,
          uncompressedSize: result.uncompressedSize,
          fileCount: result.fileCount,
          createdAt: DateTime.now(),
          operation: 'Archive build',
        ),
      );

      if (!mounted) return;

      setState(() {
        _createdFile = file;
        _message = 'Archive created successfully.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Build failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareArchive() async {
    final file = _createdFile;
    if (file == null) return;

    try {
      await _share.shareArchive(file);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Sharing failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive Builder')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'BOUNDED TEST CONFIGURATION',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Text('Archive entries: $_entries'),
          Slider(
            value: _entries.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: _busy
                ? null
                : (value) => setState(() => _entries = value.round()),
          ),
          const SizedBox(height: 12),
          const Text('Bytes per entry'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _sizePerEntry,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Test entry size',
            ),
            items: const [
              DropdownMenuItem(
                value: 1024,
                child: Text('1 KB'),
              ),
              DropdownMenuItem(
                value: 16 * 1024,
                child: Text('16 KB'),
              ),
              DropdownMenuItem(
                value: 64 * 1024,
                child: Text('64 KB'),
              ),
              DropdownMenuItem(
                value: 256 * 1024,
                child: Text('256 KB'),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _sizePerEntry = value);
                    }
                  },
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UNCOMPRESSED TEST DATA'),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.bytes(_estimatedSize),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Maximum configured test data: 8 MB.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _buildArchive,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.archive),
            label: Text(_busy ? 'Building...' : 'Build Test Archive'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!),
          ],
          if (_createdFile != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _shareArchive,
              icon: const Icon(Icons.share),
              label: const Text('Share ZIP archive'),
            ),
            Text(
              _createdFile!.path,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
