
import 'dart:io';

import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/formatters.dart';
import '../engine/archive_engine.dart';
import '../models/archive_config.dart';
import '../models/archive_result.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';

class ArchiveBuilderScreen extends StatefulWidget {
  const ArchiveBuilderScreen({super.key});

  @override
  State<ArchiveBuilderScreen> createState() =>
      _ArchiveBuilderScreenState();
}

class _ArchiveBuilderScreenState extends State<ArchiveBuilderScreen> {
  final ArchiveEngine _engine = ArchiveEngine();
  final StorageService _storage = StorageService();
  final HistoryService _history = HistoryService();
  final ShareService _share = ShareService();

  int _entries = 10;
  int _totalBytes = 1024 * 1024;
  int _compressionLevel = 6;

  bool _busy = false;
  String? _message;
  ArchiveResult? _result;

  int get _safeTotalBytes =>
      _totalBytes.clamp(1024, 8 * 1024 * 1024);

  Future<void> _buildArchive() async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _message = null;
      _result = null;
    });

    try {
      final directory = await _storage.archiveDirectory();

      final config = ArchiveConfig(
        filename:
            'zippeddon_${DateTime.now().millisecondsSinceEpoch}.zip',
        sampleBytes: _safeTotalBytes,
        entryCount: _entries,
        compressionLevel: _compressionLevel,
        nestingDepth: 0,
      );

      final result = await _engine.build(
        config: config,
        outputDirectory: directory,
      );

      final entry = HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: result.filename,
        filePath: result.path,
        archiveSize: result.compressedBytes,
        uncompressedSize: result.originalBytes,
        fileCount: result.entryCount,
        createdAt: result.createdAt,
        operation: 'Archive build',
      );

      await _history.addEntry(entry);

      if (!mounted) return;

      setState(() {
        _result = result;
        _message = 'Archive created successfully.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Archive creation failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _shareArchive() async {
    final result = _result;
    if (result == null) return;

    try {
      await _share.shareArchive(result.path);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Sharing failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Builder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'CONTROLLED ARCHIVE GENERATOR',
            style: TextStyle(
              color: AppTheme.magma,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Archive entries: $_entries',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _entries.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: _busy
                ? null
                : (value) {
                    setState(() => _entries = value.round());
                  },
          ),
          const SizedBox(height: 18),
          const Text(
            'Uncompressed test dataset',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _totalBytes,
            decoration: const InputDecoration(
              labelText: 'Dataset size',
            ),
            items: const [
              DropdownMenuItem(
                value: 64 * 1024,
                child: Text('64 KB'),
              ),
              DropdownMenuItem(
                value: 256 * 1024,
                child: Text('256 KB'),
              ),
              DropdownMenuItem(
                value: 1024 * 1024,
                child: Text('1 MB'),
              ),
              DropdownMenuItem(
                value: 4 * 1024 * 1024,
                child: Text('4 MB'),
              ),
              DropdownMenuItem(
                value: 8 * 1024 * 1024,
                child: Text('8 MB'),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _totalBytes = value);
                    }
                  },
          ),
          const SizedBox(height: 18),
          const Text(
            'Compression level',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _compressionLevel.toDouble(),
            min: 0,
            max: 9,
            divisions: 9,
            label: '$_compressionLevel',
            onChanged: _busy
                ? null
                : (value) {
                    setState(() {
                      _compressionLevel = value.round();
                    });
                  },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONFIGURATION SUMMARY',
                    style: TextStyle(
                      color: AppTheme.toxic,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _metric('Dataset', Formatters.bytes(_safeTotalBytes)),
                  _metric('Entries', '$_entries'),
                  _metric('Compression level', '$_compressionLevel / 9'),
                  _metric('Nesting', 'Disabled'),
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
                : const Icon(Icons.folder_zip),
            label: Text(
              _busy ? 'BUILDING ARCHIVE...' : 'BUILD ZIP ARCHIVE',
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!),
          ],
          if (result != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUILD RESULT',
                      style: TextStyle(
                        color: AppTheme.toxic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _metric('Filename', result.filename),
                    _metric(
                      'Original size',
                      Formatters.bytes(result.originalBytes),
                    ),
                    _metric(
                      'ZIP size',
                      Formatters.bytes(result.compressedBytes),
                    ),
                    _metric(
                      'Compression ratio',
                      Formatters.ratio(result.compressionRatio),
                    ),
                    _metric('Time', '${result.elapsed.inMilliseconds} ms'),
                    _metric('SHA-256', result.checksum),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _shareArchive,
              icon: const Icon(Icons.share),
              label: const Text('Share archive'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
