
import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../core/formatters.dart';
import '../engine/benchmark_engine.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  final BenchmarkEngine _engine = BenchmarkEngine();

  int _size = 1024 * 1024;
  bool _running = false;
  String? _error;
  BenchmarkResult? _result;

  Future<void> _run() async {
    if (_running) return;

    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _engine.run(
        bytes: _size,
        seed: DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;

      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;

      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compression Benchmark'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'COMPRESSION PERFORMANCE LAB',
            style: TextStyle(
              color: AppTheme.magma,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            initialValue: _size,
            decoration: const InputDecoration(
              labelText: 'Dataset size',
            ),
            items: const [
              DropdownMenuItem(
                value: 256 * 1024,
                child: Text('256 KB'),
              ),
              DropdownMenuItem(
                value: 1024 * 1024,
                child: Text('1 MB'),
              ),
              DropdownMenuItem(
                value: 2 * 1024 * 1024,
                child: Text('2 MB'),
              ),
              DropdownMenuItem(
                value: 4 * 1024 * 1024,
                child: Text('4 MB'),
              ),
            ],
            onChanged: _running
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _size = value);
                    }
                  },
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_running ? 'RUNNING...' : 'RUN BENCHMARK'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 24),
            _metric('Original data', Formatters.bytes(result.originalSize)),
            _metric(
              'Compressed archive',
              Formatters.bytes(result.compressedSize),
            ),
            _metric(
              'Compression ratio',
              Formatters.ratio(result.ratio),
            ),
            _metric(
              'Compression time',
              '${result.compressionTime.inMilliseconds} ms',
            ),
            _metric(
              'Decompression time',
              '${result.decompressionTime.inMilliseconds} ms',
            ),
            _metric(
              'Compression speed',
              '${result.compressionSpeed.toStringAsFixed(2)} MB/s',
            ),
            _metric(
              'Integrity verification',
              result.integrityVerified ? 'PASSED' : 'FAILED',
              highlight: result.integrityVerified,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        trailing: Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlight ? AppTheme.toxic : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
