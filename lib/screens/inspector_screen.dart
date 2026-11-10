
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../engine/archive_inspector.dart';

class InspectorScreen extends StatefulWidget {
  const InspectorScreen({super.key});

  @override
  State<InspectorScreen> createState() => _InspectorScreenState();
}

class _InspectorScreenState extends State<InspectorScreen> {
  final _inspector = ArchiveInspector();

  ArchiveInspection? _inspection;
  String? _error;
  bool _busy = false;
  bool? _safe;

  Future<void> _selectArchive() async {
    final selected = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (selected == null || selected.files.single.path == null) return;

    setState(() {
      _busy = true;
      _inspection = null;
      _error = null;
      _safe = null;
    });

    try {
      final inspection = await Future<ArchiveInspection>(() {
        return _inspector.inspectFile(
          File(selected.files.single.path!),
        );
      });

      var safe = true;
      try {
        _inspector.validateExtraction(inspection);
      } on ExtractionLimitException {
        safe = false;
      }

      if (!mounted) return;

      setState(() {
        _inspection = inspection;
        _safe = safe;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspection = _inspection;

    return Scaffold(
      appBar: AppBar(title: const Text('Archive Inspector')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'ZIP STRUCTURE ANALYSIS',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _busy ? null : _selectArchive,
            icon: const Icon(Icons.file_open),
            label: Text(_busy ? 'Inspecting...' : 'Choose ZIP File'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (inspection != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inspection.path),
                    const Divider(),
                    _info('Archive size', Formatters.bytes(inspection.archiveSize)),
                    _info('Expanded size', Formatters.bytes(inspection.totalUncompressedSize)),
                    _info('File count', '${inspection.fileCount}'),
                    _info('Expansion ratio', Formatters.ratio(inspection.expansionRatio)),
                    _info(
                      'Extraction policy',
                      _safe == true ? 'Within configured limits' : 'Limit exceeded',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ARCHIVE ENTRIES',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...inspection.entries.map(
              (entry) => Card(
                child: ListTile(
                  leading: Icon(
                    entry.isDirectory ? Icons.folder : Icons.insert_drive_file,
                  ),
                  title: Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Expanded: ${Formatters.bytes(entry.uncompressedSize)}',
                  ),
                  trailing: Text(
                    Formatters.ratio(entry.expansionRatio),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
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
