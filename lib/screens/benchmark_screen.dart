
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../engine/benchmark_engine.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  final _engine = BenchmarkEngine();

  int _size = 1024 * 1024;
  bool _running = false;
  String? _error;
  dynamic _result;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _engine.run(bytesToGenerate: _size);

      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compression Benchmark')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'CONTROLLED DATA BENCHMARK',
            style: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: _size,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
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
                    if (value != null) setState(() => _size = value);
                  },
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_running ? 'Running...' : 'Run Benchmark'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            _MetricCard(
              label: 'Original data',
              value: Formatters.bytes(_result.originalSize as int),
            ),
            _MetricCard(
              label: 'Compressed archive',
              value: Formatters.bytes(_result.compressedSize as int),
            ),
            _MetricCard(
              label: 'Compression ratio',
              value: Formatters.ratio(_result.ratio as double),
            ),
            _MetricCard(
              label: 'Elapsed time',
              value: '${_result.elapsedMilliseconds} ms',
            ),
            _MetricCard(
              label: 'Integrity check',
              value: _result.integrityPassed ? 'PASSED' : 'FAILED',
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
