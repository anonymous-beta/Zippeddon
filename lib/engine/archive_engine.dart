
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../core/config.dart';
import '../models/archive_config.dart';
import '../models/archive_result.dart';

class ArchiveEngine {
  Future<ArchiveResult> build({
    required ArchiveConfig config,
    required Directory outputDirectory,
  }) async {
    final validation = config.validate();

    if (validation.isNotEmpty) {
      throw ArgumentError(validation);
    }

    if (!await outputDirectory.exists()) {
      await outputDirectory.create(recursive: true);
    }

    final stopwatch = Stopwatch()..start();
    final archive = Archive();
    final safeName = _safeFilename(config.filename);

    final perEntry = config.sampleBytes ~/ config.entryCount;
    final remainder = config.sampleBytes % config.entryCount;

    var originalBytes = 0;

    for (var i = 0; i < config.entryCount; i++) {
      final length = perEntry + (i < remainder ? 1 : 0);

      if (length <= 0) continue;

      final data = _createBenchmarkData(length, i);

      archive.addFile(
        ArchiveFile(
          'benchmark/entry_${i + 1}.txt',
          data.length,
          data,
        ),
      );

      originalBytes += data.length;
    }

    final encoded = ZipEncoder().encode(archive);

    if (encoded.isEmpty) {
      throw StateError('ZIP encoding returned empty data.');
    }

    if (encoded.length > ZippeddonConfig.maxSampleBytes * 2) {
      throw StateError('Archive output limit exceeded.');
    }

    final output = File('${outputDirectory.path}/$safeName');

    await output.writeAsBytes(encoded, flush: true);

    final digest = sha256.convert(encoded);

    stopwatch.stop();

    return ArchiveResult(
      filename: safeName,
      path: output.path,
      originalBytes: originalBytes,
      compressedBytes: encoded.length,
      entryCount: config.entryCount,
      elapsed: stopwatch.elapsed,
      checksum: digest.toString(),
      createdAt: DateTime.now(),
    );
  }

  Uint8List _createBenchmarkData(int length, int seed) {
    final output = Uint8List(length);

    final pattern = utf8.encode(
      'ZIPPEDDON-ANONYMOUS-BETA-BENCHMARK-$seed-',
    );

    for (var i = 0; i < length; i++) {
      output[i] = pattern[i % pattern.length];
    }

    return output;
  }

  String _safeFilename(String input) {
    final clean = input
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    if (clean.isEmpty) {
      return 'zippeddon_archive.zip';
    }

    if (clean.toLowerCase().endsWith('.zip')) {
      return clean;
    }

    return '$clean.zip';
  }
}
